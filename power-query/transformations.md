# Power Query Transformations

## Overview

Power Query was used in Power BI to clean, transform, and combine the Olist e-commerce data before building the dashboard.

## 1. Timestamp Conversion

The BigQuery order timestamps caused conversion errors during import. To work around this, the timestamp was cast to a string in the SQL query and converted to a date in Power Query.

```powerquery
try
    Date.From(
        DateTimeZone.FromText(
            [order_purchase_timestamp]
        )
    )
otherwise
    null
```

The resulting column was named `Purchase Date` and assigned the Date data type.

## 2. Purchase Month

A month-level date column was created from the purchase date.

```powerquery
Date.StartOfMonth([Purchase Date])
```

This column supports monthly order trends and cohort analysis.

## 3. Customer Information Merge

The customer table was merged into the order data using `customer_id`.

The `customer_unique_id` field was expanded to identify customers across multiple orders.

## 4. First Purchase Date

A separate customer cohort query was created to identify each customer's first recorded purchase.

The process was:
1. Reference the order data.
2. Keep the customer identifier and purchase timestamp.
3. Merge customer information to obtain `customer_unique_id`.
4. Group by `customer_unique_id`.
5. Calculate the minimum purchase date.

This produces one row per actual customer.

## 5. Cohort Month

The first purchase date was converted into a month-level date.

```powerquery
Date.StartOfMonth([First Purchase Date])
```

The resulting `Cohort Month` field identifies the month in which each customer first purchased.

## 6. Merge Cohort Data into Orders

The cohort table was merged back into `Orders_Full` using `customer_unique_id` with a Left Outer join.

This added the cohort month to the order-level data, allowing orders to be analyzed by both purchase month and customer acquisition cohort.

## Final Orders_Full Fields

| Field | Purpose |
|---|---|
| `order_id` | Identifies an order |
| `customer_id` | Customer record identifier |
| `customer_unique_id` | Identifies the actual customer |
| `order_status` | Order status |
| `order_purchase_timestamp` | Original purchase timestamp |
| `Purchase Date` | Converted purchase date |
| `Purchase Month` | Month of the order |
| `Cohort Month` | Month of the customer's first purchase |

## Outcome

These transformations prepared the order-level data for the Power BI data model, KPI measures, monthly order chart, customer-type donut chart, and cohort retention matrix.
