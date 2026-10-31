# Referência manual: Aria

Dados fornecidos pelo usuário no jogo. Personagem no nível 60, com passiva maximizada;
motor no nível máximo; seis discos de rank S e aprimoramento 15. Classe Anômalo, elemento Éter.

A fonte executável deste cenário é `core/src/test/java/dev/math/zzzopt/core/build/AriaFixture.java`.
Os dados não representam um catálogo completo ou uma consulta externa ao jogo.

## Base e motor

A Aria tem ATQ 788 sem passiva e recebe 3 × 25 = 75 de ATQ base permanente. O modelo recebe
ATQ 863, já incluindo esse acréscimo, sem adicioná-lo novamente. Ela não recebe PV da passiva.

Base: PV 7749, ATQ 863, DEF 619, Impacto 87, taxa crítica 5%, dano crítico 50%,
Maestria de Anomalia 151, Proficiência de Anomalia 116, taxa de perfuração 0%
e recuperação de energia 1,2.

Anjo na Concha: ATQ básico 713 e Maestria de Anomalia +30%. Seus efeitos de combate
(90 de Proficiência, 20% de dano e 10% de dano de anomalias/disfunção) não entram na ficha.

## Composição

- Melodia de Phaethon: slots 1, 3, 4 e 5. Duas peças: Maestria +8% na ficha.
  Quatro peças: Proficiência +45 e dano de Éter +25%, ambos de combate e excluídos.
- Destino Emplumado: slots 2 e 6. Duas peças: Proficiência +30 na ficha.
  Os efeitos de quatro peças são de combate e não entram no cálculo.

## Resultado e precisão

| Atributo | Resultado decimal do core | Exibição informada no jogo |
|---|---:|---:|
| PV | 10181,47 | 10182 |
| ATQ | 2582,64 | 2582 |
| DEF | 907,136 | 907 |
| Impacto | 87 | 87 |
| Taxa crítica | 9,8% | 9,8% |
| Dano crítico | 64,4% | 64,4% |
| Maestria de Anomalia | 253,68 | 253 |
| Proficiência de Anomalia | 400 | 400 |
| Perfuração flat | 36 | 36 |
| Taxa de perfuração | 0% | 0% |
| Recuperação de energia | 1,2 | 1,2 |
| Bônus de dano de Éter | 30% | 30% |

Fórmulas de referência:

```text
ATQ = (863 + 713) × (1 + 0,39) + 316 + 38 + 38 = 2582,64
PV = 7749 × (1 + 0,03) + 2200 = 10181,47
DEF = 619 × (1 + 0,144) + 184 + 15 = 907,136
Maestria = 151 × (1 + 0,30 + 0,30 + 0,08) = 253,68
Proficiência = 116 + 36 + 36 + 27 + 92 + 27 + 36 + 30 = 400
```

O PV informado foi confirmado pelo usuário. A precisão interna e as regras de arredondamento
do jogo permanecem desconhecidas. Não há tolerância ou correção artificial para transformar
o resultado decimal em 10182. Os testes verificam a fórmula decimal, não reprodução exata
da exibição do jogo. A política de comparação dos futuros filtros nos limites permanece
pendente; não presumir equivalência entre o decimal e o inteiro exibido.
