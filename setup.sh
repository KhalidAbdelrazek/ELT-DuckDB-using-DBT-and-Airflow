#!/bin/bash

# ============================================================
#  Data Stack Setup: Airflow 3.1.0 + dbt + DuckDB
#  Project-specific, local-only, handles spaces in paths.
# ============================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths (Quoted for safety)
PROJECT_ROOT="$(pwd)"
VENV_DIR="$PROJECT_ROOT/.venv"
export AIRFLOW_HOME="$PROJECT_ROOT/airflow_home"
DBT_PROJECT_DIR="$PROJECT_ROOT/dbt_project"
DB_FILE="$PROJECT_ROOT/warehouse.duckdb"

print_step()    { echo -e "\n${BLUE}━━━ STEP $1: $2 ━━━${NC}"; }
print_success() { echo -e "${GREEN}  ✔  $1${NC}"; }

clear
echo -e "${GREEN}Initializing Modern Data Stack in: $PROJECT_ROOT${NC}"

# 1. Cleanup
print_step "1" "Cleaning old processes"
pkill -9 -f "airflow" 2>/dev/null || true

# 2. Virtual Env
print_step "2" "Setting up Python Environment"
PYTHON_BIN="python3"
PY_VER=$("$PYTHON_BIN" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

if [ ! -d "$VENV_DIR" ]; then
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

PIP="$VENV_DIR/bin/pip"
"$PIP" install --upgrade pip --quiet

# 3. Install Airflow, dbt, and DuckDB
print_step "3" "Installing Dependencies"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-3.1.0/constraints-${PY_VER}.txt"

# Strategy: Install dbt and Airflow together first so pip can resolve shared dependencies
# We move the constraint to the end or omit it for the shared packages
"$PIP" install \
    "apache-airflow==3.1.0" \
    "dbt-core" \
    "dbt-duckdb" \
    "duckdb"

# Now, "mop up" any missing Airflow providers using the constraint file
"$PIP" install "apache-airflow[amazon,google,postgres,http]==3.1.0" --constraint "$CONSTRAINT_URL"

# 4. Workspace Structure
print_step "4" "Creating Folder Structure"
mkdir -p "$AIRFLOW_HOME/dags" 
mkdir -p "$AIRFLOW_HOME/logs"
mkdir -p "$DBT_PROJECT_DIR"

# 5. dbt Profile Setup (Local)
# This creates a profiles.yml so dbt knows how to talk to your DuckDB file
print_step "5" "Configuring dbt Profile"
mkdir -p ~/.dbt # dbt looks here by default, but we can point it elsewhere
cat > "$PROJECT_ROOT/profiles.yml" << EOF
local_duckdb:
  outputs:
    dev:
      type: duckdb
      path: '$DB_FILE'
      threads: 4
  target: dev
EOF

# 6. Activation Script
print_step "6" "Creating Helper Script"
cat > "activate_project.sh" << EOF
export AIRFLOW_HOME="$AIRFLOW_HOME"
export DBT_PROFILES_DIR="$PROJECT_ROOT"
source "$VENV_DIR/bin/activate"
echo "--- Environment Activated ---"
echo "AIRFLOW_HOME: \$AIRFLOW_HOME"
echo "DBT_PROFILES_DIR: \$DBT_PROFILES_DIR"
echo "DUCKDB_PATH: $DB_FILE"
EOF
chmod +x "activate_project.sh"

# 7. Launch Airflow
print_step "7" "Launching Airflow Standalone"
export DBT_PROFILES_DIR="$PROJECT_ROOT"
exec "$VENV_DIR/bin/airflow" standalone