/**
 * OrderSelector — Centralized SOQL queries for Order__c.
 * Per ADR-006: all SOQL must live in Selector classes.
 */
public with sharing class OrderSelector {

    public static List<Order__c> selectRecentOrders(Integer limitCount) {
        return [
            SELECT Id, Name, Status__c, Total__c, Customer__c, Restaurant__c, Order_Date__c
            FROM Order__c
            ORDER BY CreatedDate DESC
            LIMIT :limitCount
        ];
    }

    public static Order__c selectById(Id orderId) {
        List<Order__c> orders = [
            SELECT Id, Name, Status__c, Total__c, Customer__c, Restaurant__c, Order_Date__c
            FROM Order__c
            WHERE Id = :orderId
            LIMIT 1
        ];
        return orders.isEmpty() ? null : orders[0];
    }

    public static List<Order__c> selectByIds(Set<Id> orderIds) {
        return [
            SELECT Id, Name, Status__c, Total__c, Customer__c, Restaurant__c, Order_Date__c
            FROM Order__c
            WHERE Id IN :orderIds
        ];
    }

    public static List<Order__c> selectByCustomer(Id customerId) {
        return [
            SELECT Id, Name, Status__c, Total__c, Order_Date__c
            FROM Order__c
            WHERE Customer__c = :customerId
            ORDER BY CreatedDate DESC
        ];
    }

    public static List<Order__c> selectByRestaurant(Id restaurantId) {
        return [
            SELECT Id, Name, Status__c, Total__c, Customer__c, Order_Date__c
            FROM Order__c
            WHERE Restaurant__c = :restaurantId
            ORDER BY CreatedDate DESC
        ];
    }

    public static List<Order__c> selectByStatus(String status) {
        return [
            SELECT Id, Name, Status__c, Total__c, Customer__c, Restaurant__c
            FROM Order__c
            WHERE Status__c = :status
            ORDER BY CreatedDate DESC
        ];
    }

    public static AggregateResult[] selectRevenueByRestaurant(Id restaurantId) {
        return [
            SELECT SUM(Total__c) totalRevenue, COUNT(Id) orderCount
            FROM Order__c
            WHERE Restaurant__c = :restaurantId
              AND Status__c = 'Completed'
        ];
    }

    public static List<Order_Item__c> selectLineItemsByOrderIds(Set<Id> orderIds) {
        return [
            SELECT Order__c, Quantity__c, Unit_Price__c
            FROM Order_Item__c
            WHERE Order__c IN :orderIds
            WITH SECURITY_ENFORCED
        ];
    }
}
