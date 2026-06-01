/**
 * CustomerSelectorTest — Tests for CustomerSelector SOQL methods.
 */
@isTest
private class CustomerSelectorTest {

    @isTest
    static void testSelectById() {
        Account restaurant = TestDataFactory.createRestaurant('CustSel Restaurant');
        Contact customer = TestDataFactory.createCustomer('CustSel', 'Tester', restaurant.Id);
        Contact result = CustomerSelector.selectById(customer.Id);
        System.assertNotEquals(null, result);
        System.assertEquals('Tester', result.LastName);
    }

    @isTest
    static void testSelectByAccountId() {
        Account restaurant = TestDataFactory.createRestaurant('CustSel Account');
        TestDataFactory.createCustomer('AcctSel', 'User', restaurant.Id);

        List<Contact> results = CustomerSelector.selectByAccountId(restaurant.Id);
        System.assertEquals(1, results.size(), 'Should find 1 contact');
    }

    @isTest
    static void testSelectByEmail() {
        Account restaurant = TestDataFactory.createRestaurant('Email Restaurant');
        Contact customer = TestDataFactory.createCustomer('Email', 'Finder', restaurant.Id);
        // TestDataFactory creates email as firstname.lastname@test.com
        Contact result = CustomerSelector.selectByEmail('email.finder@test.com');
        System.assertNotEquals(null, result);
        System.assertEquals(customer.Id, result.Id);
    }

    @isTest
    static void testSelectByEmailNotFound() {
        Contact result = CustomerSelector.selectByEmail('nonexistent@nowhere.test');
        System.assertEquals(null, result, 'Should return null for unknown email');
    }
}
