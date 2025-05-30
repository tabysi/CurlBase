@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Farbe: Hintergrund Blau (1), Text Weiß (F)
color 0F
REM Titel des Fensters setzen
title CURL Test-Menü
REM Log-Datei im gleichen Verzeichnis wie das Skript erstellen
if not exist "%~dp0tests" (
    echo [!] Das Verzeichnis "tests" wurde nicht gefunden.
    echo Bitte erstellen Sie ein Verzeichnis "tests" im gleichen Ordner wie dieses Skript.
    pause
    exit /b
)

set "logFile=%~dp0curl_execution_log.txt"

:menu
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════╗
echo ║                         CURL TEST-MENÜ                            ║
echo ╠═══════════════════════════════════════════════════════════════════╣
echo ║ Wähle eine .txt-Datei, um den enthaltenen CURL-Befehl auszuführen ║
echo ║                                                                   ║
echo ║  [q] Beenden                                                      ║
echo ╚═══════════════════════════════════════════════════════════════════╝
echo.

REM Dateien auflisten
set /a index=0
for %%F in ("%~dp0tests\*.txt") do (
    set /a index+=1
    set "file[!index!]=%%~fF"
    echo    [!index!]  %%~nxF
)

if %index%==0 (
    echo.
    echo [!] Keine .txt-Dateien im aktuellen Verzeichnis gefunden.
    pause
    exit /b
)

echo.
set /p choice=→ Auswahl (Zahl oder q für Beenden): 

if /i "%choice%"=="q" (
    echo.
    echo 💡 Programm wird beendet...
    timeout /t 1 >nul
    exit /b
)

if not defined file[%choice%] (
    echo.
    echo [!] ❌ Ungültige Auswahl.
    timeout /t 2 >nul
    goto menu
)

REM Datei wählen
set "selectedFile=!file[%choice%]!"
set "cmdFile=%TEMP%\temp_curl.cmd"
copy /Y "!selectedFile!" "!cmdFile!" >nul

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║ ⚙️  CURL-Befehl wird ausgeführt                        ║
echo ╚══════════════════════════════════════════════════════╝
echo Datei: !selectedFile!
echo Zeit:  %date% %time%
echo ----------------------------------------- >> "%logFile%"
echo Datei: !selectedFile! >> "%logFile%"
echo Zeit: %date% %time% >> "%logFile%"

REM CURL ausführen
for /f "delims=" %%R in ('cmd /c ""!cmdFile!""') do (
    echo ▶ Antwort: %%R
    echo Antwort: %%R >> "%logFile%"
)

REM Status prüfen
if !errorlevel! neq 0 (
    echo ❌ Fehler beim Ausführen des CURL-Befehls.
    echo Fehler bei der Ausführung >> "%logFile%"
) else (
    echo ✅ Erfolgreich ausgeführt.
    echo Erfolgreich ausgeführt >> "%logFile%"
)

echo ----------------------------------------- >> "%logFile%"
echo.
pause
goto menu