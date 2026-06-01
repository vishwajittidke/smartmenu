# Security Architecture


# SmartMenu


Version: 1.0


Status: Draft


Owner: Security Architect


---


# Security Principles


The platform follows:


* Least Privilege

* Zero Trust

* Need-To-Know Access

* Separation of Duties

* Auditability


---


# User Types


## Platform Administrator


Full Access


Responsibilities:


* Configuration

* Security

* Deployment


---


## Restaurant Owner


Access:


Own Restaurant Only


Capabilities:


* Manage Menu

* Manage Orders

* View Revenue


---


## Restaurant Manager


Access:


Assigned Restaurant


Capabilities:


* Process Orders

* Manage Reviews


---


## Customer Support Agent


Access:


Cases

Reviews


Capabilities:


* Resolve Complaints


---


## Customer


Access:


Own Orders

Own Reviews


Capabilities:


* Track Orders

* Submit Reviews


---


# Organization-Wide Defaults


| Object             | OWD                  |

| ------------------ | -------------------- |

| Account            | Private              |

| Contact            | Private              |

| Order__c           | Private              |

| Order_Item__c      | Controlled by Parent |

| Review__c          | Private              |

| Case               | Private              |

| AI_Conversation__c | Private              |

| Application_Log__c | Private              |

| Notification__c    | Private              |


---


# Role Hierarchy


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


---


# Permission Sets


Restaurant_Manager_PS

Customer_Support_PS

Restaurant_Analytics_PS

API_User_PS

Agentforce_User_PS


---


# Permission Set Groups


Restaurant_Owner_PSG

Support_Agent_PSG

Operations_PSG


---


# Restriction Rules


Restaurant users may only access:


* Their Restaurant

* Their Orders

* Their Reviews


Customers may only access:


* Their Orders

* Their Reviews

* Their Cases


---


# Field Level Security


Restricted Fields


* Revenue

* Lifetime Value

* AI Confidence Score

* Internal Logs


Visible Only To:


* Admin

* Restaurant Owner

* Analytics Users


---


# API Security


Requirements


* OAuth 2.0

* Connected Apps

* Named Credentials

* TLS 1.2+

