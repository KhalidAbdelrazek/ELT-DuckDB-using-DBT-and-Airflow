# Olist E-Commerce ELT Pipeline

An end-to-end ELT (Extract, Load, Transform) data pipeline leveraging the Brazilian E-Commerce Public Dataset by Olist. The pipeline orchestrates the ingestion of raw CSV files into a local DuckDB data warehouse, and uses dbt (Data Build Tool) to model the data into robust analytical marts, all orchestrated through Apache Airflow.

## Project Overview

This project simulates a modern data stack fully localized on a single machine. It demonstrates key data engineering patterns:
- **Scalable Ingestion**: Idempotent Python scripts that dynamically load new CSV datasets into a local DuckDB warehouse.
- **Robust Transformation**: Dedicated dbt layers (Staging -> Marts) utilizing best practices to build a comprehensive star schema and fact/dimension tables.
- **Reliable Orchestration**: Apache Airflow DAGs that manage job dependencies and define a clear, scheduled execution flow.

## Architecture

The pipeline follows an ELT architecture, with DuckDB serving as the core engine.

```mermaid
flowchart LR
    subgraph Data Sources
        CSV(Olist CSV Files)
    end
    
    subgraph Ingestion
        Python[Python Ingestion Script]
    end

    subgraph Data Warehouse: DuckDB
        Raw(Raw Tables)
        Staging(Staging Layer - dbt)
        Marts(Marts Layer - dbt)
    end

    CSV -- "Read & Clean\nvia Pandas" --> Python
    Python -- "Insert via \nDuckDB Conn" --> Raw
    Raw -- "Transform \nvia dbt" --> Staging
    Staging -- "Aggregate & \nJoin via dbt" --> Marts
    
    subgraph Orchestration
        Airflow((Apache Airflow))
    end
    
    Airflow -.->|"1. Triggers Ingestion"| Python
    Airflow -.->|"2. Triggers Transforms"| Staging
```

## Setup Instructions

### 1. Environment Setup
To isolate the project's dependencies, create and activate a Python virtual environment, then install the necessary packages.

```bash
# Create the virtual environment
python3 -m venv .venv

# Activate the virtual environment
source .venv/bin/activate

# Install the required packages
pip install -r requirements.txt
```

### 2. Configure dbt Profile
Ensure your `~/.dbt/profiles.yml` is configured to target DuckDB for this project. Use the `ecommerce_platform` profile layout out below:

```yaml
ecommerce_platform:
  outputs:
    dev:
      type: duckdb
      # Update path to point to your local DuckDB database file
      path: /home/khalidabdelrazk/data engineer/e-commerce/DataBase.duckdb 
      threads: 4
  target: dev
```

## Orchestration & Pipeline Details

### DAG: `olist_end_to_end_pipeline`
The core Airflow DAG (`dags/olist_end_to_end_pipeline.py`) manages the end-to-end data build process. It consists of two primary tasks:
1. **`ingest_csv_to_duckdb`** (BashOperator): Executes the Python ingestion application (`ingestion/main.py`) to systematically parse, clean, and load new data into DuckDB.
2. **`dbt_run_transformations`** (BashOperator): Initiates the dbt build process (`dbt run`). It pulls the staging tables, applies SQL transformations, and materializes downstream data models.

*Execution Flow*: `ingest_csv_to_duckdb` >> `dbt_run_transformations`

### Pipeline Orchestration
> **Proof of Work:** Airflow DAG execution confirming successful end-to-end task chaining and successes.
![Airflow DAG](screenshots/airflow_dag.png)

## Data Model

The final dbt schema conforms to a Star Schema architecture designed to empower BI tools and reporting services.

### Core Fact Tables
- **`fct_sales_comprehensive`**: The unified fact table aggregating comprehensive metrics for orders, payment, freight, and geolocation metrics per sale.
- **`fact_order_items`**: A granular fact table capturing line-item level details of order transactions.

### Key Dimension Tables
- **`dim_products`**: Core dimensions (category, sizes) describing purchased goods.
- **`dim_customers`**: Dimensional reference for user context and demographics.
- **`dim_sellers`**: Metrics specific to the seller listing the products.
- **`dim_geolocation`**: Geographic location entities across Brazil (zip code, city, state).
- **`dim_orders`**: Order-level statuses, approval, and shipment delivery timestamps.
- **`dim_payments`**: Represents order transaction methods (Credit Card, Boleto) and sequences.
- **`dim_reviews`**: Review-level scoring and commentary tied to customer satisfaction.

### Data Lineage
> **Proof of Work:** dbt lineage graph demonstrating the seamless transformation dependencies flowing from `stg_orders` and other staging models directly into the `fct_sales_comprehensive` mart.
![dbt Lineage](screenshots/dbt_lineage.png)

### The Resulting Data
> **Proof of Work:** A direct query preview of the `fct_sales_comprehensive` table securely functioning inside DuckDB, observed utilizing DBeaver or an identical database explorer.
![Data in DBeaver](screenshots/dbeaver_data.png)

### Database ER Diagram
> **Proof of Work:** An Entity-Relationship (ER) diagram generated from DBeaver showing the relationships between the tables in your data warehouse.
![DBeaver ER Diagram](screenshots/dbeaver_diagram.png)
