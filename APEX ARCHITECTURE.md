\# Apex Architecture



\# SmartMenu



\## AI-Powered Restaurant Operations Platform



\*\*Version:\*\* 1.0

\*\*Status:\*\* Draft

\*\*Owner:\*\* Salesforce Technical Architect

\*\*Platform:\*\* Salesforce Apex, Lightning Platform



\---



\# 1. Purpose



This document defines the Apex design standards, patterns, and execution model for SmartMenu.



It ensures:



\* Scalable Apex design

\* Governor limit safety

\* Testability

\* Reusability

\* Security enforcement

\* Separation of concerns



\---



\# 2. Apex Architecture Overview



SmartMenu follows a \*\*layered Apex architecture pattern\*\*:



```text id="a1k9qz"

Trigger Layer

&#x20;   ↓

Handler Layer

&#x20;   ↓

Service Layer

&#x20;   ↓

Domain Layer

&#x20;   ↓

Selector Layer

&#x20;   ↓

SObject Layer (Data)

```



\---



\# 3. Trigger Design Strategy



\## Rules



\* One trigger per object

\* No business logic in triggers

\* Triggers only delegate



\---



\## Trigger Structure



Example:



```apex id="t9x2lm"

trigger OrderTrigger on Order\_\_c (before insert, before update, after insert, after update) {

&#x20;   OrderTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.operationType);

}

```



\---



\## Supported Objects



\* Order\_\_c

\* Order\_Item\_\_c

\* Review\_\_c

\* Case



\---



\# 4. Trigger Handler Layer



\## Purpose



Central entry point for trigger logic.



\---



\## Responsibilities



\* Route execution by context

\* Prevent recursion

\* Delegate to service layer



\---



\## Example Structure



```apex id="h2x7pz"

public class OrderTriggerHandler {



&#x20;   public static void handle(List<Order\_\_c> newList,

&#x20;                             Map<Id, Order\_\_c> oldMap,

&#x20;                             System.TriggerOperation operation) {



&#x20;       if (operation == System.TriggerOperation.BEFORE\_INSERT) {

&#x20;           OrderService.beforeInsert(newList);

&#x20;       }



&#x20;       if (operation == System.TriggerOperation.AFTER\_UPDATE) {

&#x20;           OrderService.afterUpdate(newList, oldMap);

&#x20;       }

&#x20;   }

}

```



\---



\# 5. Service Layer



\## Purpose



Contains business workflows.



\---



\## Services



\### OrderService



Responsibilities:



\* Calculate order totals

\* Validate restaurant availability

\* Publish order events

\* Handle status transitions



\---



\### MenuService



\* Menu validation

\* Price calculations

\* Availability rules



\---



\### ReviewService



\* Validate rating rules

\* Trigger AI response generation



\---



\### RevenueService



\* Revenue aggregation logic

\* Summary calculations



\---



\## Example



```apex id="s8k4qz"

public class OrderService {



&#x20;   public static void beforeInsert(List<Order\_\_c> orders) {

&#x20;       OrderValidator.validateOrders(orders);

&#x20;       OrderCalculator.calculateTotals(orders);

&#x20;   }



&#x20;   public static void afterUpdate(List<Order\_\_c> newList,

&#x20;                                  Map<Id, Order\_\_c> oldMap) {



&#x20;       OrderEventPublisher.publishStatusChanges(newList, oldMap);

&#x20;   }

}

```



\---



\# 6. Domain Layer



\## Purpose



Encapsulates pure business rules.



No DML. No SOQL.



\---



\## Examples



\### OrderDomain



Rules:



\* Order must be within restaurant operating hours

\* Order cannot be placed if restaurant is inactive

\* Status transitions must be valid



\---



\## Example



```apex id="d4l9mn"

public class OrderDomain {



&#x20;   public static void validateStatusTransition(Order\_\_c oldOrder, Order\_\_c newOrder) {



&#x20;       if (oldOrder.Status\_\_c == 'Delivered'

&#x20;           \&\& newOrder.Status\_\_c == 'Preparing') {

&#x20;           throw new BusinessException('Invalid status transition');

&#x20;       }

&#x20;   }

}

```



\---



\# 7. Selector Layer



\## Purpose



Centralized SOQL layer.



\---



\## Rules



\* No SOQL in Service Layer

\* Queries must be reusable

\* Must support bulk operations



\---



\## Example



```apex id="q3v8zx"

public class OrderSelector {



&#x20;   public static List<Order\_\_c> getOrdersByRestaurant(Id restaurantId) {

&#x20;       return \[

&#x20;           SELECT Id, Status\_\_c, Total\_\_c

&#x20;           FROM Order\_\_c

&#x20;           WHERE Restaurant\_\_c = :restaurantId

&#x20;       ];

&#x20;   }

}

```



\---



\# 8. Utility Layer



\## Purpose



Reusable helpers.



\---



\## Examples



\* Date utilities

\* String utilities

\* JSON serialization helpers



\---



\# 9. Async Processing Architecture



\---



\## Queueable Apex



\### Use Cases



\* Agentforce responses

\* Notifications

\* External API calls



\---



\## Example



```apex id="a7z1pq"

public class ReviewResponseQueueable implements Queueable {



&#x20;   public void execute(QueueableContext context) {



&#x20;       List<Review\_\_c> reviews = ReviewSelector.getPendingReviews();



&#x20;       for (Review\_\_c r : reviews) {

&#x20;           r.AI\_Response\_\_c = AIService.generateResponse(r.Comment\_\_c);

&#x20;       }



&#x20;       update reviews;

&#x20;   }

}

```



\---



\## Batch Apex



\### Use Cases



\* Revenue aggregation

\* Order archiving

\* Analytics computation



\---



\## Example



```apex id="b1x7lm"

global class RevenueBatch implements Database.Batchable<SObject> {



&#x20;   global Database.QueryLocator start(Database.BatchableContext bc) {

&#x20;       return Database.getQueryLocator(

&#x20;           'SELECT Id, Total\_\_c FROM Order\_\_c WHERE Status\_\_c = \\'Delivered\\''

&#x20;       );

&#x20;   }



&#x20;   global void execute(Database.BatchableContext bc, List<Order\_\_c> scope) {



&#x20;       RevenueService.aggregate(scope);

&#x20;   }



&#x20;   global void finish(Database.BatchableContext bc) {}

}

```



\---



\## Scheduled Apex



\### Use Cases



\* Idle order detection

\* SLA checks

\* Data cleanup



\---



\# 10. Exception Handling Framework



\---



\## Exception Types



```text id="e9m2qz"

ApplicationException

BusinessException

ValidationException

IntegrationException

```



\---



\## Example



```apex id="x2p9lm"

public class BusinessException extends Exception {}

```



\---



\# 11. Logging Framework



\---



\## Object



```text id="l1z8qv"

Application\_Log\_\_c

```



\---



\## Usage



```apex id="g7x2lm"

ApplicationLogger.logError('OrderService', 'calculateTotals', ex.getMessage());

```



\---



\# 12. Security Enforcement in Apex



\---



\## Mandatory Rules



\* WITH SHARING on all service classes

\* CRUD/FLS enforced using:



```apex id="s3v8qz"

Security.stripInaccessible()

```



\* No hardcoded IDs

\* No bypassing sharing without justification



\---



\# 13. Event-Driven Apex



\---



\## Platform Event Publishing



```apex id="p9x3lm"

Order\_Placed\_\_e event = new Order\_Placed\_\_e(

&#x20;   OrderId\_\_c = order.Id,

&#x20;   RestaurantId\_\_c = order.Restaurant\_\_c

);



EventBus.publish(event);

```



\---



\# 14. Integration Apex



\---



\## Patterns



\* Request/Response Apex REST

\* Named Credential integration

\* Retry logic for failures



\---



\## Example Endpoint



```apex id="i8z2lm"

@RestResource(urlMapping='/api/v1/orders/\*')

global class OrderAPI {



&#x20;   @HttpPost

&#x20;   global static String createOrder() {

&#x20;       // logic delegated to service layer

&#x20;       return OrderService.createOrder();

&#x20;   }

}

```



\---



\# 15. Performance Standards



\---



\## Apex Rules



\* No SOQL in loops

\* No DML in loops

\* Bulk-safe methods only

\* Use Sets and Maps for lookup optimization



\---



\## Limits Strategy



| Area  | Strategy                         |

| ----- | -------------------------------- |

| SOQL  | Bulk queries                     |

| DML   | Single operation per transaction |

| Async | Queueable/Batch                  |

| CPU   | Minimize loops                   |



\---



\# 16. Testing Strategy



\---



\## Required Coverage



\* Minimum 90%

\* Business logic focused tests

\* Negative test cases required



\---



\## Test Types



\* Unit Tests

\* Integration Tests

\* Bulk Tests

\* Security Tests



\---



\## Example



```apex id="t5x9lm"

@isTest

private class OrderServiceTest {



&#x20;   @isTest

&#x20;   static void testOrderCalculation() {



&#x20;       // Arrange

&#x20;       Order\_\_c order = TestDataFactory.createOrder();



&#x20;       // Act

&#x20;       OrderService.beforeInsert(new List<Order\_\_c>{order});



&#x20;       // Assert

&#x20;       System.assert(order.Total\_\_c > 0);

&#x20;   }

}

```



\---



\# 17. Design Principles



\* Single Responsibility Principle

\* Separation of Concerns

\* Bulkification first

\* Security by design

\* Event-driven where possible

\* Async for heavy operations



\---



\# End of Document



