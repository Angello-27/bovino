@echo off
echo Activando Python 3.11.9 para el proyecto Bovino IA...
echo.

REM Verificar si Python 3.11 está disponible
py -3.11 --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python 3.11 no está instalado o no está en el PATH
    echo Por favor instala Python 3.11.9 desde https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Desactivar entorno virtual si está activo
if defined VIRTUAL_ENV (
    echo Desactivando entorno virtual anterior...
    deactivate
)

REM Eliminar entorno virtual anterior si existe
if exist venv (
    echo Eliminando entorno virtual anterior...
    rmdir /s /q venv
)

REM Crear nuevo entorno virtual con Python 3.11
echo Creando nuevo entorno virtual con Python 3.11.9...
py -3.11 -m venv venv

REM Activar el entorno virtual
echo Activando entorno virtual...
call venv\Scripts\activate.bat

REM Verificar la versión
echo.
echo Verificando versión de Python:
python --version

REM Instalar dependencias
echo.
echo Instalando dependencias...
pip install -r requirements.txt

echo.
echo ¡Configuración completada! El proyecto ahora usa Python 3.11.9
echo Para activar el entorno virtual en el futuro, ejecuta: venv\Scripts\activate.bat
echo.
pause 