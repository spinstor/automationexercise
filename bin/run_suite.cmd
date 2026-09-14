@echo off
REM ============================================================
REM  Run a single test suite by name/path, e.g.:
REM      run_suite.cmd tests\auth\login.robot
REM      run_suite.cmd tests\auth\login.robot --variable HEADLESS:true
REM ============================================================
setlocal
cd /d "%~dp0.."

if not "%~1"=="" goto :run
echo Usage: run_suite.cmd test_path [robot options...]
echo.
echo Examples:
echo   run_suite.cmd tests\auth\login.robot                  headed Chrome
echo   run_suite.cmd tests\auth\login.robot --variable HEADLESS:true
echo   run_suite.cmd tests\auth\login.robot --variable BROWSER:headlesschrome
exit /b 1

:run
set "TARGET=%~1"
shift

set "REST="
:collect
if "%~1"=="" goto :execute
set "REST=%REST% %~1"
shift
goto :collect

:execute
robot --outputdir output --log log_suite.html --report report_suite.html %REST% %TARGET%
endlocal
