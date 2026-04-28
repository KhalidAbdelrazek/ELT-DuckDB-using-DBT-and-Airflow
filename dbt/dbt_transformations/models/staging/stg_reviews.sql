SELECT 
CAST(review_id AS VARCHAR(32)) AS review_id,
CAST(order_id AS VARCHAR(32)) AS order_id,
CAST(review_score AS SMALLINT) AS review_score,
CAST(review_comment_title AS VARCHAR(32)) AS review_comment_title,
CAST(review_comment_message AS STRING) AS review_comment_message,
CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM {{ source('raw', 'reviews') }}