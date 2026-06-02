/**
 * OrderApi — REST API endpoint for external order operations.
 * Refactored: delegates to Service Layer, includes input validation, versioned-ready.
 */
@RestResource(urlMapping='/orders/*')
global with sharing class OrderApi {

    @HttpGet
    global static List<Order__c> doGet() {
        return OrderSelector.selectRecentOrders(50);
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        String body = req.requestBody.toString();
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);

            // Input validation — supports both uppercase (metadata) and lowercase (JavaScript client) keys
            String name = payload.containsKey('Name') ? (String) payload.get('Name') : 
                          (payload.containsKey('name') ? (String) payload.get('name') : null);
            if (String.isBlank(name)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Name is required"}');
                return;
            }

            Decimal total = null;
            Object val = null;
            if (payload.containsKey('Total__c')) {
                val = payload.get('Total__c');
            } else if (payload.containsKey('total')) {
                val = payload.get('total');
            }
            if (val != null) {
                total = Decimal.valueOf(String.valueOf(val));
                if (total < 0) {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf('{"error":"Total cannot be negative"}');
                    return;
                }
            }

            String customerInput = payload.containsKey('Customer__c') ? (String) payload.get('Customer__c') : 
                                   (payload.containsKey('customer') ? (String) payload.get('customer') : null);
            
            Id resolvedContactId = null;
            if (String.isNotBlank(customerInput)) {
                resolvedContactId = resolveOrCreateContact(customerInput);
            }

            String restaurantId = payload.containsKey('Restaurant__c') ? (String) payload.get('Restaurant__c') : 
                                  (payload.containsKey('restaurant') ? (String) payload.get('restaurant') : null);

            // Delegate to Service Layer — ensures validation, events, and audit
            Order__c o = OrderService.createOrder(name, resolvedContactId, restaurantId);
            
            // Handle child order items if provided, otherwise set flat total
            List<Object> itemsList = payload.containsKey('items') ? (List<Object>) payload.get('items') : null;
            if (itemsList != null && !itemsList.isEmpty()) {
                List<Order_Item__c> childItems = new List<Order_Item__c>();
                for (Object itemObj : itemsList) {
                    Map<String, Object> itemMap = (Map<String, Object>) itemObj;
                    String menuItemId = (String) itemMap.get('menuItemId');
                    Decimal qty = itemMap.containsKey('quantity') ? Decimal.valueOf(String.valueOf(itemMap.get('quantity'))) : 1;
                    
                    Menu_Item__c menuItem = MenuSelector.selectById(menuItemId);
                    if (menuItem != null) {
                        childItems.add(new Order_Item__c(
                            Order__c = o.Id,
                            Menu_Item__c = menuItem.Id,
                            Quantity__c = qty,
                            Unit_Price__c = menuItem.Price__c
                        ));
                    }
                }
                if (!childItems.isEmpty()) {
                    insert childItems;
                }
            } else if (total != null) {
                o.Total__c = total;
                update o;
            }

            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(o));

        } catch (BusinessException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        } catch (Exception e) {
            res.statusCode = 500;
            String msg = e.getMessage() == null ? 'Unknown error' : String.escapeSingleQuotes(e.getMessage());
            res.responseBody = Blob.valueOf('{"error":"' + msg + '"}');
        }
    }

    private static Id resolveOrCreateContact(String customerName) {
        if (String.isBlank(customerName)) return null;
        
        // Check if it's already a valid Salesforce ID for Contact
        if (customerName.length() >= 15 && customerName.startsWith('003')) {
            try {
                Id cid = (Id)customerName;
                return cid;
            } catch (Exception e) {
                // Not a valid ID, fall back to name search
            }
        }
        
        // Split name into first and last
        String firstName = '';
        String lastName = customerName.trim();
        Integer spaceIdx = customerName.indexOf(' ');
        if (spaceIdx != -1) {
            firstName = customerName.substring(0, spaceIdx).trim();
            lastName = customerName.substring(spaceIdx + 1).trim();
        }
        if (String.isBlank(lastName)) {
            lastName = 'Customer';
        }
        
        // Look up by name
        List<Contact> contacts = [
            SELECT Id 
            FROM Contact 
            WHERE FirstName = :firstName AND LastName = :lastName 
            LIMIT 1
        ];
        if (!contacts.isEmpty()) {
            return contacts[0].Id;
        }
        
        // Create new Contact
        Contact c = new Contact(
            FirstName = firstName,
            LastName = lastName
        );
        insert c;
        return c.Id;
    }
}

