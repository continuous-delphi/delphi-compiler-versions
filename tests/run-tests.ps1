# tests/run-tests.ps1
if ($IsWindows) {
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
}
Import-Module Pester -MinimumVersion 5.7.0 -Force
Push-Location (Join-Path $PSScriptRoot '..')
$config = New-PesterConfiguration -Hashtable (Import-PowerShellDataFile "$PSScriptRoot/pwsh/PesterConfig.psd1")
$config.Run.PassThru = $true
$result = $null
try {
  $result = Invoke-Pester -Configuration $config
} finally {
  Pop-Location
}
if ($result.FailedCount -gt 0) { exit 1 }
