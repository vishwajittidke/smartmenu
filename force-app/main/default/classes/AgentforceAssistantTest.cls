@isTest
private class AgentforceAssistantTest {
    @isTest
    static void testHandleMessageOrderStatus() {
        Account restaurant = TestDataFactory.createRestaurant('Agent Test');
        Contact customer = TestDataFactory.createCustomer('Test', 'User', restaurant.Id);
        Order__c order = TestDataFactory.createOrder('Agent Order', 'New', 99, customer.Id, restaurant.Id);

        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-session-1';
        req.message = 'Where is my order?';
        req.orderId = order.Id;

        Test.startTest();
        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertNotEquals(null, responses[0].responseText, 'Should have response text');
        System.assertEquals(false, responses[0].escalated, 'Should not be escalated');

        // Verify AI conversation was logged
        List<AI_Conversation__c> logs = [SELECT Id FROM AI_Conversation__c WHERE Session_Id__c = 'test-session-1'];
        System.assertEquals(1, logs.size(), 'Should log AI conversation');
    }

    @isTest
    static void testHandleMessageGeneral() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-session-2';
        req.message = 'Hello';

        Test.startTest();
        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });
        Test.stopTest();

        System.assert(responses[0].responseText.contains('SmartMenu Assistant'),
                       'Default response should identify as SmartMenu Assistant');
    }

    @isTest
    static void testLegacyHandleMessage() {
        Test.startTest();
        AgentforceAssistant.handleMessage('legacy-session', 'Hello from legacy');
        Test.stopTest();

        List<AI_Conversation__c> logs = [SELECT Id FROM AI_Conversation__c WHERE Session_Id__c = 'legacy-session'];
        System.assertEquals(1, logs.size(), 'Legacy method should also log conversation');
    }
}
