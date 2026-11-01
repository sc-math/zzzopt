# Contrato de entrada e saída

Este documento complementa a [spec](business-rules.md). Distingue convenções acordadas de
propostas ainda abertas; não publica uma API já implementada. O [estado](implementation-status.md)
e o [plano técnico](architecture-and-roadmap.md) descrevem os modelos existentes.

## Convenções acordadas

- Inventário e filtros entram em JSON. O envelope completo depende de Q-13 da spec.
- Cada disco informa `id`, `gear`, `set`, `rank`, `enhance`, `main` e `substats`.
- O ID da peça é string não vazia, único no inventário recebido. Identidade do conjunto não
  é seu nome traduzido; a representação externa de IDs do catálogo ainda precisa ser fechada.
- Slots são inteiros de 1 a 6; ranks de disco são B, A e S; aprimoramento inicial suportado
  é de 0 a 15. Consultar RF-07/RF-08 para validação e limites desse recorte.
- Atributos têm tipo e valor decimal não negativo. 55 representa 55%; flat e percentual
  são tipos distintos. Não inferir unidade pelo valor.
- Personagem e motor são fixos durante um pedido. Seus IDs de catálogo são numéricos;
  isso não determina automaticamente se o JSON público aceitará ID ou nome.
- Filtros descrevem alternativas de conjuntos, principais opcionais dos slots 4/5/6 e
  intervalos de atributos; sua estrutura final aguarda Q-01, Q-02 e Q-13.

Exemplo conceitual preservado da referência da Aria. Os nomes dos tipos e a string do conjunto
representam o modelo atual; não são um contrato HTTP aprovado para o catálogo numérico:

```json
{
  "items": [
    {
      "id": "aria-disc-1",
      "gear": 1,
      "set": "melodia-de-phaethon",
      "rank": "S",
      "enhance": 15,
      "main": { "type": "HEALTH_FLAT", "value": 2200 },
      "substats": [
        { "type": "ANOMALY_PROFICIENCY_FLAT", "value": 36 },
        { "type": "PENETRATION_FLAT", "value": 18 },
        { "type": "DEFENSE_FLAT", "value": 15 },
        { "type": "ATTACK_PERCENT", "value": 3 }
      ]
    }
  ]
}
```

## Resultado acordado

Cada build identifica as seis peças que a formam e informa sua ficha, sem dano, score ou ranking.
O contexto da execução precisa permitir interpretar os IDs das peças; isso não exige inventário
pessoal persistente. Resultados são transmitidos progressivamente e não recuperados do histórico.

Conclusão completa, cancelamento, falha e interrupção por limite precisam ser distinguíveis.
Não há replay, restauração ou garantia de retomada por sequência de lotes.
Formato dos resultados/eventos e semântica da conclusão sem builds continuam abertos.

## Propostas de HTTP, ainda não publicadas

| Operação discutida | Intenção | Estado |
|---|---|---|
| POST /otimizacoes | Validar, registrar execução e devolver ID sem aguardar a busca inteira | Proposta |
| GET /otimizacoes/{id} | Consultar estado/metadados, sem builds históricas | Proposta |
| GET /otimizacoes/{id}/eventos | Receber lotes e situação final | Proposta |

O retorno 202 Accepted e os estados pendente, processando, concluído, cancelado e falha foram
discutidos, mas nomes públicos, transições, motivos e códigos finais ainda não foram fechados.
SSE é uma opção técnica discutida, não uma API implementada.

## Contratos a fechar antes da implementação dependente

| Tema | Perguntas da spec |
|---|---|
| Envelope, IDs, nomes de atributos e alternativas de conjuntos | Q-02, Q-13 |
| Comparação, inclusividade e representação dos limites | Q-01 |
| Inventário sem solução e erros agregados por peça/campo | Q-03, Q-04, Q-05 |
| Dados não suportados e compatibilidade de motor | Q-06, Q-15 |
| Estados, cancelamento, substituição e reinício | Q-07, Q-08 |
| Conexão, eventos, sequência, múltiplos consumidores e ordem | Q-09, Q-17 |
| Limites, admissão, timeouts e encerramento incompleto | Q-10 |
| Autenticação, autorização e histórico | Q-11, Q-12 |
| Idioma e versão dos dados | Q-14, Q-16 |

A matriz de aceite deve acompanhar o contrato quando uma dessas respostas for aprovada.
Não usar os campos de modelos Java ou tabelas SQL como aprovação implícita do JSON público.
