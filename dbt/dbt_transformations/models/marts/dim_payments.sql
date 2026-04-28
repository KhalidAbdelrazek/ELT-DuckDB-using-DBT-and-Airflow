{{ config(
    materialized='table',
    schema='marts',
    post_hook=["CREATE INDEX IF NOT EXISTS idx_pay_order_id ON {{ this }} (order_id)"]
) }}

SELECT
    order_id,
    MODE(payment_sequential) AS payment_sequential,
    MODE(payment_type) AS payment_type,
    MODE(payment_installments) AS payment_installments,
    MODE(payment_value) AS payment_value,
    SUM(payment_value) AS total_payment_value
FROM {{ ref('stg_payments') }}
GROUP BY order_id