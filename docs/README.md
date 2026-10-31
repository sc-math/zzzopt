# Documentação do projeto

Esta documentação consolida as decisões tomadas com o usuário. O [README principal](../README.md)
apresenta o projeto ao público; aqui ficam os detalhes necessários para desenvolver cada etapa.

| Documento | Conteúdo |
|---|---|
| [Regras de negócio](business-rules.md) | Objetivo da v1, inventário, ficha, conjuntos, filtros e ciclo das execuções |
| [Contratos](contracts.md) | Modelos atuais, convenções de dados e limites do contrato HTTP ainda não implementado |
| [Arquitetura e etapas](architecture-and-roadmap.md) | Stack, organização, persistência, concorrência, experimentos e evolução |
| [Referência da Aria](aria-reference.md) | Cenário real de validação e pendência de precisão |
| [AGENTS.md](../AGENTS.md) | Permissões, restrições, proibições e instruções de colaboração para agentes de IA |

## Como interpretar o estado das decisões

- **Implementado:** comportamento presente no código atual.
- **Acordado para a v1:** requisito definido, mas não necessariamente implementado.
- **Planejado:** direção de implementação ou experimento, ainda sujeito à etapa correspondente.
- **Pendente:** ponto que precisa ser fechado; não presumir uma resposta definitiva.
- **Fora da v1:** não implementar antecipadamente.

Quando houver uma nova decisão do usuário, atualizar o documento correspondente. Se ela afetar
permissões ou proibições de trabalho, atualizar também o `AGENTS.md`. Os contratos HTTP não devem
ser considerados publicados apenas porque há exemplos nesta documentação.
