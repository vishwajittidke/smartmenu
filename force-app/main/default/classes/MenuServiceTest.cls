@isTest
private class MenuServiceTest {
    @isTest
    static void testCreateMenuItem() {
        Account restaurant = TestDataFactory.createRestaurant('Menu Test');

        Test.startTest();
        Menu_Item__c item = MenuService.createMenuItem('Paneer Tikka Wrap', 'Spiced paneer cubes grilled with bell peppers', 249.00, 'Main Course', restaurant.Id);
        Test.stopTest();

        System.assertNotEquals(null, item.Id, 'Menu item should be created');
        System.assertEquals(true, item.Is_Available__c, 'Should default to available');
    }

    @isTest
    static void testCreateMenuItemInvalidPrice() {
        Account restaurant = TestDataFactory.createRestaurant('Menu Test 2');

        Test.startTest();
        try {
            MenuService.createMenuItem('Bad Item', 'desc', -5, 'Appetizer', restaurant.Id);
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('positive'));
        }
        Test.stopTest();
    }

    @isTest
    static void testGetMenuForRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('Menu List Test');
        TestDataFactory.createMenuItems(restaurant.Id, 3);

        Test.startTest();
        List<Menu_Item__c> items = MenuService.getMenuForRestaurant(restaurant.Id);
        Test.stopTest();

        System.assertEquals(3, items.size(), 'Should return 3 menu items');
    }

    @isTest
    static void testToggleAvailability() {
        Account restaurant = TestDataFactory.createRestaurant('Toggle Test');
        Menu_Item__c item = TestDataFactory.createMenuItem('Toggleable', 10, 'Appetizer', restaurant.Id);
        System.assertEquals(true, item.Is_Available__c);

        Test.startTest();
        Menu_Item__c toggled = MenuService.toggleAvailability(item.Id);
        Test.stopTest();

        System.assertEquals(false, toggled.Is_Available__c, 'Should be toggled to false');
    }
}
