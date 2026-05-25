-- Ensures user ages fall within a realistic human lifespan (0–120).
-- Ages outside this range indicate data entry errors or incorrect parsing from the source system.
SELECT user_id, full_name, age
FROM {{ ref('stg_raw_users') }}
WHERE age < 0 OR age > 120