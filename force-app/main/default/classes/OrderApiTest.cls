@isTest
private class OrderApiTest {
    @isTest
    static void testDoPostAndGet() {
        Test.startTest();

        // Prepare RestContext for POST with proper JSON payload
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Name":"API Test","Status__c":"New","Total__c":50}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        OrderApi.doPost();
        System.assertEquals(201, RestContext.response.statusCode, 'Should return 201 Created');

        // Now test GET
        RestRequest getReq = new RestRequest();
        getReq.requestUri = '/services/apexrest/orders/';
        getReq.httpMethod = 'GET';
        RestContext.request = getReq;
        List<Order__c> results = OrderApi.doGet();
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'Should return at least one order');
    }

    @isTest
    static void testDoPostMissingName() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Status__c":"New","Total__c":50}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        OrderApi.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 for missing Name');
    }

    @isTest
    static void testDoPostNegativeTotal() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Name":"Negative","Total__c":-10}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        OrderApi.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 for negative total');
    }
}
