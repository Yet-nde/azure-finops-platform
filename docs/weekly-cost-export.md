# Weekly Cost Report

## Purpose
The weekly cost report uses an Azure Function to analyse exported Azure cost data and highlight changes in cloud spending over time.

## Input Data
Cost data is provided by the Azure Cost Management export created in Phase 4 and stored in the `cost-exports` Blob Storage Container. <br/>
The function analyses usage date, cost, azure service and resource group

## Seven-Day Comparison
The function compares the latest seven days of available cost data and the preceding seven-day period.<br/>
It calculates total spend, cost change, percentage change, top services, top resource groups, and significant service-level increases.

## Authentication
The function uses a system-assigned managed identity with the `Storage Blob Data Contributor` role. This allows Blob Storage access without storng Storage Account keys in the application code.

## Output
The generated JSON report is written to `reports/weekly-cost-report.json`. Real cost reports are not committed to the public GitHub repository.

## Schedule
The function uses a timer trigger. A short interval is used during testing. After validation, the function is configured to run weekly using the `TIMER_SCHEDULE` environment variable.

## Limitations
+ Cost reporting depends on the availability of Cost Management export data.
+ A complete comparison requires enough data for both seven-day periods.
+ The function must support the file format and compression used by the export.
+ Cost information is not real-time.



