/**
 * OrderCalculator — Pure calculation logic for orders.
 * Domain layer: NO DML, NO SOQL per architecture.
 * SOQL moved to OrderSelector, DML moved to callers (Service layer).
 */
public with sharing class OrderCalculator {

    /**
     * Calculates order totals from line items.
     * Returns a map of Order ID → calculated total.
     * Caller is responsible for SOQL (to fetch items) and DML (to update orders).
     */
    public static Map<Id, Decimal> calculateTotals(Set<Id> orderIds, List<Order_Item__c> items) {
        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        for (Id oid : orderIds) {
            totals.put(oid, 0);
        }

        for (Order_Item__c item : items) {
            Decimal lineTotal = (item.Quantity__c != null ? item.Quantity__c : 0)
                              * (item.Unit_Price__c != null ? item.Unit_Price__c : 0);
            Decimal existing = totals.get(item.Order__c);
            totals.put(item.Order__c, (existing != null ? existing : 0) + lineTotal);
        }

        return totals;
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
