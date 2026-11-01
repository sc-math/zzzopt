# Instruções do projeto para agentes de IA

Este arquivo registra permissões, restrições e preferências do usuário. É documentação
versionável de colaboração, não a spec do produto nem prova de funcionalidade implementada.

## Autoridade e leitura do contexto

- A [spec](docs/business-rules.md) é a fonte normativa do comportamento aprovado.
  O [contrato público](docs/contracts.md) a complementa. Perguntas abertas não são requisitos aprovados.
- Antes de uma tarefa, ler a spec, os contratos, o [plano técnico](docs/architecture-and-roadmap.md),
  as [decisões](docs/decisions.md), a [matriz de aceite](docs/acceptance-criteria.md) e as
  [tarefas](docs/tasks.md) aplicáveis.
- Consultar o [estado implementado](docs/implementation-status.md) para distinguir o que existe
  do que foi decidido ou apenas proposto. Não transformar sugestão de agente em aprovação.
- A [referência da Aria](docs/aria-reference.md) e os dados de
  [personagens](docs/catalog.md), [motores](docs/w-engines.md) e
  [conjuntos](docs/disc-sets.md) preservam a origem e as correções fornecidas pelo usuário.
- O usuário autorizou manter este arquivo quando decidir nova permissão/restrição/proibição.
  Registrar a decisão também no documento apropriado; substituir instruções superadas sem
  deixar contradições. Instrução atual do usuário prevalece sobre este arquivo.
- README é apresentação pública para recrutadores/devs. Detalhes e decisões ficam em docs.

## Fluxo obrigatório SDD

1. Se mudar comportamento, explicitar a mudança e atualizar primeiro a spec/contrato com
   a decisão aprovada. Não preencher pergunta de jogo ou preferência com suposição.
2. Atualizar depois o plano técnico e o ADR correspondente, distinguindo aceito/proposto.
3. Definir uma tarefa pequena, dependências, critério de aceite verificável e critério de pronto.
4. Só então alterar código, uma tarefa por vez, dentro do escopo aprovado.
5. Verificar o resultado, relacionar a evidência ao aceite e atualizar o estado/tarefa.
   Ao concluir cada passo, informar o que mudou, como foi verificado e as pendências.

- Trabalhar em incrementos compreensíveis; não antecipar várias fases ou infraestrutura.
- A aprovação da reorganização documental não autoriza nova funcionalidade, respostas às
  perguntas abertas ou todas as tarefas do backlog. A aprovação de uma tarefa não cobre
  alteração não autorizada de teste consolidado.
- Não é necessário TDD, mas critérios de aceite devem preceder a implementação e testes
  unitários/de integração devem acompanhar o trabalho.
- Ao responder ao usuário, terminar com resumo curto do que mudou e do que depende dele.

## Segredos e variáveis de ambiente

- É proibido ler ou exibir `.env` ou arquivos locais equivalentes com segredos, por qualquer
  ferramenta, inclusive por leitura indireta, scripts ou comandos de diagnóstico.
- É proibido executar comandos que listem ou imprimam variáveis de ambiente: por exemplo,
  `env`, `printenv`, `set` para listar o ambiente ou `Get-ChildItem Env:`.
- Não imprimir configurações resolvidas, logs ou diagnósticos que revelem valores de segredos.
  Não executar `docker compose config` com interpolação que exponha esses valores.
- É permitido criar e manter `.env.example`, com nomes das configurações, instruções e valores
  fictícios. O usuário cria e preenche seu `.env`; não abri-lo para verificar o preenchimento.
- Manter `.env` e variantes locais no `.gitignore`, preservando `.env.example` versionável.
- O futuro Compose deve referenciar as configurações do `.env`, sem copiar segredos para
  arquivos versionados. Não solicitar chaves de API sem necessidade concreta da etapa.

## Testes e autorizações de alteração

- Implementar testes unitários e de integração ao longo do projeto. TDD não é obrigatório.
- Usar `@DisplayName` do JUnit em classes e métodos de teste, com frases em português.
  Testes parametrizados devem ter `name` identificando os valores relevantes de cada caso.
- Não alterar, remover, desabilitar ou enfraquecer testes implementados e consolidados sem
  autorização explícita. Isso inclui asserções, resultados esperados, tolerâncias, fixtures,
  seleção de testes e configurações que reduzam sua proteção.
- Ao falhar um teste, investigar e corrigir a implementação. Se houver erro no teste ou mudança
  intencional do requisito, explicar a evidência e a alteração proposta e pedir autorização
  antes de editá-lo. Não modificar o teste apenas para fazê-lo passar.
- Autorizações são específicas ao escopo solicitado; não constituem permissão permanente.

Histórico de exceções:

- Em 2026-10-30, o usuário autorizou modificar ou excluir a base anterior de código e testes
  durante a reestruturação inicial. Essa autorização não se estende aos novos testes
  consolidados nem autoriza futuras reescritas gerais. O código legado foi preservado.
- Depois da primeira etapa, o usuário autorizou adicionar descrições legíveis a todos os testes.
  Foram alterados apenas os nomes de exibição e das execuções parametrizadas; cenários,
  valores esperados, asserções e tolerâncias foram preservados. A tarefa está concluída.
- Em 2026-10-31, o usuário autorizou adaptar especificamente `db/checks/agent-base-stats.sql`
  ao contrato de base crua e passiva separadas, preservando a proteção de valores, unidades
  e integridade. Essa autorização não abrange testes Java nem `db/checks/catalog.sql`.

## Arquitetura e limites de escopo

- Toda regra de negócio e validação autoritativa fica no backend.
- core é Java puro, sem Spring/JPA/infraestrutura. Busca e eventual worker são Java, sem Python.
- Começar no processo da aplicação Spring Boot. Worker/RabbitMQ só após medições.
- PostgreSQL em Docker Compose; não instalar servidor no host. Stack de persistência:
  PostgreSQL, Flyway e integração JPA futura. Não introduzir MongoDB.
- Sem contêiner dinâmico por tarefa, nuvem, Kubernetes ou interface elaborada na v1.
- Sem scanner/importação automática na v1; não capturar tráfego nem ler memória do jogo.
  Inventário pessoal entra em JSON.
- Carga inicial do catálogo usa somente dados enviados manualmente pelo usuário, sem scraping.
  IDs de conjuntos foram extraídos do texto das URLs, sem acessar o site.
- Não persistir builds/inventário pessoal nem implementar replay/restauração na v1.
  Guardar só metadados de execução; resultados devem ter buffers limitados.
- Manter dano/efeitos de combate fora da ficha da v1. Não inventar tetos, arredondamentos,
  traduções, atributos, estágio de lançamento, fórmulas de Sheer Force ou conversão de Armorer.
- Não declarar busca, API, JPA, poda, paralelismo ou benchmarks concluídos sem implementação
  e verificação; não fabricar números de desempenho.

## Proteção dos dados fornecidos

- Preservar IDs, nomes, valores, unidades, base crua, passivas, atributos dos motores,
  efeitos de conjuntos e correções documentadas. Não substituir dados por conhecimento presumido.
- Não confundir IDs numéricos do catálogo com IDs string das peças/modelos atuais;
  não reescrever automaticamente fixtures para trocar IDs.
- Para Anby, manter a separação confirmada da base crua/passiva. A partir da Nicole,
  os dados enviados já eram base crua sem passiva; não subtrair bônus novamente.
- Manter BASE separado de SHEET e FLAT separado de PERCENT; não generalizar +75 ATQ.
  Preservar percentuais de Sunna/Manato/Zhao, PV base da Yixuan e exceções em catalog.md.
- Ausência não é zero. Não inferir energia de adrenalina/Sharpness, nem perfuração 100%.
  Zero de Sheer Force da origem não é um cálculo da build.
- Preservar Armorer com Sharpness/Laceration distintos e passiva informada, sem adicionar ATQ
  por analogia. Sunbringer permanece beta, com nome de elemento provisório. Não inventar collabs.
- Preservar rank I/∞ de Pyrois, identidades de variantes/básicos e nomes por idioma.
- Na v1, motor usa somente básico/avançado; passivas são combate para a v2 funcional.
  Indicador de revisão de combate falso não bloqueia esses atributos na v1.
- Todos os 4-PC dos 30 conjuntos fornecidos e os quatro 2-PC documentados como combate
  permanecem COMBAT. Preservar os outros 26 como SHEET e todas as descrições/condições.
  Não generalizar automaticamente a classificação para conjuntos futuros.

## Banco local, migrations e autorização inicial de reset

- V1, V2 e V3 foram aplicadas/verificadas em 2026-10-31: 63 personagens, 102 motores e 30 conjuntos,
  com 20 tabelas e 204 atributos de motor unificados. Houve comparação integral antes/depois.
  Compose mantém target=1; Apply-Catalog.ps1 é histórico V2; Simplify-Catalog.ps1 usa target=3.
- Os testes isolados verificam primeiro V1 vazia com os testes existentes, depois V2.
  Não alterar os testes históricos para fazê-los aceitar outro estágio.
- O usuário autorizou agora apagar e reconstruir o volume Docker do banco deste projeto
  durante estas etapas iniciais, condicionado a não perder dados de personagens, motores e
  equipamentos/conjuntos. A autorização persiste nesse escopo inicial; não é permanente.
- Um reset necessário a uma tarefa aprovada pode prosseguir nesse escopo sem pedir novamente
  a mesma autorização. Antes, conferir volume/projeto exatos, fonte recuperável do catálogo e
  reconstrução fiel em banco temporário. Preservar também dados adicionais locais, se existirem.
  Não remover volumes de outros projetos nem apagar fontes SQL/referências.
- Após a reorganização SDD, o usuário aprovou ADR-06/ADR-07: enums/checks de rank por domínio
  e uma tabela de atributos do motor com BASE/ADVANCED e modifier. Usar V3, sem reset necessário;
  preservar V1/V2, dados e testes consolidados. Executar checks históricos nas fases V1/V2
  e verificações novas na V3; comparar o catálogo inteiro antes/depois.
- A aprovação não abrange ADR-08, novas funcionalidades ou edição de testes consolidados.
- Preservar V1/V2/V3 aplicadas; usar novas migrations como caminho normal. Se uma tarefa futura
  definir reconsolidação inicial, explicitar essa mudança e sua aprovação antes de editar o histórico.
- Rascunhos em db/drafts são referências históricas sem execução independente.
- Consultar [operação do catálogo](docs/catalog-operations.md) para comandos e preservação.
  O Compose pode consumir .env sem que o agente o abra; o usuário já confirmou seu preenchimento.
