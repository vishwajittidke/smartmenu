# Apex Architecture


# SmartMenu


## AI-Powered Restaurant Operations Platform


**Version:** 1.0

**Status:** Draft

**Owner:** Salesforce Technical Architect

**Platform:** Salesforce Apex, Lightning Platform


---


# 1. Purpose


This document defines the Apex design standards, patterns, and execution model for SmartMenu.


It ensures:


* Scalable Apex design

* Governor limit safety

* Testability

* Reusability

* Security enforcement

* Separation of concerns


---


# 2. Apex Architecture Overview


SmartMenu follows a **layered Apex architecture pattern**:


```text id="a1k9qz"

Trigger Layer

   ↓

Handler Layer

   ↓

Service Layer

   ↓

Domain Layer

   ↓

Selector Layer

   ↓

SObject Layer (Data)

```


---


# 3. Trigger Design Strategy


## Rules


* One trigger per object

* No business logic in triggers

* Triggers only delegate


---


## Trigger Structure


Example:


```apex id="t9x2lm"

trigger OrderTrigger on Order__c (before insert, before update, after insert, after update) {

   OrderTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.operationType);

}

```


---


## Supported Objects


* Order__c

* Order_Item__c

* Review__c

* Case


---


# 4. Trigger Handler Layer


## Purpose


Central entry point for trigger logic.


---


## Responsibilities


* Route execution by context

* Prevent recursion

* Delegate to service layer


---


## Example Structure


```apex id="h2x7pz"

public class OrderTriggerHandler {


   public static void handle(List<Order__c> newList,

                             Map<Id, Order__c> oldMap,

                             System.TriggerOperation operation) {


       if (operation == System.TriggerOperation.BEFORE_INSERT) {

           OrderService.beforeInsert(newList);

       }


       if (operation == System.TriggerOperation.AFTER_UPDATE) {

           OrderService.afterUpdate(newList, oldMap);

       }
   }
}

```


---


# 5. Service Layer


## Purpose


Contains business workflows.


---


## Services


### OrderService


Responsibilities:


* Calculate order totals

* Validate restaurant availability

* Publish order events

* Handle status transitions


---


### MenuService


* Menu validation

* Price calculations

* Availability rules


---


### ReviewService


* Validate rating rules

* Trigger AI response generation


---


### RevenueService


* Revenue aggregation logic

* Summary calculations


---


## Example


```apex id="s8k4qz"

public class OrderService {


   public static void beforeInsert(List<Order__c> orders) {

       OrderValidator.validateOrders(orders);

       OrderCalculator.calculateTotals(orders);

   }


   public static void afterUpdate(List<Order__c> newList,

                                  Map<Id, Order__c> oldMap) {


       OrderEventPublisher.publishStatusChanges(newList, oldMap);

   }
}

```


---


# 6. Domain Layer


## Purpose


Encapsulates pure business rules.


No DML. No SOQL.


---


## Examples


### OrderDomain


Rules:


* Order must be within restaurant operating hours

* Order cannot be placed if restaurant is inactive

* Status transitions must be valid

