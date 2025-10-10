#!/bin/bash
# ==============================================
# PostgreSQL Initialization Script
# TrabalhoSBD2 - Data Warehouse Setup
# ==============================================
set -e

echo "🚀 Iniciando configuração do banco de dados..."
echo "📊 Usuário: $POSTGRES_USER | Banco principal: $POSTGRES_DB"

# Aguardar o PostgreSQL estar pronto
until psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c '\q' 2>/dev/null; do
  echo "⏳ Aguardando PostgreSQL..."
  sleep 1
done

echo "✅ PostgreSQL pronto!"

# Criar banco de dados data_warehouse e usuário
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  -- Criando banco de dados para o Data Warehouse (se não existir)
  SELECT 'CREATE DATABASE data_warehouse'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'data_warehouse')\gexec
  
  -- Criando usuário específico para o Data Warehouse (se não existir)
  DO \$\$
  BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'dw_user') THEN
      CREATE USER dw_user WITH PASSWORD 'dw_password';
      RAISE NOTICE '✅ Usuário dw_user criado';
    ELSE
      RAISE NOTICE '⚠️  Usuário dw_user já existe';
    END IF;
  END
  \$\$;
  
  -- Concedendo privilégios ao usuário do Data Warehouse
  GRANT ALL PRIVILEGES ON DATABASE data_warehouse TO dw_user;
  GRANT ALL PRIVILEGES ON DATABASE data_warehouse TO ${POSTGRES_USER};
  
EOSQL

echo "📂 Criando schemas no data_warehouse..."

# Conectando ao banco data_warehouse e criando schemas iniciais
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "data_warehouse" <<-EOSQL
  -- Criando schemas para organização do Data Warehouse
  CREATE SCHEMA IF NOT EXISTS staging;
  CREATE SCHEMA IF NOT EXISTS bronze;
  CREATE SCHEMA IF NOT EXISTS silver;
  CREATE SCHEMA IF NOT EXISTS gold;
  
  -- Comentários explicativos
  COMMENT ON SCHEMA staging IS 'Camada de staging - dados brutos ingeridos';
  COMMENT ON SCHEMA bronze IS 'Camada bronze - dados brutos com mínimo processamento';
  COMMENT ON SCHEMA silver IS 'Camada silver - dados limpos e transformados';
  COMMENT ON SCHEMA gold IS 'Camada gold - dados agregados para análise';
  
  -- Concedendo privilégios nos schemas
  GRANT ALL ON SCHEMA staging TO dw_user;
  GRANT ALL ON SCHEMA bronze TO dw_user;
  GRANT ALL ON SCHEMA silver TO dw_user;
  GRANT ALL ON SCHEMA gold TO dw_user;
  
  -- Concedendo privilégios também ao usuário principal do Airflow
  GRANT ALL ON SCHEMA staging TO ${POSTGRES_USER};
  GRANT ALL ON SCHEMA bronze TO ${POSTGRES_USER};
  GRANT ALL ON SCHEMA silver TO ${POSTGRES_USER};
  GRANT ALL ON SCHEMA gold TO ${POSTGRES_USER};
  
EOSQL

echo "✅ Banco de dados data_warehouse configurado com sucesso!"
echo "📊 Schemas criados: staging, bronze, silver, gold"
