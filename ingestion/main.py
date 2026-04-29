import pandas as pd
import functions as fn
import config
import os

if __name__ == "__main__":
    # 1. Initialize DB
    conn = fn.init_duckdb()
    fn.create_schema(conn)
    
    # merged tables
    merged_df = fn.merge_ingested_data(config)
    

    try:
        # Pass the table name to make it dynamic
        latest_ts = fn.get_latest_timestamp(conn, "orders", "order_purchase_timestamp")
        print(f"Latest timestamp in orders: {latest_ts}")
    except Exception as e:
        print(f"Error occurred while fetching latest timestamp for orders: {e}")
        latest_ts = None


    # for col in merged_df.columns:
    #     if 'timestamp' in col or 'date' in col:
    #         merged_df[col] = pd.to_datetime(merged_df[col])

    # 2. Process each table
    for table_name, details in config.TABLES.items():
        print(f"--- Processing: {table_name} ---")
        
        # Pull the columns we want to KEEP in the DB
        final_columns = details["columns"]
        # The column we use for filtering (order_purchase_timestamp)
        ts_col = details["timestamp_column"]

        # Get data for this table + the timestamp column for filtering
        cols_to_pull = final_columns
        df = merged_df[cols_to_pull].copy()
        
        # Deduplicate
        # df.drop_duplicates(subset=details["primary_key"], inplace=True)


        
        # 4. Filter for new records BEFORE dropping the TS column
        if latest_ts:
            latest_ts = pd.to_datetime(latest_ts)
            latest_ts = str(latest_ts)  

            new_data = df[df[ts_col] > latest_ts]
            print(f"Found {len(new_data)} new records for {table_name}.")
        else:
            new_data = df
            print(f"Found {len(new_data)} new records for {table_name}.")

        if table_name != "orders":
            final_columns = [col for col in final_columns if col != ts_col]

        if not new_data.empty:
            # 5. Define the Final Payload (Only the columns specified in config)
            # This ensures 'order_purchase_timestamp' only goes into 'orders' 
            # if it was explicitly listed in that table's columns in config.py
            payload = new_data[final_columns]

            # Create table if first run
            fn.create_tables(conn, table_name, payload, details["primary_key"])
            
            # Insert data
            fn.insert_data(conn, table_name, payload)
            print(f"Inserted {len(payload)} records into {table_name}.")
        else:
            print(f"No new records for {table_name}.")

    conn.close()