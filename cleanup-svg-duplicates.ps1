# Script corregido para limpiar SVGs y asegurar compatibilidad con GitHub
# Arregla el problema de fill="#000" duplicado

Write-Host "Limpiando SVGs para compatibilidad perfecta con GitHub..." -ForegroundColor Green

# Cambiar al directorio icons
Set-Location -Path ".\icons"

# Obtener todos los archivos SVG
$svgFiles = Get-ChildItem -Filter "*.svg" -File
Write-Host "Encontrados $($svgFiles.Count) archivos SVG para limpiar" -ForegroundColor Yellow

# Crear respaldo
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "..\svg-backup-cleanup-$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item *.svg $backupDir -Force
Write-Host "Respaldo creado en: $backupDir" -ForegroundColor Cyan

$cleanedFiles = 0

foreach ($file in $svgFiles) {
    Write-Host "Limpiando: $($file.Name)" -ForegroundColor White
    
    try {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Si ya esta en estructura GitHub, limpiar duplicados
        if ($content -match '<g fill="#000">') {
            
            # Limpiar fill duplicados en paths dentro de g fill
            $content = $content -replace '(<g fill="#000">[^<]*)<path fill="#000"', '$1<path'
            
            # Limpiar multiples espacios
            $content = $content -replace '\s+', ' '
            
            # Asegurar formato correcto con saltos de linea
            $content = $content -replace '><', ">`n<"
            $content = $content -replace '<g fill="#000">', "<g fill=`"#000`">`n"
            $content = $content -replace '</g>', "`n</g>"
            $content = $content -replace '</svg>', "`n</svg>"
            
            # Limpiar espacios extra al inicio de lineas
            $content = ($content -split "`n" | ForEach-Object { $_.Trim() }) -join "`n"
            
            # Escribir archivo limpio
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            
            $cleanedFiles++
            Write-Host "  Limpiado: $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "  Sin cambios necesarios: $($file.Name)" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "  Error limpiando $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Volver al directorio principal
Set-Location -Path ".."

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "LIMPIEZA DE SVG COMPLETADA" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "Archivos limpiados: $cleanedFiles" -ForegroundColor Green
Write-Host "Problemas corregidos:" -ForegroundColor Yellow
Write-Host "- Eliminados fill='#000' duplicados en paths" -ForegroundColor Gray
Write-Host "- Corregido formato de saltos de linea" -ForegroundColor Gray
Write-Host "- Limpiados espacios extra" -ForegroundColor Gray
Write-Host ""
Write-Host "Los SVG ahora deberian mostrarse correctamente en GitHub!" -ForegroundColor Green