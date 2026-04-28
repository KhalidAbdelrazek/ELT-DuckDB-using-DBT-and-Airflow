
SELECT 
CAST(order_id AS VARCHAR(32)) AS order_id, 
CAST(customer_id AS VARCHAR(32)) AS customer_id, 
CAST(order_status AS VARCHAR(16)) AS order_status, 
CAST(order_purchase_timestamp AS TIMESTAMP) AS purchase_at, 
CAST(order_approved_at AS TIMESTAMP) AS approved_at, 
CAST(order_delivered_carrier_date AS TIMESTAMP) AS delivered_carrier_at, 
CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_customer_at, 
CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_at
FROM {{ source('raw', 'orders') }}
