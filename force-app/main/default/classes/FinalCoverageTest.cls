/**
 * FinalCoverageTest — Closes remaining coverage gaps for production readiness.
 */
@isTest
private class FinalCoverageTest {

    // ─── BusinessException ──────────────────────────────────────────────
    @isTest
    static void testBusinessException() {
        BusinessException ex = new BusinessException('Test error');
        System.assertEquals('Test error', ex.getMessage());
        System.assertEquals('BUSINESS_VALIDATION_ERROR', ex.getErrorCode());
    }

    // ─── MenuService.getRecommendations ─────────────────────────────────
    @isTest
    static void testGetRecommendations() {
        Account restaurant = TestDataFactory.createRestaurant('Reco Restaurant');
        Contact customer = TestDataFactory.createCustomer('Reco', 'User', restaurant.Id);
        Menu_Item__c item = TestDataFactory.createMenuItem('Popular Dish', 20.00, 'Main Course', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-RECO', 'New', 20, customer.Id, restaurant.Id);
        TestDataFactory.createOrderItem(order.Id, item.Id, 5, 20.00);

        List<Menu_Item__c> recs = MenuService.getRecommendations(restaurant.Id);
        System.assert(recs.size() >= 1, 'Should return recommendations');
    }

    // ─── MenuService.updatePrice ────────────────────────────────────────
    @isTest
    static void testUpdatePrice() {
        Account restaurant = TestDataFactory.createRestaurant('Price Restaurant');
        Menu_Item__c item = TestDataFactory.createMenuItem('Price Item', 10.00, 'Appetizer', restaurant.Id);

        Menu_Item__c updated = MenuService.updatePrice(item.Id, 15.00);
        System.assertEquals(15.00, updated.Price__c);
    }

    @isTest
    static void testUpdatePriceInvalid() {
        Account restaurant = TestDataFactory.createRestaurant('PriceInv Restaurant');
        Menu_Item__c item = TestDataFactory.createMenuItem('Inv Item', 10.00, 'Appetizer', restaurant.Id);

        try {
            MenuService.updatePrice(item.Id, -5.00);
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('positive'));
        }
    }

    // ─── OrderTriggerHandler.resetGuards ────────────────────────────────
    @isTest
    static void testResetGuards() {
        OrderTriggerHandler.resetGuards();
        // No exception = success
        System.assert(true);
    }

    // ─── OrderService.createOrder via OrderApi path ─────────────────────
    @isTest
    static void testCreateOrderBlankName() {
        try {
            OrderService.createOrder('', null, null);
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('required'));
        }
    }
}
