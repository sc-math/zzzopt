# ZZZ Build Optimizer

Projeto de um otimizador de combinações em Java, usando os equipamentos de **Zenless Zone Zero**
como problema de domínio. O objetivo é receber um inventário e restrições e enumerar as combinações
de seis peças que atendem aos filtros, apresentando seus atributos calculados.

O projeto está em desenvolvimento incremental. A primeira entrega é a engine de montagem da ficha;
busca combinatória, poda, paralelismo e serviço web compõem as próximas etapas.

## O problema

Com `nᵢ` candidatos em cada slot, o espaço bruto de busca é `n₁ × n₂ × … × n₆`. Restrições de
conjuntos, atributos principais e intervalos de atributos precisam reduzir o trabalho sem perder
combinações válidas. O volume dos resultados também faz parte do problema: a futura API deverá
transmiti-los progressivamente com consumo de memória controlado.

## Implementado

- Modelos imutáveis de inventário, equipamentos, conjuntos, personagem e motor.
- Montagem dos atributos com bônus flat e percentuais, distinguindo ficha de efeitos de combate.
- Ativação de conjuntos pela identidade e quantidade das peças, incluindo composições 2+2+2.
- Cálculo decimal com `BigDecimal` e testes unitários sobre uma build real de referência.
- `core` independente de frameworks web e de persistência.

**Tecnologias atuais:** Java 25, Maven Wrapper e JUnit 6.

## Em desenvolvimento

1. Busca de referência, filtros e geração de entradas reproduzíveis.
2. Poda, benchmarks e comparação de estratégias de paralelismo.
3. API Spring Boot, PostgreSQL, JPA, Flyway, Docker Compose e resultados em streaming.

O isolamento em worker Java e o uso de RabbitMQ serão avaliados com medições de carga.
Ainda não há API executável nem números de benchmark publicados.

## Executar os testes

Com JDK 25, entre na pasta `core` e execute no PowerShell:

```powershell
.\mvnw.cmd -B -ntp test
```

Os testes possuem descrições em português com `@DisplayName`. A [referência da Aria](docs/aria-reference.md)
documenta os dados utilizados e a diferença conhecida entre o cálculo decimal do PV e a exibição
do jogo. Os testes legados de dano permanecem separados da engine de ficha.

## Documentação

- [Regras de negócio](docs/business-rules.md)
- [Contratos e convenções de dados](docs/contracts.md)
- [Arquitetura, etapas e experimentos planejados](docs/architecture-and-roadmap.md)
- [Índice da documentação](docs/README.md)
