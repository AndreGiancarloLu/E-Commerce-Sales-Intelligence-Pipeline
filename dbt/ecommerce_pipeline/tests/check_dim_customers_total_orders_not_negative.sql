-- Checks if total_orders in dim_customers is negative. Total orders should never be negative, so this test will fail if there are any records with total_orders < 0.
SELECT customer_id, total_orders
FROM {{ref('dim_customers')}}
WHERE total_orders < 0