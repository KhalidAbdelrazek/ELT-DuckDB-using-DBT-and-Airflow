{{ config(
    materialized='table',
    schema='marts',
    post_hook=["CREATE INDEX IF NOT EXISTS idx_geo_zip ON {{ this }} (geolocation_zip_code_prefix)"]
) }}

SELECT
    geolocation_zip_code_prefix,
    ANY_VALUE(geolocation_lat) AS geolocation_lat,
    ANY_VALUE(geolocation_lng) AS geolocation_lng,
    ANY_VALUE(geolocation_city) AS geolocation_city,
    ANY_VALUE(geolocation_state) AS geolocation_state
FROM {{ ref('stg_geolocation') }}
GROUP BY 1
ORDER BY geolocation_zip_code_prefix