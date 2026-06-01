@isTest
private class OrderServiceTest {
    static testMethod void testGetRecentOrders() {
        Order__c o = new Order__c(Name='Test Order', Status__c='New', Total__c=100);
        insert o;
        Test.startTest();
        List<Order__c> result = OrderService.getRecentOrders();
        Test.stopTest();
        System.assertNotEquals(0, result.size());
    }
}
