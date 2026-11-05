# FinOps Visibility Dashboard

## Purpose
The Azure Workbook provides operational and governance visibility for the FinOps platform.

## Dashboard Views
The dashboard includes:
- Project resource inventory
- Resource distribution by Azure service type
- Regional resource distribution
- Governance tag compliance
- Missing-tag detection
- Business-category reporting

## Cost Visibility
Azure Cost Management remains the source for detailed financial analysis. <br/>
The platform complements Cost Management with automated budget alerts, scheduled cost exports and a severless weekly cosr comparison report.

## Data Sources
The Workbook uses Azure Resource Graph to query resource metadata and governance information. <br/>
Weekly financial reporting is generated separately from Cost Management export data by the Azure Function.
