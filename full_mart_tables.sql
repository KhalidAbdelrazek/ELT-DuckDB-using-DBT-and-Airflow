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



{{config(materialized='table', schema='marts')}}
WITH dim_products AS (
    SELECT
    DISTINCT product_id AS product_id,
    MODE(product_category_name) AS product_category_name,
    MODE(product_name_lenght) AS product_name_lenght,
    MODE(product_description_lenght) AS product_description_lenght,
    MODE(product_photos_qty) AS product_photos_qty,
    MODE(product_weight_g) AS product_weight_g,
    MODE(product_length_cm) AS product_length_cm,
    MODE(product_height_cm) AS product_height_cm,
    MODE(product_width_cm) AS product_width_cm
    FROM {{ ref('stg_products') }}
    GROUP BY product_id
)
SELECT * FROM dim_products


{{config(materialized='table', schema='marts')}}

WITH dim_reviews AS (
    SELECT
    DISTINCT review_id AS review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
    FROM {{ ref('stg_reviews') }}
)
SELECT * FROM dim_reviews



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