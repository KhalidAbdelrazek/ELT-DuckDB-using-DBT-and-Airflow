from datetime import datetime
from pathlib import Path
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator # Modern import

# 1. PATH CONFIGURATION - Fixed leading slash and paths
PROJECT_ROOT = Path("/home/khalidabdelrazk/projects/workshops/ELT-DuckDB-using-DBT-and-Airflow")
# Based on your 'ls', your dbt project is inside 'dbt/dbt_transformations'
DBT_ROOT = PROJECT_ROOT / "dbt" / "dbt_transformations"
VENV_PYTHON = PROJECT_ROOT / ".venv" / "bin" / "python"
VENV_DBT = PROJECT_ROOT / ".venv" / "bin" / "dbt"

with DAG(
    dag_id="olist_end_to_end_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=['olist', 'elt', 'duckdb', 'dbt', 'airflow']
) as dag:

    # TASK 1: INGESTION
    ingest_data = BashOperator(
        task_id="ingest_csv_to_duckdb",
        cwd=str(PROJECT_ROOT / "ingestion"), 
        # Using f-strings without extra single quotes is usually safer for local paths
        bash_command=f"{VENV_PYTHON} main.py",
    )

    # TASK 2: DBT TRANSFORMATIONS
    dbt_transform = BashOperator(
        task_id="dbt_run_transformations",
        cwd=str(DBT_ROOT),
        # Points specifically to your dbt binary and profile folder
        bash_command=f"{VENV_DBT} run --profiles-dir /home/khalidabdelrazk/.dbt",
    )

    ingest_data >> dbt_transform