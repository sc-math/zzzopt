# Decisões de arquitetura e processo (ADR simples)

Status aceito registra decisão do usuário; proposto é alternativa sem aprovação.
O [estado implementado](implementation-status.md) é separado da decisão. Data desta consolidação:
2026-10-31. A spec permanece em [regras de negócio](business-rules.md).

## ADR-01 — Fluxo SDD

- Status: aceito.
- Contexto: regras, estratégia e histórico estavam misturados e sem rastreabilidade única.
- Decisão: comportamento aprovado na spec, depois plano técnico, tarefas pequenas e só então
  código. Uma tarefa por vez. Alteração de comportamento deve explicitar seu impacto e obter
  aprovação; não transformar proposta em requisito. Reorganização documental não aprova novas funcionalidades.
- Alternativas descartadas: nesta etapa, continuar implementando funcionalidade antes da
  consolidação e aprovação documental.
- Revisitar: se o usuário mudar o processo ou o formato necessário aos documentos.

## ADR-02 — Stack e execução Java inicial

- Status: aceito.
- Contexto: serviço de combinações precisa ser testável sem infraestrutura e mensurado antes
  de introduzir distribuição.
- Decisão: core Java puro; aplicação futura Spring Boot; PostgreSQL em Docker Compose;
  Flyway e integração JPA. Busca no processo Java da aplicação. Separar worker Java e RabbitMQ
  somente se medições justificarem. Não instalar PostgreSQL no host.
- Alternativas descartadas para a v1: worker Python, MongoDB, contêiner dinâmico por job,
  nuvem e Kubernetes. SSE é opção discutida, não contrato público fechado.
- Revisitar: após benchmarks/carga e degradação mensurada, não para justificar artificialmente uma fila.

## ADR-03 — Base crua e passiva total separadas

- Status: aceito.
- Contexto: algumas passivas aumentam a base; outras modificam a ficha junto dos itens.
- Decisão: guardar base crua máxima e totais da passiva maximizada separados, com estágio
  BASE/SHEET e modifier FLAT/PERCENT. Não modelar progressão. Na integração, compor uma vez.
  Preservar dados e correções em [catálogo](catalog.md), inclusive exceções de personagens.
- Alternativas descartadas: manter todos os bônus embutidos na base; criar uma migration por
  personagem durante a coleta; deduzir passivas por analogia.
- Revisitar: se o produto passar a suportar níveis/passivas não maximizados, fora do escopo atual.

## ADR-04 — Streaming sem persistência das builds

- Status: aceito.
- Contexto: filtros amplos podem produzir volume de resultados incompatível com uma lista em RAM.
- Decisão: resultados em lotes com buffers limitados e controle do consumidor; histórico somente
  de metadados. Desconexão detectada cancela cooperativamente. Sem replay/restauração na v1.
  Configuração no navegador é possibilidade futura, não retomada de job.
- Alternativas descartadas para a v1: persistir todas as builds e paginar o histórico; acumular
  todo o resultado em RAM; presumir que TCP ou IDs de lote implementam replay.
- Revisitar: se houver requisito explícito de retomada, com armazenamento, limites e custos definidos.

## ADR-05 — Reset local nas etapas iniciais, com preservação do catálogo

- Status: aceito; escopo limitado às etapas iniciais atuais.
- Contexto: o usuário permite reconstruir o banco local enquanto o schema ainda está amadurecendo.
- Decisão: pode apagar e reconstruir o volume Docker do banco deste projeto nessas etapas,
  preservando dados de personagens, motores e conjuntos/equipamentos. A fonte SQL, IDs, valores,
  nomes, atributos, passivas, efeitos e correções não podem se perder. Não apagar outros volumes.
  O reset não é necessário para a reorganização documental e não foi executado nela.
- Condições: definir antes a mudança de schema aprovada, confirmar o volume exato e demonstrar
  reconstrução fiel em banco temporário; preservar dados adicionais locais se existirem.
  Permissão de reset não aprova opções de schema ainda propostas, reescrita genérica de
  migrations aplicadas ou alteração de testes consolidados.
- Alternativas: uma nova migration preservando o banco continua válida; não foi descartada.
  A auditoria propôs V3 como caminho normal. A autorização posterior permite avaliar reconstrução
  local nesta fase; eventual reconsolidação de V1/V2 deve constar da tarefa aprovada.
- Revisitar: ao sair destas etapas iniciais ou antes de operações sobre dados de usuários/ambiente público.

## ADR-06 — Simplificação dos ranks

- Status: aceito pelo usuário em 2026-10-31.
- Contexto: tabelas de rank sem regra de cálculo própria, com domínios distintos.
- Decisão: enums AgentRank A/S/I e WEngineRank B/A/S; colunas textuais com checks por domínio.
  O símbolo de I permanece ∞ no enum de agente. Não confundir com DiscRank.
- Alternativas descartadas nesta etapa: manter as duas tabelas ou unificá-las com domínio.
- Impacto: sem mudança da ficha; validação passa a fechar os valores permitidos. Novo rank
  exige evolução explícita. Valores antigos incompatíveis abortam a migration, sem descarte.
- Implementado e verificado: V3, preservando V1/V2 e testes históricos em suas fases. Verificações
  novas cobrem o schema atual e equivalência dos dados; não editar testes consolidados.
- Revisitar: se rank passar a ter metadados/configuração dinâmica que justifiquem catálogo próprio.

## ADR-07 — Unificar atributos básicos e avançados do motor

- Status: aceito pelo usuário em 2026-10-31.
- Contexto: os dois papéis compartilham estrutura de valor, mas incidem em etapas diferentes.
- Decisão: w_engine_stats com papel BASE/ADVANCED, stat_code, modifier e valor. Uma parcela por
  motor/papel. BASE é ATTACK/DEFENSE absoluto (FLAT) antes dos multiplicadores; ADVANCED mantém
  FLAT/PERCENT e sua unidade. Não unificar com atributos de personagem.
- Exemplo: BASE/DEF/FLAT 431 e ADVANCED/DEF/PERCENT 48 continuam distintos; CRIT_RATE/FLAT 24
  soma pontos percentuais.
- Alternativa descartada nesta etapa: manter as duas tabelas. Modifier sozinho não substitui papel.
- Impacto: sem mudança pretendida de resultado; banco passa a rejeitar parcelas repetidas por
  papel. Não inferir atributos ausentes; tratamento de perfil incompleto continua Q-06.
- Implementado e verificado: os 204 valores foram copiados/comparados na V3 antes de remover
  tabelas antigas; o catálogo inteiro foi comparado no script, em banco temporário e local,
  incluindo repetição Flyway. Nenhum volume foi apagado.
- Revisitar: se um motor vier a ter vários atributos simultâneos no mesmo papel; exige nova decisão.

## ADR-08 — Fonte dos bônus de ficha normalizados

- Status: proposto.
- Contexto: os 26 bônus de ficha aparecem em linhas normalizadas e em analysis JSONB;
  a auditoria não encontrou divergência atual, mas há duplicação editável.
- Proposta: linhas normalizadas como fonte de cálculo; descrição original preservada para
  referência; analysis tratado como derivado/anotação sem edição independente de bônus de ficha.
  Qualquer divergência exige revisão, não correção presumida do jogo.
- Alternativas em avaliação: remover a duplicação na análise ou validá-la automaticamente.
  Nenhuma descartada/implementada nesta etapa.
- Impacto: evitar divergências sem mudar bônus ou resultados. Não altera a análise de condições de combate.
- Revisitar/decidir: no planejamento da manutenção do catálogo.

## ADR-09 — Identidade, traduções e origem dos dados

- Status: aceito.
- Contexto: nomes por idioma, elementos variantes e dados de beta não podem definir identidades.
- Decisão: preservar IDs fornecidos e nomes por idioma; variantes mantêm relação com seu básico
  sem inferir herança de fórmulas. Carga manual enviada pelo usuário, sem scraping. JSON serve
  como entrada/fonte de teste, não segundo catálogo obrigatório editado em paralelo.
- Alternativas descartadas: inventar traduções/dados, substituir ID por nome traduzido,
  reduzir variantes ao elemento básico e coletar automaticamente o site nesta carga.
- Revisitar: quando houver requisito de idioma/atualização de catálogo aprovado; fallback continua Q-14.

## ADR-10 — Testes protegidos e validação incremental

- Status: aceito.
- Contexto: testes consolidados são proteção explícita do projeto.
- Decisão: testes unitários e de integração ao longo do trabalho; TDD não é obrigatório.
  Usar DisplayName em português e nomes parametrizados informativos. Corrigir implementação
  quando falhar; alterações de teste exigem evidência, proposta e autorização específica.
  Critérios de aceite podem apontar para testes futuros sem afirmar que já passam.
- Alternativas descartadas: alterar, remover, desabilitar ou enfraquecer testes para fazer
  implementação passar; tratar autorização anterior como permanente.
- Revisitar: somente por decisão explícita do usuário. Exceções históricas estão no AGENTS.md.
