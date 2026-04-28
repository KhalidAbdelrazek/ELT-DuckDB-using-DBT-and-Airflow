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