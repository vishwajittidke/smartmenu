/**
 * ReviewService — Business workflows for customer reviews.
 * All SOQL delegated to ReviewSelector per architecture.
 */
public with sharing class ReviewService {

    @AuraEnabled
    public static Review__c submitReview(Id orderId, Id customerId, Id restaurantId,
                                          Decimal rating, String comment) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new BusinessException('Rating must be between 1 and 5.');
        }
        if (restaurantId == null) {
            throw new BusinessException('Restaurant is required.');
        }

        Review__c review = new Review__c(
            Order__c = orderId,
            Customer__c = customerId,
            Restaurant__c = restaurantId,
            Rating__c = rating,
            Comment__c = comment
        );
        insert review;

        // Publish platform event
        publishReviewEvent(review);

        return review;
    }

    @AuraEnabled(cacheable=true)
    public static List<Review__c> getReviewsForRestaurant(Id restaurantId) {
        return ReviewSelector.selectByRestaurant(restaurantId);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> generateSummary(Id restaurantId) {
        return ReviewSelector.selectAggregateByRestaurant(restaurantId);
    }

    private static void publishReviewEvent(Review__c review) {
        Review_Submitted__e evt = new Review_Submitted__e(
            Review_Id__c     = review.Id,
            Restaurant_Id__c = review.Restaurant__c,
            Rating__c        = review.Rating__c
        );
        Database.SaveResult sr = EventBus.publish(evt);
        if (!sr.isSuccess()) {
            System.debug(LoggingLevel.ERROR, 'Review_Submitted__e publish failed: ' + sr.getErrors());
        }
    }
}
