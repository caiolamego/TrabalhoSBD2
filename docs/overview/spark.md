## Processamento de Dados (Spark)

* Execução distribuída em cluster Spark local
* Transformações estatísticas e temporais
* Detecção automática de outliers
* Enriquecimento de dados e agregações
* Exportação para múltiplos formatos (Parquet, CSV, JSON)

Exemplo simplificado:

```python
from spark_config.config import get_banking_spark_session
import pyspark.sql.functions as F

spark = get_banking_spark_session("Analise_FMI")

df = spark.read.csv("/opt/airflow/base_dados/Resultados/BOP.csv", header=True, inferSchema=True)

result = (df.groupBy("COUNTRY")
          .agg(F.sum("VALUE").alias("total_valor"),
               F.avg("VALUE").alias("media_valor"))
          .orderBy(F.desc("total_valor")))

result.show(10, truncate=False)
spark.stop()
```