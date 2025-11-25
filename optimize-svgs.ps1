# Script para optimizar archivos SVG usando SVGO
# Asegurate de tener Node.js y SVGO instalados primero:
# npm install -g svgo

Write-Host "Optimizando archivos SVG en la carpeta icons..." -ForegroundColor Green

# Verificar si SVGO está instalado
try {
    $svgoVersion = svgo --version
    Write-Host "SVGO version: $svgoVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: SVGO no está instalado. Instálalo primero con: npm install -g svgo" -ForegroundColor Red
    exit 1
}

# Cambiar al directorio icons
Set-Location -Path ".\icons"

# Obtener todos los archivos SVG
$svgFiles = Get-ChildItem -Filter "*.svg" -File

Write-Host "Encontrados $($svgFiles.Count) archivos SVG para optimizar" -ForegroundColor Yellow

# Crear respaldo antes de optimizar
$backupDir = "..\svg-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force
Copy-Item *.svg $backupDir -Force
Write-Host "Respaldo creado en: $backupDir" -ForegroundColor Cyan

# Optimizar cada archivo SVG
foreach ($file in $svgFiles) {
    Write-Host "Optimizando: $($file.Name)..." -ForegroundColor White
    
    # Obtener tamaño original
    $originalSize = $file.Length
    
    # Optimizar con SVGO (preservando IDs y clases para compatibilidad)
    svgo --input $file.FullName --output $file.FullName --config '{
        "plugins": [
            "preset-default",
            {
                "name": "cleanupIds",
                "params": {
                    "preserve": true
                }
            },
            {
                "name": "removeViewBox",
                "params": {
                    "disabled": true
                }
            }
        ]
    }'
    
    # Obtener tamaño optimizado
    $optimizedSize = (Get-Item $file.FullName).Length
    $savings = $originalSize - $optimizedSize
    $savingsPercent = [math]::Round(($savings / $originalSize) * 100, 2)
    
    Write-Host "  Original: $originalSize bytes | Optimizado: $optimizedSize bytes | Ahorro: $savingsPercent%" -ForegroundColor Green
}

# Volver al directorio principal
Set-Location -Path ".."

Write-Host "`n✅ Optimización completada!" -ForegroundColor Green
Write-Host "💾 Los archivos originales están respaldados en: $backupDir" -ForegroundColor Cyan
Write-Host "📊 Para ver estadísticas detalladas, revisa la salida anterior" -ForegroundColor Yellow