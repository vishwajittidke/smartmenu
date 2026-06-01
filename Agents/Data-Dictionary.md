# Data Dictionary


# SmartMenu


## AI-Powered Restaurant Operations Platform


**Document Version:** 1.0

**Status:** Draft

**Owner:** Data Architect

**Last Updated:** June 2026


---


# 1. Document Purpose


This document defines the logical data model for SmartMenu.


Objectives:


* Establish a single source of truth for data definitions

* Standardize field usage

* Support security design

* Support Apex development

* Support integrations

* Support reporting and analytics

* Support Agentforce grounding


---


# 2. Data Governance Standards


## Naming Convention


### Custom Objects


```text

ObjectName__c

```


Example:


```text

Restaurant__c

Menu_Item__c

Order__c

```


---


### Custom Fields


```text

Field_Name__c

```


Example:


```text

Restaurant_Code__c

Revenue__c

```


---


## Required Audit Fields


All objects must support:


* Created By

* Created Date

* Last Modified By

* Last Modified Date

* Owner


---


# 3. Data Classification


| Classification | Description                           |

| -------------- | ------------------------------------- |

| Public         | Non-sensitive business information    |

| Internal       | Internal operational data             |

| Confidential   | Customer data                         |

| Restricted     | Financial and business-sensitive data |


---


# 4. Core Entity Relationship Model


```text

Restaurant__c

   |

   | Master-Detail

   |

Menu_Item__c


Restaurant__c

   |

   | Lookup

   |

Order__c

   |

   | Lookup

   |

Customer__c


Order__c

   |

   | Lookup

   |

Order_Item__c

   |

   | Lookup

   |

Menu_Item__c


Restaurant__c

   |

   | Lookup

   |

Review__c

   |

   | Lookup

   |

Customer__c

```


---


# 5. Restaurant__c


## Description


Stores restaurant information.


---


## Ownership


Platform Administrator


---


## Record Volume Estimate


1,000+


---


## Fields


### Name


| Property       | Value  |

| -------------- | ------ |

| Type           | Text   |

| Required       | Yes    |

| Unique         | No     |

| Classification | Public |


---


### Restaurant_Code__c


| Property       | Value    |

| -------------- | -------- |

| Type           | Text(20) |

| Required       | Yes      |

| Unique         | Yes      |

| External ID    | Yes      |

| Classification | Internal |


Example:


```text

REST-00001

```


---


### Status__c


| Property       | Value                       |

| -------------- | --------------------------- |

| Type           | Picklist                    |

| Values         | Active, Inactive, Suspended |

| Required       | Yes                         |

| Classification | Internal                    |


---


### Cuisine_Type__c


| Property       | Value    |

| -------------- | -------- |

| Type           | Picklist |

| Classification | Public   |


Values:

