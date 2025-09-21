import sdmx
import pandas as pd
import sys
import os
import re, json

base = sys.argv[1]
lista_estrutura = ["attributes","dimensions","measures"]


# Cliente IMF
client = sdmx.Client("IMF_DATA")
dataflows = client.dataflow()

if base in dataflows.dataflow.keys():
    print('Base encontrada')

    # Acessando a estrutura da base
    base_dados = client.dataflow(base)
    estrutura_str = list(base_dados.structure.keys())[0]
    estrutura = base_dados.structure[estrutura_str]

    # Criando pasta para os metadados da base
    pasta = base
    os.makedirs(pasta, exist_ok=True)
    print(f"Pasta '{pasta}' criada/verificada com sucesso!")

    codelist = base_dados.codelist
    codelist_str = str(codelist).replace("{","").replace("}","").split(",")
    with open(f"{pasta}/codelist.txt", "w", encoding="utf-8") as f:
        for linha in codelist_str:
            f.write(linha + "\n")

    for item in lista_estrutura:

        if item == 'dimensions':
            data = str(getattr(estrutura,item).components)
            data = data.replace("[","").replace("]","").split(",")
            data = [re.findall(r"<\w+\s([A-Z_]+)>", dimensao)[0] for dimensao in data]

            lista_filtros_codelist = {}
            for dimensao in data:
                for key in codelist:
                    if dimensao in key or dimensao[:4] in key:
                        print(f'Encontrei key de {dimensao}: {key}')
                        indicator_values = base_dados.codelist[key]
                        lista_filtros_codelist[key] = indicator_values
                        df_valores = sdmx.to_pandas(indicator_values)
                        df_valores.to_csv(f"{pasta}/{key}.csv")

                        with open(f"{pasta}/lista_filtros_codelist.txt", "w", encoding="utf-8") as f:
                            for chave,valor in lista_filtros_codelist.items():
                                try:
                                    f.write(f"{chave}: {valor.description}\n")
                                except Exception as e:
                                    f.write(f"{chave}: Error accessing description - {str(e)}\n")

        else:    
            data = str(getattr(estrutura,item).components)
            data = data.replace("[","").replace("]","")
            if item == "attributes":
                data= data.split("DataAttribute(annotations=,")
            else: data = data.split(",")

        arquivo = f"{item}.txt"

        # Caminho completo para o arquivo
        caminho = os.path.join(pasta, arquivo)

        # Criar e escrever no arquivo
        with open(caminho, "w", encoding="utf-8") as f:
            for linha in data:
                f.write(linha + "\n")

        print(f"Arquivo '{caminho}' criado e escrito com sucesso!")




else: 
    print('Essa base de dados não existe!')






