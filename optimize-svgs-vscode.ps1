# Script para optimizar archivos SVG usando tecnicas de optimizacion basica
# Compatible con PowerShell y VS Code

Write-Host "Optimizando archivos SVG..." -ForegroundColor Green

# Cambiar al directorio icons
Set-Location -Path ".\icons"

# Obtener todos los archivos SVG
$svgFiles = Get-ChildItem -Filter "*.svg" -File
Write-Host "Encontrados $($svgFiles.Count) archivos SVG para optimizar" -ForegroundColor Yellow

# Crear respaldo antes de optimizar
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "..\svg-backup-$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item *.svg $backupDir -Force
Write-Host "Respaldo creado en: $backupDir" -ForegroundColor Cyan

# Variables para estadisticas
$totalOriginalSize = 0
$totalOptimizedSize = 0

# Procesar cada archivo SVG
foreach ($file in $svgFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    # Obtener tamano original
    $originalSize = $file.Length
    $totalOriginalSize += $originalSize
    
    # Abrir el archivo y aplicar minificacion
    $filePath = $file.FullName
    
    try {
        # Leer el contenido del archivo
        $content = Get-Content -Path $filePath -Raw
        
        # Aplicar optimizaciones basicas de SVG
        # Remover comentarios XML
        $content = $content -replace '<!--[\s\S]*?-->', ''
        
        # Remover espacios en blanco extra entre elementos
        $content = $content -replace '>\s+<', '><'
        
        # Remover espacios en blanco al inicio y final
        $content = $content.Trim()
        
        # Remover atributos vacios o innecesarios
        $content = $content -replace '\s*xmlns:[\w-]*=""', ''
        $content = $content -replace '\s*xml:space="preserve"', ''
        
        # Optimizar numeros decimales (remover ceros innecesarios)
        $content = $content -replace '(\d+)\.0+(?=\D)', '$1'
        $content = $content -replace '(\.\d*?)0+(?=\D)', '$1'
        
        # Escribir el contenido optimizado
        [System.IO.File]::WriteAllText($filePath, $content)
        
        # Obtener tamano optimizado
        $optimizedSize = (Get-Item $filePath).Length
        $totalOptimizedSize += $optimizedSize
        
        $savings = $originalSize - $optimizedSize
        $savingsPercent = if ($originalSize -gt 0) { [math]::Round(($savings / $originalSize) * 100, 2) } else { 0 }
        
        Write-Host "  Original: $originalSize bytes -> Optimizado: $optimizedSize bytes" -ForegroundColor Green
        Write-Host "  Ahorro: $savings bytes ($savingsPercent%)" -ForegroundColor Cyan
        
    } catch {
        Write-Host "  Error procesando $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Volver al directorio principal
Set-Location -Path ".."

# Mostrar estadisticas finales
$totalSavings = $totalOriginalSize - $totalOptimizedSize
$totalSavingsPercent = if ($totalOriginalSize -gt 0) { [math]::Round(($totalSavings / $totalOriginalSize) * 100, 2) } else { 0 }

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "ESTADISTICAS FINALES" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "Archivos procesados: $($svgFiles.Count)" -ForegroundColor Yellow
Write-Host "Tamano original total: $totalOriginalSize bytes" -ForegroundColor White
Write-Host "Tamano optimizado total: $totalOptimizedSize bytes" -ForegroundColor White
Write-Host "Ahorro total: $totalSavings bytes ($totalSavingsPercent%)" -ForegroundColor Green
Write-Host "Backup guardado en: $backupDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Optimizacion completada exitosamente!" -ForegroundColor Green