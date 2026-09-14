@echo off
REM ============================================================
REM  Run a test suite with login credentials sourced from MongoDB.
REM  Loads config\mongo_login.py as a Robot variablefile, so
REM  ${LOGIN_EMAIL} / ${LOGIN_PASSWORD} / ${LOGIN_NAME} are set.
REM  MongoDB is auto-started if needed and shut down afterwards
REM  only when this wrapper started it.
REM
REM      run_mongo.cmd tests\auth\mongo_credentials.robot
REM ============================================================
setlocal
cd /d "%~dp0.."

if not "%~1"=="" goto :confirmexe
echo Usage: run_mongo.cmd test_path [robot options...]
echo.
echo Example: run_mongo.cmd tests\auth\mongo_credentials.robot
exit /b 1

:confirmexe
set "MONGOD_EXE=%MONGOD_EXE%"
if not defined MONGOD_EXE set "MONGOD_EXE=C:\mongodb\mongodb-win32-x86_64-windows-6.0.0\bin\mongod.exe"
set "MONGOD_DBPATH=%MONGOD_DBPATH%"
if not defined MONGOD_DBPATH set "MONGOD_DBPATH=C:\mongodb\data"

REM Start MongoDB if needed; exit code 1 means this wrapper started it.
call bin\start_mongod.cmd
set "CM_START=%ERRORLEVEL%"
if "%CM_START%"=="1" set "STARTED_MONGOD=1"
if "%CM_START%"=="0" set "STARTED_MONGOD=0"
if "%CM_START%"=="2" (
    echo Starting MongoDB failed; aborting.
    exit /b 2
)

set "TARGET=%~1"
shift
set "REST="
:collect
if "%~1"=="" goto :execute
set "REST=%REST% %~1"
shift
goto :collect

:execute
robot --outputdir output --log log_suite.html --report report_suite.html --variablefile config\mongo_login.py %REST% %TARGET%
set "CM_EXIT=%ERRORLEVEL%"

if "%STARTED_MONGOD%"=="1" (
    echo Stopping MongoDB that this wrapper started...
    "%MONGOD_EXE%" --shutdown --dbpath "%MONGOD_DBPATH%" >nul 2>&1
    powershell -NoProfile -Command "Get-Process mongod -ErrorAction SilentlyContinue | Stop-Process -Force"
)

endlocal & exit /b %CM_EXIT%