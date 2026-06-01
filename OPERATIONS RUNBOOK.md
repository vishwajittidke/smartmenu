\# Operations Runbook



\# SmartMenu



\## AI-Powered Restaurant Operations Platform



\*\*Version:\*\* 1.0

\*\*Status:\*\* Draft

\*\*Owner:\*\* Platform Operations Team

\*\*Platform:\*\* Salesforce Production Environment



\---



\# 1. Purpose



This document defines operational procedures for running SmartMenu in production.



It ensures:



\* Incident handling

\* System monitoring

\* Failure recovery

\* Data integrity maintenance

\* User support workflows



\---



\# 2. Operational Principles



\* System stability first

\* Minimal downtime tolerance

\* Fast incident resolution

\* Transparent escalation paths

\* Data consistency preservation



\---



\# 3. System Monitoring Overview



\## Monitored Components



\* Apex services

\* LWC UI performance

\* REST APIs

\* Platform Events

\* Batch jobs

\* Agentforce interactions



\---



\## Monitoring Tools



\* Salesforce Setup Monitoring

\* Debug Logs

\* Event Monitoring (future)

\* Custom logging objects



\---



\# 4. Key Logs \& Data Sources



\## Application Logs



Stored in:



```text id="l1"

Application\_Log\_\_c

```



Tracks:



\* Errors

\* Warnings

\* System events



\---



\## Integration Logs



Stored in:



```text id="l2"

Integration\_Transaction\_\_c

```



Tracks:



\* API requests

\* API responses

\* Failures

\* Retry attempts



\---



\## AI Logs



Stored in:



```text id="l3"

AI\_Conversation\_\_c

```



Tracks:



\* User prompts

\* Agent responses

\* Escalations

\* Confidence scores



\---



\# 5. Incident Severity Levels



| Level | Description          | Response Time |

| ----- | -------------------- | ------------- |

| P1    | System down          | Immediate     |

| P2    | Major feature broken | 1 hour        |

| P3    | Minor issue          | 24 hours      |

| P4    | Cosmetic issue       | Next release  |



\---



\# 6. Incident Response Process



\## Step Flow



```text id="i1"

Detect Issue

&#x20;   ↓

Classify Severity

&#x20;   ↓

Assign Owner

&#x20;   ↓

Investigate Logs

&#x20;   ↓

Apply Fix

&#x20;   ↓

Validate System

&#x20;   ↓

Close Incident

```



\---



\# 7. Common Incident Scenarios



\---



\## 7.1 Order Creation Failure



\### Symptoms



\* Orders not appearing

\* API errors on order submission



\### Investigation



\* Check Order\_\_c insert failures

\* Check Application\_Log\_\_c

\* Check validation rules



\---



\### Resolution



\* Fix validation rule / Apex error

\* Retry failed transactions



\---



\## 7.2 Agentforce Not Responding



\### Symptoms



\* No AI response

\* Timeout errors



\### Investigation



\* Check AI\_Conversation\_\_c

\* Check Queueable Apex failures



\---



\### Resolution



\* Retry Queueable job

\* Validate prompt grounding data



\---



\## 7.3 API Failure



\### Symptoms



\* External app cannot create orders



\### Investigation



\* Check Integration\_Transaction\_\_c

\* Check OAuth tokens



\---



\### Resolution



\* Refresh authentication

\* Retry failed requests



\---



\## 7.4 LWC Dashboard Not Updating



\### Symptoms



\* Stale order data



\### Investigation



\* Check Platform Events

\* Check LMS subscriptions



\---



\### Resolution



\* Restart event listener

\* Verify event publishing



\---



\# 8. Data Recovery Procedures



\---



\## 8.1 Failed Order Recovery



\### Steps



1\. Identify failed order in logs

2\. Validate partial data

3\. Reprocess via Apex service

4\. Confirm order creation



\---



\## 8.2 Data Corruption Handling



\* Restore from last known valid state

\* Re-run batch jobs if needed

\* Validate consistency



\---



\# 9. Backup Strategy



\## Salesforce Native Backup



\* Weekly export

\* Object-level backups

\* Metadata backups via SFDX



\---



\## Critical Objects



\* Order\_\_c

\* Account (Restaurant)

\* Contact (Customer)



\---



\# 10. System Health Checks



\## Daily Checks



\* API response times

\* Batch job completion

\* Error log count

\* Event processing backlog



\---



\## Weekly Checks



\* Data growth analysis

\* Performance trends

\* Security audit logs



\---



\# 11. Performance Troubleshooting



\## Slow API Response



\### Causes



\* Large SOQL queries

\* Missing indexes

\* Governor limit issues



\---



\### Fixes



\* Optimize queries

\* Add selective filters

\* Move to async processing



\---



\## Slow LWC



\### Causes



\* Excessive re-rendering

\* Large data sets



\---



\### Fixes



\* Pagination

\* Lazy loading

\* caching



\---



\# 12. Security Incident Handling



\## Unauthorized Access Attempt



\### Steps



1\. Check login history

2\. Validate role assignment

3\. Review permission sets

4\. Block user if needed



\---



\## Data Exposure Risk



\* Immediately restrict object access

\* Rotate credentials if API involved

\* Audit FLS violations



\---



\# 13. Agentforce Incident Handling



\## Hallucination Detection



\### Signs



\* Incorrect order details

\* Non-existent menu items



\---



\### Fix



\* Validate grounding data

\* Restrict prompt scope

\* Improve selector queries



\---



\## Escalation Failure



\* Ensure Case creation fallback

\* Re-trigger escalation flow



\---



\# 14. Deployment Issue Handling



\## Failed Deployment



\### Steps



1\. Identify failing component

2\. Review CI/CD logs

3\. Fix metadata issue

4\. Re-run pipeline



\---



\# 15. Escalation Matrix



| Issue Type          | Owner                |

| ------------------- | -------------------- |

| Apex failure        | Backend Engineer     |

| UI issue            | LWC Engineer         |

| Integration failure | Integration Engineer |

| AI issue            | AI Architect         |

| Data issue          | Data Architect       |



\---



\# 16. Operational SLAs



| Component           | SLA      |

| ------------------- | -------- |

| API uptime          | 99.9%    |

| Incident resolution | < 24 hrs |

| Critical fixes      | < 1 hr   |



\---



\# 17. Monitoring Alerts



Triggers:



\* API failure spike

\* Batch job failure

\* High error rate

\* Agentforce escalation spike



\---



\# 18. Maintenance Tasks



\## Daily



\* Log review

\* Error monitoring



\---



\## Weekly



\* Data cleanup

\* Performance review



\---



\## Monthly



\* Security audit

\* Architecture review



\---



\# 19. Operational Design Principles



\* Detect fast

\* Recover faster

\* Prevent recurrence

\* Keep system observable

\* Always maintain audit trail



\---



\# End of Document



