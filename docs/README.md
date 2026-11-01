# Documentação do projeto

O [README público](../README.md) apresenta o projeto. Aqui estão comportamento, implementação,
decisões e evidências, separados segundo SDD.

## Ordem de leitura e autoridade

| Documento | Papel |
|---|---|
| [Spec: regras de negócio](business-rules.md) | Fonte normativa do comportamento aprovado, RF-01 a RF-18 e perguntas abertas |
| [Contrato de entrada e saída](contracts.md) | Convenções externas acordadas; propostas HTTP claramente marcadas |
| [Plano técnico](architecture-and-roadmap.md) | Stack, dados, schema, algoritmos, concorrência e dependências |
| [Decisões (ADR)](decisions.md) | Contexto, decisão/proposta, alternativas e quando revisitar |
| [Critérios de aceite](acceptance-criteria.md) | Cenários verificáveis ligados aos testes e às lacunas |
| [Tarefas](tasks.md) | Trabalho pequeno, ordenado, com bloqueios e critério de pronto |
| [Estado implementado](implementation-status.md) | O que existe e evidências anteriores, sem confundir decisão com entrega |
| [AGENTS.md](../AGENTS.md) | Permissões, proibições e fluxo obrigatório para agentes |

## Referências de dados e operação

| Documento | Papel |
|---|---|
| [Referência da Aria](aria-reference.md) | Cenário fornecido pelo usuário e divergência conhecida de precisão |
| [Personagens](catalog.md) | Dados, exceções, unidades e correções da base crua/passiva |
| [Motores](w-engines.md) | Atributos básicos/avançados e unidades confirmadas |
| [Conjuntos](disc-sets.md) | IDs, efeitos, máximos condicionais e dúvidas para o cálculo de dano futuro |
| [Referência interna do core](core-reference.md) | Modelos Java e validações existentes, sem definir API HTTP |
| [Operação do catálogo](catalog-operations.md) | Aplicação/teste em Docker, fases V1/V2/V3 e condições de reset |

## Fluxo de mudança

Mudança de comportamento: primeiro spec/contrato aprovado, depois plano/ADR, depois tarefa,
só então código. Uma tarefa por vez. Verificar aceite e atualizar o estado ao concluir.
A existência de uma tarefa não autoriza executá-la; perguntas abertas não são respondidas por
implementação. Testes consolidados exigem autorização específica para alteração.

- Aceito/aprovado: decisão vigente, não necessariamente implementada.
- Proposto: alternativa ainda sem aprovação.
- Implementado/verificado: evidência de execução ou código existente, com limites explícitos.
- Pendente/bloqueado: informação ou decisão necessária antes da tarefa dependente.

Dados e fórmulas não confirmados do jogo permanecem perguntas. Não usar uma duplicação em
plano, fixture ou JSON como nova fonte de requisito. O catálogo é a fonte dos valores
versionados; a spec é a fonte do comportamento.
