-- Procedure para gerar clientes
CREATE OR REPLACE PROCEDURE gerar_clientes(qtd INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    i INTEGER;
    v_cpf VARCHAR(15);
    v_nome VARCHAR(50);
    v_endereco VARCHAR(100);
    v_estado_civil VARCHAR(20);
    v_num_filhos INT;
    v_data_nasc DATE;
    v_telefone VARCHAR(15);
    v_codH INT;
    estados_civis TEXT[] := ARRAY['Solteiro','Casado','Divorciado','Viúvo'];
BEGIN
    FOR i IN 1..qtd LOOP
        v_cpf := lpad((floor(random() * 99999999999))::TEXT,11,'0');
        v_nome := 'Cliente_' || i;
        v_endereco := 'Rua ' || (floor(random()*500) + 1)::TEXT || ', Bairro ' || (floor(random()*100))::TEXT;
        v_estado_civil := estados_civis[1+ floor(random() * array_length(estados_civis, 1))::INT];
        v_num_filhos := floor(random() * 5)::INT;
        v_data_nasc := DATE '1950-01-01' + (trunc(random() * 20000)) * INTERVAL '1 day';
        v_telefone := '(' || (10 + floor(random() * 89))::INT || ')' || (90000 + floor(random() * 9999))::INT;
        
        SELECT codh INTO v_codh
        FROM public.habilitacoes
        ORDER BY random()
        LIMIT 1;
        
        INSERT INTO public.clientes (cpf, nome, endereco, estado_civil, num_filhos, data_nasc, telefone, codh)
        VALUES (v_cpf, v_nome, v_endereco, v_estado_civil, v_num_filhos, v_data_nasc, v_telefone, v_codh);
    END LOOP;
END;
$$;

-- Procedure para gerar funcionários
CREATE OR REPLACE PROCEDURE gerar_funcionarios(qtd INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..qtd LOOP
        INSERT INTO funcionarios (codF, nome, telefone, endereco, idade, salario)
        VALUES (
            i,
            'Funcionario_' || i,
            '(' || (10 + floor(random()*89))::INT || ')' || (90000 + floor(random()*9999))::INT,
            'Rua ' || (floor(random()*200)+1)::TEXT,
            20 + floor(random()*40)::INT,
            round(random()*3000+1500,2)
        );
    END LOOP;
END;
$$;

-- Procedure para gerar veículos
CREATE OR REPLACE PROCEDURE gerar_veiculos(qtd INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..qtd LOOP
        INSERT INTO veiculos (matricula, nome, modelo, comprimento, potMotor, vlDiaria, codTipo)
        VALUES (
            i,
            'Veiculo_' || i,
            'Modelo_' || i,
            3 + floor(random()*7)::INT,
            50 + floor(random()*300)::INT,
            100 + floor(random()*400)::INT,
            1
        );
    END LOOP;
END;
$$;

-- Procedure para gerar locações
CREATE OR REPLACE PROCEDURE gerar_locacoes(qtd INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    v_codLoc INT;
    v_cpf VARCHAR(15);
    v_func INT;
    v_mat INT;
BEGIN
    FOR i IN 1..qtd LOOP
        SELECT cpf INTO v_cpf FROM clientes ORDER BY random() LIMIT 1;
        SELECT codF INTO v_func FROM funcionarios ORDER BY random() LIMIT 1;
        SELECT matricula INTO v_mat FROM veiculos ORDER BY random() LIMIT 1;

        v_codLoc := i;

        INSERT INTO locacoes (codLoc, valor, inicio, fim, obs, matricula, codF, cpf)
        VALUES (
            v_codLoc,
            round(random()*500+100,2),
            CURRENT_DATE - (floor(random()*100)::INT),
            CURRENT_DATE,
            'Locação gerada automaticamente',
            v_mat, v_func, v_cpf
        );
    END LOOP;
END;
$$;

-- Procedure principal para popular todo o banco
CREATE OR REPLACE PROCEDURE popular_banco(qtd_clientes INT, qtd_veiculos INT, qtd_funcionarios INT, qtd_locacoes INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cpf_especial VARCHAR(15);
    v_func INT;
    v_mat INT;
    v_count INT := 0;
BEGIN
    -- gerar dados básicos
    CALL gerar_clientes(qtd_clientes);
    CALL gerar_funcionarios(qtd_funcionarios);
    CALL gerar_veiculos(qtd_veiculos);
    CALL gerar_locacoes(qtd_locacoes);

    -- escolher um cliente "especial"
    SELECT cpf INTO v_cpf_especial FROM clientes ORDER BY random() LIMIT 1;
    SELECT codF INTO v_func FROM funcionarios ORDER BY random() LIMIT 1;

    -- garantir que ele alugue TODOS os veículos
    FOR v_mat IN SELECT matricula FROM veiculos LOOP
        v_count := v_count + 1;
        INSERT INTO locacoes (codLoc, valor, inicio, fim, obs, matricula, codF, cpf)
        VALUES (
            10000+v_count,
            200,
            CURRENT_DATE - 10,
            CURRENT_DATE,
            'Cliente especial alugou todos os veículos',
            v_mat, v_func, v_cpf_especial
        );
    END LOOP;
END;
$$;
