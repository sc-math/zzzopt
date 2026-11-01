-- Verificações de integração do catálogo. As alterações de teste são revertidas no final.
BEGIN;

\echo 'Deve preservar os 63 IDs fornecidos e seus nomes em inglês'
DO $test$
DECLARE
    expected_ids BIGINT[] := ARRAY[
        1211,1401,1011,1111,1501,1201,1311,1471,1121,1081,1171,1071,1521,1611,1061,1481,
        1191,1321,1181,1091,1291,1261,1391,1101,1441,1161,1451,1151,1511,1021,1031,1571,
        1301,1421,1641,1281,1541,1351,1551,1251,1581,1621,1461,1271,1631,1591,1381,1041,
        1131,1531,1601,1491,1361,1221,1411,1561,1331,1141,1431,1051,1371,1341,1241
    ];
BEGIN
    IF (SELECT count(*) FROM catalog.agent_names WHERE agent_id = ANY(expected_ids) AND locale = 'en') <> 63 THEN
        RAISE EXCEPTION 'Faltam personagens ou nomes em inglês na carga fornecida.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM catalog.agent_names WHERE agent_id = 1491 AND locale = 'en' AND name = 'Sunna')
       OR NOT EXISTS (SELECT 1 FROM catalog.agent_names WHERE agent_id = 1601 AND locale = 'en' AND name = 'Sunbringer') THEN
        RAISE EXCEPTION 'Os IDs corrigidos de Sunna e Sunbringer não foram preservados.';
    END IF;
END
$test$;

\echo 'Deve aceitar o rank I de Pyrois e preservar seu símbolo de infinito'
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM catalog.agents a JOIN catalog.agent_ranks r ON r.code = a.rank_code
        WHERE a.id = 1551 AND r.code = 'I' AND r.symbol = '∞'
    ) THEN
        RAISE EXCEPTION 'Rank especial de Pyrois não preservado.';
    END IF;
END
$test$;

\echo 'Deve preservar os quatro elementos variantes e seus elementos básicos'
DO $test$
BEGIN
    IF (SELECT count(*) FROM catalog.elements WHERE
        (code = 'FROST' AND base_element_code = 'ICE') OR
        (code = 'AURIC_INK' AND base_element_code = 'ETHER') OR
        (code = 'HONED_EDGE' AND base_element_code = 'PHYSICAL') OR
        (code = 'GENESIS_FLARE' AND base_element_code = 'FIRE')) <> 4 THEN
        RAISE EXCEPTION 'Relações dos elementos variantes incorretas.';
    END IF;
END
$test$;

\echo 'Deve impedir IDs duplicados e traduções vinculadas a personagens inexistentes'
DO $test$
BEGIN
    BEGIN
        INSERT INTO catalog.agents (id, rank_code, element_code, specialty_code, faction_code)
        SELECT id, rank_code, element_code, specialty_code, faction_code FROM catalog.agents WHERE id = 1501;
        RAISE EXCEPTION 'Um ID de personagem duplicado foi aceito.';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;
    BEGIN
        INSERT INTO catalog.agent_names (agent_id, locale, name)
        VALUES (-1, 'en', 'Personagem fictício do teste');
        RAISE EXCEPTION 'Uma tradução sem personagem foi aceita.';
    EXCEPTION WHEN foreign_key_violation THEN
        NULL;
    END;
END
$test$;

\echo 'Deve permitir nomes em dois idiomas sem duplicar o personagem ou alterar seus atributos'
INSERT INTO catalog.locales (code) VALUES ('x-catalog-test');
INSERT INTO catalog.agent_names (agent_id, locale, name)
VALUES (1501, 'x-catalog-test', 'Aria — nome fictício do teste');

DO $test$
BEGIN
    IF (SELECT count(*) FROM catalog.agent_names WHERE agent_id = 1501
        AND locale IN ('en', 'x-catalog-test')) <> 2 THEN
        RAISE EXCEPTION 'Não foi possível adicionar um nome localizado independente.';
    END IF;
    IF (SELECT count(*) FROM catalog.agents WHERE id = 1501) <> 1 THEN
        RAISE EXCEPTION 'A localização duplicou o personagem.';
    END IF;
END
$test$;

ROLLBACK;
\echo 'Catálogo validado; dados fictícios de integração revertidos'
