# tools/generate-cd-delphi-compiler-versions-pas.ps1
# Generates: generated/DelphiCompilerVersions.pas
# Requires: PowerShell 7+
#
# Standalone generator: does not depend on tools/_lib.

[CmdletBinding()]
param(
  [Parameter()]
  [string] $DataPath = (Join-Path $PSScriptRoot '..\data\delphi-compiler-versions.json'),

  [Parameter()]
  [string] $OutPath  = (Join-Path $PSScriptRoot '..\generated\DelphiCompilerVersions.pas'),

  [Parameter()]
  [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-FileExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "File not found: $Path"
  }
}

function Ensure-ParentDir {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $FilePath
  )

  $dir = Split-Path -Parent $FilePath
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }
}

function Write-TextFileUtf8NoBom {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Path,

    [Parameter(Mandatory=$true)]
    [string] $Text
  )

  Ensure-ParentDir -FilePath $Path
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Get-CompilerVersionsData {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Path
  )

  Assert-FileExists -Path $Path

  $jsonText = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  $data = $jsonText | ConvertFrom-Json

  if (-not $data.schemaVersion) { throw 'Missing schemaVersion in JSON.' }
  if (-not $data.dataVersion)   { throw 'Missing dataVersion in JSON.' }
  if (-not $data.versions)      { throw 'Missing versions[] in JSON.' }

  # Ensure versions is always treated as an array (ConvertFrom-Json can return a scalar for single-item arrays).
  $data.versions = @($data.versions)

  return $data
}

function Pas-EnumName {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Prefix,

    [Parameter(Mandatory=$true)]
    [string] $Token
  )

  # Example: dpWin64, dbMSBuild
  # First character is capitalised so that the prefix boundary is visually clear
  # regardless of the original platform string casing (e.g. 'iOS' -> 'dpIOS',
  # 'macOS64' -> 'dpMacOS64').
  $safe = [regex]::Replace($Token, '[^0-9A-Za-z]+', '')
  if (-not $safe) { $safe = 'Unknown' }
  $safe = $safe[0].ToString().ToUpper() + $safe.Substring(1)
  return ($Prefix + $safe)
}

function Pas-Escape {
  [CmdletBinding()]
  param(
    [Parameter()]
    [AllowNull()]
    [string] $Value
  )

  if ($null -eq $Value) { return "''" }
  $s = [string]$Value
  $s = $s -replace '''', ''''''
  return ("'" + $s + "'")
}

function Join-AliasesCsv {
  [CmdletBinding()]
  param(
    [Parameter()]
    $Aliases
  )

  if ($null -eq $Aliases) { return '' }

  $list = @()
  foreach ($a in ($Aliases | ForEach-Object { $_ })) {
    if ($null -ne $a -and ([string]$a).Trim() -ne '') {
      $list += ([string]$a)
    }
  }

  # Use ';' as a simple delimiter for runtime consumption.
  return ($list -join ';')
}

$data = Get-CompilerVersionsData -Path $DataPath

# Collect unions for enums
$platforms = @()
$buildSystems = @()

foreach ($v in $data.versions) {
  foreach ($p in ($v.supportedPlatforms | ForEach-Object { $_ })) {
    if ($platforms -notcontains $p) { $platforms += $p }
  }
  foreach ($b in ($v.supportedBuildSystems | ForEach-Object { $_ })) {
    if ($buildSystems -notcontains $b) { $buildSystems += $b }
  }
}

# Ensure these remain arrays even if there is a single unique value.
$platforms = @($platforms | Sort-Object)
$buildSystems = @($buildSystems | Sort-Object)

# Sort versions by numeric part of VER### (VER90 must come before VER180, etc.)
$sorted = @(
  $data.versions | Sort-Object `
    @{ Expression = { if ($_.verDefine -match '^VER(\d+)$') { [int]$Matches[1] } else { [int]::MaxValue } } }, `
    verDefine
)

# Emit Pascal
$sb = New-Object System.Text.StringBuilder

$null = $sb.AppendLine('unit DelphiCompilerVersions;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('interface')
$null = $sb.AppendLine()
$null = $sb.AppendLine('type')

# Platform enum
$null = $sb.AppendLine('  TCDDelphiPlatform = (')
for ($i=0; $i -lt $platforms.Count; $i++) {
  $name = Pas-EnumName -Prefix 'dp' -Token $platforms[$i]
  $comma = if ($i -lt ($platforms.Count-1)) { ',' } else { '' }
  $null = $sb.AppendLine('    ' + $name + $comma)
}
$null = $sb.AppendLine('  );')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  TCDDelphiPlatforms = set of TCDDelphiPlatform;')
$null = $sb.AppendLine()

# Build system enum
$null = $sb.AppendLine('  TCDDelphiBuildSystem = (')
for ($i=0; $i -lt $buildSystems.Count; $i++) {
  $name = Pas-EnumName -Prefix 'db' -Token $buildSystems[$i]
  $comma = if ($i -lt ($buildSystems.Count-1)) { ',' } else { '' }
  $null = $sb.AppendLine('    ' + $name + $comma)
}
$null = $sb.AppendLine('  );')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  TCDDelphiBuildSystems = set of TCDDelphiBuildSystem;')
$null = $sb.AppendLine()

# Record
$null = $sb.AppendLine('  TCDDelphiVersion = record')
$null = $sb.AppendLine('    VerDefine: string;')
$null = $sb.AppendLine('    CompilerVersion: string;')
$null = $sb.AppendLine('    ProductName: string;')
$null = $sb.AppendLine('    PackageVersion: string;')
$null = $sb.AppendLine('    RegKeyRelativePath: string;')
$null = $sb.AppendLine('    SupportedPlatforms: TCDDelphiPlatforms;')
$null = $sb.AppendLine('    SupportedBuildSystems: TCDDelphiBuildSystems;')
$null = $sb.AppendLine('    AliasesCsv: string;')
$null = $sb.AppendLine('  end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  PCDDelphiVersion = ^TCDDelphiVersion;')
$null = $sb.AppendLine()

# Constants
$null = $sb.AppendLine('const')
$null = $sb.AppendLine('  CD_SCHEMA_VERSION = ' + (Pas-Escape $data.schemaVersion) + ';')
$null = $sb.AppendLine('  CD_DATA_VERSION   = ' + (Pas-Escape $data.dataVersion) + ';')
$null = $sb.AppendLine()

# Version array (use sorted count)
$verCount = $sorted.Count
$null = $sb.AppendLine('  CDDelphiVersions: array[0..' + ([string]($verCount-1)) + '] of TCDDelphiVersion =')
$null = $sb.AppendLine('  (')

for ($i=0; $i -lt $sorted.Count; $i++) {
  $v = $sorted[$i]

  # Ensure these are arrays even if single value
  $platItems = @()
  foreach ($p in ($v.supportedPlatforms | ForEach-Object { $_ })) {
    $platItems += (Pas-EnumName -Prefix 'dp' -Token $p)
  }
  $platItems = @($platItems | Sort-Object)

  $bsItems = @()
  foreach ($b in ($v.supportedBuildSystems | ForEach-Object { $_ })) {
    $bsItems += (Pas-EnumName -Prefix 'db' -Token $b)
  }
  $bsItems = @($bsItems | Sort-Object)

  $platSet = if ($platItems.Count -gt 0) { '[' + ($platItems -join ', ') + ']' } else { '[]' }
  $bsSet   = if ($bsItems.Count -gt 0) { '[' + ($bsItems -join ', ') + ']' } else { '[]' }

  $aliasesCsv = Join-AliasesCsv -Aliases $v.aliases

  $comma = if ($i -lt ($sorted.Count-1)) { ',' } else { '' }

  $null = $sb.AppendLine('    (')
  $null = $sb.AppendLine('      VerDefine: ' + (Pas-Escape $v.verDefine) + ';')
  $null = $sb.AppendLine('      CompilerVersion: ' + (Pas-Escape $v.compilerVersion) + ';')
  $null = $sb.AppendLine('      ProductName: ' + (Pas-Escape $v.productName) + ';')
  $null = $sb.AppendLine('      PackageVersion: ' + (Pas-Escape $v.packageVersion) + ';')
  $null = $sb.AppendLine('      RegKeyRelativePath: ' + (Pas-Escape $v.regKeyRelativePath) + ';')
  $null = $sb.AppendLine('      SupportedPlatforms: ' + $platSet + ';')
  $null = $sb.AppendLine('      SupportedBuildSystems: ' + $bsSet + ';')
  $null = $sb.AppendLine('      AliasesCsv: ' + (Pas-Escape $aliasesCsv) + ';')
  $null = $sb.AppendLine('    )' + $comma)
}

$null = $sb.AppendLine('  );')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CDTryGetVersionByVerDefine(const AVerDefine: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('function CDTryGetVersionByProductName(const AProductName: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('function CDTryGetVersionByAlias(const AAlias: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('function CDGetLatestVersion: TCDDelphiVersion;')
$null = $sb.AppendLine()
# CDCurrentCompilerVersion and CDCurrentCompilerVersionKnown are set in the
# initialization section via $IFDEF VERxxx chains; they are vars, not consts,
# because the value depends on the compiler processing this unit.
$null = $sb.AppendLine('var')
$null = $sb.AppendLine('  CDCurrentCompilerVersion: TCDDelphiVersion;')
$null = $sb.AppendLine('  CDCurrentCompilerVersionKnown: Boolean;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('implementation')
$null = $sb.AppendLine()
$null = $sb.AppendLine('uses')
# UNICODE is defined from Delphi 2009 (VER200) onward - the same version that
# introduced both UnicodeString and dotted unit names. Using $IFDEF UNICODE
# avoids $IF/$IFEND which Delphi 2-5 do not support even inside inactive branches.
$null = $sb.AppendLine('{$IFDEF UNICODE}')
$null = $sb.AppendLine('  System.SysUtils')
$null = $sb.AppendLine('{$ELSE}')
$null = $sb.AppendLine('  SysUtils')
$null = $sb.AppendLine('{$ENDIF}')
$null = $sb.AppendLine('  ;')
$null = $sb.AppendLine()
# TextEqualsIgnoreCase: CompareText is in SysUtils since Delphi 1 and is
# locale-independent ASCII comparison - correct for all identifiers used here.
# This avoids string.Compare (XE3+) keeping compatibility back to Delphi 2.
$null = $sb.AppendLine('function TextEqualsIgnoreCase(const A, B: string): Boolean;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := CompareText(A, B) = 0;')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CDTryGetVersionByVerDefine(const AVerDefine: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('var')
$null = $sb.AppendLine('  I: Integer;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := False;')
$null = $sb.AppendLine('  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do')
$null = $sb.AppendLine('  begin')
$null = $sb.AppendLine('    if TextEqualsIgnoreCase(CDDelphiVersions[I].VerDefine, AVerDefine) then')
$null = $sb.AppendLine('    begin')
$null = $sb.AppendLine('      AVersion := CDDelphiVersions[I];')
$null = $sb.AppendLine('      Result := True;')
$null = $sb.AppendLine('      Exit;')
$null = $sb.AppendLine('    end;')
$null = $sb.AppendLine('  end;')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CDTryGetVersionByProductName(const AProductName: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('var')
$null = $sb.AppendLine('  I: Integer;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := False;')
$null = $sb.AppendLine('  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do')
$null = $sb.AppendLine('  begin')
$null = $sb.AppendLine('    if TextEqualsIgnoreCase(CDDelphiVersions[I].ProductName, AProductName) then')
$null = $sb.AppendLine('    begin')
$null = $sb.AppendLine('      AVersion := CDDelphiVersions[I];')
$null = $sb.AppendLine('      Result := True;')
$null = $sb.AppendLine('      Exit;')
$null = $sb.AppendLine('    end;')
$null = $sb.AppendLine('  end;')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CsvContainsToken(const ACsv, AToken: string): Boolean;')
$null = $sb.AppendLine('var')
$null = $sb.AppendLine('  I, StartPos: Integer;')
$null = $sb.AppendLine('  Part: string;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := False;')
$null = $sb.AppendLine('  if (ACsv = '''') or (AToken = '''') then')
$null = $sb.AppendLine('    Result := False;')
$null = $sb.AppendLine('    Exit;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  StartPos := 1;')
$null = $sb.AppendLine('  for I := 1 to Length(ACsv) + 1 do')
$null = $sb.AppendLine('  begin')
$null = $sb.AppendLine('    if (I > Length(ACsv)) or (ACsv[I] = '';'') then')
$null = $sb.AppendLine('    begin')
$null = $sb.AppendLine('      Part := Trim(Copy(ACsv, StartPos, I - StartPos));')
$null = $sb.AppendLine('      if (Part <> '''') and TextEqualsIgnoreCase(Part, AToken) then')
$null = $sb.AppendLine('        Result := True;')
$null = $sb.AppendLine('        Exit;')
$null = $sb.AppendLine('      StartPos := I + 1;')
$null = $sb.AppendLine('    end;')
$null = $sb.AppendLine('  end;')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CDTryGetVersionByAlias(const AAlias: string; var AVersion: TCDDelphiVersion): Boolean;')
$null = $sb.AppendLine('var')
$null = $sb.AppendLine('  I: Integer;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := False;')
$null = $sb.AppendLine('  for I := Low(CDDelphiVersions) to High(CDDelphiVersions) do')
$null = $sb.AppendLine('  begin')
$null = $sb.AppendLine('    if CsvContainsToken(CDDelphiVersions[I].AliasesCsv, AAlias) then')
$null = $sb.AppendLine('    begin')
$null = $sb.AppendLine('      AVersion := CDDelphiVersions[I];')
$null = $sb.AppendLine('      Result := True;')
$null = $sb.AppendLine('      Exit;')
$null = $sb.AppendLine('    end;')
$null = $sb.AppendLine('  end;')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
$null = $sb.AppendLine('function CDGetLatestVersion: TCDDelphiVersion;')
$null = $sb.AppendLine('begin')
$null = $sb.AppendLine('  Result := CDDelphiVersions[High(CDDelphiVersions)];')
$null = $sb.AppendLine('end;')
$null = $sb.AppendLine()
# Emit initialization section: assign CDCurrentCompilerVersion via $IFDEF chain.
# CDCurrentCompilerVersionKnown stays False (default) when the compiler is not
# in the dataset. VER180 is guarded with IFNDEF VER185 because Delphi 2007
# defines both symbols; VER185 takes precedence.
$null = $sb.AppendLine('initialization')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER90}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[0];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER100}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[1];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER120}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[2];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER130}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[3];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER140}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[4];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER150}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[5];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER170}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[6];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER180}{$IFNDEF VER185}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[7];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}{$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER185}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[8];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER200}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[9];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER210}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[10];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER220}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[11];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER230}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[12];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER240}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[13];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER250}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[14];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER260}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[15];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER270}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[16];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER280}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[17];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER290}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[18];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER300}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[19];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER310}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[20];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER320}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[21];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER330}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[22];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER340}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[23];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER350}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[24];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER360}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[25];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('  {$IFDEF VER370}')
$null = $sb.AppendLine('    CDCurrentCompilerVersion := CDDelphiVersions[26];')
$null = $sb.AppendLine('    CDCurrentCompilerVersionKnown := True;')
$null = $sb.AppendLine('  {$ENDIF}')
$null = $sb.AppendLine()
$null = $sb.AppendLine('end.')

$newText = $sb.ToString()

# Normalise to CRLF regardless of the OS running the generator.
# .pas files in this repository are always CRLF (matches Delphi IDE convention).
$newText = $newText -replace "`r`n", "`n"
$newText = $newText -replace "`r",   "`n"
$newText = $newText -replace "`n",   "`r`n"

if ((-not $Force) -and (Test-Path -LiteralPath $OutPath)) {
  $existing = Get-Content -LiteralPath $OutPath -Raw -Encoding UTF8
  if ($existing -eq $newText) {
    Write-Host "No changes: $OutPath"
    exit 0
  }
}

Write-TextFileUtf8NoBom -Path $OutPath -Text $newText

Write-Host "Wrote: $OutPath"
Write-Host ('SchemaVersion: ' + $data.schemaVersion + '  DataVersion: ' + $data.dataVersion)
