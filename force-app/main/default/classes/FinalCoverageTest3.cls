/**
 * FinalCoverageTest3 — Targets remaining uncovered lines to push past 75%.
 */
@isTest
private class FinalCoverageTest3 {

    // ─── OrderApi: POST with total (covers lines 51-53) ─────────────────
    @isTest
    static void testOrderApiPostWithTotal() {
        Account restaurant = TestDataFactory.createRestaurant('API Total Restaurant');
        Contact customer = TestDataFactory.createCustomer('Api', 'Total', restaurant.Id);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Name":"ORD-API-TOTAL","Total__c":99.99,"Customer__c":"' +
            customer.Id + '","Restaurant__c":"' + restaurant.Id + '"}');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        OrderApi.doPost();
        Test.stopTest();

        System.assertEquals(201, res.statusCode);
    }

    // ─── OrderApi: POST triggers BusinessException (covers lines 59-61) ──
    @isTest
    static void testOrderApiPostBusinessException() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        // Blank name after trim
        req.requestBody = Blob.valueOf('{"Name":"  "}');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        OrderApi.doPost();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

    // ─── OrderApi: POST triggers generic Exception (covers lines 62-65) ──
    @isTest
    static void testOrderApiPostGenericException() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders/';
        req.httpMethod = 'POST';
        // Malformed JSON will cause deserialization error
        req.requestBody = Blob.valueOf('{invalid json}');

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        OrderApi.doPost();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
    }

    // ─── OrderService.beforeInsert and afterUpdate (covers lines 61-69) ──
    @isTest
    static void testOrderServiceBeforeInsert() {
        List<Order__c> orders = new List<Order__c>{
            new Order__c(Name = 'SvcBefore Test', Status__c = 'New')
        };
        // Call the service method directly
        OrderService.beforeInsert(orders);
        System.assertNotEquals(null, orders[0].Order_Date__c);
    }

    @isTest
    static void testOrderServiceAfterUpdate() {
        Account restaurant = TestDataFactory.createRestaurant('AfterUpd Restaurant');
        Contact customer = TestDataFactory.createCustomer('After', 'Upd', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-AFTER', 'New', 50, customer.Id, restaurant.Id);

        Map<Id, Order__c> oldMap = new Map<Id, Order__c>();
        oldMap.put(order.Id, order.clone(true, true));
        order.Status__c = 'In Progress';
        update order;

        // Call directly — covers lines 67-69
        OrderService.afterUpdate(new List<Order__c>{ order }, oldMap);
    }

    // ─── ReviewService getReviewsForRestaurant (covers line 33-34) ──────
    @isTest
    static void testGetReviewsForRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('RevGet Restaurant');
        Contact customer = TestDataFactory.createCustomer('RevGet', 'User', restaurant.Id);
        TestDataFactory.createReview(null, customer.Id, restaurant.Id, 5, 'Amazing!');

        List<Review__c> reviews = ReviewService.getReviewsForRestaurant(restaurant.Id);
        System.assertEquals(1, reviews.size());
    }
}
