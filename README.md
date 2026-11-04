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

Governance Tags <br />
|Tag   |          Value |
| --- | --- |
|Environment  |   Dev |
|Project  |       FinOpsPlatform |
|CostCentre  |    Portfolio |
|ManagedBy   |    Bicep |

Design Decisions
A single resource group is being used for the development environment because the resources share the same project lifecycle. <br />
UK South is the primary deployment region. <br />
A £10 monthly subscription budget was configured before deploying workload resources to provide early visibility into PAYG spending.

**Phase 2-Cost Managemnt and Governance** <br />
-[x] Explored Azure Cost Analysis <br />
-[x] Defined subscription and project cost scopes <br />
-[x] Defined project tagging strategy <br />
-[x] Defined business-friendly cost categories <br />
-[x] Documented cost governance decisions <br />

**Cost Reporting Strategy** 

The platform preserves Azure-native cost information for technical analysis while introducing business-friendly reporting categories for stakeholders. <br />

Detailed documentation: <br />
+ docs/cost-governance.md
+ docs/cost-mapping.md

**Phase 3-Automated Cost Alerting** <br />
-[x] Logic App deployed <br />
-[x] Azure Monitor Action Group configured <br />
-[x] Budget connected to Action Group <br />
-[x] Automated email workflow configured <br />
-[x] Alert workflow tested <br />
-[x] Alerting architecture documented

**Phase 4-Cost Data Export & Storage** <br />
-[x] Azure Storage Account deployed <br/>
-[x] Cost export container configured <br/>
-[x] Daily Cost Management export configured <br/>
-[x] Actual cost dataset exported <br/>
-[x] Export delivery verified <br/>
-[x] Cost export architecture documented

**Phase 5-Weekly Cost Analysis** <br/>
-[x] Python Axure Function developed <br/>
-[x] Cost export data processed <br/>
-[x] Managed identity configured <br/>
-[x] Weekly report to be written to Azure Storage <br/>
-[x] Function execution verified </br>


Current Status <br />
-[x] Resource group created <br />
-[x] Governance tags applied <br />
-[x] PAYG safety budget configured <br />
-[x] Cost Management configured <br />
-[x] Action Group configured <br />
-[x] Logic App deployed <br />
-[x] Cost export configured <br />
-[x] Azure Function deployed <br />
-[] Workbook created <br />
-[] Infrastructure converted to Bicep <br />
