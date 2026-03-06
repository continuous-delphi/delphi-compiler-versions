# tests/pwsh/Generate-DelphiCompilerVersions-Pas.GoldenFile.Tests.ps1
#
# NOTE: This test will fail in a clean checkout until the generated file has
# been committed. Run the following command then commit the result:
#
#   pwsh tools/generate-delphi-compiler-versions-pas.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'DelphiCompilerVersions.pas golden file consistency' {

  It 'committed pas file matches generator output from canonical JSON' {

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $genPath  = Join-Path $repoRoot 'tools\generate-delphi-compiler-versions-pas.ps1'
    $dataPath = Join-Path $repoRoot 'data\delphi-compiler-versions.json'
    $pasPath  = Join-Path $repoRoot 'generated\DelphiCompilerVersions.pas'

    if (-not (Test-Path -LiteralPath $genPath))  { throw "Generator not found: $genPath" }
    if (-not (Test-Path -LiteralPath $dataPath)) { throw "Canonical JSON not found: $dataPath" }
    if (-not (Test-Path -LiteralPath $pasPath))  { throw "Committed pas file not found: $pasPath" }

    $tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-golden-' + [Guid]::NewGuid().ToString('N'))
    $tmpOut  = Join-Path $tmpRoot 'DelphiCompilerVersions.pas'

    try {
      New-Item -ItemType Directory -Path $tmpRoot | Out-Null

      # Generate fresh output
      & $genPath -DataPath $dataPath -OutPath $tmpOut -Force | Out-Null

      # Compare as raw bytes (strict comparison)
      $expected = [System.IO.File]::ReadAllBytes($tmpOut)
      $actual   = [System.IO.File]::ReadAllBytes($pasPath)

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
generated/DelphiCompilerVersions.pas is out of date.

Run:
  pwsh tools/generate-delphi-compiler-versions-pas.ps1

Then commit the updated pas file.
"@
    }
    finally {
      if (Test-Path -LiteralPath $tmpRoot) {
        Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
      }
    }
  }
}
