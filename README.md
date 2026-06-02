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
