/**
 * OrderDomain — Pure business rules for Order__c.
 * No DML. No SOQL. Domain layer per architecture.
 */
public with sharing class OrderDomain {

    private static final Set<String> VALID_STATUSES = new Set<String>{
        'New', 'In Progress', 'Completed', 'Cancelled'
    };

    // Valid transitions: from → allowed tos
    private static final Map<String, Set<String>> VALID_TRANSITIONS = new Map<String, Set<String>>{
        'New'         => new Set<String>{ 'In Progress', 'Cancelled' },
        'In Progress' => new Set<String>{ 'Completed', 'Cancelled' },
        'Completed'   => new Set<String>(),
        'Cancelled'   => new Set<String>()
    };

    /**
     * Validates that the status transition is allowed.
     * @throws BusinessException if invalid
     */
    public static void validateStatusTransition(Order__c oldOrder, Order__c newOrder) {
        if (oldOrder.Status__c == newOrder.Status__c) return;

        Set<String> allowed = VALID_TRANSITIONS.get(oldOrder.Status__c);
        if (allowed == null || !allowed.contains(newOrder.Status__c)) {
            throw new BusinessException(
                'Invalid status transition from "' + oldOrder.Status__c +
                '" to "' + newOrder.Status__c + '".'
            );
        }
    }

    /**
     * Validates that the order has required fields for insertion.
     */
    public static void validateForInsert(List<Order__c> orders) {
        for (Order__c o : orders) {
            if (String.isBlank(o.Name)) {
                throw new BusinessException('Order Name is required.');
            }
            if (String.isBlank(o.Status__c)) {
                o.Status__c = 'New';
            }
            if (!VALID_STATUSES.contains(o.Status__c)) {
                throw new BusinessException('Invalid status: ' + o.Status__c);
            }
            if (o.Total__c != null && o.Total__c < 0) {
                throw new BusinessException('Order total cannot be negative.');
            }
        }
    }

    /**
     * Validates status transitions for a batch of updated orders.
     */
    public static void validateForUpdate(List<Order__c> newList, Map<Id, Order__c> oldMap) {
        for (Order__c newOrder : newList) {
            Order__c oldOrder = oldMap.get(newOrder.Id);
            if (oldOrder != null && oldOrder.Status__c != newOrder.Status__c) {
                validateStatusTransition(oldOrder, newOrder);
            }
        }
    }
}
