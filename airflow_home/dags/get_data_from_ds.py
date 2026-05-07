import os
import shutil
import kagglehub
from airflow import DAG
from airflow.operators.python import PythonOperator 
from datetime import datetime

# Force the Kaggle config path
os.environ['KAGGLE_CONFIG_DIR'] = "/home/khalidabdelrazk/.kaggle"

def download_and_move_data():
    dataset_handle = "olistbr/brazilian-ecommerce"
    target_dir = "/home/khalidabdelrazk/projects/workshops/ELT-DuckDB-using-DBT-and-Airflow/data"
    
    # 1. Clean and Prepare target
    os.makedirs(target_dir, exist_ok=True)

    # 2. Download (This handles the API call and extraction)
    print(f"Downloading {dataset_handle}...")
    cache_path = kagglehub.dataset_download(dataset_handle)
    print(f"Kagglehub cache path: {cache_path}")

    # 3. Walk through the cache to find ALL files (handling subfolders)
    files_found = 0
    for root, dirs, files in os.walk(cache_path):
        for file in files:
            if file.endswith(".csv"):
                source_file = os.path.join(root, file)
                destination_file = os.path.join(target_dir, file)
                shutil.copy2(source_file, destination_file)
                print(f"Successfully copied: {file}")
                files_found += 1

    if files_found == 0:
        raise Exception(f"No CSV files found in {cache_path}. Check Kaggle dataset structure.")
    
    print(f"Total files copied to project: {files_found}")
    return target_dir

with DAG(
    dag_id="get_data_from_ds",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=['workshop', 'ingestion']
) as dag:

    download_task = PythonOperator(
        task_id="get_data_task",
        python_callable=download_and_move_data,
    )