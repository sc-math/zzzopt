# Critérios de aceite e rastreabilidade

Fonte normativa: [spec](business-rules.md). Cada cenário abaixo distingue evidência existente,
cobertura parcial e teste ainda necessário. IDs de regra/aceite não afirmam que toda a regra
está implementada. Esta reorganização não executa novamente os testes.

## Evidências existentes

| Referência | Arquivo |
|---|---|
| BC | [BuildCalculatorTest](../core/src/test/java/dev/math/zzzopt/core/build/BuildCalculatorTest.java) |
| EV | [EquipmentValidationTest](../core/src/test/java/dev/math/zzzopt/core/equipment/EquipmentValidationTest.java) |
| AB | [agent-base-stats.sql](../db/checks/agent-base-stats.sql) |
| CAT | [catalog.sql](../db/checks/catalog.sql) |
| LOAD | [catalog-load.sql](../db/checks/catalog-load.sql) |
| SCHEMA | [schema.sql](../db/checks/schema.sql) |

Os testes de dano legados e SanityTest não comprovam a busca ou a API. A tolerância de dano
não se aplica à ficha/filtros. Nenhum teste consolidado pode ser adaptado sem autorização.

## Cenários de ficha e inventário

| Aceite | Regra | Dado | Resultado esperado | Evidência/status |
|---|---|---|---|---|
| AC-01 | RF-02, RF-03, RF-04, RF-05 | Referência Aria, motor e seis discos registrados | PV 10181,47; ATQ 2582,64; DEF 907,136; Maestria 253,68; Proficiência 400; demais valores da referência, sem bônus de combate | BC.assemblesAriaSheetWithoutCombatBonusesOrDisplayRounding; 13 casos parametrizados |
| AC-02 | RF-09 | Uma peça de cada um de seis conjuntos, todos com mesmo bônus 2-PC | Nenhum bônus 2-PC ativado | BC.identicalEffectsFromDifferentSetsDoNotSharePieceCounts |
| AC-03 | RF-09 | Duas peças de A/B/C com bônus fictícios 10/20/30 de Proficiência | Proficiência adicional 60 | BC.activatesThreeIndependentTwoPieceBonuses |
| AC-04 | RF-09 | Seis peças de conjunto fictício com SHEET 2-PC +5 CR, SHEET 4-PC +7 e COMBAT +100 | Acréscimo 12 CR, sem duplicar 2-PC e sem combate | BC.activatesTwoAndFourPieceSheetEffectsOnceAndIgnoresCombatPart; fixture genérica, não conjunto real |
| AC-05 | RF-05 | Taxa crítica base 195 e bônus 20 | Resultado 215, sem teto | BC.doesNotImposeACriticalRateCap; ainda não testa filtro |
| AC-06 | RF-07 | Duas peças idênticas com IDs diferentes | Inventário mantém as duas | EV.acceptsIdenticalPiecesWithDifferentIdsAndCurrentEnhancementValues; enumeração em AC-18 |
| AC-07 | RF-07 | Dois discos com o mesmo ID no inventário | Rejeitar IDs repetidos | EV.rejectsRepeatedInventoryIds |
| AC-08 | RF-07, RF-08 | Build incompleta, slots repetidos ou IDs repetidos | Rejeitar a build | EV.requiresSixDistinctSlotsAndSixDistinctPieces |
| AC-09 | RF-08 | Slot 0/7 ou aprimoramento -1/16 | Rejeitar valor fora da faixa inicial | EV.rejectsInvalidSlots e rejectsEnhancementOutsideTheInitialSupportedRange |
| AC-10 | RF-08 | Disco sem conjunto ou slot 1 com ATQ como principal | Rejeitar estrutura incompatível | EV.rejectsMissingSetAndIncompatibleFixedMainStat; rejeição dos outros slots fixos sem caso específico |
| AC-11 | RF-09, RF-12 | Conjunto ausente da referência do cálculo ou ID de conjunto duplicado | Rejeitar, identificando o disco quando desconhecido | BC.rejectsUnknownSetsWithTheAffectedDiscId e rejectsDuplicateCatalogIdsInsteadOfSelectingOneSilently |
| AC-12 | RF-04 | Repetir cálculo com mesmas entradas | Mesma ficha, sem acumular bônus ou alterar entradas | BC.repeatedCalculationsDoNotAccumulateBonusesOrChangeInputs |
| AC-13 | RF-04 | Coleções originais alteradas após criar inventário/disco/Stats | Objetos existentes preservados e coleções imutáveis | EV.inventoryAndDiscDefensivelyCopyTheirLists e statsDefensivelyCopyTheirMap; propriedade técnica de apoio |
| AC-14 | RF-09 | Duas peças cujo efeito 2-PC seja COMBAT | Não acrescentar esse efeito à ficha | Sem teste específico do cálculo de 2-PC COMBAT; LOAD verifica a classificação dos quatro efeitos reais |

## Catálogo e integração

| Aceite | Regra | Dado | Resultado esperado | Evidência/status |
|---|---|---|---|---|
| AC-15 | RF-04, RF-12 | Base crua Anby 583 ATQ/118 Impacto e passiva +75/+18 BASE | Base composta 658/136, sem alterar origem | AB recomposição; LOAD confere registros reais; adaptador banco/core ausente |
| AC-16 | RF-04 | Sunna: ATQ cru 675, +75 BASE e +21% ficha, sem itens/motor | ATQ 907,5, sem percentual embutido na base | LOAD confere origem/estágio, não cálculo integrado; teste da integração necessário |
| AC-17 | RF-03, RF-04 | Valores fictícios: DEF crua 100, motor DEF base 20 e DEF avançada +50% | DEF 180 antes de outros acréscimos | Sem implementação/teste; WEngine atual não representa DEF base |
| AC-19 | RF-12 | Carga manual fornecida | 63 IDs/nomes; Sunna 1491, Sunbringer 1601, Pyrois I/∞ e quatro relações variante/base preservados | CAT e LOAD; verificação estrutural, sem validar fatos do jogo externamente |
| AC-20 | RF-03, RF-12 | Motores Bravo e Grip corrigidos | Bravo ATQ 356/AP 60 FLAT; Grip ATQ 713/CR 24 pp | LOAD |
| AC-21 | RF-06 | Manato com adrenalina zero explícita; Claret/Sunbringer com Sharpness 1,5 e Laceration 150 | Preservar atributos distintos, sem criar energia nem +75 ATQ para Armorer | LOAD verifica registros selecionados; não implementa conversões |
| AC-22 | RF-09 | Os 30 conjuntos fornecidos | 26 SHEET 2-PC, quatro COMBAT 2-PC e todos os 30 efeitos 4-PC COMBAT | LOAD; não comprova o cálculo de cada conjunto |
| AC-23 | RF-06 | Campo obrigatório ausente ou atributo necessário ainda não suportado | Não apresentar silenciosamente uma ficha como completa | AB verifica ausência/zero; formato público bloqueado por Q-06 |
| AC-24 | RF-12 | Adicionar nome em outro idioma | Mesmo personagem/ID e atributos, nomes independentes | CAT; idioma padrão/fallback aguardam Q-14 |

## Busca e transmissão ainda não implementadas

| Aceite | Regra | Dado | Resultado esperado | Evidência/status |
|---|---|---|---|---|
| AC-18 | RF-01, RF-07 | Duas peças distintas elegíveis no slot 1 e uma nos demais, sem filtros restritivos | Duas builds; preservar ambas mesmo se fichas forem iguais | Sem teste da busca |
| AC-25 | RF-10 | Opções 4-PC A/B e 2-PC C/D; builds 4A+2D e 4E+2D | Aceitar a primeira e rejeitar a segunda | Sem implementação/teste; envelope e sobreposição em Q-02 |
| AC-26 | RF-11 | Exigir só quatro peças de A, sem conjunto 2-PC selecionado | Não excluir build por usar outros conjuntos nas duas posições restantes | Sem implementação/teste |
| AC-27 | RF-10 | Mínimo maior que máximo | Rejeitar filtro inconsistente | Sem implementação/teste; sem código HTTP presumido |
| AC-28 | RF-05, RF-10 | CR 215, máximo 200 informado | Excluir build sem transformar o valor em 200 | Sem implementação/teste; não depende de decidir igualdade na fronteira |
| AC-29 | RF-05, RF-10 | CR 215, nenhum máximo informado | Não excluir por teto presumido | Cálculo em AC-05; filtro sem teste |
| AC-30 | RF-01, RF-11 | Inventário pequeno, filtragem/poda contra enumeração de referência | Exatamente o mesmo conjunto de seis IDs das builds elegíveis | Sem referência/poda/teste; comparar resultados distintos, não apenas contagens |
| AC-31 | RF-13 | Consumidor lento e limite de buffer aprovado B | Produção respeita B sem acumular todos os resultados ou descartar silenciosamente | Sem implementação/teste; definição de B em Q-10 |
| AC-32 | RF-14 | Execução interrompida por limite aprovado | Sinalizar interrupção incompleta, sem conclusão completa | Sem implementação/teste; estados públicos em Q-08 |
| AC-33 | RF-15 | Desconexão detectada durante a busca | Solicitar cancelamento e liberar recursos no prazo aprovado | Sem implementação/teste; prazo/detecção em Q-09/Q-10 |
| AC-34 | RF-15 | Nova conexão após perda da execução anterior | Não prometer replay/restauração; novo cálculo é outra execução | Sem implementação/teste; protocolo em Q-09 |
| AC-35 | RF-16 | Dois pedidos simultâneos disputam a última vaga permitida | Não admitir ambos ultrapassando o limite | Sem implementação/teste; destino do pedido excedente em Q-10 |
| AC-36 | RF-17 | Consulta de histórico de execução encerrada | Disponibilizar metadados definidos, sem recuperar builds persistidas | Sem implementação/teste; campos e acesso em Q-11/Q-12 |

## Critérios bloqueados por decisões

Não há resultado esperado aprovado para igualdade nos limites (Q-01), composições sobrepostas
(Q-02), zero resultados (Q-03), rejeição/agregação HTTP (Q-04), regras completas de legalidade
(Q-05), resposta pública para perfil não suportado (Q-06), substituição/estados (Q-07/Q-08),
múltiplos consumidores (Q-09), política de excesso (Q-10), acesso por usuário (Q-11), retenção
(Q-12), seleção por nome/ID (Q-13), fallback (Q-14), compatibilidade (Q-15), versão do catálogo
(Q-16) e ordenação (Q-17). Acrescentar exemplos concretos depois das respostas, antes do código.

## Restrições e critérios de processo

| ID | Referência | Dado | Resultado esperado | Verificação |
|---|---|---|---|---|
| CP-01 | AGENTS.md; ADR-01 | Mudança de comportamento proposta | Spec aprovada, plano e tarefa com aceite precedem código | Revisão documental; não teste JUnit |
| CP-02 | AGENTS.md; ADR-10 | Teste consolidado falha | Investigar implementação; não editar teste sem autorização específica | Revisão do diff e autorizações |
| CP-03 | AGENTS.md | Execução de ferramentas/configuração | Não ler segredos nem imprimir variáveis/configuração resolvida | Revisão das ações; não executar comando proibido para testar a regra |
| CP-04 | ADR-05 | Reset local necessário e schema aprovado | Preservar IDs, nomes, valores, unidades, passivas e efeitos do catálogo completo | Comparação antes/depois e carga temporária; não apenas contagens |
| CP-05 | RF-18; ADR-02 | Etapa atual do projeto | Sem scanner, coleta de tráfego/memória, dano novo, nuvem ou worker não justificado | Revisão do escopo/diff |

CP-04 inclui preservação das fontes SQL/referências. Nesta etapa nenhum reset foi feito.
Para schema futuro, planejar teste de equivalência dos dados e pedir autorização específica
caso um teste consolidado precise mudar; a permissão de reset não concede essa autorização.

## Incremento aprovado: simplificação do schema

| Aceite | Regra | Dado | Resultado esperado | Evidência |
|---|---|---|---|---|
| AC-37 | RF-12; ADR-06 | Ranks por domínio | A/S/I em agente, B/A/S em motor; I/∞ preservado; rejeitar I em motor e B em agente | Enums Java e check V3 |
| AC-38 | RF-03/RF-04; ADR-07 | 102 motores com básico/avançado | 204 parcelas BASE/ADVANCED com os mesmos códigos, modifier e valores; sem repetição por papel | Migração e snapshot completo |
| AC-39 | RF-12; CP-04 | Catálogo local antes/depois da V3 | Mesmas linhas de personagens, nomes, bases, passivas, motores, conjuntos/efeitos; equivalência sem depender de contagens | Snapshot canônico no script |
| AC-40 | RF-03/RF-04 | BASE percentual, atributo básico inválido, papel repetido, valores negativos/não finitos ou FK ausente | Rejeitar; manter atributos avançados permitidos, incluindo soma de pontos percentuais | Check V3 transacional |

AC-37 a AC-40 aprovados em 2026-10-31: [catalog-v3.sql](../db/checks/catalog-v3.sql) e
[Simplify-Catalog.ps1](../scripts/Simplify-Catalog.ps1), com comparação integral em banco
temporário e local e repetição Flyway. Checks V1/V2 executados sem edição antes da V3.
Os enums Java foram compilados e os 41 testes existentes passaram. Nenhuma mudança de cálculo.
