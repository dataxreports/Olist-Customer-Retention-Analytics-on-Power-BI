
# DAX Measures — Olist Customer Retention & Sales Analytics

DAX (Data Analysis Expressions) was used to calculate customer KPIs and retention metrics in Power BI.

## 1. Unique Customers

```dax
Unique Customers =
DISTINCTCOUNT(Orders_Full[customer_unique_id])
```

Counts distinct customers in the current filter context.

## 2. Total Orders

```dax
Total Orders =
DISTINCTCOUNT(Orders_Full[order_id])
```

Counts distinct orders in the current filter context.

## 3. Repeat Customers

```dax
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

Counts customers with more than one distinct order in the current filter context.

## 4. Repeat Purchase Rate

```dax
Repeat Purchase Rate =
DIVIDE(
    [Repeat Customers],
    [Unique Customers],
    0
)
```

Calculates the proportion of customers classified as repeat customers. Format this measure as a percentage in Power BI.

## 5. Average Orders per Customer

```dax
Average Orders per Customer =
DIVIDE(
    [Total Orders],
    [Unique Customers],
    0
)
```

Calculates the average number of distinct orders per customer in the current filter context.

## 6. Retention Rate

```dax
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

Used in the cohort retention matrix to compare distinct active customers in a purchase month with the customer count after removing the Purchase Month filter.

The matrix uses:
- Rows: `Cohort Month`
- Columns: `Purchase Month`
- Values: `Retention Rate`

The cohort filter remains in place while the Purchase Month filter is removed.

## 7. Customer Type — Calculated Column

```dax
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

Classifies customers according to their order count across the available dataset. Used as the category in the Repeat vs. One-Time Customers donut chart.

## Notes

- Measures respond to the current report filter context.
- The Customer Type calculated column is evaluated during model refresh.
- Repeat Customers is calculated within the current filter context, so its result can differ from a lifetime repeat-customer classification.
- Retention results depend on the report's filters and the data model.
