@echo off
REM ============================================================
REM  Clean the output directory before a fresh run
REM ============================================================
setlocal
cd /d "%~dp0.."

if exist output\ (
    rmdir /s /q output
    echo Removed output\
)
mkdir output
echo Fresh output\ ready.

endlocal