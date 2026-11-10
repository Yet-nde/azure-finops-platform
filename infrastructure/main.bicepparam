using none

// General
param location = 'uksouth'
param environment = 'Dev'
param projectName = 'FinOpsPlatform'

// FinOps Storage
param storageName = 'REPLACE-FINOPS-STORAGE-ACCOUNT-NAME' 

// Monitoring and alerting
param actionGroupName = 'REPLACE-ACTION-GROUP-NAME'
param actionGroupShortName = 'FinOpsAlert'
param logicAppResourceId = '/subscriptions/REPLACE-SUBSCRIPTION-ID/resourceGroups/REPLACE-RESOURCE-GROUP/providers/Microsoft.Logic/workflows/REPLACE-LOGIC-APP-NAME'

// Azure Functions
param functionAppName = 'REPLACE-FUNCTION-APP-NAME'
param functionPlanName = 'REPLACE-FUNCTION-PLAN-NAME'
param functionStorageName = 'REPLACE-FUNCTION-STORAGE-ACCOUNT-NAME'
param applicationInsightsName = 'REPLACE-APPLICATION-INSIGHTS-NAME'

param logAnalyticsWorkspaceResourceId = '/subscriptions/REPLACE-SUBSCRIPTION-ID/resourcegroups/REPLACE-RESOURCE-GROUP/providers/microsoft.operationalinsights/workspaces/REPLACE-LOG-ANALYTICS-WORKSPACE'
param deploymentContainerName = 'REPLACE-FUNCTION-DEPLOYMENT-CONTAINER-NAME'

// Function application settings
param functionAppSettings = {
  COST_EXPORT_CONTAINER: 'cost-exports'
  COST_REPORT_CONTAINER: 'reports'
  COST_STORAGE_ACCOUNT: 'REPLACE-FINOPS-STORAGE-ACCOUNT-NAME'
  TIMER_SCHEDULE: '0 0 9 * * 1'

  // Identity-based Function Storage and monitoring
  // settings are supplied through private deployment configuration.
}

param workbookResourceName = 'REPLACE-WORKBOOK-RESOURCE-NAME'
param workbookDisplayName = 'Azure FinOps Cost & Governance Dashboard'
