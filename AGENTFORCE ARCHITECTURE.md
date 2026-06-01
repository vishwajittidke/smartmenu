\# Agentforce Architecture



\# SmartMenu



\## AI-Powered Restaurant Operations Platform



\*\*Version:\*\* 1.0

\*\*Status:\*\* Draft

\*\*Owner:\*\* AI Architect

\*\*Platform:\*\* Salesforce Agentforce, Apex, Platform Data Layer



\---



\# 1. Purpose



This document defines the architecture, behavior, constraints, and operational model of the SmartMenu AI Assistant built using Agentforce.



It ensures:



\* Controlled AI behavior

\* Grounded responses from Salesforce data

\* Safe execution boundaries

\* Auditability of AI decisions

\* Predictable escalation paths



\---



\# 2. Agent Overview



\## Agent Name



SmartMenu Assistant



\---



\## Primary Role



To assist:



\* Customers (orders, tracking, recommendations)

\* Restaurant Owners (insights, menu performance)

\* Support Agents (case summarization)



\---



\## Core Principle



> The agent does not “guess”. It retrieves, reasons, and responds only from governed Salesforce data.



\---



\# 3. Agent Architecture



\## High-Level Flow



```text id="ag1"

User Input

&#x20;  ↓

Intent Classification

&#x20;  ↓

Tool Selection (Salesforce Data / Apex Actions)

&#x20;  ↓

Grounded Retrieval (SOQL / APIs)

&#x20;  ↓

Response Generation

&#x20;  ↓

Guardrail Validation

&#x20;  ↓

User Response

```



\---



\# 4. Agent Capabilities



\## 4.1 Customer Capabilities



\* Track orders

\* View menu recommendations

\* Check order status

\* Submit queries

\* Understand restaurant details



\---



\## 4.2 Restaurant Owner Capabilities



\* View revenue summaries

\* Analyze top-selling items

\* Track order trends

\* View customer ratings



\---



\## 4.3 Support Agent Capabilities



\* Summarize customer complaints

\* Retrieve order history

\* Suggest resolution steps



\---



\# 5. Data Grounding Strategy



\## Allowed Data Sources



\* Account (Restaurant)

\* Contact (Customer)

\* Order\_\_c

\* Order\_Item\_\_c

\* Menu\_Item\_\_c

\* Review\_\_c

\* Case



\---



\## Restricted Data Sources



\* Application\_Log\_\_c

\* Integration\_Transaction\_\_c

\* Raw revenue calculations (unaggregated)

\* Security configuration objects



\---



\## Grounding Rule



> Every response must be traceable to Salesforce data.



If no data exists → agent must say:



> “I don’t have enough information to answer that.”



\---



\# 6. Tooling Strategy



\## 6.1 Apex Actions



Agent can invoke:



\* OrderService.getOrderStatus()

\* MenuService.getRecommendations()

\* ReviewService.generateSummary()

\* RevenueService.getInsights()



\---



\## 6.2 SOQL Retrieval Layer



All queries must go through Selector Layer:



\* OrderSelector

\* MenuSelector

\* CustomerSelector



\---



\## 6.3 Platform Events (Indirect Use)



Agent consumes:



\* Order\_Placed\_\_e

\* Order\_Status\_Changed\_\_e

\* Review\_Submitted\_\_e



\---



\# 7. Prompt Engineering Strategy



\## Prompt Structure



```text id="p1"

Context:

\- User Role

\- Restaurant Data

\- Order Data



Task:

\- User Request



Constraints:

\- Use only Salesforce data

\- Do not hallucinate

\- Escalate if uncertain

```



\---



\## Example Prompt



```text id="p2"

You are SmartMenu Assistant.



A customer asked:

"Where is my order?"



Use Order\_\_c data to retrieve status and respond.



If order not found → say you cannot locate it.

```



\---



\# 8. Guardrails \& Safety



\## Hard Constraints



Agent MUST NOT:



\* Access integration logs

\* Access revenue breakdowns (raw)

\* Modify records directly

\* Generate unsupported assumptions



\---



\## Soft Constraints



Agent SHOULD:



\* Be concise

\* Prefer structured responses

\* Ask clarifying questions when needed



\---



\# 9. Escalation Strategy



\## When to escalate



\* Missing order data

\* Payment disputes (future)

\* Customer complaints requiring human review

\* Security-related queries



\---



\## Escalation Flow



```text id="e1"

Agent Cannot Resolve

&#x20;      ↓

Create Case

&#x20;      ↓

Assign to Support Queue

```



\---



\# 10. Response Types



\## 10.1 Informational Response



\* Order status

\* Menu details



\---



\## 10.2 Analytical Response



\* Revenue trends

\* Top items



\---



\## 10.3 Actionable Response



\* Create Case

\* Suggest menu items



\---



\# 11. Memory Strategy



\## Short-Term Context



\* Current session only



\---



\## Long-Term Storage



Stored in:



\* AI\_Conversation\_\_c



Fields:



\* Prompt

\* Response

\* Confidence Score

\* Escalation Flag



\---



\# 12. Confidence Scoring



Each response includes internal confidence:



| Score   | Meaning                         |

| ------- | ------------------------------- |

| 0.9–1.0 | High confidence                 |

| 0.6–0.8 | Medium confidence               |

| <0.6    | Must escalate or avoid response |



\---



\# 13. Failure Handling



\## Scenarios



\### No Data Found



Response:



> “I couldn’t find matching records.”



\---



\### System Failure



Log to:



\* Application\_Log\_\_c



\---



\### External Dependency Failure



Retry via async Queueable



\---



\# 14. Performance Considerations



\* Minimize SOQL calls per interaction

\* Cache frequent queries (future)

\* Use indexed fields for Order lookup

\* Avoid deep nested queries



\---



\# 15. Auditability



Every interaction must be traceable:



\* User Input

\* Data Retrieved

\* Response Generated

\* Escalation Decision



Stored in:



\* AI\_Conversation\_\_c



\---



\# 16. Ethical Constraints



Agent must:



\* Avoid fabricated responses

\* Avoid financial manipulation advice

\* Avoid unauthorized data exposure



\---



\# 17. Design Principles



\* Grounded AI only

\* No hallucination tolerance

\* Explainable outputs

\* Safe failure by design

\* Human escalation always available



\---



\# End of Document



