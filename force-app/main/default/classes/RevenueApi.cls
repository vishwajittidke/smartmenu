/**
 * RevenueApi — REST API endpoint for revenue and insights.
 * Delegates to RevenueService per architecture.
 */
@RestResource(urlMapping='/insights/*')
global with sharing class RevenueApi {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        String path = req.requestURI;
        String[] parts = path.split('/');
        String lastSegment = parts[parts.size() - 1];

        Id restaurantId = null;
        if (lastSegment != 'insights' && lastSegment.length() >= 15) {
            try {
                restaurantId = (Id) lastSegment;
            } catch (Exception e) {
                // Ignore invalid ID, delegate to service fallback
            }
        }

        Map<String, Object> insights = RevenueService.getInsights(restaurantId);
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(insights));
    }
}
