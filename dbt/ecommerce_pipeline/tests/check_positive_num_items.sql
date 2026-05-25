-- Ensures every order contains at least one item.
-- Zero or negative item counts indicate malformed orders that would corrupt order volume metrics.
SELECT order_id, user_id, num_of_item
FROM {{ ref('stg_raw_orders') }}
WHERE num_of_item <= 0