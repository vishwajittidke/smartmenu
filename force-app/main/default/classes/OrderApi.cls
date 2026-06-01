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

            // Input validation
            String name = payload.containsKey('Name') ? (String) payload.get('Name') : null;
            if (String.isBlank(name)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Name is required"}');
                return;
            }

            Decimal total = null;
            if (payload.containsKey('Total__c')) {
                Object val = payload.get('Total__c');
                total = (val == null) ? null : Decimal.valueOf(String.valueOf(val));
                if (total != null && total < 0) {
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf('{"error":"Total cannot be negative"}');
                    return;
                }
            }

            String customerId = payload.containsKey('Customer__c') ? (String) payload.get('Customer__c') : null;
            String restaurantId = payload.containsKey('Restaurant__c') ? (String) payload.get('Restaurant__c') : null;

            // Delegate to Service Layer — ensures validation, events, and audit
            Order__c o = OrderService.createOrder(name, customerId, restaurantId);
            // Set total after creation if provided (service layer doesn't accept total)
            if (total != null) {
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
}

