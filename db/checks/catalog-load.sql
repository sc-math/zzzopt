-- Verificações da carga V2; dados fictícios e alterações são revertidos ao final.
BEGIN;

\echo 'Deve aplicar V1 e V2 uma única vez e preservar as quantidades do catálogo'
DO $test$
BEGIN
    IF (SELECT count(*) FROM public.flyway_schema_history WHERE version IS NOT NULL) <> 2
       OR (SELECT count(*) FROM public.flyway_schema_history WHERE version IN ('1', '2') AND success) <> 2
       OR (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'catalog' AND table_type = 'BASE TABLE') <> 23
       OR (SELECT count(*) FROM catalog.agents) <> 63
       OR (SELECT count(*) FROM catalog.agent_base_profiles WHERE agent_level = 60 AND passive_bonuses_complete) <> 63
       OR (SELECT count(*) FROM catalog.agent_base_stats) <> 632
       OR (SELECT count(*) FROM catalog.agent_passive_bonuses) <> 124
       OR (SELECT count(*) FROM catalog.w_engines) <> 102
       OR (SELECT count(*) FROM catalog.w_engine_names WHERE locale = 'en') <> 102
       OR (SELECT count(*) FROM catalog.w_engine_base_stats) <> 102
       OR (SELECT count(*) FROM catalog.w_engine_advanced_stats) <> 102
       OR (SELECT count(*) FROM catalog.disc_sets) <> 30
       OR (SELECT count(*) FROM catalog.disc_set_names WHERE locale = 'en') <> 30
       OR (SELECT count(*) FROM catalog.disc_set_effects) <> 60
       OR (SELECT count(*) FROM catalog.disc_set_effect_bonuses) <> 26 THEN
        RAISE EXCEPTION 'Histórico, esquema ou quantidades da carga divergentes.';
    END IF;
END
$test$;

\echo 'Deve preservar bases cruas e classificar percentuais de passivas sem somá-los à base'
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1011 AND stat_code = 'ATTACK' AND value = 583)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1011 AND stat_code = 'IMPACT' AND value = 118)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 1011 AND stat_code = 'ATTACK' AND application_stage = 'BASE' AND modifier = 'FLAT' AND value = 75)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 1011 AND stat_code = 'IMPACT' AND application_stage = 'BASE' AND modifier = 'FLAT' AND value = 18)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1031 AND stat_code = 'ATTACK' AND value = 574)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1491 AND stat_code = 'ATTACK' AND value = 675)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 1491 AND stat_code = 'ATTACK' AND application_stage = 'SHEET' AND modifier = 'PERCENT' AND value = 21)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 1441 AND stat_code = 'HEALTH' AND application_stage = 'SHEET' AND modifier = 'PERCENT' AND value = 18)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 1371 AND stat_code = 'HEALTH' AND application_stage = 'BASE' AND modifier = 'FLAT' AND value = 420)
       OR (SELECT count(*) FROM catalog.agent_base_stats WHERE agent_id IN (1491, 1551) AND stat_code = 'ENERGY_REGEN' AND value = 1) <> 2 THEN
        RAISE EXCEPTION 'Base crua, etapa da passiva ou recuperação de energia alteradas.';
    END IF;
    IF (SELECT count(*) FROM catalog.agent_base_stats WHERE agent_id IN (1601, 1611) AND stat_code = 'ATTACK' AND value = 626) <> 2
       OR (SELECT count(*) FROM catalog.agent_base_stats WHERE agent_id IN (1601, 1611) AND stat_code = 'LACERATION_DAMAGE' AND value = 150) <> 2
       OR (SELECT count(*) FROM catalog.agent_base_stats WHERE agent_id IN (1601, 1611) AND stat_code = 'AUTOMATIC_SHARPNESS_ACCUMULATION' AND value = 1.5) <> 2
       OR (SELECT count(*) FROM catalog.agent_passive_bonuses WHERE agent_id IN (1601, 1611) AND stat_code = 'CRIT_RATE' AND application_stage = 'SHEET' AND modifier = 'FLAT' AND value = 28.8) <> 2
       OR EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id IN (1601, 1611, 1371) AND stat_code = 'ATTACK')
       OR NOT EXISTS (SELECT 1 FROM catalog.agents WHERE id = 1601 AND release_stage = 'BETA')
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1441 AND stat_code = 'AUTOMATIC_ADRENALINE_ACCUMULATION' AND value = 0)
       OR EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 1441 AND stat_code = 'ENERGY_REGEN') THEN
        RAISE EXCEPTION 'Recursos próprios das classes, estágio beta ou bônus não fornecidos alterados.';
    END IF;
END
$test$;

\echo 'Deve preservar motores de DEF, unidades e correções de Bravo e Grip'
DO $test$
BEGIN
    IF (SELECT count(*) FROM catalog.w_engines WHERE rank_code = 'S') <> 49
       OR (SELECT count(*) FROM catalog.w_engines WHERE rank_code = 'A') <> 37
       OR (SELECT count(*) FROM catalog.w_engines WHERE rank_code = 'B') <> 16
       OR (SELECT count(*) FROM catalog.w_engine_base_stats WHERE stat_code = 'DEFENSE') <> 4
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_base_stats WHERE w_engine_id = 14161 AND stat_code = 'DEFENSE' AND value = 431)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_advanced_stats WHERE w_engine_id = 14161 AND stat_code = 'DEFENSE' AND modifier = 'PERCENT' AND value = 48)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_base_stats WHERE w_engine_id = 12011 AND stat_code = 'ATTACK' AND value = 356)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_advanced_stats WHERE w_engine_id = 12011 AND stat_code = 'ANOMALY_PROFICIENCY' AND modifier = 'FLAT' AND value = 60)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_base_stats WHERE w_engine_id = 14163 AND stat_code = 'ATTACK' AND value = 713)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_advanced_stats WHERE w_engine_id = 14163 AND stat_code = 'CRIT_RATE' AND modifier = 'FLAT' AND value = 24)
       OR NOT EXISTS (SELECT 1 FROM catalog.w_engine_advanced_stats WHERE w_engine_id = 14150 AND stat_code = 'ANOMALY_MASTERY' AND modifier = 'PERCENT' AND value = 30) THEN
        RAISE EXCEPTION 'Rank, unidade, DEF básica ou correções dos motores não preservados.';
    END IF;
END
$test$;

\echo 'Deve aplicar somente os bônus de ficha dos conjuntos e preservar fontes e condições de combate'
DO $test$
BEGIN
    IF (SELECT count(*) FROM catalog.disc_set_effects WHERE required_pieces = 2 AND context = 'SHEET') <> 26
       OR (SELECT count(*) FROM catalog.disc_set_effects WHERE required_pieces = 2 AND context = 'COMBAT') <> 4
       OR (SELECT count(*) FROM catalog.disc_set_effects WHERE required_pieces = 4 AND context = 'COMBAT') <> 30
       OR EXISTS (SELECT 1 FROM catalog.disc_set_effects WHERE context IS NULL OR btrim(source_description) = '')
       OR EXISTS (SELECT 1 FROM catalog.disc_set_effect_bonuses b JOIN catalog.disc_set_effects e USING (disc_set_id, required_pieces, effect_key) WHERE e.context <> 'SHEET')
       OR NOT EXISTS (SELECT 1 FROM catalog.disc_set_effect_bonuses WHERE disc_set_id = 33900 AND stat_code = 'WIND_DAMAGE_BONUS' AND modifier = 'FLAT' AND value = 10)
       OR NOT EXISTS (SELECT 1 FROM catalog.disc_set_effects WHERE disc_set_id = 31900 AND required_pieces = 2 AND context = 'COMBAT')
       OR NOT EXISTS (SELECT 1 FROM catalog.disc_set_effects WHERE disc_set_id = 32300 AND required_pieces = 4 AND analysis #>> '{components,0,maximum}' = '53')
       OR NOT EXISTS (SELECT 1 FROM catalog.disc_set_effects WHERE disc_set_id = 31000 AND required_pieces = 4 AND analysis #> '{components,0,maximum}' = 'null'::JSONB) THEN
        RAISE EXCEPTION 'Contextos, unidades, máximos condicionais ou pendências de combate alterados.';
    END IF;
END
$test$;

\echo 'Deve rejeitar motores sem especialidade, atributos negativos e efeitos duplicados ou sem conjunto'
DO $test$
BEGIN
    BEGIN
        UPDATE catalog.w_engines SET specialty_code = 'INEXISTENTE' WHERE id = 14150;
        RAISE EXCEPTION 'Especialidade inexistente aceita.';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        UPDATE catalog.w_engine_base_stats SET value = -1 WHERE w_engine_id = 14150;
        RAISE EXCEPTION 'Atributo básico negativo aceito.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.disc_set_effects SELECT * FROM catalog.disc_set_effects WHERE disc_set_id = 32800 AND required_pieces = 2;
        RAISE EXCEPTION 'Efeito duplicado aceito.';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.disc_set_effects (disc_set_id, required_pieces, effect_key, context, source_description, analysis)
        VALUES (999999, 2, '2PC', 'COMBAT', 'Fixture fictícia', '{}'::JSONB);
        RAISE EXCEPTION 'Efeito sem conjunto aceito.';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
END
$test$;

ROLLBACK;
\echo 'Carga V2 validada; alterações dos testes revertidas'
