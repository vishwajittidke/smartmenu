/**
 * AgentforceAssistantCoverageTest — Additional tests for untested paths.
 */
@isTest
private class AgentforceAssistantCoverageTest {

    @isTest
    static void testMenuRecommendation() {
        Account restaurant = TestDataFactory.createRestaurant('AI Menu Restaurant');
        TestDataFactory.createMenuItem('AI Pasta', 18.00, 'Main Course', restaurant.Id);

        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-menu-session';
        req.message = 'What do you recommend from the menu?';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assertEquals(1, responses.size());
        System.assert(responses[0].responseText.contains('AI Pasta'),
            'Should include actual menu item name');
        System.assertEquals(false, responses[0].escalated);
    }

    @isTest
    static void testFoodIntent() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-food-session';
        req.message = 'What food do you have?';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assertEquals(1, responses.size());
        System.assertEquals(false, responses[0].escalated);
    }

    @isTest
    static void testRevenueIntent() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-revenue-session';
        req.message = 'Show me the revenue insights';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assertEquals(1, responses.size());
        System.assert(responses[0].responseText.contains('revenue'),
            'Should mention revenue');
    }

    @isTest
    static void testOrderTrackingWithoutId() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-track-session';
        req.message = 'Where is my order?';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assert(responses[0].responseText.contains('order number'),
            'Should ask for order number');
    }

    @isTest
    static void testOrderTrackingNotFound() {
        AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
        req.sessionId = 'test-notfound-session';
        req.message = 'What is my order status?';
        req.orderId = 'a0000000000FAKE';

        List<AgentforceAssistant.AgentResponse> responses =
            AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

        System.assert(responses[0].responseText.contains('could not locate') ||
                       responses[0].responseText.contains('issue'),
            'Should indicate order not found or error');
    }
}
