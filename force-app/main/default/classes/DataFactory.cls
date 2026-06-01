public with sharing class DataFactory {
    @TestVisible
    public static List<Order__c> createOrders(Integer count) {
        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < count; i++) {
            Order__c o = new Order__c(Name = 'Test Order ' + i, Status__c = 'New', Total__c = Decimal.valueOf(10 + i));
            orders.add(o);
        }
        insert orders;
        return orders;
    }
}
