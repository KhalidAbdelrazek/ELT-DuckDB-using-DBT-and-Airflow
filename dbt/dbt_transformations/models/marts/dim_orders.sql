{{ config(
    materialized='table',
    schema='marts',
    post_hook=["CREATE INDEX IF NOT EXISTS idx_ord_id ON {{ this }} (order_id)"]
) }}

SELECT 
    DISTINCT order_id,
    customer_id,
    order_status,
    purchase_at,
    approved_at,
    delivered_carrier_at,
    delivered_customer_at,
    estimated_delivery_at
FROM {{ ref('stg_orders') }}
ORDER BY purchase_at