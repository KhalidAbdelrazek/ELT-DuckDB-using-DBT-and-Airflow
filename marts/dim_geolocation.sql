{{config(materialized='table', schema='marts')}}

WITH dim_geolocation AS (
    SELECT
    DISTINCT geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
    FROM {{ ref('stg_geolocation') }}
)
SELECT * FROM dim_geolocation
