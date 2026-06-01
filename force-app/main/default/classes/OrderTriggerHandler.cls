/**
 * OrderTriggerHandler — Central entry point for Order__c trigger logic.
 * Routes by context, prevents recursion per context, delegates to service layer.
 */
public with sharing class OrderTriggerHandler {

    // Per-context recursion guards — allows BEFORE + AFTER to both run,
    // but prevents infinite re-entry within the same context.
    private static Boolean beforeInsertDone = false;
    private static Boolean beforeUpdateDone = false;
    private static Boolean afterInsertDone = false;
    private static Boolean afterUpdateDone = false;

    public static void handle(List<Order__c> newList, Map<Id, Order__c> oldMap,
                               System.TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                if (beforeInsertDone) return;
                beforeInsertDone = true;
                OrderDomain.validateForInsert(newList);
                OrderCalculator.stampOrderDate(newList);
            }
            when BEFORE_UPDATE {
                if (beforeUpdateDone) return;
                beforeUpdateDone = true;
                OrderDomain.validateForUpdate(newList, oldMap);
            }
            when AFTER_INSERT {
                if (afterInsertDone) return;
                afterInsertDone = true;
                OrderEventPublisher.publishOrderPlaced(newList);
            }
            when AFTER_UPDATE {
                if (afterUpdateDone) return;
                afterUpdateDone = true;
                OrderEventPublisher.publishStatusChanges(newList, oldMap);
                OrderEventPublisher.createStatusHistory(newList, oldMap);
            }
        }
    }

    /** Reset guards — for use in test classes only. */
    @TestVisible
    private static void resetGuards() {
        beforeInsertDone = false;
        beforeUpdateDone = false;
        afterInsertDone = false;
        afterUpdateDone = false;
    }
}
