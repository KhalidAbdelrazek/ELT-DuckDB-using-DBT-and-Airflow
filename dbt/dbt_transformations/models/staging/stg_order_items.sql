SELECT 
CAST(order_id AS VARCHAR(32)) AS order_id, 
CAST(order_item_id AS VARCHAR(32)) AS order_item_id, 
CAST(product_id AS VARCHAR(32)) AS product_id, 
CAST(seller_id AS VARCHAR(32)) AS seller_id, 
CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date, 
CAST(price AS DOUBLE) AS price, 
CAST(freight_value AS DOUBLE) AS freight_value
FROM {{ source('raw', 'order_items') }}