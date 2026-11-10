using './budget.bicep'

param budgetName = 'budget-example'
param budgetAmount = 100

param budgetStartDate = '2026-12-01T00:00:00Z'
param budgetEndDate = '2027-12-01T00:00:00Z'

param notificationEmail = 'replace-with-notification-email@example.com'

param actionGroupResourceId = '/subscriptions/REPLACE-SUBSCRIPTION-ID/resourceGroups/REPLACE-RESOURCE-GROUP/providers/Microsoft.Insights/actionGroups/REPLACE-ACTION-GROUP'
