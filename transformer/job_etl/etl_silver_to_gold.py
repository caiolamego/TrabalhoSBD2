import os

import psycopg2
import pyspark
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.functions import col, lit, split, when
from pyspark.sql.types import IntegerType, StringType, StructField, StructType

DB_HOST = "postgres"
DB_PORT = 5432
DB_NAME = "data_warehouse"
DB_USER = "dw_user"
DB_PASS = "dw_password"

DB_URL_JDBC = f"jdbc:postgresql://{DB_HOST}:{DB_PORT}/{DB_NAME}"
DB_PROPERTIES = {
    "user": DB_USER,
    "password": DB_PASS,
    "driver": "org.postgresql.Driver"
}

# caminho para a tabelona silver
SILVER_TABLE_PATH = "/opt/airflow/data_layer/silver/resultado.csv"

def get_pais_map_data():
    return [
        ('USA', 'Estados Unidos'), ('CHN', 'China'), ('DEU', 'Alemanha'), ('JPN', 'Japão'),
        ('GBR', 'Reino Unido'), ('FRA', 'França'), ('ITA', 'Itália'), ('IND', 'Índia'),
        ('CAN', 'Canadá'), ('AUS', 'Austrália'), ('KOR', 'Coreia do Sul'), ('ESP', 'Espanha'),
        ('NLD', 'Holanda'), ('IRL', 'Irlanda'), ('CHE', 'Suíça'), ('LUX', 'Luxemburgo'),
        ('SWE', 'Suécia'), ('DNK', 'Dinamarca'), ('FIN', 'Finlândia'), ('POL', 'Polônia'),
        ('AUT', 'Áustria'), ('BEL', 'Bélgica'), ('CZE', 'República Tcheca'), ('HUN', 'Hungria'),
        ('ROU', 'Romênia'), ('PRT', 'Portugal'), ('GRC', 'Grécia'), ('BRA', 'Brasil'),
        ('MEX', 'México'), ('ARG', 'Argentina'), ('COL', 'Colômbia'), ('CHL', 'Chile'),
        ('PER', 'Peru'), ('URY', 'Uruguai'), ('TWN', 'Taiwan'), ('SGP', 'Singapura'),
        ('HKG', 'Hong Kong'), ('THA', 'Tailândia'), ('MYS', 'Malásia'), ('VNM', 'Vietnã'),
        ('IDN', 'Indonésia'), ('PHL', 'Filipinas'), ('SAU', 'Arábia Saudita'),
        ('ARE', 'Emirados Árabes Unidos'), ('QAT', 'Catar'), ('KWT', 'Kuwait'),
        ('IRN', 'Irã'), ('ISR', 'Israel'), ('NOR', 'Noruega'), ('RUS', 'Rússia'),
        ('ZAF', 'África do Sul'), ('EGY', 'Egito'), ('NGA', 'Nigéria'),
        ('GHA', 'Gana'), ('KEN', 'Quênia')
    ]

def get_indicator_map_data():
    return [
        # BOP (Balanço de Pagamentos)
        ('CAB/BOP/NETCD_T', 'Conta Corrente, Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('CABXEF/BOP/NETCD_T', 'Conta Corrente (Excl. Financiamento Excepcional), Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('DXEF/BOP/L_NIL_T', 'Investimento Direto (Excl. Financ. Excepcional), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('D_F5/BOP/A_NFA_T', 'Invest. Direto (Derivativos Financ.), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('D_F5/BOP/L_NIL_T', 'Invest. Direto (Derivativos Financ.), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('D_FL/BOP/A_NFA_T', 'Invest. Direto (Ações e Títulos), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('D_FL/BOP/L_NIL_T', 'Invest. Direto (Ações e Títulos), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('EO/BOP/NETCD_T', 'Erros e Omissões, Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('FAB/BOP/NNAFANIL_T', 'Conta Financeira, Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('FABXRRI/BOP/NNAFANIL_T', 'Conta Financeira (Excl. Reservas), Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('GS/BOP/CD_T', 'Bens e Serviços, Crédito', 'BOP', 'Balanço de Pagamentos'),
        ('GS/BOP/DB_T', 'Bens e Serviços, Débito', 'BOP', 'Balanço de Pagamentos'),
        ('GS/BOP/NETCD_T', 'Bens e Serviços, Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('IN1/BOP/CD_T', 'Renda Primária, Crédito', 'BOP', 'Balanço de Pagamentos'),
        ('IN1/BOP/DB_T', 'Renda Primária, Débito', 'BOP', 'Balanço de Pagamentos'),
        ('IN1/BOP/NETCD_T', 'Renda Primária, Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('IN2/BOP/CD_T', 'Renda Secundária, Crédito', 'BOP', 'Balanço de Pagamentos'),
        ('IN2/BOP/DB_T', 'Renda Secundária, Débito', 'BOP', 'Balanço de Pagamentos'),
        ('IN2/BOP/NETCD_T', 'Renda Secundária, Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('KAB/BOP/NETCD_T', 'Conta Capital, Líquida', 'BOP', 'Balanço de Pagamentos'),
        ('O_F2/BOP/A_NFA_T', 'Outros Investimentos (Moeda e Depósitos), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F2/BOP/L_NIL_T', 'Outros Investimentos (Moeda e Depósitos), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F2/BOP/NNAFANIL_T', 'Outros Investimentos (Moeda e Depósitos), Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('O_F4/BOP/A_NFA_T', 'Outros Investimentos (Títulos de Dívida), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F4/BOP/L_NIL_T', 'Outros Investimentos (Títulos de Dívida), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F4/BOP/NNAFANIL_T', 'Outros Investimentos (Títulos de Dívida), Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('O_F81/BOP/A_NFA_T', 'Outros Investimentos (Créditos Comerciais), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F81/BOP/L_NIL_T', 'Outros Investimentos (Créditos Comerciais), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('O_F81/BOP/NNAFANIL_T', 'Outros Investimentos (Créditos Comerciais), Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('PXEF/BOP/L_NIL_T', 'Invest. Carteira (Excl. Financ. Excepcional), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('P_F3/BOP/A_NFA_T', 'Invest. Carteira (Títulos de Dívida), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('P_F3/BOP/L_NIL_T', 'Invest. Carteira (Títulos de Dívida), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('P_F5/BOP/A_NFA_T', 'Invest. Carteira (Ações), Ativo', 'BOP', 'Balanço de Pagamentos'),
        ('P_F5/BOP/L_NIL_T', 'Invest. Carteira (Ações), Passivo', 'BOP', 'Balanço de Pagamentos'),
        ('RUE/BOP/NNAFANIL_T', 'Ativos de Reserva, Líquido', 'BOP', 'Balanço de Pagamentos'),
        ('R_F/BOP/A_T', 'Ativos de Reserva (Ativos Totais)', 'BOP', 'Balanço de Pagamentos'),
        ('SF/BOP/CD_T', 'Serviços, Crédito', 'BOP', 'Balanço de Pagamentos'),
        ('SF/BOP/DB_T', 'Serviços, Débito', 'BOP', 'Balanço de Pagamentos'),
        ('SF/BOP/NETCD_T', 'Serviços, Líquido', 'BOP', 'Balanço de Pagamentos'),
        
        # --- ER (Exchange Rates) ---
        ('XDC_EUR', 'Taxa de Câmbio (Moeda Local por EUR)', 'ER', 'Taxa de Câmbio'),
        ('XDC_USD', 'Taxa de Câmbio (Moeda Local por USD)', 'ER', 'Taxa de Câmbio'),
        ('XDC_XDR', 'Taxa de Câmbio (Moeda Local por XDR)', 'ER', 'Taxa de Câmbio'),
        
        # --- IIP (Posição de Investimento) ---
        ('D/IIP/A_P', 'Investimento Direto, Ativos', 'IIP', 'Posição de Investimento'),
        ('D/IIP/L_P', 'Investimento Direto, Passivos', 'IIP', 'Posição de Investimento'),
        ('D_F5/IIP/A_P', 'Invest. Direto (Derivativos Financ.), Ativos', 'IIP', 'Posição de Investimento'),
        ('D_F5/IIP/L_P', 'Invest. Direto (Derivativos Financ.), Passivos', 'IIP', 'Posição de Investimento'),
        ('D_FL/IIP/A_P', 'Invest. Direto (Ações e Títulos), Ativos', 'IIP', 'Posição de Investimento'),
        ('D_FL/IIP/L_P', 'Invest. Direto (Ações e Títulos), Passivos', 'IIP', 'Posição de Investimento'),
        ('NIIP/IIP/NETAL_P', 'Posição de Investimento Internacional Líquida (NIIP)', 'IIP', 'Posição de Investimento'),
        ('O_F12/IIP/L_P', 'Outros Investimentos (Alocação SDR), Passivos', 'IIP', 'Posição de Investimento'),
        ('O_F2_NV/IIP/A_P', 'Outros Investimentos (Moeda e Depósitos), Ativos', 'IIP', 'Posição de Investimento'),
        ('O_F2_NV/IIP/L_P', 'Outros Investimentos (Moeda e Depósitos), Passivos', 'IIP', 'Posição de Investimento'),
        ('O_F4_NV/IIP/A_P', 'Outros Investimentos (Títulos de Dívida), Ativos', 'IIP', 'Posição de Investimento'),
        ('O_F4_NV/IIP/L_P', 'Outros Investimentos (Títulos de Dívida), Passivos', 'IIP', 'Posição de Investimento'),
        ('O_F81/IIP/A_P', 'Outros Investimentos (Créditos Comerciais), Ativos', 'IIP', 'Posição de Investimento'),
        ('O_F81/IIP/L_P', 'Outros Investimentos (Créditos Comerciais), Passivo', 'IIP', 'Posição de Investimento'),
        ('O_FL1/IIP/A_P', 'Outros Investimentos (Empréstimos), Ativos', 'IIP', 'Posição de Investimento'),
        ('P_F3_MV/IIP/A_P', 'Invest. Carteira (Títulos de Dívida), Ativos', 'IIP', 'Posição de Investimento'),
        ('P_F3_MV/IIP/L_P', 'Invest. Carteira (Títulos de Dívida), Passivos', 'IIP', 'Posição de Investimento'),
        ('P_F5_MV/IIP/A_P', 'Invest. Carteira (Ações), Ativos', 'IIP', 'Posição de Investimento'),
        ('P_F5_MV/IIP/L_P', 'Invest. Carteira (Ações), Passivos', 'IIP', 'Posição de Investimento'),
        ('P_MV/IIP/A_P', 'Investimento em Carteira, Ativos (Total)', 'IIP', 'Posição de Investimento'),
        ('P_MV/IIP/L_P', 'Investimento em Carteira, Passivos (Total)', 'IIP', 'Posição de Investimento'),
        ('R/IIP/A_P', 'Ativos de Reserva (Total)', 'IIP', 'Posição de Investimento'),
        ('R_F11_MV/IIP/A_P', 'Reservas (Ouro Monetário)', 'IIP', 'Posição de Investimento'),
        ('R_F12_MV/IIP/A_P', 'Reservas (SDRs)', 'IIP', 'Posição de Investimento'),
        ('R_FK_MV/IIP/A_P', 'Reservas (Outros Ativos)', 'IIP', 'Posição de Investimento'),
        ('TA_AFR/IIP/A_P', 'Total Ativos (Excl. Reservas)', 'IIP', 'Posição de Investimento'),
        ('TL_AFR/IIP/L_P', 'Total Passivos', 'IIP', 'Posição de Investimento'),
        
        # --- IRFCL (Reservas Internacionais) ---
        ('IRFCLDT1_IRFCL32_USD_IRFCL13', 'Títulos nas Reservas', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCL54_USD_IRFCL13', 'Reservas Oficiais + Outros Ativos FX', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCL56_USD_IRFCL13', 'Ouro nas Reservas', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCL57_USD_IRFCL13', 'Posição de Reservas no FMI', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCL65_DIC_XDR_USD_IRFCL13', 'SDR (Holdings) nas Reservas', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCL65_USD_IRFCL13', 'Reservas Oficiais (Total)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT1_IRFCLCDCFC_USD_IRFCL13', 'Moeda e Depósitos nas Reservas', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL151_SM1MUT3M_FO_USD_IRFCL13', 'Drenagens: Juros (1-3 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL151_SM3MUTY_FO_USD_IRFCL13', 'Drenagens: Juros (3-12 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL151_SUTM_FO_USD_IRFCL13', 'Drenagens: Juros (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL1_SUTM_IN_LP_USD_IRFCL13', 'Drenagens: Entradas Forwards (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL1_SUTM_SHP_USD_IRFCL13', 'Drenagens: Saídas Forwards (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL24_SM1MUT3M_USD_IRFCL13', 'Drenagens: Total (1-3 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL24_SM3MUTY_USD_IRFCL13', 'Drenagens: Total (3-12 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL24_SUTM_USD_IRFCL13', 'Drenagens: Total (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL26_SM1MUT3M_FO_USD_IRFCL13', 'Drenagens: Principal (1-3 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL26_SM3MUTY_FO_USD_IRFCL13', 'Drenagens: Principal (3-12 Meses)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_IRFCL26_SUTM_FO_USD_IRFCL13', 'Drenagens: Principal (Até 1 Mês)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT2_USD_IRFCL13', 'Drenagens Líquidas de Curto Prazo (Total)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT4_IRFCL11_DIC_XDRB_USD_IRFCL13', 'Memo: Moedas da Cesta SDR', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT4_IRFCL11_DIC_XXDR_USD_IRFCL13', 'Memo: Moedas Fora da Cesta SDR', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT4_IRFCL68_USD_IRFCL13', 'Memo: Títulos Cedidos/em Repo', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT4_IRFCL69X_USD_IRFCL13', 'Memo: Títulos Cedidos (Não Incl. Seção I)', 'IRFCL', 'Reservas Internacionais'),
        ('IRFCLDT4_IRFCLU97_A_USD_IRFCL13', 'Memo: Derivativos (Net MTM)', 'IRFCL', 'Reservas Internacionais'),
        
        # --- Demografia (DM) ---
        ('FERT_RATIO/DM/BR_L_W', 'Taxa de Fertilidade', 'DM', 'Demografia'),
        ('LFEXP/DM/Y', 'Expectativa de Vida', 'DM', 'Demografia'),
        ('MORT/DM/DT', 'Taxa de Mortalidade', 'DM', 'Demografia'),
        ('POP/DM/PS', 'População Total', 'DM', 'Demografia'),

        # --- Colunas de Metadados (Não são indicadores) ---
        ('UNIT_BOP', 'Metadado: Unidade BOP', 'META', 'Metadados'),
        ('TYPE_OF_TRANSFORMATION_ER', 'Metadado: Tipo de Transformação ER', 'META', 'Metadados'),
        ('UNIT_IIP', 'Metadado: Unidade IIP', 'META', 'Metadados'),
        ('SECTOR_IRFCL', 'Metadado: Setor IRFCL', 'META', 'Metadados'),
        ('TERRITORIAL_LEVEL', 'Metadado: Nível Territorial DM', 'META', 'Metadados'),
        ('FREQ', 'Metadado: Frequência DM', 'META', 'Metadados')
    ]


def create_spark_session(app_name="ETL_Silver_to_Gold"):
    print("Iniciando sessão Spark...")
    spark = (
        SparkSession.builder
        .appName(app_name)
        .config("spark.driver.memory", "4g")
        .config("spark.executor.memory", "2g")
        .getOrCreate()
    )
    print("Sessão Spark criada com sucesso.")
    return spark

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

def truncate_dw_tables(): #limpar as tabelas do DW antes de popular
    print("Iniciando TRUNCATE nas tabelas do DW...")
    
    sql_truncate_fato = "TRUNCATE TABLE DW.Fato_ObservacaoEconomica;"
    sql_truncate_dims = """
    TRUNCATE TABLE DW.Dim_Pais, 
                     DW.Dim_Tempo, 
                     DW.Dim_Indicador 
    RESTART IDENTITY CASCADE;
    """
    
    conn = None
    cursor = None
    try:
        conn = get_db_connection()
        conn.autocommit = True
        cursor = conn.cursor() #executar comandos SQL
        
        print(f"Executando: {sql_truncate_fato}")
        cursor.execute(sql_truncate_fato)
        print(f"Executando: {sql_truncate_dims}")
        cursor.execute(sql_truncate_dims)
        
        print("Tabelas do DW truncadas com sucesso.")
    except Exception as e:
        print(f"ERRO ao truncar tabelas: {e}")
        raise e
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def etl_dim_pais(spark: SparkSession, df_silver: DataFrame):
    print("Iniciando ETL para DW.Dim_Pais...")
    
    df_paises_silver = df_silver.select(col("COUNTRY").alias("codigo_pais")).distinct()
    
    schema_pais_map = StructType([
        StructField("codigo_pais_map", StringType(), False), #false e true indicaam se o campo pode ser nulo
        StructField("nome_pais", StringType(), True)
    ])
    pais_data = [(cod, nome) for cod, nome in get_pais_map_data()]
    df_pais_map = spark.createDataFrame(pais_data, schema=schema_pais_map)
    
    df_dim_pais = df_paises_silver.join( #interação com a tabelona, através de um join
        df_pais_map, 
        df_paises_silver.codigo_pais == df_pais_map.codigo_pais_map, 
        "left"
    ).select("codigo_pais", "nome_pais") 
    
    print(f"Escrevendo {df_dim_pais.count()} países em DW.Dim_Pais...")
    df_dim_pais.write.jdbc(
        url=DB_URL_JDBC,
        table="DW.Dim_Pais",
        mode="append", # A tabela foi truncada, então usamos append
        properties=DB_PROPERTIES
    )
    print("DW.Dim_Pais populada com sucesso.")

def etl_dim_tempo(spark: SparkSession, df_silver: DataFrame):
    print("Iniciando ETL para DW.Dim_Tempo...")
    
    df_dim_tempo = (
        df_silver.select("TIME_PERIOD").distinct()
        .withColumnRenamed("TIME_PERIOD", "periodo_completo")
        .filter(col("periodo_completo").isNotNull())
    )
    
    split_col = split(col("periodo_completo"), "-")
    
    df_dim_tempo = df_dim_tempo.withColumn("ano", split_col.getItem(0).cast("int"))
    df_dim_tempo = df_dim_tempo.withColumn(
        "trimestre",
        when(split_col.getItem(1).isNotNull(), split_col.getItem(1)).otherwise(lit(None))
    )
    # df_dim_tempo = df_dim_tempo.withColumn("mes", lit(None).cast("int"))
    
    df_dim_tempo_final = df_dim_tempo.select("periodo_completo", "ano", "trimestre")
    
    print(f"Escrevendo {df_dim_tempo_final.count()} períodos em DW.Dim_Tempo...")
    df_dim_tempo_final.write.jdbc(
        url=DB_URL_JDBC,
        table="DW.Dim_Tempo",
        mode="append", # A tabela foi truncada, então usamos append
        properties=DB_PROPERTIES
    )
    print("DW.Dim_Tempo populada com sucesso.")

def etl_dim_indicador(spark: SparkSession, all_silver_columns: list):
    print("Iniciando ETL para DW.Dim_Indicador...")
    
    id_vars = ['COUNTRY', 'TIME_PERIOD', 'FREQUENCY', 'UNIT_BOP', 
               'TYPE_OF_TRANSFORMATION_ER', 'UNIT_IIP', 'SECTOR_IRFCL', 
               'TERRITORIAL_LEVEL', 'FREQ']
    
    indicator_codes = [c for c in all_silver_columns if c not in id_vars]
    
    indicator_map_dict = {cod: (nome, fonte, cat) for cod, nome, fonte, cat in get_indicator_map_data()}
    
    schema_indicador_data = []
    for cod in indicator_codes:
        nome, fonte, cat = indicator_map_dict.get(
            cod, 
            (f"Indicador - {cod}", "Desconhecida", "Desconhecida")
        )
        schema_indicador_data.append((cod, nome, fonte, cat))
            
    schema_indicador = StructType([
        StructField("codigo_indicador", StringType(), False),
        StructField("nome_indicador", StringType(), True),
        StructField("fonte_dados", StringType(), True),
        StructField("categoria", StringType(), True),
    ])
    
    df_dim_indicador = spark.createDataFrame(schema_indicador_data, schema=schema_indicador)
    
    print(f"Escrevendo {df_dim_indicador.count()} indicadores em DW.Dim_Indicador...")
    df_dim_indicador.write.jdbc(
        url=DB_URL_JDBC,
        table="DW.Dim_Indicador",
        mode="append", # A tabela foi truncada, então usamos append
        properties=DB_PROPERTIES
    )
    print("DW.Dim_Indicador populada com sucesso.")

def etl_fato_observacao(spark: SparkSession, df_silver: DataFrame):
    print("Iniciando ETL para DW.Fato_ObservacaoEconomica...")
    
    print("Lendo Dimensões do DW (com SRKs)...")

    df_dim_pais = spark.read.jdbc(url=DB_URL_JDBC, table="DW.Dim_Pais", properties=DB_PROPERTIES)
    df_dim_tempo = spark.read.jdbc(url=DB_URL_JDBC, table="DW.Dim_Tempo", properties=DB_PROPERTIES)
    df_dim_indicador = spark.read.jdbc(url=DB_URL_JDBC, table="DW.Dim_Indicador", properties=DB_PROPERTIES)
    
    id_vars = ['COUNTRY', 'TIME_PERIOD']
    id_vars_meta = ['COUNTRY', 'TIME_PERIOD', 'FREQUENCY', 'UNIT_BOP', 
                    'TYPE_OF_TRANSFORMATION_ER', 'UNIT_IIP', 'SECTOR_IRFCL', 
                    'TERRITORIAL_LEVEL', 'FREQ']
    meta_indicadores = {cod for cod, _, fonte, _ in get_indicator_map_data() if fonte == 'META'}
    
    measure_vars = [
        c for c in df_silver.columns 
        if c not in id_vars_meta and c not in meta_indicadores
    ]
    
    stack_expr_parts = []
    for cod in measure_vars:
        stack_expr_parts.append(f"'{cod}', `{cod}`") 
            
    stack_expr = f"stack({len(measure_vars)}, {', '.join(stack_expr_parts)}) as (Codigo_Indicador, Valor)"
    
    df_long = df_silver.selectExpr(*id_vars, stack_expr)
    
    df_long_cleaned = df_long.filter(col("Valor").isNotNull())
    print(f"Unpivot concluído. {df_long_cleaned.count()} observações de fato encontradas.")
    
    print("Juntando Fato com Dimensões para obter SRKs...")
    
    # renomeando colunas
    df_long_renomeado = df_long_cleaned.withColumnRenamed("COUNTRY", "chave_pais") \
                                     .withColumnRenamed("TIME_PERIOD", "chave_tempo") \
                                     .withColumnRenamed("Codigo_Indicador", "chave_indicador")

    # Join Pais
    # (long.chave_pais == dim.codigo_pais)
    df_fato_join_pais = df_long_renomeado.join(
        df_dim_pais,
        df_long_renomeado.chave_pais == df_dim_pais.codigo_pais,
        "inner"
    ).select(
        df_long_renomeado["*"], 
        df_dim_pais.srk_pais
    )

    # Join Tempo
    df_fato_join_tempo = df_fato_join_pais.join(
        df_dim_tempo,
        df_fato_join_pais.chave_tempo == df_dim_tempo.periodo_completo,
        "inner"
    ).select(
        df_fato_join_pais["*"], 
        df_dim_tempo.srk_tempo 
    )

    # Join Indicador
    df_fato_join_final = df_fato_join_tempo.join(
        df_dim_indicador,
        df_fato_join_tempo.chave_indicador == df_dim_indicador.codigo_indicador,
        "inner"
    ).select(
        df_fato_join_tempo["*"],    
        df_dim_indicador.srk_indicador 
    )

    # Colunas finais da Fato
    df_fato_final = df_fato_join_final.select(
        col("srk_pais"),
        col("srk_tempo"),
        col("srk_indicador"),
        col("Valor").cast("decimal(30, 8)").alias("valor")
    )
    
    print(f"Escrevendo {df_fato_final.count()} linhas em DW.Fato_ObservacaoEconomica...")
    
    df_fato_final.write.jdbc(
        url=DB_URL_JDBC,
        table="DW.Fato_ObservacaoEconomica",
        mode="append", # A tabela foi truncada, então usamos append
        properties=DB_PROPERTIES
    )
    print("DW.Fato_ObservacaoEconomica populada com sucesso.")

# MAIN

def main():
    spark = None
    try:
        spark = create_spark_session()
        
        print(f"Lendo tabelona Silver de: {SILVER_TABLE_PATH}")

        df_silver = spark.read.csv(SILVER_TABLE_PATH, header=True, inferSchema=True)
        
        all_columns = df_silver.columns
        
        #Limpar tabelas antes de popular
        truncate_dw_tables()
        
        # Popular Dim
        etl_dim_pais(spark, df_silver)
        etl_dim_tempo(spark, df_silver)
        etl_dim_indicador(spark, all_columns)
        
        # Popular Fato
        etl_fato_observacao(spark, df_silver)
        
        print("\n--- SUCESSO: ETL Silver-para-Gold concluído. ---")
        
    except Exception as e:
        print(f"\n--- ERRO FATAL NO ETL: {e} ---")
        import traceback
        traceback.print_exc()
        
    finally:
        if spark:
            print("Parando sessão Spark.")
            spark.stop()

if __name__ == "__main__":
    main()