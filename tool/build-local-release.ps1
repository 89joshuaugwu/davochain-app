[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectDirectory = Split-Path $PSScriptRoot -Parent
$previousFlag = [Environment]::GetEnvironmentVariable('DAVOCHAIN_LOCAL_TEST_RELEASE', 'Process')
Push-Location $projectDirectory
try {
    $env:DAVOCHAIN_LOCAL_TEST_RELEASE = 'true'
    # Windows PowerShell can turn harmless native stderr warnings into errors.
    # Flutter's exit code remains the authoritative build result.
    $buildErrorPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & flutter build apk --release --dart-define=DAVOCHAIN_ENV=development
        $buildExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $buildErrorPreference
    }
    if ($buildExitCode -ne 0) { throw 'Local release APK build failed.' }
    Write-Host 'Optimized local-test APK: build/app/outputs/flutter-apk/app-release.apk'
    Write-Host 'Development signing identity; not for store publication.'
} finally {
    [Environment]::SetEnvironmentVariable('DAVOCHAIN_LOCAL_TEST_RELEASE', $previousFlag, 'Process')
    Pop-Location
}
