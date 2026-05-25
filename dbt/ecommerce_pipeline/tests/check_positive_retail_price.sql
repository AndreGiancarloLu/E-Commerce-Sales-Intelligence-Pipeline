-- Ensures all products have a positive retail price.
-- Zero or negative retail prices would distort revenue and discount calculations.
SELECT product_id, retail_price
FROM {{ ref('stg_raw_products') }}
WHERE retail_price <= 0