-- Ensures sale price is greater than zero.
-- A zero or negative sale price indicates bad data from the source system.
SELECT
    order_item_id,
    order_id,
    user_id,
    product_id,
    sale_price
FROM
    {{ref('fct_orders')}}
WHERE
    sale_price <= 0