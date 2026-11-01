CREATE SCHEMA catalog;

CREATE TABLE catalog.locales (
    code VARCHAR(35) PRIMARY KEY CHECK (btrim(code) <> '')
);

CREATE TABLE catalog.agent_ranks (
    code VARCHAR(8) PRIMARY KEY CHECK (btrim(code) <> ''),
    symbol TEXT NOT NULL CHECK (btrim(symbol) <> '')
);

CREATE TABLE catalog.elements (
    code VARCHAR(64) PRIMARY KEY CHECK (btrim(code) <> ''),
    base_element_code VARCHAR(64) REFERENCES catalog.elements(code),
    name_is_provisional BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (base_element_code IS NULL OR base_element_code <> code)
);

CREATE TABLE catalog.element_names (
    element_code VARCHAR(64) NOT NULL REFERENCES catalog.elements(code),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (element_code, locale)
);

CREATE TABLE catalog.specialties (
    code VARCHAR(64) PRIMARY KEY CHECK (btrim(code) <> '')
);

CREATE TABLE catalog.specialty_names (
    specialty_code VARCHAR(64) NOT NULL REFERENCES catalog.specialties(code),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (specialty_code, locale)
);

CREATE TABLE catalog.factions (
    code VARCHAR(64) PRIMARY KEY CHECK (btrim(code) <> '')
);

CREATE TABLE catalog.faction_names (
    faction_code VARCHAR(64) NOT NULL REFERENCES catalog.factions(code),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (faction_code, locale)
);

CREATE TABLE catalog.agents (
    id BIGINT PRIMARY KEY CHECK (id > 0),
    rank_code VARCHAR(8) NOT NULL REFERENCES catalog.agent_ranks(code),
    element_code VARCHAR(64) NOT NULL REFERENCES catalog.elements(code),
    specialty_code VARCHAR(64) NOT NULL REFERENCES catalog.specialties(code),
    faction_code VARCHAR(64) NOT NULL REFERENCES catalog.factions(code),
    release_stage VARCHAR(16) NOT NULL DEFAULT 'UNKNOWN'
        CHECK (release_stage IN ('UNKNOWN', 'BETA', 'RELEASED'))
);

CREATE TABLE catalog.agent_names (
    agent_id BIGINT NOT NULL REFERENCES catalog.agents(id),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (agent_id, locale)
);

COMMENT ON TABLE catalog.agents IS
    'Metadados do catálogo. Ausência de atributos base não significa atributos de valor zero.';
COMMENT ON COLUMN catalog.agents.id IS
    'ID numérico fornecido pelo usuário a partir da fonte. Não é gerado pelo banco.';
COMMENT ON COLUMN catalog.elements.base_element_code IS
    'Relação de classificação. Não implica colapsar variantes ou aplicar fórmulas de combate.';

CREATE TABLE catalog.stat_types (
    code VARCHAR(64) PRIMARY KEY CHECK (btrim(code) <> ''),
    unit VARCHAR(24) NOT NULL CHECK (unit IN ('NUMBER', 'PERCENT_POINTS'))
);

CREATE TABLE catalog.agent_base_profiles (
    agent_id BIGINT PRIMARY KEY REFERENCES catalog.agents(id),
    agent_level SMALLINT NOT NULL CHECK (agent_level > 0),
    passive_bonuses_complete BOOLEAN NOT NULL DEFAULT FALSE,
    source_note TEXT NOT NULL CHECK (btrim(source_note) <> '')
);

CREATE TABLE catalog.agent_base_stats (
    agent_id BIGINT NOT NULL REFERENCES catalog.agent_base_profiles(agent_id),
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (agent_id, stat_code)
);

CREATE TABLE catalog.agent_passive_bonuses (
    agent_id BIGINT NOT NULL REFERENCES catalog.agent_base_profiles(agent_id),
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code),
    application_stage VARCHAR(8) NOT NULL CHECK (application_stage IN ('BASE', 'SHEET')),
    modifier VARCHAR(8) NOT NULL CHECK (modifier IN ('FLAT', 'PERCENT')),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (agent_id, stat_code, application_stage, modifier),
    CHECK (application_stage <> 'BASE' OR modifier = 'FLAT'),
    CHECK (modifier <> 'PERCENT' OR stat_code IN (
        'HEALTH', 'ATTACK', 'DEFENSE', 'IMPACT', 'ANOMALY_MASTERY',
        'ANOMALY_PROFICIENCY', 'ENERGY_REGEN'
    ))
);

COMMENT ON TABLE catalog.agent_base_profiles IS
    'Um perfil no nível máximo por personagem. Não modela progressão de nível ou de passiva.';
COMMENT ON COLUMN catalog.agent_base_profiles.passive_bonuses_complete IS
    'TRUE somente após conferir todos os bônus permanentes da passiva maximizada; ausência não significa bônus zero.';
COMMENT ON TABLE catalog.agent_base_stats IS
    'Base crua no nível máximo, sem os bônus da passiva. Atributo ausente não equivale a zero informado.';
COMMENT ON TABLE catalog.agent_passive_bonuses IS
    'Totais da passiva maximizada por atributo, etapa e modificador. Efeitos de combate estão fora desta tabela.';
COMMENT ON COLUMN catalog.agent_passive_bonuses.application_stage IS
    'BASE soma à base crua antes dos multiplicadores; SHEET entra junto aos demais modificadores de ficha.';
COMMENT ON COLUMN catalog.agent_passive_bonuses.modifier IS
    'FLAT soma na unidade do atributo (inclusive pontos percentuais para taxas); PERCENT usa pontos percentuais relativos à base.';
