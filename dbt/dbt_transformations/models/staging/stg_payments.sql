SELECT 
CAST(order_id AS VARCHAR(32)) AS order_id,
CAST(payment_sequential AS SMALLINT) AS payment_sequential,
CAST(payment_type AS VARCHAR(32)) AS payment_type,
CAST(payment_installments AS SMALLINT) AS payment_installments,
CAST(payment_value AS DECIMAL(10,2)) AS payment_value
FROM {{ source('raw', 'payments') }}