"""
Configuração otimizada do PySpark para análise de dados bancários
Configurações adaptadas para datasets de tamanho médio (até 500K registros)
"""

import os
import logging

# Configurar variáveis de ambiente do Spark - PySpark via pip
os.environ['JAVA_HOME'] = '/usr/lib/jvm/java-17-openjdk-amd64'
os.environ['PYSPARK_PYTHON'] = 'python3'
os.environ['PYSPARK_DRIVER_PYTHON'] = 'python3'

# Tentar diferentes localizações do Spark
spark_locations = [
    '/opt/spark',
    '/opt/airflow/.local/lib/python3.11/site-packages/pyspark'
]

for location in spark_locations:
    if os.path.exists(location):
        os.environ['SPARK_HOME'] = location
        break

# Inicializar findspark se disponível e necessário
try:
    import findspark
    if 'SPARK_HOME' in os.environ:
        findspark.init(os.environ['SPARK_HOME'])
except ImportError:
    pass

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SparkConfig:
    """Classe para configuração e inicialização do Spark"""
    
    def __init__(self, app_name="BancoDataAnalysis", local_cores="*"):
        self.app_name = app_name
        self.local_cores = local_cores
        self.spark = None
        
    def create_spark_session(self, memory_fraction=0.8, max_result_size="2g"):
        """
        Cria uma sessão Spark otimizada para análise de dados
        
        Args:
            memory_fraction: Fração da memória para cache (padrão: 0.8)
            max_result_size: Tamanho máximo dos resultados (padrão: 2g)
        """
        try:
            # Configurações otimizadas para análise de dados bancários
            spark_config = {
                "spark.app.name": self.app_name,
                "spark.master": f"local[{self.local_cores}]",
                "spark.sql.adaptive.enabled": "true",
                "spark.sql.adaptive.coalescePartitions.enabled": "true",
                "spark.sql.adaptive.coalescePartitions.minPartitionNum": "1",
                "spark.sql.adaptive.coalescePartitions.initialPartitionNum": "200",
                "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
                "spark.sql.execution.arrow.pyspark.enabled": "true",
                "spark.sql.execution.arrow.pyspark.fallback.enabled": "true",
                "spark.driver.memory": "4g",
                "spark.driver.maxResultSize": max_result_size,
                "spark.sql.shuffle.partitions": "200",
                "spark.storage.memoryFraction": str(memory_fraction),
                "spark.sql.adaptive.skewJoin.enabled": "true",
                "spark.sql.adaptive.localShuffleReader.enabled": "true",
                "spark.sql.files.maxPartitionBytes": "134217728",  # 128MB
                "spark.sql.files.openCostInBytes": "4194304",      # 4MB
                # Configurações específicas para CSV
                "spark.sql.csv.filterPushdown.enabled": "true",
                "spark.sql.parquet.filterPushdown": "true",
                "spark.sql.parquet.mergeSchema": "false",
                # Otimizações de performance
                "spark.sql.adaptive.advisoryPartitionSizeInBytes": "64MB",
                "spark.sql.adaptive.coalescePartitions.parallelismFirst": "true"
            }
            
            # Criar SparkSession builder
            builder = SparkSession.builder
            
            # Aplicar configurações
            for key, value in spark_config.items():
                builder = builder.config(key, value)
            
            # Criar sessão
            self.spark = builder.getOrCreate()
            
            # Configurar nível de log
            self.spark.sparkContext.setLogLevel("WARN")
            
            logger.info(f"Spark Session criada: {self.app_name}")
            logger.info(f"Spark UI disponível em: {self.spark.sparkContext.uiWebUrl}")
            
            return self.spark
            
        except Exception as e:
            logger.error(f"Erro ao criar Spark Session: {str(e)}")
            raise
    
    def get_session(self):
        """Retorna a sessão Spark ativa ou cria uma nova"""
        if self.spark is None:
            return self.create_spark_session()
        return self.spark
    
    def stop_session(self):
        """Para a sessão Spark"""
        if self.spark:
            self.spark.stop()
            logger.info("Spark Session finalizada")
    
    def configure_for_banking_data(self):
        """Configurações específicas para dados bancários"""
        if self.spark:
            # Configurar timezone para dados financeiros
            self.spark.conf.set("spark.sql.session.timeZone", "UTC")
            # Configurar formato de data padrão
            self.spark.conf.set("spark.sql.timestampFormat", "yyyy-MM-dd HH:mm:ss")
            self.spark.conf.set("spark.sql.dateFormat", "yyyy-MM-dd")

class DataSchemas:
    """Esquemas pré-definidos para os dados bancários"""
    
    @staticmethod
    def bop_schema():
        """Schema para dados BOP (Balance of Payments)"""
        return StructType([
            StructField("COUNTRY", StringType(), True),
            StructField("BOP_ACCOUNTING_ENTRY", StringType(), True),
            StructField("INDICATOR", StringType(), True),
            StructField("UNIT", StringType(), True),
            StructField("FREQUENCY", StringType(), True),
            StructField("TIME_PERIOD", StringType(), True),
            StructField("value", DoubleType(), True),
            StructField("index", StringType(), True)
        ])
    
    @staticmethod
    def er_schema():
        """Schema para dados ER (Exchange Rate)"""
        return StructType([
            StructField("COUNTRY", StringType(), True),
            StructField("INDICATOR", StringType(), True),
            StructField("UNIT", StringType(), True),
            StructField("FREQUENCY", StringType(), True),
            StructField("TIME_PERIOD", StringType(), True),
            StructField("value", DoubleType(), True),
            StructField("index", StringType(), True)
        ])
    
    @staticmethod
    def iip_schema():
        """Schema para dados IIP (International Investment Position)"""
        return StructType([
            StructField("COUNTRY", StringType(), True),
            StructField("IIP_ACCOUNTING_ENTRY", StringType(), True),
            StructField("INDICATOR", StringType(), True),
            StructField("UNIT", StringType(), True),
            StructField("FREQUENCY", StringType(), True),
            StructField("TIME_PERIOD", StringType(), True),
            StructField("value", DoubleType(), True),
            StructField("index", StringType(), True)
        ])
    
    @staticmethod
    def irfcl_schema():
        """Schema para dados IRFCL (International Reserves and Foreign Currency Liquidity)"""
        return StructType([
            StructField("COUNTRY", StringType(), True),
            StructField("INDICATOR", StringType(), True),
            StructField("UNIT", StringType(), True),
            StructField("FREQUENCY", StringType(), True),
            StructField("TIME_PERIOD", StringType(), True),
            StructField("value", DoubleType(), True),
            StructField("index", StringType(), True)
        ])

def get_banking_spark_session(app_name="BankingDataAnalysis"):
    """
    Função utilitária para obter uma sessão Spark configurada para dados bancários
    
    Returns:
        SparkSession: Sessão Spark configurada
    """
    config = SparkConfig(app_name)
    spark = config.create_spark_session()
    config.configure_for_banking_data()
    return spark

# Funções utilitárias para leitura de dados
def read_banking_csv(spark, file_path, schema=None, header=True):
    """
    Lê arquivo CSV com configurações otimizadas para dados bancários
    
    Args:
        spark: SparkSession
        file_path: Caminho para o arquivo CSV
        schema: Schema pré-definido (opcional)
        header: Se o arquivo tem cabeçalho (padrão: True)
    
    Returns:
        DataFrame: DataFrame Spark
    """
    reader = spark.read.format("csv") \
        .option("header", str(header).lower()) \
        .option("inferSchema", "true" if schema is None else "false") \
        .option("timestampFormat", "yyyy-MM-dd HH:mm:ss") \
        .option("dateFormat", "yyyy-MM-dd") \
        .option("multiline", "true") \
        .option("escape", '"') \
        .option("nullValue", "") \
        .option("emptyValue", "")
    
    if schema:
        reader = reader.schema(schema)
    
    return reader.load(file_path)