# tools/tag-release.ps1
# Creates and pushes a vX.Y.Z release tag for delphi-compiler-versions.
# Requires: PowerShell 7+, git (on PATH)
#
# Usage:
#   pwsh tools/tag-release.ps1 -Version 1.0.0
#
# The release version is independent of dataVersion and schemaVersion.
# Those fields are embedded in the annotated tag message for traceability
# but are not validated against the Version argument.
#
# The script validates preconditions before touching git:
#   - Version argument matches X.Y.Z semver format
#   - Canonical data file exists and is valid JSON
#   - Working tree is clean (no uncommitted changes)
#   - Current branch matches the default branch on origin
#   - Tag does not already exist locally or on origin

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
  [Parameter(Mandatory=$true, HelpMessage='Semantic version to tag, e.g. 1.0.0')]
  [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
  [string] $Version,

  [Parameter(HelpMessage='Skip the branch check (use when hotfixing from a non-default branch)')]
  [switch] $SkipBranchCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Step([string]$Message) {
  Write-Output "  $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
  Write-Output "  ok  $Message" -ForegroundColor Green
}

function Fail([string]$Message) {
  Write-Output ""
  Write-Output "FAIL  $Message" -ForegroundColor Red
  Write-Output ""
  throw $Message
}

function Invoke-Git {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments)][string[]] $GitArgs)

  $result = & git @GitArgs 2>&1
  if ($LASTEXITCODE -ne 0) {
    Fail "git $($GitArgs -join ' ') failed (exit $LASTEXITCODE):`n$result"
  }
  return $result
}

# ---------------------------------------------------------------------------
# Resolve paths relative to the repo root (script is in tools/)
# ---------------------------------------------------------------------------

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$dataFile = Join-Path $repoRoot 'data' 'delphi-compiler-versions.json'
$tag      = "v$Version"

Write-Output ""
Write-Output "delphi-compiler-versions  tag-release" -ForegroundColor White
Write-Output "======================================" -ForegroundColor White
Write-Output "  Version : $Version"
Write-Output "  Tag     : $tag"
Write-Output "  Repo    : $repoRoot"
Write-Output ""

# ---------------------------------------------------------------------------
# Precondition 1: data file exists and is valid JSON
# ---------------------------------------------------------------------------

Write-Step "Checking data file..."

if (-not (Test-Path -LiteralPath $dataFile)) {
  Fail "Canonical data file not found: $dataFile"
}

try {
  $data = Get-Content -LiteralPath $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
  Fail "Failed to parse JSON from $dataFile`n$_"
}

Write-Ok "data file found and valid JSON"

# ---------------------------------------------------------------------------
# Build tag message - embeds dataVersion and schemaVersion for traceability
# ---------------------------------------------------------------------------

$tagMsg = "Release $tag (dataVersion $($data.dataVersion)  schemaVersion $($data.schemaVersion))"

# ---------------------------------------------------------------------------
# Precondition 2: git is available
# ---------------------------------------------------------------------------

Write-Step "Checking git..."

try {
  $gitVersion = & git --version 2>&1
  if ($LASTEXITCODE -ne 0) { throw }
} catch {
  Fail "git is not available on PATH."
}

Write-Ok "git found ($gitVersion)"

Push-Location $repoRoot
try {

  # -------------------------------------------------------------------------
  # Precondition 3: inside a git repository
  # -------------------------------------------------------------------------

  Write-Step "Checking git repository..."

  $null = & git rev-parse --git-dir 2>&1
  if ($LASTEXITCODE -ne 0) {
    Fail "Not inside a git repository: $repoRoot"
  }

  Write-Ok "inside git repository"

  # -------------------------------------------------------------------------
  # Precondition 4: current branch matches origin's default branch
  # -------------------------------------------------------------------------

  Write-Step "Checking branch..."

  $branch = (Invoke-Git rev-parse --abbrev-ref HEAD).Trim()

  # Derive the default branch from origin/HEAD (set by 'git remote set-head origin -a'
  # or automatically on clone). Falls back to 'main' if the ref is not set.
  $originHead = & git rev-parse --abbrev-ref origin/HEAD 2>$null
  $defaultBranch = if ($LASTEXITCODE -eq 0 -and $originHead) {
    $originHead.Trim() -replace '^origin/', ''
  } else {
    Write-Output "  warn  origin/HEAD not set; assuming default branch is 'main'" -ForegroundColor Yellow
    'main'
  }

  if (-not $SkipBranchCheck -and $branch -ne $defaultBranch) {
    Fail "Must be on '$defaultBranch' branch to tag a release (currently on '$branch').`n       Switch to $defaultBranch, or use -SkipBranchCheck to override (not recommended)."
  }

  if ($SkipBranchCheck -and $branch -ne $defaultBranch) {
    Write-Output "  warn  Not on '$defaultBranch' (on '$branch'); -SkipBranchCheck override active" -ForegroundColor Yellow
  } else {
    Write-Ok "on branch '$defaultBranch'"
  }

  # -------------------------------------------------------------------------
  # Precondition 5: working tree is clean
  # -------------------------------------------------------------------------

  Write-Step "Checking working tree..."

  $status = Invoke-Git status --porcelain
  if ($status) {
    Fail "Working tree is not clean. Commit or stash all changes before tagging.`n`n$status"
  }

  Write-Ok "working tree is clean"

  # -------------------------------------------------------------------------
  # Precondition 6: origin remote exists
  # -------------------------------------------------------------------------

  Write-Step "Checking for origin remote..."

  $remotes = (Invoke-Git remote).Trim().Split([Environment]::NewLine)
  if ($remotes -notcontains 'origin') {
    Fail "Remote 'origin' not found. Add it or run this script in a clone with an origin remote."
  }

  Write-Ok "origin remote found"

  # -------------------------------------------------------------------------
  # Fetch tags from origin so the local tag list is current
  # -------------------------------------------------------------------------

  Write-Step "Fetching tags from origin..."
  Invoke-Git fetch --tags origin | Out-Null
  Write-Ok "tags fetched"

  # -------------------------------------------------------------------------
  # Precondition 7: local HEAD is not behind origin/<defaultBranch>
  # -------------------------------------------------------------------------

  Write-Step "Checking HEAD is up-to-date with origin/$defaultBranch..."

  $localRev  = (Invoke-Git rev-parse HEAD).Trim()
  $remoteRev = (Invoke-Git rev-parse "origin/$defaultBranch").Trim()

  if ($localRev -ne $remoteRev) {
    $behind = (Invoke-Git rev-list --count "HEAD..origin/$defaultBranch").Trim()
    $ahead  = (Invoke-Git rev-list --count "origin/$defaultBranch..HEAD").Trim()

    if ([int]$behind -gt 0 -and [int]$ahead -eq 0) {
      Fail "Local HEAD is $behind commit(s) behind origin/$defaultBranch. Run 'git pull' before tagging."
    } elseif ([int]$ahead -gt 0 -and [int]$behind -eq 0) {
      Fail "Local HEAD is $ahead commit(s) ahead of origin/$defaultBranch. Push your changes before tagging."
    } else {
      Fail "Local HEAD has diverged from origin/$defaultBranch ($ahead ahead, $behind behind). Reconcile before tagging."
    }
  }

  Write-Ok "HEAD is up-to-date with origin/$defaultBranch"

  # -------------------------------------------------------------------------
  # Precondition 8: tag does not already exist (local or origin)
  # -------------------------------------------------------------------------

  Write-Step "Checking for existing tag..."

  & git show-ref --tags --verify --quiet "refs/tags/$tag" 2>$null
  if ($LASTEXITCODE -eq 0) {
    Fail "Tag '$tag' already exists (local or origin).`n       To delete locally:  git tag -d $tag`n       To delete on origin: git push origin --delete $tag"
  }

  Write-Ok "tag '$tag' does not exist"

  # -------------------------------------------------------------------------
  # All preconditions passed - confirm and tag
  # -------------------------------------------------------------------------

  Write-Output ""
  Write-Output "All checks passed." -ForegroundColor Green
  Write-Output ""

  if ($PSCmdlet.ShouldProcess(
        "origin  (tag: $tag  message: '$tagMsg')",
        "Create annotated tag and push")) {

    try {

      Write-Step "Creating tag $tag..."
      Invoke-Git tag -a $tag -m $tagMsg
      Write-Ok "tag created"

      Write-Step "Pushing tag to origin..."
      Invoke-Git push origin $tag | Out-Null
      Write-Ok "tag pushed"

      Write-Output ""
      Write-Output "Released: $tag" -ForegroundColor Green
      Write-Output "The GitHub Actions release workflow should run for this tag." -ForegroundColor Green
      Write-Output ""

    } catch {

      Write-Output ""
      Write-Output "ERROR: Tag/push failed." -ForegroundColor Red
      Write-Output $_ -ForegroundColor DarkRed
      Write-Output ""
      Write-Output "Partial failure - check the state and clean up if needed:" -ForegroundColor Yellow

      & git show-ref --tags --verify --quiet "refs/tags/$tag" 2>$null
      if ($LASTEXITCODE -eq 0) {
        Write-Output "  Local tag exists. If the push failed, delete it with:" -ForegroundColor Yellow
        Write-Output "    git tag -d $tag" -ForegroundColor Yellow
      }

      Write-Output "  Verify origin does not have a partial push:" -ForegroundColor Yellow
      Write-Output "    git ls-remote --tags origin refs/tags/$tag" -ForegroundColor Yellow
      Write-Output ""
      throw

    }

  } else {
    # -WhatIf was specified - echo what would happen without doing it
    Write-Output "  WhatIf: would create annotated tag and push to origin" -ForegroundColor Yellow
    Write-Output "    Tag    : $tag" -ForegroundColor Yellow
    Write-Output "    Message: $tagMsg" -ForegroundColor Yellow
    Write-Output ""
  }

} finally {
  Pop-Location
}
