/**
 * OrderItemTriggerHandler — Recalculates parent Order totals when line items change.
 */
public with sharing class OrderItemTriggerHandler {

    public static void handle(List<Order_Item__c> newList, List<Order_Item__c> oldList,
                               System.TriggerOperation operation) {
        Set<Id> orderIds = new Set<Id>();

        if (newList != null) {
            for (Order_Item__c item : newList) {
                if (item.Order__c != null) orderIds.add(item.Order__c);
            }
        }
        if (oldList != null) {
            for (Order_Item__c item : oldList) {
                if (item.Order__c != null) orderIds.add(item.Order__c);
            }
        }

        if (!orderIds.isEmpty()) {
            OrderService.recalculateTotals(orderIds);
        }
    }
}
