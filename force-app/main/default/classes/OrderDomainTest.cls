@isTest
private class OrderDomainTest {
    @isTest
    static void testValidStatusTransition() {
        Order__c oldOrder = new Order__c(Status__c = 'New');
        Order__c newOrder = new Order__c(Status__c = 'In Progress');

        Test.startTest();
        // Should not throw
        OrderDomain.validateStatusTransition(oldOrder, newOrder);
        Test.stopTest();

        System.assert(true, 'Valid transition should not throw');
    }

    @isTest
    static void testInvalidStatusTransition() {
        Order__c oldOrder = new Order__c(Status__c = 'Completed');
        Order__c newOrder = new Order__c(Status__c = 'New');

        Test.startTest();
        try {
            OrderDomain.validateStatusTransition(oldOrder, newOrder);
            System.assert(false, 'Should have thrown BusinessException');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('Invalid status transition'), 'Should mention invalid transition');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateForInsertMissingName() {
        List<Order__c> orders = new List<Order__c>{ new Order__c(Name = '', Status__c = 'New') };

        Test.startTest();
        try {
            OrderDomain.validateForInsert(orders);
            System.assert(false, 'Should have thrown BusinessException');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('Name is required'));
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateForInsertNegativeTotal() {
        List<Order__c> orders = new List<Order__c>{
            new Order__c(Name = 'Test', Status__c = 'New', Total__c = -5)
        };

        Test.startTest();
        try {
            OrderDomain.validateForInsert(orders);
            System.assert(false, 'Should have thrown BusinessException');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('cannot be negative'));
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateForInsertDefaultStatus() {
        List<Order__c> orders = new List<Order__c>{ new Order__c(Name = 'Test') };

        Test.startTest();
        OrderDomain.validateForInsert(orders);
        Test.stopTest();

        System.assertEquals('New', orders[0].Status__c, 'Should default to New');
    }
}
