/**
 * OrderSelectorTest — Tests for OrderSelector SOQL methods.
 */
@isTest
private class OrderSelectorTest {

    @isTest
    static void testSelectByIds() {
        Account restaurant = TestDataFactory.createRestaurant('OrdSel Restaurant');
        Contact customer = TestDataFactory.createCustomer('OrdSel', 'User', restaurant.Id);
        List<Order__c> orders = TestDataFactory.createOrders(2, customer.Id, restaurant.Id);

        List<Order__c> results = OrderSelector.selectByIds(new Set<Id>{ orders[0].Id, orders[1].Id });
        System.assertEquals(2, results.size(), 'Should return both orders');
    }

    @isTest
    static void testSelectByCustomer() {
        Account restaurant = TestDataFactory.createRestaurant('ByCust Restaurant');
        Contact customer = TestDataFactory.createCustomer('ByCust', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-CUST-001', 'New', 50, customer.Id, restaurant.Id);

        List<Order__c> results = OrderSelector.selectByCustomer(customer.Id);
        System.assertEquals(1, results.size());
    }

    @isTest
    static void testSelectByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('ByRest Restaurant');
        Contact customer = TestDataFactory.createCustomer('ByRest', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-REST-001', 'New', 60, customer.Id, restaurant.Id);

        List<Order__c> results = OrderSelector.selectByRestaurant(restaurant.Id);
        System.assert(results.size() >= 1, 'Should find orders for restaurant');
    }

    @isTest
    static void testSelectByStatus() {
        Account restaurant = TestDataFactory.createRestaurant('ByStatus Restaurant');
        Contact customer = TestDataFactory.createCustomer('ByStat', 'User', restaurant.Id);
        TestDataFactory.createOrder('ORD-STAT-001', 'New', 70, customer.Id, restaurant.Id);

        List<Order__c> results = OrderSelector.selectByStatus('New');
        System.assert(results.size() >= 1, 'Should find New orders');
    }

    @isTest
    static void testSelectLineItemsByOrderIds() {
        Account restaurant = TestDataFactory.createRestaurant('LineItem Restaurant');
        Contact customer = TestDataFactory.createCustomer('Line', 'Item', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-LINE-001', 'New', 0, customer.Id, restaurant.Id);
        Menu_Item__c menuItem = TestDataFactory.createMenuItem('Line Test Item', 15.00, 'Main Course', restaurant.Id);
        TestDataFactory.createOrderItem(order.Id, menuItem.Id, 1, 15.00);

        List<Order_Item__c> results = OrderSelector.selectLineItemsByOrderIds(new Set<Id>{ order.Id });
        System.assertEquals(1, results.size());
        System.assertEquals(15.00, results[0].Unit_Price__c);
    }

    @isTest
    static void testSelectRevenueByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('Revenue Restaurant');
        Contact customer = TestDataFactory.createCustomer('Rev', 'User', restaurant.Id);
        TestDataFactory.createCompletedOrder(customer.Id, restaurant.Id);

        AggregateResult[] results = OrderSelector.selectRevenueByRestaurant(restaurant.Id);
        System.assertEquals(1, results.size());
    }
}
