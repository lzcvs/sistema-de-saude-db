from config import conecta, encerra_conexao
import hashlib
## create
## read
## update
## delete
def main():
    conexao = conecta()
    cursor = conexao.cursos()

    ##update
    def insert(id_pessoa, nome, endereco, cpf, senha, telefone):
        cmd_insert = "INSERT INTO pessoa (id_pessoa, nome, endereco, cpf, senha, telefone) VALUES (%s, %s, %s, %s, %s);"
        values = nome, endereco, cpf, senha, telefone
        cursor.execute(cmd_insert, values)
        conexao.commit()
        print('Dados inseridos com sucesso')

    def seleciona():
        cmd_select = "SELECT id_pessoa, nome, cpf, endereco, telefone FROM pessoa;"
        cursor.execute(cmd_select)
        fetch =  cursor.fetchall()
        for i in fetch:
            print(i)
        return fetch
    
    def hash_senha(senha):
        return hashlib.sha256(senha.encode()).hexdigest()
    
    def atualiza():
        return
    def delete():
        return