System.debug('=== SmartMenu Agent Runner ===');

// Create test data via DML (only standard/visible fields)
Account restaurant = new Account(Name = 'Demo Restaurant');
insert restaurant;

Contact customer = new Contact(FirstName = 'Demo', LastName = 'Customer', AccountId = restaurant.Id);
insert customer;

// Use the Service Layer to create orders (runs in system mode internally)
Order__c testOrder = OrderService.createOrder('Demo Order', customer.Id, restaurant.Id);
System.debug('✓ Order created: ' + testOrder.Id + ' | ' + testOrder.Name);

// Create a menu item via MenuService
Menu_Item__c menuItem = MenuService.createMenuItem('Paneer Tikka Wrap', 'Spiced paneer cubes grilled with bell peppers and wrapped in a warm tortilla with mint chutney', 12.99, 'Main Course', restaurant.Id);
System.debug('✓ Menu item created: ' + menuItem.Name + ' | $' + menuItem.Price__c);

// Test the Agentforce assistant
AgentforceAssistant.AgentRequest req = new AgentforceAssistant.AgentRequest();
req.sessionId = 'demo-session-' + String.valueOf(Datetime.now().getTime());
req.message = 'Where is my order?';
req.orderId = testOrder.Id;

List<AgentforceAssistant.AgentResponse> responses =
    AgentforceAssistant.handleMessages(new List<AgentforceAssistant.AgentRequest>{ req });

System.debug('✓ Agent Response: ' + responses[0].responseText);
System.debug('  Escalated: ' + responses[0].escalated);

// Update order status through the service
Order__c updated = OrderService.updateOrderStatus(testOrder.Id, 'In Progress');
System.debug('✓ Order status updated to: In Progress');

// Submit a review
Review__c review = ReviewService.submitReview(testOrder.Id, customer.Id, restaurant.Id, 4.5, 'Great food, fast service!');
System.debug('✓ Review submitted: ' + review.Rating__c + ' stars');

// Get revenue insights
Map<String, Object> insights = RevenueService.getInsights(restaurant.Id);
System.debug('✓ Revenue Insights: ' + JSON.serializePretty(insights));

// Get menu recommendations
List<Menu_Item__c> menu = MenuService.getMenuForRestaurant(restaurant.Id);
System.debug('✓ Menu items for restaurant: ' + menu.size());

System.debug('=== Agent Runner Complete — All Systems Go ===');
