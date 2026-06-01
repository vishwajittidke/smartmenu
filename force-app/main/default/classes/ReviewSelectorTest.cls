/**
 * ReviewSelectorTest — Tests for ReviewSelector SOQL methods.
 */
@isTest
private class ReviewSelectorTest {

    @isTest
    static void testSelectByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('RevSel Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('Rev', 'Selector', restaurant.Id);
        TestDataFactory.createReview(null, customer.Id, restaurant.Id, 4, 'Great food!');

        List<Review__c> results = ReviewSelector.selectByRestaurant(restaurant.Id);
        System.assertEquals(1, results.size(), 'Should find 1 review');
        System.assertEquals('Great food!', results[0].Comment__c);
    }

    @isTest
    static void testSelectAggregateByRestaurant() {
        Account restaurant = TestDataFactory.createRestaurant('Agg Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('Agg', 'Tester', restaurant.Id);
        TestDataFactory.createReview(null, customer.Id, restaurant.Id, 5, 'Excellent');
        TestDataFactory.createReview(null, customer.Id, restaurant.Id, 3, 'Average');

        Map<String, Object> summary = ReviewSelector.selectAggregateByRestaurant(restaurant.Id);
        System.assertEquals(2, (Integer) summary.get('totalReviews'));
        System.assertEquals(4.0, (Decimal) summary.get('averageRating'));
    }

    @isTest
    static void testSelectById() {
        Account restaurant = TestDataFactory.createRestaurant('ById Test Restaurant');
        Contact customer = TestDataFactory.createCustomer('ById', 'Tester', restaurant.Id);
        Review__c review = TestDataFactory.createReview(null, customer.Id, restaurant.Id, 5, 'Excellent!');

        Review__c result = ReviewSelector.selectById(review.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(5, result.Rating__c);
    }

    @isTest
    static void testSelectByIdNotFound() {
        Account restaurant = TestDataFactory.createRestaurant('Dummy');
        Contact customer = TestDataFactory.createCustomer('Dummy', 'User', restaurant.Id);
        // Query with a valid-format but non-existent ID
        Review__c review = TestDataFactory.createReview(null, customer.Id, restaurant.Id, 1, 'x');
        delete review;
        Review__c result = ReviewSelector.selectById(review.Id);
        System.assertEquals(null, result, 'Should return null for deleted review');
    }
}
