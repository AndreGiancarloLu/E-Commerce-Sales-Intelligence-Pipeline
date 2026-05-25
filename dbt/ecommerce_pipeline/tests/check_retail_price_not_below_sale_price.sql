-- If sale_price > retail_price, the customer was charged more than the listed price, indicating bad data.
-- Note: retail_price reflects the current product price, not the price at time of purchase.
-- False positives are possible if product prices have changed since the order was placed.
SELECT p.product_id, oi.order_id, oi.sale_price, p.retail_price
FROM {{ ref('stg_raw_products') }} AS p
JOIN {{ ref('stg_raw_order_items') }} AS oi ON p.product_id = oi.product_id
WHERE oi.sale_price > p.retail_price