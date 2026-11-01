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
        '--project-name', 'zzzopt-catalog-test')
} else {
    # Apenas o Compose interpreta o arquivo privado; este script não o abre nem exibe.
    $composeArguments += @('--env-file', (Join-Path $projectRoot '.env'))
}

function Invoke-CatalogDocker {
    param([string[]]$DockerArguments, [string]$Stage)

    Write-Output $Stage
    # Não capturar/imprimir configurações resolvidas ou logs que possam revelar credenciais.
    & docker @composeArguments @DockerArguments *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Falha na etapa: $Stage. Confira o Docker Desktop e a configuração local sem expor segredos."
    }
}

Push-Location $projectRoot
try {
    Invoke-CatalogDocker -DockerArguments @('up', '--detach', '--wait', 'postgres') -Stage 'Iniciando PostgreSQL em Docker.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway') -Stage 'Aplicando e validando somente a V1; V2 permanece pendente.'
    if ($Test) {
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway') -Stage 'Verificando que repetir a inicialização mantém apenas a V1.'
    }
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Verificando estrutura vazia e histórico com somente a V1.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'base-stats-check') -Stage 'Verificando base crua e passiva com dados isolados e rollback.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Confirmando que os testes não deixaram dados no catálogo.'
    Write-Output 'Estrutura inicializada e verificada. V2 não executada; catálogo ainda vazio.'
} finally {
    if ($Test) {
        # Projeto exclusivo de teste, sem portas e com dados em tmpfs; não atinge o volume local.
        & docker @composeArguments down *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning 'Não foi possível encerrar o projeto temporário zzzopt-catalog-test.'
        }
    }
    Pop-Location
}
