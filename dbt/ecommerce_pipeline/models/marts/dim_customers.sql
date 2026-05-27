WITH customer_stats AS (
    SELECT
        u.user_id AS customer_id,
        u.full_name AS customer_name,
        u.email AS customer_email,
        u.country AS customer_country,
        u.age AS customer_age,
        COALESCE(SUM(oi.sale_price), 0)                AS total_spend,
        COALESCE(COUNT(DISTINCT o.order_id), 0)        AS total_orders,
        COALESCE(SUM(oi.sale_price) / NULLIF(COUNT(DISTINCT o.order_id), 0), 0) AS avg_order_value,
        MIN(o.created_at)                 AS first_order_date,
        MAX(o.created_at)                 AS last_order_date,
        CASE 
            WHEN MAX(o.created_at) IS NULL THEN NULL
            ELSE DATE_DIFF(CURRENT_DATE(), MAX(DATE(o.created_at)), DAY)
        END AS days_since_last_order
    FROM {{ ref('stg_raw_users') }} u
    LEFT JOIN {{ ref('stg_raw_orders') }} o ON u.user_id = o.user_id
    LEFT JOIN {{ ref('stg_raw_order_items') }} oi ON o.order_id = oi.order_id AND oi.status IN ('Complete', 'Shipped')
    GROUP BY u.user_id, u.full_name, u.email, u.country, u.age
)

SELECT * FROM customer_stats