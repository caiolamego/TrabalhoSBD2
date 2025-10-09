# ==============================================
# TrabalhoSBD2 - Airflow with Spark Support
# ==============================================
FROM apache/airflow:2.9.1-python3.12

# ==============================================
# SYSTEM DEPENDENCIES
# ==============================================
USER root

# Install Java 17 and system dependencies for Spark
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

# Set working directory
WORKDIR /opt/airflow

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ==============================================
# SPARK CONFIGURATION
# ==============================================
# Configure Spark environment variables
ENV SPARK_HOME=/home/airflow/.local/lib/python3.12/site-packages/pyspark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# Create Spark compatibility links
USER root
RUN mkdir -p /opt && \
    ln -sf /home/airflow/.local/lib/python3.12/site-packages/pyspark /opt/spark

# ==============================================
# FINAL SETUP
# ==============================================
USER airflow

# Set Python path to include project modules
ENV PYTHONPATH="/opt/airflow/spark_config:/opt/airflow/base_dados:/opt/airflow/dags:/opt/airflow/plugins"

# Create necessary directories
RUN mkdir -p /opt/airflow/{dags,logs,plugins,config,base_dados,Resultados,spark_config,notebooks}

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
