/**
 * OrderEventPublisher — Publishes platform events for order lifecycle changes.
 * Per ADR-004: Platform Events for async communication.
 */
public with sharing class OrderEventPublisher {

    /**
     * Publishes Order_Placed__e events for newly inserted orders.
     */
    public static void publishOrderPlaced(List<Order__c> orders) {
        List<Order_Placed__e> events = new List<Order_Placed__e>();
        for (Order__c o : orders) {
            events.add(new Order_Placed__e(
                Order_Id__c      = o.Id,
                Restaurant_Id__c = o.Restaurant__c,
                Customer_Id__c   = o.Customer__c,
                Total__c         = o.Total__c
            ));
        }
        if (!events.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(events);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    System.debug(LoggingLevel.ERROR, 'Order_Placed__e publish failed: ' + sr.getErrors());
                }
            }
        }
    }

    /**
     * Publishes Order_Status_Changed__e events when status transitions occur.
     */
    public static void publishStatusChanges(List<Order__c> newList, Map<Id, Order__c> oldMap) {
        List<Order_Status_Changed__e> events = new List<Order_Status_Changed__e>();
        for (Order__c newOrder : newList) {
            Order__c oldOrder = oldMap.get(newOrder.Id);
            if (oldOrder != null && oldOrder.Status__c != newOrder.Status__c) {
                events.add(new Order_Status_Changed__e(
                    Order_Id__c        = newOrder.Id,
                    Previous_Status__c = oldOrder.Status__c,
                    New_Status__c      = newOrder.Status__c
                ));
            }
        }
        if (!events.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(events);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    System.debug(LoggingLevel.ERROR, 'Order_Status_Changed__e publish failed: ' + sr.getErrors());
                }
            }
        }
    }

    /**
     * Creates Order_Status_History__c records for audit trail (ADR-002).
     */
    public static void createStatusHistory(List<Order__c> newList, Map<Id, Order__c> oldMap) {
        List<Order_Status_History__c> histories = new List<Order_Status_History__c>();
        for (Order__c newOrder : newList) {
            Order__c oldOrder = oldMap.get(newOrder.Id);
            if (oldOrder != null && oldOrder.Status__c != newOrder.Status__c) {
                histories.add(new Order_Status_History__c(
                    Order__c          = newOrder.Id,
                    Previous_Status__c = oldOrder.Status__c,
                    New_Status__c     = newOrder.Status__c,
                    Changed_Date__c   = Datetime.now()
                ));
            }
        }
        if (!histories.isEmpty()) {
            insert histories;
        }
    }
}
