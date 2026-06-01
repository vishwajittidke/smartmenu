/**
 * AgentforceAssistant — Agentforce integration logic.
 * Provides @InvocableMethod for Agentforce to invoke and logs conversations
 * to AI_Conversation__c for observability.
 */
public with sharing class AgentforceAssistant {

    public class AgentRequest {
        @InvocableVariable(label='Session ID' required=true)
        public String sessionId;

        @InvocableVariable(label='User Message' required=true)
        public String message;

        @InvocableVariable(label='Order ID')
        public String orderId;
    }

    public class AgentResponse {
        @InvocableVariable(label='Response Text')
        public String responseText;

        @InvocableVariable(label='Escalated')
        public Boolean escalated;
    }

    @InvocableMethod(label='SmartMenu AI Assistant' description='Handles customer messages via Agentforce')
    public static List<AgentResponse> handleMessages(List<AgentRequest> requests) {
        List<AgentResponse> responses = new List<AgentResponse>();
        for (AgentRequest req : requests) {
            responses.add(processMessage(req));
        }
        return responses;
    }

    /**
     * Legacy method — preserved for backward compatibility with AgentApi.
     */
    public static void handleMessage(String sessionId, String message) {
        AgentRequest req = new AgentRequest();
        req.sessionId = sessionId;
        req.message = message;
        processMessage(req);
    }

    private static AgentResponse processMessage(AgentRequest req) {
        AgentResponse resp = new AgentResponse();
        resp.escalated = false;

        try {
            // Determine intent and generate grounded response
            String responseText = routeAndRespond(req);
            resp.responseText = responseText;

            // Log the conversation
            logConversation(req.sessionId, req.message, responseText, false, req.orderId);

        } catch (Exception e) {
            resp.responseText = 'I encountered an issue processing your request. Let me connect you with a support agent.';
            resp.escalated = true;
            logConversation(req.sessionId, req.message, resp.responseText, true, req.orderId);
            logError('AgentforceAssistant', e);
            createEscalationCase(req.sessionId, req.message, e.getMessage());
        }

        return resp;
    }

    private static void createEscalationCase(String sessionId, String userMessage, String errorMsg) {
        try {
            Case c = new Case(
                Subject = 'AI Escalation — Session ' + sessionId,
                Description = 'User message: ' + userMessage + '\n\nError: ' + errorMsg,
                Origin = 'Chat',
                Status = 'New',
                Priority = 'Medium'
            );
            insert c;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Escalation Case creation failed: ' + e.getMessage());
        }
    }

    private static String routeAndRespond(AgentRequest req) {
        String msg = req.message != null ? req.message.toLowerCase() : '';

        // Order status inquiry
        if (msg.contains('order') && (msg.contains('status') || msg.contains('where') || msg.contains('track'))) {
            if (String.isNotBlank(req.orderId)) {
                Order__c order = OrderSelector.selectById(req.orderId);
                if (order != null) {
                    return 'Your order "' + order.Name + '" is currently ' + order.Status__c +
                           '. Total: $' + order.Total__c;
                }
                return 'I don\'t have enough information to answer that. I could not locate that order.';
            }
            return 'Could you please provide your order number so I can look it up?';
        }

        // Menu recommendations — grounded in actual data
        if (msg.contains('menu') || msg.contains('recommend') || msg.contains('food') || msg.contains('eat')) {
            List<Menu_Item__c> items = MenuSelector.selectAllAvailable(5);
            if (items.isEmpty()) {
                return 'I don\'t have any available menu items to recommend right now.';
            }
            String response = 'Here are our top available items:\n';
            for (Menu_Item__c item : items) {
                response += '• ' + item.Name + ' ($' + item.Price__c + ') — ' + item.Category__c + '\n';
            }
            return response;
        }

        // Revenue insights — grounded in actual data
        if (msg.contains('revenue') || msg.contains('insight') || msg.contains('sales') || msg.contains('analytics')) {
            return 'I can provide revenue insights for a specific restaurant. Please provide the restaurant ID or ask your admin for access to the Revenue Dashboard.';
        }

        // Default response
        return 'I\'m SmartMenu Assistant. I can help you with order tracking, menu recommendations, and restaurant information. How can I assist you?';
    }

    private static void logConversation(String sessionId, String prompt, String response,
                                         Boolean escalated, String orderId) {
        try {
            AI_Conversation__c conv = new AI_Conversation__c(
                Session_Id__c    = sessionId,
                User_Prompt__c   = prompt,
                Agent_Response__c = response,
                Escalated__c     = escalated
            );
            if (String.isNotBlank(orderId)) {
                try {
                    conv.Related_Order__c = orderId;
                } catch (Exception e) {
                    // orderId may not be valid — skip
                }
            }
            insert conv;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'AI conversation logging failed: ' + e.getMessage());
        }
    }

    private static void logError(String source, Exception e) {
        try {
            Application_Log__c log = new Application_Log__c(
                Name = 'Error-' + String.valueOf(Datetime.now().getTime()),
                Message__c = e.getMessage(),
                Level__c = 'ERROR',
                Source__c = source,
                Stack_Trace__c = e.getStackTraceString()
            );
            insert log;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error logging failed: ' + ex.getMessage());
        }
    }
}
