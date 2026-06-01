\# Architecture Decision Records (ADR)



\# SmartMenu



\## AI-Powered Restaurant Operations Platform



\*\*Version:\*\* 1.0

\*\*Status:\*\* Living Document

\*\*Owner:\*\* Solution Architect

\*\*Purpose:\*\* Record architectural decisions and rationale



\---



\# ADR-001 — Use Salesforce Standard Objects (Account/Contact) vs Custom Objects



\## Status



Accepted



\## Decision



Use:



\* `Account` → Restaurant (Record Type)

\* `Contact` → Customer



Instead of:



\* `Restaurant\_\_c`

\* `Customer\_\_c`



\## Rationale



\* Native CRM integration

\* Better scalability

\* Built-in reporting \& activities

\* Easier Service Cloud + Agentforce integration



\## Trade-offs



\* Slight loss of domain purity

\* Requires record type discipline



\---



\# ADR-002 — Order Status History as Separate Object



\## Status



Accepted



\## Decision



Create:



\* `Order\_Status\_History\_\_c`



\## Rationale



\* Salesforce field history tracking is insufficient for analytics

\* Needed for audit trails + AI context

\* Enables time-series analysis



\---



\# ADR-003 — Layered Apex Architecture (Trigger → Handler → Service → Domain → Selector)



\## Status



Accepted



\## Decision



Enforce strict layering model.



\## Rationale



\* Prevents logic sprawl in triggers

\* Improves testability

\* Enables reuse of business logic



\## Alternatives Considered



\* Fat controller pattern (rejected)

\* Trigger-only logic (rejected)



\---



\# ADR-004 — Platform Events for Async Communication



\## Status



Accepted



\## Decision



Use Platform Events for:



\* Order updates

\* Reviews

\* Notifications



\## Rationale



\* Decouples systems

\* Improves scalability

\* Enables real-time UI updates



\---



\# ADR-005 — Queueable Apex for AI Processing



\## Status



Accepted



\## Decision



Use Queueable Apex for Agentforce responses.



\## Rationale



\* AI calls are asynchronous by nature

\* Prevents blocking user transactions

\* Allows retry mechanisms



\---



\# ADR-006 — Selector Layer for SOQL Abstraction



\## Status



Accepted



\## Decision



All SOQL must be inside Selector classes.



\## Rationale



\* Prevents duplicate queries

\* Improves maintainability

\* Enables query optimization centrally



\---



\# ADR-007 — No Direct External API Calls from Agentforce



\## Status



Accepted



\## Decision



Agentforce cannot directly call external APIs.



\## Rationale



\* Security risk reduction

\* Better control via Apex layer

\* Easier monitoring and logging



\---



\# ADR-008 — Centralized Logging Strategy



\## Status



Accepted



\## Decision



Use:



\* `Application\_Log\_\_c`

\* `Integration\_Transaction\_\_c`

\* `AI\_Conversation\_\_c`



\## Rationale



\* Unified observability

\* Easier debugging

\* Audit compliance



\---



\# ADR-009 — REST API Versioning Strategy



\## Status



Accepted



\## Decision



All APIs must use:



```text id="v1"

api/v1/

```



\## Rationale



\* Future-proofing

\* Backward compatibility

\* Safe evolution



\---



\# ADR-010 — Restriction Rules Instead of Complex Sharing Logic



\## Status



Accepted



\## Decision



Use Restriction Rules for fine-grained access control.



\## Rationale



\* Cleaner than Apex sharing logic

\* Declarative security preferred

\* Easier maintenance



\---



\# ADR-011 — Revenue Aggregation via Batch Apex



\## Status



Accepted



\## Decision



Use:



\* `Restaurant\_Revenue\_Summary\_\_c`

&#x20; updated via Batch Apex



\## Rationale



\* Avoids real-time aggregation overhead

\* Supports large data volume



\---



\# ADR-012 — AI Grounding Requirement (No Hallucination Policy)



\## Status



Accepted



\## Decision



Agentforce must only respond using Salesforce data.



\## Rationale



\* Prevents misinformation

\* Ensures auditability

\* Improves trust in AI system



\---



\# ADR-013 — Event-Driven UI Updates via Platform Events + LMS



\## Status



Accepted



\## Decision



Use:



\* Platform Events

\* Lightning Message Service (LMS)



\## Rationale



\* Real-time UI updates

\* Decoupled architecture



\---



\# ADR-014 — Idempotency Key for API Order Creation



\## Status



Accepted



\## Decision



All order creation APIs must support idempotency keys.



\## Rationale



\* Prevents duplicate orders

\* Ensures API reliability



\---



\# ADR-015 — Separate Analytics Summary Tables



\## Status



Accepted



\## Decision



Use:



\* `Restaurant\_Revenue\_Summary\_\_c`



Instead of real-time aggregation queries.



\## Rationale



\* Performance optimization

\* Supports large-scale reporting



\---



\# ADR-016 — CI/CD Enforcement via GitHub Actions



\## Status



Accepted



\## Decision



All deployments must pass:



\* Unit tests

\* LWC tests

\* Security checks



\## Rationale



\* Prevents manual deployment errors

\* Ensures consistent releases



\---



\# ADR-017 — Agentforce Must Escalate Uncertain Cases



\## Status



Accepted



\## Decision



AI must create Case when confidence < threshold.



\## Rationale



\* Prevents incorrect answers

\* Ensures human fallback



\---



\# ADR-018 — No SOQL in LWC



\## Status



Accepted



\## Decision



All data access must go through Apex.



\## Rationale



\* Security enforcement

\* Centralized logic control



\---



\# End of Document



