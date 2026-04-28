SELECT 
CAST(geolocation_zip_code_prefix AS INT) AS geolocation_zip_code_prefix,
CAST(geolocation_lat AS DECIMAL(18,14)) AS geolocation_lat,
CAST(geolocation_lng AS DECIMAL(18,14)) AS geolocation_lng,
CAST(geolocation_city AS VARCHAR(32)) AS geolocation_city,
CAST(geolocation_state AS VARCHAR(32)) AS geolocation_state
FROM {{ source('raw', 'geolocation') }}