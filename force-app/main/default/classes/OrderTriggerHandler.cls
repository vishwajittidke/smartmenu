/**
 * OrderTriggerHandler — Central entry point for Order__c trigger logic.
 * Routes by context, prevents recursion, delegates to service layer.
 */
public with sharing class OrderTriggerHandler {

    private static Boolean isExecuting = false;

    public static void handle(List<Order__c> newList, Map<Id, Order__c> oldMap,
                               System.TriggerOperation operation) {
        if (isExecuting) return; // Prevent recursion
        isExecuting = true;

        try {
            switch on operation {
                when BEFORE_INSERT {
                    OrderDomain.validateForInsert(newList);
                    OrderCalculator.stampOrderDate(newList);
                }
                when BEFORE_UPDATE {
                    OrderDomain.validateForUpdate(newList, oldMap);
                }
                when AFTER_INSERT {
                    OrderEventPublisher.publishOrderPlaced(newList);
                }
                when AFTER_UPDATE {
                    OrderEventPublisher.publishStatusChanges(newList, oldMap);
                    OrderEventPublisher.createStatusHistory(newList, oldMap);
                }
            }
        } finally {
            isExecuting = false;
        }
    }
}
