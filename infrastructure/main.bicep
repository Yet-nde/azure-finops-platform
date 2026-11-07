targetScope = 'resourceGroup'

@description('Primary location for all resources.')
param location string = 'uksouth'

@description('Deployment environment.')
param environment string = 'Dev'

@description('Project name for the deployment.')
param projectName string = 'FinOpsPlatform'

@description('Globally unique name for the storage account.')
param storageName string

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

