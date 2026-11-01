# Referência do catálogo de personagens

Dados enviados manualmente pelo usuário em 2026-10-31, sem scraping ou consulta externa para
completá-los. A lista inicial tem 63 personagens, com base crua máxima e passiva total separadas.
As referências de [motores](w-engines.md) e [conjuntos](disc-sets.md) completam o catálogo.

A [spec](business-rules.md) é a fonte das regras; este arquivo registra os dados, correções
e casos particulares fornecidos. Os valores foram carregados pela
[V2](../db/migration/V2__seed_catalog.sql). Estado e evidências estão em
[implementação](implementation-status.md); comandos/reset em
[operação do catálogo](catalog-operations.md); desenho das tabelas no
[plano técnico](architecture-and-roadmap.md).

## Identidade e particularidades

- IDs de personagens são `BIGINT`, utilizando os números fornecidos, sem geração automática.
- Correção confirmada pelo usuário: **Sunna 1491; Sunbringer 1601**.
- Os IDs próprios dos discos do inventário continuam strings e não mudam por esta decisão.
- O `Agent` do `core` continua com seu contrato Java atual. A futura camada de persistência
  adaptará o identificador numérico para ele; nenhum teste ou fixture existente foi reescrito.
- Pyrois tem rank `I`, com símbolo `∞`. Rank de personagem é um catálogo separado de `DiscRank`.
- Apenas Sunbringer foi explicitamente identificada como beta nesta carga. Ela recebe `BETA`;
  os demais registros recebem `UNKNOWN`, sem presumir estágio de lançamento não informado.

## Idiomas

A identidade e os atributos são independentes do nome de exibição. As tabelas de nomes usam
uma chave composta formada pela identidade e pelo idioma. A V2 contém apenas o idioma `en`.
Não foram inventadas traduções para português ou outros idiomas.

Adicionar uma tradução significa cadastrar um idioma e seu nome na tabela correspondente,
sem duplicar o personagem nem alterar referências. A escolha de idioma pela API, o mecanismo
de fallback e o contrato HTTP ainda serão implementados e definidos na etapa da aplicação.

## Elementos variantes

| Variante | Elemento básico | Nome em inglês |
|---|---|---|
| `FROST` | `ICE` | Frost |
| `AURIC_INK` | `ETHER` | Auric Ink |
| `HONED_EDGE` | `PHYSICAL` | Honed Edge |
| `GENESIS_FLARE` | `FIRE` | Genesis Flare, provisório |

As quatro relações foram informadas pelo usuário. `WIND` e `LUMIFLUX` também são preservados
como enviados, sem presumir relações adicionais não fornecidas.

Nome e identidade são separados: atualizar a tradução de Genesis Flare não exige alterar o ID
do personagem. O indicador `name_is_provisional` registra a situação atual desse nome.
A relação variante/base é classificação; não implementa automaticamente herança de bônus,
resistências ou fórmulas de dano. Essas regras serão tratadas na etapa de combate.

## Base crua e passiva maximizada

Guardar a **base crua no nível máximo** e os **bônus totais da passiva maximizada** separadamente.
Não guardar valores por nível nem modelar progressão da passiva. Essa decisão substitui o
armazenamento anterior dos atributos com passiva embutida. Dados antigos exigem separação
confirmada; não deduzir bônus por suposição nem generalizar +75 ATQ a todos os personagens.

A partir da Nicole (1031), o usuário confirmou que os dados enviados já são a base crua,
sem passiva, com os bônus informados separadamente. Não descontá-los dos valores base.
Isso não muda retroativamente a separação já confirmada da Anby.

Cada total de passiva possui:

- `application_stage = BASE`: soma à base crua antes dos multiplicadores; somente `FLAT`.
- `application_stage = SHEET`: entra junto aos modificadores da ficha, com `FLAT` ou `PERCENT`.
- `value`: decimal não negativo e finito. Percentuais relativos usam pontos percentuais (`21` = 21%).

`FLAT` significa soma na unidade do atributo: para taxa/dano crítico, são pontos percentuais.
Não multiplicar a taxa crítica base. Efeitos de combate não entram nessa tabela de bônus permanentes.
Ausência de atributo não equivale a zero; ausência de bônus não confirma que a passiva não tem bônus.
`passive_bonuses_complete` é falso por padrão e deve ser confirmado na coleta.

Anby Demara, ID 1011, está preparada na V2:

| Atributo | Base crua | Passiva total (`BASE/FLAT`) | Base com passiva |
|---|---:|---:|---:|
| PV | 7500 | — | 7500 |
| ATQ | 583 | +75 | 658 |
| DEF | 612 | — | 612 |
| Impacto | 118 | +18 | 136 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 94 | — | 94 |
| Proficiência de Anomalia | 93 | — | 93 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | — | 1,2 |

O usuário confirmou os totais da Anby: `3 × 25 = 75` ATQ base e `3 × 6 = 18` Impacto base.
Não foram cadastrados seis níveis intermediários. O zero da taxa de perfuração foi informado.
Os lotes posteriores de Sunna e Manato informaram, respectivamente, +21% ATQ e +18% PV
como modificadores percentuais de ficha, registrados separadamente da base.
A referência da Aria continua preservada com os valores já enviados e seus bônus conhecidos.

Nicole Demara, ID 1031, também está preparada na V2:

| Atributo | Base crua | Passiva total (`BASE/FLAT`) | Base com passiva |
|---|---:|---:|---:|
| PV | 8145 | — | 8145 |
| ATQ | 574 | +75 | 649 |
| DEF | 622 | — | 622 |
| Impacto | 88 | — | 88 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 90 | — | 90 |
| Proficiência de Anomalia | 93 | — | 93 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | +0,36 | 1,56 |

Os dois bônus são acréscimos à base, conforme informado; `+0,36` de recuperação de energia
é um valor absoluto, sem conversão para percentual.

Corin Wickes, ID 1061, está preparada na V2:

| Atributo | Base crua | Passiva total | Valor com passiva, sem equipamentos |
|---|---:|---|---:|
| PV | 6976 | — | 6976 |
| ATQ | 732 | +75 (`BASE/FLAT`) | 807 |
| DEF | 604 | — | 604 |
| Impacto | 93 | — | 93 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | +28,8 pontos percentuais (`SHEET/FLAT`) | 78,8% |
| Maestria de Anomalia | 93 | — | 93 |
| Proficiência de Anomalia | 96 | — | 96 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | — | 1,2 |

O dano crítico da passiva é somado diretamente em pontos percentuais; não multiplica os 50%
da base nem é descontado do valor enviado.

Billy Kid, ID 1081 (enviado como Billy), está preparado na V2:

| Atributo | Base crua | Passiva total | Valor com passiva, sem equipamentos |
|---|---:|---|---:|
| PV | 6907 | — | 6907 |
| ATQ | 712 | +75 (`BASE/FLAT`) | 787 |
| DEF | 606 | — | 606 |
| Impacto | 91 | — | 91 |
| Taxa crítica | 5% | +14,4 pontos percentuais (`SHEET/FLAT`) | 19,4% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 92 | — | 92 |
| Proficiência de Anomalia | 91 | — | 91 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | — | 1,2 |

A taxa crítica da passiva é uma soma em pontos percentuais, sem multiplicar os 5% da base.
O nome de catálogo já informado, Billy Kid, foi preservado pelo ID 1081.

Anton Ivanov, ID 1111 (enviado como Anton), está preparado na V2:

| Atributo | Base crua | Passiva total | Valor com passiva, sem equipamentos |
|---|---:|---|---:|
| PV | 7219 | — | 7219 |
| ATQ | 716 | +75 (`BASE/FLAT`) | 791 |
| DEF | 622 | — | 622 |
| Impacto | 95 | — | 95 |
| Taxa crítica | 5% | +14,4 pontos percentuais (`SHEET/FLAT`) | 19,4% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 86 | — | 86 |
| Proficiência de Anomalia | 90 | — | 90 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | — | 1,2 |

A taxa crítica da passiva é aditiva em pontos percentuais. O nome de catálogo Anton Ivanov
foi preservado pelo ID 1111; os valores base enviados não tiveram bônus descontados.

Ben Bigger, ID 1121 (enviado como Ben), está preparado na V2:

| Atributo | Base crua | Passiva total (`BASE/FLAT`) | Base com passiva |
|---|---:|---:|---:|
| PV | 8577 | — | 8577 |
| ATQ | 578 | +75 | 653 |
| DEF | 724 | — | 724 |
| Impacto | 95 | — | 95 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 86 | — | 86 |
| Proficiência de Anomalia | 90 | — | 90 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | +0,36 | 1,56 |

Os dois bônus são acréscimos à base; recuperação de energia recebe +0,36 absoluto.
O nome de catálogo Ben Bigger foi preservado pelo ID 1121.

Soukaku, ID 1131, está preparada na V2:

| Atributo | Base crua | Passiva total (`BASE/FLAT`) | Base com passiva |
|---|---:|---:|---:|
| PV | 8025 | — | 8025 |
| ATQ | 590 | +75 | 665 |
| DEF | 597 | — | 597 |
| Impacto | 86 | — | 86 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 93 | — | 93 |
| Proficiência de Anomalia | 96 | — | 96 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | +0,36 | 1,56 |

Os dois bônus são acréscimos à base; +0,36 de recuperação de energia é um valor absoluto.
Os valores base enviados foram preservados sem descontar a passiva.

Luciana de Montefio, ID 1151 (enviada como Lucy), está preparada na V2:

| Atributo | Base crua | Passiva total (`BASE/FLAT`) | Base com passiva |
|---|---:|---:|---:|
| PV | 8025 | — | 8025 |
| ATQ | 583 | +75 | 658 |
| DEF | 612 | — | 612 |
| Impacto | 86 | — | 86 |
| Taxa crítica | 5% | — | 5% |
| Dano crítico | 50% | — | 50% |
| Maestria de Anomalia | 94 | — | 94 |
| Proficiência de Anomalia | 93 | — | 93 |
| Taxa de perfuração | 0% | — | 0% |
| Recuperação de energia | 1,2 | +0,36 | 1,56 |

Os dois bônus são acréscimos à base; recuperação de energia recebe +0,36 absoluto.
O nome de catálogo Luciana de Montefio foi preservado pelo ID 1151.

O lote seguinte acrescenta seis perfis na mesma V2:

| Atributo base | Seth (1271) | Piper (1281) | Pulchra (1351) | Pan Yinhu (1421) | Manato (1441) | Nekomiya Mana (1021) |
|---|---:|---:|---:|---:|---:|---:|
| PV | 8701 | 6976 | 7612 | 8453 | 7724 | 7560 |
| ATQ | 568 | 683 | 590 | 586 | 680 | 835 |
| DEF | 746 | 612 | 606 | 712 | 443 | 587 |
| Impacto | 94 | 86 | 118 | 94 | 95 | 92 |
| Taxa crítica | 5% | 5% | 5% | 5% | 5% | 5% |
| Dano crítico | 50% | 50% | 50% | 50% | 50% | 50% |
| Maestria de Anomalia | 86 | 116 | 92 | 91 | 87 | 97 |
| Proficiência de Anomalia | 90 | 118 | 90 | 90 | 90 | 96 |
| Taxa de perfuração | 0% | 0% | 0% | 0% | — | 0% |
| Recuperação de energia | 1,2 | 1,2 | 1,2 | 1,2 | — | 1,2 |
| Sheer Force | — | — | — | — | 0 | — |
| Acúmulo automático de adrenalina | — | — | — | — | 0 | — |

`—` indica dado não fornecido, sem inserir zero automaticamente. Nomes de catálogo como Piper
Wheel e Pulchra Fellini permanecem vinculados aos IDs enviados, sem renomear por abreviações.

| Personagem | Totais da passiva | Valores afetados, sem equipamentos |
|---|---|---|
| Seth | ATQ +75 e recuperação de energia +0,36 (`BASE/FLAT`) | ATQ 643; recuperação 1,56 |
| Piper | ATQ +75 e recuperação de energia +0,36 (`BASE/FLAT`) | ATQ 758; recuperação 1,56 |
| Pulchra | ATQ +75 e Impacto +18 (`BASE/FLAT`) | ATQ 665; Impacto 136 |
| Pan Yinhu | ATQ +75 e recuperação de energia +0,36 (`BASE/FLAT`) | ATQ 661; recuperação 1,56 |
| Manato | ATQ +75 (`BASE/FLAT`), PV +18% (`SHEET/PERCENT`) | ATQ 755; PV 9114,32, sem arredondamento |
| Nekomiya Mana | ATQ +75 (`BASE/FLAT`), taxa crítica +14,4 pontos percentuais (`SHEET/FLAT`) | ATQ 910; taxa crítica 19,4% |

### Particularidades de Rupture

O usuário informou que Rupture usa adrenalina em lugar de energia. Recuperação de energia de
equipamentos não aumenta o acúmulo de adrenalina. Os códigos novos são `SHEER_FORCE` e
`AUTOMATIC_ADRENALINE_ACCUMULATION`, ambos com unidade `NUMBER`, preparados na V2.
Não é necessário alterar a V1 para cadastrar novos códigos de atributos.

Para Manato, os dois zeros foram fornecidos explicitamente. Não foi cadastrado `ENERGY_REGEN`
nem inferida taxa de perfuração de 100%. O usuário permite deixar perfuração em zero, mas o lote
não exige fabricar um registro: sua fórmula de dano será tratada separadamente na etapa de dano.

Sheer Force depende dos atributos e da regra específica do personagem. A fórmula, coeficientes
e condições ainda não foram fornecidos; o zero cadastrado preserva a origem e não garante
Sheer Force zero em uma build. Não calcular genericamente a partir de ATQ/PV nem apresentar
esse valor como resultado derivado. O `core` ainda não contém os dois novos códigos; sua
integração e os cálculos correspondentes são pendências antes de oferecer esses resultados.

### Claret e particularidades de Armorer

Claret Flint, ID 1611 (enviada como Claret), está preparada na V2:

| Atributo | Base crua |
|---|---:|
| PV | 5651 |
| ATQ | 626 |
| Laceration DMG | 150% |
| DEF | 441 |
| Impacto | 93 |
| Taxa crítica | 5% |
| Dano crítico normal | 50% |
| Maestria de Anomalia | 80 |
| Proficiência de Anomalia | 79 |
| Taxa de perfuração | 0% |
| Acúmulo automático de Sharpness | 1,5 |

A passiva informada é +28,8 pontos percentuais de taxa crítica (`CRIT_RATE/SHEET/FLAT`).
Não foi informado +75 ATQ e ele não foi acrescentado. O ATQ base permanece 626.

Os códigos `AUTOMATIC_SHARPNESS_ACCUMULATION` (`NUMBER`) e `LACERATION_DAMAGE`
(`PERCENT_POINTS`) foram preparados na V2. Sharpness é o recurso de Armorer; não transformar
esse atributo em `ENERGY_REGEN` ou acúmulo de adrenalina. A interação com bônus de recuperação
de energia não foi detalhada, portanto não criar equivalência automática.

Laceration DMG representa o dano crítico próprio da classe. O dano crítico normal foi informado
como atributo que se converte em taxa crítica; preservar ambos os valores sem sobrescrever
`CRIT_DAMAGE` por `LACERATION_DAMAGE`. A fórmula de conversão, proporção e parcelas consideradas
ainda não foram fornecidas. A soma direta 5 + 28,8 = 33,8% antecede essa conversão e não deve
ser apresentada como taxa crítica final validada.

Os novos atributos e essa conversão ainda não estão implementados no `core`; o cadastro
preserva os dados fornecidos e não torna a ficha completa de Armorer calculável nesta etapa.

### Lote de 13 personagens e Zhu Yuan

Os 14 perfis estão preparados na mesma V2. Todos os valores abaixo são bases
cruas. Cada um informa taxa crítica 5%, dano crítico 50% e bônus separado de +75 ATQ base
(`BASE/FLAT`). Esse bônus foi enviado para cada personagem deste lote; não é uma regra geral
para personagens que ainda não tiveram seus bônus informados.

| Personagem (ID) | PV | ATQ | DEF | Impacto | Maestria | Proficiência | Outro bônus da passiva |
|---|---:|---:|---:|---:|---:|---:|---|
| Soldier 11 (1041) | 7673 | 813 | 612 | 93 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Yidhari Murphy (1051) | 8497 | 784 | 448 | 95 | 87 | 90 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Caesar King (1071) | 9526 | 636 | 753 | 105 | 87 | 90 | Impacto +18 (`BASE/FLAT`) |
| Hoshimi Miyabi (1091) | 7673 | 805 | 606 | 86 | 116 | 148 | Proficiência +90 (`BASE/FLAT`) |
| Koleda Belobog (1101) | 8127 | 660 | 594 | 116 | 97 | 96 | Impacto +18 (`BASE/FLAT`) |
| Von Lycaon (1141) | 8416 | 653 | 606 | 119 | 91 | 90 | Impacto +18 (`BASE/FLAT`) |
| Lighter (1161) | 8253 | 722 | 612 | 119 | 91 | 90 | Impacto +18 (`BASE/FLAT`) |
| Burnice White (1171) | 7368 | 788 | 600 | 83 | 118 | 120 | Recuperação de energia +0,36 (`BASE/FLAT`) |
| Grace Howard (1181) | 7482 | 750 | 600 | 83 | 115 | 116 | Maestria +36 (`BASE/FLAT`) |
| Ellen Joe (1191) | 7673 | 863 | 606 | 93 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Asaba Harumasa (1201) | 7405 | 840 | 600 | 90 | 80 | 95 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Alexandrina Sebastiane (1211) | 8609 | 642 | 600 | 83 | 93 | 92 | Taxa de perfuração +14,4 pp (`SHEET/FLAT`) |
| Tsukishiro Yanagi (1221) | 7788 | 797 | 612 | 86 | 112 | 114 | Maestria +36 (`BASE/FLAT`) |
| Zhu Yuan (1241) | 7482 | 844 | 600 | 90 | 93 | 92 | Dano crítico +28,8 pp (`SHEET/FLAT`) |

Exceto Yidhari, todos informam taxa de perfuração base 0% e recuperação de energia base 1,2.
Yidhari informa Sheer Force 0 e acúmulo automático de adrenalina **2**, sem preencher energia
ou perfuração por inferência. O acúmulo 2 não é um bônus da passiva e não deve ser somado novamente.
Seu zero de Sheer Force preserva a origem; o cálculo derivado continua pendente.

Os acréscimos de Impacto, Maestria e Proficiência ficam separados da base crua, na etapa `BASE`.
Taxa crítica, dano crítico e taxa de perfuração somam pontos percentuais na ficha (`SHEET/FLAT`).
Por exemplo, Miyabi passa de 148 para 238 de Proficiência; Grace de 115 para 151 de Maestria;
Yanagi de 112 para 148 de Maestria; Alexandrina recebe 14,4% de perfuração. Não multiplicar
a taxa de perfuração base zero por 14,4%. Nenhum arredondamento adicional foi introduzido.

Zhu Yuan fica com ATQ 919 (844 + 75) e dano crítico 78,8% (50 + 28,8), sem equipamentos.

### Lote de Qingyi a Ukinami Yuzuha

Os 14 perfis abaixo estão preparados na V2. Os valores são bases cruas, com
taxa crítica 5% e dano crítico 50% em todos os perfis. Todos recebem +75 ATQ base como segundo
bônus informado, **exceto Yixuan**, que recebe +420 PV base e nenhum acréscimo de ATQ.

| Personagem (ID) | PV | ATQ | DEF | Impacto | Maestria | Proficiência | Primeiro bônus da passiva |
|---|---:|---:|---:|---:|---:|---:|---|
| Qingyi (1251) | 8250 | 683 | 612 | 118 | 94 | 93 | Impacto +18 (`BASE/FLAT`) |
| Jane Doe (1261) | 7788 | 805 | 606 | 86 | 112 | 114 | Maestria +36 (`BASE/FLAT`) |
| Hugo Vlad (1291) | 7940 | 844 | 616 | 95 | 86 | 90 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Orphie Magnusson & Magus (1301) | 7788 | 854 | 612 | 93 | 92 | 90 | Recuperação de energia +0,36 (`BASE/FLAT`) |
| Astra Yao (1311) | 8609 | 640 | 600 | 83 | 93 | 92 | Recuperação de energia +0,36 (`BASE/FLAT`) |
| Evelyn Chevalier (1321) | 7788 | 854 | 612 | 93 | 92 | 90 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Vivian Banshee (1331) | 7673 | 805 | 606 | 86 | 108 | 118 | Maestria +36 (`BASE/FLAT`) |
| Zhao (1341) | 9117 | 690 | 701 | 93 | 93 | 96 | PV +18% (`SHEET/PERCENT`) |
| Trigger (1361) | 7923 | 675 | 600 | 113 | 96 | 95 | Impacto +18 (`BASE/FLAT`) |
| Yixuan (1371) | 7953 | 872 | 441 | 93 | 92 | 90 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Soldier 0 - Anby (1381) | 7673 | 854 | 612 | 93 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Ju Fufu (1391) | 8250 | 690 | 597 | 118 | 93 | 96 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Alice Thymefield (1401) | 7673 | 805 | 606 | 86 | 106 | 118 | Maestria +36 (`BASE/FLAT`) |
| Ukinami Yuzuha (1411) | 8829 | 683 | 612 | 86 | 88 | 93 | Maestria +36 (`BASE/FLAT`) |

Exceto Yixuan, todos informam taxa de perfuração base 0% e recuperação de energia base 1,2.
Yixuan informa Sheer Force 0 e acúmulo automático de adrenalina 2; não preencher energia ou
perfuração por inferência. O cálculo derivado de Sheer Force permanece pendente.

Casos distintos preservados:

- **Zhao:** PV base 9117 e +18% PV na etapa `SHEET/PERCENT`; sem equipamentos, PV 10758,06
  sem arredondamento. Seu +75 ATQ base é separado do bônus percentual de PV.
- **Yixuan:** PV base 7953 e +420 PV em `BASE/FLAT`, resultando em base composta 8373.
  ATQ permanece 872 antes de equipamentos, sem acrescentar +75 por analogia com outros agentes.
  A taxa crítica recebe +14,4 pontos percentuais em `SHEET/FLAT`.
- **Qingyi e Trigger:** Impacto base 118 e 113, com +18 separado, resultando em 136 e 131.
- **Ju Fufu:** o bônus informado neste lote é taxa crítica, não Impacto; não inferir pelo atributo ou classe.

### Lote de Ye Shunguang a Norma Hollowell

Os 14 perfis estão preparados na V2. Os valores abaixo são bases cruas.
Todos informam taxa crítica 5%, dano crítico 50% e, separadamente, +75 ATQ em `BASE/FLAT`.

| Personagem (ID) | PV | ATQ | DEF | Impacto | Maestria | Proficiência | Outro bônus da passiva |
|---|---:|---:|---:|---:|---:|---:|---|
| Ye Shunguang (1431) | 7673 | 863 | 606 | 83 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Lucia Elowen (1451) | 8477 | 683 | 594 | 83 | 96 | 95 | Recuperação de energia +0,36 (`BASE/FLAT`) |
| Seed (1461) | 7673 | 854 | 612 | 93 | 94 | 93 | Dano crítico +28,8 pp (`SHEET/FLAT`) |
| Banyue (1471) | 8497 | 784 | 445 | 95 | 90 | 89 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Dialyn (1481) | 8250 | 683 | 612 | 110 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Sunna (1491) | 8477 | 675 | 600 | 98 | 96 | 95 | ATQ +21% (`SHEET/PERCENT`) |
| Aria (1501) | 7749 | 788 | 619 | 87 | 115 | 116 | Maestria +36 (`BASE/FLAT`) |
| Nangong Yu (1511) | 8373 | 671 | 622 | 120 | 90 | 93 | Maestria +36 (`BASE/FLAT`) |
| Cissia (1521) | 7673 | 863 | 606 | 93 | 94 | 93 | Recuperação de energia +0,36 (`BASE/FLAT`) |
| Starlight - Billy Kid (1531) | 8497 | 784 | 445 | 95 | 90 | 89 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Promeia (1541) | 7788 | 797 | 612 | 86 | 112 | 114 | Maestria +36 (`BASE/FLAT`) |
| Pyrois (1551) | 7673 | 849 | 612 | 94 | 94 | 93 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Velina Airgid (1561) | 7788 | 797 | 612 | 86 | 112 | 111 | Proficiência +54 (`BASE/FLAT`) |
| Norma Hollowell (1571) | 7799 | 687 | 582 | 106 | 99 | 98 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |

Banyue e Starlight - Billy Kid informam Sheer Force 0 e acúmulo automático de adrenalina 2,
sem preencher energia ou taxa de perfuração por inferência. Os outros perfis informam taxa
de perfuração base 0%; a recuperação de energia é 1 para **Sunna e Pyrois** e 1,2 para os demais.

Particularidades preservadas:

- **Sunna:** ATQ base cru 675, +75 ATQ base e +21% ATQ junto aos modificadores de ficha
  (`ATTACK/SHEET/PERCENT`). Sem motor ou discos: (675 + 75) × 1,21 = 907,5.
  A classificação do bônus substitui a pendência anterior; não foram feitos testes de precisão
  contra a exibição do jogo. Recuperação de energia base 1, sem converter para 1,2.
- **Aria:** ATQ cru 788 + 75 = 863 e Maestria crua 115 + 36 = 151, consistentes com a
  [referência manual](aria-reference.md). A fixture e os testes consolidados não foram alterados.
- **Velina:** +54 de Proficiência, resultando em 165 (111 + 54), sem substituir pelo bônus 36
  de outros personagens. O ATQ com passiva, sem equipamentos, é 872 (797 + 75).
- **Pyrois:** rank `I` e símbolo de infinito do catálogo preservados; recuperação de energia base 1.
- **Norma:** PV base 7799, DEF 582 e Impacto 106 preservados exatamente como enviados.

### Lote de Remielle a Phoenix

Os cinco perfis estão preparados na V2. Todos informam bases cruas, taxa crítica
5%, dano crítico 50%, taxa de perfuração 0%, recuperação de energia 1,2 e +75 ATQ separado
em `BASE/FLAT`.

| Personagem (ID) | PV | ATQ | DEF | Impacto | Maestria | Proficiência | Outro bônus da passiva |
|---|---:|---:|---:|---:|---:|---:|---|
| Remielle Dan (1581) | 7482 | 748 | 600 | 83 | 115 | 116 | Proficiência +54 (`BASE/FLAT`) |
| Sigrid de L'Azur (1591) | 7788 | 863 | 606 | 93 | 92 | 90 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Roxy Ifrita Pryce (1621) | 8418 | 666 | 641 | 100 | 110 | 63 | Taxa crítica +14,4 pp (`SHEET/FLAT`) |
| Severian Lowell (1631) | 7826 | 858 | 606 | 94 | 91 | 90 | Dano crítico +28,8 pp (`SHEET/FLAT`) |
| Phoenix Reffaella (1641) | 7673 | 797 | 612 | 86 | 116 | 118 | Maestria +36 (`BASE/FLAT`) |

A tabela enviada não repetiu o ID da Phoenix e sua coluna está deslocada em uma linha.
Foi utilizado o ID **1641**, já fornecido para Phoenix Reffaella no catálogo, associando
os valores pelos rótulos da coluna. Os nomes de catálogo foram preservados por ID, incluindo
a grafia de Sigrid com apóstrofo tipográfico; o nome de origem com apóstrofo simples não renomeia a entidade.

Remielle recebe +54 de Proficiência: 116 + 54 = 170. Roxy mantém Proficiência base **63**.
Severian recebe +28,8 pontos percentuais de dano crítico, resultando em 78,8%.
Phoenix recebe +36 de Maestria: 116 + 36 = 152. Todos os bônus permanecem separados das bases.

Esse lote completou 62 perfis; a Sunbringer foi fornecida na sequência, conforme a seção abaixo.
O estado da aplicação da V2 está em [implementação](implementation-status.md).

### Sunbringer e conclusão da lista inicial de personagens

Sunbringer, ID 1601, permanece com estágio `BETA` e nome de elemento provisório Genesis Flare.
Os valores abaixo são os dados atuais enviados pelo usuário, sujeitos a alterações no beta.
O ATQ base 626 foi confirmado em complemento à primeira mensagem.

| Atributo | Base crua |
|---|---:|
| PV | 5736 |
| ATQ | 626 |
| Laceration DMG | 150% |
| DEF | 441 |
| Impacto | 93 |
| Taxa crítica | 5% |
| Dano crítico normal | 50% |
| Maestria de Anomalia | 78 |
| Proficiência de Anomalia | 77 |
| Taxa de perfuração | 0% |
| Acúmulo automático de Sharpness | 1,5 |

A passiva informada é +28,8 pontos percentuais de taxa crítica (`CRIT_RATE/SHEET/FLAT`).
Nenhum bônus de ATQ foi informado. Não substituir dano crítico normal por Laceration DMG;
a conversão de dano crítico em taxa crítica continua pendente, como na Claret. A soma direta
33,8% de taxa crítica antecede a conversão e não é uma ficha final validada de Armorer.

Os **63 personagens da lista inicial têm perfis com base crua e bônus separados cadastrados**
na V2. Isso não significa suporte completo da engine a todos os personagens:
permanecem as pendências de integração e fórmulas derivadas documentadas acima. Os motores
foram fornecidos posteriormente e estão detalhados no [documento próprio](w-engines.md).
Os conjuntos foram fornecidos na sequência; ver [análise e pendências](disc-sets.md).

O usuário mencionou duas personagens de collab no beta, cujos dados enviará depois.
Não foram criados registros, nomes ou IDs presumidos; não fazem parte da lista inicial de 63.

O `core` mantém seu contrato: `Agent.baseStats` recebe a base composta. A integração futura
montará essa base uma vez e encaminhará os bônus de ficha; não há carregador JPA implementado.
