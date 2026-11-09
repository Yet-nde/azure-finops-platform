@description('Azure resource name of the Workbook')
param workbookResourceName string

@description('Display name of the Workbook')
param workbookDisplayName string

@description('Deployment region')
param location string

@description('Common governance tags')
param tags object

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  identity: {
    type: 'None'
  }
  kind: 'shared'
  name: workbookResourceName
  location: location
  tags: union(tags, {
    BusinessCategory: 'Monitoring'
    ManagedBy: 'Bicep'
    'hidden-title': 'Azure FinOps Cost & Governance Dashboard'
  })
  properties: {
    displayName: workbookDisplayName
    version: 'Notebook/1.0'
    category: 'workbook'
    sourceId: 'azure monitor'
    serializedData: loadTextContent('../workbook.json')
  }
}

output workbookId string = workbook.id
output workbookResourceName string = workbook.name
