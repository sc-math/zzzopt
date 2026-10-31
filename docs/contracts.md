# Contratos e convenções de dados

## Estado do contrato

O `core` atual expõe modelos e métodos Java. Não há API HTTP, desserializador JSON, OpenAPI ou
esquema de banco implementados. Os campos básicos do disco e as semânticas abaixo foram acordados;
o envelope completo de uma requisição HTTP ainda precisa ser fechado na etapa correspondente.

Exemplos JSON neste documento descrevem a representação pretendida dos dados, não endpoints
já disponíveis. Não considerar os modelos Java automaticamente como DTOs HTTP ou entidades JPA.

## Inventário e discos

`Inventory.items` contém os discos disponíveis. Uma coleção de inventário não precisa conter
uma build completa; `EquipmentBuild` é que exige seis slots distintos.

| Campo do disco | Tipo atual | Significado |
|---|---|---|
| `id` | string não vazia | Identidade da peça no inventário |
| `gear` | inteiro de 1 a 6 | Slot do disco |
| `set` | string não vazia | ID do conjunto no catálogo |
| `rank` | enum `B`, `A`, `S` | Raridade |
| `enhance` | inteiro de 0 a 15 | Aprimoramento atual; validação estrutural inicial |
| `main` | atributo | Tipo e valor final do atributo principal |
| `substats` | lista de atributos | Até quatro atributos secundários atuais |

Cada atributo possui `type` e `value`. `value` é decimal não negativo, representado por
`BigDecimal` no Java. Percentuais usam `55` para `55%`; valores flat mantêm sua unidade numérica.

Recorte de uma peça da Aria; não representa sozinho uma build de seis discos:

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

### Tipos de bônus suportados atualmente

| Categoria | Tipos de `StatBonus.Type` |
|---|---|
| PV | `HEALTH_FLAT`, `HEALTH_PERCENT` |
| ATQ | `ATTACK_FLAT`, `ATTACK_PERCENT` |
| DEF | `DEFENSE_FLAT`, `DEFENSE_PERCENT` |
| Impacto | `IMPACT_FLAT`, `IMPACT_PERCENT` |
| Crítico | `CRIT_RATE`, `CRIT_DAMAGE` |
| Maestria de Anomalia | `ANOMALY_MASTERY_FLAT`, `ANOMALY_MASTERY_PERCENT` |
| Proficiência de Anomalia | `ANOMALY_PROFICIENCY_FLAT`, `ANOMALY_PROFICIENCY_PERCENT` |
| Perfuração | `PENETRATION_FLAT`, `PENETRATION_RATE` |
| Recuperação de energia | `ENERGY_REGEN_FLAT`, `ENERGY_REGEN_PERCENT` |
| Bônus de dano | `PHYSICAL_DAMAGE_BONUS`, `FIRE_DAMAGE_BONUS`, `ICE_DAMAGE_BONUS`, `ELECTRIC_DAMAGE_BONUS`, `ETHER_DAMAGE_BONUS` |

Ter um tipo no modelo não significa que ele seja um atributo principal ou subatributo legal
em qualquer slot/raridade. A tabela completa dessas restrições e dos valores legais ainda
precisa ser modelada. A validação atual não simula o processo de geração de itens do jogo.

### Validações atuais

- IDs únicos no inventário e nos catálogos de conjuntos utilizados pelo cálculo.
- Uma build tem seis peças de IDs distintos e uma peça em cada slot.
- Slots 1, 2 e 3 exigem, respectivamente, `HEALTH_FLAT`, `ATTACK_FLAT` e `DEFENSE_FLAT` como principal.
- Até quatro subatributos, sem tipos repetidos e sem repetir o mesmo tipo do principal.
- Percentual e flat do mesmo atributo são tipos diferentes.
- O conjunto de cada disco deve existir no catálogo fornecido à montagem da ficha.
- Coleções são copiadas para representações imutáveis; não guardar referências mutáveis do cliente.
- Ausência de dados não é representada por strings como `"undefined"`. Campos obrigatórios
  precisam ser validados; formato externo de erros agregados ainda não está implementado.

## Catálogo e entrada da montagem de ficha

| Modelo atual | Campos | Observação |
|---|---|---|
| `Agent` | `id`, `name`, `baseStats` | Base já incorpora os acréscimos permanentes da passiva maximizada |
| `WEngine` | `id`, `name`, `baseAttack`, `advancedStats` | Efeitos de combate não entram nesses atributos |
| `DiscSet` | `id`, `name`, `effects` | Identidade própria, independente da igualdade de efeitos |
| `DiscSet.Effect` | `requiredPieces`, `context`, `bonuses`, `description` | Requisito de 2 ou 4 peças; contexto `SHEET` ou `COMBAT` |
| `EquipmentBuild` | `items` | Seis discos ordenados por slot |

Efeitos de ficha exigem bônus estruturados. Efeitos de combate podem ter apenas uma descrição,
sem implementação executável nesta etapa. Vários efeitos podem compartilhar o requisito de
peças, inclusive com contextos diferentes; não impor unicidade apenas por conjunto e requisito.

Classe e elemento foram informados no cenário de referência, mas ainda não são campos de `Agent`.
O catálogo persistido e seus DTOs serão definidos quando necessários, sem obrigar a engine
de ficha a implementar regras de combate para esses metadados.

O método atual é:

```java
Stats BuildCalculator.calculate(Agent agent, WEngine engine,
                                EquipmentBuild build, List<DiscSet> sets)
```

## Ficha calculada e resultados da busca

`Stats.values` relaciona cada `Stat` ao seu valor decimal. Atributos ausentes em uma base são
interpretados como zero; a ficha calculada atual inclui todos os tipos de `Stat` disponíveis.

Tipos atuais: `HEALTH`, `ATTACK`, `DEFENSE`, `IMPACT`, `CRIT_RATE`, `CRIT_DAMAGE`,
`ANOMALY_MASTERY`, `ANOMALY_PROFICIENCY`, `PENETRATION_FLAT`, `PENETRATION_RATE`, `ENERGY_REGEN`
e os cinco tipos de bônus de dano presentes na tabela acima.

O resultado futuro de cada combinação deve reunir a ficha e a identificação dos seis discos.
O inventário de referência precisa acompanhar o contexto da execução para interpretar os IDs;
não exigir armazenar esse inventário como uma entidade pessoal permanente.

Não há dano calculado, score, ranking de melhor build ou remoção de combinações de peças
distintas que tenham a mesma ficha. O formato serializado completo do resultado e da transmissão
ainda será consolidado.

## Filtros: semântica acordada e formato pendente

O pedido deve identificar personagem e motor fixos, inventário, alternativas/composições de
conjuntos, principais opcionais dos slots 4/5/6 e intervalos de atributos.

As [regras de negócio](business-rules.md) definem a semântica. Permanecem pendentes:

- Nomes e estrutura do envelope HTTP e representação inequívoca das alternativas `4+2` e `2+2+2`.
- Uso externo de nomes, IDs estáveis ou resolução de nomes para personagem e motor. O usuário
  escolhe ambos; não inferir que seus nomes sejam chaves globais imutáveis.
- Política exata de comparação dos limites, inclusive inclusividade e precisão frente ao jogo.
- Tabela de atributos principais permitidos por slot/raridade e limites de aprimoramento específicos.
- Formato final dos erros, códigos HTTP e agregação de múltiplos problemas do inventário.

## HTTP e streaming: desenho planejado

Rotas discutidas, ainda sem implementação nem contrato publicado:

| Operação esboçada | Intenção |
|---|---|
| `POST /otimizacoes` | Validar pedido, registrar execução e devolver seu identificador sem esperar toda a busca |
| `GET /otimizacoes/{id}` | Consultar estado e metadados da execução; não recuperar builds históricas |
| `GET /otimizacoes/{id}/eventos` | Receber resultados incrementais; SSE foi a opção discutida |

O retorno `202 Accepted` foi proposto para a criação assíncrona. Estados conceituais discutidos:
pendente, processando, concluído, cancelado e falha. A interrupção por limite deve ser inequívoca
e indicar resultado incompleto. Nomes dos enums públicos, transições e motivos ainda precisam
ser formalizados; não tratá-los como um contrato já implementado.

O stream deverá informar lotes de builds e situação final. Tamanho dos lotes, campos dos eventos,
sequência, timeouts e heartbeats estão pendentes. Identificar lotes não cria garantia de replay.
Não há ACK de aplicação, recuperação por último lote ou persistência de resultados na v1.

Postman foi considerado para inspecionar SSE. Swagger/OpenAPI servirá para documentar a API;
não assumir que Swagger UI substitui um consumidor de streaming em testes de grande volume.
Uma interface futura pode salvar a configuração e o inventário no navegador para criar um novo
pedido. O backend continua validando todas as regras e não restaura a execução anterior.
