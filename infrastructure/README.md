# Azure FinOps Platform Infrastructure
This directory contains the Bicep infrastructure definitions for the Azure FinOps platform.

## Prerequisites
Before deploying the infrastructure:
+ Install Visual Studio Code
+ Install Azure CLI
+ Install the Microsoft Bicep extension for VS Code
+ Install  Azure Functions Core Tools
+ Sign in to Azure with `az login`
+ Select the target Azure subscription
+ Ensure the deploying identity has the required Azure RBAC permissions


## Deployment scopes
### Resource group scope
`main.bicep` manages infrastructure deployed to the FinOps development resource group. <br/>
The deployment includes:
+ FinOps Storage Account and Blob Containers
+ Azure Functions Storage Account
+ Flex Consumption Hosting plan
+ Azure Function App
+ Application Insights
+ Azure Monitor Action Group
+ Azure Workbook
+ Managed identity and RBAC configuration

### Subscription scope
The `subscription` directory contains resources deployed at the subscription scope:
+ Cost Management Budget
+ Cost Management Actual Cost Export

## Managed Identity and RBAC
The Azure Function uses a system-assigned managed identity to access Azure resources without storing Storage Account keys in application code. <br/>
Bicep enables the Function App identity and defines the RBAC relationships required by the workload.
The Function identity is assigned:
- *Monitoring Metrics Publisher* on Application Insights
- *Storage Blob Data Owner* on the Function runtime Storage Account
- *Storage Blob Data Contributor* on the Function deployment package container
- *Storage Blob Data Contributor* on the FinOps cost Storage Account

These assignments allow the Function to use identity-based access for its runtime storage, deployment package, monitoring and FinOps cost data. <br/>
The role assignments are defined in : `modules/function.bicep` </br>
The Function App identity is referenced dynamically:
`principalId: functionApp.identity.principalId` <br/>
`principalType: 'ServicePrincipal'` <br/>
RBAC permissions are scoped to the Azure resources that require access rather than assigning permissions across the entire subscription.

## Parameter files
Public `.bicepparam` files contain example values only. <br/>
Environment-specific parameter files use the `.local.bicepparam` suffix and are excluded from source control.
### Examples:
+ `infrastructure/main.local.bicepparam`
+ `infrastructure/subscription/budget.local.bicepparam`
+ `infrastructure/subscription/cost-export.local.bicepparam`

Secrets, access keys, OAuth tokens and signed callback URLs must not be committed to source control.

## Gmail connector authentication
The notification workflow uses the Azure Logic Apps Gmail managed connector. <br/>
Infrastructure is automated through Bicep where practical. Gmail authentication remains environment-specific because the connector requires external OAuth consent. <br/>
OAuth credentials and tokens are not stored in this repository.

## Migrating Existing Resources to Bicep
The platform was initially deployed through the Azure Portal and progressively migrated to Bicep. <br/>
Existing resources were used as the starting point for the Infrastructure as Code definitions.
### Insert an Existing Resource
- Copy the Azure resource's Resource ID from the Azure Portal.
- Create and open the target `.bicep` file in VS Code.
- Press Ctrl + Shift + P.
- Search for and select `Bicep: Insert Resource`.
- Paste the Reource ID.
- Press Enter.
- Review the generated Bicep resource definition.

The generated definition is then refactored into reusable Infrastructure as Code before deployment. <br/>
### Create Parameter Files
Environment-specific values are separated from the reusable Bicep templates using `.bicepparam` files. <br/>
In VS Code:
- Open the relevant `.bicep` file.
- Press Ctrl + Shift + P.
- Search for and select `Bicep: Generate Parameters File`
- Review the generated paramters.
- Separate public example values from the real environment-specific values.

The repository uses two types of parameter files:
- `*.bicepparam`: Public example configuration committed to Git
- `*.local.bicepparam`: Real environment-specific configuration excluded from Git 

Local parameter files are excluded through `.gitignore`. <br/>

Generated reource definitions are not deployed without review because they can contain Azure-generated properties and environment-specific configuration.


## Deployment safety
Infrastructure changes are validated using:
+ Bicep build
+ ARM preflight validation
+ What-if review
+ Deployment
+ Post-deployment What-if verification

Azure Resource Manager What-If is used to preview predicted infrastructure changes before deployment.

## Deployment Commands 
The following commands use PowerShell.
### Authentication
- Sign in to Azure: 
```powershell
`az login`
```
- Check the active subscription: 
```powershell
az account show `
  --query "{Name:name,SubscriptionId:id}" `
  --output table
```
- If required, select the target subscription: 
```powershell
az account set `
  --subscription "YOUR-SUBSCRIPTION-ID"
```
### Resource Group Infrastructure
- build
```powershell
az bicep build `
  --file infrastructure/main.bicep
```
- build local parameters
```powershell
az bicep build-params `
  --file infrastructure/main.local.bicepparam
```
- validate
```powershell
az deployment group validate `
  --resource-group rg-finops-dev-uks `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/main.local.bicepparam
```
- preview changes
```powershell
az deployment group what-if `
  --resource-group rg-finops-dev-uks `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/main.local.bicepparam
```
- deploy 
```powershell
az deployment group create `
  --name finops-platform-infrastructure `
  --resource-group rg-finops-dev-uks `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/main.local.bicepparam
```
- verify idempotency (after deployment)
```powershell
az deployment group what-if `
  --resource-group rg-finops-dev-uks `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/main.local.bicepparam
```
### Cost Management Budget
- build
```powershell
az bicep build `
  --file infrastructure/subscription/budget.bicep
```
- build local parameters
```powershell
az bicep build-params `
  --file infrastructure/subscription/budget.local.bicepparam
```
- validate
```powershell
az deployment sub validate `
  --location uksouth `
  --template-file infrastructure/subscription/budget.bicep `
  --parameters infrastructure/subscription/budget.local.bicepparam
```
- preview changes
```powershell
az deployment sub what-if `
  --location uksouth `
  --template-file infrastructure/subscription/budget.bicep `
  --parameters infrastructure/subscription/budget.local.bicepparam
```
- deploy
```powershell
az deployment sub create `
  --name finops-budget-infrastructure `
  --location uksouth `
  --template-file infrastructure/subscription/budget.bicep `
  --parameters infrastructure/subscription/budget.local.bicepparam
```
- verify idempotency
```powershell
az deployment sub what-if `
  --location uksouth `
  --template-file infrastructure/subscription/budget.bicep `
  --parameters infrastructure/subscription/budget.local.bicepparam
```
### Cost Management Budget
- build
```powershell
az bicep build `
  --file infrastructure/subscription/cost-export.bicep
```
- build local parameters
```powershell
az bicep build-params `
  --file infrastructure/subscription/cost-export.local.bicepparam
```
- validate
```powershell
az deployment sub validate `
  --location uksouth `
  --template-file infrastructure/subscription/cost-export.bicep `
  --parameters infrastructure/subscription/cost-export.local.bicepparam
```
- preview changes
```powershell
az deployment sub what-if `
  --location uksouth `
  --template-file infrastructure/subscription/cost-export.bicep `
  --parameters infrastructure/subscription/cost-export.local.bicepparam
```
- deploy
```powershell
az deployment sub create `
  --name finops-cost-export-infrastructure `
  --location uksouth `
  --template-file infrastructure/subscription/cost-export.bicep `
  --parameters infrastructure/subscription/cost-export.local.bicepparam
```
- verify idempotency
```powershell
az deployment sub what-if `
  --location uksouth `
  --template-file infrastructure/subscription/cost-export.bicep `
  --parameters infrastructure/subscription/cost-export.local.bicepparam
```
## Deployment Guidance
Always review the output from what-if before deploying. <br/>
Unexpected resource creation, deletion, replacement or configuration changes should be investigated before proceeding. <br/>
Environment-specific `.local.bicepparam` files are used for real deployments and must remain outside source control.