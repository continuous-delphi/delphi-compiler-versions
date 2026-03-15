@echo off
setlocal

set "SCRIPT_DIR=%~dp0"

pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\tools\generate-delphi-compiler-versions-inc.ps1"
pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\tools\generate-delphi-compiler-versions-pas.ps1"
pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%..\tools\generate-platform-support-md.ps1"
pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%run-tests.ps1"

set "EXITCODE=%ERRORLEVEL%"
pause

endlocal & exit /b %EXITCODE%
