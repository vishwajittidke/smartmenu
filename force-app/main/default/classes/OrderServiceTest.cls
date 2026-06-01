@isTest
private class OrderServiceTest {
    @isTest
    static void testGetRecentOrders() {
        Account restaurant = TestDataFactory.createRestaurant('Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('John', 'Doe', restaurant.Id);
        TestDataFactory.createOrder('Test Order', 'New', 100, customer.Id, restaurant.Id);

        Test.startTest();
        List<Order__c> result = OrderService.getRecentOrders();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Should return at least one order');
    }

    @isTest
    static void testGetOrderStatus() {
        Account restaurant = TestDataFactory.createRestaurant('Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('Jane', 'Doe', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Status Test', 'New', 50, customer.Id, restaurant.Id);

        Test.startTest();
        Order__c result = OrderService.getOrderStatus(order.Id);
        Test.stopTest();

        System.assertEquals('New', result.Status__c, 'Status should be New');
    }

    @isTest
    static void testGetOrderStatusNotFound() {
        Test.startTest();
        try {
            // Use a fabricated but valid-format Id that doesn't exist
            OrderService.getOrderStatus('a00000000000001AAA');
            System.assert(false, 'Should have thrown BusinessException');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('not found'), 'Should mention not found');
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateOrder() {
        Account restaurant = TestDataFactory.createRestaurant('Create Test');
        Contact customer = TestDataFactory.createCustomer('Bob', 'Test', restaurant.Id);

        Test.startTest();
        Order__c result = OrderService.createOrder('New Order', customer.Id, restaurant.Id);
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Order should be created');
        System.assertEquals('New', result.Status__c, 'Default status should be New');
    }

    @isTest
    static void testUpdateOrderStatus() {
        Account restaurant = TestDataFactory.createRestaurant('Update Test');
        Contact customer = TestDataFactory.createCustomer('Alice', 'Test', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Update Order', 'New', 75, customer.Id, restaurant.Id);

        Test.startTest();
        Order__c result = OrderService.updateOrderStatus(order.Id, 'In Progress');
        Test.stopTest();

        System.assertEquals('In Progress', result.Status__c, 'Status should be updated');
    }
}
