using none

param location = 'uksouth'
param environment = 'Dev'
param projectName = 'FinOpsPlatform'
param storageName = 'stgfinopsdev007' 

param actionGroupName = 'ag-finops-budget-dev'
param actionGroupShortName = 'FinOpsAlert'
param logicAppResourceId = '/subscriptions/c405faf8-bd9b-4f3d-96d2-5e5325306fbc/resourceGroups/rg-finops-dev-uks/providers/Microsoft.Logic/workflows/logic-finops-alerts-dev'

param functionAppName = 'func-finops-dev-uks'
param functionPlanName = 'ASP-rgfinopsdevuks-9500'
param functionStorageName = 'stgfinopsfuncdev'
param applicationInsightsName = 'func-finops-dev-uks'

param logAnalyticsWorkspaceResourceId = '/subscriptions/c405faf8-bd9b-4f3d-96d2-5e5325306fbc/resourcegroups/rg-finops-dev-uks/providers/microsoft.operationalinsights/workspaces/defaultworkspace-c405faf8-bd9b-4f3d-96d2-5e5325306fbc-suk'
param deploymentContainerName = 'app-package-func-finops-dev-uks-1b2f70e'

param functionAppSettings = {
  COST_EXPORT_CONTAINER: 'cost-exports'
  COST_REPORT_CONTAINER: 'reports'
  COST_STORAGE_ACCOUNT: 'stgfinopsdev007'
  TIMER_SCHEDULE: '0 0 9 * * 1'

  // Identity-based Function Storage and monitoring
  // settings are supplied through private deployment configuration.
}
