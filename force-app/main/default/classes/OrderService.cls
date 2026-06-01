/**
 * OrderService — Business workflows for order management.
 * Refactored to use Selector Layer and expose proper service methods.
 */
public with sharing class OrderService {

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getRecentOrders() {
        return OrderSelector.selectRecentOrders(10);
    }

    @AuraEnabled(cacheable=true)
    public static Order__c getOrderStatus(Id orderId) {
        Order__c order = OrderSelector.selectById(orderId);
        if (order == null) {
            throw new BusinessException('Order not found.');
        }
        return order;
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrdersByCustomer(Id customerId) {
        return OrderSelector.selectByCustomer(customerId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrdersByRestaurant(Id restaurantId) {
        return OrderSelector.selectByRestaurant(restaurantId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrdersByStatus(String status) {
        return OrderSelector.selectByStatus(status);
    }

    @AuraEnabled
    public static Order__c createOrder(String name, Id customerId, Id restaurantId) {
        if (String.isBlank(name)) throw new BusinessException('Order name is required.');

        Order__c o = new Order__c(
            Name = name,
            Status__c = 'New',
            Customer__c = customerId,
            Restaurant__c = restaurantId,
            Order_Date__c = Datetime.now()
        );
        insert o; // trigger will run validation & publish events
        return o;
    }

    @AuraEnabled
    public static Order__c updateOrderStatus(Id orderId, String newStatus) {
        Order__c o = OrderSelector.selectById(orderId);
        if (o == null) throw new BusinessException('Order not found.');
        o.Status__c = newStatus;
        update o; // trigger will validate transition & publish events
        return o;
    }

    // Called by trigger handler
    public static void beforeInsert(List<Order__c> orders) {
        OrderDomain.validateForInsert(orders);
        OrderCalculator.stampOrderDate(orders);
    }

    // Called by trigger handler
    public static void afterUpdate(List<Order__c> newList, Map<Id, Order__c> oldMap) {
        OrderEventPublisher.publishStatusChanges(newList, oldMap);
        OrderEventPublisher.createStatusHistory(newList, oldMap);
    }

    /**
     * Recalculates Order totals from line items.
     * Uses Selector for SOQL, Calculator for logic, Service for DML.
     */
    public static void recalculateTotals(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) return;

        List<Order_Item__c> items = OrderSelector.selectLineItemsByOrderIds(orderIds);
        Map<Id, Decimal> totals = OrderCalculator.calculateTotals(orderIds, items);

        List<Order__c> ordersToUpdate = new List<Order__c>();
        for (Id oid : totals.keySet()) {
            ordersToUpdate.add(new Order__c(Id = oid, Total__c = totals.get(oid)));
        }
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}

