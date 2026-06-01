# Agentforce Architecture


# SmartMenu


## AI-Powered Restaurant Operations Platform


**Version:** 1.0

**Status:** Draft

**Owner:** AI Architect

**Platform:** Salesforce Agentforce, Apex, Platform Data Layer


---


# 1. Purpose


This document defines the architecture, behavior, constraints, and operational model of the SmartMenu AI Assistant built using Agentforce.


It ensures:


* Controlled AI behavior

* Grounded responses from Salesforce data

* Safe execution boundaries

* Auditability of AI decisions

* Predictable escalation paths


---


# 2. Agent Overview


## Agent Name


SmartMenu Assistant


---


## Primary Role


To assist:


* Customers (orders, tracking, recommendations)

* Restaurant Owners (insights, menu performance)

* Support Agents (case summarization)


---


## Core Principle


> The agent does not “guess”. It retrieves, reasons, and responds only from governed Salesforce data.


---


# 3. Agent Architecture


## High-Level Flow


```text id="ag1"

User Input

  ↓

Intent Classification

  ↓

Tool Selection (Salesforce Data / Apex Actions)

  ↓

Grounded Retrieval (SOQL / APIs)

  ↓

Response Generation

  ↓

Guardrail Validation

  ↓

User Response

```


---


# 4. Agent Capabilities


## 4.1 Customer Capabilities


* Track orders

* View menu recommendations

* Check order status

* Submit queries

* Understand restaurant details


---


## 4.2 Restaurant Owner Capabilities


* View revenue summaries

* Analyze top-selling items

* Track order trends

* View customer ratings


---


## 4.3 Support Agent Capabilities


* Summarize customer complaints

* Retrieve order history

* Suggest resolution steps


---


# 5. Data Grounding Strategy


## Allowed Data Sources


* Account (Restaurant)

* Contact (Customer)

* Order__c

* Order_Item__c

* Menu_Item__c

* Review__c

* Case


---


## Restricted Data Sources


* Application_Log__c

* Integration_Transaction__c

* Raw revenue calculations (unaggregated)

* Security configuration objects


---


## Grounding Rule


> Every response must be traceable to Salesforce data.


If no data exists → agent must say:


> “I don’t have enough information to answer that.”


---


# 6. Tooling Strategy


## 6.1 Apex Actions


Agent can invoke:


* OrderService.getOrderStatus()

* MenuService.getRecommendations()

* ReviewService.generateSummary()

* RevenueService.getInsights()


---


## 6.2 SOQL Retrieval Layer


All queries must go through Selector Layer:


* OrderSelector

* MenuSelector

* CustomerSelector


---


## 6.3 Platform Events (Indirect Use)


Agent consumes:


* Order_Placed__e

* Order_Status_Changed__e

* Review_Submitted__e


---


# 7. Prompt Engineering Strategy


## Prompt Structure


```text id="p1"

Context:

- User Role

- Restaurant Data

- Order Data


Task:

- User Request


Constraints:

- Use only Salesforce data

- Do not hallucinate

- Escalate if uncertain

```


---


## Example Prompt


```text id="p2"

You are SmartMenu Assistant.


A customer asked:

"Where is my order?"


Use Order__c data to retrieve status and respond.


If order not found → say you cannot locate it.

```

