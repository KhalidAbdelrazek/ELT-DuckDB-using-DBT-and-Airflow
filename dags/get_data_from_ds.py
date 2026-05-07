import kagglehub
from kagglehub import KaggleDatasetAdapter
from airflow import DAG
from airflow.operators.python import PythonOperator 


def get_data():
    # Set the path to the file you'd like to load
    file_path = "../../data/raw/olist_orders_dataset.csv"

    # Load the latest version
    df = kagglehub.load_dataset(
    KaggleDatasetAdapter.PANDAS,
    "olistbr/brazilian-ecommerce",
    file_path,
    # Provide any additional arguments like 
    # sql_query or pandas_kwargs. See the 
    # documenation for more information:
    # https://github.com/Kaggle/kagglehub/blob/main/README.md#kaggledatasetadapterpandas
    )

    print("First 5 records:", df.head())



dag = DAG(
    dag_id="get_data_from_ds",
    start_date="2022-01-01",
    schedule=None,
)

get_data = PythonOperator(
    task_id="get_data",
    python_callable=get_data,
    dag=dag,
)


