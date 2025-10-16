import logging
import os

try:
    from airflow.providers.postgres.hooks.postgres import PostgresHook
    AIRFLOW_AVAILABLE = True
except ImportError:
    AIRFLOW_AVAILABLE = False


def get_postgres_conn(conn_id: str = "postgres_default") -> str:
    """
    Get PostgreSQL connection string.
    
    Works in two modes:
    1. Airflow mode: Uses PostgresHook to get connection from Airflow
    2. Manual mode: Uses environment variables or default values
    
    Args:
        conn_id: Airflow connection ID to use. Options:
                 - "postgres_default": Main Airflow database (default)
                 - "postgres_dw": Data Warehouse database
    
    Returns:
        str: PostgreSQL connection string in format:
             "dbname=X user=Y password=Z host=W port=P"
    """
    # Check if running in Airflow
    if AIRFLOW_AVAILABLE and 'AIRFLOW_HOME' in os.environ:
        try:
            hook = PostgresHook(postgres_conn_id=conn_id)
            conn = hook.get_conn()
            schema = conn.info.dbname
            logging.info(
                f"[postgres_helpers] Obtained PostgreSQL connection from Airflow (conn_id={conn_id}): "
                f"dbname={schema}, user={conn.info.user}, "
                f"host={conn.info.host}, port={conn.info.port}"
            )
            return (
                f"dbname={schema} user={conn.info.user} password={conn.info.password} "
                f"host={conn.info.host} port={conn.info.port}"
            )
        except Exception as e:
            logging.error(f"Failed to obtain PostgreSQL connection from Airflow (conn_id={conn_id}): {e}")
            logging.warning("Falling back to environment variables...")
            # Fall through to manual mode
    
    # Running manually or fallback - use environment variables or defaults
    # Map connection IDs to environment variables
    if conn_id == "postgres_dw":
        dbname = os.getenv('POSTGRES_DW_DB', 'data_warehouse')
        user = os.getenv('POSTGRES_DW_USER', 'dw_user')
        password = os.getenv('POSTGRES_DW_PASSWORD', 'dw_password')
    else:  # postgres_default
        dbname = os.getenv('POSTGRES_DB', 'airflow')
        user = os.getenv('POSTGRES_USER', 'airflow')
        password = os.getenv('POSTGRES_PASSWORD', 'airflow')
    
    # Host and port are the same for all connections
    host = os.getenv('POSTGRES_HOST', 'postgres')  # Changed default to 'postgres' for Docker
    port = os.getenv('POSTGRES_PORT', '5432')      # Changed default to internal port
    
    logging.info(
        f"[postgres_helpers] Using manual PostgreSQL connection (conn_id={conn_id}): "
        f"dbname={dbname}, user={user}, host={host}, port={port}"
    )
    
    return (
        f"dbname={dbname} user={user} password={password} "
        f"host={host} port={port}"
    )
