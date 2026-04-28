{{config(materialized='table', schema='marts')}}

WITH customers AS (
    SELECT
        DISTINCT customer_id AS customer_id,
        MODE(customer_unique_id) AS customer_unique_id,
        ANY_VALUE(customer_zip_code_prefix) AS customer_zip_code_prefix,
        ANY_VALUE(customer_city) AS customer_city,
        ANY_VALUE(customer_state) AS customer_state
    FROM {{ ref('stg_customers') }} 
    GROUP BY customer_id
)
SELECT * FROM customers