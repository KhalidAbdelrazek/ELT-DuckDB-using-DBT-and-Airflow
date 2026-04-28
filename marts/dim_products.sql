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