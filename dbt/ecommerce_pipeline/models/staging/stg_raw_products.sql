WITH raw_products AS (
    SELECT
        CAST(id AS STRING) AS product_id,
        cost,
        category,
        name,
        COALESCE(brand, 'Unknown') AS brand,
        retail_price,
        department
    FROM {{source('raw', 'products')}}
    WHERE id IS NOT NULL AND name IS NOT NULL
)

SELECT * FROM raw_products