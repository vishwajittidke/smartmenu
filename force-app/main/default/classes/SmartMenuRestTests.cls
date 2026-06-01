@isTest
private class SmartMenuRestTests {

    @isTest
    static void testReviewApiAndAccountSelector() {
        Account restaurant = TestDataFactory.createRestaurant('Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('Test', 'Customer', restaurant.Id);
        
        Test.startTest();
        // Test AccountSelector
        Account queriedAcc = AccountSelector.selectFirstRestaurant();
        System.assertNotEquals(null, queriedAcc, 'Should find the restaurant');

        // Test ReviewApi POST
        RestRequest postReq = new RestRequest();
        postReq.requestUri = '/services/apexrest/reviews/';
        postReq.httpMethod = 'POST';
        postReq.requestBody = Blob.valueOf('{"restaurantId":"' + restaurant.Id + '","rating":5,"comment":"Fabulous service!","customerId":"' + customer.Id + '"}');
        RestContext.request = postReq;
        RestContext.response = new RestResponse();

        ReviewApi.doPost();
        System.assertEquals(201, RestContext.response.statusCode, 'Review POST should succeed');

        // Test ReviewApi GET all
        RestRequest getReqAll = new RestRequest();
        getReqAll.requestUri = '/services/apexrest/reviews/';
        getReqAll.httpMethod = 'GET';
        RestContext.request = getReqAll;

        List<Review__c> reviews = ReviewApi.doGet();
        System.assertNotEquals(0, reviews.size(), 'Should retrieve reviews');

        // Test ReviewApi GET by restaurantId
        RestRequest getReqRest = new RestRequest();
        getReqRest.requestUri = '/services/apexrest/reviews/' + restaurant.Id;
        getReqRest.httpMethod = 'GET';
        RestContext.request = getReqRest;

        List<Review__c> reviewsRest = ReviewApi.doGet();
        System.assertNotEquals(0, reviewsRest.size(), 'Should retrieve reviews for restaurant');
        Test.stopTest();
    }

    @isTest
    static void testRevenueApi() {
        Account restaurant = TestDataFactory.createRestaurant('Revenue Test');
        Contact customer = TestDataFactory.createCustomer('Revenue', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Rev Order', 'Completed', 150, customer.Id, restaurant.Id);

        Test.startTest();
        // Test RevenueApi GET
        RestRequest getReq = new RestRequest();
        getReq.requestUri = '/services/apexrest/insights/' + restaurant.Id;
        getReq.httpMethod = 'GET';
        RestContext.request = getReq;
        RestContext.response = new RestResponse();

        RevenueApi.doGet();
        System.assertEquals(200, RestContext.response.statusCode, 'Insights GET should succeed');
        
        // Test RevenueApi GET with fallback
        RestRequest getReqFallback = new RestRequest();
        getReqFallback.requestUri = '/services/apexrest/insights/';
        getReqFallback.httpMethod = 'GET';
        RestContext.request = getReqFallback;
        RestContext.response = new RestResponse();

        RevenueApi.doGet();
        System.assertEquals(200, RestContext.response.statusCode, 'Insights GET fallback should succeed');
        Test.stopTest();
    }
}
