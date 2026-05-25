WITH fct_orders AS (
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.user_id,
        oi.product_id,
        oi.status AS item_status,
        oi.sale_price,
        oi.created_at,

        -- from orders
        o.num_of_item,
        o.status AS order_status,

        -- from products
        p.name AS product_name,
        p.category,
        p.department,
        p.brand,
        p.cost,
        p.retail_price,

        -- from users
        u.full_name,
        u.country,
        u.traffic_source
    FROM
        {{ ref('stg_raw_order_items')}} AS oi JOIN 
        {{ ref('stg_raw_orders') }} AS o ON o.order_id = oi.order_id JOIN 
        {{ ref('stg_raw_products')}} AS p ON oi.product_id = p.product_id JOIN
        {{ ref('stg_raw_users')}} AS u ON oi.user_id = u.user_id
)

SELECT * FROM fct_orders