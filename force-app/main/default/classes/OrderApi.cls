@RestResource(urlMapping='/orders/*')
global with sharing class OrderApi {
    @HttpGet
    global static List<Order__c> doGet() {
        RestRequest req = RestContext.request;
        // basic list retrieval — could extend with query params
        return [SELECT Id, Name, Status__c, Total__c, Customer__c FROM Order__c ORDER BY CreatedDate DESC LIMIT 50];
    }

    @HttpPost
    global static RestResponse doPost() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        // minimal JSON parsing; in production use JSON.deserialize
        try {
            Order__c o = (Order__c) JSON.deserialize(body, Order__c.class);
            insert o;
            RestResponse res = RestContext.response;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(o));
            return res;
        } catch (Exception e) {
            RestResponse res = RestContext.response;
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"'+ e.getMessage() +'"}');
            return res;
        }
    }
}
