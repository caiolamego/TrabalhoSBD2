"""
DAG para executar o notebook de coleta de dados ER (Exchange Rate)
Executa diariamente às 2:15 AM
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
    input_notebook = '/opt/airflow/base_dados/ER/2_coleta.ipynb'
    output_notebook = f'/opt/airflow/Resultados/ER_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name='python3'
    )
    print(f"Notebook executado com sucesso! Output: {output_notebook}")

with DAG(
    'er_data_collection',
    default_args=default_args,
    description='Coleta diária de dados de Taxa de Câmbio do FMI',
    schedule_interval='15 2 * * *',  # Executa diariamente às 2:15 AM
    start_date=datetime(2025, 10, 7),
    catchup=False,
    tags=['data-collection', 'exchange-rate', 'fmi'],
) as dag:

    task_execute_notebook = PythonOperator(
        task_id='execute_er_notebook',
        python_callable=execute_notebook,
    )

    task_check_output = BashOperator(
        task_id='check_er_output',
        bash_command='ls -lh /opt/airflow/Resultados/ER.csv',
    )

    task_execute_notebook >> task_check_output
