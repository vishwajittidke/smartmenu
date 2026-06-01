@RestResource(urlMapping='/agent/*')
global with sharing class AgentApi {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            String sessionId = payload.containsKey('sessionId') ? (String) payload.get('sessionId') : 'unknown';
            String message = payload.containsKey('message') ? (String) payload.get('message') : '';
            AgentforceAssistant.handleMessage(sessionId, message);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('{"status":"ok"}');
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        }
    }
}
