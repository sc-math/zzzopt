# Tarefas e ordem de implementação

Fluxo obrigatório: [spec](business-rules.md) → [plano](architecture-and-roadmap.md) →
tarefa → código → verificação. Uma tarefa por vez. Este backlog não autoriza executar
todas as tarefas nem transforma pergunta aberta em decisão.

Estados: concluída, em andamento, proposta e bloqueada. Tarefa de comportamento só começa
com spec aprovada e critério inequívoco. Teste consolidado só muda com autorização específica.

## Incremento autorizado: reorganização documental

| ID | Tarefa | Dependência | Critério de pronto | Estado |
|---|---|---|---|---|
| DOC-01 | Separar spec e contrato público dos detalhes técnicos | Auditoria aprovada | RF-01 a RF-18 e perguntas abertas; nenhum comportamento novo presumido | Concluída |
| DOC-02 | Separar plano, referência do core, estado e operação do catálogo | DOC-01 | Implementado/proposto separados; dados e comandos recuperáveis sem duplicação normativa | Concluída |
| DOC-03 | Registrar ADRs e autorização de reset com preservação | DOC-02 | Aceito/proposto explícitos, contexto/alternativas/revisão; opções de schema não presumidas | Concluída |
| DOC-04 | Ligar critérios de aceite aos testes reais e às lacunas | DOC-03 | Cada RF tem cenário ou bloqueio; evidências parciais não declaradas completas | Concluída |
| DOC-05 | Criar tarefas pequenas e dependências | DOC-04 | Uma entrega verificável por tarefa; próximos bloqueios visíveis | Concluída |
| DOC-06 | Atualizar AGENTS/índice e validar a reorganização | DOC-05 | Links e rastreabilidade válidos; dados, código, testes, migrations e scripts preservados | Concluída |

## Decisões necessárias antes do código dependente

| ID | Tarefa | Dependência | Critério de pronto | Estado |
|---|---|---|---|---|
| DEC-01 | Fechar comparação dos filtros | Q-01 | Aprovar exemplos abaixo, igual e acima do limite, precisão e intervalos | Bloqueada por resposta do usuário |
| DEC-02 | Fechar composições de conjuntos | Q-02 | Exemplos aprovados de 4+2, 2+2+2, ausência de seleção e sobreposição | Bloqueada por resposta do usuário |
| DEC-03 | Fechar entradas inválidas e zero resultados | Q-03/Q-04 | Diferenciar erro de entrada e conclusão vazia, com política de erros | Bloqueada por resposta do usuário |
| DEC-04 | Definir recorte de perfis suportados | Q-06/Q-15 | Lista de suporte, resposta para dados/fórmulas ausentes e uso por especialidade aprovados | Bloqueada por resposta/dados do usuário |
| DEC-05 | Completar legalidade dos discos | Q-05 | Tabela fornecida/confirmada por slot/rank; não inventar valores | Bloqueada por dados do usuário |

DEC-05 não exige inventar restrições para poder desenvolver cenários sintéticos; a tarefa de
busca deve declarar o recorte estrutural aceito. Recorte não autoriza entrada real apresentada
como integralmente validada sem resolver o contrato correspondente.

## Avaliação de banco: autorização de reset não é escolha do schema

| ID | Tarefa | Dependência | Critério de pronto | Estado |
|---|---|---|---|---|
| DB-01 | Decidir representação de ranks | ADR-06 | Enums/checks por domínio aprovados; I/∞ preservado | Concluída |
| DB-02 | Decidir atributos do motor | ADR-07 | Unificação com BASE/ADVANCED e modifier aprovada | Concluída |
| DB-03 | Definir fonte dos bônus de ficha | ADR-08 | Autoridade entre normalizado/analysis definida, sem alterar valores do jogo | Proposta |
| DB-04 | Especificar mudança de schema e estratégia | ADR-06/ADR-07 | V3 sem reset, comparação integral e testes históricos preservados | Concluída via DB-S01 |
| DB-05 | Validar schema/carga em banco temporário | DB-04 | Comparação por registro, constraints e regressões preservadas | Concluída via DB-S04 |
| DB-06 | Aplicar mudança local aprovada | DB-05 | V3 local, equivalência integral e repetição verificadas, sem reset | Concluída via DB-S05 |

DB-04 deve dizer se haverá nova migration ou reconsolidação inicial especificamente aprovada.
A reorganização documental não editou V1/V2 nem apagou volume. A simplificação aprovada
abaixo usa V3 e também não exige reset.
Se checks/fixtures existentes precisarem mudar, propor alteração e obter autorização antes
da edição. Nenhuma tarefa de banco inclui implementação de funcionalidade de busca.

## Próximas tarefas técnicas, ainda sem autorização de execução

| ID | Tarefa pequena | Dependência | Critério de pronto | Estado |
|---|---|---|---|---|
| CORE-01 | Representar Wind na ficha | DEC-04; tarefa aprovada | Código/bonus mapeados com unidade preservada, teste novo e regressões intactas | Proposta |
| CORE-02 | Representar atributo básico DEF do motor | DEC-04; ADR-07 | AC-17 e compatibilidade dos contratos existentes verificadas | Proposta |
| CORE-03 | Compor base e modificadores de passiva | DEC-04 | AC-15/AC-16 sem dupla aplicação, incluindo casos especiais suportados | Proposta |
| CORE-04 | Definir adaptação/validação de perfil suportado | CORE-01 a CORE-03 conforme recorte | AC-23, sem omissão silenciosa ou fórmulas presumidas | Proposta |
| BUSCA-01 | Modelar intervalos e sua validação | DEC-01/DEC-03 | AC-27 e casos de fronteira aprovados cobertos | Proposta |
| BUSCA-02 | Enumerar inventário pequeno por slot | DEC-02/DEC-03 | AC-18, cada conjunto de seis IDs emitido uma vez, sem acumular resultados completos | Proposta |
| BUSCA-03 | Aplicar filtros de principais 4/5/6 | BUSCA-02; recorte de legalidade | Somente principais selecionados; slots fixos preservados | Proposta |
| BUSCA-04 | Aplicar alternativas 4+2 sem perda | BUSCA-03/DEC-02 | AC-25/AC-26 e sobreposições aprovadas | Proposta |
| BUSCA-05 | Aplicar filtros de atributos | BUSCA-01/BUSCA-04; montagem suportada | AC-28/AC-29 e casos de fronteira aprovados, sem modificar valores | Proposta |
| BUSCA-06 | Acrescentar modo 2+2+2 | DEC-02/BUSCA-05 | Enumerar exatamente as composições aprovadas, sem repetir builds | Proposta |
| MED-01 | Gerar dados sintéticos com seed | Busca de referência | Mesmo seed reproduz inventário/cenários, sem exigir entrada manual | Proposta |
| MED-02 | Medir referência e volume de saída | MED-01 | Números reais com ambiente e metodologia; nenhum resultado fabricado | Proposta |
| PODA-01 | Introduzir uma poda por vez | MED-02; prova de preservação | AC-30 contra referência em cenários pequenos e adversos | Proposta |

Nenhuma evolução de core pode inferir Sheer Force ou conversão de Armorer. Se essas mecânicas
entrarem no recorte aprovado, abrir tarefa depois de obter coeficientes, condições e aceite.

## Etapas posteriores a desdobrar

API Spring Boot/JPA, envelope HTTP, metadados de execuções, autenticação/autorização, estados,
limites, cancelamento, streaming e carga devem ser desdobrados em tarefas pequenas antes de
qualquer código. Fechar Q-07 a Q-17 na etapa dependente e usar AC-31 a AC-36 como pontos de partida.
Não tratar esta lista de etapas como tarefas prontas para implementação.

Worker/RabbitMQ só recebem tarefas depois de medições que justifiquem isolamento.

## Incremento autorizado: ranks e atributos de motor

1. DB-S01 — Spec, ADRs, plano e aceite da simplificação: concluir antes do código.
2. DB-S02 — Adicionar os enums distintos e V3 com cópia/checagem transacional: uma entrega de schema, sem cálculo novo.
3. DB-S03 — Adicionar snapshot/check V3 e script de transição: checks existentes intactos, comparação completa antes/depois.
4. DB-S04 — Validar V1 → V2 → V3 em projeto temporário e testes Java: nenhuma proteção anterior removida.
5. DB-S05 — Aplicar V3 local, comparar novamente e atualizar o estado: mesmos dados, 20 tabelas e nenhum reset necessário.

Estado do incremento: DB-S01 a DB-S05 concluídas. V3 verificada em banco temporário e local,
comparação integral aprovada, 41 testes Java passando e testes consolidados intactos.
A autorização para estas duas simplificações não aprova ADR-08 nem funcionalidades do backlog.
