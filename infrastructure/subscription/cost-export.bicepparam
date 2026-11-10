using './cost-export.bicep'

param exportName = 'export-example-actual-cost'
param location = 'global'

param storageAccountResourceId = '/subscriptions/REPLACE-SUBSCRIPTION-ID/resourceGroups/REPLACE-RESOURCE-GROUP/providers/Microsoft.Storage/storageAccounts/REPLACE-STORAGE-ACCOUNT'

param containerName = 'cost-exports'
param rootFolderPath = 'actual-cost'

param recurrenceStartDate = '2026-12-01T00:00:00Z'
param recurrenceEndDate = '2027-12-01T00:00:00Z'
