# azure-finops-platform
Azure FinOps Cost Monitoring &amp; Governance Platform for cost visibility, budget alerting, automation and cloud governance

Objectives
* Monitor Azure cloud spending
* Implement budget thresholds and alerts
* Automate cost notifications
* Provide business-friendly cost visibility
* Apply Azure governance practices
* Deploy Infrastructure as Code (IaC) using bicep

Azure Services
* Azure Cost Management
* Azure Monitor
* Azure Logic Apps
* Azure Functions
* Azure Storage
* Azure Workbooks
* Azure Bicep

Status
-\|/- In development
  
**Phase 1-Foundation and Cost Controls**

Configuration
* Subscription: Azure Subscription 1 (PAYG)
* Primary region: UK South
* Resource group:rg-finops-dev-uks
* Environment: Development
* Monthly safety budget: £10

Governance Tags
 Tag             Value 
+ Environment     Dev
+ Project         FinOpsPlatform
+ CostCentre      Portfolio
+ ManagedBy       Bicep

Design Decisions
A single resource group is being used for the development environment because the resources share the same project lifecycle.
UK South is the primary deployment region.
A £10 monthly subscription budget was configured before deploying workload resources to provide early visibility into PAYG spending.

Current Status
-[x] Resource group created
-[x] Governance tags applied
-[x] PAYG safety budget configured
-[] Cost Management configured
-[] Action Group configured
-[] Logic App deployed
-[] Cost export configured
-[] Azure Function deployed
-[] Workbook created
-[] Infrastructure converted to Bicep
