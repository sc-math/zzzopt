[CmdletBinding()]
param(
    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$composeArguments = @('compose', '--file', (Join-Path $projectRoot 'compose.yaml'))

if ($Test) {
    $composeArguments += @('--file', (Join-Path $projectRoot 'compose.test.yaml'),
        '--env-file', (Join-Path $projectRoot '.env.example'),
        '--project-name', 'zzzopt-catalog-v2-test')
} else {
    # Somente o Compose interpreta o arquivo privado; não ler ou exibir seu conteúdo.
    $composeArguments += @('--env-file', (Join-Path $projectRoot '.env'))
}

function Invoke-CatalogDocker {
    param([string[]]$DockerArguments, [string]$Stage)

    Write-Output $Stage
    # Não imprimir configurações resolvidas ou logs que possam revelar credenciais.
    & docker @composeArguments @DockerArguments *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Falha na etapa: $Stage. Nenhum volume local será apagado automaticamente."
    }
}

Push-Location $projectRoot
try {
    Invoke-CatalogDocker -DockerArguments @('up', '--detach', '--wait', 'postgres') -Stage 'Iniciando PostgreSQL em Docker.'
    if ($Test) {
        # Preserva integralmente os testes consolidados da fase de estrutura vazia.
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=1', 'migrate') -Stage 'Aplicando somente a V1 no banco temporário.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=1', 'migrate') -Stage 'Verificando repetição da inicialização da V1.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Verificando estrutura vazia e histórico da V1.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'base-stats-check') -Stage 'Verificando base crua e passivas com rollback.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Confirmando que a fixture não deixou dados.'
    }
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=2', 'migrate') -Stage 'Aplicando V2 com tabelas de motores, conjuntos e carga do catálogo.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'catalog-check') -Stage 'Verificando IDs, idiomas, variantes e integridade do catálogo.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'load-check') -Stage 'Verificando perfis, motores, conjuntos, unidades e correções confirmadas.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=2', 'migrate') -Stage 'Verificando que repetir Flyway não reaplica nem duplica a carga.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'load-check') -Stage 'Confirmando a carga após repetição e rollback dos testes.'
    Write-Output 'V1 e V2 aplicadas e verificadas: 63 personagens, 102 motores e 30 conjuntos.'
} finally {
    if ($Test) {
        # Projeto exclusivo de teste, sem portas e com tmpfs; não atinge o volume local.
        & docker @composeArguments down *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning 'Não foi possível encerrar o projeto temporário zzzopt-catalog-v2-test.'
        }
    }
    Pop-Location
}
