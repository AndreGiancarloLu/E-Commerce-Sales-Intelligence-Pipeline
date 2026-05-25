-- Ensures sale price is never lower than the product cost.
-- If sale_price < cost, the business is selling at a loss, which may indicate bad data or a pricing error.
SELECT p.product_id, oi.order_id, oi.sale_price, p.cost
FROM {{ ref('stg_raw_products') }} AS p
JOIN {{ ref('stg_raw_order_items') }} AS oi ON p.product_id = oi.product_id
WHERE oi.sale_price < p.cost