# ==============================================
# TrabalhoSBD2 - Airflow with Spark Support (Python 3.11)
# ==============================================
FROM apache/airflow:2.9.1-python3.11

# ==============================================
# SYSTEM DEPENDENCIES
# ==============================================
USER root

# Instala Java 11 e deps do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    wget \
    curl \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# ==============================================
# PYTHON DEPENDENCIES
# ==============================================
USER airflow
WORKDIR /opt/airflow

# Instala dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ==============================================
# SPARK CONFIGURATION
# ==============================================
# Ajusta SPARK_HOME para o site-packages do Python 3.11
ENV SPARK_HOME=/home/airflow/.local/lib/python3.11/site-packages/pyspark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3
# (opcional, ajuda em ambientes com warning de hostname)
ENV SPARK_LOCAL_IP=127.0.0.1

# Cria link de compatibilidade em /opt/spark
USER root
RUN mkdir -p /opt && \
    ln -sf /home/airflow/.local/lib/python3.11/site-packages/pyspark /opt/spark

# ==============================================
# FINAL SETUP
# ==============================================
USER airflow

# PYTHONPATH do projeto
ENV PYTHONPATH="/opt/airflow/spark_config:/opt/airflow/base_dados:/opt/airflow/dags:/opt/airflow/plugins"

# ==============================================
# DIRECTORY STRUCTURE & PERMISSIONS
# ==============================================
USER root
RUN mkdir -p /opt/airflow/{dags,logs,plugins,config,base_dados,Resultados,spark_config,notebooks,silver} && \
    chown -R airflow:0 /opt/airflow && \
    chmod -R 777 /opt/airflow/{logs,Resultados,silver,notebooks,base_dados,spark_config}

# entrypoint customizado
COPY entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

# volta para o usuário airflow
USER airflow

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/custom-entrypoint.sh"]
