# tests/pwsh/Generate-DelphiCompilerVersions-Pas.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'DelphiCompilerVersions.pas generator' {

  BeforeAll {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

    $script:GenPath  = Join-Path $repoRoot 'tools\generate-delphi-compiler-versions-pas.ps1'
    $script:DataPath = Join-Path $repoRoot 'tests\pwsh\fixtures\delphi-compiler-versions.pas-min.json'

    if (-not (Test-Path -LiteralPath $script:GenPath))  { throw "Generator not found: $script:GenPath" }
    if (-not (Test-Path -LiteralPath $script:DataPath)) { throw "Test data not found: $script:DataPath" }

    $script:TmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('cd-delphi-versions-tests-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TmpRoot | Out-Null
    $outPath = Join-Path $script:TmpRoot 'DelphiCompilerVersions.pas'

    & $script:GenPath -DataPath $script:DataPath -OutPath $outPath -Force | Out-Null

    $script:OutPath = $outPath
    $script:OutText = Get-Content -LiteralPath $outPath -Raw -Encoding UTF8
  }

  # -------------------------------------------------------------------------
  # Output basics
  # -------------------------------------------------------------------------

  It 'writes the output file' {
    Test-Path -LiteralPath $script:OutPath | Should -BeTrue
  }

  It 'output filename is DelphiCompilerVersions.pas' {
    $script:OutPath | Should -Match 'DelphiCompilerVersions\.pas'
  }

  It 'writes CRLF line endings' {
    $rawBytes = [System.IO.File]::ReadAllBytes($script:OutPath)
    $text = [System.Text.Encoding]::UTF8.GetString($rawBytes)

    # Should contain CRLF
    $text | Should -Match "`r`n"

    # Should NOT contain lone LF
    $text -replace "`r`n", "" | Should -Not -Match "`n"

    # Should NOT contain lone CR
    $text -replace "`r`n", "" | Should -Not -Match "`r"
  }

  It 'does not write a UTF-8 BOM' {
    $rawBytes = [System.IO.File]::ReadAllBytes($script:OutPath)
    # UTF-8 BOM: EF BB BF
    if ($rawBytes.Length -ge 3) {
      ($rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF) | Should -BeFalse
    } else {
      $true | Should -BeTrue
    }
  }

  It 'contains only ASCII characters' {
    # Delphi 2 (VER90) has no Unicode support; any byte above 0x7F would be
    # misinterpreted. This guards against accidental insertion of non-ASCII
    # characters (em dashes, curly quotes, encoded identifiers, etc.).
    $rawBytes = [System.IO.File]::ReadAllBytes($script:OutPath)
    $nonAscii = $rawBytes | Where-Object { $_ -gt 0x7F }
    $nonAscii.Count | Should -Be 0
  }

  # -------------------------------------------------------------------------
  # Unit structure
  # -------------------------------------------------------------------------

  It 'unit declaration is DelphiCompilerVersions' {
    $script:OutText | Should -Match 'unit DelphiCompilerVersions;'
  }

  It 'contains interface and implementation sections' {
    $script:OutText | Should -Match '\binterface\b'
    $script:OutText | Should -Match '\bimplementation\b'
  }

  It 'contains initialization section' {
    $script:OutText | Should -Match '\binitialization\b'
  }

  # -------------------------------------------------------------------------
  # Metadata constants
  # -------------------------------------------------------------------------

  It 'emits schema and data version constants' {
    $script:OutText | Should -Match "CD_SCHEMA_VERSION = '1\.0\.0'"
    $script:OutText | Should -Match "CD_DATA_VERSION\s+=\s+'1\.0\.0'"
  }

  # -------------------------------------------------------------------------
  # Type declarations
  # -------------------------------------------------------------------------

  It 'declares TDelphiPlatform enum' {
    $script:OutText | Should -Match 'TDelphiPlatform = \('
  }

  It 'declares TDelphiBuildSystem enum' {
    $script:OutText | Should -Match 'TDelphiBuildSystem = \('
  }

  It 'declares TDelphiVersion record' {
    $script:OutText | Should -Match 'TDelphiVersion = record'
  }

  It 'declares PDelphiVersion pointer type' {
    $script:OutText | Should -Match 'PDelphiVersion = \^TDelphiVersion'
  }

  It 'record contains AliasesCsv field' {
    $script:OutText | Should -Match 'AliasesCsv: string'
  }

  # -------------------------------------------------------------------------
  # Version array
  # -------------------------------------------------------------------------

  It 'array bound matches fixture version count' {
    # Three entries in the fixture -> array[0..2]
    $script:OutText | Should -Match 'array\[0\.\.2\]'
  }

  It 'VER90 is the first array entry' {
    # Verify numeric sort: VER90 (9) must precede VER320 (320) and VER350 (350).
    # Alpha sort would put VER90 last; numeric sort puts it first.
    $firstVerDefine = [regex]::Match($script:OutText, "VerDefine: '(\w+)'").Groups[1].Value
    $firstVerDefine | Should -Be 'VER90'
  }

  It 'VER90 record has correct field values' {
    $script:OutText | Should -Match "VerDefine: 'VER90'"
    $script:OutText | Should -Match "CompilerVersion: '9\.0'"
    $script:OutText | Should -Match "ProductName: 'Delphi 2'"
    $script:OutText | Should -Match "PackageVersion: '20'"
  }

  It 'VER90 AliasesCsv uses semicolon delimiter' {
    $script:OutText | Should -Match "AliasesCsv: 'Delphi2;D2'"
  }

  It 'VER320 SupportedPlatforms set is non-empty' {
    $script:OutText | Should -Match 'SupportedPlatforms: \[\w+Target'
  }

  It 'VER320 SupportedBuildSystems includes MSBuildSystem' {
    $script:OutText | Should -Match 'SupportedBuildSystems: \[MSBuildSystem\]'
  }

  # -------------------------------------------------------------------------
  # Interface declarations
  # -------------------------------------------------------------------------

  It 'declares TryGetDelphiVersionByVerDefine with var parameter' {
    $script:OutText | Should -Match 'function TryGetDelphiVersionByVerDefine\(.*var AVersion'
  }

  It 'declares TryGetDelphiVersionByProductName with var parameter' {
    $script:OutText | Should -Match 'function TryGetDelphiVersionByProductName\(.*var AVersion'
  }

  It 'declares TryGetDelphiVersionByAlias with var parameter' {
    $script:OutText | Should -Match 'function TryGetDelphiVersionByAlias\(.*var AVersion'
  }

  It 'declares GetLatestDelphiVersion' {
    $script:OutText | Should -Match 'function GetLatestDelphiVersion: TDelphiVersion'
  }

  It 'declares CurrentDelphiCompilerVersion as var' {
    $m = [regex]::Match(
      $script:OutText,
      'var\b[\s\S]*?CurrentDelphiCompilerVersion: TDelphiVersion',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $m.Success | Should -BeTrue
  }

  It 'declares IsCurrentDelphiCompilerVersionKnown as var' {
    $script:OutText | Should -Match 'IsCurrentDelphiCompilerVersionKnown: Boolean'
  }

  # -------------------------------------------------------------------------
  # Implementation correctness
  # -------------------------------------------------------------------------

  It 'uses clause contains IFDEF UNICODE guard' {
    $script:OutText | Should -Match '\{\$IFDEF UNICODE\}'
  }

  It 'uses System.SysUtils inside UNICODE branch' {
    $m = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF UNICODE\}[\s\S]*?System\.SysUtils[\s\S]*?\{\$ELSE\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $m.Success | Should -BeTrue
  }

  It 'uses plain SysUtils in ELSE branch' {
    $m = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF UNICODE\}[\s\S]*?\{\$ELSE\}([\s\S]*?)\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $m.Success | Should -BeTrue
    $m.Groups[1].Value | Should -Match 'SysUtils'
    $m.Groups[1].Value | Should -Not -Match 'System\.SysUtils'
  }

  It 'uses CompareText not string.Compare' {
    $script:OutText | Should -Match 'CompareText'
    $script:OutText | Should -Not -Match 'string\.Compare'
    $script:OutText | Should -Not -Match '\bSameText\b'
  }

  It 'no Exit with return value' {
    $script:OutText | Should -Not -Match 'Exit\(True\)'
    $script:OutText | Should -Not -Match 'Exit\(False\)'
  }

  It 'CsvContainsToken is defined before TryGetDelphiVersionByAlias' {
    # CsvContainsToken is a private helper (no interface declaration); both
    # function bodies live in the implementation section. Search from there
    # so the TryGetDelphiVersionByAlias interface declaration is not counted.
    $implIdx  = $script:OutText.IndexOf('implementation')
    $idxCsv   = $script:OutText.IndexOf('function CsvContainsToken', $implIdx)
    $idxAlias = $script:OutText.IndexOf('function TryGetDelphiVersionByAlias', $implIdx)
    $idxCsv   | Should -BeGreaterThan -1
    $idxAlias | Should -BeGreaterThan -1
    $idxCsv   | Should -BeLessThan $idxAlias
  }

  It 'GetLatestDelphiVersion body uses High(DelphiVersions)' {
    $script:OutText | Should -Match 'Result := DelphiVersions\[High\(DelphiVersions\)\]'
  }

  # -------------------------------------------------------------------------
  # Initialization section
  # -------------------------------------------------------------------------

  It 'initialization assigns VER90 to DelphiVersions[0]' {
    $m = [regex]::Match(
      $script:OutText,
      '\{\$IFDEF VER90\}[\s\S]*?CurrentDelphiCompilerVersion := DelphiVersions\[0\][\s\S]*?\{\$ENDIF\}',
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $m.Success | Should -BeTrue
  }

  It 'initialization sets IsCurrentDelphiCompilerVersionKnown := True' {
    $script:OutText | Should -Match 'IsCurrentDelphiCompilerVersionKnown := True'
  }

  # -------------------------------------------------------------------------
  # Idempotency and Force flag
  # -------------------------------------------------------------------------

  It 'second run with identical data reports no changes' {
    $capturedOutput = & $script:GenPath -DataPath $script:DataPath -OutPath $script:OutPath 6>&1 | Out-String
    $capturedOutput | Should -Match 'No changes: '
  }

  It 'Force flag rewrites identical content' {
    & $script:GenPath -DataPath $script:DataPath -OutPath $script:OutPath -Force | Out-Null
    Test-Path -LiteralPath $script:OutPath | Should -BeTrue
  }

  AfterAll {
    if ($script:TmpRoot -and (Test-Path -LiteralPath $script:TmpRoot)) {
      Remove-Item -LiteralPath $script:TmpRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}


