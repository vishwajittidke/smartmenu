/**
 * MenuApi — REST API endpoint for menu operations.
 * Delegates to MenuService per architecture.
 */
@RestResource(urlMapping='/menu/*')
global with sharing class MenuApi {

    @HttpGet
    global static List<Menu_Item__c> doGet() {
        RestRequest req = RestContext.request;
        String path = req.requestURI;
        // Extract restaurant ID from URL: /menu/<restaurantId>
        String[] parts = path.split('/');
        String lastSegment = parts[parts.size() - 1];

        if (lastSegment != 'menu' && lastSegment.length() >= 15) {
            // Treat as restaurant ID
            return MenuService.getMenuForRestaurant(lastSegment);
        }
        // Return all available items (top 50)
        return MenuSelector.selectAllAvailable(50);
    }

    @HttpPost
    global static void doPost() {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        try {
            Map<String, Object> payload = (Map<String, Object>)
                JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            String name = (String) payload.get('name');
            String description = (String) payload.get('description');
            Decimal price = payload.containsKey('price')
                ? Decimal.valueOf(String.valueOf(payload.get('price'))) : null;
            String category = (String) payload.get('category');
            String restaurantId = (String) payload.get('restaurantId');

            Menu_Item__c item = MenuService.createMenuItem(name, description, price, category, restaurantId);

            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(item));

        } catch (BusinessException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        }
    }
}
