"""
DAG para executar transformação Silver to Gold
Executa o notebook transformer/job_etl/silver_gold.ipynb
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

def execute_silver_gold_notebook():
    """Executa o notebook de transformação silver to gold usando papermill"""
    input_notebook = '/opt/airflow/transformer/job_etl/silver_gold.ipynb'
    output_dir = '/opt/airflow/data_layer/raw/Resultados'
    output_notebook = f'{output_dir}/silver_gold_executed_{datetime.now().strftime("%Y%m%d_%H%M%S")}.ipynb'
    
    # Garantir que o diretório de output existe com permissões corretas
    os.makedirs(output_dir, mode=0o777, exist_ok=True)
    
    # Verificar se o arquivo de input existe
    if not os.path.exists(input_notebook):
        raise FileNotFoundError(f"Notebook não encontrado: {input_notebook}")
    
    # Verificar permissões do diretório de output
    if not os.access(output_dir, os.W_OK):
        print(f"⚠️  AVISO: Diretório {output_dir} sem permissão de escrita!")
        print(f"   Tentando ajustar permissões...")
        try:
            os.chmod(output_dir, 0o777)
        except Exception as e:
            print(f"   ❌ Não foi possível ajustar permissões: {e}")
    
    # Executar notebook
    print(f"📔 Input:  {input_notebook}")
    print(f"📄 Output: {output_notebook}")
    
    pm.execute_notebook(
        input_notebook,
        output_notebook,
        kernel_name="python3"
    )
    
    print(f"✅ Notebook executado com sucesso!")
    print(f"📁 Output salvo em: {output_notebook}")

with DAG(
    "silver_to_gold_transformation",
    default_args=default_args,
    description="Transformação de dados da camada Silver para Gold",
    schedule_interval="0 5 * * *",  # Executa diariamente às 5:00 AM (após bronze_silver)
    start_date=datetime(2025, 11, 6),
    catchup=False,
    tags=["gold", "silver", "transformation"],
) as dag:

    task_check_prerequisites = BashOperator(
        task_id="check_prerequisites",
        bash_command="echo \"Verificando pré-requisitos...\" && test -f /opt/airflow/transformer/job_etl/silver_gold.ipynb && echo \"Notebook encontrado!\"",
    )

    task_execute_notebook = PythonOperator(
        task_id="execute_silver_gold_notebook",
        python_callable=execute_silver_gold_notebook,
    )

    task_validate = BashOperator(
        task_id="validate_execution",
        bash_command="echo \"Transformação Silver to Gold concluída com sucesso!\"",
    )

    task_check_prerequisites >> task_execute_notebook >> task_validate
