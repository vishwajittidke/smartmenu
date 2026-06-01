public with sharing class OrderService {
    @AuraEnabled(cacheable=true)
    public static List<Order__c> getRecentOrders() {
        return [SELECT Id, Name, Status__c, Total__c FROM Order__c ORDER BY CreatedDate DESC LIMIT 10];
    }
}
