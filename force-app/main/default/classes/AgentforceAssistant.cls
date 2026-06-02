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

        // Greetings
        if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey') || msg.contains('hola') || msg.contains('greetings')) {
            return 'Hello! Welcome to SmartMenu. I am your virtual culinary assistant. 🍽️ How can I help you today? You can ask me about our menu, check your order status, or query restaurant analytics!';
        }

        // Thanks
        if (msg.contains('thank you') || msg.contains('thanks') || msg.contains('appreciate it')) {
            return 'You\'re very welcome! If you need anything else, feel free to ask. Enjoy your meal! 😊';
        }

        // Order status inquiry
        if (msg.contains('order') && (msg.contains('status') || msg.contains('where') || msg.contains('track'))) {
            // First check if an orderId was explicitly passed in the context
            if (String.isNotBlank(req.orderId)) {
                Order__c order = OrderSelector.selectById(req.orderId);
                if (order != null) {
                    return 'Your order "' + order.Name + '" is currently ' + order.Status__c +
                           '. Total: ₹' + order.Total__c;
                }
            }
            
            // Otherwise, try to extract the order name (e.g. ORD-20260602-120001) from the message
            String orderName = null;
            Integer ordIdx = msg.indexOf('ord-');
            if (ordIdx != -1) {
                String sub = msg.substring(ordIdx);
                List<String> parts = sub.split('[\\s,;.!]+');
                if (!parts.isEmpty()) {
                    orderName = parts[0].toUpperCase();
                }
            }
            
            if (String.isNotBlank(orderName)) {
                List<Order__c> orders = [
                    SELECT Id, Name, Status__c, Total__c, Customer__r.Name,
                           (SELECT Id, Menu_Item__r.Name, Quantity__c FROM Order_Items__r)
                    FROM Order__c 
                    WHERE Name = :orderName 
                    LIMIT 1
                ];
                if (!orders.isEmpty()) {
                    Order__c o = orders[0];
                    String itemsDesc = '';
                    if (o.Order_Items__r != null && !o.Order_Items__r.isEmpty()) {
                        List<String> itemNames = new List<String>();
                        for (Order_Item__c item : o.Order_Items__r) {
                            String itemName = item.Menu_Item__r != null ? item.Menu_Item__r.Name : 'Item';
                            itemNames.add(itemName + ' (x' + Integer.valueOf(item.Quantity__c) + ')');
                        }
                        itemsDesc = ' containing ' + String.join(itemNames, ', ');
                    }
                    return 'Order details for ' + o.Name + ':\n' +
                           '• Customer: ' + (o.Customer__r != null ? o.Customer__r.Name : 'Guest') + '\n' +
                           '• Status: ' + o.Status__c + '\n' +
                           '• Total: ₹' + o.Total__c + '\n' +
                           '• Items:' + itemsDesc;
                }
            }
            
            return 'Could you please provide your order number (e.g. ORD-XXXXXX) so I can look it up?';
        }

        // Specific Item Query
        if (msg.contains('paneer') || msg.contains('wrap') || msg.contains('pasta') || msg.contains('falafel') || msg.contains('salad') || msg.contains('dessert') || msg.contains('beverage') || msg.contains('drink')) {
            String searchKey = '';
            if (msg.contains('paneer') || msg.contains('wrap')) searchKey = 'Paneer';
            else if (msg.contains('pasta')) searchKey = 'Pasta';
            else if (msg.contains('falafel') || msg.contains('salad')) searchKey = 'Falafel';
            else if (msg.contains('dessert') || msg.contains('panna')) searchKey = 'Panna';
            else if (msg.contains('lemonade') || msg.contains('beverage') || msg.contains('drink')) searchKey = 'Lemon';
            
            if (String.isNotBlank(searchKey)) {
                List<Menu_Item__c> matchedItems = [
                    SELECT Id, Name, Description__c, Price__c, Category__c 
                    FROM Menu_Item__c 
                    WHERE Is_Available__c = true AND Name LIKE :('%' + searchKey + '%')
                    LIMIT 3
                ];
                if (!matchedItems.isEmpty()) {
                    String respText = 'Yes, we have that available! Here is what we found:\n';
                    for (Menu_Item__c item : matchedItems) {
                        respText += '• *' + item.Name + '* (₹' + item.Price__c + ') — ' + item.Description__c + '\n';
                    }
                    return respText;
                }
            }
        }

        // Menu recommendations — grounded in actual data
        if (msg.contains('menu') || msg.contains('recommend') || msg.contains('food') || msg.contains('eat')) {
            List<Menu_Item__c> items = MenuSelector.selectAllAvailable(5);
            if (items.isEmpty()) {
                return 'I don\'t have any available menu items to recommend right now.';
            }
            String response = 'Here are our top available items:\n';
            for (Menu_Item__c item : items) {
                response += '• ' + item.Name + ' (₹' + item.Price__c + ') — ' + item.Category__c + '\n';
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
