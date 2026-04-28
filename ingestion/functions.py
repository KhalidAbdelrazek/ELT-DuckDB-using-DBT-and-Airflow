import pandas as pd
import duckdb


def init_duckdb():
    conn = duckdb.connect('../Datawarehouse.duckdb')
       
    return conn

def create_schema(conn : duckdb.DuckDBPyConnection):
    conn.execute("CREATE SCHEMA IF NOT EXISTS raw")
    conn.execute("CREATE SCHEMA IF NOT EXISTS staging")
    conn.execute("CREATE SCHEMA IF NOT EXISTS marts")

def ingest_data(file_path) :
    return pd.read_csv(file_path)

def create_tables(conn, table_name, df, primary_key):
    # This creates the table with the correct columns but 0 rows
    conn.execute(f"CREATE TABLE IF NOT EXISTS raw.{table_name} AS SELECT * FROM df WHERE 1=0")

def get_latest_timestamp(conn : duckdb.DuckDBPyConnection, table_name : str, timestamp_column : str):
    result = conn.execute(
        """
        SELECT MAX(order_purchase_timestamp) FROM raw.orders
        """.format(timestamp_column="order_purchase_timestamp", table_name="orders")
    ).fetchall()
    return result[0][0] if result else None

def insert_data (conn : duckdb.DuckDBPyConnection, table_name : str, df : pd.DataFrame):
    conn.execute("""
        INSERT INTO raw.{table_name} SELECT * FROM df
    """.format(table_name=table_name))
    conn.commit()

import gc

def merge_ingested_data(config):
    # 1. Load and merge the core transaction tables first
    orders = pd.read_csv(config.TABLES["orders"]["file_path"])
    items = pd.read_csv(config.TABLES["order_items"]["file_path"])
    
    # Merge items into orders and immediately delete items to free RAM
    df = pd.merge(orders, items, on="order_id", how="left")
    del orders, items
    gc.collect()

    # 2. Add Products
    products = pd.read_csv(config.TABLES["products"]["file_path"])
    df = pd.merge(df, products, on="product_id", how="left")
    del products
    gc.collect()

    # 3. Add Customers (needed for the zip_code link later)
    customers = pd.read_csv(config.TABLES["customers"]["file_path"])
    df = pd.merge(df, customers, on="customer_id", how="left")
    del customers
    gc.collect()

    # 4. Handle Geolocation (DANGER ZONE)
    # The geolocation table has many duplicates per zip code. 
    # We MUST drop duplicates before merging to avoid memory explosion.
    geo = pd.read_csv(config.TABLES["geolocation"]["file_path"])
    geo = geo.drop_duplicates(subset=['geolocation_zip_code_prefix']) # Keep only 1 row per zip
    
    df = pd.merge(df, geo, left_on="customer_zip_code_prefix", 
                  right_on="geolocation_zip_code_prefix", how="left")
    del geo
    gc.collect()

    # 5. Add remaining small tables (Payments/Reviews)
    payments = pd.read_csv(config.TABLES["payments"]["file_path"])
    df = pd.merge(df, payments, on="order_id", how="left")
    del payments

    sellers = pd.read_csv(config.TABLES["sellers"]["file_path"])
    
    # We use 'left' join so we don't lose orders that might have missing seller info
    df = pd.merge(df, sellers, on="seller_id", how="left")
    
    del sellers
    gc.collect()
    
    reviews = pd.read_csv(config.TABLES["reviews"]["file_path"])
    df = pd.merge(df, reviews, on="order_id", how="left")
    del reviews

    gc.collect()
    return df