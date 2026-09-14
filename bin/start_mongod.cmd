@echo off
REM ============================================================
REM  Start MongoDB if it is not already running (idempotent).
REM
REM  Exit codes:
REM      0  MongoDB was already running (nothing started)
REM      1  MongoDB was started by this script
REM      2  Failed to locate or start MongoDB
REM
REM  Overrides:
REM      MONGOD_EXE      path to mongod.exe
REM      MONGOD_DBPATH   data directory (default C:\mongodb\data)
REM ============================================================
setlocal

set "MONGOD_EXE=%MONGOD_EXE%"
if not defined MONGOD_EXE set "MONGOD_EXE=C:\mongodb\mongodb-win32-x86_64-windows-6.0.0\bin\mongod.exe"
if not exist "%MONGOD_EXE%" (
    for /f "delims=" %%p in ('where mongod 2^>nul') do set "MONGOD_EXE=%%p"
)
if not exist "%MONGOD_EXE%" (
    echo ERROR: mongod.exe not found. Install MongoDB or set MONGOD_EXE.
    exit /b 2
)

set "DBPATH=%MONGOD_DBPATH%"
if not defined DBPATH set "DBPATH=C:\mongodb\data"

REM Already listening? -> exit 0 (already running)
powershell -NoProfile -Command "$c = New-Object Net.Sockets.TcpClient; try { $c.Connect('127.0.0.1',27017); $c.Close(); exit 0 } catch { exit 1 }"
if not errorlevel 1 goto :already

REM Existing mongod process still warming up?
for /f "delims=" %%p in ('powershell -NoProfile -Command "try { (Get-Process mongod -ErrorAction Stop).Id } catch { exit 0 }"') do set "MONGOD_PIDS=%%p"
if errorlevel 1 goto :alreadyprocess
if not defined MONGOD_PIDS set "MONGOD_PIDS=none"
if not "%MONGOD_PIDS%"=="none" goto :alreadyprocess

REM No mongod anywhere -> start a fresh one in the background.
echo Starting MongoDB with dbpath %DBPATH%...
powershell -NoProfile -Command "$p = Start-Process -FilePath '%MONGOD_EXE%' -ArgumentList '--dbpath','%DBPATH%' -WindowStyle Hidden -RedirectStandardOutput '%DBPATH%\.mongod.out.log' -RedirectStandardError '%DBPATH%\.mongod.err.log' -PassThru; Start-Sleep -Seconds 2; Write-Host ('Launched mongod PID ' + $p.Id)"
if errorlevel 1 (
    echo ERROR: failed to launch mongod.
    exit /b 2
)
goto :waitport1

:alreadyprocess
echo Waiting for existing mongod process to accept connections...
goto :waitport0

:waitport0
powershell -NoProfile -Command "$ok=$false; for($i=0;$i -lt 40;$i++){ Start-Sleep -Milliseconds 500; $c=New-Object Net.Sockets.TcpClient; try { $c.Connect('127.0.0.1',27017); $c.Close(); $ok=$true; break } catch {} }; if($ok){ exit 0 } else { exit 1 }"
if errorlevel 1 goto :fail
echo MongoDB is ready on 127.0.0.1:27017
exit /b 0

:waitport1
powershell -NoProfile -Command "$ok=$false; for($i=0;$i -lt 40;$i++){ Start-Sleep -Milliseconds 500; $c=New-Object Net.Sockets.TcpClient; try { $c.Connect('127.0.0.1',27017); $c.Close(); $ok=$true; break } catch {} }; if($ok){ exit 0 } else { exit 1 }"
if errorlevel 1 goto :fail
echo MongoDB started by this script and ready on 127.0.0.1:27017
exit /b 1

:fail
echo ERROR: MongoDB did not become ready on 127.0.0.1:27017.
exit /b 2

:already
echo MongoDB already running on 127.0.0.1:27017
exit /b 0