
-- Project: Olist Customer Retention & Sales Analytics
-- Purpose: Identify repeat customers and calculate repeat purchase rate.
-- Platform: Google BigQuery

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM
        `my-website-dataxreports.brazil_ecommerce_dataset.Olist_customer_dataset` AS c
    JOIN
        `my-website-dataxreports.brazil_ecommerce_dataset.olist_orders` AS o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    COUNT(*) AS unique_customers,
    COUNTIF(order_count > 1) AS repeat_customers,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(order_count > 1),
            COUNT(*)
        ) * 100,
        2
    ) AS repeat_purchase_rate_pct
FROM
    customer_orders;
