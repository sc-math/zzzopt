# Regras de negócio

## 1. Objetivo da v1

Receber um inventário de discos e filtros, com personagem e motor fixos, e encontrar todas as
combinações válidas de seis discos dentro dos limites explícitos da execução. Cada resultado
identifica as seis peças e seus atributos finais de ficha.

A v1 não identifica a melhor build por dano. Distribuição livre de rolls é outra área futura;
o problema atual é a combinação de peças concretas do inventário. O scanner de outro jogo
foi utilizado somente como referência de estrutura de dados.

## 2. Catálogo e entrada do usuário

- O catálogo interno descreve personagens, motores e conjuntos. Não é um inventário pessoal.
- O inventário e os filtros são enviados pelo usuário em JSON.
- O personagem é considerado no nível máximo, com os acréscimos permanentes da passiva principal
  maximizada já incorporados à base. Não somar esses acréscimos novamente.
- O motor é considerado no nível máximo. Refinamento não participa do cálculo de atributos base
  neste recorte; efeitos de combate do motor não entram na ficha.
- Passivas e skills dependentes de condições de combate serão modeladas na etapa de dano.
- Classe e elemento são informações do personagem; não determinam filtros ou prioridades
  obrigatórios. Não presumir que toda uma classe precisa dos mesmos atributos.

## 3. Inventário e identidade das peças

- Cada disco informa `id`, `gear`, `set`, `rank`, `enhance`, `main` e `substats`.
- O ID pode ser gerado pelo usuário ou pelo gerador de entradas. No contrato atual, é uma string.
- O ID deve ser único dentro do inventário recebido, sem exigir unicidade global entre usuários.
- Duas peças com atributos idênticos e IDs diferentes continuam sendo duas peças distintas.
- Utilizar os valores atuais dos atributos. Não exigir rolls nem simular aprimoramentos futuros.
- Aceitar peças parcialmente aprimoradas, respeitadas as validações suportadas.
- Dados ausentes ou inválidos devem ser informados ao cliente, com identificação da peça e do
  campo quando possível. Não descartar peças inválidas silenciosamente.
- A peça estar equipada em outro personagem não é uma restrição da v1; não exigimos esse vínculo.
- Uma build possui seis peças distintas, exatamente uma de cada slot de 1 a 6.

## 4. Atributos e montagem da ficha

Para atributos sujeitos a bônus relativos à base:

```text
Ficha = Base × (1 + soma dos bônus percentuais / 100) + soma dos bônus flat
```

Para ATQ, a base inclui o ATQ base do personagem na condição acordada e o ATQ básico do motor.
Nos demais atributos, utilizar a base correspondente do personagem e os bônus suportados.
Incrementos diretos em taxas, como taxa crítica e dano crítico, são somados em pontos percentuais;
não tratá-los como multiplicadores da taxa base.

- Percentuais usam pontos percentuais: `55` significa `55%`, tanto nos dados do modelo atual
  quanto na ficha retornada pelo `core`. Não aceitar unidades ambíguas por inferência do valor.
- Atributos flat e percentuais são distintos, inclusive perfuração flat e taxa de perfuração.
- Incluir bônus de dano elemental na ficha, mesmo que também sejam utilizados futuramente no dano.
- O modelo não deve restringir os atributos da ficha com base na classe do personagem.
- Aplicar apenas efeitos de ficha; efeitos de combate não modificam os resultados da v1.
- A montagem deve ser reutilizável pela busca e pelo futuro cálculo de dano.

O `core` atual usa `BigDecimal` e preserva os decimais. Não existe regra geral de arredondamento
do jogo confirmada. Na [referência da Aria](aria-reference.md), o PV calculado é `10181.47`, enquanto
o usuário confirmou `10182` no jogo. O ATQ base 863 já inclui `788 + 3 × 25` da passiva; ela não
ganha PV nessa passiva. Não criar correções artificiais para encaixar a exibição observada.

**Pendente:** política de comparação nos limites dos futuros filtros e reprodução da exibição.
A tolerância de 2% dos testes legados de dano não é uma tolerância aprovada para a ficha ou filtros.

## 5. Conjuntos e efeitos

- Contar peças pela identidade do conjunto, nunca pela igualdade de seu efeito.
- Uma peça de A e uma de B não ativam um bônus de duas peças, mesmo que A e B concedam o mesmo bônus.
- Cada efeito pertence a um conjunto e informa quantidade necessária de peças e contexto.
- Contextos atuais: `SHEET` (ficha) e `COMBAT` (combate).
- O requisito de peças e o contexto são independentes: quatro peças também podem conceder bônus
  de ficha; não assumir que todo efeito de quatro peças é condicional.
- Ao atingir quatro peças, avaliar tanto os efeitos de duas quanto os de quatro peças.
- Cada efeito é aplicado uma vez ao atingir seu requisito, não uma vez a cada grupo de duas peças.
- Um bônus com parte fixa e parte condicional pode ter efeitos separados com o mesmo requisito.
- Efeitos de combate podem ter descrição sem fórmula implementada. Não interpretar descrições
  como código nem considerar que todos os efeitos futuros já estão modelados.

## 6. Filtros da busca

Requisitos acordados para a v1, ainda não implementados:

- Seleção opcional de conjuntos de quatro e duas peças.
- Alternativas aceitas: quatro peças de A **ou** B, combinadas com duas de C **ou** D.
- Composição alternativa `2+2+2`, com prioridade menor de implementação, mas dentro do escopo.
- Atributo principal opcional para cada um dos slots 4, 5 e 6.
- Atributos principais fixos: slot 1 PV flat; slot 2 ATQ flat; slot 3 DEF flat.
- Limite mínimo e, opcionalmente, máximo por atributo. Validar mínimo não maior que máximo.
- Só aplicar máximo quando informado pelo usuário. Não impor teto de taxa crítica de 100%,
  200% ou qualquer outro valor por classe ou por uma regra presumida do jogo.
- Máximo é uma condição de elegibilidade: uma build acima dele é excluída; seu valor não é reduzido.
- Sem slider de prioridade ou ranking na v1. Prioridades não substituem restrições obrigatórias.

Na pré-filtragem, remover peças incompatíveis com os atributos principais selecionados.
Só remover outros conjuntos quando isso preservar todas as composições permitidas. Por exemplo,
ao exigir apenas quatro peças de A, as duas peças restantes podem vir de outros conjuntos.
Selecionar alternativas também exige preservar a união das composições admitidas.

Não descartar builds válidas por terem atributos menores que outra build. Peças distintas podem
produzir fichas iguais e ainda assim constituir resultados distintos. A promessa de retornar todas
as builds impede aplicar eliminação por dominância como se fosse uma busca apenas da melhor.

## 7. Execuções, transmissão e histórico

Requisitos acordados para a aplicação web futura:

- Executar a busca em segundo plano, inicialmente no processo Java da aplicação.
- Transmitir resultados incrementalmente em lotes, sem acumular toda a busca em uma lista na RAM.
- Limitar buffers; se o consumidor for lento, controlar a produção sem crescimento ilimitado
  nem descarte silencioso de resultados que deveriam ser entregues.
- Identificar conclusão completa, cancelamento, falha e interrupção por limite de recurso.
  Uma busca interrompida não pode ser apresentada como enumeração completa.
- Impor limites por usuário e execução, inclusive concorrência, tempo e volume de saída.
  Valores numéricos ainda não foram definidos.
- Guardar registros/metadados de execução para histórico, não os resultados das builds.
- Não assumir persistência do inventário pessoal. Campos exatos e retenção do histórico estão pendentes.
- Quando a desconexão do consumidor for detectada, solicitar cancelamento cooperativo da busca
  e liberar recursos. Não confundir conclusão normal do stream com cancelamento.
- Perda isolada de pacote ou atraso recuperável não equivale automaticamente a desconexão.
- Detecção de desconexão pode depender de erros e timeouts; parâmetros serão definidos na implementação.
- Não implementar retenção de lotes para replay, retomada após reconexão ou restauração de resultados.
- Uma nova execução recalcula os resultados. No futuro, o frontend poderá guardar configuração
  e inventário no navegador para reenviar o pedido; isso não é uma restauração do job anterior.

O usuário pode ter vários pedidos, por agente ou mudança de filtro. Foi proposta a regra de que
um novo pedido substitui/cancela o anterior, mas o **escopo exato da substituição está pendente**:
por usuário, agente ou configuração/build. Não implementar cancelamento global por suposição.

## 8. Fora da v1

- Cálculo e classificação por dano, rotação e efeitos condicionais de combate.
- Distribuição livre de rolls como pool abstrato.
- Importação automática, scanner e reconhecimento de screenshots/OpenCV.
- Captura de tráfego e leitura de memória do jogo não fazem parte da solução.
- Interface elaborada, nuvem e Kubernetes.
- Contêiner dedicado criado dinamicamente para cada tarefa.
- Persistência de builds, replay e restauração de resultados de jobs anteriores.
