-- Simplificação aprovada: ranks por domínio e atributos de motor unificados.
-- Preserva V1/V2 e os dados; execução transacional pelo Flyway/PostgreSQL.
DO $migration$
BEGIN
    IF EXISTS (
        (SELECT code, symbol FROM catalog.agent_ranks
         EXCEPT ALL SELECT * FROM (VALUES ('A', 'A'), ('S', 'S'), ('I', '∞')) expected(code, symbol))
        UNION ALL
        (SELECT * FROM (VALUES ('A', 'A'), ('S', 'S'), ('I', '∞')) expected(code, symbol)
         EXCEPT ALL SELECT code, symbol FROM catalog.agent_ranks)
    ) OR EXISTS (
        (SELECT code FROM catalog.w_engine_ranks
         EXCEPT ALL SELECT * FROM (VALUES ('B'), ('A'), ('S')) expected(code))
        UNION ALL
        (SELECT * FROM (VALUES ('B'), ('A'), ('S')) expected(code)
         EXCEPT ALL SELECT code FROM catalog.w_engine_ranks)
    ) THEN
        RAISE EXCEPTION 'Ranks/símbolos existentes diferem dos domínios aprovados; migração abortada sem descarte.';
    END IF;

    IF EXISTS (SELECT w_engine_id FROM catalog.w_engine_base_stats GROUP BY w_engine_id HAVING count(*) > 1)
       OR EXISTS (SELECT w_engine_id FROM catalog.w_engine_advanced_stats GROUP BY w_engine_id HAVING count(*) > 1) THEN
        RAISE EXCEPTION 'Motor com mais de uma parcela por papel; revisar dados antes da unificação.';
    END IF;
END
$migration$;

ALTER TABLE catalog.agents
    ADD CONSTRAINT agents_rank_code_check CHECK (rank_code IN ('A', 'S', 'I'));
ALTER TABLE catalog.w_engines
    ADD CONSTRAINT w_engines_rank_code_check CHECK (rank_code IN ('B', 'A', 'S'));

CREATE TABLE catalog.w_engine_stats (
    w_engine_id BIGINT NOT NULL REFERENCES catalog.w_engines(id),
    role VARCHAR(8) NOT NULL CHECK (role IN ('BASE', 'ADVANCED')),
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code),
    modifier VARCHAR(8) NOT NULL CHECK (modifier IN ('FLAT', 'PERCENT')),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (w_engine_id, role),
    CHECK (role <> 'BASE' OR (stat_code IN ('ATTACK', 'DEFENSE') AND modifier = 'FLAT')),
    CHECK (modifier <> 'PERCENT' OR stat_code IN (
        'HEALTH', 'ATTACK', 'DEFENSE', 'IMPACT', 'ANOMALY_MASTERY',
        'ANOMALY_PROFICIENCY', 'ENERGY_REGEN'
    ))
);

INSERT INTO catalog.w_engine_stats (w_engine_id, role, stat_code, modifier, value)
SELECT w_engine_id, 'BASE', stat_code, 'FLAT', value FROM catalog.w_engine_base_stats
UNION ALL
SELECT w_engine_id, 'ADVANCED', stat_code, modifier, value FROM catalog.w_engine_advanced_stats;

DO $migration$
BEGIN
    IF EXISTS (
        (SELECT w_engine_id, 'BASE'::VARCHAR, stat_code, 'FLAT'::VARCHAR, value FROM catalog.w_engine_base_stats
         UNION ALL
         SELECT w_engine_id, 'ADVANCED', stat_code, modifier, value FROM catalog.w_engine_advanced_stats)
        EXCEPT ALL
        SELECT w_engine_id, role, stat_code, modifier, value FROM catalog.w_engine_stats
    ) OR EXISTS (
        SELECT w_engine_id, role, stat_code, modifier, value FROM catalog.w_engine_stats
        EXCEPT ALL
        (SELECT w_engine_id, 'BASE'::VARCHAR, stat_code, 'FLAT'::VARCHAR, value FROM catalog.w_engine_base_stats
         UNION ALL
         SELECT w_engine_id, 'ADVANCED', stat_code, modifier, value FROM catalog.w_engine_advanced_stats)
    ) THEN
        RAISE EXCEPTION 'A cópia alterou atributos dos motores; migração abortada.';
    END IF;
END
$migration$;

DROP TABLE catalog.w_engine_base_stats;
DROP TABLE catalog.w_engine_advanced_stats;

ALTER TABLE catalog.agents DROP CONSTRAINT agents_rank_code_fkey;
ALTER TABLE catalog.w_engines DROP CONSTRAINT w_engines_rank_code_fkey;
DROP TABLE catalog.agent_ranks;
DROP TABLE catalog.w_engine_ranks;

COMMENT ON COLUMN catalog.agents.rank_code IS
    'Rank de agente A/S/I, correspondente a AgentRank; I tem símbolo de exibição ∞.';
COMMENT ON COLUMN catalog.w_engines.rank_code IS
    'Rank de motor B/A/S, correspondente a WEngineRank, independente do rank de agente.';
COMMENT ON TABLE catalog.w_engine_stats IS
    'Atributos máximos do motor por papel: BASE antes dos multiplicadores; ADVANCED junto aos itens.';
COMMENT ON COLUMN catalog.w_engine_stats.modifier IS
    'BASE é FLAT em ATTACK/DEFENSE. ADVANCED mantém FLAT na unidade do atributo ou PERCENT relativo à base.';
