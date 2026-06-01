/**
 * OrderCalculator — Calculates order totals from line items.
 * Domain layer: pure calculation, no DML.
 */
public with sharing class OrderCalculator {

    /**
     * Recalculates the Total__c for orders based on their Order_Item__c line items.
     * @param orderIds Set of Order__c IDs to recalculate
     */
    public static void recalculateTotals(Set<Id> orderIds) {
        if (orderIds.isEmpty()) return;

        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        for (Id oid : orderIds) {
            totals.put(oid, 0);
        }

        List<Order_Item__c> items = [
            SELECT Order__c, Quantity__c, Unit_Price__c
            FROM Order_Item__c
            WHERE Order__c IN :orderIds
        ];

        for (Order_Item__c item : items) {
            Decimal lineTotal = (item.Quantity__c != null ? item.Quantity__c : 0)
                              * (item.Unit_Price__c != null ? item.Unit_Price__c : 0);
            Decimal existing = totals.get(item.Order__c);
            totals.put(item.Order__c, (existing != null ? existing : 0) + lineTotal);
        }

        List<Order__c> ordersToUpdate = new List<Order__c>();
        for (Id oid : totals.keySet()) {
            ordersToUpdate.add(new Order__c(Id = oid, Total__c = totals.get(oid)));
        }
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    /**
     * Sets Order_Date__c to now if not already set.
     */
    public static void stampOrderDate(List<Order__c> orders) {
        for (Order__c o : orders) {
            if (o.Order_Date__c == null) {
                o.Order_Date__c = Datetime.now();
            }
        }
    }
}
