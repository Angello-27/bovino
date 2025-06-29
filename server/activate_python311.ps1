Write-Host "Activando Python 3.11.9 para el proyecto Bovino IA..." -ForegroundColor Green
Write-Host ""

# Verificar si Python 3.11 está disponible
try {
    $pythonVersion = py -3.11 --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Python 3.11 no encontrado"
    }
    Write-Host "Python 3.11 encontrado: $pythonVersion" -ForegroundColor Yellow
} catch {
    Write-Host "ERROR: Python 3.11 no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Por favor instala Python 3.11.9 desde https://www.python.org/downloads/" -ForegroundColor Red
    Read-Host "Presiona Enter para continuar"
    exit 1
}

# Desactivar entorno virtual si está activo
if ($env:VIRTUAL_ENV) {
    Write-Host "Desactivando entorno virtual anterior..." -ForegroundColor Yellow
    deactivate
}

# Eliminar entorno virtual anterior si existe
if (Test-Path "venv") {
    Write-Host "Eliminando entorno virtual anterior..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "venv"
}

# Crear nuevo entorno virtual con Python 3.11
Write-Host "Creando nuevo entorno virtual con Python 3.11.9..." -ForegroundColor Yellow
py -3.11 -m venv venv

# Activar el entorno virtual
Write-Host "Activando entorno virtual..." -ForegroundColor Yellow
& ".\venv\Scripts\Activate.ps1"

# Verificar la versión
Write-Host ""
Write-Host "Verificando versión de Python:" -ForegroundColor Cyan
python --version

# Instalar dependencias
Write-Host ""
Write-Host "Instalando dependencias..." -ForegroundColor Yellow
pip install -r requirements.txt

Write-Host ""
Write-Host "¡Configuración completada! El proyecto ahora usa Python 3.11.9" -ForegroundColor Green
Write-Host "Para activar el entorno virtual en el futuro, ejecuta: .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host ""
Read-Host "Presiona Enter para continuar" 