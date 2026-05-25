-- Checks if total_spend in dim_customers is negative. Total spend should never be negative, so this test will fail if there are any records with total_spend < 0.
SELECT customer_id, total_spend
FROM {{ref('dim_customers')}}
WHERE total_spend < 0