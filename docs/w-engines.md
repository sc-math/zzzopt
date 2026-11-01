# Referência do catálogo de motores

O usuário forneceu 102 motores: 49 S, 37 A e 16 B, com atributos máximos e unidades confirmadas.
Os dados e correções estão na [V2](../db/migration/V2__seed_catalog.sql).
Consultar [spec](business-rules.md), [estado implementado](implementation-status.md) e
[plano técnico](architecture-and-roadmap.md). Os arquivos em db/drafts são históricos,
sem execução independente.

Os nomes foram fornecidos em inglês; somente `en` foi preparado. IDs de motor são `BIGINT`,
preservando os números enviados; não mudar automaticamente os IDs string do `core`.
`Defence` da entrada corresponde ao código de especialidade já existente `DEFENSE`.
Isso não altera a grafia dos nomes dos motores nem cria uma segunda especialidade.

## Unidades confirmadas

Na coluna **Base Stat**, `ATK` e `DEF` são valores básicos absolutos. No schema atual da V3
ficam em `w_engine_stats` com papel `BASE` e modifier `FLAT`; o avançado usa
papel `ADVANCED` e mantém seu modifier. A [V2](../db/migration/V2__seed_catalog.sql) preserva
a origem nas tabelas históricas, convertidas sem alterar os valores pela V3.

Na coluna **Main Stat**, aplicar a convenção explicitamente confirmada:

| Texto recebido | Atributo do catálogo | Modificador | Exemplo |
|---|---|---|---|
| `Attack`, `ATK`, `ATK%` | `ATTACK` | `PERCENT` | 30 significa +30% ATQ |
| `HP`, `HP%` | `HEALTH` | `PERCENT` | 30 significa +30% PV |
| `Defense`, `DEF%` | `DEFENSE` | `PERCENT` | 48 significa +48% DEF |
| `Impact` | `IMPACT` | `PERCENT` | 18 significa +18% Impacto |
| `Energy Regen` | `ENERGY_REGEN` | `PERCENT` | 60 significa +60% de recuperação de energia |
| `Anomaly Mastery` | `ANOMALY_MASTERY` | `PERCENT` | 30 significa +30% Maestria |
| `Anomaly Proficiency` | `ANOMALY_PROFICIENCY` | `FLAT` | 90 soma 90 de Proficiência |
| `Crit Rate` | `CRIT_RATE` | `FLAT` | 24 soma 24 pontos percentuais |
| `Crit DMG` | `CRIT_DAMAGE` | `FLAT` | 48 soma 48 pontos percentuais |
| `PEN Ratio` | `PENETRATION_RATE` | `FLAT` | 24 soma 24 pontos percentuais |

O contexto da coluna é necessário: `ATK 25` em Main Stat é percentual pela confirmação do
usuário; `ATK 624` em Base Stat é básico absoluto. Os textos originais estão preservados em
`source_note` na V2, junto da representação normalizada. Não inferir unidades apenas pela magnitude.

## Casos específicos e correções

| Motor | ID | Atributo básico | Atributo avançado |
|---|---:|---|---|
| Crimson Thirst | 14161 | DEF 431 | DEF +48% |
| Bloodmarrow Coffer | 13021 | DEF 356 | Taxa crítica +20 pontos percentuais |
| Catty Luck | 13017 | DEF 356 | DEF +40% |
| [Lunar] Semiluna | 12016 | DEF 282 | DEF +32% |
| Incarcerating Grip | 14163 | ATQ 713 | Taxa crítica +24 pontos percentuais |
| [Magnetic Storm] Bravo | 12011 | ATQ 356 | Proficiência +60 |
| [Vortex] Hatchet | 12009 | ATQ 475 | Recuperação de energia +16% |

Há **102 atributos básicos e 102 atributos avançados** preparados. O usuário corrigiu a
Proficiência de Bravo de 0 para 60 e completou o Grip com ATQ básico 713 e taxa crítica 24%.
Essas informações substituem os dados anteriores; o ATQ base 356 de Bravo foi preservado.
O detalhamento das passivas de combate dos dois motores fica para a v2 do programa, como as demais.

## Passivas e limites da implementação

O usuário definiu que as passivas dos motores são efeitos de combate (`COMBAT`) e ficam para
a **v2 do programa**, junto ao cálculo de dano. A v1 usa somente os atributos básico e avançado.
Essa decisão substitui a exigência anterior de revisar individualmente o contexto das passivas.
Não exigir seus textos, valores, refinamentos ou fórmulas de combate para concluir a ficha
ou a carga da v1. Os bônus permanentes da passiva dos personagens mantêm suas regras próprias.

O indicador de revisão das passivas de combate não bloqueia o uso dos atributos básico e
avançado na v1. Os detalhes de combate não foram coletados; não inventar descrições ou fórmulas.
A v2 funcional não é a migration Flyway V2 da carga inicial.

A integração com o core está em [estado implementado](implementation-status.md).
Formato HTTP e uso de motor por especialidade continuam perguntas abertas Q-13/Q-15 da spec.
