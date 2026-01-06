-- main_postgres.sql
CREATE TYPE status_agendamento AS ENUM ('aguardando', 'realizado', 'cancelado');
CREATE TYPE status_exame AS ENUM ('aguardando', 'realizado', 'cancelado');
CREATE TYPE status_calendario AS ENUM ('disponível', 'indisponível');
CREATE TYPE status_consulta AS ENUM ('aguardando', 'confirmada', 'realizado', 'cancelada');

CREATE TABLE pessoa (
    id_pessoa SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(100),
    cpf VARCHAR(14) NOT NULL UNIQUE,
    senha VARCHAR(200) NOT NULL,
    telefone VARCHAR(30)
);

CREATE TABLE paciente (
    id_paciente SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    tipo_sanguineo VARCHAR(10),
    ficha_medica TEXT,
    historico_doencas TEXT,
    sexo VARCHAR(20),
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE profissional (
    id_profissional SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    especialidade VARCHAR(255),
    numero_registro_medico VARCHAR(255),
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE agendamento (
    id_agendamento SERIAL PRIMARY KEY,
    id_profissional INT NOT NULL,
    id_paciente INT NOT NULL,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    endereco VARCHAR(255),
    status status_agendamento NOT NULL DEFAULT 'aguardando',
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_profissional) ON DELETE CASCADE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    CONSTRAINT uq_profissional_data_hora UNIQUE(id_profissional, data, hora)
);

CREATE TABLE exame (
    id_exame SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_profissional INT NOT NULL,
    tipo_exame VARCHAR(255),
    status status_exame NOT NULL DEFAULT 'aguardando',
    resultado_exame TEXT,
    observacoes TEXT,
    data_realizacao DATE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_profissional) ON DELETE CASCADE
);

CREATE TABLE calendario(
    id_calendario SERIAL PRIMARY KEY,
    status_dia status_calendario NOT NULL DEFAULT 'disponível',
    especialista VARCHAR(255)
);

CREATE TABLE unidade_saude(
    cnpj VARCHAR(255) PRIMARY KEY,
    numero INT,
    endereco VARCHAR(255)
);

CREATE TABLE unidade_profissional(
    cnpj VARCHAR(255),
    id_profissional INT,
    PRIMARY KEY (cnpj, id_profissional),
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_profissional) ON DELETE CASCADE,
    FOREIGN KEY (cnpj) REFERENCES unidade_saude(cnpj) ON DELETE CASCADE
);

CREATE TABLE profissional_calendario(
    id_profissional INT,
    id_calendario INT,
    PRIMARY KEY (id_profissional, id_calendario),
    FOREIGN KEY (id_profissional) REFERENCES profissional(id_profissional) ON DELETE CASCADE,
    FOREIGN KEY (id_calendario) REFERENCES calendario(id_calendario) ON DELETE CASCADE
);

CREATE TABLE consulta(
    id_consulta SERIAL PRIMARY KEY,
    id_agendamento INT,
    status status_consulta NOT NULL DEFAULT 'aguardando',
    observacoes TEXT,
    FOREIGN KEY (id_agendamento) REFERENCES agendamento(id_agendamento) ON DELETE CASCADE
);

CREATE TABLE consulta_exame(
    id_consulta INT,
    id_exame INT,
    PRIMARY KEY (id_consulta, id_exame),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta) ON DELETE CASCADE,
    FOREIGN KEY (id_exame) REFERENCES exame(id_exame) ON DELETE CASCADE
);


CREATE INDEX idx_paciente_pessoa ON paciente(id_pessoa);
CREATE INDEX idx_profissional_pessoa ON profissional(id_pessoa);
CREATE INDEX idx_agendamento_profissional ON agendamento(id_profissional);
CREATE INDEX idx_agendamento_paciente ON agendamento(id_paciente);
CREATE INDEX idx_agendamento_data ON agendamento(data);
CREATE INDEX idx_exame_paciente ON exame(id_paciente);
CREATE INDEX idx_exame_profissional ON exame(id_profissional);
CREATE INDEX idx_consulta_agendamento ON consulta(id_agendamento);
