@description('Primary deployment region')
param location string

@description('Name of the Function App')
param functionAppName string

@description('Name of the Flex Consumption Plan')
param functionPlanName string

@description('Name of the Function runtime and deployment Storage account')
param functionStorageName string

@description('Name of the Application Insights resource')
param appInsightsName string

@description('Resource ID of the Log Analytics workspace for Application Insights')
param logAnalyticsWorkspaceResourceId string

@description('Name of the deployment package container')
param deploymentContainerName string

@description('Common governance tags')
param tags object

@secure()
@description('Complete set of Function App settings')
param functionAppSettings object

@description('Name of the FinOps cost Storage Account')
param costStorageAccountName string

@description('Existing Monitoring Metrics Publisher role-assignment name')
param monitoringMetricsPublisherAssignmentName string

@description('Existing Function Storage Blob Data Owner role-assignment name')
param functionStorageOwnerAssignmentName string

@description('Existing deployment-container Blob Data Contributor role-assignment name')
param deploymentContainerContributorAssignmentName string

@description('Existing cost Storage Blob Data Contributor role-assignment name')
param costStorageContributorAssignmentName string

var storageTags = union(tags, {
  BusinessCategory: 'Automation'
  ManagedBy: 'Bicep'
})

var monitoringTags = union(tags, {
  BusinessCategory: 'Monitoring'
  ManagedBy: 'Bicep'
})

var monitoringMetricsPublisherRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '3913510d-42f4-4e42-8a64-420c390055eb'
)

var storageBlobDataOwnerRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
)

var storageBlobDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

resource functionStorage 'Microsoft.Storage/storageAccounts@2026-09-01' = {
  name: functionStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: storageTags

  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowCrossTenantDelegationSas: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true

    networkAcls: {
      bypass: 'None'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
      ipv6Rules: []
    }

    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource functionBlobService 'Microsoft.Storage/storageAccounts/blobServices@2026-09-01' = {
  name: 'default'
  parent: functionStorage

  properties: {
    deleteRetentionPolicy: {
      enabled: false
      allowPermanentDelete: false
    }

    staticWebsite: { enabled: false }
  }
}

resource deploymentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-09-01' = {
  name: deploymentContainerName
  parent: functionBlobService
  properties: {
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: monitoringTags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableLocalAuth: true
  }
}

resource functionPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: functionPlanName
  location: location
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  kind: 'functionapp'
  tags: storageTags

  properties: {
    reserved: true
    zoneRedundant: false
  }
}

resource functionApp 'Microsoft.Web/sites@2025-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  tags: union(storageTags, {
    'hidden-link: /app-insights-resource-id': applicationInsights.id
  })

  properties: {
    enabled: true
    httpsOnly: true
    reserved: true
    publicNetworkAccess: 'Enabled'
    keyVaultReferenceIdentity: 'SystemAssigned'
    serverFarmId: functionPlan.id
    siteConfig: {
      alwaysOn: false
      functionAppScaleLimit: 100
      minimumElasticInstanceCount: 0
    }

    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: 'https://${functionStorage.name}.blob.${environment().suffixes.storage}/${deploymentContainer.name}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }

      runtime: {
        name: 'python'
        version: '3.15'
      }

      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 512
      }
    }
  }
}

resource monitoringMetricsPublisherAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: monitoringMetricsPublisherAssignmentName
  scope: applicationInsights

  properties: {
    roleDefinitionId: monitoringMetricsPublisherRoleId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource functionStorageOwnerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: functionStorageOwnerAssignmentName
  scope: functionStorage

  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentContainerContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: deploymentContainerContributorAssignmentName
  scope: deploymentContainer

  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource costStorageContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: costStorageContributorAssignmentName
  scope: costStorage

  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource functionAppConfiguration 'Microsoft.Web/sites/config@2025-03-01' = {
  name: 'appsettings'
  parent: functionApp
  properties: functionAppSettings
}

resource costStorage 'Microsoft.Storage/storageAccounts@2026-06-01' existing = {
  name: costStorageAccountName
}



output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output functionPrincipalId string = functionApp.identity.principalId
output functionStorageId string = functionStorage.id
output applicationInsightsId string = applicationInsights.id

