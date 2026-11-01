# Spec: regras de negócio

Este documento é a fonte normativa do comportamento aprovado do produto. Uma regra aqui
não significa que já esteja implementada; consultar o [estado verificado](implementation-status.md).
O [contrato de entrada e saída](contracts.md) complementa esta spec. O
[plano técnico](architecture-and-roadmap.md) explica a implementação, os
[ADRs](decisions.md) registram escolhas e a [matriz de aceite](acceptance-criteria.md)
liga regras a evidências. Perguntas abertas não são requisitos aprovados.

## Objetivo e escopo

### RF-01 — Enumerar builds elegíveis

Receber o inventário de discos do usuário, personagem, motor e filtros. Encontrar todas as
combinações válidas de seis peças dentro dos limites explícitos da execução e devolver os
atributos de ficha e a identificação das seis peças de cada build.

A v1 não calcula dano, score ou ranking. Uma build de atributos inferiores a outra ainda é
um resultado válido se passar nos filtros. Não eliminar peças distintas por produzirem a
mesma ficha. Uma execução interrompida não pode ser apresentada como enumeração completa.

### RF-02 — Condição dos personagens e motores

Considerar personagens no nível máximo e com passiva maximizada e motores no nível máximo.
Não modelar progressão por nível nem exigir o histórico dos rolls dos discos. Usar os valores
atuais das peças, inclusive parcialmente aprimoradas. Refinamento do motor não altera seus
atributos básicos neste recorte.

O catálogo descreve personagens, motores e conjuntos; não representa o inventário pessoal.
A base crua e os bônus totais da passiva são informações distintas. Efeitos de combate de
personagens e motores ficam fora da ficha da v1.

## Ficha e unidades

### RF-03 — Distinguir unidades

Atributos absolutos e percentuais são diferentes. Percentuais usam 55 para representar 55%.
Um percentual relativo à base não é um acréscimo em pontos percentuais a uma taxa.

No atributo avançado do motor, ATQ, PV, DEF, Impacto, recuperação de energia e Maestria são
percentuais relativos; Proficiência é absoluta; taxa crítica, dano crítico e taxa de
perfuração são acréscimos em pontos percentuais. Atributos básicos de ATQ/DEF são absolutos.
Não inferir a unidade pelo tamanho do número. Perfuração flat e taxa de perfuração são distintas.

O motor mantém um papel básico e um avançado, sem repetir parcelas do mesmo papel. O básico
altera a base e é absoluto; o avançado mantém sua unidade e incide na ficha. Unificar sua
representação não pode confundir esses papéis nem alterar os valores ou resultados.

### RF-04 — Compor a base e aplicar os bônus uma única vez

Para atributos sujeitos a percentuais relativos:

```text
Base composta = base crua do personagem
              + acréscimos da passiva que alteram a base
              + atributo básico correspondente do motor, quando fornecido

Ficha = Base composta × (1 + soma dos percentuais de ficha / 100)
      + soma dos acréscimos absolutos de ficha
```

Os bônus da passiva que alteram a base entram antes dos multiplicadores. Bônus percentuais
da passiva que modificam a ficha somam aos percentuais dos itens. Incrementos diretos em
taxas somam pontos percentuais, sem multiplicar a taxa base. Nenhuma parcela pode ser aplicada
duas vezes.

Os [dados do catálogo](catalog.md) distinguem base crua, acréscimos à base e modificadores
de ficha. Não presumir +75 ATQ para todos os personagens. A separação confirmada da Anby,
os percentuais da Sunna/Manato/Zhao e o acréscimo de PV da Yixuan devem ser preservados.

### RF-05 — Preservar precisão e não inventar tetos

Não impor teto automático de atributos, inclusive taxa crítica de 100% ou 200%.
Não arredondar ou ajustar valores para reproduzir uma exibição do jogo sem uma regra confirmada.

A [referência da Aria](aria-reference.md) preserva o cálculo decimal e a exibição informada
pelo usuário. A divergência de PV não autoriza alterar a fórmula nem introduzir tolerância.
A política de comparação dos filtros na fronteira continua aberta em Q-01.

### RF-06 — Preservar atributos e recursos distintos

Incluir bônus de dano elemental na ficha. Não restringir a representação dos atributos
somente pela classe do personagem.

Rupture usa adrenalina; recuperação de energia não aumenta o acúmulo de adrenalina.
Sheer Force é um atributo próprio; seu valor zero na origem não representa um cálculo
da build. Não presumir uma fórmula de ATQ/PV ou simular essa classe com 100% de perfuração.

Armorer usa Sharpness e possui Laceration DMG, distintos de energia e dano crítico normal.
A conversão de dano crítico normal em taxa crítica ainda depende de proporção, condições e
parcelas fornecidas pelo usuário. Não inventar essa fórmula.

Campo ausente, zero informado e atributo ainda não suportado são situações diferentes.
Não omitir informação necessária e apresentar a ficha como completa. A resposta pública
para dados incompletos ou mecânicas não suportadas está aberta em Q-06.

## Inventário

### RF-07 — Identidade das peças e composição

Cada disco informa `id`, `gear`, `set`, `rank`, `enhance`, `main` e `substats`.
O ID da peça é único dentro do inventário recebido, sem exigência de unicidade global.
Duas peças de atributos iguais e IDs diferentes continuam sendo duas peças distintas.

Uma build contém seis peças distintas, exatamente uma de cada slot de 1 a 6. A peça estar
equipada em outro personagem não é uma restrição da v1; esse vínculo não é obrigatório.

### RF-08 — Validação estrutural dos discos

Slots 1, 2 e 3 têm como atributo principal, respectivamente, PV absoluto, ATQ absoluto e DEF
absoluta. Uma peça tem no máximo quatro subatributos, sem repetir o mesmo tipo nem o tipo
do atributo principal. Flat e percentual do mesmo atributo são tipos distintos.

A faixa inicial suportada de aprimoramento é 0 a 15 e os ranks de disco são B, A e S.
Isso não afirma que todo tipo e valor seja possível em todos os slots/ranks. A tabela completa
de legalidade depende dos dados do jogo e permanece aberta em Q-05.

Itens inválidos não podem ser descartados silenciosamente. Informar a peça e o campo afetado
quando possível. A política de rejeição do pedido e agregação dos erros está aberta em Q-04.

## Conjuntos e filtros

### RF-09 — Ativar efeitos pela identidade do conjunto

Contar peças do mesmo conjunto. Uma peça de A e uma de B não ativam um bônus de duas peças,
mesmo quando seus efeitos são iguais. Aplicar cada efeito uma vez ao atingir o requisito,
sem reaplicá-lo para cada grupo de duas peças.

Ao atingir quatro peças, avaliar os requisitos de duas e quatro peças. Requisito de peças e
contexto do efeito são independentes: o modelo admite parcelas de ficha e combate com o mesmo
requisito. Somente efeitos de ficha participam do cálculo da v1.

Nos 30 conjuntos fornecidos, todos os 4-PC são de combate. Também são de combate os 2-PC de
Dawn's Bloom, King of the Summit, Shadow Harmony e Proto Punk; os outros 26 são de ficha.
Essa classificação não generaliza automaticamente conjuntos futuros. Preservar descrições,
condições e máximos condicionais para a futura etapa de dano; não aplicá-los como constantes.

### RF-10 — Selecionar filtros explicitamente

Permitir seleção opcional de conjuntos de quatro e duas peças, com alternativas:
quatro peças de A ou B combinadas com duas de C ou D. A composição 2+2+2 faz parte da v1,
com prioridade menor de implementação. A representação inequívoca e os casos sobrepostos
estão abertos em Q-02.

Permitir escolher o atributo principal dos slots 4, 5 e 6 e limites mínimos e máximos de
atributos. Máximo é opcional e só existe quando informado. Rejeitar mínimo maior que máximo.
Uma build acima do máximo informado é excluída; seu atributo não é reduzido ao máximo.

Não escolher prioridades obrigatórias pela classe. Slider de prioridade e ranking ficam
fora da v1; filtros obrigatórios não são substituídos por um score.

### RF-11 — Preservar todas as composições admitidas

Restrições de conjuntos e principais não podem causar perda de builds elegíveis.
Se o usuário exige somente quatro peças de A e não seleciona um conjunto de duas peças,
as duas peças restantes podem vir de outros conjuntos. Alternativas devem preservar a união
das composições admitidas. Não excluir candidatos por dominância de atributos.

## Catálogo

### RF-12 — Preservar identidade, idioma e origem

Preservar IDs numéricos fornecidos para personagens, motores e conjuntos. Nomes e traduções
não definem identidade. IDs das peças pessoais pertencem a outro domínio e continuam strings.
A representação pública da seleção de personagem/motor está aberta em Q-13.

Preservar o rank I e o símbolo de infinito de Pyrois, distintos dos ranks de disco.
Os ranks aceitos são A/S/I para personagens e B/A/S para motores, cada domínio validado
separadamente. Não aceitar um rank de outro domínio. Novo rank exige decisão explícita.
Preservar elementos variantes e sua relação com o básico sem presumir herança de bônus ou
fórmulas. Não inventar traduções, atributos, estágios de lançamento ou dados das collabs ausentes.
Dados de beta e nomes provisórios podem mudar; manter essa condição explícita.

A carga inicial usa os dados enviados manualmente pelo usuário. Não coletar automaticamente
dados do site mencionado. Os detalhes e correções estão nas referências de
[personagens](catalog.md), [motores](w-engines.md) e [conjuntos](disc-sets.md).

## Execuções e resultados

### RF-13 — Entregar resultados progressivamente

Transmitir builds incrementalmente em lotes sem acumular todos os resultados em memória.
Se o consumidor for lento, controlar a produção com buffers limitados, sem descarte silencioso.
Tamanho dos lotes, limite do buffer e política de conexão estão abertos em Q-09 e Q-10.

Cada resultado deve permitir identificar suas seis peças e conhecer seus atributos de ficha.
Não há ordenação por qualidade nem cálculo de dano na v1.

### RF-14 — Informar o término corretamente

Distinguir conclusão completa, cancelamento, falha e interrupção por limite de recurso.
Não apresentar uma execução interrompida como completa. Estados públicos, transições, motivos
e resolução das disputas entre término/cancelamento estão abertos em Q-08.

Um novo pedido poderá substituir outro conforme a regra ainda aberta em Q-07; não assumir
cancelamento global por usuário.

### RF-15 — Cancelar após desconexão detectada

Ao detectar desconexão do consumidor, solicitar cancelamento cooperativo e liberar recursos.
Perda isolada de pacote ou atraso recuperável não equivale automaticamente a desconexão.
Detecção e prazo de liberação dependem dos parâmetros ainda abertos em Q-09 e Q-10.

Não implementar replay, retomada por lote nem restauração das builds. Uma nova execução recalcula.
Uma interface futura poderá guardar configuração e inventário no navegador para reenviar;
isso não restaura o job anterior.

### RF-16 — Limitar concorrência e recursos

Permitir processamento para vários usuários, com limites por usuário e execução, incluindo
concorrência, tempo e volume de saída. Não ultrapassar um limite por causa de pedidos simultâneos.
Os valores e o comportamento de admissão estão abertos em Q-10.

Autenticação e autorização devem existir antes da exposição como serviço multiusuário público.
Acesso a execuções e operações permitidas precisam ser fechados em Q-11.

### RF-17 — Guardar somente o histórico necessário

Persistir registros/metadados das execuções, sem persistir resultados das builds na v1.
Não exigir inventário pessoal persistente. Campos, retenção e conteúdo dos registros estão
abertos em Q-12. Toda validação autoritativa e regra de negócio pertence ao backend.

## Fora da v1

RF-18: cálculo/classificação por dano, rotações e efeitos de combate; distribuição livre de rolls;
importação automática e scanner; interface elaborada; nuvem e Kubernetes; contêiner por job;
persistência de builds e replay. Não capturar tráfego nem ler memória do jogo.

## Perguntas abertas

Nenhuma resposta abaixo está presumida. Resolver a pergunta antes da tarefa dependente.

| ID | Pergunta |
|---|---|
| Q-01 | Os limites são inclusivos? Comparam decimal calculado ou exibição? Um intervalo pode informar somente máximo? |
| Q-02 | Como representar 4+2/2+2+2 e alternativas? Aceitar sobreposição do mesmo conjunto? Quais composições sem filtros? |
| Q-03 | Inventário vazio, slot sem candidatos e busca sem solução são erro ou conclusão com zero builds? |
| Q-04 | Um item inválido rejeita todo o pedido? Agregar todos os erros? Qual formato externo? |
| Q-05 | Quais principais/subatributos, valores e aprimoramentos são legais por slot e rank? |
| Q-06 | Qual resposta para dados incompletos ou personagens/mecânicas ainda não suportados? Quais fórmulas faltantes entram na v1? |
| Q-07 | Novo pedido substitui execução por usuário, personagem ou configuração? |
| Q-08 | Quais estados/transições/motivos, regras de cancelamento explícito, disputa com conclusão e reinício da aplicação? |
| Q-09 | O que ocorre se o stream nunca conectar, conectar tarde ou tiver mais de um consumidor? Qual timeout de desconexão? |
| Q-10 | Quais limites de entrada, tempo, concorrência, buffers e saída? Qual prazo de cancelamento e resposta ao atingir limites? |
| Q-11 | Quem consulta/cancela cada execução? Como identificar o usuário e responder a acesso não permitido? |
| Q-12 | Quais metadados, retenção e dados de diagnóstico são guardados, sem persistir builds/inventário? |
| Q-13 | Personagem/motor serão selecionados por ID ou nome? Qual envelope e quais tipos públicos de atributos? |
| Q-14 | Qual idioma padrão e fallback quando não houver tradução? |
| Q-15 | Qual regra de uso de motor de outra especialidade? |
| Q-16 | Qual referência de versão do catálogo vale para uma execução durante uma atualização? |
| Q-17 | Há garantia de ordem dos resultados ou apenas do conjunto de builds elegíveis? |
