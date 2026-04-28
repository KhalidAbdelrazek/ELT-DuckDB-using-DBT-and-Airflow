{{config(materialized='table', schema='marts')}}

WITH dim_payments AS (
    SELECT
    DISTINCT order_id AS order_id,
    MODE(payment_sequential) AS payment_sequential,
    MODE(payment_type) AS payment_type,
    MODE(payment_installments) AS payment_installments,
    MODE(payment_value) AS payment_value
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)
SELECT * FROM dim_payments