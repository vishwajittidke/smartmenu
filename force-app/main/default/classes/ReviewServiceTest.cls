@isTest
private class ReviewServiceTest {
    @isTest
    static void testSubmitReview() {
        Account restaurant = TestDataFactory.createRestaurant('Review Test');
        Contact customer = TestDataFactory.createCustomer('Review', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Review Order', 'New', 50, customer.Id, restaurant.Id);

        Test.startTest();
        Review__c review = ReviewService.submitReview(order.Id, customer.Id, restaurant.Id, 4.5, 'Great food!');
        Test.stopTest();

        System.assertNotEquals(null, review.Id, 'Review should be created');
        System.assertEquals(4.5, review.Rating__c, 'Rating should match');
    }

    @isTest
    static void testSubmitReviewInvalidRating() {
        Account restaurant = TestDataFactory.createRestaurant('Bad Review');

        Test.startTest();
        try {
            ReviewService.submitReview(null, null, restaurant.Id, 6, 'Too high');
            System.assert(false, 'Should throw');
        } catch (BusinessException e) {
            System.assert(e.getMessage().contains('between 1 and 5'));
        }
        Test.stopTest();
    }

    @isTest
    static void testGenerateSummary() {
        Account restaurant = TestDataFactory.createRestaurant('Summary Test');
        Contact customer = TestDataFactory.createCustomer('Summary', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Summary Order', 'New', 50, customer.Id, restaurant.Id);
        TestDataFactory.createReview(order.Id, customer.Id, restaurant.Id, 4, 'Good');
        TestDataFactory.createReview(order.Id, customer.Id, restaurant.Id, 5, 'Excellent');

        Test.startTest();
        Map<String, Object> summary = ReviewService.generateSummary(restaurant.Id);
        Test.stopTest();

        System.assertEquals(2, (Integer) summary.get('totalReviews'), 'Should have 2 reviews');
    }
}
