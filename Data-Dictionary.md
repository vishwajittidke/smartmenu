\# Data Dictionary



\# SmartMenu



\## AI-Powered Restaurant Operations Platform



\*\*Document Version:\*\* 1.0

\*\*Status:\*\* Draft

\*\*Owner:\*\* Data Architect

\*\*Last Updated:\*\* June 2026



\---



\# 1. Document Purpose



This document defines the logical data model for SmartMenu.



Objectives:



\* Establish a single source of truth for data definitions

\* Standardize field usage

\* Support security design

\* Support Apex development

\* Support integrations

\* Support reporting and analytics

\* Support Agentforce grounding



\---



\# 2. Data Governance Standards



\## Naming Convention



\### Custom Objects



```text

ObjectName\_\_c

```



Example:



```text

Restaurant\_\_c

Menu\_Item\_\_c

Order\_\_c

```



\---



\### Custom Fields



```text

Field\_Name\_\_c

```



Example:



```text

Restaurant\_Code\_\_c

Revenue\_\_c

```



\---



\## Required Audit Fields



All objects must support:



\* Created By

\* Created Date

\* Last Modified By

\* Last Modified Date

\* Owner



\---



\# 3. Data Classification



| Classification | Description                           |

| -------------- | ------------------------------------- |

| Public         | Non-sensitive business information    |

| Internal       | Internal operational data             |

| Confidential   | Customer data                         |

| Restricted     | Financial and business-sensitive data |



\---



\# 4. Core Entity Relationship Model



```text

Restaurant\_\_c

&#x20;   |

&#x20;   | Master-Detail

&#x20;   |

Menu\_Item\_\_c



Restaurant\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Order\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Customer\_\_c



Order\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Order\_Item\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Menu\_Item\_\_c



Restaurant\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Review\_\_c

&#x20;   |

&#x20;   | Lookup

&#x20;   |

Customer\_\_c

```



\---



\# 5. Restaurant\_\_c



\## Description



Stores restaurant information.



\---



\## Ownership



Platform Administrator



\---



\## Record Volume Estimate



1,000+



\---



\## Fields



\### Name



| Property       | Value  |

| -------------- | ------ |

| Type           | Text   |

| Required       | Yes    |

| Unique         | No     |

| Classification | Public |



\---



\### Restaurant\_Code\_\_c



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



\---



\### Status\_\_c



| Property       | Value                       |

| -------------- | --------------------------- |

| Type           | Picklist                    |

| Values         | Active, Inactive, Suspended |

| Required       | Yes                         |

| Classification | Internal                    |



\---



\### Cuisine\_Type\_\_c



| Property       | Value    |

| -------------- | -------- |

| Type           | Picklist |

| Classification | Public   |



Values:



\* Indian

\* Chinese

\* Italian

\* Mexican

\* Multi-Cuisine



\---



\### Opening\_Time\_\_c



| Property | Value |

| -------- | ----- |

| Type     | Time  |

| Required | Yes   |



\---



\### Closing\_Time\_\_c



| Property | Value |

| -------- | ----- |

| Type     | Time  |

| Required | Yes   |



\---



\### Average\_Rating\_\_c



| Property       | Value       |

| -------------- | ----------- |

| Type           | Number(3,2) |

| Formula        | Yes         |

| Classification | Public      |



\---



\### Revenue\_\_c



| Property       | Value      |

| -------------- | ---------- |

| Type           | Currency   |

| Classification | Restricted |



\---



\### Address\_\_c



| Property       | Value          |

| -------------- | -------------- |

| Type           | Long Text Area |

| Classification | Internal       |



\---



\### Email\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Email        |

| Classification | Confidential |



\---



\### Phone\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Phone        |

| Classification | Confidential |



\---



\# 6. Menu\_Item\_\_c



\## Description



Stores restaurant menu items.



\---



\## Parent



Restaurant\_\_c



Relationship:



Master-Detail



\---



\## Fields



\### Name



| Property | Value |

| -------- | ----- |

| Type     | Text  |

| Required | Yes   |



\---



\### Menu\_Code\_\_c



| Property    | Value    |

| ----------- | -------- |

| Type        | Text(20) |

| Unique      | Yes      |

| External ID | Yes      |



\---



\### Category\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Picklist |



Values:



\* Veg

\* Non-Veg

\* Beverage

\* Dessert



\---



\### Price\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Currency |

| Required | Yes      |



\---



\### Calories\_\_c



| Property | Value       |

| -------- | ----------- |

| Type     | Number(6,2) |



\---



\### Ingredients\_\_c



| Property | Value          |

| -------- | -------------- |

| Type     | Long Text Area |



\---



\### AI\_Description\_\_c



| Property | Value          |

| -------- | -------------- |

| Type     | Long Text Area |



Generated by Prompt Builder.



\---



\### Is\_Available\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Checkbox |

| Default  | True     |



\---



\# 7. Customer\_\_c



\## Description



Stores customer profile information.



\---



\## Record Volume Estimate



100,000+



\---



\## Fields



\### Customer\_Code\_\_c



| Property    | Value    |

| ----------- | -------- |

| Type        | Text(20) |

| Unique      | Yes      |

| External ID | Yes      |



\---



\### First\_Name\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Text(80)     |

| Classification | Confidential |



\---



\### Last\_Name\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Text(80)     |

| Classification | Confidential |



\---



\### Email\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Email        |

| Required       | Yes          |

| Classification | Confidential |



\---



\### Phone\_\_c



| Property       | Value        |

| -------------- | ------------ |

| Type           | Phone        |

| Classification | Confidential |



\---



\### Address\_\_c



| Property       | Value          |

| -------------- | -------------- |

| Type           | Long Text Area |

| Classification | Confidential   |



\---



\### Lifetime\_Value\_\_c



| Property       | Value      |

| -------------- | ---------- |

| Type           | Currency   |

| Classification | Restricted |



\---



\### Last\_Order\_Date\_\_c



| Property | Value |

| -------- | ----- |

| Type     | Date  |



\---



\# 8. Order\_\_c



\## Description



Stores customer orders.



\---



\## Record Volume Estimate



1,000,000+



\---



\## Relationships



Lookup → Restaurant\_\_c



Lookup → Customer\_\_c



\---



\## Fields



\### Order\_Number\_\_c



| Property | Value        |

| -------- | ------------ |

| Type     | Auto Number  |

| Format   | ORD-{000000} |

| Unique   | Yes          |



\---



\### Status\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Picklist |



Values:



\* Placed

\* Accepted

\* Preparing

\* Ready

\* Delivered

\* Cancelled



\---



\### Ordered\_On\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | DateTime |

| Required | Yes      |



\---



\### Total\_\_c



| Property       | Value      |

| -------------- | ---------- |

| Type           | Currency   |

| Classification | Restricted |



Calculated by Apex.



\---



\### Estimated\_Delivery\_Time\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | DateTime |



\---



\### Is\_Late\_\_c



| Property | Value            |

| -------- | ---------------- |

| Type     | Formula Checkbox |



\---



\### Notes\_\_c



| Property | Value          |

| -------- | -------------- |

| Type     | Long Text Area |



\---



\# 9. Order\_Item\_\_c



\## Description



Junction object between Order and Menu Item.



\---



\## Fields



\### Quantity\_\_c



| Property | Value        |

| -------- | ------------ |

| Type     | Number(10,0) |

| Required | Yes          |



\---



\### Unit\_Price\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Currency |



\---



\### Line\_Total\_\_c



| Property | Value            |

| -------- | ---------------- |

| Type     | Formula Currency |



Formula:



```text

Quantity \* Unit Price

```



\---



\# 10. Review\_\_c



\## Description



Stores customer reviews.



\---



\## Fields



\### Rating\_\_c



| Property | Value       |

| -------- | ----------- |

| Type     | Number(1,0) |

| Min      | 1           |

| Max      | 5           |



\---



\### Comment\_\_c



| Property | Value          |

| -------- | -------------- |

| Type     | Long Text Area |



\---



\### AI\_Response\_\_c



| Property | Value          |

| -------- | -------------- |

| Type     | Long Text Area |



Generated by Agentforce.



\---



\### Review\_Status\_\_c



| Property | Value    |

| -------- | -------- |

| Type     | Picklist |



Values:



\* Pending

\* Published

\* Rejected



\---



\# 11. Case



\## Description



Stores customer complaints.



\---



\## Fields



\### Complaint\_Type\_\_c



Values:



\* Wrong Order

\* Missing Item

\* Late Delivery

\* Quality Issue

\* Other



\---



\### Resolution\_Status\_\_c



Values:



\* New

\* Assigned

\* Investigating

\* Resolved

\* Closed



\---



\# 12. Platform Event Objects



\---



\## Order\_Placed\_Event\_\_e



Purpose:



Trigger downstream automation.



Fields:



\* Order Id

\* Restaurant Id

\* Timestamp



\---



\## Order\_Delivered\_Event\_\_e



Purpose:



Analytics and notifications.



Fields:



\* Order Id

\* Delivery Timestamp



\---



\## Review\_Submitted\_Event\_\_e



Purpose:



AI response generation.



Fields:



\* Review Id

\* Customer Id



\---



\# 13. Custom Metadata Types



\## Restaurant\_Config\_\_mdt



Stores:



\* SLA Thresholds

\* Notification Settings

\* Escalation Rules



\---



\## Notification\_Config\_\_mdt



Stores:



\* Email Templates

\* Alert Settings



\---



\# 14. Data Retention Policy



| Object     | Retention |

| ---------- | --------- |

| Restaurant | Permanent |

| Menu Item  | Permanent |

| Customer   | 7 Years   |

| Orders     | 7 Years   |

| Reviews    | Permanent |

| Cases      | 5 Years   |

| Logs       | 90 Days   |



\---



\# 15. Archiving Strategy



Orders older than 24 months:



\* Archived via Batch Apex

\* Removed from operational reporting

\* Retained for compliance



\---



\# 16. Data Quality Rules



\* Restaurant Code must be unique.

\* Menu Code must be unique.

\* Customer Email must be valid.

\* Review Rating must be between 1 and 5.

\* Order Total cannot be negative.

\* Restaurant Closing Time must be after Opening Time.



\---



\# 17. Future Data Model Extensions



\* Loyalty Program

\* Inventory Management

\* Delivery Tracking

\* Multi-Location Restaurant Hierarchy

\* Subscription Plans



\---



\# End of Document



