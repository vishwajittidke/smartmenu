/**
 * TestDataFactory — Comprehensive test data creation for all SmartMenu objects.
 * Used by all test classes to maintain consistent test data patterns.
 */
@isTest
public class TestDataFactory {

    public static Account createRestaurant(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    public static Contact createCustomer(String firstName, String lastName, Id accountId) {
        Contact c = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@test.com',
            AccountId = accountId
        );
        insert c;
        return c;
    }

    public static Menu_Item__c createMenuItem(String name, Decimal price, String category,
                                               Id restaurantId) {
        Menu_Item__c item = new Menu_Item__c(
            Name = name,
            Price__c = price,
            Category__c = category,
            Is_Available__c = true,
            Restaurant__c = restaurantId
        );
        insert item;
        return item;
    }

    public static List<Menu_Item__c> createMenuItems(Id restaurantId, Integer count) {
        List<Menu_Item__c> items = new List<Menu_Item__c>();
        String[] categories = new String[]{ 'Appetizer', 'Main Course', 'Dessert', 'Beverage' };
        for (Integer i = 0; i < count; i++) {
            items.add(new Menu_Item__c(
                Name = 'Test Item ' + i,
                Price__c = 10 + i,
                Category__c = categories[Math.mod(i, categories.size())],
                Is_Available__c = true,
                Restaurant__c = restaurantId
            ));
        }
        insert items;
        return items;
    }

    public static Order__c createOrder(String name, String status, Decimal total,
                                        Id customerId, Id restaurantId) {
        Order__c o = new Order__c(
            Name = name,
            Status__c = status,
            Total__c = total,
            Customer__c = customerId,
            Restaurant__c = restaurantId
        );
        insert o;
        return o;
    }

    public static List<Order__c> createOrders(Integer count, Id customerId, Id restaurantId) {
        List<Order__c> orders = new List<Order__c>();
        for (Integer i = 0; i < count; i++) {
            orders.add(new Order__c(
                Name = 'Test Order ' + i,
                Status__c = 'New',
                Total__c = Decimal.valueOf(10 + i),
                Customer__c = customerId,
                Restaurant__c = restaurantId
            ));
        }
        insert orders;
        return orders;
    }

    public static Order__c createCompletedOrder(Id customerId, Id restaurantId) {
        Order__c o = new Order__c(
            Name = 'Completed Order',
            Status__c = 'New',
            Total__c = 100,
            Customer__c = customerId,
            Restaurant__c = restaurantId
        );
        insert o;
        // Transition through valid states
        o.Status__c = 'In Progress';
        update o;
        o.Status__c = 'Completed';
        update o;
        return o;
    }

    public static Order_Item__c createOrderItem(Id orderId, Id menuItemId,
                                                 Integer qty, Decimal unitPrice) {
        Order_Item__c oi = new Order_Item__c(
            Order__c = orderId,
            Menu_Item__c = menuItemId,
            Quantity__c = qty,
            Unit_Price__c = unitPrice
        );
        insert oi;
        return oi;
    }

    public static Review__c createReview(Id orderId, Id customerId, Id restaurantId,
                                          Decimal rating, String comment) {
        Review__c r = new Review__c(
            Order__c = orderId,
            Customer__c = customerId,
            Restaurant__c = restaurantId,
            Rating__c = rating,
            Comment__c = comment
        );
        insert r;
        return r;
    }

    public static Application_Log__c createLog(String message, String level, String source) {
        Application_Log__c log = new Application_Log__c(
            Name = 'TestLog-' + String.valueOf(Datetime.now().getTime()),
            Message__c = message,
            Level__c = level,
            Source__c = source
        );
        insert log;
        return log;
    }
}
