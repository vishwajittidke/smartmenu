/**
 * MenuSelector — Centralized SOQL queries for Menu_Item__c.
 */
public with sharing class MenuSelector {

    public static List<Menu_Item__c> selectByRestaurant(Id restaurantId) {
        return [
            SELECT Id, Name, Description__c, Price__c, Category__c, Is_Available__c, Restaurant__c
            FROM Menu_Item__c
            WHERE Restaurant__c = :restaurantId
            ORDER BY Category__c, Name
        ];
    }

    public static List<Menu_Item__c> selectAvailableByRestaurant(Id restaurantId) {
        return [
            SELECT Id, Name, Description__c, Price__c, Category__c, Restaurant__c
            FROM Menu_Item__c
            WHERE Restaurant__c = :restaurantId
              AND Is_Available__c = true
            ORDER BY Category__c, Name
        ];
    }

    public static Menu_Item__c selectById(Id menuItemId) {
        List<Menu_Item__c> items = [
            SELECT Id, Name, Description__c, Price__c, Category__c, Is_Available__c, Restaurant__c
            FROM Menu_Item__c
            WHERE Id = :menuItemId
            LIMIT 1
        ];
        return items.isEmpty() ? null : items[0];
    }

    public static List<Menu_Item__c> selectByIds(Set<Id> menuItemIds) {
        return [
            SELECT Id, Name, Price__c, Category__c, Is_Available__c, Restaurant__c
            FROM Menu_Item__c
            WHERE Id IN :menuItemIds
        ];
    }

    public static List<Menu_Item__c> selectTopSelling(Id restaurantId, Integer limitCount) {
        // Uses aggregate on Order_Item__c to find most-ordered items
        List<AggregateResult> topItems = [
            SELECT Menu_Item__c itemId, COUNT(Id) cnt
            FROM Order_Item__c
            WHERE Order__r.Restaurant__c = :restaurantId
            GROUP BY Menu_Item__c
            ORDER BY COUNT(Id) DESC
            LIMIT :limitCount
        ];
        Set<Id> itemIds = new Set<Id>();
        for (AggregateResult ar : topItems) {
            itemIds.add((Id) ar.get('itemId'));
        }
        if (itemIds.isEmpty()) return new List<Menu_Item__c>();
        return [
            SELECT Id, Name, Price__c, Category__c
            FROM Menu_Item__c
            WHERE Id IN :itemIds
        ];
    }

    public static List<Menu_Item__c> selectAllAvailable(Integer limitCount) {
        return [
            SELECT Id, Name, Description__c, Price__c, Category__c, Is_Available__c, Restaurant__c
            FROM Menu_Item__c
            WHERE Is_Available__c = true
            WITH SECURITY_ENFORCED
            ORDER BY Category__c, Name
            LIMIT :limitCount
        ];
    }
}
