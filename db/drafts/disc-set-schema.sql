-- Referência histórica do esquema de conjuntos, incorporado à V2 antes de sua primeira aplicação.
-- Não executar separadamente: a criação destas tabelas é responsabilidade da migration V2.
CREATE TABLE catalog.disc_sets (
    id BIGINT PRIMARY KEY CHECK (id > 0),
    source_url TEXT NOT NULL CHECK (btrim(source_url) <> ''),
    source_note TEXT NOT NULL CHECK (btrim(source_note) <> '')
);

CREATE TABLE catalog.disc_set_names (
    disc_set_id BIGINT NOT NULL REFERENCES catalog.disc_sets(id),
    locale VARCHAR(35) NOT NULL REFERENCES catalog.locales(code),
    name TEXT NOT NULL CHECK (btrim(name) <> ''),
    PRIMARY KEY (disc_set_id, locale)
);

CREATE TABLE catalog.disc_set_effects (
    disc_set_id BIGINT NOT NULL REFERENCES catalog.disc_sets(id),
    required_pieces SMALLINT NOT NULL CHECK (required_pieces IN (2, 4)),
    effect_key VARCHAR(64) NOT NULL CHECK (btrim(effect_key) <> ''),
    context VARCHAR(8) CHECK (context IN ('SHEET', 'COMBAT')),
    source_description TEXT NOT NULL CHECK (btrim(source_description) <> ''),
    analysis JSONB NOT NULL CHECK (jsonb_typeof(analysis) = 'object'),
    review_note TEXT,
    PRIMARY KEY (disc_set_id, required_pieces, effect_key),
    CHECK (context IS NOT NULL OR (review_note IS NOT NULL AND btrim(review_note) <> ''))
);

CREATE TABLE catalog.disc_set_effect_bonuses (
    disc_set_id BIGINT NOT NULL,
    required_pieces SMALLINT NOT NULL,
    effect_key VARCHAR(64) NOT NULL,
    stat_code VARCHAR(64) NOT NULL REFERENCES catalog.stat_types(code),
    modifier VARCHAR(8) NOT NULL CHECK (modifier IN ('FLAT', 'PERCENT')),
    value NUMERIC NOT NULL CHECK (value >= 0 AND value < 'Infinity'::NUMERIC),
    PRIMARY KEY (disc_set_id, required_pieces, effect_key, stat_code, modifier),
    FOREIGN KEY (disc_set_id, required_pieces, effect_key)
        REFERENCES catalog.disc_set_effects(disc_set_id, required_pieces, effect_key),
    CHECK (modifier <> 'PERCENT' OR stat_code IN (
        'HEALTH', 'ATTACK', 'DEFENSE', 'IMPACT', 'ANOMALY_MASTERY',
        'ANOMALY_PROFICIENCY', 'ENERGY_REGEN'
    ))
);

COMMENT ON TABLE catalog.disc_sets IS
    'Conjuntos, não peças pessoais. IDs extraídos do texto das URLs fornecidas, sem acesso ao site.';
COMMENT ON TABLE catalog.disc_set_effects IS
    'Fonte original e análise de cada efeito. Vários efeitos podem compartilhar requisito de peças.';
COMMENT ON COLUMN catalog.disc_set_effects.context IS
    'SHEET ou COMBAT confirmado; NULL indica classificação pendente, nunca bônus zero ou efeito ignorado silenciosamente.';
COMMENT ON COLUMN catalog.disc_set_effects.analysis IS
    'Resumo declarativo com máximos, condições, duração e acúmulos; não é código executável nem simulação de dano.';
COMMENT ON TABLE catalog.disc_set_effect_bonuses IS
    'Bônus de ficha estruturados. Importador futuro deve exigir contexto SHEET e resolver pendências antes do cálculo.';
