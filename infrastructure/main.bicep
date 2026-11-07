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

@description ('Resource ID of the Logic App to be invoked by the Action Group')
param logicAppResourceId string

@secure()
@description ('Callback URL of the Logic App to be invoked by the Action Group')
param logicAppCallbackUrl string

var commonTags = {
  Environment: environment
  Project: projectName
  CostCentre: 'Portfolio'
}

module storage 'modules/storage.bicep'= {
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
