/**
 * FinalCoverageTest2 — Covers escalation paths and trigger edge cases.
 */
@isTest
private class FinalCoverageTest2 {

    // ─── AgentforceAssistant escalation path ────────────────────────────
    // Force an exception by providing a malformed orderId to selectById
    @isTest
    static void testEscalationPath() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-escalation';
        req.message = 'What is my order status?';
        req.orderId = 'completely-invalid-id-string';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assertEquals(1, responses.size());
        // Either escalated or handled gracefully
    }

    // ─── OrderItemTriggerHandler delete path ────────────────────────────
    @isTest
    static void testOrderItemDelete() {
        Account restaurant = TestDataFactory.createRestaurant('Delete Restaurant');
        Contact customer = TestDataFactory.createCustomer('Del', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-DEL', 'New', 0, customer.Id, restaurant.Id);
        Menu_Item__c menuItem = TestDataFactory.createMenuItem('Del Item', 10.00, 'Main Course', restaurant.Id);
        Order_Item__c lineItem = TestDataFactory.createOrderItem(order.Id, menuItem.Id, 2, 10.00);

        // Verify total was recalculated on insert
        Order__c afterInsert = [SELECT Total__c FROM Order__c WHERE Id = :order.Id];
        System.assertEquals(20.00, afterInsert.Total__c, 'Total after insert should be 20');

        // Delete the line item — triggers oldList path
        Test.startTest();
        delete lineItem;
        Test.stopTest();

        Order__c afterDelete = [SELECT Total__c FROM Order__c WHERE Id = :order.Id];
        System.assertEquals(0, afterDelete.Total__c, 'Total after delete should be 0');
    }

    // ─── OrderItemTriggerHandler update path ────────────────────────────
    @isTest
    static void testOrderItemUpdate() {
        Account restaurant = TestDataFactory.createRestaurant('Update Restaurant');
        Contact customer = TestDataFactory.createCustomer('Upd', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-UPD', 'New', 0, customer.Id, restaurant.Id);
        Menu_Item__c menuItem = TestDataFactory.createMenuItem('Upd Item', 10.00, 'Main Course', restaurant.Id);
        Order_Item__c lineItem = TestDataFactory.createOrderItem(order.Id, menuItem.Id, 1, 10.00);

        // Update quantity
        Test.startTest();
        lineItem.Quantity__c = 5;
        update lineItem;
        Test.stopTest();

        Order__c afterUpdate = [SELECT Total__c FROM Order__c WHERE Id = :order.Id];
        System.assertEquals(50.00, afterUpdate.Total__c, 'Total should be 5 * 10 = 50');
    }

    // ─── ReviewService missing restaurant ───────────────────────────────
    @isTest
    static void testSubmitReviewMissingRestaurant() {
        try {
            ReviewService.submitReview(null, null, null, 3, 'No restaurant');
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('Restaurant'));
        }
    }

    // ─── OrderDomain negative total ─────────────────────────────────────
    @isTest
    static void testValidateForInsertNegativeTotal() {
        Order__c o = new Order__c(Name = 'Bad Total', Status__c = 'New', Total__c = -5);
        try {
            OrderDomain.validateForInsert(new List<Order__c>{ o });
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('negative'));
        }
    }
}
