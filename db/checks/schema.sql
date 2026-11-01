\echo 'Deve aplicar somente a V1 e manter a V2 sem execução'
DO $test$
BEGIN
    IF (SELECT count(*) FROM public.flyway_schema_history WHERE version IS NOT NULL) <> 1
       OR NOT EXISTS (SELECT 1 FROM public.flyway_schema_history WHERE version = '1' AND success) THEN
        RAISE EXCEPTION 'O histórico não contém exclusivamente a V1 aplicada com sucesso.';
    END IF;
END
$test$;

\echo 'Deve criar todas as tabelas e manter o catálogo sem dados enquanto a V2 está em preenchimento'
DO $test$
DECLARE
    table_name TEXT;
    row_count BIGINT;
BEGIN
    FOREACH table_name IN ARRAY ARRAY[
        'locales', 'agent_ranks', 'elements', 'element_names', 'specialties',
        'specialty_names', 'factions', 'faction_names', 'agents', 'agent_names',
        'stat_types', 'agent_base_profiles', 'agent_base_stats', 'agent_passive_bonuses'
    ] LOOP
        IF to_regclass(format('catalog.%I', table_name)) IS NULL THEN
            RAISE EXCEPTION 'Tabela ausente: %.', table_name;
        END IF;
        EXECUTE format('SELECT count(*) FROM catalog.%I', table_name) INTO row_count;
        IF row_count <> 0 THEN
            RAISE EXCEPTION 'A tabela % recebeu dados antes da carga final.', table_name;
        END IF;
    END LOOP;
END
$test$;

\echo 'Estrutura vazia e histórico da V1 validados'
