/**
 * OrderItemTrigger — Fires when line items change.
 * Delegates to handler per architecture (one trigger per object, no logic).
 */
trigger OrderItemTrigger on Order_Item__c (after insert, after update, after delete) {
    OrderItemTriggerHandler.handle(Trigger.new, Trigger.old, Trigger.operationType);
}
