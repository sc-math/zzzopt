# Instruções do projeto para agentes de IA

Este arquivo registra as permissões, restrições e preferências dadas pelo usuário.
É documentação versionável do projeto, não uma descrição de funcionalidades implementadas.

## Leitura e manutenção do contexto

- Antes de implementar uma etapa, consultar [regras de negócio](docs/business-rules.md),
  [contratos](docs/contracts.md) e [arquitetura e etapas](docs/architecture-and-roadmap.md).
- A [referência da Aria](docs/aria-reference.md) registra os dados reais fornecidos pelo usuário
  e a divergência conhecida de precisão. Não substituí-la por suposições sobre o jogo.
- O usuário autorizou atualizar este arquivo sempre que ele decidir uma nova permissão,
  restrição ou proibição. Registrar também a mudança no documento funcional apropriado.
- Manter decisões fechadas, sugestões, pendências e estado implementado claramente distintos.
  Não transformar uma sugestão de agente em requisito aprovado.
- Quando uma nova decisão substituir uma anterior, atualizar a regra vigente e registrar a
  substituição relevante. Não deixar instruções contraditórias para o próximo agente.
- Manter o README voltado à apresentação pública do projeto no GitHub, para recrutadores e
  desenvolvedores. Regras detalhadas, contratos e decisões ficam em `docs/`.

## Desenvolvimento em etapas

- Trabalhar em incrementos pequenos, compreensíveis e revisáveis, respeitando a etapa combinada.
- Não implementar várias fases de uma vez nem antecipar infraestrutura sem necessidade.
- A primeira etapa de montagem da ficha está implementada. A próxima etapa planejada é a
  busca de referência com filtros; API, persistência e streaming ainda são futuros.
- Ao concluir uma etapa, informar o que mudou, a verificação feita e as pendências relevantes.

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

## Restrições de arquitetura e escopo

- Toda regra de negócio e validação autoritativa fica no backend.
- O `core` é uma biblioteca Java pura, independente de Spring, JPA e infraestrutura.
- Busca e eventual worker são Java. Não introduzir Python para executar otimizações.
- Começar com a execução no processo da aplicação Spring Boot. Worker separado e RabbitMQ
  só devem entrar após medições que justifiquem a mudança.
- PostgreSQL deve rodar em Docker Compose. Não exigir nem instalar o servidor PostgreSQL
  diretamente na máquina do usuário. Persistência planejada: JPA e Flyway.
- PostgreSQL atende ao catálogo e aos registros de execução; MongoDB não faz parte da stack.
- Não implementar contêiner dinâmico por job, nuvem, Kubernetes ou interface elaborada na v1.
- Não implementar scanner/importação automática na v1. Não capturar tráfego nem ler memória
  do jogo. O inventário é informado em JSON pelo usuário.
- Não persistir builds nem implementar replay/restauração dos resultados na v1. Persistir
  apenas registros/metadados das execuções; buffers de transmissão precisam ser limitados.
- Manter cálculos de dano e efeitos de combate fora da montagem da ficha da v1.
- Não inventar tetos de atributos ou arredondamentos para adaptar resultados ao jogo.
- Não declarar busca, poda, paralelismo, benchmarks, API ou integrações como concluídos antes
  de implementá-los e verificá-los. Não fabricar resultados de desempenho para o README.
