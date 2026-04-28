TABLES = {
    "orders": {
        "file_path": "../data/olist_orders_dataset.csv",
        "primary_key": "order_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["order_id","customer_id","order_status","order_purchase_timestamp","order_approved_at","order_delivered_carrier_date","order_delivered_customer_date","order_estimated_delivery_date"]
    },
    "order_items": {
        "file_path": "../data/olist_order_items_dataset.csv",
        "primary_key": "order_item_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["order_id","order_item_id","product_id","seller_id","shipping_limit_date","price","freight_value","order_purchase_timestamp"]
    },
    "customers": {
        "file_path": "../data/olist_customers_dataset.csv",
        "primary_key": "customer_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["customer_id","customer_unique_id","customer_zip_code_prefix","customer_city","customer_state","order_purchase_timestamp"]
    },
    "products": {
        "file_path": "../data/olist_products_dataset.csv",
        "primary_key": "product_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["product_id","product_category_name","product_name_lenght","product_description_lenght","product_photos_qty","product_weight_g","product_length_cm","product_height_cm","product_width_cm","order_purchase_timestamp"]
    },
    "sellers": {
        "file_path": "../data/olist_sellers_dataset.csv",
        "primary_key": "seller_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["seller_id","seller_zip_code_prefix","seller_city","seller_state","order_purchase_timestamp"]
    },
    "reviews": {
        "file_path": "../data/olist_order_reviews_dataset.csv",
        "primary_key": "review_id",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["review_id","order_id","review_score","review_comment_title","review_comment_message","review_creation_date","review_answer_timestamp","order_purchase_timestamp"]
    },
    "payments": {
        "file_path": "../data/olist_order_payments_dataset.csv",
        "primary_key": "order_id", # Note: payments doesn't have a unique payment_id, it's order_id + sequence
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["order_id","payment_sequential","payment_type","payment_installments","payment_value","order_purchase_timestamp"]
    },
    "geolocation": {
        "file_path": "../data/olist_geolocation_dataset.csv",
        "primary_key": "geolocation_zip_code_prefix",
        "timestamp_column": "order_purchase_timestamp",
        "columns": ["geolocation_zip_code_prefix","geolocation_lat","geolocation_lng","geolocation_city","geolocation_state","order_purchase_timestamp"]
    }
}