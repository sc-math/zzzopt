-- Snapshot somente de dados do catálogo, sem credenciais/configuração/histórico técnico.
-- JSONB torna a ordem das colunas irrelevante. O script compara todas as linhas ordenadas.
SELECT format(
    'SELECT jsonb_build_object(''table'', %L, ''row'', to_jsonb(entry)) FROM catalog.%I entry ORDER BY to_jsonb(entry)::text;',
    tablename, tablename
)
FROM pg_catalog.pg_tables
WHERE schemaname = 'catalog'
  AND tablename NOT IN (
      'agent_ranks', 'w_engine_ranks',
      'w_engine_base_stats', 'w_engine_advanced_stats', 'w_engine_stats'
  )
ORDER BY tablename
\gexec

-- Os códigos de rank das entidades já estão no snapshot. As tabelas de domínios/símbolos
-- são conferidas integralmente pela V3 antes de serem substituídas por enums/checks.
SELECT CASE WHEN to_regclass('catalog.w_engine_stats') IS NULL THEN
    'SELECT jsonb_build_object(''table'', ''w_engine_base_stats'', ''row'', to_jsonb(entry)) FROM catalog.w_engine_base_stats entry;'
ELSE
    'SELECT jsonb_build_object(''table'', ''w_engine_base_stats'', ''row'', jsonb_build_object(''w_engine_id'', w_engine_id, ''stat_code'', stat_code, ''value'', value)) FROM catalog.w_engine_stats WHERE role = ''BASE'';'
END
\gexec

SELECT CASE WHEN to_regclass('catalog.w_engine_stats') IS NULL THEN
    'SELECT jsonb_build_object(''table'', ''w_engine_advanced_stats'', ''row'', to_jsonb(entry)) FROM catalog.w_engine_advanced_stats entry;'
ELSE
    'SELECT jsonb_build_object(''table'', ''w_engine_advanced_stats'', ''row'', jsonb_build_object(''w_engine_id'', w_engine_id, ''stat_code'', stat_code, ''modifier'', modifier, ''value'', value)) FROM catalog.w_engine_stats WHERE role = ''ADVANCED'';'
END
\gexec
