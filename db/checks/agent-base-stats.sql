-- Adaptação autorizada pelo usuário em 2026-10-31 para base crua e passiva separadas.
-- Não executa a V2: toda a fixture é criada nesta transação e revertida ao final.
BEGIN;

INSERT INTO catalog.agent_ranks (code, symbol) VALUES ('TEST', 'T');
INSERT INTO catalog.elements (code) VALUES ('TEST');
INSERT INTO catalog.specialties (code) VALUES ('TEST');
INSERT INTO catalog.factions (code) VALUES ('TEST');
INSERT INTO catalog.agents (id, rank_code, element_code, specialty_code, faction_code)
VALUES (9000000000000000000, 'TEST', 'TEST', 'TEST', 'TEST');
INSERT INTO catalog.stat_types (code, unit) VALUES
    ('HEALTH', 'NUMBER'), ('ATTACK', 'NUMBER'), ('DEFENSE', 'NUMBER'),
    ('IMPACT', 'NUMBER'), ('CRIT_RATE', 'PERCENT_POINTS'), ('CRIT_DAMAGE', 'PERCENT_POINTS'),
    ('ANOMALY_MASTERY', 'NUMBER'), ('ANOMALY_PROFICIENCY', 'NUMBER'),
    ('PENETRATION_RATE', 'PERCENT_POINTS'), ('ENERGY_REGEN', 'NUMBER');
INSERT INTO catalog.agent_base_profiles (agent_id, agent_level, source_note)
VALUES (9000000000000000000, 60, 'Fixture com os valores da Anby, sem carregar o catálogo real.');

\echo 'Deve distinguir passiva pendente e atributos ausentes de bônus e valores explicitamente zero'
DO $test$
BEGIN
    IF EXISTS (SELECT 1 FROM catalog.agent_base_stats WHERE agent_id = 9000000000000000000)
       OR EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses WHERE agent_id = 9000000000000000000)
       OR EXISTS (SELECT 1 FROM catalog.agent_base_profiles
                  WHERE agent_id = 9000000000000000000 AND passive_bonuses_complete) THEN
        RAISE EXCEPTION 'O perfil recebeu valores ou confirmação de passiva não fornecidos.';
    END IF;
END
$test$;

-- Base crua derivada dos totais confirmados: ATQ 658 - 75; Impacto 136 - 18.
INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (9000000000000000000, 'HEALTH', 7500),
    (9000000000000000000, 'ATTACK', 583),
    (9000000000000000000, 'DEFENSE', 612),
    (9000000000000000000, 'IMPACT', 118),
    (9000000000000000000, 'CRIT_RATE', 5),
    (9000000000000000000, 'CRIT_DAMAGE', 50),
    (9000000000000000000, 'ANOMALY_MASTERY', 94),
    (9000000000000000000, 'ANOMALY_PROFICIENCY', 93),
    (9000000000000000000, 'PENETRATION_RATE', 0),
    (9000000000000000000, 'ENERGY_REGEN', 1.2);
INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
VALUES (9000000000000000000, 'ATTACK', 'BASE', 'FLAT', 75),
       (9000000000000000000, 'IMPACT', 'BASE', 'FLAT', 18);
UPDATE catalog.agent_base_profiles SET passive_bonuses_complete = TRUE WHERE agent_id = 9000000000000000000;

\echo 'Deve preservar os dez valores fornecidos da Anby ao recompor base crua e passiva maximizada'
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM catalog.agent_base_profiles
        WHERE agent_id = 9000000000000000000 AND agent_level = 60 AND passive_bonuses_complete) THEN
        RAISE EXCEPTION 'Condição do perfil máximo incorreta.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM (VALUES
            ('HEALTH', 7500), ('ATTACK', 658), ('DEFENSE', 612), ('IMPACT', 136),
            ('CRIT_RATE', 5), ('CRIT_DAMAGE', 50), ('ANOMALY_MASTERY', 94),
            ('ANOMALY_PROFICIENCY', 93), ('PENETRATION_RATE', 0), ('ENERGY_REGEN', 1.2)
        ) AS expected(stat_code, value)
        LEFT JOIN catalog.agent_base_stats actual
          ON actual.agent_id = 9000000000000000000 AND actual.stat_code = expected.stat_code
        LEFT JOIN catalog.agent_passive_bonuses passive
          ON passive.agent_id = actual.agent_id AND passive.stat_code = actual.stat_code
         AND passive.application_stage = 'BASE' AND passive.modifier = 'FLAT'
        WHERE actual.value + COALESCE(passive.value, 0) IS DISTINCT FROM expected.value
    ) THEN
        RAISE EXCEPTION 'A separação alterou ou omitiu um dos dez atributos fornecidos da Anby.';
    END IF;
    IF (SELECT value FROM catalog.agent_base_stats
        WHERE agent_id = 9000000000000000000 AND stat_code = 'ATTACK') <> 583
       OR (SELECT value FROM catalog.agent_base_stats
        WHERE agent_id = 9000000000000000000 AND stat_code = 'IMPACT') <> 118 THEN
        RAISE EXCEPTION 'A base crua contém bônus de passiva embutidos.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM catalog.stat_types WHERE code = 'CRIT_RATE' AND unit = 'PERCENT_POINTS')
       OR NOT EXISTS (SELECT 1 FROM catalog.stat_types WHERE code = 'ENERGY_REGEN' AND unit = 'NUMBER') THEN
        RAISE EXCEPTION 'Unidades dos atributos incorretas.';
    END IF;
END
$test$;

\echo 'Deve guardar bônus percentuais e aditivos de ficha separados dos acréscimos à base'
-- Casos fictícios de estrutura, sem afirmar os bônus de Sunna ou Manato.
INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value) VALUES
    (9000000000000000000, 'ATTACK', 'SHEET', 'PERCENT', 21),
    (9000000000000000000, 'ATTACK', 'SHEET', 'FLAT', 10),
    (9000000000000000000, 'CRIT_RATE', 'SHEET', 'FLAT', 4.8);
DO $test$
BEGIN
    IF (SELECT count(*) FROM catalog.agent_passive_bonuses
        WHERE agent_id = 9000000000000000000 AND stat_code = 'ATTACK') <> 3
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_passive_bonuses
        WHERE agent_id = 9000000000000000000 AND stat_code = 'CRIT_RATE'
          AND application_stage = 'SHEET' AND modifier = 'FLAT' AND value = 4.8)
       OR (SELECT value FROM catalog.agent_base_stats
        WHERE agent_id = 9000000000000000000 AND stat_code = 'ATTACK') <> 583 THEN
        RAISE EXCEPTION 'Bônus de etapas ou unidades distintas foram confundidos.';
    END IF;
END
$test$;

\echo 'Deve manter zero explícito e aceitar taxa crítica acima de 100 ou 200 por cento'
UPDATE catalog.agent_base_stats SET value = 215
WHERE agent_id = 9000000000000000000 AND stat_code = 'CRIT_RATE';
DO $test$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats
        WHERE agent_id = 9000000000000000000 AND stat_code = 'CRIT_RATE' AND value = 215)
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_base_stats
        WHERE agent_id = 9000000000000000000 AND stat_code = 'PENETRATION_RATE' AND value = 0) THEN
        RAISE EXCEPTION 'Teto automático aplicado ou zero explícito perdido.';
    END IF;
END
$test$;

\echo 'Deve rejeitar valores negativos, atributos repetidos e códigos de bônus no lugar de atributos base'
DO $test$
BEGIN
    BEGIN
        UPDATE catalog.agent_base_stats SET value = -1
        WHERE agent_id = 9000000000000000000 AND stat_code = 'HEALTH';
        RAISE EXCEPTION 'Um atributo negativo foi aceito.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value)
        VALUES (9000000000000000000, 'CRIT_RATE', 220);
        RAISE EXCEPTION 'Um atributo base duplicado foi aceito.';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value)
        VALUES (9000000000000000000, 'ATTACK_PERCENT', 21);
        RAISE EXCEPTION 'Um tipo de bônus foi tratado como código de atributo base.';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
END
$test$;

\echo 'Deve rejeitar passivas duplicadas, sem perfil, negativas ou classificadas de forma inválida'
DO $test$
BEGIN
    BEGIN
        INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
        VALUES (9000000000000000000, 'ATTACK', 'BASE', 'FLAT', 75);
        RAISE EXCEPTION 'Um total de passiva duplicado foi aceito.';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
        VALUES (-1, 'ATTACK', 'BASE', 'FLAT', 75);
        RAISE EXCEPTION 'Um bônus sem perfil foi aceito.';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        UPDATE catalog.agent_passive_bonuses SET value = -1
        WHERE agent_id = 9000000000000000000 AND stat_code = 'IMPACT';
        RAISE EXCEPTION 'Um bônus negativo foi aceito.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
        VALUES (9000000000000000000, 'ATTACK', 'BASE', 'PERCENT', 21);
        RAISE EXCEPTION 'Um percentual de ficha foi aceito como acréscimo à base.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
        VALUES (9000000000000000000, 'CRIT_RATE', 'SHEET', 'PERCENT', 5);
        RAISE EXCEPTION 'Taxa crítica foi aceita como multiplicador da taxa base.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_passive_bonuses (agent_id, stat_code, application_stage, modifier, value)
        VALUES (9000000000000000000, 'ATTACK', 'COMBAT', 'FLAT', 75);
        RAISE EXCEPTION 'Efeito de combate foi aceito na tabela de bônus permanentes.';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
END
$test$;

ROLLBACK;
\echo 'Base crua e totais de passiva validados; fixture revertida'
