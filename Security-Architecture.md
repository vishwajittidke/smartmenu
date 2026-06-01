\# Security Architecture



\# SmartMenu



Version: 1.0



Status: Draft



Owner: Security Architect



\---



\# Security Principles



The platform follows:



\* Least Privilege

\* Zero Trust

\* Need-To-Know Access

\* Separation of Duties

\* Auditability



\---



\# User Types



\## Platform Administrator



Full Access



Responsibilities:



\* Configuration

\* Security

\* Deployment



\---



\## Restaurant Owner



Access:



Own Restaurant Only



Capabilities:



\* Manage Menu

\* Manage Orders

\* View Revenue



\---



\## Restaurant Manager



Access:



Assigned Restaurant



Capabilities:



\* Process Orders

\* Manage Reviews



\---



\## Customer Support Agent



Access:



Cases

Reviews



Capabilities:



\* Resolve Complaints



\---



\## Customer



Access:



Own Orders

Own Reviews



Capabilities:



\* Track Orders

\* Submit Reviews



\---



\# Organization-Wide Defaults



| Object             | OWD                  |

| ------------------ | -------------------- |

| Account            | Private              |

| Contact            | Private              |

| Order\_\_c           | Private              |

| Order\_Item\_\_c      | Controlled by Parent |

| Review\_\_c          | Private              |

| Case               | Private              |

| AI\_Conversation\_\_c | Private              |

| Application\_Log\_\_c | Private              |

| Notification\_\_c    | Private              |



\---



\# Role Hierarchy



CEO



↓



Platform Admin



↓



Restaurant Owner



↓



Restaurant Manager



↓



Support Agent



↓



Customer



\---



\# Permission Sets



Restaurant\_Manager\_PS



Customer\_Support\_PS



Restaurant\_Analytics\_PS



API\_User\_PS



Agentforce\_User\_PS



\---



\# Permission Set Groups



Restaurant\_Owner\_PSG



Support\_Agent\_PSG



Operations\_PSG



\---



\# Restriction Rules



Restaurant users may only access:



\* Their Restaurant

\* Their Orders

\* Their Reviews



Customers may only access:



\* Their Orders

\* Their Reviews

\* Their Cases



\---



\# Field Level Security



Restricted Fields



\* Revenue

\* Lifetime Value

\* AI Confidence Score

\* Internal Logs



Visible Only To:



\* Admin

\* Restaurant Owner

\* Analytics Users



\---



\# API Security



Requirements



\* OAuth 2.0

\* Connected Apps

\* Named Credentials

\* TLS 1.2+



\---



\# Apex Security Standards



Mandatory:



\* with sharing

\* WITH SECURITY\_ENFORCED

\* Security.stripInaccessible()



Prohibited:



\* Hardcoded User IDs

\* Unsecured SOQL Queries



\---



\# Agentforce Security



Agent Access Limited To:



\* Restaurant Data

\* Menu Data

\* Order Data



Agent Cannot Access:



\* Revenue

\* Internal Logs

\* Security Settings



Escalation Required For:



\* Complaints

\* Refund Requests

\* Security Questions



\---



\# Monitoring



Track:



\* Login Failures

\* API Failures

\* Permission Errors

\* Agent Escalations



\---



\# Security Review Checklist



Before Production:



\* CRUD Verified

\* FLS Verified

\* Sharing Verified

\* Restriction Rules Verified

\* API Security Verified

\* Agent Security Verified



End Of Document



