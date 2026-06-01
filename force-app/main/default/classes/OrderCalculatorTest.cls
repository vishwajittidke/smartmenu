/**
 * OrderCalculatorTest — Tests for the pure domain calculator.
 */
@isTest
private class OrderCalculatorTest {

    @isTest
    static void testCalculateTotals() {
        Account restaurant = TestDataFactory.createRestaurant('Calc Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('Calc', 'Tester', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('ORD-CALC-001', 'New', 0, customer.Id, restaurant.Id);

        Menu_Item__c item1 = TestDataFactory.createMenuItem('Calc Item 1', 10.00, 'Main Course', restaurant.Id);
        Menu_Item__c item2 = TestDataFactory.createMenuItem('Calc Item 2', 5.50, 'Beverage', restaurant.Id);

        insert new List<Order_Item__c>{
            new Order_Item__c(Order__c = order.Id, Menu_Item__c = item1.Id, Quantity__c = 2, Unit_Price__c = 10.00),
            new Order_Item__c(Order__c = order.Id, Menu_Item__c = item2.Id, Quantity__c = 3, Unit_Price__c = 5.50)
        };

        Set<Id> orderIds = new Set<Id>{ order.Id };
        List<Order_Item__c> items = OrderSelector.selectLineItemsByOrderIds(orderIds);
        Map<Id, Decimal> totals = OrderCalculator.calculateTotals(orderIds, items);

        System.assertEquals(36.50, totals.get(order.Id), 'Total should be (2*10)+(3*5.50)=36.50');
    }

    @isTest
    static void testCalculateTotalsEmpty() {
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Decimal> totals = OrderCalculator.calculateTotals(orderIds, new List<Order_Item__c>());
        System.assertEquals(0, totals.size(), 'Empty set should return empty map');
    }

    @isTest
    static void testStampOrderDate() {
        Order__c o = new Order__c(Name = 'Test', Status__c = 'New');
        OrderCalculator.stampOrderDate(new List<Order__c>{ o });
        System.assertNotEquals(null, o.Order_Date__c, 'Date should be stamped');
    }

    @isTest
    static void testStampOrderDatePreserves() {
        Datetime fixed = Datetime.newInstance(2020, 1, 1);
        Order__c o = new Order__c(Name = 'Test', Status__c = 'New', Order_Date__c = fixed);
        OrderCalculator.stampOrderDate(new List<Order__c>{ o });
        System.assertEquals(fixed, o.Order_Date__c, 'Existing date should not be overwritten');
    }
}
