
-- Project: Olist Customer Retention & Sales Analytics
-- Purpose: Calculate monthly customer retention by acquisition cohort.
-- Platform: Google BigQuery

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC(
            DATE(o.order_purchase_timestamp),
            MONTH
        ) AS order_month
    FROM
        `my-website-dataxreports.brazil_ecommerce_dataset.Olist_customer_dataset` AS c
    JOIN
        `my-website-dataxreports.brazil_ecommerce_dataset.olist_orders` AS o
        ON c.customer_id = o.customer_id
),

first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_activity AS (
    SELECT
        f.cohort_month,
        DATE_DIFF(
            o.order_month,
            f.cohort_month,
            MONTH
        ) AS months_since_first_purchase,
        COUNT(DISTINCT o.customer_unique_id) AS active_customers
    FROM customer_orders AS o
    JOIN first_purchase AS f
        ON o.customer_unique_id = f.customer_unique_id
    GROUP BY
        f.cohort_month,
        months_since_first_purchase
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
)

SELECT
    a.cohort_month,
    a.months_since_first_purchase,
    s.cohort_size,
    a.active_customers,
    ROUND(
        SAFE_DIVIDE(
            a.active_customers,
            s.cohort_size
        ) * 100,
        2
    ) AS retention_rate_pct
FROM cohort_activity AS a
JOIN cohort_sizes AS s
    ON a.cohort_month = s.cohort_month
ORDER BY
    a.cohort_month,
    a.months_since_first_purchase;
