**Cost Governance Strategy** <br />
**Subscription Scope** <br />
Subscription-level Cost Management provides visibility across the Pay-As-You-Go subscription. <br />

A £10 monthly safety budget has been configured at subscription scope to provide early warning of Azure expenditure. <br />

**Project Scope** <br />
The FinOps platform uses the following development resource group: rg-finops-dev-uks <br />

**Tagging Strategy** <br />
| Tag | Purpose |
| --- | ---|
|Environment | Identifies the deployment environment|
| Project | Identifies the project|
|CostCentre | Identifies cost ownership|
|ManagedBy | Identifies the deployment mechanism|

**Cost Reporting** <br />
Costs will be analysed using dimensions including:
+ Azure service
* Resource group
* Business category
* Time period
* Project/environment

**Cost Analysis** <br />
+ Which service is costing the most? <br />
During the analysed period, virtual machine was the largest cost contributor at £0.05.

+ Which resource group owns the expenditure? <br />
The largest proportion of expenditure was associated with forpolicypractice,representing £0.05 during the analysed period.

+ How could be a business owner understand thes costs? <br />
Azure-native service names are useful for technical teams but may not provide enough business context for non-technical stakeholders. The FinOps platform will therefore translate Azure expenditure into business-oriented categories such as Servers, Storage, Applications, Databases, Automation, Monitoring and Security. This allows stakeholders to understand both where cloud expenditure originates and the business function associated with that expenditure.

**Key FinOps Observation** <br />
Cost visibility alone does not provide cost governance. Cost Analysis provides visibility into where expenditure originates, but budgets, alerting, automation and reporting are required to make that information actionable.