WITH raw_orders AS (
    SELECT
        CAST(order_id AS STRING) AS order_id,
        CAST(user_id AS STRING) AS user_id,
        num_of_item,
        status,
        created_at
    FROM {{source('raw', 'orders') }}
    WHERE order_id IS NOT NULL 
)

SELECT * FROM raw_orders