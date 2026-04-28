{{ config(
    materialized='table',
    schema='marts',
    post_hook=["CREATE INDEX IF NOT EXISTS idx_rev_id ON {{ this }} (review_id)"]
) }}

SELECT
    DISTINCT review_id AS review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM {{ ref('stg_reviews') }}
ORDER BY review_score DESC