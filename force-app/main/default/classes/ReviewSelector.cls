/**
 * ReviewSelector — All SOQL for Review__c in one place.
 * Per architecture: no SOQL outside selectors.
 */
public with sharing class ReviewSelector {

    public static List<Review__c> selectByRestaurant(Id restaurantId) {
        return [
            SELECT Id, Name, Rating__c, Comment__c, Customer__c,
                   Customer__r.FirstName, Customer__r.LastName, CreatedDate
            FROM Review__c
            WHERE Restaurant__c = :restaurantId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }

    public static Map<String, Object> selectAggregateByRestaurant(Id restaurantId) {
        AggregateResult[] results = [
            SELECT AVG(Rating__c) avgRating, COUNT(Id) totalReviews
            FROM Review__c
            WHERE Restaurant__c = :restaurantId
        ];
        Map<String, Object> summary = new Map<String, Object>();
        if (!results.isEmpty()) {
            summary.put('averageRating', results[0].get('avgRating'));
            summary.put('totalReviews', results[0].get('totalReviews'));
        }
        return summary;
    }

    public static Review__c selectById(Id reviewId) {
        List<Review__c> reviews = [
            SELECT Id, Name, Rating__c, Comment__c, Customer__c, Restaurant__c,
                   Order__c, CreatedDate
            FROM Review__c
            WHERE Id = :reviewId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return reviews.isEmpty() ? null : reviews[0];
    }
}
