# Architecture Decision Records (ADR)


# SmartMenu


## AI-Powered Restaurant Operations Platform


**Version:** 1.0

**Status:** Living Document

**Owner:** Solution Architect

**Purpose:** Record architectural decisions and rationale


---


# ADR-001 — Use Salesforce Standard Objects (Account/Contact) vs Custom Objects


## Status


Accepted


## Decision


Use:


* `Account` → Restaurant (Record Type)

* `Contact` → Customer


Instead of:


* `Restaurant__c`

* `Customer__c`


## Rationale


* Native CRM integration

* Better scalability

* Built-in reporting & activities

* Easier Service Cloud + Agentforce integration


## Trade-offs


* Slight loss of domain purity

* Requires record type discipline


---


# ADR-002 — Order Status History as Separate Object


## Status


Accepted


## Decision


Create:


* `Order_Status_History__c`


## Rationale


* Salesforce field history tracking is insufficient for analytics

* Needed for audit trails + AI context

* Enables time-series analysis


---


# ADR-003 — Layered Apex Architecture (Trigger → Handler → Service → Domain → Selector)


## Status


Accepted


## Decision


Enforce strict layering model.


## Rationale


* Prevents logic sprawl in triggers

* Improves testability

* Enables reuse of business logic


## Alternatives Considered


* Fat controller pattern (rejected)

* Trigger-only logic (rejected)


---


# ADR-004 — Platform Events for Async Communication


## Status


Accepted


## Decision


Use Platform Events for:


* Order updates

* Reviews

* Notifications


## Rationale


* Decouples systems

* Improves scalability

* Enables real-time UI updates


---


# ADR-005 — Queueable Apex for AI Processing


## Status


Accepted


## Decision


Use Queueable Apex for Agentforce responses.


## Rationale


* AI calls are asynchronous by nature

* Prevents blocking user transactions

* Allows retry mechanisms


---


# ADR-006 — Selector Layer for SOQL Abstraction


## Status


Accepted


## Decision


All SOQL must be inside Selector classes.


## Rationale


* Prevents duplicate queries

* Improves maintainability

* Enables query optimization centrally


---


# ADR-007 — No Direct External API Calls from Agentforce


## Status


Accepted


## Decision


Agentforce cannot directly call external APIs.


## Rationale


* Security risk reduction

* Better control via Apex layer

* Easier monitoring and logging


---


# ADR-008 — Centralized Logging Strategy


## Status


Accepted


## Decision


Use:


* `Application_Log__c`

* `Integration_Transaction__c`

* `AI_Conversation__c`


## Rationale


* Unified observability

* Easier debugging

* Audit compliance


---


# ADR-009 — REST API Versioning Strategy


## Status


Accepted


## Decision


All APIs must use:


```text id="v1"

api/v1/

```

