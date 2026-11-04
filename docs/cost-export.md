**Cost Data Export** <br />

**Purpose** <br />
The FinOps platform requires historical Azure cost data for reporting and trend analysis. <br/>
Azure Cost Management exports cost data into Azure Storage for downstream processing.

**Architecture** <br/>
Azure Cost Management <br/>
+ Scheduled Cost Export
+ Azure Storage
+ Azure Function (Phase 5)
+ Weekly Cost Report

**Configuration** <br/>
+ Scope: Subscription
+ Dataset: Actual cost
+ Schedule: Daily
+ Timeframe: Month-to-date
+ Storage container: cost-exports
+ Root path: actual-cost

**Storage Governance** <br/>
The Storage Account belongs to the development resource group and uses the project's governance tags.
Raw cost export files are not stored in the public GitHub repository.

**Future Processing** <br/>
A later Azure Function will process exported cost data to calculate weekly spending changes and identify significant cost movements.




