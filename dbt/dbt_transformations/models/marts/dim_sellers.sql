{{ config(
    materialized='table',
    schema='marts',
    post_hook=["CREATE INDEX IF NOT EXISTS idx_sel_id ON {{ this }} (seller_id)"]
) }}

SELECT
    DISTINCT seller_id AS seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM {{ ref('stg_selllers') }}
ORDER BY seller_zip_code_prefix