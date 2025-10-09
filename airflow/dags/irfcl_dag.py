"""
DAG para executar o notebook de coleta de dados IRFCL (International Reserves and Foreign Currency Liquidity)
Executa diariamente às 2:45 AM
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
    input_notebook = '/opt/airflow/base_dados/IRFCL/2_coleta.ipynb'
    output_notebook = f'/opt/airflow/Resultados/IRFCL_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name='python3'
    )
    print(f"Notebook executado com sucesso! Output: {output_notebook}")

with DAG(
    'irfcl_data_collection',
    default_args=default_args,
    description='Coleta diária de dados IRFCL do FMI',
    schedule_interval='45 2 * * *',  # Executa diariamente às 2:45 AM
    start_date=datetime(2025, 10, 7),
    catchup=False,
    tags=['data-collection', 'irfcl', 'fmi'],
) as dag:

    task_execute_notebook = PythonOperator(
        task_id='execute_irfcl_notebook',
        python_callable=execute_notebook,
    )

    task_check_output = BashOperator(
        task_id='check_irfcl_output',
        bash_command='ls -lh /opt/airflow/Resultados/IRFCL.csv',
    )

    task_execute_notebook >> task_check_output
