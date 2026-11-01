# Operação técnica do catálogo

Estado da carga: [implementação](implementation-status.md). Dados de origem:
[personagens](catalog.md), [motores](w-engines.md), [conjuntos](disc-sets.md).
Decisões de schema e reset: [ADRs](decisions.md).

## Aplicar o catálogo completo

Requer Docker Desktop com motor Linux. Não exige PostgreSQL/Flyway instalados na máquina.

O usuário preenche .env com base em .env.example. Agentes não podem ler esse arquivo nem
exibir variáveis, configuração resolvida ou logs que revelem segredos. Somente o Compose
interpreta as credenciais; os scripts ocultam a saída do Docker e informam etapas.

```powershell
# Somente em banco novo, carregar primeiro a fase histórica V2:
.\scripts\Apply-Catalog.ps1
# Em banco com V2 ou V3, aplicar/validar o schema simplificado:
.\scripts\Simplify-Catalog.ps1
```

Aplica até V2, verifica o catálogo e repete Flyway para conferir que a carga não é duplicada.
Num banco já populado, valida o checksum e não executa novamente a migration aplicada.
Não recria o banco nem apaga volumes. Depois de V3, usar Simplify-Catalog; Apply-Catalog é
a rotina histórica de V2 e seus checks pressupõem as tabelas antigas.

Simplify-Catalog captura dados do catálogo em memória, aplica até V3, verifica o schema de
20 tabelas e compara todas as linhas antes/depois, normalizando os atributos do motor para
a mesma representação. As tabelas de ranks substituídas têm seus códigos/símbolos conferidos
na migration; os ranks das entidades permanecem na comparação. Repete Flyway e confere
novamente. Não imprime dados/credenciais nem altera V1/V2, e não apaga o volume.

O projeto Compose é zzzopt. O banco persiste em postgres-data, publica somente em 127.0.0.1
e usa POSTGRES_PORT (padrão 5432). Alterar credenciais de .env não modifica automaticamente
as credenciais de um volume já inicializado.

O padrão do serviço Flyway no Compose continua target=1; Apply-Catalog solicita target=2 e
Simplify-Catalog solicita target=3.
Não editar V1/V2 aplicadas sem uma reconsolidação especificamente definida e aprovada.

## Testar a transição completa em isolamento

```powershell
.\scripts\Simplify-Catalog.ps1 -Test
```

Usa .env.example com dados fictícios e o projeto zzzopt-catalog-v3-test, sem portas e com
PostgreSQL em tmpfs. Encerra o projeto temporário ao final, sem atingir o volume local.

A rotina verifica V1 vazia, executa a fixture de base/passivas e confirma rollback.
Depois aplica V2, executa os checks de catálogo/carga sem edição e repete Flyway.
Só então aplica V3 com comparação integral dos dados e os checks novos, incluindo repetição.
A rotina histórica Apply-Catalog.ps1 -Test continua disponível para a fotografia V2.

## Rotina histórica da fase V1

```powershell
.\scripts\Initialize-Catalog.ps1
.\scripts\Initialize-Catalog.ps1 -Test
```

Destinada exclusivamente à fase de estrutura vazia, não ao catálogo local já populado.
Seu teste usa o projeto zzzopt-catalog-test, .env.example, tmpfs e nenhuma porta.
Os checks exigem deliberadamente histórico contendo só V1 e tabelas vazias.
Não alterar esses testes para fazê-los aceitar a fase V2.

## Checks existentes

| Arquivo | Fase e propósito |
|---|---|
| [schema.sql](../db/checks/schema.sql) | Somente V1, estrutura vazia antes/depois da fixture |
| [agent-base-stats.sql](../db/checks/agent-base-stats.sql) | Base crua, passivas, unidades, integridade e ausência versus zero; rollback |
| [catalog.sql](../db/checks/catalog.sql) | IDs, nomes, rank I, variantes, tradução e integridade após a carga |
| [catalog-load.sql](../db/checks/catalog-load.sql) | Fotografia V2: duas migrations, 23 tabelas, quantidades, correções e contextos |
| [catalog-v3.sql](../db/checks/catalog-v3.sql) | V3: 20 tabelas, ranks fechados, 204 parcelas BASE/ADVANCED e constraints |
| [catalog-snapshot.sql](../db/checks/catalog-snapshot.sql) | Leitura canônica dos dados para comparação integral no script V3 |

Os testes usam descrições legíveis e não deixam dados fictícios. O check da carga fixa a
fotografia V2; uma nova migration precisa planejar sua verificação e qualquer adaptação
de teste depende de autorização específica. Não enfraquecer as asserções.

## Reconstrução nas etapas iniciais

O usuário autorizou apagar e reconstruir somente o volume Docker do banco local deste projeto
durante estas etapas iniciais. Personagens, motores, conjuntos, atributos, nomes, efeitos,
IDs e correções devem ser preservados. A autorização não é uma obrigação de resetar.

Antes de uma reconstrução necessária:
1. Definir a mudança de schema aprovada e seu critério de preservação.
2. Conferir a fonte de carga e os registros reais; conservar uma cópia recuperável do catálogo
   se houver dados locais além da fonte versionada, sem capturar/exibir credenciais.
3. Validar o schema/carga propostos em banco temporário e comparar dados, não apenas contagens.
4. Confirmar por metadados não sensíveis o projeto e o volume exatos; não usar remoção ampla.
5. Reconstruir somente esse banco e conferir identidades, valores, unidades e correções.

Na reorganização documental não houve reset ou alteração de migrations; a simplificação
posterior acrescentou V3 sem apagar o volume. A autorização não cobre outros
volumes, perda das fontes SQL/referências nem alteração de testes consolidados.
Depois das etapas iniciais, novos resets precisam de autorização apropriada ao contexto.

## Consulta de referência

```sql
SELECT a.id, n.name, a.rank_code, a.element_code, e.base_element_code,
       a.specialty_code, a.faction_code, a.release_stage
FROM catalog.agents a
JOIN catalog.agent_names n ON n.agent_id = a.id AND n.locale = 'en'
JOIN catalog.elements e ON e.code = a.element_code
ORDER BY a.id;
```
