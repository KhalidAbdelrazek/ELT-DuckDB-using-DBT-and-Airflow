from datetime import datetime
from pathlib import Path
from airflow import DAG
from airflow.operators.bash import BashOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig

# 1. PATH CONFIGURATION
PROJECT_ROOT = Path("/home/khalidabdelrazk/data engineer/e-commerce")
DBT_ROOT = PROJECT_ROOT / "dbt" / "dbt_transformations"
VENV_PYTHON = PROJECT_ROOT / ".venv" / "bin" / "python"
VENV_DBT = PROJECT_ROOT / ".venv" / "bin" / "dbt"

# 2. PROFILE CONFIGURATION
profile_config = ProfileConfig(
    profile_name="ecommerce_platform",
    target_name="dev",
    profiles_yml_filepath=Path("/home/khalidabdelrazk/.dbt/profiles.yml"),
)

with DAG(
    dag_id="olist_end_to_end_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    # TASK 1: INGESTION
    ingest_data = BashOperator(
        task_id="ingest_csv_to_duckdb",
        # Added 'cwd' (Current Working Directory)
        cwd=str(PROJECT_ROOT / "ingestion"), 
        bash_command=f"'{VENV_PYTHON}' main.py",
    )

    # TASK 2: DBT TRANSFORMATIONS
    dbt_transform = BashOperator(
        task_id="dbt_run_transformations",
        # Added 'cwd' here as well for safety
        cwd=str(DBT_ROOT),
        bash_command=f"'{VENV_DBT}' run --profiles-dir /home/khalidabdelrazk/.dbt",
    )

    ingest_data >> dbt_transform