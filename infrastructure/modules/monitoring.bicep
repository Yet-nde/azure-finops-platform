@description('Name of the Azure Monitor Action Group')
param actionGroupName string

@description('Short display name for the Action Group')
param actionGroupShortName string

@description ('Common goveranace tags for the Action Group')
param tags object

@description ('Resource ID of the Logic App to be invoked by the Action Group')
param logicAppResourceId string

@secure()
@description ('Callback URL of the Logic App to be invoked by the Action Group')
param logicAppCallbackUrl string


resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: actionGroupName
  location: 'Global'

  tags: union (tags,{
    BusinessCategory: 'Monitoring'
    ManagedBy: 'Bicep'
  })
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: [
      {
        name: 'InvokeFinOpsLOgicApp'
        resourceId: logicAppResourceId
        callbackUrl: logicAppCallbackUrl
        useCommonAlertSchema: false
      }
    ]
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name
