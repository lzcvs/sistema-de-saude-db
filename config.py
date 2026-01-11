import psycopg2
import os
from dotenv import load_dotenv
from psycopg2 import Error


load_dotenv()
password = os.getenv('password')

def conecta():
    try:
        conexao = psycopg2.connect(
            user='postgres',
            password=password,
            host='localhost',
            port='5432',
            database="saude2"
        )

        print('Conectado com sucesso')

        return conexao


    except Error as e:
        print(f"ocorreu um erro ao se conectar: {e}")

def encerra_conexao(conexao):
    if conexao:
        conexao.close()
        print('Conexao encerrada')