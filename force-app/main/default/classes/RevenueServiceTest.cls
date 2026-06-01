@isTest
private class RevenueServiceTest {
    @isTest
    static void testGetInsights() {
        Account restaurant = TestDataFactory.createRestaurant('Revenue Test');
        Contact customer = TestDataFactory.createCustomer('Revenue', 'User', restaurant.Id);

        // Create orders and complete them
        Order__c o1 = TestDataFactory.createOrder('Rev Order 1', 'New', 100, customer.Id, restaurant.Id);
        o1.Status__c = 'In Progress';
        update o1;
        o1.Status__c = 'Completed';
        update o1;

        Order__c o2 = TestDataFactory.createOrder('Rev Order 2', 'New', 200, customer.Id, restaurant.Id);

        Test.startTest();
        Map<String, Object> insights = RevenueService.getInsights(restaurant.Id);
        Test.stopTest();

        System.assertNotEquals(null, insights, 'Insights should not be null');
        System.assert(insights.containsKey('totalRevenue'), 'Should contain totalRevenue');
        System.assert(insights.containsKey('ordersByStatus'), 'Should contain status breakdown');
    }
}
