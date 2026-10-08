# Olist Customer Retention & Sales Analytics

## Project Overview

This project analyzes customer retention, purchasing behavior, and sales
activity using the Olist Brazilian E-commerce dataset downloaded from
Kaggle.

The project demonstrates: - SQL and BigQuery for business-metric
analysis - Power Query for data preparation and transformation - DAX for
analytical measures - Power BI for interactive reporting - Cohort
analysis for customer retention

## Business Questions

-   How many unique customers and orders are there?
-   What is the average number of orders per customer?
-   How many customers placed more than one order?
-   What is the repeat purchase rate?
-   How do orders change over time?
-   Which Brazilian states have the highest order volumes?
-   How does retention change after a customer's first purchase?
-   How do different customer cohorts behave over subsequent months?

## Dataset

Source: Olist Brazilian E-commerce dataset, downloaded from Kaggle.

Primary tables used: - `olist_customers_dataset` -
`olist_orders_dataset`

The analysis distinguishes between: - `customer_id`: customer record
associated with an order - `customer_unique_id`: identifier used to
represent the actual customer across orders

`customer_unique_id` is used for customer-level retention and
repeat-purchase analysis.

## Workflow

``` text
Olist Dataset
    ↓
Google BigQuery
    ↓
SQL business-metric exploration
    ↓
Power BI
    ↓
Power Query data preparation
    ↓
Data model + DAX
    ↓
Interactive Power BI Dashboard
```

The project initially explored calculations in BigQuery SQL. The final
analytical workflow was implemented in Power BI rather than relying on
permanent BigQuery view tables.

## SQL Analysis

### Basic Business Metrics

The initial SQL analysis calculated total orders, customer counts, and
orders per customer.

``` sql
SELECT
  COUNT(DISTINCT order_id) AS total_orders,
  COUNT(DISTINCT customer_id) AS unique_customers,
  ROUND(
    COUNT(DISTINCT order_id) /
    COUNT(DISTINCT customer_id),
    2
  ) AS orders_per_customer
FROM
  `my-website-dataxreports.brazil_ecommerce_dataset.olist_orders`;
```

For retention analysis, `customer_unique_id` is the appropriate
identifier for counting actual customers across orders.

### Repeat Customers

Customers were classified as repeat customers when their distinct order
count was greater than one.

Core metrics: - Unique Customers - Total Orders - Repeat Customers

## Cohort Retention Analysis

A customer cohort is defined by the month of the customer's first
recorded purchase.

Retention is calculated as:

``` text
Retention Rate =
Active Customers in Cohort Period
----------------------------------
Original Cohort Size
```

The SQL workflow calculated first purchase month, months since first
purchase, active customers, cohort size, and retention rate for months 0
through 12.

Month 0 represents the original cohort, so it is expected to show 100%
retention when the cohort is defined by customers who first purchased in
that month.

## BigQuery → Power BI

Power BI was connected to the BigQuery project:

-   Project: `my-website-dataxreports`
-   Dataset: `brazil_ecommerce_dataset`

A timestamp import issue occurred during development. To avoid the Power
BI timestamp error, order timestamps were returned from BigQuery as
strings and converted inside Power Query.

Example:

``` sql
SELECT
  order_id,
  customer_id,
  order_status,
  CAST(order_purchase_timestamp AS STRING)
    AS order_purchase_timestamp
FROM
  `my-website-dataxreports.brazil_ecommerce_dataset.olist_orders`;
```

## Power Query

Power Query was used to: - Convert timestamps into dates - Create
purchase months - Merge customer information into orders - Identify
first purchase dates - Create cohort months - Merge cohort information
back into the order-level table

### Purchase Date

``` powerquery
try
    Date.From(
        DateTimeZone.FromText(
            [order_purchase_timestamp]
        )
    )
otherwise
    null
```

### Purchase Month

``` powerquery
Date.StartOfMonth([Purchase Date])
```

### Cohort Month

``` powerquery
Date.StartOfMonth([First Purchase Date])
```

The final `Orders_Full` table contains fields including:

  Field                        Purpose
  ---------------------------- -------------------------------------------
  `order_id`                   Order identifier
  `customer_id`                Customer record associated with the order
  `customer_unique_id`         Actual customer identifier
  `order_status`               Order status
  `order_purchase_timestamp`   Original purchase timestamp
  `Purchase Month`             Month of the order
  `Cohort Month`               Month of the customer's first purchase

## DAX Measures

### Unique Customers

``` dax
Unique Customers =
DISTINCTCOUNT(Orders_Full[customer_unique_id])
```

### Total Orders

``` dax
Total Orders =
DISTINCTCOUNT(Orders_Full[order_id])
```

### Repeat Customers

``` dax
Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(Orders_Full[customer_unique_id]),
        CALCULATE(
            DISTINCTCOUNT(Orders_Full[order_id])
        ) > 1
    )
)
```

### Repeat Purchase Rate

``` dax
Repeat Purchase Rate =
DIVIDE(
    [Repeat Customers],
    [Unique Customers],
    0
)
```

### Average Orders per Customer

``` dax
Average Orders per Customer =
DIVIDE(
    [Total Orders],
    [Unique Customers],
    0
)
```

## Cohort Retention in Power BI

The cohort matrix uses: - Rows: `Cohort Month` - Columns:
`Purchase Month` - Values: `Retention Rate`

``` dax
Retention Rate =
DIVIDE(
    DISTINCTCOUNT(Orders_Full[customer_unique_id]),
    CALCULATE(
        DISTINCTCOUNT(Orders_Full[customer_unique_id]),
        REMOVEFILTERS(Orders_Full[Purchase Month])
    ),
    0
)
```

Conditional formatting was applied to create a retention heatmap.

## Repeat vs. One-Time Customers

A calculated DAX column classifies customers using their lifetime order
count:

``` dax
Customer Type =
VAR CustomerOrders =
    CALCULATE(
        DISTINCTCOUNT(Orders_Full[order_id]),
        ALLEXCEPT(
            Orders_Full,
            Orders_Full[customer_unique_id]
        )
    )
RETURN
    IF(
        CustomerOrders > 1,
        "Repeat Customer",
        "One-Time Customer"
    )
```

This classification is based on the customer's order history across the
available dataset.

## Dashboard

The final dashboard contains:

### KPI Cards

-   Unique Customers
-   Repeat Purchase Rate
-   Repeat Customers
-   Total Orders
-   Average Orders per Customer

### Visuals

-   Monthly Total Orders
-   Orders by Top 10 Brazilian States
-   Repeat vs. One-Time Customers
-   Cohort Retention Matrix

### Slicers

-   Year
-   Order Status
-   Customer State
-   Cohort Month

## Current Dashboard Findings

With the dashboard filters set to All, the report shows approximately: -
96K unique customers - 99K total orders - 3K repeat customers - 3.12%
repeat purchase rate - 1.03 average orders per customer - 96.88%
one-time customers

These values can change when slicers are applied.

## Tools Used

  Tool              Purpose
  ----------------- -------------------------------------
  Google BigQuery   Data storage and SQL analysis
  SQL               Business metric and cohort analysis
  Power Query / M   Data preparation and transformation
  DAX               Dynamic Power BI calculations
  Power BI          Data modeling and visualization
  Kaggle            Dataset source

## Skills Demonstrated

-   SQL aggregation
-   `COUNT(DISTINCT ...)`
-   Customer-level analysis
-   Repeat-purchase analysis
-   Cohort analysis
-   Retention analysis
-   BigQuery
-   Power Query / M
-   Data merging and transformation
-   DAX measures
-   DAX calculated columns
-   Filter context
-   Power BI visualization
-   Interactive dashboard design
-   Business metric definition


## Conclusion

This project demonstrates an end-to-end analytics workflow from raw
e-commerce data through SQL analysis, BigQuery, Power Query
transformations, DAX calculations, and an interactive Power BI
dashboard.

The main analytical focus was customer retention: identifying repeat
customers, calculating repeat purchase rate, defining customer cohorts,
and visualizing retention over time.
