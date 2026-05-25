WITH raw_order_items AS (
    SELECT
        CAST(oi.id AS STRING) AS order_item_id,
        CAST(oi.order_id AS STRING) AS order_id,
        CAST(oi.user_id AS STRING) AS user_id,
        CAST(oi.product_id AS STRING) AS product_id,
        CAST(oi.inventory_item_id AS STRING) AS inventory_item_id,
        oi.status,
        oi.created_at,
        oi.sale_price
    FROM {{ source('raw', 'order_items') }} oi
    INNER JOIN {{ ref('stg_raw_products') }} p ON CAST(oi.product_id AS STRING) = p.product_id
    WHERE oi.id IS NOT NULL
)

SELECT * FROM raw_order_items