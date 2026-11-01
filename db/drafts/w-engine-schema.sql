-- Referência histórica do esquema de motores, incorporado à V2 antes de sua primeira aplicação.
-- Não executar separadamente: a criação destas tabelas é responsabilidade da migration V2.
CREATE TABLE catalog.w_engine_ranks (
    code VARCHAR(8) PRIMARY KEY CHECK (btrim(code) <> '')
);

CREATE TABLE catalog.w_engines (
    id BIGINT PRIMARY KEY CHECK (id > 0),
    rank_code VARCHAR(8) NOT NULL REFERENCES catalog.w_engine_ranks(code),
    specialty_code VARCHAR(64) NOT NULL REFERENCES catalog.specialties(code),
    passives_reviewed BOOLEAN NOT NULL DEFAULT FALSE,
    source_note TEXT NOT NULL CHECK (btrim(source_note) <> '')
);

CREATE TABLE catalog.w_engine_names (
    w_engine_id BIGINT NOT NULL REFERENCES catalog.w_engines(id),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (w_engine_id, locale)
);

CREATE TABLE catalog.w_engine_base_stats (
    w_engine_id BIGINT NOT NULL REFERENCES catalog.w_engines(id),
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code)
        CHECK (stat_code IN ('ATTACK', 'DEFENSE')),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (w_engine_id, stat_code)
);

CREATE TABLE catalog.w_engine_advanced_stats (
    w_engine_id BIGINT NOT NULL REFERENCES catalog.w_engines(id),
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code),
    modifier VARCHAR(8) NOT NULL CHECK (modifier IN ('FLAT', 'PERCENT')),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (w_engine_id, stat_code, modifier),
    CHECK (modifier <> 'PERCENT' OR stat_code IN (
        'HEALTH', 'ATTACK', 'DEFENSE', 'IMPACT', 'ANOMALY_MASTERY',
        'ANOMALY_PROFICIENCY', 'ENERGY_REGEN'
    ))
);

COMMENT ON TABLE catalog.w_engines IS
    'Catálogo de motores com IDs fornecidos pelo usuário; especialidade e rank independentes dos nomes.';
COMMENT ON COLUMN catalog.w_engines.passives_reviewed IS
    'Revisão dos detalhes de combate para a v2 do programa. FALSE não bloqueia a v1, que usa somente base e atributo avançado.';
COMMENT ON TABLE catalog.w_engine_base_stats IS
    'Atributos básicos máximos fornecidos: ATQ ou DEF, somados à base correspondente. Ausência não é zero.';
COMMENT ON TABLE catalog.w_engine_advanced_stats IS
    'Atributos avançados máximos; FLAT usa a unidade do atributo, PERCENT usa pontos percentuais relativos à base.';
