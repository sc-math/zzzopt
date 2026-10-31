# Arquitetura, decisões e etapas

## Estado atual

Implementado: módulo Maven `core`, JDK 25, JUnit 6, modelos imutáveis e montagem da ficha em
Java puro com `BigDecimal`. O cenário manual da Aria e regras de conjuntos/validação possuem
testes unitários. Os testes legados de dano continuam isolados e não participam da montagem.

Última execução verificada antes desta consolidação documental: 41 testes passando, sem falhas
ou testes ignorados. Não há API, banco, Compose, busca combinatória ou benchmarks implementados.

## Separação de responsabilidades

| Componente | Responsabilidade | Estado |
|---|---|---|
| `core` | Modelos, regras, ficha e futura busca/filtros | Ficha implementada |
| `api` | HTTP, validação de pedidos, usuários, autenticação, estado e transmissão | Planejado |
| Persistência | Catálogo e registros de execução | Planejada |
| Executor interno | Orçamento de execução e threads dentro da aplicação Java | Planejado |
| `worker` separado | Executar a mesma busca reutilizando o `core` | Condicionado a medições |
| RabbitMQ | Mensageria entre processos, se houver justificativa | Não faz parte do primeiro desenho executável |

O `core` é biblioteca, não um processo worker. Não adicionar dependências de Spring/JPA ao domínio.
A busca continuará em Java; não introduzir um consumidor Python.

## Organização

Adotar uma aplicação modular organizada por funcionalidade, com conceitos de DDD onde ajudarem
a expressar as regras. DDD não se resume a nomes de pastas e não exige adotar todos os padrões.

O `core` atual separa `stats`, `equipment` e `build`; `damage` contém o código legado. Quando a API
existir, separar casos de uso, HTTP e persistência dentro das funcionalidades necessárias.
Não criar camadas vazias ou dezenas de abstrações antes de existir um caso de uso concreto.
Toda validação autoritativa e regra de negócio é do backend. Uma futura interface pode validar
por conveniência, mas isso não substitui a validação do pedido no servidor.

## Persistência e catálogo

Decisão de stack: PostgreSQL, JPA e Flyway. PostgreSQL rodará em Docker Compose; o usuário não
instalará o servidor localmente. Variáveis serão referenciadas do `.env`, preenchido pelo usuário
com base no `.env.example`. Segredos não devem ser lidos por agentes, conforme o [AGENTS.md](../AGENTS.md).

Separar os seguintes conceitos:

- Catálogo interno de personagens, motores, conjuntos e efeitos.
- Inventário recebido em cada pedido, sem exigir um inventário pessoal persistente.
- Registros/metadados de execução, sem armazenar os resultados das builds.

Conjuntos e efeitos serão representados com relação um-para-muitos. Cada efeito informa a
identidade de seu conjunto, requisito de peças e contexto. Não são necessárias duas chaves
estrangeiras no conjunto para apontar seus efeitos de duas e quatro peças.
Os esquemas SQL, entidades JPA e política de retenção serão implementados na etapa correspondente.

Tabelas de catálogo não precisam estar todas relacionadas entre si. PostgreSQL também permite
campos JSONB, caso haja uma necessidade concreta; isso não justifica acrescentar MongoDB.

Arquivos JSON podem servir para carga inicial controlada ou entradas fictícias de teste.
Não são um cache obrigatório. Escolher uma rotina de manutenção que evite um catálogo no banco
e outro em arquivo sendo editados independentemente. A forma de carga inicial ainda não foi fechada.
As entidades persistidas não serão consultadas a cada combinação; a engine trabalha com dados
necessários já carregados e independentes do banco.

## Concorrência e ciclo das execuções

A ausência de itens consumíveis não elimina race conditions. Ao implementar jobs, tratar:

- Pedidos simultâneos substituindo a execução anterior.
- Conclusão disputando com cancelamento ou timeout, sem sobrescrever indevidamente estado final.
- Verificação e reserva de limites por usuário feitas atomicamente.
- Sinalização cooperativa de cancelamento dentro da busca e liberação de buffers.
- Estado mutável da busca isolado por job/thread; dados de entrada compartilhados somente se imutáveis.

Mecanismos concretos ainda serão escolhidos. `@Version` pode proteger uma entidade, mas não resolve
sozinho um limite envolvendo várias execuções. Não manter transação de banco aberta durante
toda a busca. Se RabbitMQ entrar futuramente, tratar reentrega, idempotência, aquisição do job e
consistência entre registrar o pedido e publicar a mensagem; detalhes não estão implementados.

O paralelismo pretendido combina alguns jobs simultâneos com algumas threads por job, mantendo
o orçamento total próximo da CPU disponível, inclusive limites do container. Por exemplo, dois
jobs com quatro threads cada é uma configuração experimental, não reserva de núcleos exclusivos.
O número final de jobs e threads será medido, não fixado apenas pelo exemplo.

Transmitir resultados com buffers limitados. Sem retenção de builds, desconexão detectada cancela
o processamento e não há recuperação da execução. Erro de conexão não é resolvido trocando
TCP por UDP; replay exigiria uma funcionalidade de retenção e retomada que está fora da v1.

## Sequência de incrementos

1. **Concluído:** modelar inventário, conjuntos e montagem da ficha; conferir a referência da Aria;
   adicionar testes unitários e descrições em português com `@DisplayName`.
2. **Próximo:** fechar precisão/semântica dos limites e contrato dos filtros, implementar busca
   simples de referência para casos pequenos, cobrindo composições e identidade das peças.
3. Gerar entradas sintéticas com seed reproduzível e medir custo da enumeração e volume de saída.
4. Implementar poda comprovadamente correta e comparar com a referência, preservando todas as
   builds válidas; medir representação numérica e paralelismo antes de otimizações adicionais.
5. Adicionar Spring Boot, pedidos, validação HTTP, catálogo e registros de execução em PostgreSQL
   via JPA/Flyway. Criar Compose quando a infraestrutura for necessária.
6. Integrar orçamento de jobs/threads, cancelamento, limites por usuário e transmissão incremental.
   Autenticação e autorização entram no serviço antes de tratá-lo como multiusuário público.
7. Medir latência da API sob carga. Só separar worker e mensageria quando os dados justificarem.

Cada item será desenvolvido em incrementos pequenos; a lista não é autorização para implementar
todas as fases de uma vez. Nenhuma nova etapa pode alterar testes consolidados sem respeitar
a política do `AGENTS.md`.

## Experimentos planejados

- Enumeração de referência contra busca com poda, verificando também equivalência de resultados.
- Uma thread contra múltiplas threads.
- Jobs em série usando mais threads contra jobs simultâneos com menos threads cada.
- Carga com múltiplos usuários e, se o worker isolado existir, comparação de um contra quatro workers.

Entradas sintéticas não dependem de scanner ou dados reais de inventário. JMH foi discutido para
medições da engine; testes de carga do serviço serão uma etapa separada. Não há resultados de
benchmark ainda. Registrar dados, ambiente relevante sem segredos, limites de CPU/memória e
metodologia quando esses experimentos forem executados.

Uma busca rápida é um resultado válido; não aumentar artificialmente o problema para justificar
fila. A motivação para eventual isolamento deve vir de medições reais, como degradação de latência
da API durante carga de CPU, e ser explicada com números no README.

## Evolução posterior

- Cálculo de dano utilizando a ficha já montada, depois efeitos de combate, passivas e skills.
- Distribuição livre de rolls como funcionalidade separada da busca por inventário.
- Possível importação automática e leitura de screenshots/OpenCV, sem captura de tráfego ou memória.
- Interface futura, incluindo armazenamento local da configuração para novos pedidos.
- Explicação de como escalar em nuvem, com opções como KEDA/Fargate, sem implementá-las na v1.

Não há container dinâmico por tarefa: numa única máquina, isso não cria CPU ou memória adicional.
Limites por container e por usuário continuam necessários na arquitetura local.

## Decisões substituídas e pendências

- A ideia original de otimizar um pool livre de rolls foi substituída na v1 por combinações de discos.
- O worker Python foi descartado; a execução é Java, inicialmente junto da aplicação.
- Persistir todas as builds e paginá-las posteriormente foi substituído por transmissão incremental
  sem armazenamento dos resultados. Paginação histórica exigiria retenção ou recálculo.
- Replay por IDs de lotes foi discutido e retirado do escopo. Identificação não implica retomada.
- Prioridade de atributos por classe e sliders foram adiados; mínimos/máximos são os filtros da v1.

Pendências antes de consolidar as respectivas funcionalidades:

1. Precisão e política de comparação dos limites frente aos valores exibidos no jogo.
2. Formato completo dos filtros, erros e eventos HTTP, inclusive nomes e IDs externos.
3. Escopo de substituição do job anterior ao enviar um novo pedido.
4. Valores dos limites de tempo, concorrência, saída e buffers; retenção dos metadados.
5. Validações completas de legalidade dos discos e manutenção/versionamento do catálogo.
