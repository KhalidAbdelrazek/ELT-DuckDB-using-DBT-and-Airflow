{{ config(materialized='table', schema='marts') }}

WITH order_items AS (
    SELECT * FROM {{ ref('fact_order_items') }}
),
orders AS (
    SELECT * FROM {{ ref('dim_orders') }}
),
customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
),
products AS (
    SELECT * FROM {{ ref('dim_products') }}
),
sellers AS (
    SELECT * FROM {{ ref('dim_sellers') }}
),
reviews AS (
    SELECT * FROM {{ ref('dim_reviews') }}
),
geo AS (
    SELECT * FROM {{ ref('dim_geolocation') }}
),
payments AS (
    SELECT * FROM {{ ref('dim_payments') }}
)

SELECT
    -- Unique Key for this grain (item level)
    md5(CAST(oi.order_id AS VARCHAR) || CAST(oi.order_item_id AS VARCHAR)) AS order_item_key,
    
    -- IDs & Keys
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    o.customer_id,
    
    -- Transactional Data
    o.order_status,
    o.purchase_at,
    oi.price,
    oi.freight_value,
    
    -- Payment Details
    pay.payment_type,
    pay.payment_installments,
    pay.payment_value AS total_order_payment_value,

    -- Customer Info & Geography
    c.customer_city,
    c.customer_state,
    cg.geolocation_lat AS customer_lat,
    cg.geolocation_lng AS customer_lng,
    
    -- Seller Info & Geography
    s.seller_city,
    s.seller_state,
    sg.geolocation_lat AS seller_lat,
    sg.geolocation_lng AS seller_lng,
    
    -- Product Details
    p.product_category_name,
    
    -- Customer Feedback
    r.review_score

FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
LEFT JOIN reviews r ON oi.order_id = r.order_id
LEFT JOIN payments pay ON oi.order_id = pay.order_id
LEFT JOIN geo cg ON c.customer_zip_code_prefix = cg.geolocation_zip_code_prefix
LEFT JOIN geo sg ON s.seller_zip_code_prefix = sg.geolocation_zip_code_prefix