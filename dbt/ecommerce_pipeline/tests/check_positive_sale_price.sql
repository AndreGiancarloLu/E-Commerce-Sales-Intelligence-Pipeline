-- Ensures all order items have a positive sale price.
-- Sale price is the primary revenue metric, zero or negative values would directly corrupt revenue reporting.
SELECT order_item_id, order_id, sale_price
FROM {{ ref('stg_raw_order_items') }}
WHERE sale_price <= 0