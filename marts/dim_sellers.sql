{{config(materialized='table', schema='marts')}}

WITH dim_sellers AS (
    SELECT
    DISTINCT seller_id AS seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
    FROM {{ ref('stg_selllers') }}
)
SELECT * FROM dim_sellers