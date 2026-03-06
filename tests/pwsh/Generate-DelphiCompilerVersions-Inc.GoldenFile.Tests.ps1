# tests/pwsh/Generate-DelphiCompilerVersions-Inc.GoldenFile.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'DELPHI_COMPILER_VERSIONS.inc golden file consistency' {

  It 'committed include file matches generator output from canonical JSON' {

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $genPath  = Join-Path $repoRoot 'tools\generate-delphi-compiler-versions-inc.ps1'
    $dataPath = Join-Path $repoRoot 'data\delphi-compiler-versions.json'
    $incPath  = Join-Path $repoRoot 'generated\DELPHI_COMPILER_VERSIONS.inc'

    if (-not (Test-Path -LiteralPath $genPath))  { throw "Generator not found: $genPath" }
    if (-not (Test-Path -LiteralPath $dataPath)) { throw "Canonical JSON not found: $dataPath" }
    if (-not (Test-Path -LiteralPath $incPath))  { throw "Committed include file not found: $incPath" }

    $tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-golden-' + [Guid]::NewGuid().ToString('N'))
    $tmpOut  = Join-Path $tmpRoot 'DELPHI_COMPILER_VERSIONS.inc'

    try {
        New-Item -ItemType Directory -Path $tmpRoot | Out-Null

        # Generate fresh output
        & $genPath -DataPath $dataPath -OutPath $tmpOut -Force | Out-Null

        # Compare as raw bytes (strict comparison)
        $expected = [System.IO.File]::ReadAllBytes($tmpOut)
        $actual   = [System.IO.File]::ReadAllBytes($incPath)

        $same = $true

        if ($expected.Length -ne $actual.Length) {
            $same = $false
        }
        else {
            for ($i = 0; $i -lt $expected.Length; $i++) {
                if ($expected[$i] -ne $actual[$i]) {
                    $same = $false
                    break
                }
            }
        }

        $same | Should -BeTrue -Because @"
generated/DELPHI_COMPILER_VERSIONS.inc is out of date.

Run:
  pwsh tools/generate-delphi-compiler-versions-inc.ps1

Then commit the updated include file.
"@
    }
    finally {
        if (Test-Path -LiteralPath $tmpRoot) {
            Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
  }
}
