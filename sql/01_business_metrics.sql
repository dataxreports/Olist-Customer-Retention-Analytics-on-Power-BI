
-- Project: Olist Customer Retention & Sales Analytics
-- Purpose: Calculate core order and customer-record metrics.
-- Platform: Google BigQuery

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_records,
    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT order_id),
            COUNT(DISTINCT customer_id)
        ),
        2
    ) AS orders_per_customer_record
FROM
    `my-website-dataxreports.brazil_ecommerce_dataset.olist_orders`;
