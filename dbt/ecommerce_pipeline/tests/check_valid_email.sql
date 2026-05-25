-- Ensures all user emails follow a basic valid format (contains @ and a domain with a dot).
-- Invalid emails would break any downstream email marketing or communication workflows.
SELECT user_id, full_name, email
FROM {{ ref('stg_raw_users') }}
WHERE email NOT LIKE '%@%.%'