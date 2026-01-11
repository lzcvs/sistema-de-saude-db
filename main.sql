-- main_postgres.sql

-- Tipos ENUM
CREATE TYPE status_agendamento AS ENUM ('aguardando', 'realizado', 'cancelado');
CREATE TYPE status_exame AS ENUM ('aguardando', 'realizado', 'cancelado');
CREATE TYPE status_disponibilidade AS ENUM ('disponivel', 'indisponivel'); -- Corrigido acentuação
CREATE TYPE status_consulta AS ENUM ('aguardando', 'confirmada', 'realizada', 'cancelada'); -- Corrigido: 'realizado' para 'realizada'

CREATE TABLE pessoa (
    id_pessoa SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(100),
    cpf VARCHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(200) NOT NULL,
    telefone VARCHAR(30)
);

CREATE TABLE paciente (
    id_pessoa INT PRIMARY KEY, -- Usa o mesmo ID da pessoa
    tipo_sanguineo VARCHAR(10),
    ficha_medica TEXT,
    historico_doencas TEXT,
    sexo VARCHAR(20),
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);


CREATE TABLE profissional (
    id_pessoa INT PRIMARY KEY, -- Usa o mesmo ID da pessoa
    especialidade VARCHAR(255),
    numero_registro_medico VARCHAR(255) UNIQUE, -- Registro médico deve ser único
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela unidade_saude (renomeada para snake_case e melhorada)
CREATE TABLE unidade_saude (
    cnpj VARCHAR(18) PRIMARY KEY, -- CNPJ tem 14 dígitos + formatação
    nome VARCHAR(255) NOT NULL, -- Adicionado nome da unidade
    numero VARCHAR(10), -- Número pode ter letras (ex: "12A")
    endereco VARCHAR(255) NOT NULL,
    telefone VARCHAR(30)
);

CREATE TABLE agendamento (
    id_agendamento SERIAL PRIMARY KEY,
    id_profissional INT NOT NULL,
    id_paciente INT NOT NULL,
    data_hora TIMESTAMP NOT NULL, -- Data e hora juntas para facilitar
    endereco VARCHAR(255),
    status status_agendamento NOT NULL DEFAULT 'aguardando',
    observacoes TEXT, -- Adicionado para observações do agendamento
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_pessoa) ON DELETE CASCADE,
    CONSTRAINT uq_profissional_data_hora UNIQUE(id_profissional, data_hora),
    CONSTRAINT chk_data_hora_futura CHECK (data_hora > CURRENT_TIMESTAMP)
);

CREATE TABLE consulta(
    id_consulta SERIAL PRIMARY KEY,
    id_agendamento INT NOT NULL UNIQUE, -- Um agendamento vira uma consulta
    status status_consulta NOT NULL DEFAULT 'aguardando',
    diagnostico TEXT,
    prescricao TEXT,
    observacoes TEXT,
    data_realizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agendamento) REFERENCES agendamento(id_agendamento) ON DELETE CASCADE
);

CREATE TABLE exame (
    id_exame SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_profissional INT NOT NULL,
    tipo_exame VARCHAR(255) NOT NULL,
    status status_exame NOT NULL DEFAULT 'aguardando',
    resultado_exame TEXT,
    observacoes TEXT,
    data_solicitacao DATE DEFAULT CURRENT_DATE,
    data_realizacao DATE,
    data_resultado DATE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE agenda_profissional(
    id_agenda SERIAL PRIMARY KEY,
    id_profissional INT NOT NULL,
    data DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    status status_disponibilidade NOT NULL DEFAULT 'disponivel',
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_pessoa) ON DELETE CASCADE,
    CONSTRAINT uq_profissional_data UNIQUE(id_profissional, data),
    CONSTRAINT chk_hora_valida CHECK (hora_fim > hora_inicio)
);


CREATE TABLE unidade_profissional(
    cnpj VARCHAR(18),
    id_profissional INT,
    data_inicio DATE DEFAULT CURRENT_DATE,
    data_fim DATE,
    PRIMARY KEY (cnpj, id_profissional),
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_pessoa) ON DELETE CASCADE,
    FOREIGN KEY (cnpj) REFERENCES unidade_saude(cnpj) ON DELETE CASCADE,
    CONSTRAINT chk_datas_validas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE INDEX idx_pessoa_cpf ON pessoa(cpf);
CREATE INDEX idx_pessoa_nome ON pessoa(nome);
CREATE INDEX idx_agendamento_data_hora ON agendamento(data_hora);
CREATE INDEX idx_agendamento_status ON agendamento(status);
CREATE INDEX idx_consulta_status ON consulta(status);
CREATE INDEX idx_exame_status ON exame(status);
CREATE INDEX idx_exame_data_realizacao ON exame(data_realizacao);
CREATE INDEX idx_agenda_profissional_data ON agenda_profissional(data);
CREATE INDEX idx_agenda_profissional_status ON agenda_profissional(status);