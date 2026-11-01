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
        '--project-name', 'zzzopt-catalog-v3-test')
} else {
    # Apenas o Compose interpreta o arquivo privado. Não ler nem imprimir seu conteúdo.
    $composeArguments += @('--env-file', (Join-Path $projectRoot '.env'))
}

function Invoke-CatalogDocker {
    param([string[]]$DockerArguments, [string]$Stage)
    Write-Output $Stage
    & docker @composeArguments @DockerArguments *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Falha na etapa: $Stage. Nenhum volume será apagado automaticamente."
    }
}

function Read-CatalogRows {
    param([string[]]$PsqlArguments)
    # Somente consultas ao catálogo/histórico; stderr não é exibido e .env não é aberto.
    $catalogRows = @(& docker @composeArguments run --rm --no-deps catalog-check --no-psqlrc --set=ON_ERROR_STOP=1 --quiet --tuples-only --no-align --pset=pager=off @PsqlArguments 2> $null)
    if ($LASTEXITCODE -ne 0) {
        throw 'Não foi possível consultar os dados do catálogo; configuração e credenciais não serão exibidas.'
    }
    return $catalogRows
}

function Get-CatalogSnapshot {
    $snapshotRows = @(Read-CatalogRows -PsqlArguments @('--file=/checks/catalog-snapshot.sql'))
    if ($snapshotRows.Count -eq 0) {
        throw 'Snapshot vazio; aplicação interrompida.'
    }
    foreach ($snapshotRow in $snapshotRows) {
        if (-not $snapshotRow.StartsWith('{')) {
            throw 'Snapshot com formato inesperado; dados não serão exibidos.'
        }
    }
    # Comparação de todas as linhas, incluindo multiplicidade; nenhum dado é salvo em disco.
    return [string]::Join("`n", [string[]]($snapshotRows | Sort-Object -CaseSensitive))
}

Push-Location $projectRoot
try {
    Invoke-CatalogDocker -DockerArguments @('up', '--detach', '--wait', 'postgres') -Stage 'Iniciando PostgreSQL em Docker.'
    if ($Test) {
        # Checks consolidados continuam intactos e nas fases que verificam.
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=1', 'migrate') -Stage 'Aplicando V1 no banco temporário.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=1', 'migrate') -Stage 'Verificando repetição da fase V1.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Verificando V1 vazia.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'base-stats-check') -Stage 'Verificando base/passivas com rollback.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'schema-check') -Stage 'Confirmando que a fixture deixou V1 vazia.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=2', 'migrate') -Stage 'Aplicando V2 histórica.'
    }

    $versionRows = @(Read-CatalogRows -PsqlArguments @('--command', "SELECT max(version::INTEGER) FROM public.flyway_schema_history WHERE success AND version IS NOT NULL;"))
    $catalogVersion = 0
    if ($versionRows.Count -ne 1 -or -not [int]::TryParse($versionRows[0], [ref]$catalogVersion) -or $catalogVersion -notin @(2, 3)) {
        throw 'Esta rotina requer V2 ou V3 aplicada. Em banco novo, inicialize primeiro com Apply-Catalog.ps1.'
    }
    if ($catalogVersion -eq 2) {
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'catalog-check') -Stage 'Executando o teste consolidado do catálogo na fase V2.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'load-check') -Stage 'Executando o teste consolidado da carga V2.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=2', 'migrate') -Stage 'Verificando repetição da fase V2.'
        Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'load-check') -Stage 'Confirmando integridade após repetir V2.'
    }

    Write-Output 'Capturando somente os dados do catálogo em memória para comparação integral.'
    $snapshotBefore = Get-CatalogSnapshot
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=3', 'migrate') -Stage 'Aplicando V3 sem recriar volume.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'v3-check') -Stage 'Verificando V3, ranks, papéis, unidades e constraints.'
    $snapshotAfter = Get-CatalogSnapshot
    if (-not [string]::Equals($snapshotBefore, $snapshotAfter, [StringComparison]::Ordinal)) {
        throw 'Diferença entre os dados anteriores e posteriores à V3. Nenhum volume será apagado.'
    }

    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'flyway', '-target=3', 'migrate') -Stage 'Verificando repetição da V3 sem duplicar dados.'
    Invoke-CatalogDocker -DockerArguments @('run', '--rm', '--no-deps', 'v3-check') -Stage 'Repetindo checks V3 após rollback e validação Flyway.'
    $snapshotRepeated = Get-CatalogSnapshot
    if (-not [string]::Equals($snapshotBefore, $snapshotRepeated, [StringComparison]::Ordinal)) {
        throw 'Diferença nos dados após repetição da V3.'
    }
    Write-Output 'V3 verificada: 20 tabelas, 63 personagens, 102 motores, 30 conjuntos e 204 atributos de motor preservados.'
    Write-Output 'Comparação integral dos dados aprovada. Nenhum volume foi apagado.'
} finally {
    if ($Test) {
        # Projeto exclusivo, sem portas, dados em tmpfs; não atinge volume local.
        & docker @composeArguments down *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning 'Não foi possível encerrar o projeto temporário zzzopt-catalog-v3-test.'
        }
    }
    Pop-Location
}
