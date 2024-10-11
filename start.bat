@echo off
set "dateipfad=%~dp0Configuration.au3"

rem Prüfen, ob es ein 64-Bit-System ist
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "programm=%~dp0install\AutoIt3_x64.exe"
) else (
    set "programm=%~dp0install\AutoIt3.exe"
)

start "" "%programm%" "%dateipfad%"
