# Referência do catálogo de conjuntos

O usuário forneceu 30 conjuntos e 60 descrições originais, uma de duas e outra de quatro peças.
Os IDs foram extraídos somente do texto das URLs enviadas, sem acessar o site; VM662:1 não é
parte dos IDs. Cabeçalhos repetidos não duplicam conjuntos e os nomes em inglês foram preservados.
Os dados estão na [V2](../db/migration/V2__seed_catalog.sql).

A [spec](business-rules.md) define aplicação e classificação dos efeitos. Esta referência
preserva os textos, máximos condicionais e dúvidas de combate. O [plano](architecture-and-roadmap.md)
descreve as tabelas e a análise declarativa; [estado](implementation-status.md) e
[operação](catalog-operations.md) registram carga e verificação.
IDs numéricos de conjuntos não reescrevem IDs string das fixtures atuais do core.

## Identidades e efeitos de 2 peças

| ID extraído | Conjunto | Descrição original de 2 peças | Contexto preparado |
|---:|---|---|---|
| 32800 | Astral Voice | ATK +10%. | SHEET |
| 32700 | Branch & Blade Song | CRIT DMG +16%. | SHEET |
| 33700 | Bunny in Wonderland | HP +10%. | SHEET |
| 31800 | Chaos Jazz | Anomaly Proficiency +30. | SHEET |
| 32300 | Chaotic Metal | Ether DMG +10%. | SHEET |
| 33300 | Dawn's Bloom | Increases Basic Attack DMG by 15%. | COMBAT |
| 32600 | Fanged Metal | Physical DMG +10%. | SHEET |
| 34100 | Feathered Fate | Anomaly Proficiency +30 | SHEET |
| 31300 | Freedom Blues | Anomaly Proficiency +30. | SHEET |
| 31400 | Hormone Punk | ATK +10%. | SHEET |
| 32200 | Inferno Metal | Fire DMG +10%. | SHEET |
| 33200 | King of the Summit | Increases Daze of attacks by 6%. | COMBAT |
| 33400 | Moonlight Lullaby | Energy Regen +20%. | SHEET |
| 33800 | Notes From the Chained | Ice DMG +10%. | SHEET |
| 33000 | Phaethon's Melody | Anomaly Mastery +8%. | SHEET |
| 32500 | Polar Metal | Ice DMG +10%. | SHEET |
| 31900 | Proto Punk | Shield Effect +15%. | COMBAT |
| 31100 | Puffer Electro | PEN Ratio +8%. | SHEET |
| 32900 | Shadow Harmony | The DMG of Aftershocks and Dash Attacks is increased by 15%. | COMBAT |
| 33600 | Shining Aria | Ether DMG +10%. | SHEET |
| 31200 | Shockstar Disco | Impact +6%. | SHEET |
| 31500 | Soul Rock | DEF +16%. | SHEET |
| 31600 | Swing Jazz | Energy Regen +20%. | SHEET |
| 34000 | The Sky Ablaze | Ether DMG +10%. | SHEET |
| 34200 | Thorned Rose | DEF +16% | SHEET |
| 32400 | Thunder Metal | Electric DMG +10%. | SHEET |
| 33500 | White Water Ballad | Physical DMG +10%. | SHEET |
| 31000 | Woodpecker Electro | CRIT Rate +8%. | SHEET |
| 33900 | Wuthering Salon | Wind DMG +10%. | SHEET |
| 33100 | Yunkui Tales | HP +10%. | SHEET |

São 26 efeitos de ficha estruturados e quatro de combate, sem classificação pendente.
Basic Attack, Aftershock, Dash Attack e Daze são métricas próprias; Daze +6% de King of the
Summit não equivale a Impacto +6%. Shield Effect +15% do Proto Punk foi definido pelo
usuário como efeito de combate.

Wuthering Salon acrescenta `WIND_DAMAGE_BONUS` em pontos percentuais ao catálogo carregado.
O enum `Stat` do `core` ainda não suporta esse código: sua integração é uma etapa futura,
sem convertê-lo para outro elemento ou omitir o bônus de uma ficha apresentada como completa.

## Máximos analisados de 4 peças

Os números abaixo dizem respeito **somente ao efeito de 4 peças**. O bônus de 2 peças será
avaliado separadamente quando o conjunto tiver ao menos quatro peças. Máximo condicional
não significa bônus permanentemente ativo ou aplicável a qualquer personagem.

| Conjunto | Máximo por parcela | Condições e limites preservados |
|---|---|---|
| Astral Voice | Dano de Quick Assist: +24% | Entrar usando Quick Assist; 3 acúmulos de Astral; 3 acúmulos; duração 15s; somente um efeito ativo na equipe |
| Branch & Blade Song | Dano crítico: +30%; Taxa crítica: +12% | Maestria de Anomalia do portador >=115; Membro da equipe aplica Freeze ou Shatter; duração 15s |
| Bunny in Wonderland | Dano da equipe: +18% | Portador Defense; EX Special do portador ou Defensive/Evasive Assist da equipe; 3 acúmulos; 3 acúmulos; duração 25s; efeitos de mesmo nome não acumulam; um acúmulo por vez |
| Chaos Jazz | Dano fogo: +15%; Dano elétrico: +15%; Dano EX Special: +20%; Dano de Assist Attack: +20% | Portador fora de campo ou nos 5s de persistência ao voltar; persistência 5s; intervalo de persistência 7,5s |
| Chaotic Metal | Dano crítico: +53% | 6 acúmulos gerados por dano adicional de Corruption da equipe; 6 acúmulos; acúmulos duram 8s |
| Dawn's Bloom | Dano de Basic Attack: +40% | Portador Attack; EX Special ou Ultimate nos últimos 25s; duração 25s |
| Fanged Metal | Dano: +35% | Equipe inflige Assault no alvo; duração 12s |
| Feathered Fate | Proficiência: +50; Dano de anomalia do atributo: +15% | Portador entra no campo ou é selecionado como ativo; Portador Lumiflux; Ativação ao entrar no campo; duração 15s |
| Freedom Blues | Redução de Anomaly Buildup RES do alvo: +20% | EX Special acerta o alvo; duração 8s; não acumula com outros efeitos do mesmo atributo |
| Hormone Punk | ATQ: +25% | Entrar em combate ou trocar para o portador; duração 10s; intervalo 20s |
| Inferno Metal | Taxa crítica: +28% | Acertar inimigo com Burning; duração 8s |
| King of the Summit | Dano crítico da equipe: +30% | Portador Stun; Usar EX Special ou Chain Attack; Taxa crítica do portador >=50%; duração 15s; efeitos de mesmo nome não acumulam |
| Moonlight Lullaby | Dano da equipe: +18% | Portador Support; Usar EX Special ou Ultimate; duração 25s; efeitos de mesmo nome não acumulam |
| Notes From the Chained | Proficiência: +48; Dano de anomalia de todos os atributos: +16%; Dano de Disorder: +16% | Portador ativa Abloom; Portador ativa Freeze; duração 30s |
| Phaethon's Melody | Proficiência: +45; Dano Éter: +25% | Qualquer membro da equipe usa EX Special; Outro membro da equipe, diferente do portador, usa EX Special; duração 8s |
| Polar Metal | Dano de Basic Attack: +40%; Dano de Dash Attack: +40% | Equipe inflige Freeze ou Shatter; duração 12s |
| Proto Punk | Dano da equipe: +15% | Qualquer membro da equipe ativa Defensive Assist ou Evasive Assist; duração 10s; efeitos de mesmo nome não acumulam |
| Puffer Electro | Dano de Ultimate: +20%; ATQ: +15% | Portador usa Ultimate; duração 12s |
| Shadow Harmony | ATQ: +12%; Taxa crítica: +12% | Acertar com Aftershock ou Dash Attack do atributo do portador; 3 acúmulos; 3 acúmulos; duração 15s; no máximo um acúmulo por uso de habilidade |
| Shining Aria | Proficiência: +36; Dano: +25% | Basic Attack do portador acerta inimigo; Algum inimigo no campo fica Stunned; duração 8s; duração 18s |
| Shockstar Disco | Daze: +20% | Basic Attack, Dash Attack ou Dodge Counter |
| Soul Rock | Redução de dano recebido: +40% | Portador recebe ataque inimigo e perde PV; duração 2,5s; intervalo 15s |
| Swing Jazz | Dano da equipe: +15% | Portador usa Chain Attack ou Ultimate; duração 12s; efeitos de mesmo nome não acumulam |
| The Sky Ablaze | Dano crítico: +30%; ATQ: +10% | Portador Ether; Portador usa EX Special ou Ultimate; duração 30s |
| Thorned Rose | Dano: +15%; Taxa crítica: +16% | DEF inicial do portador >=1800 |
| Thunder Metal | ATQ: +28% | Há inimigo em combate com Shocked |
| White Water Ballad | Taxa crítica: +20%; ATQ: +10% | Dentro de qualquer Ether Veil ou até 15s após sair; Portador Attack; Ativar ou estender Ether Veil e manter o bônus de 30s; Portador Attack ativa ou estende Ether Veil; duração 30s |
| Woodpecker Electro | ATQ: máximo pendente (hipótese 27%) | Críticos de Basic Attack, Dodge Counter ou EX Special; duração 6s |
| Wuthering Salon | Proficiência: +50; Dano: +18% | Usar EX Special e atingir 2 acúmulos; Portador ativa Windswept; 2 acúmulos; duração 40s |
| Yunkui Tales | Taxa crítica: +12%; Sheer DMG: +10% | Usar EX Special, Chain Attack ou Ultimate; 3 acúmulos; Manter 3 acúmulos do efeito de taxa crítica; 3 acúmulos; duração 15s |

### Classificações definidas

O usuário testou **The Sky Ablaze** no jogo e confirmou seu efeito de 4 peças como `COMBAT`.
Em seguida, definiu todos os efeitos ainda pendentes como `COMBAT`: os 4-PC de Branch & Blade
Song, Chaos Jazz, Chaotic Metal e Thorned Rose, além do 2-PC do Proto Punk. Essa decisão
substitui as pendências anteriores, sem afirmar que os demais foram testados individualmente.

Todos os 30 efeitos de 4 peças estão preparados como `COMBAT` e não modificam a ficha da v1.
Os máximos continuam condicionais, com parcelas e gatilhos preservados para a etapa de dano.

### Ambiguidades do máximo e da duração

- **Woodpecker Electro:** +9% ATQ e duração de 6s por habilidade. O texto não explicita um
  teto de acúmulos. Três bônus simultâneos, um por categoria de habilidade, dariam 27%, mas
  esse limite é hipótese a confirmar; `maximum` fica `null` e `hypothetical_maximum` fica 27.
- **Feathered Fate:** os 15s são citados na parcela Lumiflux; a abrangência sobre os +50 de
  Proficiência precisa de confirmação antes de simular a duração desse bônus.
- **Phaethon's Melody:** os 8s são explícitos na parcela de Proficiência; a abrangência sobre
  os +25% de dano Éter precisa de confirmação antes da simulação.

Outras distinções preservadas:

- Chaotic Metal chega a **53 pontos percentuais de dano crítico**: 20 + 6 × 5,5. A parcela
  de 20 é de combate e a parcela acumulada exige dano adicional de Corruption.
- Thorned Rose oferece **8 ou 16 pontos percentuais** de taxa crítica por patamar de DEF;
  o máximo usa o patamar 1800, sem somar os dois patamares para chegar a 24.
- White Water Ballad pode oferecer 20 pontos percentuais de taxa crítica somente com as duas
  parcelas ativas e portador Attack. O ATQ +10% tem a condição própria de ativar ou estender o véu.
- Bônus de atributo, habilidade e dano genérico ficam em parcelas distintas; não
  somá-los num único percentual nem transformar AP, Daze ou redução de dano em bônus genérico.
- Parcelas com gatilhos diferentes, como Abloom e Freeze em Notes From the Chained, permanecem
  independentes; o resumo não garante que todo personagem ative todas simultaneamente.

## Limites desta etapa

O [estado implementado](implementation-status.md) registra a aplicação da V2.
A integração dos atributos com a engine continua pendente; `core` e testes existentes foram
preservados. Somente efeitos de ficha poderão participar da v1;
efeitos de combate e sua execução dinâmica pertencem à etapa futura de dano.

Os números máximos são uma análise dos textos enviados, não benchmarks ou resultados
medidos no jogo. A validação da carga no PostgreSQL não valida a simulação de combate.
