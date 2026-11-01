-- Catálogo: dados enviados manualmente pelo usuário em 2026-10-31; sem scraping.
-- Correção confirmada: Sunna = 1491; Sunbringer = 1601.
-- Apenas Sunbringer foi explicitamente identificada como beta. Demais estágios ficam UNKNOWN.
-- Aplicação solicitada pelo usuário após concluir a classificação dos conjuntos.
-- Inclui as nove tabelas adicionais; preserva a V1 já aplicada, sem reset do banco.
-- Não inventar base crua ou traduções; separar os totais da passiva maximizada.

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

INSERT INTO catalog.stat_types (code, unit) VALUES
    ('HEALTH', 'NUMBER'),
    ('ATTACK', 'NUMBER'),
    ('DEFENSE', 'NUMBER'),
    ('IMPACT', 'NUMBER'),
    ('CRIT_RATE', 'PERCENT_POINTS'),
    ('CRIT_DAMAGE', 'PERCENT_POINTS'),
    ('ANOMALY_MASTERY', 'NUMBER'),
    ('ANOMALY_PROFICIENCY', 'NUMBER'),
    ('PENETRATION_FLAT', 'NUMBER'),
    ('PENETRATION_RATE', 'PERCENT_POINTS'),
    ('ENERGY_REGEN', 'NUMBER'),
    ('SHEER_FORCE', 'NUMBER'),
    ('AUTOMATIC_ADRENALINE_ACCUMULATION', 'NUMBER'),
    ('AUTOMATIC_SHARPNESS_ACCUMULATION', 'NUMBER'),
    ('LACERATION_DAMAGE', 'PERCENT_POINTS'),
    ('PHYSICAL_DAMAGE_BONUS', 'PERCENT_POINTS'),
    ('FIRE_DAMAGE_BONUS', 'PERCENT_POINTS'),
    ('ICE_DAMAGE_BONUS', 'PERCENT_POINTS'),
    ('ELECTRIC_DAMAGE_BONUS', 'PERCENT_POINTS'),
    ('ETHER_DAMAGE_BONUS', 'PERCENT_POINTS');

INSERT INTO catalog.locales (code) VALUES ('en');
INSERT INTO catalog.agent_ranks (code, symbol) VALUES ('A', 'A'), ('S', 'S'), ('I', '∞');

WITH supplied(code, name, base_element_code, provisional) AS (
    VALUES
        ('PHYSICAL', 'Physical', NULL, FALSE),
        ('FIRE', 'Fire', NULL, FALSE),
        ('ICE', 'Ice', NULL, FALSE),
        ('ELECTRIC', 'Electric', NULL, FALSE),
        ('ETHER', 'Ether', NULL, FALSE),
        ('WIND', 'Wind', NULL, FALSE),
        ('LUMIFLUX', 'Lumiflux', NULL, FALSE),
        ('FROST', 'Frost', 'ICE', FALSE),
        ('AURIC_INK', 'Auric Ink', 'ETHER', FALSE),
        ('HONED_EDGE', 'Honed Edge', 'PHYSICAL', FALSE),
        ('GENESIS_FLARE', 'Genesis Flare', 'FIRE', TRUE)
), inserted AS (
    INSERT INTO catalog.elements (code, base_element_code, name_is_provisional)
    SELECT code, base_element_code, provisional FROM supplied
    RETURNING code
)
INSERT INTO catalog.element_names (element_code, locale, name)
SELECT supplied.code, 'en', supplied.name FROM supplied JOIN inserted USING (code);

WITH supplied(code, name) AS (
    VALUES
        ('ATTACK', 'Attack'),
        ('STUN', 'Stun'),
        ('ANOMALY', 'Anomaly'),
        ('SUPPORT', 'Support'),
        ('DEFENSE', 'Defense'),
        ('RUPTURE', 'Rupture'),
        ('ARMORER', 'Armorer')
), inserted AS (
    INSERT INTO catalog.specialties (code) SELECT code FROM supplied RETURNING code
)
INSERT INTO catalog.specialty_names (specialty_code, locale, name)
SELECT supplied.code, 'en', supplied.name FROM supplied JOIN inserted USING (code);

WITH supplied(code, name) AS (
    VALUES
        ('VICTORIA_HOUSEKEEPING', 'Victoria Housekeeping Co.'),
        ('SPOOK_SHACK', 'Spook Shack'),
        ('CUNNING_HARES', 'Cunning Hares'),
        ('BELOBOG_HEAVY_INDUSTRIES', 'Belobog Heavy Industries'),
        ('ANGELS_OF_DELUSION', 'Angels of Delusion'),
        ('SECTION_6', 'Hollow Special Operations Section 6'),
        ('STARS_OF_LYRA', 'Stars of Lyra'),
        ('KRAMPUS_COMPLIANCE_AUTHORITY', 'Krampus Compliance Authority'),
        ('SONS_OF_CALYDON', 'Sons of Calydon'),
        ('METROPOLITAN_ORDER_DIVISION', 'Metropolitan Order Division'),
        ('FLINT_WORKSHOP', 'Flint Workshop'),
        ('MOCKINGBIRD', 'Mockingbird'),
        ('CRIMINAL_INVESTIGATION', 'Criminal Investigation Special Response Team'),
        ('YUNKUI_SUMMIT', 'Yunkui Summit'),
        ('EXTERNAL_STRATEGY_DEPARTMENT', 'External Strategy Department'),
        ('OBOL_SQUAD', 'Obol Squad'),
        ('PHAETHON', 'Phaethon'),
        ('COVENANT_OF_DAYAT', 'Covenant of Dayat'),
        ('AIRSPACE_PATROL_DEPARTMENT', 'Airspace Patrol Department'),
        ('SILVER_SQUAD', 'Defense Force - Silver Squad'),
        ('ROSCAELIFER', 'Roscaelifer')
), inserted AS (
    INSERT INTO catalog.factions (code) SELECT code FROM supplied RETURNING code
)
INSERT INTO catalog.faction_names (faction_code, locale, name)
SELECT supplied.code, 'en', supplied.name FROM supplied JOIN inserted USING (code);

WITH supplied(id, name, rank_code, element_code, specialty_code, faction_code, release_stage) AS (
    VALUES
        (1211, 'Alexandrina Sebastiane', 'S', 'ELECTRIC', 'SUPPORT', 'VICTORIA_HOUSEKEEPING', 'UNKNOWN'),
        (1401, 'Alice Thymefield', 'S', 'PHYSICAL', 'ANOMALY', 'SPOOK_SHACK', 'UNKNOWN'),
        (1011, 'Anby Demara', 'A', 'ELECTRIC', 'STUN', 'CUNNING_HARES', 'UNKNOWN'),
        (1111, 'Anton Ivanov', 'A', 'ELECTRIC', 'ATTACK', 'BELOBOG_HEAVY_INDUSTRIES', 'UNKNOWN'),
        (1501, 'Aria', 'S', 'ETHER', 'ANOMALY', 'ANGELS_OF_DELUSION', 'UNKNOWN'),
        (1201, 'Asaba Harumasa', 'S', 'ELECTRIC', 'ATTACK', 'SECTION_6', 'UNKNOWN'),
        (1311, 'Astra Yao', 'S', 'ETHER', 'SUPPORT', 'STARS_OF_LYRA', 'UNKNOWN'),
        (1471, 'Banyue', 'S', 'FIRE', 'RUPTURE', 'KRAMPUS_COMPLIANCE_AUTHORITY', 'UNKNOWN'),
        (1121, 'Ben Bigger', 'A', 'FIRE', 'DEFENSE', 'BELOBOG_HEAVY_INDUSTRIES', 'UNKNOWN'),
        (1081, 'Billy Kid', 'A', 'PHYSICAL', 'ATTACK', 'CUNNING_HARES', 'UNKNOWN'),
        (1171, 'Burnice White', 'S', 'FIRE', 'ANOMALY', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1071, 'Caesar King', 'S', 'PHYSICAL', 'DEFENSE', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1521, 'Cissia', 'S', 'ELECTRIC', 'ATTACK', 'METROPOLITAN_ORDER_DIVISION', 'UNKNOWN'),
        (1611, 'Claret Flint', 'S', 'ELECTRIC', 'ARMORER', 'FLINT_WORKSHOP', 'UNKNOWN'),
        (1061, 'Corin Wickes', 'A', 'PHYSICAL', 'ATTACK', 'VICTORIA_HOUSEKEEPING', 'UNKNOWN'),
        (1481, 'Dialyn', 'S', 'PHYSICAL', 'STUN', 'KRAMPUS_COMPLIANCE_AUTHORITY', 'UNKNOWN'),
        (1191, 'Ellen Joe', 'S', 'ICE', 'ATTACK', 'VICTORIA_HOUSEKEEPING', 'UNKNOWN'),
        (1321, 'Evelyn Chevalier', 'S', 'FIRE', 'ATTACK', 'STARS_OF_LYRA', 'UNKNOWN'),
        (1181, 'Grace Howard', 'S', 'ELECTRIC', 'ANOMALY', 'BELOBOG_HEAVY_INDUSTRIES', 'UNKNOWN'),
        (1091, 'Hoshimi Miyabi', 'S', 'FROST', 'ANOMALY', 'SECTION_6', 'UNKNOWN'),
        (1291, 'Hugo Vlad', 'S', 'ICE', 'ATTACK', 'MOCKINGBIRD', 'UNKNOWN'),
        (1261, 'Jane Doe', 'S', 'PHYSICAL', 'ANOMALY', 'CRIMINAL_INVESTIGATION', 'UNKNOWN'),
        (1391, 'Ju Fufu', 'S', 'FIRE', 'STUN', 'YUNKUI_SUMMIT', 'UNKNOWN'),
        (1101, 'Koleda Belobog', 'S', 'FIRE', 'STUN', 'BELOBOG_HEAVY_INDUSTRIES', 'UNKNOWN'),
        (1441, 'Komano Manato', 'A', 'FIRE', 'RUPTURE', 'SPOOK_SHACK', 'UNKNOWN'),
        (1161, 'Lighter', 'S', 'FIRE', 'STUN', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1451, 'Lucia Elowen', 'S', 'ETHER', 'SUPPORT', 'SPOOK_SHACK', 'UNKNOWN'),
        (1151, 'Luciana de Montefio', 'A', 'FIRE', 'SUPPORT', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1511, 'Nangong Yu', 'S', 'ETHER', 'STUN', 'ANGELS_OF_DELUSION', 'UNKNOWN'),
        (1021, 'Nekomiya Mana', 'S', 'PHYSICAL', 'ATTACK', 'CUNNING_HARES', 'UNKNOWN'),
        (1031, 'Nicole Demara', 'A', 'ETHER', 'SUPPORT', 'CUNNING_HARES', 'UNKNOWN'),
        (1571, 'Norma Hollowell', 'S', 'FIRE', 'STUN', 'EXTERNAL_STRATEGY_DEPARTMENT', 'UNKNOWN'),
        (1301, 'Orphie Magnusson & Magus', 'S', 'FIRE', 'ATTACK', 'OBOL_SQUAD', 'UNKNOWN'),
        (1421, 'Pan Yinhu', 'A', 'PHYSICAL', 'DEFENSE', 'YUNKUI_SUMMIT', 'UNKNOWN'),
        (1641, 'Phoenix Reffaella', 'S', 'FIRE', 'ANOMALY', 'KRAMPUS_COMPLIANCE_AUTHORITY', 'UNKNOWN'),
        (1281, 'Piper Wheel', 'A', 'PHYSICAL', 'ANOMALY', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1541, 'Promeia', 'S', 'ICE', 'ANOMALY', 'KRAMPUS_COMPLIANCE_AUTHORITY', 'UNKNOWN'),
        (1351, 'Pulchra Fellini', 'A', 'PHYSICAL', 'STUN', 'SONS_OF_CALYDON', 'UNKNOWN'),
        (1551, 'Pyrois', 'I', 'ETHER', 'ATTACK', 'PHAETHON', 'UNKNOWN'),
        (1251, 'Qingyi', 'S', 'ELECTRIC', 'STUN', 'CRIMINAL_INVESTIGATION', 'UNKNOWN'),
        (1581, 'Remielle Dan', 'S', 'LUMIFLUX', 'ANOMALY', 'COVENANT_OF_DAYAT', 'UNKNOWN'),
        (1621, 'Roxy Ifrita Pryce', 'S', 'WIND', 'STUN', 'FLINT_WORKSHOP', 'UNKNOWN'),
        (1461, 'Seed', 'S', 'ELECTRIC', 'ATTACK', 'OBOL_SQUAD', 'UNKNOWN'),
        (1271, 'Seth Lowell', 'A', 'ELECTRIC', 'DEFENSE', 'CRIMINAL_INVESTIGATION', 'UNKNOWN'),
        (1631, 'Severian Lowell', 'S', 'WIND', 'ATTACK', 'METROPOLITAN_ORDER_DIVISION', 'UNKNOWN'),
        (1591, 'Sigrid de L’Azur', 'S', 'ICE', 'ATTACK', 'AIRSPACE_PATROL_DEPARTMENT', 'UNKNOWN'),
        (1381, 'Soldier 0 - Anby', 'S', 'ELECTRIC', 'ATTACK', 'SILVER_SQUAD', 'UNKNOWN'),
        (1041, 'Soldier 11', 'S', 'FIRE', 'ATTACK', 'OBOL_SQUAD', 'UNKNOWN'),
        (1131, 'Soukaku', 'A', 'ICE', 'SUPPORT', 'SECTION_6', 'UNKNOWN'),
        (1531, 'Starlight - Billy Kid', 'S', 'PHYSICAL', 'RUPTURE', 'CUNNING_HARES', 'UNKNOWN'),
        (1601, 'Sunbringer', 'S', 'GENESIS_FLARE', 'ARMORER', 'ROSCAELIFER', 'BETA'),
        (1491, 'Sunna', 'S', 'PHYSICAL', 'SUPPORT', 'ANGELS_OF_DELUSION', 'UNKNOWN'),
        (1361, 'Trigger', 'S', 'ELECTRIC', 'STUN', 'OBOL_SQUAD', 'UNKNOWN'),
        (1221, 'Tsukishiro Yanagi', 'S', 'ELECTRIC', 'ANOMALY', 'SECTION_6', 'UNKNOWN'),
        (1411, 'Ukinami Yuzuha', 'S', 'PHYSICAL', 'SUPPORT', 'SPOOK_SHACK', 'UNKNOWN'),
        (1561, 'Velina Airgid', 'S', 'WIND', 'ANOMALY', 'EXTERNAL_STRATEGY_DEPARTMENT', 'UNKNOWN'),
        (1331, 'Vivian Banshee', 'S', 'ETHER', 'ANOMALY', 'MOCKINGBIRD', 'UNKNOWN'),
        (1141, 'Von Lycaon', 'S', 'ICE', 'STUN', 'VICTORIA_HOUSEKEEPING', 'UNKNOWN'),
        (1431, 'Ye Shunguang', 'S', 'HONED_EDGE', 'ATTACK', 'YUNKUI_SUMMIT', 'UNKNOWN'),
        (1051, 'Yidhari Murphy', 'S', 'ICE', 'RUPTURE', 'SPOOK_SHACK', 'UNKNOWN'),
        (1371, 'Yixuan', 'S', 'AURIC_INK', 'RUPTURE', 'YUNKUI_SUMMIT', 'UNKNOWN'),
        (1341, 'Zhao', 'S', 'ICE', 'DEFENSE', 'KRAMPUS_COMPLIANCE_AUTHORITY', 'UNKNOWN'),
        (1241, 'Zhu Yuan', 'S', 'ETHER', 'ATTACK', 'CRIMINAL_INVESTIGATION', 'UNKNOWN')
), inserted AS (
    INSERT INTO catalog.agents (id, rank_code, element_code, specialty_code, faction_code, release_stage)
    SELECT id, rank_code, element_code, specialty_code, faction_code, release_stage FROM supplied
    RETURNING id
)
INSERT INTO catalog.agent_names (agent_id, locale, name)
SELECT supplied.id, 'en', supplied.name FROM supplied JOIN inserted USING (id);

-- ATRIBUTOS BASE E PASSIVAS: adicionar aqui os perfis confirmados durante a coleta.
-- agent_base_stats: base crua no nível máximo, SEM passiva.
-- agent_passive_bonuses: apenas o total maximizado, separado em BASE ou SHEET.
-- BASE / FLAT: soma antes dos multiplicadores.
-- SHEET / PERCENT: soma aos percentuais dos itens; SHEET / FLAT: soma direta.
-- Marcar passive_bonuses_complete = TRUE apenas quando todos os bônus forem conferidos.

-- Anby: valores originalmente enviados com passiva incluída (ATQ 658, Impacto 136).
-- Separação confirmada pelo usuário em 2026-10-31: +3x25 ATQ base, +3x6 Impacto base.
-- Base crua: 658 - 75 = 583 ATQ; 136 - 18 = 118 Impacto. Demais valores preservados.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1011, 60, TRUE,
    'Anby Demara: atributos e totais da passiva maximizada fornecidos manualmente pelo usuário em 2026-10-31.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1011, 'HEALTH', 7500),
    (1011, 'ATTACK', 583),
    (1011, 'DEFENSE', 612),
    (1011, 'IMPACT', 118),
    (1011, 'CRIT_RATE', 5),
    (1011, 'CRIT_DAMAGE', 50),
    (1011, 'ANOMALY_MASTERY', 94),
    (1011, 'ANOMALY_PROFICIENCY', 93),
    (1011, 'PENETRATION_RATE', 0),
    (1011, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1011, 'ATTACK', 'BASE', 'FLAT', 75),
    (1011, 'IMPACT', 'BASE', 'FLAT', 18);

-- Nicole: base crua fornecida pelo usuário em 2026-10-31, SEM os valores da passiva.
-- Não descontar os bônus abaixo: 574 + 75 = 649 ATQ; 1.2 + 0.36 = 1.56 recuperação de energia.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1031, 60, TRUE,
    'Nicole Demara: usuário confirmou base sem passiva e informou separadamente os bônus maximizados em 2026-10-31.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1031, 'HEALTH', 8145),
    (1031, 'ATTACK', 574),
    (1031, 'DEFENSE', 622),
    (1031, 'IMPACT', 88),
    (1031, 'CRIT_RATE', 5),
    (1031, 'CRIT_DAMAGE', 50),
    (1031, 'ANOMALY_MASTERY', 90),
    (1031, 'ANOMALY_PROFICIENCY', 93),
    (1031, 'PENETRATION_RATE', 0),
    (1031, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1031, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1031, 'ATTACK', 'BASE', 'FLAT', 75);

-- Corin: base crua fornecida pelo usuário, SEM os valores da passiva.
-- ATQ: 732 + 75 = 807; dano crítico: 50 + 28.8 = 78.8 pontos percentuais.
-- O bônus de dano crítico é aditivo na ficha, não um percentual multiplicando a taxa base.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1061, 60, TRUE,
    'Corin Wickes: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1061, 'HEALTH', 6976),
    (1061, 'ATTACK', 732),
    (1061, 'DEFENSE', 604),
    (1061, 'IMPACT', 93),
    (1061, 'CRIT_RATE', 5),
    (1061, 'CRIT_DAMAGE', 50),
    (1061, 'ANOMALY_MASTERY', 93),
    (1061, 'ANOMALY_PROFICIENCY', 96),
    (1061, 'PENETRATION_RATE', 0),
    (1061, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1061, 'CRIT_DAMAGE', 'SHEET', 'FLAT', 28.8),
    (1061, 'ATTACK', 'BASE', 'FLAT', 75);

-- Billy Kid (1081): base crua e bônus da passiva fornecidos separadamente pelo usuário.
-- ATQ: 712 + 75 = 787; taxa crítica: 5 + 14.4 = 19.4 pontos percentuais.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1081, 60, TRUE,
    'Billy: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1081, 'HEALTH', 6907),
    (1081, 'ATTACK', 712),
    (1081, 'DEFENSE', 606),
    (1081, 'IMPACT', 91),
    (1081, 'CRIT_RATE', 5),
    (1081, 'CRIT_DAMAGE', 50),
    (1081, 'ANOMALY_MASTERY', 92),
    (1081, 'ANOMALY_PROFICIENCY', 91),
    (1081, 'PENETRATION_RATE', 0),
    (1081, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1081, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1081, 'ATTACK', 'BASE', 'FLAT', 75);

-- Anton Ivanov (1111): base crua e bônus da passiva fornecidos separadamente pelo usuário.
-- ATQ: 716 + 75 = 791; taxa crítica: 5 + 14.4 = 19.4 pontos percentuais.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1111, 60, TRUE,
    'Anton: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1111, 'HEALTH', 7219),
    (1111, 'ATTACK', 716),
    (1111, 'DEFENSE', 622),
    (1111, 'IMPACT', 95),
    (1111, 'CRIT_RATE', 5),
    (1111, 'CRIT_DAMAGE', 50),
    (1111, 'ANOMALY_MASTERY', 86),
    (1111, 'ANOMALY_PROFICIENCY', 90),
    (1111, 'PENETRATION_RATE', 0),
    (1111, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1111, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1111, 'ATTACK', 'BASE', 'FLAT', 75);

-- Ben Bigger (1121): base crua e bônus da passiva fornecidos separadamente pelo usuário.
-- ATQ: 578 + 75 = 653; recuperação de energia: 1.2 + 0.36 = 1.56.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1121, 60, TRUE,
    'Ben: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1121, 'HEALTH', 8577),
    (1121, 'ATTACK', 578),
    (1121, 'DEFENSE', 724),
    (1121, 'IMPACT', 95),
    (1121, 'CRIT_RATE', 5),
    (1121, 'CRIT_DAMAGE', 50),
    (1121, 'ANOMALY_MASTERY', 86),
    (1121, 'ANOMALY_PROFICIENCY', 90),
    (1121, 'PENETRATION_RATE', 0),
    (1121, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1121, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1121, 'ATTACK', 'BASE', 'FLAT', 75);

-- Soukaku (1131): base crua e bônus da passiva fornecidos separadamente pelo usuário.
-- ATQ: 590 + 75 = 665; recuperação de energia: 1.2 + 0.36 = 1.56.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1131, 60, TRUE,
    'Soukaku: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1131, 'HEALTH', 8025),
    (1131, 'ATTACK', 590),
    (1131, 'DEFENSE', 597),
    (1131, 'IMPACT', 86),
    (1131, 'CRIT_RATE', 5),
    (1131, 'CRIT_DAMAGE', 50),
    (1131, 'ANOMALY_MASTERY', 93),
    (1131, 'ANOMALY_PROFICIENCY', 96),
    (1131, 'PENETRATION_RATE', 0),
    (1131, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1131, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1131, 'ATTACK', 'BASE', 'FLAT', 75);

-- Luciana de Montefio (1151), enviada como Lucy: base crua e passiva separadas.
-- ATQ: 583 + 75 = 658; recuperação de energia: 1.2 + 0.36 = 1.56.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1151, 60, TRUE,
    'Lucy: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1151, 'HEALTH', 8025),
    (1151, 'ATTACK', 583),
    (1151, 'DEFENSE', 612),
    (1151, 'IMPACT', 86),
    (1151, 'CRIT_RATE', 5),
    (1151, 'CRIT_DAMAGE', 50),
    (1151, 'ANOMALY_MASTERY', 94),
    (1151, 'ANOMALY_PROFICIENCY', 93),
    (1151, 'PENETRATION_RATE', 0),
    (1151, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1151, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1151, 'ATTACK', 'BASE', 'FLAT', 75);

-- Lote: Seth, Piper, Pulchra, Pan Yinhu, Komano Manato e Nekomiya Mana.
-- Todos os valores são bases cruas no nível máximo, sem descontar os bônus enviados à parte.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES
    (1271, 60, TRUE, 'Seth Lowell: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1281, 60, TRUE, 'Piper: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1351, 60, TRUE, 'Pulchra: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1421, 60, TRUE, 'Pan Yinhu: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1441, 60, TRUE, 'Komano Manato: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote; adrenalina e Sheer Force informados como zero.'),
    (1021, 60, TRUE, 'Nekomiya Mana: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.');

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1271, 'HEALTH', 8701),
    (1271, 'ATTACK', 568),
    (1271, 'DEFENSE', 746),
    (1271, 'IMPACT', 94),
    (1271, 'CRIT_RATE', 5),
    (1271, 'CRIT_DAMAGE', 50),
    (1271, 'ANOMALY_MASTERY', 86),
    (1271, 'ANOMALY_PROFICIENCY', 90),
    (1271, 'PENETRATION_RATE', 0),
    (1271, 'ENERGY_REGEN', 1.2),
    (1281, 'HEALTH', 6976),
    (1281, 'ATTACK', 683),
    (1281, 'DEFENSE', 612),
    (1281, 'IMPACT', 86),
    (1281, 'CRIT_RATE', 5),
    (1281, 'CRIT_DAMAGE', 50),
    (1281, 'ANOMALY_MASTERY', 116),
    (1281, 'ANOMALY_PROFICIENCY', 118),
    (1281, 'PENETRATION_RATE', 0),
    (1281, 'ENERGY_REGEN', 1.2),
    (1351, 'HEALTH', 7612),
    (1351, 'ATTACK', 590),
    (1351, 'DEFENSE', 606),
    (1351, 'IMPACT', 118),
    (1351, 'CRIT_RATE', 5),
    (1351, 'CRIT_DAMAGE', 50),
    (1351, 'ANOMALY_MASTERY', 92),
    (1351, 'ANOMALY_PROFICIENCY', 90),
    (1351, 'PENETRATION_RATE', 0),
    (1351, 'ENERGY_REGEN', 1.2),
    (1421, 'HEALTH', 8453),
    (1421, 'ATTACK', 586),
    (1421, 'DEFENSE', 712),
    (1421, 'IMPACT', 94),
    (1421, 'CRIT_RATE', 5),
    (1421, 'CRIT_DAMAGE', 50),
    (1421, 'ANOMALY_MASTERY', 91),
    (1421, 'ANOMALY_PROFICIENCY', 90),
    (1421, 'PENETRATION_RATE', 0),
    (1421, 'ENERGY_REGEN', 1.2),
    (1441, 'HEALTH', 7724),
    (1441, 'ATTACK', 680),
    (1441, 'DEFENSE', 443),
    (1441, 'IMPACT', 95),
    (1441, 'CRIT_RATE', 5),
    (1441, 'CRIT_DAMAGE', 50),
    (1441, 'ANOMALY_MASTERY', 87),
    (1441, 'ANOMALY_PROFICIENCY', 90),
    (1441, 'SHEER_FORCE', 0),
    (1441, 'AUTOMATIC_ADRENALINE_ACCUMULATION', 0),
    (1021, 'HEALTH', 7560),
    (1021, 'ATTACK', 835),
    (1021, 'DEFENSE', 587),
    (1021, 'IMPACT', 92),
    (1021, 'CRIT_RATE', 5),
    (1021, 'CRIT_DAMAGE', 50),
    (1021, 'ANOMALY_MASTERY', 97),
    (1021, 'ANOMALY_PROFICIENCY', 96),
    (1021, 'PENETRATION_RATE', 0),
    (1021, 'ENERGY_REGEN', 1.2);

-- No Manato, +18% PV é modificador de ficha junto aos itens, não acréscimo à base crua.
-- Os zeros de Sheer Force e adrenalina são os dados enviados, não uma fórmula derivada.
-- Não preencher recuperação de energia nem inferir 100% de perfuração para Rupture.
INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1271, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1271, 'ATTACK', 'BASE', 'FLAT', 75),
    (1281, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1281, 'ATTACK', 'BASE', 'FLAT', 75),
    (1351, 'IMPACT', 'BASE', 'FLAT', 18),
    (1351, 'ATTACK', 'BASE', 'FLAT', 75),
    (1421, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1421, 'ATTACK', 'BASE', 'FLAT', 75),
    (1441, 'HEALTH', 'SHEET', 'PERCENT', 18),
    (1441, 'ATTACK', 'BASE', 'FLAT', 75),
    (1021, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1021, 'ATTACK', 'BASE', 'FLAT', 75);

-- Claret Flint (1611): base crua e passiva fornecidas separadamente pelo usuário.
-- Dano crítico normal e Laceration DMG são atributos distintos; não substituir um pelo outro.
-- Taxa crítica direta: 5 + 28.8 = 33.8, ANTES da conversão de dano crítico, cuja fórmula está pendente.
-- Não presumir +75 ATQ nem recuperação de energia: não foram informados para este perfil.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1611, 60, TRUE,
    'Claret: onze atributos base e bônus de taxa crítica da passiva maximizada fornecidos manualmente pelo usuário; conversão de dano crítico ainda sem fórmula.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1611, 'HEALTH', 5651),
    (1611, 'ATTACK', 626),
    (1611, 'LACERATION_DAMAGE', 150),
    (1611, 'DEFENSE', 441),
    (1611, 'IMPACT', 93),
    (1611, 'CRIT_RATE', 5),
    (1611, 'CRIT_DAMAGE', 50),
    (1611, 'ANOMALY_MASTERY', 80),
    (1611, 'ANOMALY_PROFICIENCY', 79),
    (1611, 'PENETRATION_RATE', 0),
    (1611, 'AUTOMATIC_SHARPNESS_ACCUMULATION', 1.5);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1611, 'CRIT_RATE', 'SHEET', 'FLAT', 28.8);

-- Lote de 13 personagens: bases cruas e totais da passiva fornecidos separadamente pelo usuário.
-- Yidhari: Sheer Force 0 e acúmulo automático de adrenalina 2; não preencher energia ou perfuração.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES
    (1041, 60, TRUE, 'Soldier 11: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1051, 60, TRUE, 'Yidhari Murphy: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1071, 60, TRUE, 'Caesar King: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1091, 60, TRUE, 'Hoshimi Miyabi: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1101, 60, TRUE, 'Koleda Belobog: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1141, 60, TRUE, 'Von Lycaon: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1161, 60, TRUE, 'Lighter: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1171, 60, TRUE, 'Burnice White: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1181, 60, TRUE, 'Grace Howard: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1191, 60, TRUE, 'Ellen Joe: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1201, 60, TRUE, 'Asaba Harumasa: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1211, 60, TRUE, 'Alexandrina Sebastiane: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.'),
    (1221, 60, TRUE, 'Tsukishiro Yanagi: base crua e passiva maximizada fornecidas manualmente pelo usuário em lote.');

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1041, 'HEALTH', 7673),
    (1041, 'ATTACK', 813),
    (1041, 'DEFENSE', 612),
    (1041, 'IMPACT', 93),
    (1041, 'CRIT_RATE', 5),
    (1041, 'CRIT_DAMAGE', 50),
    (1041, 'ANOMALY_MASTERY', 94),
    (1041, 'ANOMALY_PROFICIENCY', 93),
    (1041, 'PENETRATION_RATE', 0),
    (1041, 'ENERGY_REGEN', 1.2),
    (1051, 'HEALTH', 8497),
    (1051, 'ATTACK', 784),
    (1051, 'DEFENSE', 448),
    (1051, 'IMPACT', 95),
    (1051, 'CRIT_RATE', 5),
    (1051, 'CRIT_DAMAGE', 50),
    (1051, 'ANOMALY_MASTERY', 87),
    (1051, 'ANOMALY_PROFICIENCY', 90),
    (1051, 'SHEER_FORCE', 0),
    (1051, 'AUTOMATIC_ADRENALINE_ACCUMULATION', 2),
    (1071, 'HEALTH', 9526),
    (1071, 'ATTACK', 636),
    (1071, 'DEFENSE', 753),
    (1071, 'IMPACT', 105),
    (1071, 'CRIT_RATE', 5),
    (1071, 'CRIT_DAMAGE', 50),
    (1071, 'ANOMALY_MASTERY', 87),
    (1071, 'ANOMALY_PROFICIENCY', 90),
    (1071, 'PENETRATION_RATE', 0),
    (1071, 'ENERGY_REGEN', 1.2),
    (1091, 'HEALTH', 7673),
    (1091, 'ATTACK', 805),
    (1091, 'DEFENSE', 606),
    (1091, 'IMPACT', 86),
    (1091, 'CRIT_RATE', 5),
    (1091, 'CRIT_DAMAGE', 50),
    (1091, 'ANOMALY_MASTERY', 116),
    (1091, 'ANOMALY_PROFICIENCY', 148),
    (1091, 'PENETRATION_RATE', 0),
    (1091, 'ENERGY_REGEN', 1.2),
    (1101, 'HEALTH', 8127),
    (1101, 'ATTACK', 660),
    (1101, 'DEFENSE', 594),
    (1101, 'IMPACT', 116),
    (1101, 'CRIT_RATE', 5),
    (1101, 'CRIT_DAMAGE', 50),
    (1101, 'ANOMALY_MASTERY', 97),
    (1101, 'ANOMALY_PROFICIENCY', 96),
    (1101, 'PENETRATION_RATE', 0),
    (1101, 'ENERGY_REGEN', 1.2),
    (1141, 'HEALTH', 8416),
    (1141, 'ATTACK', 653),
    (1141, 'DEFENSE', 606),
    (1141, 'IMPACT', 119),
    (1141, 'CRIT_RATE', 5),
    (1141, 'CRIT_DAMAGE', 50),
    (1141, 'ANOMALY_MASTERY', 91),
    (1141, 'ANOMALY_PROFICIENCY', 90),
    (1141, 'PENETRATION_RATE', 0),
    (1141, 'ENERGY_REGEN', 1.2),
    (1161, 'HEALTH', 8253),
    (1161, 'ATTACK', 722),
    (1161, 'DEFENSE', 612),
    (1161, 'IMPACT', 119),
    (1161, 'CRIT_RATE', 5),
    (1161, 'CRIT_DAMAGE', 50),
    (1161, 'ANOMALY_MASTERY', 91),
    (1161, 'ANOMALY_PROFICIENCY', 90),
    (1161, 'PENETRATION_RATE', 0),
    (1161, 'ENERGY_REGEN', 1.2),
    (1171, 'HEALTH', 7368),
    (1171, 'ATTACK', 788),
    (1171, 'DEFENSE', 600),
    (1171, 'IMPACT', 83),
    (1171, 'CRIT_RATE', 5),
    (1171, 'CRIT_DAMAGE', 50),
    (1171, 'ANOMALY_MASTERY', 118),
    (1171, 'ANOMALY_PROFICIENCY', 120),
    (1171, 'PENETRATION_RATE', 0),
    (1171, 'ENERGY_REGEN', 1.2),
    (1181, 'HEALTH', 7482),
    (1181, 'ATTACK', 750),
    (1181, 'DEFENSE', 600),
    (1181, 'IMPACT', 83),
    (1181, 'CRIT_RATE', 5),
    (1181, 'CRIT_DAMAGE', 50),
    (1181, 'ANOMALY_MASTERY', 115),
    (1181, 'ANOMALY_PROFICIENCY', 116),
    (1181, 'PENETRATION_RATE', 0),
    (1181, 'ENERGY_REGEN', 1.2),
    (1191, 'HEALTH', 7673),
    (1191, 'ATTACK', 863),
    (1191, 'DEFENSE', 606),
    (1191, 'IMPACT', 93),
    (1191, 'CRIT_RATE', 5),
    (1191, 'CRIT_DAMAGE', 50),
    (1191, 'ANOMALY_MASTERY', 94),
    (1191, 'ANOMALY_PROFICIENCY', 93),
    (1191, 'PENETRATION_RATE', 0),
    (1191, 'ENERGY_REGEN', 1.2),
    (1201, 'HEALTH', 7405),
    (1201, 'ATTACK', 840),
    (1201, 'DEFENSE', 600),
    (1201, 'IMPACT', 90),
    (1201, 'CRIT_RATE', 5),
    (1201, 'CRIT_DAMAGE', 50),
    (1201, 'ANOMALY_MASTERY', 80),
    (1201, 'ANOMALY_PROFICIENCY', 95),
    (1201, 'PENETRATION_RATE', 0),
    (1201, 'ENERGY_REGEN', 1.2),
    (1211, 'HEALTH', 8609),
    (1211, 'ATTACK', 642),
    (1211, 'DEFENSE', 600),
    (1211, 'IMPACT', 83),
    (1211, 'CRIT_RATE', 5),
    (1211, 'CRIT_DAMAGE', 50),
    (1211, 'ANOMALY_MASTERY', 93),
    (1211, 'ANOMALY_PROFICIENCY', 92),
    (1211, 'PENETRATION_RATE', 0),
    (1211, 'ENERGY_REGEN', 1.2),
    (1221, 'HEALTH', 7788),
    (1221, 'ATTACK', 797),
    (1221, 'DEFENSE', 612),
    (1221, 'IMPACT', 86),
    (1221, 'CRIT_RATE', 5),
    (1221, 'CRIT_DAMAGE', 50),
    (1221, 'ANOMALY_MASTERY', 112),
    (1221, 'ANOMALY_PROFICIENCY', 114),
    (1221, 'PENETRATION_RATE', 0),
    (1221, 'ENERGY_REGEN', 1.2);

-- Acréscimos numéricos de Impacto, Maestria e Proficiência são guardados separados da base crua.
-- Taxa crítica e taxa de perfuração recebem pontos percentuais diretamente na ficha.
INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1041, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1041, 'ATTACK', 'BASE', 'FLAT', 75),
    (1051, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1051, 'ATTACK', 'BASE', 'FLAT', 75),
    (1071, 'IMPACT', 'BASE', 'FLAT', 18),
    (1071, 'ATTACK', 'BASE', 'FLAT', 75),
    (1091, 'ANOMALY_PROFICIENCY', 'BASE', 'FLAT', 90),
    (1091, 'ATTACK', 'BASE', 'FLAT', 75),
    (1101, 'IMPACT', 'BASE', 'FLAT', 18),
    (1101, 'ATTACK', 'BASE', 'FLAT', 75),
    (1141, 'IMPACT', 'BASE', 'FLAT', 18),
    (1141, 'ATTACK', 'BASE', 'FLAT', 75),
    (1161, 'IMPACT', 'BASE', 'FLAT', 18),
    (1161, 'ATTACK', 'BASE', 'FLAT', 75),
    (1171, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1171, 'ATTACK', 'BASE', 'FLAT', 75),
    (1181, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1181, 'ATTACK', 'BASE', 'FLAT', 75),
    (1191, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1191, 'ATTACK', 'BASE', 'FLAT', 75),
    (1201, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1201, 'ATTACK', 'BASE', 'FLAT', 75),
    (1211, 'PENETRATION_RATE', 'SHEET', 'FLAT', 14.4),
    (1211, 'ATTACK', 'BASE', 'FLAT', 75),
    (1221, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1221, 'ATTACK', 'BASE', 'FLAT', 75);

-- Zhu Yuan (1241): base crua e passiva fornecidas separadamente pelo usuário.
-- ATQ: 844 + 75 = 919; dano crítico: 50 + 28.8 = 78.8 pontos percentuais.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1241, 60, TRUE,
    'Zhu Yuan: base crua e bônus totais da passiva maximizada fornecidos manualmente pelo usuário.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1241, 'HEALTH', 7482),
    (1241, 'ATTACK', 844),
    (1241, 'DEFENSE', 600),
    (1241, 'IMPACT', 90),
    (1241, 'CRIT_RATE', 5),
    (1241, 'CRIT_DAMAGE', 50),
    (1241, 'ANOMALY_MASTERY', 93),
    (1241, 'ANOMALY_PROFICIENCY', 92),
    (1241, 'PENETRATION_RATE', 0),
    (1241, 'ENERGY_REGEN', 1.2);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1241, 'CRIT_DAMAGE', 'SHEET', 'FLAT', 28.8),
    (1241, 'ATTACK', 'BASE', 'FLAT', 75);

-- Lote de 14 personagens: de Qingyi a Ukinami Yuzuha, conforme dados enviados pelo usuário.
-- Bases cruas preservadas; passivas separadas. Yixuan recebe PV base +420, sem bônus de ATQ.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES
    (1251, 60, TRUE, 'Qingyi: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1261, 60, TRUE, 'Jane Doe: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1291, 60, TRUE, 'Hugo Vlad: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1301, 60, TRUE, 'Orphie Magnusson & Magus: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1311, 60, TRUE, 'Astra Yao: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1321, 60, TRUE, 'Evelyn Chevalier: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1331, 60, TRUE, 'Vivian Banshee: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1341, 60, TRUE, 'Zhao: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1361, 60, TRUE, 'Trigger: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1371, 60, TRUE, 'Yixuan: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1381, 60, TRUE, 'Soldier 0 - Anby: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1391, 60, TRUE, 'Ju Fufu: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1401, 60, TRUE, 'Alice Thymefield: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1411, 60, TRUE, 'Ukinami Yuzuha: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.');

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1251, 'HEALTH', 8250),
    (1251, 'ATTACK', 683),
    (1251, 'DEFENSE', 612),
    (1251, 'IMPACT', 118),
    (1251, 'CRIT_RATE', 5),
    (1251, 'CRIT_DAMAGE', 50),
    (1251, 'ANOMALY_MASTERY', 94),
    (1251, 'ANOMALY_PROFICIENCY', 93),
    (1251, 'PENETRATION_RATE', 0),
    (1251, 'ENERGY_REGEN', 1.2),
    (1261, 'HEALTH', 7788),
    (1261, 'ATTACK', 805),
    (1261, 'DEFENSE', 606),
    (1261, 'IMPACT', 86),
    (1261, 'CRIT_RATE', 5),
    (1261, 'CRIT_DAMAGE', 50),
    (1261, 'ANOMALY_MASTERY', 112),
    (1261, 'ANOMALY_PROFICIENCY', 114),
    (1261, 'PENETRATION_RATE', 0),
    (1261, 'ENERGY_REGEN', 1.2),
    (1291, 'HEALTH', 7940),
    (1291, 'ATTACK', 844),
    (1291, 'DEFENSE', 616),
    (1291, 'IMPACT', 95),
    (1291, 'CRIT_RATE', 5),
    (1291, 'CRIT_DAMAGE', 50),
    (1291, 'ANOMALY_MASTERY', 86),
    (1291, 'ANOMALY_PROFICIENCY', 90),
    (1291, 'PENETRATION_RATE', 0),
    (1291, 'ENERGY_REGEN', 1.2),
    (1301, 'HEALTH', 7788),
    (1301, 'ATTACK', 854),
    (1301, 'DEFENSE', 612),
    (1301, 'IMPACT', 93),
    (1301, 'CRIT_RATE', 5),
    (1301, 'CRIT_DAMAGE', 50),
    (1301, 'ANOMALY_MASTERY', 92),
    (1301, 'ANOMALY_PROFICIENCY', 90),
    (1301, 'PENETRATION_RATE', 0),
    (1301, 'ENERGY_REGEN', 1.2),
    (1311, 'HEALTH', 8609),
    (1311, 'ATTACK', 640),
    (1311, 'DEFENSE', 600),
    (1311, 'IMPACT', 83),
    (1311, 'CRIT_RATE', 5),
    (1311, 'CRIT_DAMAGE', 50),
    (1311, 'ANOMALY_MASTERY', 93),
    (1311, 'ANOMALY_PROFICIENCY', 92),
    (1311, 'PENETRATION_RATE', 0),
    (1311, 'ENERGY_REGEN', 1.2),
    (1321, 'HEALTH', 7788),
    (1321, 'ATTACK', 854),
    (1321, 'DEFENSE', 612),
    (1321, 'IMPACT', 93),
    (1321, 'CRIT_RATE', 5),
    (1321, 'CRIT_DAMAGE', 50),
    (1321, 'ANOMALY_MASTERY', 92),
    (1321, 'ANOMALY_PROFICIENCY', 90),
    (1321, 'PENETRATION_RATE', 0),
    (1321, 'ENERGY_REGEN', 1.2),
    (1331, 'HEALTH', 7673),
    (1331, 'ATTACK', 805),
    (1331, 'DEFENSE', 606),
    (1331, 'IMPACT', 86),
    (1331, 'CRIT_RATE', 5),
    (1331, 'CRIT_DAMAGE', 50),
    (1331, 'ANOMALY_MASTERY', 108),
    (1331, 'ANOMALY_PROFICIENCY', 118),
    (1331, 'PENETRATION_RATE', 0),
    (1331, 'ENERGY_REGEN', 1.2),
    (1341, 'HEALTH', 9117),
    (1341, 'ATTACK', 690),
    (1341, 'DEFENSE', 701),
    (1341, 'IMPACT', 93),
    (1341, 'CRIT_RATE', 5),
    (1341, 'CRIT_DAMAGE', 50),
    (1341, 'ANOMALY_MASTERY', 93),
    (1341, 'ANOMALY_PROFICIENCY', 96),
    (1341, 'PENETRATION_RATE', 0),
    (1341, 'ENERGY_REGEN', 1.2),
    (1361, 'HEALTH', 7923),
    (1361, 'ATTACK', 675),
    (1361, 'DEFENSE', 600),
    (1361, 'IMPACT', 113),
    (1361, 'CRIT_RATE', 5),
    (1361, 'CRIT_DAMAGE', 50),
    (1361, 'ANOMALY_MASTERY', 96),
    (1361, 'ANOMALY_PROFICIENCY', 95),
    (1361, 'PENETRATION_RATE', 0),
    (1361, 'ENERGY_REGEN', 1.2),
    (1371, 'HEALTH', 7953),
    (1371, 'ATTACK', 872),
    (1371, 'DEFENSE', 441),
    (1371, 'IMPACT', 93),
    (1371, 'CRIT_RATE', 5),
    (1371, 'CRIT_DAMAGE', 50),
    (1371, 'ANOMALY_MASTERY', 92),
    (1371, 'ANOMALY_PROFICIENCY', 90),
    (1371, 'SHEER_FORCE', 0),
    (1371, 'AUTOMATIC_ADRENALINE_ACCUMULATION', 2),
    (1381, 'HEALTH', 7673),
    (1381, 'ATTACK', 854),
    (1381, 'DEFENSE', 612),
    (1381, 'IMPACT', 93),
    (1381, 'CRIT_RATE', 5),
    (1381, 'CRIT_DAMAGE', 50),
    (1381, 'ANOMALY_MASTERY', 94),
    (1381, 'ANOMALY_PROFICIENCY', 93),
    (1381, 'PENETRATION_RATE', 0),
    (1381, 'ENERGY_REGEN', 1.2),
    (1391, 'HEALTH', 8250),
    (1391, 'ATTACK', 690),
    (1391, 'DEFENSE', 597),
    (1391, 'IMPACT', 118),
    (1391, 'CRIT_RATE', 5),
    (1391, 'CRIT_DAMAGE', 50),
    (1391, 'ANOMALY_MASTERY', 93),
    (1391, 'ANOMALY_PROFICIENCY', 96),
    (1391, 'PENETRATION_RATE', 0),
    (1391, 'ENERGY_REGEN', 1.2),
    (1401, 'HEALTH', 7673),
    (1401, 'ATTACK', 805),
    (1401, 'DEFENSE', 606),
    (1401, 'IMPACT', 86),
    (1401, 'CRIT_RATE', 5),
    (1401, 'CRIT_DAMAGE', 50),
    (1401, 'ANOMALY_MASTERY', 106),
    (1401, 'ANOMALY_PROFICIENCY', 118),
    (1401, 'PENETRATION_RATE', 0),
    (1401, 'ENERGY_REGEN', 1.2),
    (1411, 'HEALTH', 8829),
    (1411, 'ATTACK', 683),
    (1411, 'DEFENSE', 612),
    (1411, 'IMPACT', 86),
    (1411, 'CRIT_RATE', 5),
    (1411, 'CRIT_DAMAGE', 50),
    (1411, 'ANOMALY_MASTERY', 88),
    (1411, 'ANOMALY_PROFICIENCY', 93),
    (1411, 'PENETRATION_RATE', 0),
    (1411, 'ENERGY_REGEN', 1.2);

-- Zhao: +18% PV é modificador de ficha. Yixuan: +420 PV é acréscimo à base.
-- Yixuan: adrenalina 2 e Sheer Force 0 são valores de origem, não resultados de uma fórmula de build.
INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1251, 'IMPACT', 'BASE', 'FLAT', 18),
    (1251, 'ATTACK', 'BASE', 'FLAT', 75),
    (1261, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1261, 'ATTACK', 'BASE', 'FLAT', 75),
    (1291, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1291, 'ATTACK', 'BASE', 'FLAT', 75),
    (1301, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1301, 'ATTACK', 'BASE', 'FLAT', 75),
    (1311, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1311, 'ATTACK', 'BASE', 'FLAT', 75),
    (1321, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1321, 'ATTACK', 'BASE', 'FLAT', 75),
    (1331, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1331, 'ATTACK', 'BASE', 'FLAT', 75),
    (1341, 'HEALTH', 'SHEET', 'PERCENT', 18),
    (1341, 'ATTACK', 'BASE', 'FLAT', 75),
    (1361, 'IMPACT', 'BASE', 'FLAT', 18),
    (1361, 'ATTACK', 'BASE', 'FLAT', 75),
    (1371, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1371, 'HEALTH', 'BASE', 'FLAT', 420),
    (1381, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1381, 'ATTACK', 'BASE', 'FLAT', 75),
    (1391, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1391, 'ATTACK', 'BASE', 'FLAT', 75),
    (1401, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1401, 'ATTACK', 'BASE', 'FLAT', 75),
    (1411, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1411, 'ATTACK', 'BASE', 'FLAT', 75);

-- Lote de 14 personagens: Ye Shunguang a Norma Hollowell, conforme dados enviados pelo usuário.
-- Bases cruas preservadas. Sunna e Pyrois têm recuperação de energia base 1.
-- Sunna: +21% ATQ na ficha; Aria: Maestria 115 + 36 = 151 e ATQ 788 + 75 = 863.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES
    (1431, 60, TRUE, 'Ye Shunguang: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1451, 60, TRUE, 'Lucia Elowen: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1461, 60, TRUE, 'Seed: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1471, 60, TRUE, 'Banyue: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1481, 60, TRUE, 'Dialyn: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1491, 60, TRUE, 'Sunna: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1501, 60, TRUE, 'Aria: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1511, 60, TRUE, 'Nangong Yu: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1521, 60, TRUE, 'Cissia: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1531, 60, TRUE, 'Starlight - Billy Kid: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1541, 60, TRUE, 'Promeia: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1551, 60, TRUE, 'Pyrois: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1561, 60, TRUE, 'Velina Airgid: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1571, 60, TRUE, 'Norma Hollowell: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.');

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1431, 'HEALTH', 7673),
    (1431, 'ATTACK', 863),
    (1431, 'DEFENSE', 606),
    (1431, 'IMPACT', 83),
    (1431, 'CRIT_RATE', 5),
    (1431, 'CRIT_DAMAGE', 50),
    (1431, 'ANOMALY_MASTERY', 94),
    (1431, 'ANOMALY_PROFICIENCY', 93),
    (1431, 'PENETRATION_RATE', 0),
    (1431, 'ENERGY_REGEN', 1.2),
    (1451, 'HEALTH', 8477),
    (1451, 'ATTACK', 683),
    (1451, 'DEFENSE', 594),
    (1451, 'IMPACT', 83),
    (1451, 'CRIT_RATE', 5),
    (1451, 'CRIT_DAMAGE', 50),
    (1451, 'ANOMALY_MASTERY', 96),
    (1451, 'ANOMALY_PROFICIENCY', 95),
    (1451, 'PENETRATION_RATE', 0),
    (1451, 'ENERGY_REGEN', 1.2),
    (1461, 'HEALTH', 7673),
    (1461, 'ATTACK', 854),
    (1461, 'DEFENSE', 612),
    (1461, 'IMPACT', 93),
    (1461, 'CRIT_RATE', 5),
    (1461, 'CRIT_DAMAGE', 50),
    (1461, 'ANOMALY_MASTERY', 94),
    (1461, 'ANOMALY_PROFICIENCY', 93),
    (1461, 'PENETRATION_RATE', 0),
    (1461, 'ENERGY_REGEN', 1.2),
    (1471, 'HEALTH', 8497),
    (1471, 'ATTACK', 784),
    (1471, 'DEFENSE', 445),
    (1471, 'IMPACT', 95),
    (1471, 'CRIT_RATE', 5),
    (1471, 'CRIT_DAMAGE', 50),
    (1471, 'ANOMALY_MASTERY', 90),
    (1471, 'ANOMALY_PROFICIENCY', 89),
    (1471, 'SHEER_FORCE', 0),
    (1471, 'AUTOMATIC_ADRENALINE_ACCUMULATION', 2),
    (1481, 'HEALTH', 8250),
    (1481, 'ATTACK', 683),
    (1481, 'DEFENSE', 612),
    (1481, 'IMPACT', 110),
    (1481, 'CRIT_RATE', 5),
    (1481, 'CRIT_DAMAGE', 50),
    (1481, 'ANOMALY_MASTERY', 94),
    (1481, 'ANOMALY_PROFICIENCY', 93),
    (1481, 'PENETRATION_RATE', 0),
    (1481, 'ENERGY_REGEN', 1.2),
    (1491, 'HEALTH', 8477),
    (1491, 'ATTACK', 675),
    (1491, 'DEFENSE', 600),
    (1491, 'IMPACT', 98),
    (1491, 'CRIT_RATE', 5),
    (1491, 'CRIT_DAMAGE', 50),
    (1491, 'ANOMALY_MASTERY', 96),
    (1491, 'ANOMALY_PROFICIENCY', 95),
    (1491, 'PENETRATION_RATE', 0),
    (1491, 'ENERGY_REGEN', 1),
    (1501, 'HEALTH', 7749),
    (1501, 'ATTACK', 788),
    (1501, 'DEFENSE', 619),
    (1501, 'IMPACT', 87),
    (1501, 'CRIT_RATE', 5),
    (1501, 'CRIT_DAMAGE', 50),
    (1501, 'ANOMALY_MASTERY', 115),
    (1501, 'ANOMALY_PROFICIENCY', 116),
    (1501, 'PENETRATION_RATE', 0),
    (1501, 'ENERGY_REGEN', 1.2),
    (1511, 'HEALTH', 8373),
    (1511, 'ATTACK', 671),
    (1511, 'DEFENSE', 622),
    (1511, 'IMPACT', 120),
    (1511, 'CRIT_RATE', 5),
    (1511, 'CRIT_DAMAGE', 50),
    (1511, 'ANOMALY_MASTERY', 90),
    (1511, 'ANOMALY_PROFICIENCY', 93),
    (1511, 'PENETRATION_RATE', 0),
    (1511, 'ENERGY_REGEN', 1.2),
    (1521, 'HEALTH', 7673),
    (1521, 'ATTACK', 863),
    (1521, 'DEFENSE', 606),
    (1521, 'IMPACT', 93),
    (1521, 'CRIT_RATE', 5),
    (1521, 'CRIT_DAMAGE', 50),
    (1521, 'ANOMALY_MASTERY', 94),
    (1521, 'ANOMALY_PROFICIENCY', 93),
    (1521, 'PENETRATION_RATE', 0),
    (1521, 'ENERGY_REGEN', 1.2),
    (1531, 'HEALTH', 8497),
    (1531, 'ATTACK', 784),
    (1531, 'DEFENSE', 445),
    (1531, 'IMPACT', 95),
    (1531, 'CRIT_RATE', 5),
    (1531, 'CRIT_DAMAGE', 50),
    (1531, 'ANOMALY_MASTERY', 90),
    (1531, 'ANOMALY_PROFICIENCY', 89),
    (1531, 'SHEER_FORCE', 0),
    (1531, 'AUTOMATIC_ADRENALINE_ACCUMULATION', 2),
    (1541, 'HEALTH', 7788),
    (1541, 'ATTACK', 797),
    (1541, 'DEFENSE', 612),
    (1541, 'IMPACT', 86),
    (1541, 'CRIT_RATE', 5),
    (1541, 'CRIT_DAMAGE', 50),
    (1541, 'ANOMALY_MASTERY', 112),
    (1541, 'ANOMALY_PROFICIENCY', 114),
    (1541, 'PENETRATION_RATE', 0),
    (1541, 'ENERGY_REGEN', 1.2),
    (1551, 'HEALTH', 7673),
    (1551, 'ATTACK', 849),
    (1551, 'DEFENSE', 612),
    (1551, 'IMPACT', 94),
    (1551, 'CRIT_RATE', 5),
    (1551, 'CRIT_DAMAGE', 50),
    (1551, 'ANOMALY_MASTERY', 94),
    (1551, 'ANOMALY_PROFICIENCY', 93),
    (1551, 'PENETRATION_RATE', 0),
    (1551, 'ENERGY_REGEN', 1),
    (1561, 'HEALTH', 7788),
    (1561, 'ATTACK', 797),
    (1561, 'DEFENSE', 612),
    (1561, 'IMPACT', 86),
    (1561, 'CRIT_RATE', 5),
    (1561, 'CRIT_DAMAGE', 50),
    (1561, 'ANOMALY_MASTERY', 112),
    (1561, 'ANOMALY_PROFICIENCY', 111),
    (1561, 'PENETRATION_RATE', 0),
    (1561, 'ENERGY_REGEN', 1.2),
    (1571, 'HEALTH', 7799),
    (1571, 'ATTACK', 687),
    (1571, 'DEFENSE', 582),
    (1571, 'IMPACT', 106),
    (1571, 'CRIT_RATE', 5),
    (1571, 'CRIT_DAMAGE', 50),
    (1571, 'ANOMALY_MASTERY', 99),
    (1571, 'ANOMALY_PROFICIENCY', 98),
    (1571, 'PENETRATION_RATE', 0),
    (1571, 'ENERGY_REGEN', 1.2);

-- Os percentuais de ATQ da Sunna somam aos demais percentuais de ficha, separados do ATQ base +75.
-- Banyue e Starlight - Billy Kid: Sheer Force 0 e adrenalina 2 são valores de origem.
-- Velina: bônus de Proficiência 54, preservado como informado.
INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1431, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1431, 'ATTACK', 'BASE', 'FLAT', 75),
    (1451, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1451, 'ATTACK', 'BASE', 'FLAT', 75),
    (1461, 'CRIT_DAMAGE', 'SHEET', 'FLAT', 28.8),
    (1461, 'ATTACK', 'BASE', 'FLAT', 75),
    (1471, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1471, 'ATTACK', 'BASE', 'FLAT', 75),
    (1481, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1481, 'ATTACK', 'BASE', 'FLAT', 75),
    (1491, 'ATTACK', 'SHEET', 'PERCENT', 21),
    (1491, 'ATTACK', 'BASE', 'FLAT', 75),
    (1501, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1501, 'ATTACK', 'BASE', 'FLAT', 75),
    (1511, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1511, 'ATTACK', 'BASE', 'FLAT', 75),
    (1521, 'ENERGY_REGEN', 'BASE', 'FLAT', 0.36),
    (1521, 'ATTACK', 'BASE', 'FLAT', 75),
    (1531, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1531, 'ATTACK', 'BASE', 'FLAT', 75),
    (1541, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1541, 'ATTACK', 'BASE', 'FLAT', 75),
    (1551, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1551, 'ATTACK', 'BASE', 'FLAT', 75),
    (1561, 'ANOMALY_PROFICIENCY', 'BASE', 'FLAT', 54),
    (1561, 'ATTACK', 'BASE', 'FLAT', 75),
    (1571, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1571, 'ATTACK', 'BASE', 'FLAT', 75);

-- Lote de cinco personagens: Remielle, Sigrid, Roxy, Severian e Phoenix.
-- Phoenix foi enviada sem ID neste lote: usar 1641, já fornecido no catálogo de metadados.
-- A coluna de Phoenix está deslocada uma linha; valores foram associados pelos rótulos.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES
    (1581, 60, TRUE, 'Remielle Dan: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1591, 60, TRUE, 'Sigrid de L''Azur: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1621, 60, TRUE, 'Roxy Ifrita Pryce: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1631, 60, TRUE, 'Severian Lowell: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.'),
    (1641, 60, TRUE, 'Phoenix Reffaella: base crua e totais da passiva maximizada fornecidos manualmente pelo usuário em lote.');

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1581, 'HEALTH', 7482),
    (1581, 'ATTACK', 748),
    (1581, 'DEFENSE', 600),
    (1581, 'IMPACT', 83),
    (1581, 'CRIT_RATE', 5),
    (1581, 'CRIT_DAMAGE', 50),
    (1581, 'ANOMALY_MASTERY', 115),
    (1581, 'ANOMALY_PROFICIENCY', 116),
    (1581, 'PENETRATION_RATE', 0),
    (1581, 'ENERGY_REGEN', 1.2),
    (1591, 'HEALTH', 7788),
    (1591, 'ATTACK', 863),
    (1591, 'DEFENSE', 606),
    (1591, 'IMPACT', 93),
    (1591, 'CRIT_RATE', 5),
    (1591, 'CRIT_DAMAGE', 50),
    (1591, 'ANOMALY_MASTERY', 92),
    (1591, 'ANOMALY_PROFICIENCY', 90),
    (1591, 'PENETRATION_RATE', 0),
    (1591, 'ENERGY_REGEN', 1.2),
    (1621, 'HEALTH', 8418),
    (1621, 'ATTACK', 666),
    (1621, 'DEFENSE', 641),
    (1621, 'IMPACT', 100),
    (1621, 'CRIT_RATE', 5),
    (1621, 'CRIT_DAMAGE', 50),
    (1621, 'ANOMALY_MASTERY', 110),
    (1621, 'ANOMALY_PROFICIENCY', 63),
    (1621, 'PENETRATION_RATE', 0),
    (1621, 'ENERGY_REGEN', 1.2),
    (1631, 'HEALTH', 7826),
    (1631, 'ATTACK', 858),
    (1631, 'DEFENSE', 606),
    (1631, 'IMPACT', 94),
    (1631, 'CRIT_RATE', 5),
    (1631, 'CRIT_DAMAGE', 50),
    (1631, 'ANOMALY_MASTERY', 91),
    (1631, 'ANOMALY_PROFICIENCY', 90),
    (1631, 'PENETRATION_RATE', 0),
    (1631, 'ENERGY_REGEN', 1.2),
    (1641, 'HEALTH', 7673),
    (1641, 'ATTACK', 797),
    (1641, 'DEFENSE', 612),
    (1641, 'IMPACT', 86),
    (1641, 'CRIT_RATE', 5),
    (1641, 'CRIT_DAMAGE', 50),
    (1641, 'ANOMALY_MASTERY', 116),
    (1641, 'ANOMALY_PROFICIENCY', 118),
    (1641, 'PENETRATION_RATE', 0),
    (1641, 'ENERGY_REGEN', 1.2);

-- Remielle: bônus de Proficiência 54; Roxy: Proficiência base 63, conforme enviados.
INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1581, 'ANOMALY_PROFICIENCY', 'BASE', 'FLAT', 54),
    (1581, 'ATTACK', 'BASE', 'FLAT', 75),
    (1591, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1591, 'ATTACK', 'BASE', 'FLAT', 75),
    (1621, 'CRIT_RATE', 'SHEET', 'FLAT', 14.4),
    (1621, 'ATTACK', 'BASE', 'FLAT', 75),
    (1631, 'CRIT_DAMAGE', 'SHEET', 'FLAT', 28.8),
    (1631, 'ATTACK', 'BASE', 'FLAT', 75),
    (1641, 'ANOMALY_MASTERY', 'BASE', 'FLAT', 36),
    (1641, 'ATTACK', 'BASE', 'FLAT', 75);

-- Sunbringer (1601): valores atuais do beta, fornecidos manualmente pelo usuário.
-- ATQ base 626 confirmado em complemento ao envio; demais valores preservados.
-- Passiva informada: apenas +28.8 pontos percentuais de taxa crítica, sem bônus de ATQ presumido.
-- Preservar CRIT_DAMAGE e LACERATION_DAMAGE separados; conversão para taxa crítica pendente.
INSERT INTO catalog.agent_base_profiles (
    agent_id, agent_level, passive_bonuses_complete, source_note
) VALUES (
    1601, 60, TRUE,
    'Sunbringer: dados atuais do beta fornecidos pelo usuário; ATQ base 626 confirmado em complemento. Valores sujeitos a alterações futuras.'
);

INSERT INTO catalog.agent_base_stats (agent_id, stat_code, value) VALUES
    (1601, 'HEALTH', 5736),
    (1601, 'ATTACK', 626),
    (1601, 'LACERATION_DAMAGE', 150),
    (1601, 'DEFENSE', 441),
    (1601, 'IMPACT', 93),
    (1601, 'CRIT_RATE', 5),
    (1601, 'CRIT_DAMAGE', 50),
    (1601, 'ANOMALY_MASTERY', 78),
    (1601, 'ANOMALY_PROFICIENCY', 77),
    (1601, 'PENETRATION_RATE', 0),
    (1601, 'AUTOMATIC_SHARPNESS_ACCUMULATION', 1.5);

INSERT INTO catalog.agent_passive_bonuses (
    agent_id, stat_code, application_stage, modifier, value
) VALUES
    (1601, 'CRIT_RATE', 'SHEET', 'FLAT', 28.8);

-- Os 63 perfis de personagens da lista inicial foram preenchidos com os dados fornecidos.
-- MOTORES: 102 registros fornecidos manualmente pelo usuário; dados no nível máximo.
-- Unidades do Main Stat confirmadas pelo usuário: percentuais relativos, exceto Proficiência flat e taxas diretas.
-- As tabelas de motores são criadas no início desta V2.
INSERT INTO catalog.w_engine_ranks (code) VALUES ('S'), ('A'), ('B');

WITH supplied(id, name, rank_code, specialty_code, source_note) AS (
    VALUES
        (14150, 'Angel in the Shell', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Mastery 30; passiva não revisada.'),
        (14130, 'Bellicose Blaze', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14116, 'Blazing Laurel', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Impact 18; passiva não revisada.'),
        (14157, 'Chief Sidekick', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14143, 'Cloudcleave Radiance', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 743; Main Stat: Crit DMG 48; passiva não revisada.'),
        (14146, 'Cordis Germina', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14162, 'Crimson Moon Casket', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14161, 'Crimson Thirst', 'S', 'ARMORER', 'Dados manuais do usuário. Base Stat: DEF 431; Main Stat: DEF% 48; passiva não revisada.'),
        (14119, 'Deep Sea Visitor', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14145, 'Dreamlit Hearth', 'S', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: HP 30; passiva não revisada.'),
        (14131, 'Elegant Vanity', 'S', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Attack 30; passiva não revisada.'),
        (14117, 'Flamemaker Shaker', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Attack 30; passiva não revisada.'),
        (14133, 'Flight of Fancy', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Proficiency 90; passiva não revisada.'),
        (14154, 'Frostfall Sickle', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Mastery 30; passiva não revisada.'),
        (14118, 'Fusion Compiler', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: PEN Ratio 24; passiva não revisada.'),
        (14109, 'Hailstorm Shrine', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 743; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14134, 'Half-Sugar Bunny', 'S', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: HP 30; passiva não revisada.'),
        (14132, 'Heartstring Nocturne', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14110, 'Hellfire Gears', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: Impact 18; passiva não revisada.'),
        (14125, 'Ice-Jade Teapot', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Impact 18; passiva não revisada.'),
        (14163, 'Incarcerating Grip', 'S', 'ATTACK', 'Dados corrigidos pelo usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24%; passiva não revisada.'),
        (14156, 'Joyau Dore', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14159, 'Knight’s Extolment', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit DMG 48; passiva não revisada.'),
        (14105, 'Kraken’s Cradle', 'S', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: HP 30; passiva não revisada.'),
        (14141, 'Metanukimorphosis', 'S', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14129, 'Myriad Eclipse', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14151, 'Neon Fantasies', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Mastery 30; passiva não revisada.'),
        (14158, 'Ode of Resurrected Wings', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 743; Main Stat: ATK% 36; passiva não revisada.'),
        (14164, 'Plume of Rebirth', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Mastery 30; passiva não revisada.'),
        (14140, 'Practiced Perfection', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Attack 30; passiva não revisada.'),
        (14137, 'Qingming Birdcage', 'S', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 743; Main Stat: HP 30; passiva não revisada.'),
        (14124, 'Riot Suppressor Mark VI', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit DMG 48; passiva não revisada.'),
        (14139, 'Roaring Fur-nace', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Attack 30; passiva não revisada.'),
        (14152, 'Serpentine Seeker', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14138, 'Severed Innocence', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit DMG 48; passiva não revisada.'),
        (14126, 'Sharpened Stinger', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Anomaly Proficiency 90; passiva não revisada.'),
        (14155, 'Sol Exuvia', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: ATK% 30; passiva não revisada.'),
        (14136, 'Spectral Gaze', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14153, 'Starlight Rider Faceplate', 'S', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: HP% 30; passiva não revisada.'),
        (14102, 'Steel Cushion', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14104, 'The Brimstone', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: Attack 30; passiva não revisada.'),
        (14114, 'The Restrained', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: Impact 18; passiva não revisada.'),
        (14149, 'Thoughtbop', 'S', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Energy Regen 60; passiva não revisada.'),
        (14122, 'Timeweaver', 'S', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Attack 30; passiva não revisada.'),
        (14107, 'Tusks of Fury', 'S', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Impact 18; passiva não revisada.'),
        (14121, 'Weeping Cradle', 'S', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 684; Main Stat: PEN Ratio 24; passiva não revisada.'),
        (14147, 'Wrathful Vajra', 'S', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: HP 30; passiva não revisada.'),
        (14148, 'Yesterday Calls', 'S', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit Rate 24; passiva não revisada.'),
        (14120, 'Zanshin Herb Case', 'S', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 713; Main Stat: Crit DMG 48; passiva não revisada.'),
        (13113, 'Bashful Demon', 'A', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Attack 25; passiva não revisada.'),
        (13112, 'Big Cylinder', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Defense 40; passiva não revisada.'),
        (13021, 'Bloodmarrow Coffer', 'A', 'ARMORER', 'Dados manuais do usuário. Base Stat: DEF 356; Main Stat: Crit Rate 20; passiva não revisada.'),
        (13018, 'Boisterous Echoes', 'A', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Anomaly Proficiency 75; passiva não revisada.'),
        (13135, 'Box Cutter', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Impact 15; passiva não revisada.'),
        (13010, 'Bunny Band', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Defense 40; passiva não revisada.'),
        (14001, 'Cannon Rotor', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Crit Rate 20; passiva não revisada.'),
        (13017, 'Catty Luck', 'A', 'ARMORER', 'Dados manuais do usuário. Base Stat: DEF 356; Main Stat: DEF% 40; passiva não revisada.'),
        (13019, 'Cauldron of Clarity', 'A', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: HP 25; passiva não revisada.'),
        (13101, 'Demara Battery Mark II', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Impact 15; passiva não revisada.'),
        (13111, 'Drill Rig - Red Axis', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Energy Regen 50; passiva não revisada.'),
        (13009, 'Electro-Lip Gloss', 'A', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Anomaly Proficiency 75; passiva não revisada.'),
        (13013, 'Gilded Blossom', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (13144, 'Grill O’Wisp', 'A', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: HP 25; passiva não revisada.'),
        (13106, 'Housekeeper', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Attack 25; passiva não revisada.'),
        (13115, 'Kaboom the Cannon', 'A', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Energy Regen 50; passiva não revisada.'),
        (13015, 'Marcato Desire', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Crit Rate 20; passiva não revisada.'),
        (13007, 'Original Transmorpher', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: HP 25; passiva não revisada.'),
        (13127, 'Peacekeeper - Specialized', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Attack 25; passiva não revisada.'),
        (13006, 'Precious Fossilized Core', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Impact 15; passiva não revisada.'),
        (13012, 'Puzzle Sphere', 'A', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (13014, 'Radiowave Journey', 'A', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: HP 25; passiva não revisada.'),
        (13003, 'Rainforest Gourmet', 'A', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Anomaly Proficiency 75; passiva não revisada.'),
        (13016, 'Reel Projector', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Impact 15; passiva não revisada.'),
        (13128, 'Roaring Ride', 'A', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Attack 25; passiva não revisada.'),
        (14003, 'Six Shooter', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Impact 15; passiva não revisada.'),
        (13002, 'Slice of Time', 'A', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: PEN Ratio 20; passiva não revisada.'),
        (13011, 'Spring Embrace', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (13004, 'Starlight Engine', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (13108, 'Starlight Engine Replica', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: ATK 25; passiva não revisada.'),
        (13005, 'Steam Oven', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Energy Regen 50; passiva não revisada.'),
        (13001, 'Street Superstar', 'A', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (13020, 'The Simmering Pot', 'A', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Impact 15; passiva não revisada.'),
        (13103, 'The Vault', 'A', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Energy Regen 50; passiva não revisada.'),
        (13142, 'Tremor Trigram Vessel', 'A', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 624; Main Stat: Attack 25; passiva não revisada.'),
        (14002, 'Unfettered Game Ball', 'A', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Energy Regen 50; passiva não revisada.'),
        (13008, 'Weeping Gemini', 'A', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 594; Main Stat: Attack 25; passiva não revisada.'),
        (12015, '[Cinder] Cobalt', 'B', 'RUPTURE', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: HP 20; passiva não revisada.'),
        (12013, '[Identity] Base', 'B', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Defense 32; passiva não revisada.'),
        (12014, '[Identity] Inflection', 'B', 'DEFENSE', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Defense 32; passiva não revisada.'),
        (12002, '[Lunar] Decrescent', 'B', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Attack 20; passiva não revisada.'),
        (12003, '[Lunar] Noviluna', 'B', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Crit Rate 16; passiva não revisada.'),
        (12001, '[Lunar] Pleniluna', 'B', 'ATTACK', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Attack 20; passiva não revisada.'),
        (12016, '[Lunar] Semiluna', 'B', 'ARMORER', 'Dados manuais do usuário. Base Stat: DEF 282; Main Stat: DEF% 32; passiva não revisada.'),
        (12010, '[Magnetic Storm] Alpha', 'B', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Attack 20; passiva não revisada.'),
        (12011, '[Magnetic Storm] Bravo', 'B', 'ANOMALY', 'Dados corrigidos pelo usuário. Base Stat: ATK 356; Main Stat: Anomaly Proficiency 60; passiva não revisada.'),
        (12012, '[Magnetic Storm] Charlie', 'B', 'ANOMALY', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: PEN Ratio 16; passiva não revisada.'),
        (12004, '[Reverb] Mark I', 'B', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Attack 20; passiva não revisada.'),
        (12005, '[Reverb] Mark II', 'B', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Energy Regen 40; passiva não revisada.'),
        (12006, '[Reverb] Mark III', 'B', 'SUPPORT', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: HP 20; passiva não revisada.'),
        (12008, '[Vortex] Arrow', 'B', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Impact 12; passiva não revisada.'),
        (12009, '[Vortex] Hatchet', 'B', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Energy Regen 16; passiva não revisada.'),
        (12007, '[Vortex] Revolver', 'B', 'STUN', 'Dados manuais do usuário. Base Stat: ATK 475; Main Stat: Attack 20; passiva não revisada.')
), inserted AS (
    INSERT INTO catalog.w_engines (id, rank_code, specialty_code, passives_reviewed, source_note)
    SELECT id, rank_code, specialty_code, FALSE, source_note FROM supplied
    RETURNING id
)
INSERT INTO catalog.w_engine_names (w_engine_id, locale, name)
SELECT supplied.id, 'en', supplied.name FROM supplied JOIN inserted USING (id);

-- A base dos motores de Armorer fornecidos é DEF, preservada como atributo distinto de ATQ.
INSERT INTO catalog.w_engine_base_stats (w_engine_id, stat_code, value) VALUES
    (14150, 'ATTACK', 713),
    (14130, 'ATTACK', 713),
    (14116, 'ATTACK', 713),
    (14157, 'ATTACK', 713),
    (14143, 'ATTACK', 743),
    (14146, 'ATTACK', 713),
    (14162, 'ATTACK', 713),
    (14161, 'DEFENSE', 431),
    (14119, 'ATTACK', 713),
    (14145, 'ATTACK', 713),
    (14131, 'ATTACK', 713),
    (14117, 'ATTACK', 713),
    (14133, 'ATTACK', 713),
    (14154, 'ATTACK', 713),
    (14118, 'ATTACK', 684),
    (14109, 'ATTACK', 743),
    (14134, 'ATTACK', 713),
    (14132, 'ATTACK', 713),
    (14110, 'ATTACK', 684),
    (14125, 'ATTACK', 713),
    (14163, 'ATTACK', 713),
    (14156, 'ATTACK', 713),
    (14159, 'ATTACK', 713),
    (14105, 'ATTACK', 713),
    (14141, 'ATTACK', 713),
    (14129, 'ATTACK', 713),
    (14151, 'ATTACK', 713),
    (14158, 'ATTACK', 743),
    (14164, 'ATTACK', 713),
    (14140, 'ATTACK', 713),
    (14137, 'ATTACK', 743),
    (14124, 'ATTACK', 713),
    (14139, 'ATTACK', 713),
    (14152, 'ATTACK', 713),
    (14138, 'ATTACK', 713),
    (14126, 'ATTACK', 713),
    (14155, 'ATTACK', 713),
    (14136, 'ATTACK', 713),
    (14153, 'ATTACK', 713),
    (14102, 'ATTACK', 684),
    (14104, 'ATTACK', 684),
    (14114, 'ATTACK', 684),
    (14149, 'ATTACK', 713),
    (14122, 'ATTACK', 713),
    (14107, 'ATTACK', 713),
    (14121, 'ATTACK', 684),
    (14147, 'ATTACK', 713),
    (14148, 'ATTACK', 713),
    (14120, 'ATTACK', 713),
    (13113, 'ATTACK', 624),
    (13112, 'ATTACK', 624),
    (13021, 'DEFENSE', 356),
    (13018, 'ATTACK', 594),
    (13135, 'ATTACK', 624),
    (13010, 'ATTACK', 594),
    (14001, 'ATTACK', 594),
    (13017, 'DEFENSE', 356),
    (13019, 'ATTACK', 594),
    (13101, 'ATTACK', 624),
    (13111, 'ATTACK', 624),
    (13009, 'ATTACK', 594),
    (13013, 'ATTACK', 594),
    (13144, 'ATTACK', 624),
    (13106, 'ATTACK', 624),
    (13115, 'ATTACK', 624),
    (13015, 'ATTACK', 594),
    (13007, 'ATTACK', 594),
    (13127, 'ATTACK', 624),
    (13006, 'ATTACK', 594),
    (13012, 'ATTACK', 594),
    (13014, 'ATTACK', 594),
    (13003, 'ATTACK', 594),
    (13016, 'ATTACK', 594),
    (13128, 'ATTACK', 624),
    (14003, 'ATTACK', 594),
    (13002, 'ATTACK', 594),
    (13011, 'ATTACK', 594),
    (13004, 'ATTACK', 594),
    (13108, 'ATTACK', 624),
    (13005, 'ATTACK', 594),
    (13001, 'ATTACK', 594),
    (13020, 'ATTACK', 594),
    (13103, 'ATTACK', 624),
    (13142, 'ATTACK', 624),
    (14002, 'ATTACK', 594),
    (13008, 'ATTACK', 594),
    (12015, 'ATTACK', 475),
    (12013, 'ATTACK', 475),
    (12014, 'ATTACK', 475),
    (12002, 'ATTACK', 475),
    (12003, 'ATTACK', 475),
    (12001, 'ATTACK', 475),
    (12016, 'DEFENSE', 282),
    (12010, 'ATTACK', 475),
    (12011, 'ATTACK', 356),
    (12012, 'ATTACK', 475),
    (12004, 'ATTACK', 475),
    (12005, 'ATTACK', 475),
    (12006, 'ATTACK', 475),
    (12008, 'ATTACK', 475),
    (12009, 'ATTACK', 475),
    (12007, 'ATTACK', 475);

-- FLAT em taxa crítica, dano crítico ou perfuração significa soma em pontos percentuais.
-- Main Stat sem '%' normalizado apenas conforme a confirmação explícita do usuário.
INSERT INTO catalog.w_engine_advanced_stats (w_engine_id, stat_code, modifier, value) VALUES
    (14150, 'ANOMALY_MASTERY', 'PERCENT', 30),
    (14130, 'ENERGY_REGEN', 'PERCENT', 60),
    (14116, 'IMPACT', 'PERCENT', 18),
    (14157, 'CRIT_RATE', 'FLAT', 24),
    (14143, 'CRIT_DAMAGE', 'FLAT', 48),
    (14146, 'CRIT_RATE', 'FLAT', 24),
    (14162, 'ENERGY_REGEN', 'PERCENT', 60),
    (14161, 'DEFENSE', 'PERCENT', 48),
    (14119, 'CRIT_RATE', 'FLAT', 24),
    (14145, 'HEALTH', 'PERCENT', 30),
    (14131, 'ATTACK', 'PERCENT', 30),
    (14117, 'ATTACK', 'PERCENT', 30),
    (14133, 'ANOMALY_PROFICIENCY', 'FLAT', 90),
    (14154, 'ANOMALY_MASTERY', 'PERCENT', 30),
    (14118, 'PENETRATION_RATE', 'FLAT', 24),
    (14109, 'CRIT_RATE', 'FLAT', 24),
    (14134, 'HEALTH', 'PERCENT', 30),
    (14132, 'CRIT_RATE', 'FLAT', 24),
    (14110, 'IMPACT', 'PERCENT', 18),
    (14125, 'IMPACT', 'PERCENT', 18),
    (14163, 'CRIT_RATE', 'FLAT', 24),
    (14156, 'ENERGY_REGEN', 'PERCENT', 60),
    (14159, 'CRIT_DAMAGE', 'FLAT', 48),
    (14105, 'HEALTH', 'PERCENT', 30),
    (14141, 'ENERGY_REGEN', 'PERCENT', 60),
    (14129, 'CRIT_RATE', 'FLAT', 24),
    (14151, 'ANOMALY_MASTERY', 'PERCENT', 30),
    (14158, 'ATTACK', 'PERCENT', 36),
    (14164, 'ANOMALY_MASTERY', 'PERCENT', 30),
    (14140, 'ATTACK', 'PERCENT', 30),
    (14137, 'HEALTH', 'PERCENT', 30),
    (14124, 'CRIT_DAMAGE', 'FLAT', 48),
    (14139, 'ATTACK', 'PERCENT', 30),
    (14152, 'ENERGY_REGEN', 'PERCENT', 60),
    (14138, 'CRIT_DAMAGE', 'FLAT', 48),
    (14126, 'ANOMALY_PROFICIENCY', 'FLAT', 90),
    (14155, 'ATTACK', 'PERCENT', 30),
    (14136, 'CRIT_RATE', 'FLAT', 24),
    (14153, 'HEALTH', 'PERCENT', 30),
    (14102, 'CRIT_RATE', 'FLAT', 24),
    (14104, 'ATTACK', 'PERCENT', 30),
    (14114, 'IMPACT', 'PERCENT', 18),
    (14149, 'ENERGY_REGEN', 'PERCENT', 60),
    (14122, 'ATTACK', 'PERCENT', 30),
    (14107, 'IMPACT', 'PERCENT', 18),
    (14121, 'PENETRATION_RATE', 'FLAT', 24),
    (14147, 'HEALTH', 'PERCENT', 30),
    (14148, 'CRIT_RATE', 'FLAT', 24),
    (14120, 'CRIT_DAMAGE', 'FLAT', 48),
    (13113, 'ATTACK', 'PERCENT', 25),
    (13112, 'DEFENSE', 'PERCENT', 40),
    (13021, 'CRIT_RATE', 'FLAT', 20),
    (13018, 'ANOMALY_PROFICIENCY', 'FLAT', 75),
    (13135, 'IMPACT', 'PERCENT', 15),
    (13010, 'DEFENSE', 'PERCENT', 40),
    (14001, 'CRIT_RATE', 'FLAT', 20),
    (13017, 'DEFENSE', 'PERCENT', 40),
    (13019, 'HEALTH', 'PERCENT', 25),
    (13101, 'IMPACT', 'PERCENT', 15),
    (13111, 'ENERGY_REGEN', 'PERCENT', 50),
    (13009, 'ANOMALY_PROFICIENCY', 'FLAT', 75),
    (13013, 'ATTACK', 'PERCENT', 25),
    (13144, 'HEALTH', 'PERCENT', 25),
    (13106, 'ATTACK', 'PERCENT', 25),
    (13115, 'ENERGY_REGEN', 'PERCENT', 50),
    (13015, 'CRIT_RATE', 'FLAT', 20),
    (13007, 'HEALTH', 'PERCENT', 25),
    (13127, 'ATTACK', 'PERCENT', 25),
    (13006, 'IMPACT', 'PERCENT', 15),
    (13012, 'ATTACK', 'PERCENT', 25),
    (13014, 'HEALTH', 'PERCENT', 25),
    (13003, 'ANOMALY_PROFICIENCY', 'FLAT', 75),
    (13016, 'IMPACT', 'PERCENT', 15),
    (13128, 'ATTACK', 'PERCENT', 25),
    (14003, 'IMPACT', 'PERCENT', 15),
    (13002, 'PENETRATION_RATE', 'FLAT', 20),
    (13011, 'ATTACK', 'PERCENT', 25),
    (13004, 'ATTACK', 'PERCENT', 25),
    (13108, 'ATTACK', 'PERCENT', 25),
    (13005, 'ENERGY_REGEN', 'PERCENT', 50),
    (13001, 'ATTACK', 'PERCENT', 25),
    (13020, 'IMPACT', 'PERCENT', 15),
    (13103, 'ENERGY_REGEN', 'PERCENT', 50),
    (13142, 'ATTACK', 'PERCENT', 25),
    (14002, 'ENERGY_REGEN', 'PERCENT', 50),
    (13008, 'ATTACK', 'PERCENT', 25),
    (12015, 'HEALTH', 'PERCENT', 20),
    (12013, 'DEFENSE', 'PERCENT', 32),
    (12014, 'DEFENSE', 'PERCENT', 32),
    (12002, 'ATTACK', 'PERCENT', 20),
    (12003, 'CRIT_RATE', 'FLAT', 16),
    (12001, 'ATTACK', 'PERCENT', 20),
    (12016, 'DEFENSE', 'PERCENT', 32),
    (12010, 'ATTACK', 'PERCENT', 20),
    (12011, 'ANOMALY_PROFICIENCY', 'FLAT', 60),
    (12012, 'PENETRATION_RATE', 'FLAT', 16),
    (12004, 'ATTACK', 'PERCENT', 20),
    (12005, 'ENERGY_REGEN', 'PERCENT', 40),
    (12006, 'HEALTH', 'PERCENT', 20),
    (12008, 'IMPACT', 'PERCENT', 12),
    (12009, 'ENERGY_REGEN', 'PERCENT', 16),
    (12007, 'ATTACK', 'PERCENT', 20);

-- Correção do usuário: Incarcerating Grip (14163) tem ATQ base 713 e taxa crítica +24 pontos percentuais.
-- Correção do usuário: [Magnetic Storm] Bravo (12011) tem Proficiência 60; ATQ base 356 preservado.
-- Decisão do usuário: passivas dos motores são efeitos de combate, fora da v1 do programa.
-- Detalhes ficam para a v2 do programa com cálculo de dano; passives_reviewed FALSE não bloqueia a ficha da v1.

-- CONJUNTOS: 30 IDs extraídos somente do texto das URLs fornecidas, sem acesso ao site.
-- As tabelas de conjuntos são criadas no início desta V2.
-- Máximos de 4 peças preservam condições e não incluem o bônus de 2 peças.
-- Contextos definidos pelo usuário: todos os 4-PC são COMBAT; 2-PC têm 26 SHEET e 4 COMBAT.
INSERT INTO catalog.stat_types (code, unit) VALUES ('WIND_DAMAGE_BONUS', 'PERCENT_POINTS');

WITH supplied(id, name, source_url) AS (
    VALUES
        (32800, 'Astral Voice', 'https://zzz.gachabase.net/drive-discs/32800/astral-voice/release?lang=en'),
        (32700, 'Branch & Blade Song', 'https://zzz.gachabase.net/drive-discs/32700/branch-blade-song/release?lang=en'),
        (33700, 'Bunny in Wonderland', 'https://zzz.gachabase.net/drive-discs/33700/bunny-in-wonderland/release?lang=en'),
        (31800, 'Chaos Jazz', 'https://zzz.gachabase.net/drive-discs/31800/chaos-jazz/release?lang=en'),
        (32300, 'Chaotic Metal', 'https://zzz.gachabase.net/drive-discs/32300/chaotic-metal/release?lang=en'),
        (33300, 'Dawn''s Bloom', 'https://zzz.gachabase.net/drive-discs/33300/dawns-bloom/release?lang=en'),
        (32600, 'Fanged Metal', 'https://zzz.gachabase.net/drive-discs/32600/fanged-metal/release?lang=en'),
        (34100, 'Feathered Fate', 'https://zzz.gachabase.net/drive-discs/34100/feathered-fate/release?lang=en'),
        (31300, 'Freedom Blues', 'https://zzz.gachabase.net/drive-discs/31300/freedom-blues/release?lang=en'),
        (31400, 'Hormone Punk', 'https://zzz.gachabase.net/drive-discs/31400/hormone-punk/release?lang=en'),
        (32200, 'Inferno Metal', 'https://zzz.gachabase.net/drive-discs/32200/inferno-metal/release?lang=en'),
        (33200, 'King of the Summit', 'https://zzz.gachabase.net/drive-discs/33200/king-of-the-summit/release?lang=en'),
        (33400, 'Moonlight Lullaby', 'https://zzz.gachabase.net/drive-discs/33400/moonlight-lullaby/release?lang=en'),
        (33800, 'Notes From the Chained', 'https://zzz.gachabase.net/drive-discs/33800/notes-from-the-chained/release?lang=en'),
        (33000, 'Phaethon''s Melody', 'https://zzz.gachabase.net/drive-discs/33000/phaethons-melody/release?lang=en'),
        (32500, 'Polar Metal', 'https://zzz.gachabase.net/drive-discs/32500/polar-metal/release?lang=en'),
        (31900, 'Proto Punk', 'https://zzz.gachabase.net/drive-discs/31900/proto-punk/release?lang=en'),
        (31100, 'Puffer Electro', 'https://zzz.gachabase.net/drive-discs/31100/puffer-electro/release?lang=en'),
        (32900, 'Shadow Harmony', 'https://zzz.gachabase.net/drive-discs/32900/shadow-harmony/release?lang=en'),
        (33600, 'Shining Aria', 'https://zzz.gachabase.net/drive-discs/33600/shining-aria/release?lang=en'),
        (31200, 'Shockstar Disco', 'https://zzz.gachabase.net/drive-discs/31200/shockstar-disco/release?lang=en'),
        (31500, 'Soul Rock', 'https://zzz.gachabase.net/drive-discs/31500/soul-rock/release?lang=en'),
        (31600, 'Swing Jazz', 'https://zzz.gachabase.net/drive-discs/31600/swing-jazz/release?lang=en'),
        (34000, 'The Sky Ablaze', 'https://zzz.gachabase.net/drive-discs/34000/the-sky-ablaze/release?lang=en'),
        (34200, 'Thorned Rose', 'https://zzz.gachabase.net/drive-discs/34200/thorned-rose/release?lang=en'),
        (32400, 'Thunder Metal', 'https://zzz.gachabase.net/drive-discs/32400/thunder-metal/release?lang=en'),
        (33500, 'White Water Ballad', 'https://zzz.gachabase.net/drive-discs/33500/white-water-ballad/release?lang=en'),
        (31000, 'Woodpecker Electro', 'https://zzz.gachabase.net/drive-discs/31000/woodpecker-electro/release?lang=en'),
        (33900, 'Wuthering Salon', 'https://zzz.gachabase.net/drive-discs/33900/wuthering-salon/release?lang=en'),
        (33100, 'Yunkui Tales', 'https://zzz.gachabase.net/drive-discs/33100/yunkui-tales/release?lang=en')
), inserted AS (
    INSERT INTO catalog.disc_sets (id, source_url, source_note)
    SELECT id, source_url, 'Dados e descrições fornecidos pelo usuário; ID extraído do texto da URL, sem acesso ao site.' FROM supplied
    RETURNING id
)
INSERT INTO catalog.disc_set_names (disc_set_id, locale, name)
SELECT supplied.id, 'en', supplied.name FROM supplied JOIN inserted USING (id);

INSERT INTO catalog.disc_set_effects (
    disc_set_id, required_pieces, effect_key, context, source_description, analysis, review_note
) VALUES
    (32800, 2, '2PC', 'SHEET', 'ATK +10%.', '{"schema_version":1,"bonus":{"stat_code":"ATTACK","modifier":"PERCENT","value":10}}'::JSONB, NULL),
    (32800, 4, '4PC', 'COMBAT', 'Whenever any squad member enters the field using a Quick Assist, all squad members gain 1 stack of Astral, up to a maximum of 3 stacks, and lasting 15s. Repeated triggers reset the duration. Each stack of Astral increases the DMG dealt by the character entering the field using a Quick Assist by 8%. Only one of this effect can be active at a time in the same squad.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"QUICK_ASSIST_DAMAGE_BONUS","maximum":24,"unit":"PERCENT_POINTS","conditions":["Entrar usando Quick Assist","3 acúmulos de Astral"],"per_stack":8,"max_stacks":3,"duration_seconds":15,"target":"personagem que entra por Quick Assist","refresh":"novos gatilhos renovam duração","stacking":"somente um efeito ativo na equipe"}]}'::JSONB, NULL),
    (32700, 2, '2PC', 'SHEET', 'CRIT DMG +16%.', '{"schema_version":1,"bonus":{"stat_code":"CRIT_DAMAGE","modifier":"FLAT","value":16}}'::JSONB, NULL),
    (32700, 4, '4PC', 'COMBAT', 'When Anomaly Mastery exceeds or equals 115 points, the equipper''s CRIT damage increases by 30%. When any squad member applies Freeze or triggers the Shatter effect on an enemy, the equipper''s CRIT Rate increases by 12%, lasting 15s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_DAMAGE","maximum":30,"unit":"PERCENT_POINTS","conditions":["Maestria de Anomalia do portador >=115"]},{"metric":"CRIT_RATE","maximum":12,"unit":"PERCENT_POINTS","conditions":["Membro da equipe aplica Freeze ou Shatter"],"duration_seconds":15}]}'::JSONB, 'Classificado como COMBAT por decisão explícita do usuário; substitui a pendência de contexto.'),
    (33700, 2, '2PC', 'SHEET', 'HP +10%.', '{"schema_version":1,"bonus":{"stat_code":"HEALTH","modifier":"PERCENT","value":10}}'::JSONB, NULL),
    (33700, 4, '4PC', 'COMBAT', 'When the equipper is a Defense character: When the equipper launches an EX Special Attack or any squad member triggers a Defensive Assist or Evasive Assist, all squad members'' DMG increases by 6%, stacking up to 3 times, lasting 25s. Stacks decay one at a time, and duration refreshes when gained or decayed. Passive effects of the same name do not stack.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TEAM_DAMAGE_BONUS","maximum":18,"unit":"PERCENT_POINTS","conditions":["Portador Defense","EX Special do portador ou Defensive/Evasive Assist da equipe","3 acúmulos"],"per_stack":6,"max_stacks":3,"duration_seconds":25,"refresh":"duração renova ao ganhar ou perder acúmulo","decay":"um acúmulo por vez","stacking":"efeitos de mesmo nome não acumulam"}]}'::JSONB, NULL),
    (31800, 2, '2PC', 'SHEET', 'Anomaly Proficiency +30.', '{"schema_version":1,"bonus":{"stat_code":"ANOMALY_PROFICIENCY","modifier":"FLAT","value":30}}'::JSONB, NULL),
    (31800, 4, '4PC', 'COMBAT', 'Fire DMG and Electric DMG are increased by 15%. When off-field, the damage caused by EX Special Attacks and Assist Attacks is increased by 20%. When the character switches back onto the field, this buff continues for 5s. The lasting effect can be triggered once every 7.5s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"FIRE_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":[]},{"metric":"ELECTRIC_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":[]},{"metric":"EX_SPECIAL_DAMAGE_BONUS","maximum":20,"unit":"PERCENT_POINTS","conditions":["Portador fora de campo ou nos 5s de persistência ao voltar"],"off_field":true,"linger_seconds":5,"linger_cooldown_seconds":7.5},{"metric":"ASSIST_ATTACK_DAMAGE_BONUS","maximum":20,"unit":"PERCENT_POINTS","conditions":["Portador fora de campo ou nos 5s de persistência ao voltar"],"off_field":true,"linger_seconds":5,"linger_cooldown_seconds":7.5}]}'::JSONB, 'Classificado como COMBAT por decisão explícita do usuário; substitui a pendência de contexto.'),
    (32300, 2, '2PC', 'SHEET', 'Ether DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ETHER_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (32300, 4, '4PC', 'COMBAT', 'The equipper''s CRIT DMG increases by 20%. When any character in the squad triggers Corruption''s additional DMG, this effect further increases by 5.5% for 8s, stacking up to 6 times. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_DAMAGE","maximum":53,"unit":"PERCENT_POINTS","conditions":["6 acúmulos gerados por dano adicional de Corruption da equipe"],"unconditional":20,"per_stack":5.5,"max_stacks":6,"stack_duration_seconds":8,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, 'Classificado como COMBAT por decisão explícita do usuário; substitui a pendência de contexto.'),
    (33300, 2, '2PC', 'COMBAT', 'Increases Basic Attack DMG by 15%.', '{"schema_version":1,"components":[{"metric":"BASIC_ATTACK_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":[]}]}'::JSONB, NULL),
    (33300, 4, '4PC', 'COMBAT', 'Increases Basic Attack DMG by 20%. When equipped by an Attack character, using an EX Special Attack or Ultimate will further increase Basic Attack DMG by 20% for 25s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"BASIC_ATTACK_DAMAGE_BONUS","maximum":40,"unit":"PERCENT_POINTS","conditions":["Portador Attack","EX Special ou Ultimate nos últimos 25s"],"unconditional":20,"conditional":20,"duration_seconds":25,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, NULL),
    (32600, 2, '2PC', 'SHEET', 'Physical DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"PHYSICAL_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (32600, 4, '4PC', 'COMBAT', 'Whenever a squad member inflicts Assault on an enemy, the equipper deals 35% increased damage to the target for 12s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"DAMAGE_BONUS","maximum":35,"unit":"PERCENT_POINTS","conditions":["Equipe inflige Assault no alvo"],"duration_seconds":12,"target":"alvo afetado"}]}'::JSONB, NULL),
    (34100, 2, '2PC', 'SHEET', 'Anomaly Proficiency +30', '{"schema_version":1,"bonus":{"stat_code":"ANOMALY_PROFICIENCY","modifier":"FLAT","value":30}}'::JSONB, NULL),
    (34100, 4, '4PC', 'COMBAT', 'When the equipper enters the battlefield or is switched in as the active character, they gain the following buff: Anomaly Proficiency increases by 50. If the equipper is a Lumiflux character, Attribute Anomaly DMG increases by 15%, lasting 15s.This buff remains active while the equipper is off-field.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ANOMALY_PROFICIENCY","maximum":50,"unit":"NUMBER","conditions":["Portador entra no campo ou é selecionado como ativo"],"persists_off_field":true},{"metric":"ATTRIBUTE_ANOMALY_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":["Portador Lumiflux","Ativação ao entrar no campo"],"duration_seconds":15,"persists_off_field":true}],"review_notes":["O texto menciona 15s na parcela Lumiflux; confirmar se essa duração também rege o bônus de Proficiência."]}'::JSONB, NULL),
    (31300, 2, '2PC', 'SHEET', 'Anomaly Proficiency +30.', '{"schema_version":1,"bonus":{"stat_code":"ANOMALY_PROFICIENCY","modifier":"FLAT","value":30}}'::JSONB, NULL),
    (31300, 4, '4PC', 'COMBAT', 'When an EX Special Attack hits an enemy, reduce the targets Anomaly Buildup RES to equippers attribute by 20% for 8s. This effect does not stack with others of the same attribute.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TARGET_ANOMALY_BUILDUP_RES_REDUCTION","maximum":20,"unit":"PERCENT_POINTS","conditions":["EX Special acerta o alvo"],"duration_seconds":8,"attribute":"atributo do portador","stacking":"não acumula com outros efeitos do mesmo atributo"}]}'::JSONB, NULL),
    (31400, 2, '2PC', 'SHEET', 'ATK +10%.', '{"schema_version":1,"bonus":{"stat_code":"ATTACK","modifier":"PERCENT","value":10}}'::JSONB, NULL),
    (31400, 4, '4PC', 'COMBAT', 'Upon entering combat or switching in, its user''s ATK increased by 25% for 10s. This effect can be triggered once every 20s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ATTACK_PERCENT","maximum":25,"unit":"PERCENT_POINTS","conditions":["Entrar em combate ou trocar para o portador"],"duration_seconds":10,"cooldown_seconds":20}]}'::JSONB, NULL),
    (32200, 2, '2PC', 'SHEET', 'Fire DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"FIRE_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (32200, 4, '4PC', 'COMBAT', 'Upon hitting a Burning enemy, the equipper''s CRIT Rate is increased by 28% for 8s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_RATE","maximum":28,"unit":"PERCENT_POINTS","conditions":["Acertar inimigo com Burning"],"duration_seconds":8}]}'::JSONB, NULL),
    (33200, 2, '2PC', 'COMBAT', 'Increases Daze of attacks by 6%.', '{"schema_version":1,"components":[{"metric":"DAZE_BONUS","maximum":6,"unit":"PERCENT_POINTS","conditions":["Daze de ataques"]}],"notes":["Bônus de Daze não é bônus do atributo Impacto."]}'::JSONB, NULL),
    (33200, 4, '4PC', 'COMBAT', 'When the equipper is a Stun character and uses an EX Special Attack or Chain Attack, increases CRIT DMG of all squad members by 15%, and when the equipper''s CRIT Rate is more than or equal to 50%, further increases CRIT DMG by 15%, lasting 15s. Repeated triggers reset the duration. Passive effects of the same name do not stack.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TEAM_CRIT_DAMAGE","maximum":30,"unit":"PERCENT_POINTS","conditions":["Portador Stun","Usar EX Special ou Chain Attack","Taxa crítica do portador >=50%"],"conditional_base":15,"threshold_extra":15,"duration_seconds":15,"refresh":"gatilhos repetidos renovam duração","stacking":"efeitos de mesmo nome não acumulam"}]}'::JSONB, NULL),
    (33400, 2, '2PC', 'SHEET', 'Energy Regen +20%.', '{"schema_version":1,"bonus":{"stat_code":"ENERGY_REGEN","modifier":"PERCENT","value":20}}'::JSONB, NULL),
    (33400, 4, '4PC', 'COMBAT', 'When the equipper is a Support character and uses an EX Special Attack or Ultimate, the DMG dealt by all squad members increases by 18% for 25s. Repeated triggers reset the duration. Passive effects of the same name do not stack.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TEAM_DAMAGE_BONUS","maximum":18,"unit":"PERCENT_POINTS","conditions":["Portador Support","Usar EX Special ou Ultimate"],"duration_seconds":25,"refresh":"gatilhos repetidos renovam duração","stacking":"efeitos de mesmo nome não acumulam"}]}'::JSONB, NULL),
    (33800, 2, '2PC', 'SHEET', 'Ice DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ICE_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (33800, 4, '4PC', 'COMBAT', 'When the equipper triggers Abloom, their Anomaly Proficiency increases by 48 for 30s; repeated triggers reset the duration. When the equipper triggers a Freeze effect, their All-Attribute Anomaly DMG and Disorder DMG increase by 16% for 30s; repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ANOMALY_PROFICIENCY","maximum":48,"unit":"NUMBER","conditions":["Portador ativa Abloom"],"duration_seconds":30,"refresh":"gatilhos repetidos renovam duração"},{"metric":"ALL_ATTRIBUTE_ANOMALY_DAMAGE_BONUS","maximum":16,"unit":"PERCENT_POINTS","conditions":["Portador ativa Freeze"],"duration_seconds":30,"refresh":"gatilhos repetidos renovam duração"},{"metric":"DISORDER_DAMAGE_BONUS","maximum":16,"unit":"PERCENT_POINTS","conditions":["Portador ativa Freeze"],"duration_seconds":30,"refresh":"gatilhos repetidos renovam duração"}],"review_notes":["As parcelas têm condições próprias; não assumir que todo portador consegue ativar todas simultaneamente."]}'::JSONB, NULL),
    (33000, 2, '2PC', 'SHEET', 'Anomaly Mastery +8%.', '{"schema_version":1,"bonus":{"stat_code":"ANOMALY_MASTERY","modifier":"PERCENT","value":8}}'::JSONB, NULL),
    (33000, 4, '4PC', 'COMBAT', 'When any squad member uses an EX Special Attack, the equipper''s Anomaly Proficiency increases by 45 for 8s. If the character using the EX Special Attack is not the equipper, the equipper''s Ether DMG is increased by 25%.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ANOMALY_PROFICIENCY","maximum":45,"unit":"NUMBER","conditions":["Qualquer membro da equipe usa EX Special"],"duration_seconds":8},{"metric":"ETHER_DAMAGE_BONUS","maximum":25,"unit":"PERCENT_POINTS","conditions":["Outro membro da equipe, diferente do portador, usa EX Special"]}],"review_notes":["A duração de 8s é explícita na parcela de Proficiência; confirmar sua extensão à parcela de dano Éter antes de simular."]}'::JSONB, NULL),
    (32500, 2, '2PC', 'SHEET', 'Ice DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ICE_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (32500, 4, '4PC', 'COMBAT', 'Increases the DMG of Basic Attack and Dash Attack by 20%. When any squad member inflicts Freeze or Shatter, this effect increases by an additional 20% for 12s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"BASIC_ATTACK_DAMAGE_BONUS","maximum":40,"unit":"PERCENT_POINTS","conditions":["Equipe inflige Freeze ou Shatter"],"unconditional":20,"conditional":20,"duration_seconds":12},{"metric":"DASH_ATTACK_DAMAGE_BONUS","maximum":40,"unit":"PERCENT_POINTS","conditions":["Equipe inflige Freeze ou Shatter"],"unconditional":20,"conditional":20,"duration_seconds":12}]}'::JSONB, NULL),
    (31900, 2, '2PC', 'COMBAT', 'Shield Effect +15%.', '{"schema_version":1,"components":[{"metric":"SHIELD_EFFECT_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":[]}]}'::JSONB, 'Classificado como COMBAT por decisão explícita do usuário; substitui a pendência de contexto.'),
    (31900, 4, '4PC', 'COMBAT', 'When any squad member triggers a Defensive Assist or Evasive Assist, all squad members deal 15% increased DMG, lasting 10s. Passive effects of the same name do not stack.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TEAM_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":["Qualquer membro da equipe ativa Defensive Assist ou Evasive Assist"],"duration_seconds":10,"stacking":"efeitos de mesmo nome não acumulam"}]}'::JSONB, NULL),
    (31100, 2, '2PC', 'SHEET', 'PEN Ratio +8%.', '{"schema_version":1,"bonus":{"stat_code":"PENETRATION_RATE","modifier":"FLAT","value":8}}'::JSONB, NULL),
    (31100, 4, '4PC', 'COMBAT', 'Ultimate DMG increases by 20%. Launching an Ultimate increases the equippers ATK by 15% for 12s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ULTIMATE_DAMAGE_BONUS","maximum":20,"unit":"PERCENT_POINTS","conditions":[]},{"metric":"ATTACK_PERCENT","maximum":15,"unit":"PERCENT_POINTS","conditions":["Portador usa Ultimate"],"duration_seconds":12}]}'::JSONB, NULL),
    (32900, 2, '2PC', 'COMBAT', 'The DMG of Aftershocks and Dash Attacks is increased by 15%.', '{"schema_version":1,"components":[{"metric":"AFTERSHOCK_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":["Aftershock"]},{"metric":"DASH_ATTACK_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":["Dash Attack"]}]}'::JSONB, NULL),
    (32900, 4, '4PC', 'COMBAT', 'Upon hitting an enemy with an Aftershock or Dash Attack, if the DMG dealt aligns with the equipper''s attribute, the equipper gains 1 stack of a buff effect, at most once per use of a skill. For each stack, the equipper''s ATK increases by 4%, and CRIT Rate increases by 4%. The effect can stack up to 3 times and lasts for 15s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ATTACK_PERCENT","maximum":12,"unit":"PERCENT_POINTS","conditions":["Acertar com Aftershock ou Dash Attack do atributo do portador","3 acúmulos"],"per_stack":4,"max_stacks":3,"duration_seconds":15,"limit":"no máximo um acúmulo por uso de habilidade","refresh":"gatilhos repetidos renovam duração"},{"metric":"CRIT_RATE","maximum":12,"unit":"PERCENT_POINTS","conditions":["Acertar com Aftershock ou Dash Attack do atributo do portador","3 acúmulos"],"per_stack":4,"max_stacks":3,"duration_seconds":15,"limit":"no máximo um acúmulo por uso de habilidade","refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, NULL),
    (33600, 2, '2PC', 'SHEET', 'Ether DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ETHER_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (33600, 4, '4PC', 'COMBAT', 'When the equipper''s Basic Attack hits an enemy, their Anomaly Proficiency increases by 36, lasting 8s. Repeated triggers reset the duration. When any enemy on the field is Stunned, the equipper''s DMG increases by 25% for 18s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ANOMALY_PROFICIENCY","maximum":36,"unit":"NUMBER","conditions":["Basic Attack do portador acerta inimigo"],"duration_seconds":8,"refresh":"gatilhos repetidos renovam duração"},{"metric":"DAMAGE_BONUS","maximum":25,"unit":"PERCENT_POINTS","conditions":["Algum inimigo no campo fica Stunned"],"duration_seconds":18,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, NULL),
    (31200, 2, '2PC', 'SHEET', 'Impact +6%.', '{"schema_version":1,"bonus":{"stat_code":"IMPACT","modifier":"PERCENT","value":6}}'::JSONB, NULL),
    (31200, 4, '4PC', 'COMBAT', 'Basic Attacks, Dash Attacks, and Dodge Counters, inflict 20% more Daze upon the main target.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"DAZE_BONUS","maximum":20,"unit":"PERCENT_POINTS","conditions":["Basic Attack, Dash Attack ou Dodge Counter"],"target":"alvo principal"}]}'::JSONB, NULL),
    (31500, 2, '2PC', 'SHEET', 'DEF +16%.', '{"schema_version":1,"bonus":{"stat_code":"DEFENSE","modifier":"PERCENT","value":16}}'::JSONB, NULL),
    (31500, 4, '4PC', 'COMBAT', 'Upon receiving an enemy attack and losing HP, the equipper takes 40% less DMG for 2.5s. This effect can trigger once every 15s.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"DAMAGE_TAKEN_REDUCTION","maximum":40,"unit":"PERCENT_POINTS","conditions":["Portador recebe ataque inimigo e perde PV"],"duration_seconds":2.5,"cooldown_seconds":15}]}'::JSONB, NULL),
    (31600, 2, '2PC', 'SHEET', 'Energy Regen +20%.', '{"schema_version":1,"bonus":{"stat_code":"ENERGY_REGEN","modifier":"PERCENT","value":20}}'::JSONB, NULL),
    (31600, 4, '4PC', 'COMBAT', 'Launching a Chain Attack or Ultimate increases all squad members'' DMG by 15% for 12s. Passive effects of the same name do not stack.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"TEAM_DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":["Portador usa Chain Attack ou Ultimate"],"duration_seconds":12,"stacking":"efeitos de mesmo nome não acumulam"}]}'::JSONB, NULL),
    (34000, 2, '2PC', 'SHEET', 'Ether DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ETHER_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (34000, 4, '4PC', 'COMBAT', 'When the equipper is an Ether attribute Agent, their CRIT DMG increases by 30%. When the equipper uses an EX Special Attack or Ultimate, their ATK increases by 10% for 30s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_DAMAGE","maximum":30,"unit":"PERCENT_POINTS","conditions":["Portador Ether"]},{"metric":"ATTACK_PERCENT","maximum":10,"unit":"PERCENT_POINTS","conditions":["Portador usa EX Special ou Ultimate"],"duration_seconds":30,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, 'O usuário testou The Sky Ablaze no jogo e confirmou o efeito de 4 peças como COMBAT.'),
    (34200, 2, '2PC', 'SHEET', 'DEF +16%', '{"schema_version":1,"bonus":{"stat_code":"DEFENSE","modifier":"PERCENT","value":16}}'::JSONB, NULL),
    (34200, 4, '4PC', 'COMBAT', 'The equipper''s DMG increases by 15%. When the equipper''s initial DEF is at least 1,000/1,800, CRIT Rate increases by 8/16%.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"DAMAGE_BONUS","maximum":15,"unit":"PERCENT_POINTS","conditions":[]},{"metric":"CRIT_RATE","maximum":16,"unit":"PERCENT_POINTS","conditions":["DEF inicial do portador >=1800"],"tiers":[{"minimum_initial_defense":1000,"value":8},{"minimum_initial_defense":1800,"value":16}],"tier_mode":"usar o maior patamar atingido, não somar 8 e 16"}]}'::JSONB, 'Classificado como COMBAT por decisão explícita do usuário; substitui a pendência de contexto.'),
    (32400, 2, '2PC', 'SHEET', 'Electric DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"ELECTRIC_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (32400, 4, '4PC', 'COMBAT', 'As long as an enemy in combat is Shocked, the equipper''s ATK is increased by 28%.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ATTACK_PERCENT","maximum":28,"unit":"PERCENT_POINTS","conditions":["Há inimigo em combate com Shocked"],"duration":"enquanto a condição persistir"}]}'::JSONB, NULL),
    (33500, 2, '2PC', 'SHEET', 'Physical DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"PHYSICAL_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (33500, 4, '4PC', 'COMBAT', 'When the equipper is within any [Ether Veil], their CRIT Rate increases by 10%. After leaving the Ether Veil, this buff remains for 15s. If the equipper is an Attack character, activating an Ether Veil or extending an Ether Veil''s duration increases their CRIT Rate by 10% and ATK by 10% for 30s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_RATE","maximum":20,"unit":"PERCENT_POINTS","conditions":["Dentro de qualquer Ether Veil ou até 15s após sair","Portador Attack","Ativar ou estender Ether Veil e manter o bônus de 30s"],"parts":[{"value":10,"condition":"presença em Ether Veil","linger_seconds":15},{"value":10,"condition":"portador Attack ativa ou estende Ether Veil","duration_seconds":30}]},{"metric":"ATTACK_PERCENT","maximum":10,"unit":"PERCENT_POINTS","conditions":["Portador Attack ativa ou estende Ether Veil"],"duration_seconds":30,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, NULL),
    (31000, 2, '2PC', 'SHEET', 'CRIT Rate +8%.', '{"schema_version":1,"bonus":{"stat_code":"CRIT_RATE","modifier":"FLAT","value":8}}'::JSONB, NULL),
    (31000, 4, '4PC', 'COMBAT', 'Triggering a critical hit with a Basic Attack, Dodge Counter or EX Special Attack increases the equippers ATK by 9% for 6s. The buff duration for different skills are calculated separately.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ATTACK_PERCENT","maximum":null,"unit":"PERCENT_POINTS","conditions":["Críticos de Basic Attack, Dodge Counter ou EX Special"],"per_trigger":9,"duration_seconds":6,"independent_duration_per_skill":true,"hypothetical_maximum":27,"maximum_status":"PENDING","hypothesis":"9% de cada uma das três categorias ativos simultaneamente; confirmar limite de uma instância por categoria"}],"review_notes":["O texto informa durações independentes por habilidade, sem explicitar o limite de acúmulos. 27% é hipótese, não máximo confirmado."]}'::JSONB, NULL),
    (33900, 2, '2PC', 'SHEET', 'Wind DMG +10%.', '{"schema_version":1,"bonus":{"stat_code":"WIND_DAMAGE_BONUS","modifier":"FLAT","value":10}}'::JSONB, NULL),
    (33900, 4, '4PC', 'COMBAT', 'When the equipper uses an EX Special Attack, their Anomaly Proficiency increases by 25, stacking up to 2 times, and lasting 40s; repeated triggers reset the duration. When the equipper triggers Windswept, their DMG increases by 18% for 40s. Repeated triggers reset the duration.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"ANOMALY_PROFICIENCY","maximum":50,"unit":"NUMBER","conditions":["Usar EX Special e atingir 2 acúmulos"],"per_stack":25,"max_stacks":2,"duration_seconds":40,"refresh":"gatilhos repetidos renovam duração"},{"metric":"DAMAGE_BONUS","maximum":18,"unit":"PERCENT_POINTS","conditions":["Portador ativa Windswept"],"duration_seconds":40,"refresh":"gatilhos repetidos renovam duração"}]}'::JSONB, NULL),
    (33100, 2, '2PC', 'SHEET', 'HP +10%.', '{"schema_version":1,"bonus":{"stat_code":"HEALTH","modifier":"PERCENT","value":10}}'::JSONB, NULL),
    (33100, 4, '4PC', 'COMBAT', 'When using [EX Special Attack], [Chain Attack], or [Ultimate], CRIT Rate increases by 4%, stacking up to 3 times and lasting 15s. Repeated triggers reset the duration. When having 3 stacks of this effect, Sheer DMG increases by 10%.', '{"schema_version":1,"maxima_scope":"4PC_ONLY","components":[{"metric":"CRIT_RATE","maximum":12,"unit":"PERCENT_POINTS","conditions":["Usar EX Special, Chain Attack ou Ultimate","3 acúmulos"],"per_stack":4,"max_stacks":3,"duration_seconds":15,"refresh":"gatilhos repetidos renovam duração"},{"metric":"SHEER_DAMAGE_BONUS","maximum":10,"unit":"PERCENT_POINTS","conditions":["Manter 3 acúmulos do efeito de taxa crítica"]}]}'::JSONB, NULL);

-- Bônus de ficha confirmados de 2 peças. Daze, Basic Attack e Aftershock não viram atributos genéricos.
INSERT INTO catalog.disc_set_effect_bonuses (
    disc_set_id, required_pieces, effect_key, stat_code, modifier, value
) VALUES
    (32800, 2, '2PC', 'ATTACK', 'PERCENT', 10),
    (32700, 2, '2PC', 'CRIT_DAMAGE', 'FLAT', 16),
    (33700, 2, '2PC', 'HEALTH', 'PERCENT', 10),
    (31800, 2, '2PC', 'ANOMALY_PROFICIENCY', 'FLAT', 30),
    (32300, 2, '2PC', 'ETHER_DAMAGE_BONUS', 'FLAT', 10),
    (32600, 2, '2PC', 'PHYSICAL_DAMAGE_BONUS', 'FLAT', 10),
    (34100, 2, '2PC', 'ANOMALY_PROFICIENCY', 'FLAT', 30),
    (31300, 2, '2PC', 'ANOMALY_PROFICIENCY', 'FLAT', 30),
    (31400, 2, '2PC', 'ATTACK', 'PERCENT', 10),
    (32200, 2, '2PC', 'FIRE_DAMAGE_BONUS', 'FLAT', 10),
    (33400, 2, '2PC', 'ENERGY_REGEN', 'PERCENT', 20),
    (33800, 2, '2PC', 'ICE_DAMAGE_BONUS', 'FLAT', 10),
    (33000, 2, '2PC', 'ANOMALY_MASTERY', 'PERCENT', 8),
    (32500, 2, '2PC', 'ICE_DAMAGE_BONUS', 'FLAT', 10),
    (31100, 2, '2PC', 'PENETRATION_RATE', 'FLAT', 8),
    (33600, 2, '2PC', 'ETHER_DAMAGE_BONUS', 'FLAT', 10),
    (31200, 2, '2PC', 'IMPACT', 'PERCENT', 6),
    (31500, 2, '2PC', 'DEFENSE', 'PERCENT', 16),
    (31600, 2, '2PC', 'ENERGY_REGEN', 'PERCENT', 20),
    (34000, 2, '2PC', 'ETHER_DAMAGE_BONUS', 'FLAT', 10),
    (34200, 2, '2PC', 'DEFENSE', 'PERCENT', 16),
    (32400, 2, '2PC', 'ELECTRIC_DAMAGE_BONUS', 'FLAT', 10),
    (33500, 2, '2PC', 'PHYSICAL_DAMAGE_BONUS', 'FLAT', 10),
    (31000, 2, '2PC', 'CRIT_RATE', 'FLAT', 8),
    (33900, 2, '2PC', 'WIND_DAMAGE_BONUS', 'FLAT', 10),
    (33100, 2, '2PC', 'HEALTH', 'PERCENT', 10);

-- Preservar a descrição completa e as ambiguidades de máximo e duração para a futura etapa de dano.
-- Woodpecker: 27% ATQ é hipótese de três categorias independentes; máximo confirmado permanece NULL.

-- PENDENTE DA V1 DO PROGRAMA: integração dos atributos do catálogo na engine.
-- Duas personagens de collab serão enviadas futuramente.
-- Sheer Force: fórmula específica por personagem ainda não fornecida nem implementada.
-- Armorer: conversão de dano crítico normal em taxa crítica ainda sem proporção/condições informadas.
