-- Ensures product cost is greater than zero.
-- A zero or negative cost indicates bad data from the source system.
SELECT product_id, cost
FROM {{ ref('stg_raw_products') }}
WHERE cost <= 0