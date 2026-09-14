@echo off
REM ============================================================
REM  Run the FULL AutomationExercise suite (UI + API)
REM  Arguments are passed through to robot, e.g.:
REM      run_all.cmd --variable BROWSER:headlesschrome
REM ============================================================
setlocal
cd /d "%~dp0.."

robot --listener resources/common/console_listener.py --outputdir output --log log.html --report report.html tests %*

endlocal