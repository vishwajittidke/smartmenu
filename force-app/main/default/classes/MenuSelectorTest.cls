/**
 * MenuSelectorTest — Tests for MenuSelector SOQL methods.
 */
@isTest
private class MenuSelectorTest {

    @isTest
    static void testSelectByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('MenuSel Restaurant');
        TestDataFactory.createMenuItem('Burger', 12.00, 'Main Course', restaurant.Id);
        TestDataFactory.createMenuItem('Soda', 3.00, 'Beverage', restaurant.Id);

        List<Menu_Item__c> results = MenuSelector.selectByRestaurant(restaurant.Id);
        System.assertEquals(2, results.size());
    }

    @isTest
    static void testSelectByIds() {
        Account restaurant = TestDataFactory.createRestaurant('ByIds Restaurant');
        Menu_Item__c item1 = TestDataFactory.createMenuItem('Item A', 10.00, 'Appetizer', restaurant.Id);
        Menu_Item__c item2 = TestDataFactory.createMenuItem('Item B', 15.00, 'Main Course', restaurant.Id);

        List<Menu_Item__c> results = MenuSelector.selectByIds(new Set<Id>{ item1.Id, item2.Id });
        System.assertEquals(2, results.size());
    }

    @isTest
    static void testSelectTopSelling() {
        Account restaurant = TestDataFactory.createRestaurant('TopSell Restaurant');
        Contact customer = TestDataFactory.createCustomer('Top', 'Seller', restaurant.Id);
        Menu_Item__c item = TestDataFactory.createMenuItem('Popular Item', 20.00, 'Main Course', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-TOP-001', 'New', 20, customer.Id, restaurant.Id);
        TestDataFactory.createOrderItem(order.Id, item.Id, 2, 20.00);

        List<Menu_Item__c> results = MenuSelector.selectTopSelling(restaurant.Id, 5);
        System.assert(results.size() >= 1, 'Should find top-selling items');
    }

    @isTest
    static void testSelectAllAvailable() {
        Account restaurant = TestDataFactory.createRestaurant('AllAvail Restaurant');
        TestDataFactory.createMenuItem('Available Item', 10.00, 'Appetizer', restaurant.Id);

        List<Menu_Item__c> results = MenuSelector.selectAllAvailable(50);
        System.assert(results.size() >= 1, 'Should find available items');
    }
}
