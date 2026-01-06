from config import conecta, encerra_conexao

def main():
    conexao = conecta()
    cursor = conexao.cursor()

    def check(id_pessoa):
        cmd_check = "SELECT id_pessoa FROM pessoa WHERE id_pessoa = %s;"
        cursor.execute(cmd_check, (id_pessoa,))
        pessoa_existe = cursor.fetchone()

        if not pessoa_existe:
            print(f'Error: pessoa {id_pessoa} não existe.')
            return False
        else:
            return True


    def insert(id_pessoa, nome, endereco, cpf, senha, telefone):
        cmd_insert = "INSERT INTO pessoa (id_pessoa, nome, endereco, cpf, senha, telefone) VALUES (%s, %s, %s, %s, %s, %s);"
        values = id_pessoa, nome, endereco, cpf, senha, telefone
        cursor.execute(cmd_insert, values)
        conexao.commit()
        print('Dados inseridos com sucesso')


    def criar_paciente(id_paciente, id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo):
        try:
            if check(id_pessoa):
                cmd_paciente = "INSERT INTO paciente (id_paciente, id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo) VALUES (%s, %s, %s, %s, %s, %s)"
                values_paciente = (id_paciente, id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo)
                cursor.execute(cmd_paciente, values_paciente)
                conexao.commit()
                print('Paciente criado com sucesso')
                return True
            else:
                return False
        except Exception as e:
            conexao.rollback()
            print(f"error ao criar paciente {e}")
            return False
    
    def criar_profissional(id_profissional, id_pessoa, especialidade, numero_reg):
        try:
            if check(id_pessoa):
                cmd_profissional = "INSERT INTO profissional (id_profissional, id_pessoa, tipo_sanguineo, especialidade, numero_registro_medico) VALUES (%s, %s, %s, %s)"
                values_profissional = (id_profissional, id_pessoa, especialidade, numero_reg)
                cursor.execute(cmd_profissional, values_profissional)
                conexao.commit()
                print("Profissional criado com sucesso")
                return True
            else:
                return False
        except Exception as e:
            conexao.rollback()
            print(f"error ao criar profissional {e}")
            return False
            
    def seleciona():
        cmd_select = "SELECT * FROM paciente, pessoa;"
        cursor.execute(cmd_select)
        fetch =  cursor.fetchall()
        for i in fetch:
            print(i)
        return fetch
    
    def buscar_por_cpf(cpf):
        cursor.execute("SELECT * FROM pessoa WHERE CPF = %s", (cpf,))
        pessoa = cursor.fetchone()

        if pessoa:
            print(f"Nome: {pessoa[1]}")
            print(f"CPF: {pessoa[3]}")
            print(f"Telefone: {pessoa[5]}")

    def atualizar_dados():
        id_pessoa = input("Qual o seu id? ")
        cursor.execute("SELECT * FROM pessoa WHERE id_pessoa = %s", (id_pessoa,))
        pessoa = cursor.fetchone()

        if not pessoa:
            print("Pessoa não encontrada")
            return

        print(f"Dados atuais - Nome: ({pessoa[1]}), Endereco ({pessoa[2]}) Telefone: ({pessoa[5]})")

        novo_endereco = input("Novo endereco (enter para manter): ")
        nova_senha = input("Nova senha (enter para manter): ")
        nova_senha2 = input("Repita a senha (enter para manter): ")
        novo_telefone = input("Novo telefone (enter para manter): ")

        campos = []
        valores = []
        if novo_endereco:
            campos.append("endereco = %s")
            valores.append(novo_endereco)
        if nova_senha == nova_senha2:
            campos.append("senha = %s")
            valores.append(nova_senha)
        else:
            print("As senhas não batem")
        if novo_telefone:
            campos.append("telefone = %s")
            valores.append(novo_telefone)

        if not campos:
            print("Nada para atualizar")
            return
        valores.append(id_pessoa)
        cmd_update = f"UPDATE pessoa SET {', '.join(campos)} WHERE id_pessoa = %s;"
        cursor.execute(cmd_update, tuple(valores))
        conexao.commit()
        print("Atualizado!")

    def delete(id):
        cmd_delete = f"DELETE FROM paciente WHERE id_paciente= '{id}'"
        cursor.execute(cmd_delete)
        conexao.commit()
        print('Registro deletado com sucesso')

    # insert("1045", "joaozinho", "rua do joao", "0123414151", "123445585", "199293003")
    # criar_paciente("103", "1045", "O+", "alergia a gatos", "","M")
    buscar_por_cpf("0123414151")
    seleciona()
    encerra_conexao(conexao)

if __name__ ==  "__main__":
    main()
