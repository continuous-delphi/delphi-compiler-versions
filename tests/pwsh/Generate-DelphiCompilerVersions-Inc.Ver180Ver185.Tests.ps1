# tests/pwsh/Generate-DelphiCompilerVersions-Inc.Ver180Ver185.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'DELPHI_COMPILER_VERSIONS.inc generator (VER180/VER185 compatibility)' {

  BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $genPath  = Join-Path $repoRoot 'tools\generate-delphi-compiler-versions-inc.ps1'
    $dataPath = Join-Path $repoRoot 'tests\pwsh\fixtures\delphi-compiler-versions.ver180-ver185.json'

    if (-not (Test-Path -LiteralPath $genPath))  { throw "Generator not found: $genPath" }
    if (-not (Test-Path -LiteralPath $dataPath)) { throw "Fixture not found: $dataPath" }

    $script:TmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-tests-v180-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TmpRoot | Out-Null
    $outPath = Join-Path $script:TmpRoot 'DELPHI_COMPILER_VERSIONS.inc'

    & $genPath -DataPath $dataPath -OutPath $outPath -Force | Out-Null

    $script:OutPath = $outPath
    $script:OutText = Get-Content -LiteralPath $outPath -Raw -Encoding UTF8
  }

  It 'wraps VER180 block in IFNDEF VER185 guard' {

    # Expect pattern:
    # {$IFNDEF VER185}
    # {$IFDEF VER180}
    #   ...
    # {$ENDIF}
    # {$ENDIF}

    $pattern = '\{\$IFNDEF VER185\}\s*\r?\n\s*\{\$IFDEF VER180\}'

    $script:OutText | Should -Match $pattern
  }

  It 'closes the VER180 IFNDEF VER185 guard properly' {

    # Match full guarded structure
    $match = [regex]::Match(
      $script:OutText,
      '\{\$IFNDEF VER185\}[\s\S]*?\{\$IFDEF VER180\}[\s\S]*?\{\$ENDIF\}[\s\S]*?\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $match.Success | Should -BeTrue
  }

  It 'does not wrap VER185 block in an IFNDEF guard' {

    # Ensure VER185 block is normal IFDEF without outer IFNDEF
    $script:OutText | Should -Match '\{\$IFDEF VER185\}'

    # Make sure no IFNDEF VER185 appears immediately before VER185 block
    $script:OutText | Should -Not -Match '\{\$IFNDEF VER185\}\s*\r?\n\s*\{\$IFDEF VER185\}'
  }

  It 'emits both compiler version 18 defines (shared major)' {

    # Both VER180 and VER185 produce CD_DELPHI_COMPILER_VERSION_18 (once per block),
    # and the forward-compat block repeats the last known version's defines (VER185),
    # adding a third occurrence.

    $matches = [regex]::Matches(
      $script:OutText,
      '\{\$DEFINE CD_DELPHI_COMPILER_VERSION_18\}'
    )

    $matches.Count | Should -Be 3
  }

  AfterAll {
    if ($script:TmpRoot -and (Test-Path -LiteralPath $script:TmpRoot)) {
        Remove-Item -LiteralPath $script:TmpRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
