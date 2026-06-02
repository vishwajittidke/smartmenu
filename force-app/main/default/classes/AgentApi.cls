@RestResource(urlMapping='/agent/*')
global with sharing class AgentApi {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            String sessionId = payload.containsKey('sessionId') ? (String) payload.get('sessionId') : 'unknown';
            String message = payload.containsKey('message') ? (String) payload.get('message') : '';
            String orderId = payload.containsKey('orderId') ? (String) payload.get('orderId') : null;
            
            AgentforceAssistant.AgentRequest agentReq = new AgentforceAssistant.AgentRequest();
            agentReq.sessionId = sessionId;
            agentReq.message = message;
            agentReq.orderId = orderId;
            
            List<AgentforceAssistant.AgentResponse> responses = AgentforceAssistant.handleMessages(
                new List<AgentforceAssistant.AgentRequest>{ agentReq }
            );
            
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            if (!responses.isEmpty()) {
                res.responseBody = Blob.valueOf(JSON.serialize(responses[0]));
            } else {
                res.responseBody = Blob.valueOf('{"responseText":"I could not generate a response.","escalated":false}');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"' + String.escapeSingleQuotes(e.getMessage()) + '"}');
        }
    }
}
