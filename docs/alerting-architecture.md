**Automated Cost Alerting** <br />

**Overview** <br />
The FinOps platform implements automated cost notifications using Azure Cost Management, Azure Monitor Action Groups and Azure Logic Apps.

**Alert Flow** <br />
Budget threshold reached
+ Azure Monitor Action Group
+ Azure Logic App
+ Email notification

**Components** <br />
+ Cost Management Budget <br />
Provides subscription-level financial monitoring and evaluates configured cost thresholds.

+ Azure Monitor Action Group <br />
Provides the automation link between a budget event and the notification workflow.

+ Azure Logic App <br />
Receives the event and executes the notification workflow.

**Design Considerations** <br />
Cost Management budget alerts should not be treated as real-time monitoring because cost data and budget evaluation have inherent processing delays. <br />
The Logic App endpoint is treated as sensitive configuration and is not stored in this public repository.
