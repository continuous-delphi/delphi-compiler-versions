# tests/PSScriptAnalyzerSettings.psd1
# PSScriptAnalyzer settings for the delphi-compiler-versions toolchain.
#
# Usage:
#   Invoke-ScriptAnalyzer -Path tools\ -Recurse -Settings .\tests\PSScriptAnalyzerSettings.psd1
#
# Suppressions are limited to rules that conflict with deliberate conventions
# in this codebase. Each suppression is justified below.

@{
  ExcludeRules = @(

    # Internal helper functions (Ensure-*, Normalize-*, Pas-*, Assert-*) are
    # not exported cmdlets. The approved-verb and singular-noun requirements
    # apply to public module APIs, not private script helpers.
    'PSUseApprovedVerbs'
    'PSUseSingularNouns'

    # [OutputType()] attributes on internal functions add no value here.
    # These functions are not part of a public API surface.
    'PSUseOutputTypeCorrectly'

    # Invoke-Git is deliberately variadic -- callers pass git subcommands and
    # flags as positional arguments (e.g. Invoke-Git 'tag' '-a' ...).
    # Requiring named parameters would defeat its purpose.
    # Join-Path positional usage is idiomatic PowerShell.
    'PSAvoidUsingPositionalParameters'

  )
}
