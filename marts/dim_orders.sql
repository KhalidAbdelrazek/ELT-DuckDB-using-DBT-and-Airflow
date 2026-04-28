{{config(materialized='table', schema='marts')}}

WITH dim_orders AS(
    SELECT 
    DISTINCT order_id AS order_id,
    customer_id,
    order_status,
    purchase_at,
    approved_at,
    delivered_carrier_at,
    delivered_customer_at,
    delivered_customer_at,
    estimated_delivery_at
    FROM {{ ref('stg_orders') }}
)
SELECT * FROM dim_orders