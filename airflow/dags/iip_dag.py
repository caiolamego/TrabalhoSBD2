"""
DAG para executar o notebook de coleta de dados IIP (International Investment Position)
Executa diariamente às 2:30 AM
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import papermill as pm

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

def execute_notebook():
    """Executa o notebook usando papermill"""
    input_notebook = '/opt/airflow/data_layer/raw/IIP/2_coleta.ipynb'
    output_notebook = f'/opt/airflow/data_layer/raw/Resultados/IIP_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name='python3'
    )
    print(f"Notebook executado com sucesso! Output: {output_notebook}")

with DAG(
    'iip_data_collection',
    default_args=default_args,
    description='Coleta diária de dados IIP do FMI',
    schedule_interval='30 2 * * *',  # Executa diariamente às 2:30 AM
    start_date=datetime(2025, 10, 7),
    catchup=False,
    tags=['data-collection', 'iip', 'fmi'],
) as dag:

    task_execute_notebook = PythonOperator(
        task_id='execute_iip_notebook',
        python_callable=execute_notebook,
    )

    task_check_output = BashOperator(
        task_id='check_iip_output',
        bash_command='ls -lh /opt/airflow/data_layer/raw/Resultados/IIP.csv',
    )

    task_execute_notebook >> task_check_output
