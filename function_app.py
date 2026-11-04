import csv
import gzip
import io
import json
import logging
import os
from collections import defaultdict
from datetime import datetime, timedelta, timezone

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

app = func.FunctionApp()


DATE_COLUMNS = [
    "Date",
    "date",
    "UsageDate",
    "usageDate",
    "ChargePeriodStart",
]

COST_COLUMNS = [
    "CostInBillingCurrency",
    "costInBillingCurrency",
    "PreTaxCost",
    "Cost",
    "cost",
]

SERVICE_COLUMNS = [
    "ServiceName",
    "serviceName",
    "ConsumedService",
    "MeterCategory",
]

RESOURCE_GROUP_COLUMNS = [
    "ResourceGroup",
    "resourceGroup",
    "ResourceGroupName",
    "resourceGroupName",
]


def first_value(row: dict, candidates: list[str], default: str = "") -> str:
    for column in candidates:
        value = row.get(column)
        if value not in (None, ""):
            return str(value)
    return default


def parse_date(value: str):
    formats = [
        "%Y-%m-%d",
        "%m/%d/%Y",
        "%d/%m/%Y",
        "%Y-%m-%dT%H:%M:%SZ",
        "%Y-%m-%dT%H:%M:%S",
    ]

    for date_format in formats:
        try:
            return datetime.strptime(value, date_format).date()
        except ValueError:
            continue

    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00")).date()
    except ValueError:
        return None


def parse_cost(value: str) -> float:
    if value is None:
        return 0.0

    cleaned = str(value).replace(",", "").strip()

    try:
        return float(cleaned)
    except ValueError:
        return 0.0


def percentage_change(current: float, previous: float):
    if previous == 0:
        return None if current != 0 else 0.0

    return ((current - previous) / previous) * 100


def load_latest_cost_csv(blob_service: BlobServiceClient, container_name: str):
    container = blob_service.get_container_client(container_name)

    csv_blobs = [
        blob
        for blob in container.list_blobs()
        if blob.name.lower().endswith((".csv", ".csv.gz"))
    ]

    if not csv_blobs:
        raise RuntimeError(
            f"No CSV cost exports were found in container '{container_name}'."
        )

    latest_blob = max(
        csv_blobs,
        key=lambda blob: blob.last_modified or datetime.min.replace(
            tzinfo=timezone.utc
        ),
    )

    logging.info("Reading cost export blob: %s", latest_blob.name)

    blob_client = container.get_blob_client(latest_blob.name)
    raw_content = blob_client.download_blob().readall()

    if latest_blob.name.lower().endswith(".csv.gz"):
        raw_content = gzip.decompress(raw_content)

    content = raw_content.decode("utf-8-sig")

    reader = csv.DictReader(io.StringIO(content))
    return list(reader), latest_blob.name


def build_weekly_report(rows: list[dict], source_blob: str):
    parsed_rows = []

    for row in rows:
        date_value = first_value(row, DATE_COLUMNS)
        cost_value = first_value(row, COST_COLUMNS)

        usage_date = parse_date(date_value)
        if usage_date is None:
            continue

        parsed_rows.append(
            {
                "date": usage_date,
                "cost": parse_cost(cost_value),
                "service": first_value(
                    row,
                    SERVICE_COLUMNS,
                    "Uncategorised service",
                ),
                "resource_group": first_value(
                    row,
                    RESOURCE_GROUP_COLUMNS,
                    "No resource group",
                ),
            }
        )

    if not parsed_rows:
        raise RuntimeError(
            "The export was read, but no valid dated cost records were found."
        )

    latest_date = max(row["date"] for row in parsed_rows)

    current_start = latest_date - timedelta(days=6)
    previous_end = current_start - timedelta(days=1)
    previous_start = previous_end - timedelta(days=6)

    current_rows = [
        row
        for row in parsed_rows
        if current_start <= row["date"] <= latest_date
    ]

    previous_rows = [
        row
        for row in parsed_rows
        if previous_start <= row["date"] <= previous_end
    ]

    current_total = sum(row["cost"] for row in current_rows)
    previous_total = sum(row["cost"] for row in previous_rows)

    current_by_service = defaultdict(float)
    previous_by_service = defaultdict(float)
    current_by_resource_group = defaultdict(float)

    for row in current_rows:
        current_by_service[row["service"]] += row["cost"]
        current_by_resource_group[row["resource_group"]] += row["cost"]

    for row in previous_rows:
        previous_by_service[row["service"]] += row["cost"]

    all_services = set(current_by_service) | set(previous_by_service)
    service_changes = []

    for service in all_services:
        current_cost = current_by_service.get(service, 0.0)
        previous_cost = previous_by_service.get(service, 0.0)

        service_changes.append(
            {
                "service": service,
                "current_cost": round(current_cost, 2),
                "previous_cost": round(previous_cost, 2),
                "change": round(current_cost - previous_cost, 2),
            }
        )

    top_services = sorted(
        current_by_service.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:5]

    top_resource_groups = sorted(
        current_by_resource_group.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:5]

    largest_increases = sorted(
        service_changes,
        key=lambda item: item["change"],
        reverse=True,
    )[:5]

    return {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_blob": source_blob,
        "current_period": {
            "start": current_start.isoformat(),
            "end": latest_date.isoformat(),
            "total_cost": round(current_total, 2),
        },
        "previous_period": {
            "start": previous_start.isoformat(),
            "end": previous_end.isoformat(),
            "total_cost": round(previous_total, 2),
        },
        "comparison": {
            "absolute_change": round(current_total - previous_total, 2),
            "percentage_change": (
                None
                if percentage_change(current_total, previous_total) is None
                else round(
                    percentage_change(current_total, previous_total),
                    2,
                )
            ),
        },
        "top_services": [
            {"service": service, "cost": round(cost, 2)}
            for service, cost in top_services
        ],
        "top_resource_groups": [
            {"resource_group": group, "cost": round(cost, 2)}
            for group, cost in top_resource_groups
        ],
        "largest_service_increases": largest_increases,
    }


def create_blob_service_client():
    account_name = os.environ["COST_STORAGE_ACCOUNT"]

    credential = DefaultAzureCredential()

    return BlobServiceClient(
        account_url=f"https://{account_name}.blob.core.windows.net",
        credential=credential,
    )


@app.timer_trigger(
    schedule="%TIMER_SCHEDULE%",
    arg_name="timer",
    run_on_startup=False,
    use_monitor=True,
)
def weekly_cost_report(timer: func.TimerRequest) -> None:
    logging.info("Weekly FinOps cost report started.")

    source_container = os.getenv(
        "COST_EXPORT_CONTAINER",
        "cost-exports",
    )
    report_container = os.getenv(
        "COST_REPORT_CONTAINER",
        "reports",
    )

    blob_service = create_blob_service_client()

    rows, source_blob = load_latest_cost_csv(
        blob_service,
        source_container,
    )

    report = build_weekly_report(rows, source_blob)

    report_container_client = blob_service.get_container_client(
        report_container
    )

    try:
        report_container_client.create_container()
    except Exception:
        # The container probably already exists.
        pass

    report_blob = report_container_client.get_blob_client(
        "weekly-cost-report.json"
    )

    report_blob.upload_blob(
        json.dumps(report, indent=2),
        overwrite=True,
        content_type="application/json",
    )

    logging.info(
        "Weekly report created. Current cost: %.2f; previous cost: %.2f",
        report["current_period"]["total_cost"],
        report["previous_period"]["total_cost"],
    )