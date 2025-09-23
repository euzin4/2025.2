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
        
        /*Codh fictício (supondo que existam registros em habilitacoes)*/
        SELECT codh INTO v_codh
        FROM public.habilitacoes
        ORDER BY random()
        LIMIT 1;
        
        INSERT INTO public.clientes (cpf, nome, endereco, estado_civil, num_filhos, data_nasc, telefone, codh)
        VALUES (v_cpf, v_nome, v_endereco, v_estado_civil, v_num_filhos, v_data_nasc, v_telefone, v_codh);
    END LOOP;
END;
$$;
