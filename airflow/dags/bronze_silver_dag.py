"""
DAG para executar transformação Bronze to Silver
Executa o notebook silver/bronze_silver.ipynb
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import papermill as pm
import os

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

def execute_bronze_silver_notebook():
    """Executa o notebook de transformação bronze to silver usando papermill"""
    input_notebook = '/opt/airflow/silver/bronze_silver.ipynb'
    output_notebook = f'/opt/airflow/Resultados/bronze_silver_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    # Verificar se o arquivo de input existe
    if not os.path.exists(input_notebook):
        raise FileNotFoundError(f"Notebook não encontrado: {input_notebook}")
    
    # Executar notebook
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name="python3"
    )
    print(f"Notebook executado com sucesso!")
    print(f"Output salvo em: {output_notebook}")

with DAG(
    "bronze_to_silver_transformation",
    default_args=default_args,
    description="Transformação de dados da camada Bronze para Silver",
    schedule_interval="0 4 * * *",
    start_date=datetime(2025, 10, 11),
    catchup=False,
    tags=["silver", "bronze", "transformation"],
) as dag:

    task_check_prerequisites = BashOperator(
        task_id="check_prerequisites",
        bash_command="echo \"Verificando pré-requisitos...\" && test -f /opt/airflow/silver/bronze_silver.ipynb && echo \"Notebook encontrado!\"",
    )

    task_execute_notebook = PythonOperator(
        task_id="execute_bronze_silver_notebook",
        python_callable=execute_bronze_silver_notebook,
    )

    task_validate = BashOperator(
        task_id="validate_execution",
        bash_command="echo \"Transformação Bronze to Silver concluída com sucesso!\"",
    )

    task_check_prerequisites >> task_execute_notebook >> task_validate
