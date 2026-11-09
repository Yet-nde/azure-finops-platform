targetScope = 'subscription'

@description('Name of the subscription budget')
param budgetName string

@description('Budget amount')
param budgetAmount int

@description('Budget start date')
param budgetStartDate string

@description('Budget end date')
param budgetEndDate string

@description('Email address that receives budget notifications')
param notificationEmail string

@description('Resource ID of the Action Group used for budget notifications')
param actionGroupResourceId string

resource budget 'Microsoft.Consumption/budgets@2026-06-01' = {
  name: budgetName

  properties: {
    amount: budgetAmount
    category: 'Cost'
    timeGrain: 'Monthly'

    timePeriod: {
      startDate: budgetStartDate
      endDate: budgetEndDate
    }
  
    notifications: {
      actual_GreaterThan_100_Percent: {
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroupResourceId      
        ]
        contactRoles: []
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        thresholdType: 'Actual'
      }
      actual_GreaterThan_50_Percent: {
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroupResourceId
        ]
        contactRoles: []
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        thresholdType: 'Actual'
      }
      actual_GreaterThan_80_Percent: {
        contactEmails: [
          notificationEmail
        ]
        contactGroups: [
          actionGroupResourceId
        ]
        contactRoles: []
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        thresholdType: 'Actual'
      }
    }
  }
}
