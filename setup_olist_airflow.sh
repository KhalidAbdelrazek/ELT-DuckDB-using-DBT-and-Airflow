#!/bin/bash

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths - Using your existing .venv and project location
PROJECT_ROOT="/home/khalidabdelrazk/data engineer/e-commerce"
VENV_BIN="$PROJECT_ROOT/.venv/bin"
export AIRFLOW_HOME="$HOME/airflow"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPTIMIZING AIRFLOW FOR LOCAL OLIST PROJECT ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1. Kill old processes
print_info() { echo -e "${GREEN}➜ $1${NC}"; }
pkill -9 -f "airflow" 2>/dev/null || true
rm -f "$AIRFLOW_HOME"/airflow-*.pid 2>/dev/null || true

# 2. Fix Dependencies (The structlog error fix)
print_info "Fixing structlog dependency and installing Cosmos..."
"$VENV_BIN/pip" install "structlog<24.1.0" astronomer-cosmos dbt-duckdb --quiet

# 3. Initialize Folders
mkdir -p "$AIRFLOW_HOME/dags"

# 4. Set Environment Variables for Local Use
# We remove the Codespace URL logic and use local binding
export AIRFLOW__API__HOST="127.0.0.1"
export AIRFLOW__WEBSERVER__EXPOSE_CONFIG="True"

# 5. Create/Update the Olist DAG file
print_info "Creating Olist ELT DAG in $AIRFLOW_HOME/dags..."
cat > "$AIRFLOW_HOME/dags/olist_elt_pipeline.py" << EOF
from datetime import datetime
from pathlib import Path
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import DuckDBConnectionProfileConfig

DBT_PROJECT_PATH = Path("$PROJECT_ROOT/dbt/dbt_transformations")

profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=DuckDBConnectionProfileConfig(
        path=str(DBT_PROJECT_PATH / "Datawarehouse.duckdb"),
    ),
)

olist_dag = DbtDag(
    project_config=ProjectConfig(DBT_PROJECT_PATH),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path="$VENV_BIN/dbt",
    ),
    operator_args={
        "install_deps": True,
        "threads": 1,
    },
    schedule_interval="@daily",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    dag_id="olist_elt_pipeline",
)
EOF

print_info "Setup Complete."
echo -e "${GREEN}Launch command:${NC} source .venv/bin/activate && airflow standalone"