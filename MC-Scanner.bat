@echo off
color 0B
title MC Anti-Cheat Scanner v2.5
echo.
echo   =================================================
echo     MC Anti-Cheat Scanner v2.5
echo     Screenshare Tool per Minecraft
echo   =================================================
echo.

:: Controlla admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Riavvio come Amministratore...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

echo   [OK] Privilegi admin attivi
echo   [OK] Download scanner in corso...
echo.

set SCRIPT_URL=https://cosmicmc2026-png.github.io/Cosmic-Scanner/scanner.ps1
set SCRIPT_PATH=%TEMP%\mc-scan-%RANDOM%.ps1

:: Scarica lo script
powershell -Command "(New-Object Net.WebClient).DownloadFile('%SCRIPT_URL%', '%SCRIPT_PATH%')"

if not exist "%SCRIPT_PATH%" (
    echo   [ERRORE] Download fallito. Controlla la connessione.
    pause
    exit /b
)

echo   [OK] Scanner scaricato
echo   [OK] Avvio scansione...
echo.

:: Esegui lo scanner
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

:: Cancella lo script dopo l'esecuzione
del "%SCRIPT_PATH%" >nul 2>&1

echo.
echo   [OK] Scanner rimosso dal PC.
