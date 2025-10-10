import logging
import os

try:
    from airflow.providers.postgres.hooks.postgres import PostgresHook
    AIRFLOW_AVAILABLE = True
except ImportError:
    AIRFLOW_AVAILABLE = False


def get_postgres_conn() -> str:
    """
    Get PostgreSQL connection string.
    
    Works in two modes:
    1. Airflow mode: Uses PostgresHook to get connection from Airflow
    2. Manual mode: Uses environment variables or default values
    
    Returns:
        str: PostgreSQL connection string in format:
             "dbname=X user=Y password=Z host=W port=P"
    """
    # Check if running in Airflow
    if AIRFLOW_AVAILABLE and 'AIRFLOW_HOME' in os.environ:
        try:
            hook = PostgresHook(postgres_conn_id="postgres_default")
            conn = hook.get_conn()
            schema = conn.info.dbname
            logging.info(
                f"[postgres_helpers] Obtained PostgreSQL connection from Airflow: "
                f"dbname={schema}, user={conn.info.user},"
                f"host={conn.info.host}, port={conn.info.port}"
            )
            return (
                f"dbname={schema} user={conn.info.user} password={conn.info.password} "
                f"host={conn.info.host} port={conn.info.port}"
            )
        except Exception as e:
            logging.error(f"Failed to obtain PostgreSQL connection from Airflow: {e}")
            raise
    else:
        # Running manually - use environment variables or defaults
        dbname = os.getenv('POSTGRES_DB', 'airflow')
        user = os.getenv('POSTGRES_USER', 'airflow')
        password = os.getenv('POSTGRES_PASSWORD', 'airflow')
        host = os.getenv('POSTGRES_HOST', 'localhost')
        port = os.getenv('POSTGRES_PORT', '5432')
        
        logging.info(
            f"[postgres_helpers] Using manual PostgreSQL connection: "
            f"dbname={dbname}, user={user}, host={host}, port={port}"
        )
        
        return (
            f"dbname={dbname} user={user} password={password} "
            f"host={host} port={port}"
        )
