WITH raw_users AS (
    SELECT
        CAST(id AS STRING) AS user_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        email,
        age,
        country,
        state,
        city,
        traffic_source,
        created_at
    FROM {{ source('raw', 'users') }}
    WHERE id IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY created_at DESC) = 1
)

SELECT * FROM raw_users