# Estado implementado e evidências

A [spec](business-rules.md) define o comportamento esperado; este documento registra o que existe.
Não considerar o conteúdo do catálogo como suporte automático da engine a todos os personagens.

## Implementado

- Módulo Maven core, Java 25 e JUnit 6.
- Modelos imutáveis de inventário, peças, conjuntos e ficha.
- Montagem com BigDecimal; ATQ básico do motor somado à base ATQ.
- Bônus flat/percentuais, ativação por identidade/requisito e exclusão de COMBAT.
- Validação estrutural de peças e builds; referência da Aria sem arredondamento artificial.
- PostgreSQL/Flyway em Docker Compose; V1/V2/V3 aplicadas e verificadas em 2026-10-31.
- V3: 20 tabelas, ranks como texto com checks por domínio e enums Java distintos; I preserva ∞.
- Atributos de motor em w_engine_stats, por BASE/ADVANCED com modifier preservado.
- 63 personagens, 63 perfis, 632 atributos base e 124 totais de passiva.
- 102 motores, com 102 atributos básicos e 102 avançados.
- 30 conjuntos, 60 efeitos: 26 SHEET de duas peças, quatro COMBAT de duas peças e 30 COMBAT de quatro.

## Limitações e trabalho futuro

| Área | Estado real |
|---|---|
| Novos atributos | Wind, Sheer Force, adrenalina, Sharpness e Laceration ainda não estão todos no enum do core |
| Motores DEF | Banco preserva o atributo; WEngine atual só recebe ATQ básico |
| Passivas separadas | Banco separa; adaptador para o core ainda não existe |
| Rupture/Armorer | Fórmulas e conversão ainda não foram fornecidas; sem ficha completa validada |
| Catálogo → core | Sem carregador JPA ou adaptação completa |
| Busca/filtros | Não implementados |
| Spring Boot/API/autenticação | Não implementados |
| Jobs/limites/streaming | Não implementados |
| Poda/paralelismo/benchmarks | Não implementados, sem números publicados |
| Dano | Somente legado; fora da ficha da v1 |

## Evidências anteriores à reorganização SDD

- Última execução Java reportada: 41 testes aprovados; inclui testes do legado.
- Aplicação V2 em banco temporário e local aprovada em 2026-10-31, inclusive repetição do
  Flyway sem duplicar a carga.
- Checks SQL de V1, base/passivas, catálogo e carga permanecem preservados.
- A auditoria SDD foi estática, sem executar novamente testes ou banco.

A reorganização SDD é documental. Não representa nova execução dos testes de funcionalidade.
Sua validação deve conferir links, rastreabilidade e preservação de código, testes, dados e migrations.

Reorganização documental concluída e conferida em 2026-10-31: 18 regras, 17 perguntas abertas,
36 cenários de aceite e cinco critérios de processo. Links locais e referências a métodos de
teste foram verificados. Hashes dos 32 arquivos de código, testes, migrations, rascunhos,
Compose e scripts conferidos permaneceram iguais aos do início da etapa; as tabelas numéricas
das quatro referências foram preservadas. Nenhum reset ou teste de funcionalidade foi executado.

## Evidências da simplificação V3

- 41 testes Java aprovados, sem falhas/erros/ignorados; enums compilados com o core.
- Verificação isolada V1 → V2 → V3 aprovada; checks históricos executados sem edição.
- V3 aplicada no banco local sem reset, com comparação integral de linhas antes/depois e após
  repetição do Flyway. Mesmos personagens, bases/passivas, nomes, motores, conjuntos e efeitos.
- 204 parcelas de motor preservadas; domínios de ranks, modifier, papel, FKs e finitude verificados.
- Hashes dos 29 arquivos anteriores protegidos (migrations, checks, Java, scripts históricos,
  Compose de teste e pom) conferidos e inalterados. Compose principal só ganhou um check V3.
- O novo cenário de FK foi ajustado durante sua elaboração, antes de consolidar, para usar
  um atributo FLAT e isolar a FK do check de PERCENT. Nenhum teste anterior foi alterado.
- AC-37 a AC-40 verificados. Sem mudança do cálculo da ficha; WEngine continua sem DEF base.

## Histórico essencial

1. A proposta de distribuição livre de rolls deu lugar à combinação de discos reais na v1.
2. A primeira montagem da ficha e a referência da Aria foram implementadas.
3. O catálogo foi antecipado; a coleta separou base crua e passiva maximizada.
4. Um reset especificamente autorizado consolidou V1 (estrutura) e V2 (coleta).
5. A V2 recebeu as nove tabelas novas antes da primeira aplicação, sem alterar a V1.
6. A aplicação foi verificada; os rascunhos em db/drafts são somente históricos.
7. O usuário aprovou a reorganização SDD e autorizou reset do volume local durante estas
   etapas iniciais, condicionado à preservação dos dados de catálogo. Não houve novo reset
   nesta reorganização; as simplificações de ADR-06/ADR-07 foram aprovadas posteriormente.
