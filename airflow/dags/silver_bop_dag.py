"""
DAG para executar análise Silver do BOP usando PySpark
Executa o notebook de análise silver/bop_analysis.ipynb
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import papermill as pm
import os

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

def execute_silver_notebook():
    """Executa o notebook de análise silver usando papermill"""
    input_notebook = '/opt/airflow/silver/bop_analysis.ipynb'
    output_notebook = f'/opt/airflow/silver/outputs/silver_bop_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    # Verificar se o arquivo de input existe
    if not os.path.exists(input_notebook):
        raise FileNotFoundError(f"Notebook não encontrado: {input_notebook}")
    
    # Executar notebook
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name='python3'
    )
    print(f"Notebook executado com sucesso!")
    print(f"Output salvo em: {output_notebook}")

with DAG(
    'silver_bop_analysis',
    default_args=default_args,
    description='Análise Silver de dados BOP com PySpark',
    schedule_interval='0 3 * * *',
    start_date=datetime(2025, 10, 9),
    catchup=False,
    tags=['silver', 'bop', 'analysis', 'pyspark'],
) as dag:

    task_check_input = BashOperator(
        task_id='check_bop_csv_exists',
        bash_command='test -f /opt/airflow/base_dados/Resultados/BOP.csv && echo "BOP.csv found!" || exit 1',
    )

    task_execute_notebook = PythonOperator(
        task_id='execute_silver_notebook',
        python_callable=execute_silver_notebook,
    )

    task_validate = BashOperator(
        task_id='validate_execution',
        bash_command='echo "Silver BOP analysis completed successfully!"',
    )

    task_check_input >> task_execute_notebook >> task_validate
