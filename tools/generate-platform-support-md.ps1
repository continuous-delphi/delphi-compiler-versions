# tools/generate-platform-support-md.ps1
# Generates: generated/PlatformSupport.md
# Requires: PowerShell 7+
#
# Produces a markdown matrix of platforms (rows) vs Delphi versions (columns),
# newest version first. Cell values:
#   checkmark+superscript-plus  -- first version to support this platform
#   checkmark                   -- supported
#   checkmark+superscript-minus -- last version to support this platform (dropped after)
#   (blank)                     -- not supported

[CmdletBinding()]
param(
  [Parameter()]
  [string] $DataPath = (Join-Path $PSScriptRoot '..' 'data' 'delphi-compiler-versions.json'),

  [Parameter()]
  [string] $OutPath  = (Join-Path $PSScriptRoot '..' 'generated' 'PlatformSupport.md'),

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

function Get-DelphiProductShortName([string]$productName) {
  # Strips leading "Delphi " and keeps only the version identifier.
  # If a leading numeric (integer or decimal) is found after "Delphi ", everything
  # after it is stripped. If no leading numeric is found the remainder is kept as-is.
  #
  # Examples:
  #   "Delphi 2"            -> "D2"
  #   "Delphi 2005"         -> "D2005"
  #   "Delphi XE2"          -> "DXE2"
  #   "Delphi 10 Seattle"   -> "D10"
  #   "Delphi 10.1 Berlin"  -> "D10.1"
  #   "Delphi 11 Alexandria"-> "D11"

  $rest = $productName -replace '^Delphi ', ''

  if ($rest -match '^(\d+(\.\d+)?)') {
    return 'D' + $Matches[1]
  }

  return 'D' + $rest
}

# ---------------------------------------------------------------------------
# Load and validate data
# ---------------------------------------------------------------------------

Assert-FileExists $DataPath

$jsonText = Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8
$data     = $jsonText | ConvertFrom-Json

if (-not $data.schemaVersion) { throw 'Missing schemaVersion in JSON.' }
if (-not $data.dataVersion)   { throw 'Missing dataVersion in JSON.' }
if (-not $data.versions)      { throw 'Missing versions[] in JSON.' }

# Sort chronologically ascending (by VER number), then reverse for newest-first columns
$versionsAsc = @($data.versions | Sort-Object {
  if ($_.verDefine -match '^VER(\d+)$') { [int]$Matches[1] } else { 0 }
})
$versions     = @($versionsAsc[($versionsAsc.Count - 1)..0])  # newest first
$versionCount = $versions.Count

# ---------------------------------------------------------------------------
# Platform display order (rows)
# ---------------------------------------------------------------------------

$platformOrder = @(
  'Win32', 'Win64',
  'macOS32', 'macOS64', 'macOSARM64',
  'iOS', 'iOSSimulator',
  'Android32', 'Android64',
  'Linux64'
)

# Append any platforms present in data but not in the display order
$knownPlatforms = [System.Collections.Generic.HashSet[string]]::new()
foreach ($v in $versionsAsc) {
  foreach ($p in @($v.supportedPlatforms)) {
    [void]$knownPlatforms.Add([string]$p)
  }
}
foreach ($p in $platformOrder) { [void]$knownPlatforms.Remove($p) }
foreach ($p in ($knownPlatforms | Sort-Object)) { $platformOrder += $p }

# ---------------------------------------------------------------------------
# Determine first and last chronological index (in versionsAsc) per platform
# ---------------------------------------------------------------------------

$platformFirst = @{}  # index into versionsAsc of first version supporting platform
$platformLast  = @{}  # index into versionsAsc of last  version supporting platform

for ($i = 0; $i -lt $versionsAsc.Count; $i++) {
  foreach ($p in @($versionsAsc[$i].supportedPlatforms)) {
    $p = [string]$p
    if (-not $platformFirst.ContainsKey($p)) { $platformFirst[$p] = $i }
    $platformLast[$p] = $i
  }
}

# ---------------------------------------------------------------------------
# Symbol constants -- [string] cast avoids char arithmetic pitfalls
# ---------------------------------------------------------------------------

$symCheck      = [string][char]0x2713                           # checkmark
$symCheckPlus  = [string][char]0x2713 + [string][char]0x207A   # checkmark + superscript plus
$symCheckMinus = [string][char]0x2713 + [string][char]0x207B   # checkmark + superscript minus

# ---------------------------------------------------------------------------
# Cell symbol logic
# versionIndex is an index into $versions (newest-first display order).
# First/last detection uses $versionsAsc indices via verDefine lookup.
# ---------------------------------------------------------------------------

# Build a lookup from verDefine -> ascending index for first/last checks
$ascIndexByVerDefine = @{}
for ($i = 0; $i -lt $versionsAsc.Count; $i++) {
  $ascIndexByVerDefine[$versionsAsc[$i].verDefine] = $i
}

function Get-Cell([string]$platform, [int]$displayIndex) {
  $v         = $versions[$displayIndex]
  $supported = $false
  foreach ($p in @($v.supportedPlatforms)) {
    if ([string]$p -eq $platform) { $supported = $true; break }
  }

  if (-not $supported) { return '' }

  $ascIdx    = $ascIndexByVerDefine[$v.verDefine]
  $isFirst   = $platformFirst[$platform] -eq $ascIdx
  $isDropped = $platformLast[$platform]  -eq $ascIdx -and ($ascIdx -lt $versionsAsc.Count - 1)

  if ($isFirst)   { return $symCheckPlus }
  if ($isDropped) { return $symCheckMinus }
  return $symCheck
}

# ---------------------------------------------------------------------------
# Build markdown
# ---------------------------------------------------------------------------

$sb = [System.Text.StringBuilder]::new()
function Emit([string]$line = '') { [void]$sb.AppendLine($line) }

$genDate       = if ($data.meta -and $data.meta.generatedUtcDate) { $data.meta.generatedUtcDate } else { '' }
$dataVersion   = $data.dataVersion
$schemaVersion = $data.schemaVersion

Emit '<!-- Generated from data/delphi-compiler-versions.json -- do not edit manually -->'
Emit "<!-- SchemaVersion: $schemaVersion  DataVersion: $dataVersion  Generated: $genDate -->"
Emit ''
Emit '# Platform Support by Delphi Version'
Emit ''
Emit '| Symbol | Meaning |'
Emit '|--------|---------|'
Emit "| $symCheckPlus | First version to support this platform |"
Emit "| $symCheck  | Supported |"
Emit "| $symCheckMinus | Last version to support this platform |"
Emit '| (blank) | Not supported |'
Emit ''

# Header row -- platforms as rows, versions as columns (newest first)
$header    = '| Platform'
$separator = '|:---'
for ($i = 0; $i -lt $versionCount; $i++) {
  $short      = Get-DelphiProductShortName $versions[$i].productName
  $header    += " | $short"
  $separator += ' | :---:'
}
$header    += ' |'
$separator += ' |'
Emit $header
Emit $separator

# Data rows -- one row per platform
foreach ($platform in $platformOrder) {
  $row = "| $platform"
  for ($i = 0; $i -lt $versionCount; $i++) {
    $cell = Get-Cell $platform $i
    $row += " | $cell"
  }
  $row += ' |'
  Emit $row
}

Emit ''
Emit '---'
Emit ''
Emit "_Generated from $("`")data/delphi-compiler-versions.json$("`") -- "
Emit "dataVersion $("`")$dataVersion$("`"), schemaVersion $("`")$schemaVersion$("`")._"

# ---------------------------------------------------------------------------
# Write output (LF line endings -- markdown, not Delphi source)
# ---------------------------------------------------------------------------

Ensure-ParentDir $OutPath

$newText = $sb.ToString()
$newText = $newText -replace "`r`n", "`n"
$newText = $newText -replace "`r",   "`n"

if ((-not $Force) -and (Test-Path -LiteralPath $OutPath)) {
  $existing = Get-Content -LiteralPath $OutPath -Raw -Encoding UTF8
  if ($existing -eq $newText) {
    Write-Output "No changes: $OutPath"
    exit 0
  }
}

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($OutPath, $newText, $Utf8NoBom)

Write-Output "Wrote: $OutPath"
Write-Output "SchemaVersion: $($data.schemaVersion)  DataVersion: $($data.dataVersion)"
