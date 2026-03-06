# tests/pwsh/Generate-DelphiCompilerVersions-Pas.Ver180Ver185.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'DelphiCompilerVersions.pas generator (VER180/VER185 compatibility)' {

  BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $genPath  = Join-Path $repoRoot 'tools\generate-delphi-compiler-versions-pas.ps1'
    $dataPath = Join-Path $repoRoot 'tests\pwsh\fixtures\delphi-compiler-versions.pas-ver180-ver185.json'

    if (-not (Test-Path -LiteralPath $genPath))  { throw "Generator not found: $genPath" }
    if (-not (Test-Path -LiteralPath $dataPath)) { throw "Fixture not found: $dataPath" }

    $script:TmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-tests-v180-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TmpRoot | Out-Null
    $outPath = Join-Path $script:TmpRoot 'DelphiCompilerVersions.pas'

    & $genPath -DataPath $dataPath -OutPath $outPath -Force | Out-Null

    $script:OutPath = $outPath
    $script:OutText = Get-Content -LiteralPath $outPath -Raw -Encoding UTF8
  }

  It 'VER180 initialization block is wrapped in IFNDEF VER185' {

    # Generator emits {$IFDEF VER180}{$IFNDEF VER185} on a single line.
    # Delphi 2007 defines both VER180 and VER185; the IFNDEF guard ensures
    # that only VER185 (the more specific symbol) matches for Delphi 2007.
    $pattern = '\{\$IFDEF VER180\}\{\$IFNDEF VER185\}'

    $script:OutText | Should -Match $pattern
  }

  It 'VER180 IFNDEF VER185 guard closes with ENDIF ENDIF' {

    # Match the full guarded block: {$IFDEF VER180}{$IFNDEF VER185}...{$ENDIF}{$ENDIF}
    $match = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF VER180\}\{\$IFNDEF VER185\}[\s\S]*?\{\$ENDIF\}\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $match.Success | Should -BeTrue
  }

  It 'VER180 block assigns CurrentDelphiCompilerVersion' {

    # Verify the VER180 block (inside IFNDEF VER185) contains a
    # CurrentDelphiCompilerVersion assignment. The array index is determined by
    # the generator's sort order of the full canonical dataset.
    $match = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF VER180\}\{\$IFNDEF VER185\}[\s\S]*?\{\$ENDIF\}\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $match.Success | Should -BeTrue
    $match.Value | Should -Match 'CurrentDelphiCompilerVersion := DelphiVersions\[\d+\]'
  }

  It 'VER185 block appears after VER180 block in initialization' {

    # VER180 (numeric 180) sorts before VER185 (numeric 185); verify the
    # initialization blocks appear in that order in the output.
    $idxVer180 = $script:OutText.IndexOf('{$IFDEF VER180}{$IFNDEF VER185}')
    $idxVer185 = $script:OutText.IndexOf('{$IFDEF VER185}')

    $idxVer180 | Should -BeGreaterThan -1
    $idxVer185 | Should -BeGreaterThan -1
    $idxVer180 | Should -BeLessThan $idxVer185
  }

  It 'VER185 block has no IFNDEF guard' {

    # Ensure VER185 block is a plain IFDEF without an outer IFNDEF
    $script:OutText | Should -Match '\{\$IFDEF VER185\}'

    # Make sure IFNDEF VER185 does not appear on the line immediately before
    # the VER185 block (which would indicate an erroneous double-guard)
    $script:OutText | Should -Not -Match '\{\$IFNDEF VER185\}\s*\r?\n\s*\{\$IFDEF VER185\}'
  }

  It 'VER180 block sets IsCurrentDelphiCompilerVersionKnown := True' {

    $ver180Block = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF VER180\}\{\$IFNDEF VER185\}[\s\S]*?\{\$ENDIF\}\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $ver180Block.Success | Should -BeTrue
    $ver180Block.Value | Should -Match 'IsCurrentDelphiCompilerVersionKnown := True'
  }

  It 'VER185 block sets IsCurrentDelphiCompilerVersionKnown := True' {

    $ver185Block = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF VER185\}[\s\S]*?\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $ver185Block.Success | Should -BeTrue
    $ver185Block.Value | Should -Match 'IsCurrentDelphiCompilerVersionKnown := True'
  }

  AfterAll {
    if ($script:TmpRoot -and (Test-Path -LiteralPath $script:TmpRoot)) {
      Remove-Item -LiteralPath $script:TmpRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
