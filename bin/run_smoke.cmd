@echo off
REM ============================================================
REM  Run only SMOKE tagged tests (fast feedback)
REM      run_smoke.cmd --variable BROWSER:chrome
REM ============================================================
setlocal
cd /d "%~dp0.."

robot --listener resources/common/console_listener.py --outputdir output --tag smoke --log log_smoke.html --report report_smoke.html tests %*

endlocal