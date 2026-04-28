{{ config(
    materialized='table',
    schema='marts',
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_fct_ord_id ON {{ this }} (order_id)",
        "CREATE INDEX IF NOT EXISTS idx_fct_prod_id ON {{ this }} (product_id)"
    ]
) }}

SELECT
    -- Native DuckDB way to create a unique hash
    md5(CAST(order_id AS VARCHAR) || CAST(order_item_id AS VARCHAR)) as order_item_key,
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM {{ ref('stg_order_items') }}
ORDER BY order_id