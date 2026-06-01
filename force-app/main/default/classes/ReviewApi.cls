/**
 * ReviewApi — REST API endpoint for customer reviews.
 * Delegates to ReviewService per architecture.
 */
@RestResource(urlMapping='/reviews/*')
global with sharing class ReviewApi {

    @HttpGet
    global static List<Review__c> doGet() {
        RestRequest req = RestContext.request;
        String path = req.requestURI;
        String[] parts = path.split('/');
        String lastSegment = parts[parts.size() - 1];

        if (lastSegment != 'reviews' && lastSegment.length() >= 15) {
            // Treat as restaurant ID
            return ReviewSelector.selectByRestaurant(lastSegment);
        }
        // Return recent reviews (top 50)
        return ReviewSelector.selectRecentReviews(50);
    }

    @HttpPost
    global static void doPost() {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        try {
            Map<String, Object> payload = (Map<String, Object>)
                JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            String orderId = payload.containsKey('orderId') ? (String) payload.get('orderId') :
                             (payload.containsKey('order') ? (String) payload.get('order') :
                             (payload.containsKey('Order__c') ? (String) payload.get('Order__c') : null));

            String customerId = payload.containsKey('customerId') ? (String) payload.get('customerId') :
                                (payload.containsKey('customer') ? (String) payload.get('customer') :
                                (payload.containsKey('Customer__c') ? (String) payload.get('Customer__c') : null));

            String restaurantId = payload.containsKey('restaurantId') ? (String) payload.get('restaurantId') :
                                  (payload.containsKey('restaurant') ? (String) payload.get('restaurant') :
                                  (payload.containsKey('Restaurant__c') ? (String) payload.get('Restaurant__c') : null));

            Decimal rating = null;
            Object ratingVal = payload.containsKey('rating') ? payload.get('rating') :
                               (payload.containsKey('Rating__c') ? payload.get('Rating__c') : null);
            if (ratingVal != null) {
                rating = Decimal.valueOf(String.valueOf(ratingVal));
            }

            String comment = payload.containsKey('comment') ? (String) payload.get('comment') :
                             (payload.containsKey('Comment__c') ? (String) payload.get('Comment__c') : null);

            Review__c review = ReviewService.submitReview(orderId, customerId, restaurantId, rating, comment);

            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(review));

        } catch (BusinessException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        }
    }
}
