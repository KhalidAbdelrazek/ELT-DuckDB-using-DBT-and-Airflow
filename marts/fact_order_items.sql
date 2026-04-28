{{config(materialized='table', schema='marts')}}

WITH fact_order_items AS (
    SELECT
    order_item_id,
    order_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
    FROM {{ ref('stg_order_items') }}
)
SELECT * from fact_order_items