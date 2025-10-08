FROM apache/airflow:2.7.3-python3.11

USER root

# Instalar dependências do sistema se necessário
RUN apt-get update && apt-get install -y --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Instalar pacotes Python necessários
RUN pip install --no-cache-dir \
    sdmx1 \
    pandas \
    papermill \
    ipykernel \
    jupyter
