targetScope = 'subscription'

@description('Name of the Cost Management Export')
param exportName string

@description('Azure region used for the Export managed identity')
param location string

@description('Resource ID of the destination Storage Account')
param storageAccountResourceId string

@description('Name of the destination Blob container')
param containerName string

@description('Root folder path within the destination container')
param rootFolderPath string

@description('Start of the recurring export schedule in UTC')
param recurrenceStartDate string

@description('End of the recurring export schedule in UTC')
param recurrenceEndDate string

resource costExport 'Microsoft.CostManagement/exports@2026-06-01' = {
  name: exportName
  location: location

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    exportDescription: 'Daily month-to-date actual cost export managed by Bicep'

    definition: {
      type: 'ActualCost'
      timeframe: 'MonthToDate'

      dataSet: {
        granularity: 'Daily'

      }
    }

    deliveryInfo: {
      destination: {
        type: 'AzureBlob'
        resourceId: storageAccountResourceId
        container: containerName
        rootFolderPath: rootFolderPath
      }
    }

    format: 'Csv'
    compressionMode: 'gzip'
    partitionData: true
    dataOverwriteBehavior: 'CreateNewReport'

    schedule: {
      status: 'Active'
      recurrence: 'Daily'

      recurrencePeriod: {
        from: recurrenceStartDate
        to: recurrenceEndDate
      }
    }
  }
}

output exportId string = costExport.id
output exportName string = costExport.name
output exportPrincipalId string = costExport.identity.principalId
