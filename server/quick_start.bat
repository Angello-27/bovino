@echo off
echo ========================================
echo 🐄 BOVINO IA SERVER - QUICK START
echo ========================================
echo.

echo Iniciando lanzador interactivo...
echo.

REM Intentar ejecutar el lanzador
python launch_server.py

REM Si falla, mostrar instrucciones
if errorlevel 1 (
    echo.
    echo ❌ Error ejecutando el lanzador
    echo.
    echo 💡 Posibles soluciones:
    echo 1. Verificar que Python 3.11 esté instalado
    echo 2. Ejecutar: py -3.11 launch_server.py
    echo 3. Usar los scripts de configuración:
    echo    - PowerShell: .\activate_python311.ps1
    echo    - Command Prompt: activate_python311.bat
    echo.
    pause
) 