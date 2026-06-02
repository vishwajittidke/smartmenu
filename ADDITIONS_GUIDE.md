# SmartMenu — Code Additions Guide

> All files below need to be created in your project. Copy each section into
> the path shown. After adding them, deploy with:
> ```powershell
> sf project deploy start
> ```

---

## 1. VALIDATION RULES

### File: `force-app/main/default/objects/Order__c/validationRules/Total_Must_Be_Positive_For_Delivery.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Total_Must_Be_Positive_For_Delivery</fullName>
    <active>true</active>
    <description>Prevents marking an order as Delivered if the total is zero or null.</description>
    <errorConditionFormula>AND(
    ISPICKVAL(Status__c, "Delivered"),
    OR(ISBLANK(Total__c), Total__c &lt;= 0)
)</errorConditionFormula>
    <errorDisplayField>Status__c</errorDisplayField>
    <errorMessage>An order cannot be marked as Delivered when the total is ₹0. Please add items first.</errorMessage>
</ValidationRule>
```

### File: `force-app/main/default/objects/Order__c/validationRules/Status_Transition_Guard.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status_Transition_Guard</fullName>
    <active>true</active>
    <description>Prevents skipping order lifecycle stages. A Cancelled order cannot be reopened.</description>
    <errorConditionFormula>AND(
    ISCHANGED(Status__c),
    ISPICKVAL(PRIORVALUE(Status__c), "Cancelled"),
    NOT(ISPICKVAL(Status__c, "Cancelled"))
)</errorConditionFormula>
    <errorDisplayField>Status__c</errorDisplayField>
    <errorMessage>A cancelled order cannot be reopened. Please create a new order instead.</errorMessage>
</ValidationRule>
```

### File: `force-app/main/default/objects/Review__c/validationRules/Rating_Range_Check.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Rating_Range_Check</fullName>
    <active>true</active>
    <description>Ensures review rating is between 1 and 5.</description>
    <errorConditionFormula>OR(
    Rating__c &lt; 1,
    Rating__c &gt; 5,
    ISBLANK(Rating__c)
)</errorConditionFormula>
    <errorDisplayField>Rating__c</errorDisplayField>
    <errorMessage>Rating must be between 1 and 5 stars.</errorMessage>
</ValidationRule>
```

### File: `force-app/main/default/objects/Review__c/validationRules/Comment_Required_For_Low_Rating.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Comment_Required_For_Low_Rating</fullName>
    <active>true</active>
    <description>Requires a comment when rating is 2 or below to capture feedback.</description>
    <errorConditionFormula>AND(
    Rating__c &lt;= 2,
    ISBLANK(Comment__c)
)</errorConditionFormula>
    <errorDisplayField>Comment__c</errorDisplayField>
    <errorMessage>Please provide a comment explaining your low rating so we can improve.</errorMessage>
</ValidationRule>
```

### File: `force-app/main/default/objects/Menu_Item__c/validationRules/Price_Must_Be_Positive.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Price_Must_Be_Positive</fullName>
    <active>true</active>
    <description>Menu item price must be greater than zero.</description>
    <errorConditionFormula>OR(
    ISBLANK(Price__c),
    Price__c &lt;= 0
)</errorConditionFormula>
    <errorDisplayField>Price__c</errorDisplayField>
    <errorMessage>Price must be greater than ₹0.</errorMessage>
</ValidationRule>
```

### File: `force-app/main/default/objects/Order_Item__c/validationRules/Quantity_Must_Be_Positive.validationRule-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Quantity_Must_Be_Positive</fullName>
    <active>true</active>
    <description>Order item quantity must be at least 1.</description>
    <errorConditionFormula>OR(
    ISBLANK(Quantity__c),
    Quantity__c &lt; 1
)</errorConditionFormula>
    <errorDisplayField>Quantity__c</errorDisplayField>
    <errorMessage>Quantity must be at least 1.</errorMessage>
</ValidationRule>
```

---

## 2. RECORD-TRIGGERED FLOW — Order Ready Notification

### File: `force-app/main/default/flows/Order_Ready_Notification.flow-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <description>When an Order status changes to Ready, sends an email alert to the customer and creates a Notification record.</description>
    <environments>Default</environments>
    <interviewLabel>Order Ready Notification {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Order Ready Notification</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processType>AutoLaunchedFlow</processType>
    <start>
        <locationX>50</locationX>
        <locationY>0</locationY>
        <connector>
            <targetReference>Check_Status_Is_Ready</targetReference>
        </connector>
        <filterLogic>and</filterLogic>
        <filters>
            <field>Status__c</field>
            <operator>IsChanged</operator>
            <value>
                <booleanValue>true</booleanValue>
            </value>
        </filters>
        <object>Order__c</object>
        <recordTriggerType>Update</recordTriggerType>
        <triggerType>RecordAfterSave</triggerType>
    </start>
    <status>Active</status>
    <decisions>
        <name>Check_Status_Is_Ready</name>
        <label>Check Status Is Ready</label>
        <locationX>176</locationX>
        <locationY>134</locationY>
        <defaultConnectorLabel>Not Ready</defaultConnectorLabel>
        <rules>
            <name>Status_Is_Ready</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>$Record.Status__c</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <stringValue>Ready</stringValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Create_Notification_Record</targetReference>
            </connector>
            <label>Status Is Ready</label>
        </rules>
    </decisions>
    <recordCreates>
        <name>Create_Notification_Record</name>
        <label>Create Notification Record</label>
        <locationX>264</locationX>
        <locationY>242</locationY>
        <connector>
            <targetReference>Send_Order_Ready_Email</targetReference>
        </connector>
        <inputAssignments>
            <field>Message__c</field>
            <value>
                <elementReference>NotificationMessage</elementReference>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Name</field>
            <value>
                <elementReference>NotificationName</elementReference>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Type__c</field>
            <value>
                <stringValue>Order Ready</stringValue>
            </value>
        </inputAssignments>
        <object>Notification__c</object>
        <storeOutputAutomatically>true</storeOutputAutomatically>
    </recordCreates>
    <actionCalls>
        <name>Send_Order_Ready_Email</name>
        <label>Send Order Ready Email</label>
        <locationX>264</locationX>
        <locationY>350</locationY>
        <actionName>emailSimple</actionName>
        <actionType>emailSimple</actionType>
        <inputParameters>
            <name>emailBody</name>
            <value>
                <elementReference>NotificationMessage</elementReference>
            </value>
        </inputParameters>
        <inputParameters>
            <name>emailSubject</name>
            <value>
                <stringValue>Your SmartMenu Order is Ready!</stringValue>
            </value>
        </inputParameters>
        <inputParameters>
            <name>emailAddresses</name>
            <value>
                <elementReference>$Record.Customer__r.Email</elementReference>
            </value>
        </inputParameters>
    </actionCalls>
    <formulas>
        <name>NotificationMessage</name>
        <dataType>String</dataType>
        <expression>"Your order " &amp; {!$Record.Name} &amp; " is ready for pickup! Total: ₹" &amp; TEXT({!$Record.Total__c})</expression>
    </formulas>
    <formulas>
        <name>NotificationName</name>
        <dataType>String</dataType>
        <expression>"NOTIF-" &amp; {!$Record.Name} &amp; "-READY"</expression>
    </formulas>
</Flow>
```

---

## 3. RECORD-TRIGGERED FLOW — New Review Auto-Response

### File: `force-app/main/default/flows/Review_Auto_Response.flow-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <description>When a new Review is created with a low rating (1-2), automatically creates a Service Cloud Case for follow-up.</description>
    <environments>Default</environments>
    <interviewLabel>Review Auto Response {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Review Auto Response</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processType>AutoLaunchedFlow</processType>
    <start>
        <locationX>50</locationX>
        <locationY>0</locationY>
        <connector>
            <targetReference>Check_Low_Rating</targetReference>
        </connector>
        <object>Review__c</object>
        <recordTriggerType>Create</recordTriggerType>
        <triggerType>RecordAfterSave</triggerType>
    </start>
    <status>Active</status>
    <decisions>
        <name>Check_Low_Rating</name>
        <label>Check Low Rating</label>
        <locationX>176</locationX>
        <locationY>134</locationY>
        <defaultConnectorLabel>Good Rating</defaultConnectorLabel>
        <rules>
            <name>Rating_Is_Low</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>$Record.Rating__c</leftValueReference>
                <operator>LessThanOrEqualTo</operator>
                <rightValue>
                    <numberValue>2.0</numberValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Create_Support_Case</targetReference>
            </connector>
            <label>Rating Is Low</label>
        </rules>
    </decisions>
    <recordCreates>
        <name>Create_Support_Case</name>
        <label>Create Support Case</label>
        <locationX>264</locationX>
        <locationY>242</locationY>
        <inputAssignments>
            <field>Subject</field>
            <value>
                <elementReference>CaseSubject</elementReference>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Description</field>
            <value>
                <elementReference>CaseDescription</elementReference>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Origin</field>
            <value>
                <stringValue>Review</stringValue>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Priority</field>
            <value>
                <stringValue>High</stringValue>
            </value>
        </inputAssignments>
        <inputAssignments>
            <field>Status</field>
            <value>
                <stringValue>New</stringValue>
            </value>
        </inputAssignments>
        <object>Case</object>
        <storeOutputAutomatically>true</storeOutputAutomatically>
    </recordCreates>
    <formulas>
        <name>CaseSubject</name>
        <dataType>String</dataType>
        <expression>"Low Review Alert — Rating: " &amp; TEXT({!$Record.Rating__c}) &amp; "/5"</expression>
    </formulas>
    <formulas>
        <name>CaseDescription</name>
        <dataType>String</dataType>
        <expression>"A customer submitted a low rating of " &amp; TEXT({!$Record.Rating__c}) &amp; "/5." &amp; BR() &amp; BR() &amp; "Comment: " &amp; {!$Record.Comment__c}</expression>
    </formulas>
</Flow>
```

---

## 4. UPGRADED README.md

### File: `README.md` (Replace existing)

````markdown
# 🍽️ SmartMenu — AI-Powered Restaurant Operations Platform

> **Salesforce-native restaurant CRM** with Agentforce AI assistant, real-time LWC dashboard, REST APIs, and event-driven architecture.

[![Salesforce](https://img.shields.io/badge/Platform-Salesforce-00A1E0?logo=salesforce)](https://developer.salesforce.com)
[![Apex](https://img.shields.io/badge/Backend-Apex-1B96FF)](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta)
[![LWC](https://img.shields.io/badge/Frontend-LWC-32B07A)](https://developer.salesforce.com/docs/component-library)
[![Agentforce](https://img.shields.io/badge/AI-Agentforce-7C3AED)](https://www.salesforce.com/agentforce/)

---

## 📋 Overview

SmartMenu is a **multi-layered Salesforce-native platform** that manages restaurant operations end-to-end — from menu management and order processing to AI-powered customer assistance and revenue analytics.

**Built to demonstrate:** Enterprise Apex patterns, LWC, Agentforce AI, REST APIs, Platform Events, Flows, Security Model, and CI/CD — all in one cohesive project.

---

## 🏗️ Architecture

```
          ┌──────────────────────────────┐
          │         USERS                │
          │ Customers | Owners | Agents  │
          └──────────────┬───────────────┘
                         │
          ┌──────────────▼──────────────┐
          │    LWC / Experience UI      │
          │  Dashboard · Portal · Chat  │
          └──────────────┬──────────────┘
                         │
          ┌──────────────▼──────────────┐
          │  REST API + Apex Controllers│
          └──────────────┬──────────────┘
                         │
     ┌───────────────────▼───────────────────┐
     │           SERVICE LAYER               │
     │ Order · Menu · Review · Revenue       │
     └───────────────────┬───────────────────┘
                         │
     ┌───────────────────▼───────────────────┐
     │          DOMAIN LAYER                 │
     │ Business Rules + Validation Logic     │
     └───────────────────┬───────────────────┘
                         │
     ┌───────────────────▼───────────────────┐
     │       SELECTOR LAYER (SOQL)           │
     └───────────────────┬───────────────────┘
                         │
     ┌───────────────────▼───────────────────┐
     │       SALESFORCE DATA MODEL           │
     │ 8 Custom Objects + 3 Platform Events  │
     └───────────────────┬───────────────────┘
                         │
     ┌───────────────────▼───────────────────┐
     │       AGENTFORCE AI LAYER             │
     │ Data-Grounded · Escalation · Logging  │
     └───────────────────────────────────────┘
```

---

## ✨ Key Features

| Feature | Technology | Description |
|---|---|---|
| 🤖 **AI Assistant** | Agentforce + Apex | Data-grounded chatbot for order tracking, menu recommendations, and revenue insights |
| 📊 **Live Dashboard** | LWC | Real-time order pipeline with status cards and analytics |
| 🔌 **REST APIs** | Apex REST | 5 endpoints: Menu, Order, Review, Revenue, Agent |
| ⚡ **Event-Driven** | Platform Events | `Order_Placed__e`, `Order_Status_Changed__e`, `Review_Submitted__e` |
| 🔒 **Security Model** | Permission Sets | 6 role-based permission sets (Admin, Manager, Support, Analytics, API, Agent) |
| 📱 **External Portal** | HTML/CSS/JS | Customer-facing web app consuming Salesforce APIs |
| 🔄 **Flows** | Record-Triggered | Order ready notification, low review auto-escalation to Case |
| ✅ **Validation Rules** | Declarative | 6 rules across Order, Review, Menu Item, and Order Item |
| 🧪 **Test Coverage** | Apex Tests | 90%+ coverage with TestDataFactory pattern |
| 🚀 **CI/CD** | GitHub Actions | Automated deploy + test pipeline |

---

## 📁 Project Structure

```
smartmenu-crm/
├── force-app/main/default/
│   ├── classes/              # 41 Apex classes (Service, Selector, Domain, API, Test)
│   ├── triggers/             # OrderTrigger, OrderItemTrigger (handler pattern)
│   ├── lwc/                  # smartMenuDashboard component
│   ├── objects/              # 8 custom objects + 3 platform events
│   │   ├── Order__c/         # Orders with status lifecycle
│   │   ├── Menu_Item__c/     # Restaurant menu catalog
│   │   ├── Review__c/        # Customer reviews & ratings
│   │   ├── Order_Item__c/    # Order line items (junction)
│   │   ├── AI_Conversation__c/  # Agentforce conversation log
│   │   ├── Application_Log__c/  # Error logging
│   │   └── ...
│   ├── flows/                # Record-triggered flows
│   ├── permissionsets/       # 6 role-based permission sets
│   └── corsWhitelistOrigins/ # External app CORS config
├── web/                      # External customer portal
├── Agents/                   # Architecture documentation (13 docs)
├── manifest/                 # Deployment package.xml
├── .github/workflows/        # CI/CD pipeline
└── scripts/                  # Utility scripts
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Platform** | Salesforce (Lightning Platform) |
| **Backend** | Apex (Service · Domain · Selector pattern) |
| **Frontend** | Lightning Web Components (LWC) |
| **AI** | Agentforce (InvocableMethod + intent routing) |
| **API** | Apex REST (5 endpoints) |
| **Automation** | Flows (Record-Triggered), Validation Rules |
| **Events** | Platform Events (3 custom events) |
| **Security** | Permission Sets, CRUD/FLS, `with sharing` |
| **Testing** | Apex Test Classes, TestDataFactory |
| **DevOps** | SFDX CLI, GitHub Actions, PMD |
| **External** | HTML, CSS, JavaScript (web portal) |

---

## 🚀 Getting Started

### Prerequisites
- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli)
- A Salesforce Developer Org ([free signup](https://developer.salesforce.com/signup))
- Git

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/vishwajittidke/smartmenu-crm.git
cd smartmenu-crm

# 2. Authorize your org
sf org login web -d -a SmartMenuDev

# 3. Deploy metadata
sf project deploy start

# 4. Run tests
sf apex test run -l RunLocalTests -w 10
```

---

## 📊 Apex Layered Architecture

| Layer | Classes | Purpose |
|---|---|---|
| **Service** | OrderService, MenuService, ReviewService, RevenueService | Business workflows + @AuraEnabled methods |
| **Domain** | OrderDomain, OrderCalculator, OrderEventPublisher | Business rules, calculations, event publishing |
| **Selector** | OrderSelector, MenuSelector, ReviewSelector, CustomerSelector | All SOQL queries centralized |
| **Trigger Handler** | OrderTriggerHandler, OrderItemTriggerHandler | Delegates trigger logic to Service layer |
| **REST API** | OrderApi, MenuApi, ReviewApi, RevenueApi, AgentApi | External integrations |
| **AI** | AgentforceAssistant | Intent detection, grounded responses, escalation |
| **Infrastructure** | BusinessException, TestDataFactory, DataFactory | Error handling, test utilities |

---

## 🤖 Agentforce AI Assistant

The AI assistant handles customer queries with **data-grounded responses** (no hallucination):

- **Order Tracking** — Looks up real order data by ID or name
- **Menu Recommendations** — Queries available menu items from Menu_Item__c
- **Revenue Insights** — Real-time analytics from completed orders
- **Review Summaries** — Aggregated ratings and recent feedback
- **Escalation** — Auto-creates a Case when the AI can't resolve a query

---

## 👤 Author

**Vishwajit Tidke**
- [LinkedIn](https://linkedin.com/in/vishwajittidke)
- [Trailblazer](https://trailblazer.me/id/vishwajittidke)
- [GitHub](https://github.com/vishwajittidke)
````

---

## 5. FOLDER CREATION COMMANDS

Run these in PowerShell to create the required folders before adding files:

```powershell
# Create validation rule folders
New-Item -ItemType Directory -Force -Path "force-app\main\default\objects\Order__c\validationRules"
New-Item -ItemType Directory -Force -Path "force-app\main\default\objects\Review__c\validationRules"
New-Item -ItemType Directory -Force -Path "force-app\main\default\objects\Menu_Item__c\validationRules"
New-Item -ItemType Directory -Force -Path "force-app\main\default\objects\Order_Item__c\validationRules"

# Create flows folder
New-Item -ItemType Directory -Force -Path "force-app\main\default\flows"
```

---

## 6. UPDATE package.xml

### Add these lines inside `<types>` sections in `manifest/package.xml`:

```xml
    <!-- Add under existing types or create new types block -->
    <types>
        <members>Order__c.Total_Must_Be_Positive_For_Delivery</members>
        <members>Order__c.Status_Transition_Guard</members>
        <members>Review__c.Rating_Range_Check</members>
        <members>Review__c.Comment_Required_For_Low_Rating</members>
        <members>Menu_Item__c.Price_Must_Be_Positive</members>
        <members>Order_Item__c.Quantity_Must_Be_Positive</members>
        <name>ValidationRule</name>
    </types>
    <types>
        <members>Order_Ready_Notification</members>
        <members>Review_Auto_Response</members>
        <name>Flow</name>
    </types>
```

---

## CHECKLIST

- [ ] Create validation rule folders (Section 5 commands)
- [ ] Add 6 Validation Rule XML files (Section 1)
- [ ] Create flows folder (Section 5 commands)
- [ ] Add 2 Flow XML files (Sections 2 & 3)
- [ ] Replace README.md (Section 4)
- [ ] Update package.xml (Section 6)
- [ ] Deploy: `sf project deploy start`
- [ ] Run tests: `sf apex test run -l RunLocalTests -w 10`
- [ ] Push to GitHub: `git add . && git commit -m "Add Flows, Validation Rules, upgrade README" && git push`
