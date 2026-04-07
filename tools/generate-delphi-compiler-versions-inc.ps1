# tools/generate-delphi-compiler-versions-inc.ps1
# Generates: generated/DELPHI_COMPILER_VERSIONS.inc
# Requires: PowerShell 7+

[CmdletBinding()]
param(
  [Parameter()]
  [string] $DataPath = (Join-Path $PSScriptRoot '..\data\delphi-compiler-versions.json'),

  [Parameter()]
  [string] $OutPath  = (Join-Path $PSScriptRoot '..\generated\DELPHI_COMPILER_VERSIONS.inc'),

  [Parameter()]
  [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-FileExists([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "File not found: $Path"
  }
}

function Ensure-ParentDir([string]$FilePath) {
  $dir = Split-Path -Parent $FilePath
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }
}

function Normalize-VersionToken([string]$v) {
  # Used for schema/data version tokens only (e.g. "1.0.0" -> "1_0_0").
  # Preserves original casing so version-derived tokens remain unchanged.
  # Contrast with Normalize-Ident, which forces uppercase for compiler identifiers.
  return ($v -replace '[^0-9A-Za-z]+','_').Trim('_')
}

function Normalize-Ident([string]$s) {
  # Used for all compiler/capability identifier tokens (e.g. "macOS32" -> "MACOS32",
  # "10.2 Tokyo" -> "10_2_TOKYO"). Forces uppercase because Delphi $DEFINE names are
  # case-insensitive but convention is ALL_CAPS; also collapses any non-alphanumeric
  # run to a single underscore.
  # Contrast with Normalize-VersionToken, which preserves casing for version strings.
  $t = $s.ToUpperInvariant()
  $t = $t -replace '[^A-Z0-9]+','_'
  $t = $t.Trim('_')
  if ($t.Length -eq 0) { return $null }
  return $t
}

function Get-VerDigits([string]$verDefine) {
  if ($verDefine -match '^VER(\d+)$') { return $Matches[1] }
  return $null
}

function Get-CompilerVersionMajor([string]$compilerVersion) {
  if ([string]::IsNullOrWhiteSpace($compilerVersion)) { return $null }
  $s = $compilerVersion.Trim()
  $dot = $s.IndexOf('.')
  if ($dot -gt 0) { $s = $s.Substring(0, $dot) }
  $s = $s -replace '[^0-9]', ''
  if ($s.Length -eq 0) { return $null }
  return $s
}

function Get-PackageVersionToken([object]$packageVersion) {
  if ($null -eq $packageVersion) { return $null }
  $s = ([string]$packageVersion).Trim()
  if ($s.Length -eq 0) { return $null }
  $s = $s -replace '[^0-9]', ''
  if ($s.Length -eq 0) { return $null }
  return $s
}

function Get-DefinesForProductName([string]$productName) {
  $defs = New-Object System.Collections.Generic.List[string]
  $name = ($productName ?? '').Trim()
  if ($name.Length -eq 0) { return $defs }

  $rest = $name
  if ($name -match '^(Delphi)\s+(.+)$') {
    $rest = $Matches[2].Trim()
  }

  if ($rest -match '^(XE\d*)\b') {
    $xe = Normalize-Ident $Matches[1]
    if ($xe) { $defs.Add($xe) }
    return $defs
  }

  if ($rest -match '^(20\d{2})\b') {
    $yr = Normalize-Ident $Matches[1]
    if ($yr) { $defs.Add($yr) }
    return $defs
  }

  if ($rest -match '^(\d+)(\.(\d+))?\b(.*)$') {
    $major = $Matches[1]
    $minor = $Matches[3]
    $tail  = ($Matches[4] ?? '').Trim()

    if ([string]::IsNullOrWhiteSpace($minor)) {
      $defs.Add((Normalize-Ident $major))                  # "12"
    } else {
      $defs.Add((Normalize-Ident ($major + '_' + $minor))) # "10_4"
    }

    if (-not [string]::IsNullOrWhiteSpace($tail)) {
      $brand = $tail.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)[0]
      $brandTok = Normalize-Ident $brand
      if ($brandTok) { $defs.Add($brandTok) }
    }

    return $defs
  }

  $fallback = Normalize-Ident $rest
  if ($fallback) { $defs.Add($fallback) }
  return $defs
}

function Get-StringArray([object]$maybeArray) {
  # Returns @() if null; ensures strings
  if ($null -eq $maybeArray) { return @() }
  if ($maybeArray -is [System.Array]) { return @($maybeArray | ForEach-Object { [string]$_ }) }
  # ConvertFrom-Json sometimes gives singletons not as array; handle
  return @([string]$maybeArray)
}

function Find-Range([bool[]]$flags) {
  # flags ordered by version ascending
  # Returns hasSupport, minIndex, firstUnsupportedIndex (nullable)
  $min = -1
  for ($i=0; $i -lt $flags.Length; $i++) {
    if ($flags[$i]) { $min = $i; break }
  }
  if ($min -lt 0) { return @{ Has=$false; Min=-1; FirstOff=$null } }

  $firstOff = $null
  for ($i=$min+1; $i -lt $flags.Length; $i++) {
    if (-not $flags[$i]) { $firstOff = $i; break }
  }
  return @{ Has=$true; Min=$min; FirstOff=$firstOff }
}

Assert-FileExists $DataPath

$jsonText = Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8NoBOM
$data = $jsonText | ConvertFrom-Json

if (-not $data.schemaVersion) { throw 'Missing schemaVersion in JSON.' }
if (-not $data.dataVersion)   { throw 'Missing dataVersion in JSON.' }
if (-not $data.versions)      { throw 'Missing versions[] in JSON.' }

$schemaTok = Normalize-VersionToken $data.schemaVersion
$dataTok   = Normalize-VersionToken $data.dataVersion

$genDate = $null
if ($data.meta -and $data.meta.generatedUtcDate) { $genDate = $data.meta.generatedUtcDate }

$versions = @($data.versions | Sort-Object {
  $d = Get-VerDigits $_.verDefine
  if ($d) { [int]$d } else { 0 }
})

# Harden for singletons/unwrapped values
$versions = @($versions)
$versionCount = $versions.Length

# Delphi 2007 special case: VER185 defined, but VER180 also defined.
$hasVER185 = $false
for ($i=0; $i -lt $versionCount; $i++) {
  if ($versions[$i].verDefine -eq 'VER185') { $hasVER185 = $true; break }
}

$sb = New-Object System.Text.StringBuilder
function Emit([string]$line = '') { [void]$sb.AppendLine($line) }

function Get-MinTokenForIndex([int]$idx) {
  $toks = @(Get-DefinesForProductName ([string]$versions[$idx].productName))
  if ($toks.Length -gt 0) { return $toks[0] }
  return $null
}

Emit '(*-----------------------------------------------------------------------------'
Emit ' delphi-compiler-versions'
Emit
Emit ' Canonical Delphi compiler version mapping based on official VER### symbols.'
Emit ' Provides standardized symbols for use in {$IFDEF} and related conditional compilation.'
Emit ' Permissively licensed for unrestricted use in commercial and open-source projects.'
Emit
Emit ' Generated from: data/delphi-compiler-versions.json'
Emit ' Auto-generated file. Do not edit manually; update the canonical source instead.'
Emit
Emit ' Project repository:'
Emit ' https://github.com/continuous-delphi/delphi-compiler-versions'
Emit
Emit " Part of Continuous-Delphi: Strengthening Delphi's continued success"
Emit ' https://github.com/continuous-delphi'
Emit
Emit ' Compiler version data also used by the PowerShell toolchain discovery tool:'
Emit ' https://github.com/continuous-delphi/delphi-inspect'
Emit
Emit ' Copyright (c) 2026 Darian Miller'
Emit ' Licensed under the MIT License.'
Emit ' https://opensource.org/licenses/MIT'
Emit ' SPDX-License-Identifier: MIT'
Emit '-----------------------------------------------------------------------------*)'
Emit
Emit '{ ---------------------------------------------------------------------------'
Emit '  Metadata'
Emit '  --------------------------------------------------------------------------- }'
Emit
Emit ('{$DEFINE CD_DELPHI_SCHEMA_' + $schemaTok + '}')
Emit ('{$DEFINE CD_DELPHI_DATA_'   + $dataTok   + '}')
if ($genDate) {
  $genTok = Normalize-Ident ($genDate -replace '-', '_')
  if ($genTok) { Emit ('{$DEFINE CD_DELPHI_GENERATED_' + $genTok + '}') }
}
Emit
Emit '{ ---------------------------------------------------------------------------'
Emit '  Unknown version detection'
Emit '  - CD_DELPHI_VERSION_UNKNOWN is defined by default'
Emit '  - Any recognized VER### block will UNDEF it'
Emit '  - If still defined after all VER### checks, the forward-compat block'
Emit '    inherits defines from the latest known version'
Emit '  --------------------------------------------------------------------------- }'
Emit
Emit '{$DEFINE CD_DELPHI_VERSION_UNKNOWN}'
Emit

Emit '{ ---------------------------------------------------------------------------'
Emit '  Version defines'
Emit '  --------------------------------------------------------------------------- }'
Emit

for ($i=0; $i -lt $versionCount; $i++) {
  $v = $versions[$i]

  $verDefine = [string]$v.verDefine
  if ([string]::IsNullOrWhiteSpace($verDefine)) { continue }

  $digits = Get-VerDigits $verDefine
  if (-not $digits) { continue }

  $compilerVersion = [string]$v.compilerVersion
  $productName     = [string]$v.productName
  $packageVersion  = $v.packageVersion

  $cvMajor = Get-CompilerVersionMajor $compilerVersion
  $pkgTok  = Get-PackageVersionToken $packageVersion
  $tokens  = @(Get-DefinesForProductName $productName)

  Emit ('{ ' + $verDefine + ' - ' + $productName + ' - CompilerVersion ' + $compilerVersion + ' }')

  if ($hasVER185 -and $verDefine -eq 'VER180') {
    Emit '{$IFNDEF VER185}'
  }

  Emit ('{$IFDEF ' + $verDefine + '}')
  Emit '  {$UNDEF CD_DELPHI_VERSION_UNKNOWN}'

  for ($t=0; $t -lt $tokens.Length; $t++) {
    $tok = $tokens[$t]
    Emit ('  {$DEFINE CD_DELPHI_' + $tok + '}')
    Emit ('  {$DEFINE CD_DELPHI_' + $tok + '_OR_LATER}')
  }

  if ($cvMajor) {
    Emit ('  {$DEFINE CD_DELPHI_COMPILER_VERSION_' + $cvMajor + '}')
  }

  if ($pkgTok) {
    Emit ('  {$DEFINE CD_DELPHI_PACKAGE_VERSION_' + $pkgTok + '}')
  }

  Emit '{$ENDIF}'

  if ($hasVER185 -and $verDefine -eq 'VER180') {
    Emit '{$ENDIF}'
  }

  Emit
}

# ---------------- Forward compatibility block ----------------
# If CD_DELPHI_VERSION_UNKNOWN is still defined after all VER### checks, the
# compiler is a version newer than this file knows about.  We inherit the
# defines of the latest known version so that code written for that version
# continues to compile.  CD_DELPHI_VERSION_UNKNOWN is intentionally left
# defined so callers can detect the fallback if needed.

$last = $versions[$versionCount - 1]

$lastVerDefine       = [string]$last.verDefine
$lastCompilerVersion = [string]$last.compilerVersion
$lastProductName     = [string]$last.productName
$lastPackageVersion  = $last.packageVersion
$lastCvMajor         = Get-CompilerVersionMajor $lastCompilerVersion
$lastPkgTok          = Get-PackageVersionToken $lastPackageVersion
$lastTokens          = @(Get-DefinesForProductName $lastProductName)

Emit '{ ---------------------------------------------------------------------------'
Emit '  Forward compatibility'
Emit ('  Compiler not recognised -- inheriting defines of ' + $lastProductName + ' (' + $lastVerDefine + ')')
Emit '  CD_DELPHI_VERSION_UNKNOWN remains defined so callers can detect the fallback.'
Emit '  --------------------------------------------------------------------------- }'
Emit
Emit '{$IFDEF CD_DELPHI_VERSION_UNKNOWN}'

foreach ($tok in $lastTokens) {
  Emit ('  {$DEFINE CD_DELPHI_' + $tok + '}')
  Emit ('  {$DEFINE CD_DELPHI_' + $tok + '_OR_LATER}')
}

if ($lastCvMajor) {
  Emit ('  {$DEFINE CD_DELPHI_COMPILER_VERSION_' + $lastCvMajor + '}')
}

if ($lastPkgTok) {
  Emit ('  {$DEFINE CD_DELPHI_PACKAGE_VERSION_' + $lastPkgTok + '}')
}

Emit '{$ENDIF}'
Emit

# ---------------- _OR_LATER cascade ----------------
# Each version's _OR_LATER tokens are only set inside its own {$IFDEF VERxxx} block.
# This cascade propagates them downward so that, e.g., CD_DELPHI_2_OR_LATER is
# defined for any compiler from Delphi 2 onwards, not just when compiling on Delphi 2.
# Runs newest-to-oldest so each step can rely on the one above it already being set.

Emit '{ ---------------------------------------------------------------------------'
Emit '  _OR_LATER cascade'
Emit '  Propagates version tokens downward so CD_DELPHI_X_OR_LATER is defined for'
Emit '  all compilers at version X and above, not only the exact version X.'
Emit '  --------------------------------------------------------------------------- }'
Emit

for ($i = $versionCount - 1; $i -ge 1; $i--) {
  $curr  = $versions[$i]
  $prev  = $versions[$i - 1]

  $currToks = @(Get-DefinesForProductName ([string]$curr.productName))
  $prevToks = @(Get-DefinesForProductName ([string]$prev.productName))

  if ($currToks.Length -eq 0 -or $prevToks.Length -eq 0) { continue }

  # Trigger on the first (numeric/primary) token of the current version
  $trigger = 'CD_DELPHI_' + $currToks[0] + '_OR_LATER'

  Emit ('{$IFDEF ' + $trigger + '}')
  foreach ($tok in $prevToks) {
    Emit ('  {$DEFINE CD_DELPHI_' + $tok + '_OR_LATER}')
  }
  Emit '{$ENDIF}'
  Emit
}

# ---------------- Capabilities section (range guarded, optimistic for open-ended) ----------------

# Collect all platforms/buildsystems present in dataset
$allPlatforms = New-Object System.Collections.Generic.HashSet[string]
$allBuildSystems = New-Object System.Collections.Generic.HashSet[string]

for ($i=0; $i -lt $versionCount; $i++) {
  $v = $versions[$i]

  foreach ($p in (Get-StringArray $v.supportedPlatforms)) {
    $tok = Normalize-Ident $p
    if ($tok) { [void]$allPlatforms.Add($tok) }
  }

  foreach ($b in (Get-StringArray $v.supportedBuildSystems)) {
    $tok = Normalize-Ident $b
    if ($tok) { [void]$allBuildSystems.Add($tok) }
  }
}

Emit '{ ---------------------------------------------------------------------------'
Emit '  Capabilities'
Emit '  - Range-guarded using *_OR_LATER tokens to avoid repetition.'
Emit '  - Open-ended ranges are optimistic: we assume support continues in future versions'
Emit '    until a removal is recorded in the dataset.'
Emit '  --------------------------------------------------------------------------- }'
Emit

# Build system: MSBUILD
if ($allBuildSystems.Contains('MSBUILD')) {
  $flags = New-Object bool[] $versionCount
  for ($i=0; $i -lt $versionCount; $i++) {
    $bs = Get-StringArray $versions[$i].supportedBuildSystems
    $has = $false
    foreach ($b in $bs) {
      if ((Normalize-Ident $b) -eq 'MSBUILD') { $has = $true; break }
    }
    $flags[$i] = $has
  }

  $range = Find-Range $flags
  if ($range.Has) {
    $minTok = Get-MinTokenForIndex $range.Min
    if ($minTok) {
      Emit ('{$IFDEF CD_DELPHI_' + $minTok + '_OR_LATER}')

      if ($null -ne $range.FirstOff) {
        $offTok = Get-MinTokenForIndex $range.FirstOff
        if ($offTok) {
          Emit ('  {$IFNDEF CD_DELPHI_' + $offTok + '_OR_LATER}')
          Emit '    {$DEFINE CD_DELPHI_SUPPORTS_MSBUILD}'
          Emit '  {$ENDIF}'
        } else {
          # fallback: optimistic open ended
          Emit '  {$DEFINE CD_DELPHI_SUPPORTS_MSBUILD}'
        }
      } else {
        # optimistic open ended
        Emit '  {$DEFINE CD_DELPHI_SUPPORTS_MSBUILD}'
      }

      Emit '{$ENDIF}'
      Emit
    }
  }
}

# Platforms
$platformList = @($allPlatforms) | Sort-Object
foreach ($platTok in $platformList) {
  $flags = New-Object bool[] $versionCount
  for ($i=0; $i -lt $versionCount; $i++) {
    $ps = Get-StringArray $versions[$i].supportedPlatforms
    $has = $false
    foreach ($p in $ps) {
      if ((Normalize-Ident $p) -eq $platTok) { $has = $true; break }
    }
    $flags[$i] = $has
  }

  $range = Find-Range $flags
  if (-not $range.Has) { continue }

  $minTok = Get-MinTokenForIndex $range.Min
  if (-not $minTok) { continue }

  Emit ('{$IFDEF CD_DELPHI_' + $minTok + '_OR_LATER}')

  if ($null -ne $range.FirstOff) {
    $offTok = Get-MinTokenForIndex $range.FirstOff
    if ($offTok) {
      Emit ('  {$IFNDEF CD_DELPHI_' + $offTok + '_OR_LATER}')
      Emit ('    {$DEFINE CD_DELPHI_SUPPORTS_PLATFORM_' + $platTok + '}')
      Emit '  {$ENDIF}'
    } else {
      # fallback: optimistic open ended
      Emit ('  {$DEFINE CD_DELPHI_SUPPORTS_PLATFORM_' + $platTok + '}')
    }
  } else {
    # optimistic open ended
    Emit ('  {$DEFINE CD_DELPHI_SUPPORTS_PLATFORM_' + $platTok + '}')
  }

  Emit '{$ENDIF}'
  Emit
}

# Write output
Ensure-ParentDir $OutPath

# Normalize line endings to CRLF explicitly
$newText = $sb.ToString()

# Convert any existing line ending style to LF first, then force CRLF
$newText = $newText -replace "`r`n", "`n"
$newText = $newText -replace "`r", "`n"
$newText = $newText -replace "`n", "`r`n"

if ((-not $Force) -and (Test-Path -LiteralPath $OutPath)) {
  $existing = Get-Content -LiteralPath $OutPath -Raw -Encoding UTF8NoBOM
  if ($existing -eq $newText) {
    Write-Output "No changes: $OutPath"
    exit 0
  }
}

# Use UTF8 without BOM (cleaner for include files)
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutPath, $newText, $Utf8NoBom)

Write-Output "Wrote: $OutPath"
Write-Output ('SchemaVersion: ' + $data.schemaVersion + '  DataVersion: ' + $data.dataVersion)
