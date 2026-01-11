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


    def criar_pessoa(id_pessoa, nome, endereco, cpf, senha, telefone):
        cmd_insert = "INSERT INTO pessoa (id_pessoa, nome, endereco, cpf, senha, telefone) VALUES (%s, %s, %s, %s, %s, %s);"
        values = id_pessoa, nome, endereco, cpf, senha, telefone
        cursor.execute(cmd_insert, values)
        conexao.commit()
        print('Dados inseridos com sucesso')


    def criar_paciente(id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo):
        try:
            if check(id_pessoa):
                cmd_paciente = "INSERT INTO paciente (id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo) VALUES (%s, %s, %s, %s, %s)"
                values_paciente = (id_pessoa, tipo_sanguineo, ficha_medica, historico_doencas, sexo)
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
    
    def criar_profissional(id_pessoa, especialidade, numero_reg):
        try:
            if check(id_pessoa):
                cmd_profissional = "INSERT INTO profissional (id_pessoa, especialidade, numero_registro_medico) VALUES (%s, %s, %s)"
                values_profissional = (id_pessoa, especialidade, numero_reg)
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
        cmd_select = "SELECT * FROM paciente, pessoa, profissional;"
        cursor.execute(cmd_select)
        fetch =  cursor.fetchall()
        for i in fetch:
            print(i)
        return fetch

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
    
    def buscar_por_id(id):
        try:
            cursor.execute("SELECT * FROM pessoa pe join paciente pa on pa.id_pessoa = pe.id_pessoa join profissional pr on pr.id_pessoa = pr.id_pessoa WHERE pe.id_pessoa = %s", (id,))
            pessoa = cursor.fetchone()
            
            if pessoa:
                print("^-^")
                return True
            else:
                print(f"Não existe registros com o id: {id}")
                return False
        except Exception as e:
            conexao.rollback()
            print(f"{e}")
    
    def delete(id):
        
        if buscar_por_id(id):
            cursor.execute("DELETE FROM pessoa WHERE id_pessoa = %s", (id,))
            conexao.commit()
            print('Registro deletado com sucesso')
        
    
        
    # criar_pessoa("1", "Patricio", "Rua do 15", "3333444-33", "22003", "123456")
    # criar_paciente('1', "O+", "gripe suína", "peste bulbonica em 1864", "M")
    # criar_profissional("1", "Clinico Geral, Oftalmologista", "00000000")
    # buscar_por_id(1)
    seleciona()
    encerra_conexao(conexao)

if __name__ ==  "__main__":
    main()
