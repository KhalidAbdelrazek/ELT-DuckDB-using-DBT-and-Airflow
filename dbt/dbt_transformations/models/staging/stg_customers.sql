SELECT 
CAST(customer_id AS VARCHAR(32)) AS customer_id,
CAST(customer_unique_id AS VARCHAR(32)) AS customer_unique_id,
CAST(customer_zip_code_prefix AS INT) AS customer_zip_code_prefix,
CAST(customer_city AS VARCHAR(32)) AS customer_city,
CAST(customer_state AS VARCHAR(32)) AS customer_state,
FROM {{ source('raw', 'customers') }}