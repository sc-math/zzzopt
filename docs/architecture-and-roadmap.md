# Plano técnico e sequência de implementação

A [spec](business-rules.md) define o comportamento. Este documento descreve como atendê-la,
sem aprovar respostas às perguntas abertas. Consultar [ADRs](decisions.md), [tarefas](tasks.md),
[aceite](acceptance-criteria.md) e [estado verificado](implementation-status.md).

## Stack e módulos

| Parte | Escolha técnica | Referência |
|---|---|---|
| core | Biblioteca Java pura, sem Spring/JPA/infraestrutura; modelos imutáveis | RF-02 a RF-11 |
| api futura | Spring Boot para HTTP, validação, acesso, pedidos e transmissão | RF-13 a RF-17 |
| Banco | PostgreSQL em Docker Compose; migrations Flyway; integração JPA futura | RF-12, RF-17 |
| Execução inicial | Busca Java no processo da aplicação; executor com orçamento de recursos | RF-13 a RF-16 |
| Isolamento posterior | Worker Java e RabbitMQ somente após medições | ADR-02 |
| Testes | JUnit com descrições em português e verificações SQL transacionais | Matriz de aceite |

Ambiente atual: Java 25, Maven Wrapper, JUnit 6 e BigDecimal na montagem da ficha.
As versões e modelos existentes estão no [estado](implementation-status.md) e na
[referência interna do core](core-reference.md). Python não executará buscas.

Organizar módulos por funcionalidade e usar conceitos de DDD onde expressem regras reais.
Os pacotes atuais são stats, equipment, build e damage (legado). Não criar camadas vazias.
Quando necessário, separar casos de uso, HTTP e persistência dentro das funcionalidades.

## Dados e adaptação para o core

Carregar o catálogo necessário fora do laço de combinações. Não consultar JPA a cada build.
A representação do banco e os modelos Java não são automaticamente DTOs HTTP.

Na integração:
1. Resolver personagem, motor, conjuntos e atributos pelo catálogo.
2. Validar completude e suporte antes de prometer uma ficha completa (Q-06).
3. Compor base crua, bônus de passiva BASE e atributo básico correspondente do motor.
4. Encaminhar bônus SHEET junto aos modificadores de ficha, uma única vez.
5. Adaptar IDs numéricos aos contratos internos sem reescrever fixtures consolidadas.

O core atual ainda recebe base composta e só representa ATQ básico do motor.
Seu enum não cobre todos os códigos do catálogo. Evoluções precisam de tarefa e aceite;
não converter DEF em ATQ, nem descartar códigos desconhecidos silenciosamente.
Uso de motor de outra especialidade e versão do catálogo por execução dependem de Q-15/Q-16.

## Persistência atual e propostas

V1 cria 14 tabelas. V2 acrescenta nove tabelas e a carga de 63 personagens, 102 motores e
30 conjuntos. Ambas foram aplicadas; novos dados usam novas migrations, salvo reconsolidação
especificamente aprovada. A autorização de reset local está em ADR-05 e no AGENTS.md.

| Tabela atual | Responsabilidade | Avaliação de simplificação |
|---|---|---|
| locales | Idiomas cadastrados | Manter |
| agents.rank_code | Rank A/S/I | Enum AgentRank + check na V3; não é tabela extra |
| elements | Elementos, variantes e indicação de nome provisório | Manter |
| element_names | Nomes de elementos por idioma | Manter |
| specialties | Identidade compartilhada de especialidades | Manter; não define compatibilidade automaticamente |
| specialty_names | Nomes de especialidades por idioma | Manter |
| factions | Identidade da facção | Manter como metadado |
| faction_names | Nomes de facções por idioma | Manter |
| agents | Identidade/metadados do personagem | Manter |
| agent_names | Nomes de personagens por idioma | Manter |
| stat_types | Código e unidade de atributos | Alinhar com os códigos suportados no core |
| agent_base_profiles | Nível, origem e completude da passiva | Manter; união com agents é apenas alternativa avaliada |
| agent_base_stats | Base crua por personagem/atributo | Manter |
| agent_passive_bonuses | Total por atributo, estágio e modifier | Manter separado da base |
| w_engines.rank_code | Rank B/A/S | Enum WEngineRank + check na V3; não é tabela extra |
| w_engines | Identidade, especialidade, origem e revisão de combate | Manter |
| w_engine_names | Nomes de motores por idioma | Manter |
| w_engine_stats | Valor por motor e papel BASE/ADVANCED | Tabela unificada aprovada na V3, com modifier preservado |
| disc_sets | Identidade, fonte e origem do conjunto | Manter |
| disc_set_names | Nomes de conjuntos por idioma | Manter |
| disc_set_effects | Requisito de peças, contexto e descrição/análise | Manter |
| disc_set_effect_bonuses | Bônus de ficha normalizados | Manter; fonte de cálculo proposta em ADR-08 |

O Flyway administra public.flyway_schema_history. Não é entidade de negócio.
O quadro descreve o schema V3 aplicado (20 tabelas); as duas linhas de colunas de rank não
são tabelas extras. V1/V2 históricas criavam 23 tabelas antes da simplificação.
Usuários, registros de execução e sua retenção ainda não têm schema implementado.

O banco usa valores NUMERIC não negativos e finitos. stat_types distingue NUMBER e
PERCENT_POINTS. Passivas BASE aceitam FLAT; SHEET aceita FLAT ou PERCENT relativo nos atributos
suportados. O modifier não substitui o estágio do bônus.

As constraints e os testes da carga não garantem toda a completude de cada entrada futura.
Definir na tarefa de integração qual camada garante um atributo básico/avançado por motor,
perfis completos e efeitos SHEET com bônus válidos. Não inserir regras de legalidade
do jogo sem dados confirmados.

disc_set_effects.analysis é JSONB declarativo, não executa condições. Seu contexto pode
ser NULL com nota, indicando pendência de catálogo; o lote atual não tem contexto pendente.
A análise de combate não é uma implementação de dano. Os bônus de ficha aparecem também
em analysis; ADR-08 propõe uma fonte autoritativa para evitar divergência.

As migrations são a fonte versionada da carga. As referências manuais registram origem,
casos especiais e exemplos; não manter um segundo JSON editado independentemente.
Os arquivos em db/drafts são históricos e não devem ser executados separadamente.
Comandos e estratégia de reconstrução estão em [operação do catálogo](catalog-operations.md).

## Busca, poda e resultados

Antes da tarefa dependente, fechar Q-01 a Q-06 e a representação dos filtros.
Implementar uma enumeração simples para inventários pequenos como referência verificável.
Representar cada resultado por sua ficha e suas seis peças.

A pré-filtragem poderá agrupar candidatos por slot e restringir principais/conjuntos somente
quando preservar todas as composições admitidas por RF-10/RF-11.
Otimizações de poda devem ser comparadas com a referência pelo conjunto de identidades das
builds, incluindo peças diferentes de atributos iguais. Não usar dominância para perder resultados.

Gerar entradas fictícias com seed reproduzível. Medir tempo de enumeração, memória e volume
de saída antes de selecionar representações ou paralelismo adicionais.
Usar BigDecimal é a implementação atual; qualquer mudança de representação numérica exige
aceite de equivalência e respeito aos testes consolidados.

## Concorrência e transmissão

Mecanismos concretos dependem dos contratos de execução:
- Orçamento global de jobs e threads por job, considerando CPU disponível e limites do container.
- Estado de busca isolado por job/thread; entradas compartilhadas imutáveis.
- Admissão/verificação dos limites por usuário de forma atômica.
- Cancelamento cooperativo dentro da busca e liberação de buffers.
- Transições que não sobrescrevam indevidamente um estado final.
- Produção de lotes com buffers limitados e controle do consumidor lento.

N × M próximo da CPU é hipótese de dimensionamento, não reserva exclusiva de núcleos.
Dois jobs com quatro threads cada é exemplo experimental; os valores não estão fixados.

SSE foi discutido para transmissão HTTP. Sequência, tamanho de lote, heartbeat, timeouts e
número de consumidores dependem de Q-08 a Q-10/Q-17. Não há replay.
Postman pode servir à inspeção; Swagger documenta a API e não substitui um consumidor de
streaming sob grande volume. TCP não fornece replay de aplicação após reconexão.

JPA @Version é uma possibilidade para entidades, não resolve sozinho limites entre várias
execuções. Não manter transação de banco durante toda a busca. Se mensageria for justificada,
planejar reentrega, idempotência, aquisição de jobs e consistência entre registro e publicação.

## Verificação e evolução

Preservar os testes existentes sem alteração não autorizada. Os checks históricos de V1 e V2
validam suas respectivas fases; uma evolução de schema deve planejar sua cobertura sem
enfraquecê-los. O teste de carga fixa duas migrations/23 tabelas, e a fixture de base usa rank
TEST: alterações relacionadas dependem de autorização específica para adaptar esses testes.

Experimentos planejados, sem resultados fabricados:
- Enumeração de referência versus poda, verificando equivalência.
- Uma thread versus múltiplas threads.
- Jobs em série com mais threads versus concorrentes com menos threads.
- Carga de usuários e latência da API; comparar um versus quatro workers somente se existirem.

JMH é uma ferramenta discutida, ainda não adotada como requisito. Registrar ambiente,
limites de recursos, metodologia e seed sem revelar segredos. Só isolar worker/RabbitMQ se
os números mostrarem custo ou degradação de latência que justifique a mudança.

## Sequência por dependências

1. Consolidar spec, contratos, ADRs, aceite e tarefas sem mudar comportamento.
2. Fechar perguntas que bloqueiam a busca e o suporte de fichas.
3. Evoluir representação/adaptação dos atributos em tarefas aprovadas, sem antecipar JPA.
4. Implementar referência da busca e geração reproduzível.
5. Medir e introduzir poda comprovadamente equivalente.
6. Implementar aplicação Spring Boot, catálogo via JPA e registros de execução.
7. Adicionar limites, cancelamento, acesso e transmissão por lotes.
8. Medir carga e decidir isolamento.

Esta sequência não autoriza executar todas as fases. O [backlog](tasks.md) detalha tarefas
pequenas e registra bloqueios. Nuvem, Kubernetes e contêiner por job não entram na v1.

## Evolução posterior, sem antecipação

- Cálculo de dano reutilizando a ficha e acrescentando efeitos de combate, skills e passivas de motores.
- Distribuição livre de rolls como funcionalidade separada.
- Possível importação automática e configuração salva no navegador, mediante nova etapa aprovada.
- Explicação no README de como uma evolução poderia escalar com KEDA/Fargate e por que não foi
  implementada; não implantar nuvem ou Kubernetes na v1.

## Incremento aprovado: simplificação do catálogo

ADR-06/ADR-07 foram aceitos pelo usuário. V3 remove as duas tabelas de ranks, adicionando
checks próprios às colunas existentes, e transfere os 102 básicos/102 avançados para
w_engine_stats. O schema atual tem 20 tabelas. V1/V2 permaneceram inalteradas, sem reset.
AgentRank (A/S/I, com I representado por ∞) e WEngineRank (B/A/S) são enums Java distintos;
os modelos Agent/WEngine não ganham campos nem cálculo novo nesta etapa.

A tabela unificada tem chave (w_engine_id, role). BASE aceita apenas ATTACK/DEFENSE com
FLAT; ADVANCED mantém FLAT/PERCENT e a restrição dos atributos relativos. NUMERIC deve ser
finito/não negativo e as FKs preservadas. A ausência de um papel continua sob o contrato de
completude, não se cria fórmula ou preenchimento presumido.

V3 deve abortar se os ranks/símbolos antigos não corresponderem aos enums ou se houver
parcelas repetidas do mesmo papel. Copiar e comparar todos os atributos antes de remover
as tabelas antigas, dentro da transação da migration.

Testes existentes rodam sem alteração em suas fases V1 e V2 no novo script Simplify-Catalog.
O script captura somente dados do catálogo em JSON canônico, em memória, antes/depois da V3;
para atributos unificados reconstrói a representação anterior. Ranks de entidades permanecem
no snapshot; o mapeamento de códigos/símbolos é conferido antes da remoção. Comparar todas
as linhas, não apenas contagens. Adicionar check V3 para schema/constraints e regressões;
repetir Flyway e comparar novamente. Não imprimir dados, configuração ou credenciais.

O Compose só recebe um serviço adicional para esse check; scripts e checks históricos
continuam intactos. Validar primeiro em projeto Docker temporário sem portas, depois aplicar
no banco local autorizado. Se algum teste consolidado exigir edição, parar essa edição e
pedir autorização específica; a estratégia atual não exige isso.

Verificado em 2026-10-31: V3 aplicada em banco temporário e local, comparação integral e
repetição aprovadas, 41 testes Java passando. O novo cenário de FK foi isolado durante sua
elaboração; nenhum teste consolidado foi alterado.
