SELECT
CAST(seller_id AS VARCHAR(32)) AS seller_id,
CAST(seller_zip_code_prefix AS INT) AS seller_zip_code_prefix,
CAST(seller_city AS VARCHAR(16)) AS seller_city,
CAST(seller_state AS VARCHAR(16)) AS seller_state
FROM {{ source('raw', 'sellers') }}