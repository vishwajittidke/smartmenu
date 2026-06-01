/**
 * OrderServiceCoverageTest — Additional tests for uncovered OrderService methods.
 */
@isTest
private class OrderServiceCoverageTest {

    @isTest
    static void testGetOrdersByCustomer() {
        Account restaurant = TestDataFactory.createRestaurant('SvcCov Restaurant');
        Contact customer = TestDataFactory.createCustomer('SvcCov', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-SVC-001', 'New', 50, customer.Id, restaurant.Id);

        List<Order__c> results = OrderService.getOrdersByCustomer(customer.Id);
        System.assertEquals(1, results.size());
    }

    @isTest
    static void testGetOrdersByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('SvcRest Restaurant');
        Contact customer = TestDataFactory.createCustomer('SvcRest', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-SVC-002', 'New', 60, customer.Id, restaurant.Id);

        List<Order__c> results = OrderService.getOrdersByRestaurant(restaurant.Id);
        System.assert(results.size() >= 1);
    }

    @isTest
    static void testGetOrdersByStatus() {
        Account restaurant = TestDataFactory.createRestaurant('SvcStat Restaurant');
        Contact customer = TestDataFactory.createCustomer('SvcStat', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-SVC-003', 'New', 70, customer.Id, restaurant.Id);

        List<Order__c> results = OrderService.getOrdersByStatus('New');
        System.assert(results.size() >= 1);
    }

    @isTest
    static void testRecalculateTotals() {
        Account restaurant = TestDataFactory.createRestaurant('Recalc Restaurant');
        Contact customer = TestDataFactory.createCustomer('Recalc', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-RECALC', 'New', 0, customer.Id, restaurant.Id);
        Menu_Item__c item = TestDataFactory.createMenuItem('Recalc Item', 25.00, 'Main Course', restaurant.Id);
        TestDataFactory.createOrderItem(order.Id, item.Id, 2, 25.00);

        // Recalculate
        OrderService.recalculateTotals(new Set<Id>{ order.Id });

        Order__c updated = [SELECT Total__c FROM Order__c WHERE Id = :order.Id];
        System.assertEquals(50.00, updated.Total__c, 'Should be 2 * 25 = 50');
    }

    @isTest
    static void testRecalculateTotalsNull() {
        // Should handle null/empty gracefully
        OrderService.recalculateTotals(null);
        OrderService.recalculateTotals(new Set<Id>());
    }
}
