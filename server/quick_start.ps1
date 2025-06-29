Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🐄 BOVINO IA SERVER - QUICK START" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Iniciando lanzador interactivo..." -ForegroundColor Yellow
Write-Host ""

try {
    # Intentar ejecutar el lanzador
    python launch_server.py
    
    if ($LASTEXITCODE -ne 0) {
        throw "Error ejecutando el lanzador"
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error ejecutando el lanzador" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Posibles soluciones:" -ForegroundColor Yellow
    Write-Host "1. Verificar que Python 3.11 esté instalado" -ForegroundColor White
    Write-Host "2. Ejecutar: py -3.11 launch_server.py" -ForegroundColor White
    Write-Host "3. Usar los scripts de configuración:" -ForegroundColor White
    Write-Host "   - PowerShell: .\activate_python311.ps1" -ForegroundColor White
    Write-Host "   - Command Prompt: activate_python311.bat" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter para continuar"
} 