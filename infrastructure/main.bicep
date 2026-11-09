targetScope = 'resourceGroup'

@description('Primary location for all resources.')
param location string = 'uksouth'

@description('Deployment environment.')
param environment string = 'Dev'

@description('Project name for the deployment.')
param projectName string = 'FinOpsPlatform'

@description('Globally unique name for the storage account.')
param storageName string

@description('Name of the Azure Monitor Action Group')
param actionGroupName string = 'ag-finops-budget-dev'

@description('Short display name for the Action Group')
param actionGroupShortName string = 'FinOpsAlert'

@description('Resource ID of the Logic App to be invoked by the Action Group')
param logicAppResourceId string

@secure()
@description('Callback URL of the Logic App to be invoked by the Action Group')
param logicAppCallbackUrl string

@description('Name of the Function App')
param functionAppName string = 'func-finops-dev-uks'

@description('Name of the Flex Consumption hosting plan')
param functionPlanName string = 'ASP-rgfinopsdevuks-9500'

@description('Name of the Function runtime Storage Account')
param functionStorageName string = 'stgfinopsfuncdev'

@description('Name of the Application Insights resource')
param applicationInsightsName string = 'func-finops-dev-uks'

@description('Resource ID of the existing Log Analytics workspace')
param logAnalyticsWorkspaceResourceId string

@description('Name of the Function deployment package container')
param deploymentContainerName string

@secure()
@description('Complete Function App setting collection')
param functionAppSettings object

@description('Existing Monitoring Metrics Publisher role-assignment name')
param monitoringMetricsPublisherAssignmentName string

@description('Existing Function Storage Blob Data Owner role-assignment name')
param functionStorageOwnerAssignmentName string

@description('Existing deployment-container Blob Data Contributor role-assignment name')
param deploymentContainerContributorAssignmentName string

@description('Existing cost Storage Blob Data Contributor role-assignment name')
param costStorageContributorAssignmentName string

@description('Azure resource name of the FinOps Workbook')
param workbookResourceName string

@description('Display name of the FinOps Workbook')
param workbookDisplayName string

var commonTags = {
  Environment: environment
  Project: projectName
  CostCentre: 'Portfolio'
}

module storage 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageName: storageName
    location: location
    tags: commonTags
  }
}

output storageAccountId string = storage.outputs.storageAccountId
output storageAccountName string = storage.outputs.storageAccountName

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoringDeployment'
  params: {
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupShortName
    tags: commonTags
    logicAppResourceId: logicAppResourceId
    logicAppCallbackUrl: logicAppCallbackUrl
  }
}
output actionGroupId string = monitoring.outputs.actionGroupId
output actionGroupName string = monitoring.outputs.actionGroupName

module functionInfrastructure 'modules/function.bicep' = {
  name: 'functionInfrastructureDeployment'

  params: {
    location: location
    functionAppName: functionAppName
    functionPlanName: functionPlanName
    functionStorageName: functionStorageName
    appInsightsName: applicationInsightsName
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    deploymentContainerName: deploymentContainerName
    tags: commonTags
    functionAppSettings: functionAppSettings
    costStorageAccountName: storage.outputs.storageAccountName
    monitoringMetricsPublisherAssignmentName: monitoringMetricsPublisherAssignmentName
    functionStorageOwnerAssignmentName: functionStorageOwnerAssignmentName
    deploymentContainerContributorAssignmentName: deploymentContainerContributorAssignmentName
    costStorageContributorAssignmentName: costStorageContributorAssignmentName
  }
}

output functionAppId string = functionInfrastructure.outputs.functionAppId
output functionPrincipalId string = functionInfrastructure.outputs.functionPrincipalId

module workbook 'modules/workbook.bicep' = {
  name: 'workbookDeployment'

  params: {
    workbookResourceName: workbookResourceName
    workbookDisplayName: workbookDisplayName
    location: location
    tags: commonTags
  }
}

output workbookId string = workbook.outputs.workbookId
