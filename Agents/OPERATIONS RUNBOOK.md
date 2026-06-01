# Operations Runbook


# SmartMenu


## AI-Powered Restaurant Operations Platform


**Version:** 1.0

**Status:** Draft

**Owner:** Platform Operations Team

**Platform:** Salesforce Production Environment


---


# 1. Purpose


This document defines operational procedures for running SmartMenu in production.


It ensures:


* Incident handling

* System monitoring

* Failure recovery

* Data integrity maintenance

* User support workflows


---


# 2. Operational Principles


* System stability first

* Minimal downtime tolerance

* Fast incident resolution

* Transparent escalation paths

* Data consistency preservation


---


# 3. System Monitoring Overview


## Monitored Components


* Apex services

* LWC UI performance

* REST APIs

* Platform Events

* Batch jobs

* Agentforce interactions


---


## Monitoring Tools


* Salesforce Setup Monitoring

* Debug Logs

* Event Monitoring (future)

* Custom logging objects


---


# 4. Key Logs & Data Sources


## Application Logs


Stored in:


```text id="l1"

Application_Log__c

```


Tracks:


* Errors

* Warnings

* System events


---


## Integration Logs


Stored in:


```text id="l2"

Integration_Transaction__c

```


Tracks:


* API requests

* API responses

* Failures

* Retry attempts


---


## AI Logs


Stored in:


```text id="l3"

AI_Conversation__c

```


Tracks:


* User prompts

* Agent responses

* Escalations

* Confidence scores


---


# 5. Incident Severity Levels


| Level | Description          | Response Time |

| ----- | -------------------- | ------------- |

| P1    | System down          | Immediate     |

| P2    | Major feature broken | 1 hour        |

| P3    | Minor issue          | 24 hours      |

| P4    | Cosmetic issue       | Next release  |


---


# 6. Incident Response Process


## Step Flow


```text id="i1"

Detect Issue

   ↓

Classify Severity

   ↓

Assign Owner

   ↓

Investigate Logs

   ↓

Apply Fix

   ↓

Validate System

   ↓

Close Incident

```


---


# 7. Common Incident Scenarios


---


## 7.1 Order Creation Failure


### Symptoms


* Orders not appearing

* API errors on order submission


### Investigation


* Check Order__c insert failures

* Check Application_Log__c

* Check validation rules


---


### Resolution


* Fix validation rule / Apex error

* Retry failed transactions


---


## 7.2 Agentforce Not Responding


### Symptoms


* No AI response

* Timeout errors


### Investigation


* Check AI_Conversation__c

* Check Queueable Apex failures


---


### Resolution


* Retry Queueable job

* Validate prompt grounding data


---


## 7.3 API Failure


### Symptoms


* External app cannot create orders


### Investigation


* Check Integration_Transaction__c

