trigger OrderTrigger on Order__c (before insert, before update, after insert, after update) {
    OrderTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.operationType);
}
