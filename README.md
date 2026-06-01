# SmartMenu — Salesforce Project

Salesforce-native restaurant operations platform (SmartMenu) — scaffolding for demo portfolio.

Getting started

1. Install Salesforce CLI: https://developer.salesforce.com/tools/sfdxcli
2. Authorize an org:

```powershell
sfdx auth:web:login -d -a SmartMenuDev
```

3. Deploy source to the org:

```powershell
sfdx force:source:deploy -p force-app -u SmartMenuDev
```

4. Run Apex tests:

```powershell
sfdx force:apex:test:run -u SmartMenuDev --resultformat human --codecoverage
```

Files added

- `sfdx-project.json` — project config
- `force-app/main/default/classes/OrderService.cls` — sample Apex service
- `force-app/main/default/classes/OrderServiceTest.cls` — unit test
- `force-app/main/default/lwc/smartMenuDashboard/*` — LWC skeleton
- `force-app/main/default/objects/Order__c/*` — sample custom object metadata
- `.github/workflows/ci.yml` — CI workflow stub

Additional scaffold

- `force-app/main/default/objects/Order__c/fields/Status__c.field-meta.xml` — Order status picklist
- `force-app/main/default/objects/Order__c/fields/Total__c.field-meta.xml` — Order total currency field
- `force-app/main/default/objects/Order__c/fields/Customer__c.field-meta.xml` — lookup to Contact
- `force-app/main/default/classes/OrderApi.cls` — simple Apex REST endpoint
- `force-app/main/default/classes/AgentforceAssistant.cls` — Agentforce integration placeholder
- `manifest/package.xml` — deployment manifest
- `scripts/init-repo.ps1` — git init script

CI / Secrets

- For automated deployment configure GitHub secrets: `SF_CLIENT_ID`, `SF_CLIENT_SECRET`, `SF_USERNAME`, `SF_SERVER_URL`, or use JWT auth with a certificate and `SF_JWT_KEY`.

Quick deploy (example using authenticated org alias `SmartMenuDev`):

```powershell
# deploy metadata from manifest
sfdx force:source:deploy -x manifest/package.xml -u SmartMenuDev
```
