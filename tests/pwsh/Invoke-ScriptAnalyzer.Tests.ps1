# tests/pwsh/Invoke-ScriptAnalyzer.Tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'PSScriptAnalyzer -- tools\' {

  BeforeAll {
    # Verify PSScriptAnalyzer is available
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
      throw 'PSScriptAnalyzer module is not installed. Run: Install-Module PSScriptAnalyzer -Scope CurrentUser'
    }

    Import-Module PSScriptAnalyzer -Force

    $repoRoot     = (Resolve-Path (Join-Path $PSScriptRoot '..\\..')).Path
    $toolsPath    = Join-Path $repoRoot 'tools'
    $settingsPath = Join-Path $repoRoot 'tests' 'PSScriptAnalyzerSettings.psd1'

    if (-not (Test-Path -LiteralPath $toolsPath))    { throw "tools\ not found: $toolsPath" }
    if (-not (Test-Path -LiteralPath $settingsPath)) { throw "Settings file not found: $settingsPath" }

    $script:Findings = Invoke-ScriptAnalyzer `
      -Path $toolsPath `
      -Recurse `
      -Settings $settingsPath
  }

  It 'reports no errors' {
    $errors = @($script:Findings | Where-Object Severity -EQ 'Error')
    $errors | Should -BeNullOrEmpty -Because (
      "PSScriptAnalyzer errors in tools\:`n" +
      ($errors | ForEach-Object { "  [$($_.ScriptName):$($_.Line)] $($_.RuleName) -- $($_.Message)" } | Join-String -Separator "`n")
    )
  }

  It 'reports no warnings' {
    $warnings = @($script:Findings | Where-Object Severity -EQ 'Warning')
    $warnings | Should -BeNullOrEmpty -Because (
      "PSScriptAnalyzer warnings in tools\:`n" +
      ($warnings | ForEach-Object { "  [$($_.ScriptName):$($_.Line)] $($_.RuleName) -- $($_.Message)" } | Join-String -Separator "`n")
    )
  }

}
