# Referência técnica do core existente

Este documento descreve a implementação atual, não define o contrato HTTP nem substitui a
[spec](business-rules.md). Evoluções devem seguir [plano](architecture-and-roadmap.md),
[tarefas](tasks.md) e [aceite](acceptance-criteria.md).

## Modelos e cálculo

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

Classe e elemento existem nos metadados persistidos, mas ainda não são campos de `Agent`.
DTOs HTTP e entidades JPA serão definidos na etapa correspondente, sem obrigar a engine de
ficha a implementar regras de combate para esses metadados.

O método atual é:

```java
Stats BuildCalculator.calculate(Agent agent, WEngine engine,
                                EquipmentBuild build, List<DiscSet> sets)
```

## Atributos e validação atuais

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

## Representação da ficha

Stats usa um mapa imutável de Stat para BigDecimal, rejeita valores negativos e retorna zero
para uma chave ausente. BuildCalculator percorre os tipos de Stat suportados e preserva
decimais, sem teto ou arredondamento de exibição.

Esse zero interno não autoriza tratar dados obrigatórios ausentes no catálogo como completos.
O adaptador precisa resolver RF-06/Q-06 antes de calcular uma ficha apresentada como completa.

O enum atual inclui HEALTH, ATTACK, DEFENSE, IMPACT, CRIT_RATE, CRIT_DAMAGE,
ANOMALY_MASTERY, ANOMALY_PROFICIENCY, PENETRATION_FLAT, PENETRATION_RATE, ENERGY_REGEN
e bônus PHYSICAL/FIRE/ICE/ELECTRIC/ETHER_DAMAGE_BONUS. Os novos códigos do catálogo ainda
dependem de evolução.

Agent.baseStats recebe a base já composta. Não existe carregador de passivas do banco.
WEngine aceita somente baseAttack; motores DEF ainda não podem ser representados.
IDs atuais são strings, independentes dos IDs numéricos do catálogo.

## Ranks de catálogo

AgentRank e WEngineRank são enums distintos em build, adicionados na simplificação V3.
AgentRank aceita A/S/I e fornece symbol(), com I representado por ∞. WEngineRank aceita B/A/S.
DiscRank continua independente. Os modelos Agent/WEngine não receberam novos campos e não
há cálculo ou contrato HTTP novo decorrente desses enums; integração JPA permanece futura.

## Legado

damage e a classe main são código anterior, sem ligação com a montagem da ficha.
Usam double e percentuais fracionários em sua própria entrada; isso não altera a convenção
55 = 55% da ficha. A tolerância de 2% dos testes de dano não vale para os filtros.

Os testes legados compartilham o módulo Maven com os demais; o isolamento é por responsabilidade,
não por uma execução Maven separada. Preservá-los sem edição não autorizada.
