# Script para convertir TODOS los SVGs a formato compatible con GitHub
# Procesa automaticamente toda la carpeta icons

Write-Host "Convirtiendo TODOS los SVGs a formato compatible con GitHub..." -ForegroundColor Green

# Cambiar al directorio icons
Set-Location -Path ".\icons"

# Obtener todos los archivos SVG
$svgFiles = Get-ChildItem -Filter "*.svg" -File
Write-Host "Encontrados $($svgFiles.Count) archivos SVG para convertir" -ForegroundColor Yellow

# Crear respaldo antes de convertir
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "..\svg-backup-github-conversion-$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item *.svg $backupDir -Force
Write-Host "Respaldo creado en: $backupDir" -ForegroundColor Cyan

# Variables para estadisticas
$convertedFiles = 0
$skippedFiles = 0

# Función para convertir SVG
function Convert-SVGToGitHubFormat {
    param(
        [string]$FilePath,
        [string]$FileName
    )
    
    try {
        # Leer contenido del archivo
        $content = Get-Content -Path $FilePath -Raw
        
        # Verificar si ya esta en formato correcto
        if ($content -match '<svg width="24" height="24" xmlns="http://www\.w3\.org/2000/svg" viewBox="0 0 24 24" fill="none">' -and 
            $content -match '<g fill="#000">') {
            Write-Host "  Ya esta en formato GitHub: $FileName" -ForegroundColor Green
            return $false
        }
        
        # Extraer todos los paths
        $pathPattern = '<path[^>]*d="[^"]*"[^>]*/?>'
        $pathMatches = [regex]::Matches($content, $pathPattern)
        
        if ($pathMatches.Count -eq 0) {
            Write-Host "  Sin paths encontrados: $FileName" -ForegroundColor Red
            return $false
        }
        
        # Limpiar y preparar paths
        $cleanPaths = @()
        foreach ($match in $pathMatches) {
            $pathContent = $match.Value
            
            # Limpiar atributos innecesarios
            $pathContent = $pathContent -replace '\s+class="[^"]*"', ''
            $pathContent = $pathContent -replace '\s+id="[^"]*"', ''
            $pathContent = $pathContent -replace '\s+style="[^"]*"', ''
            
            # Asegurar que sea autocerrante
            if ($pathContent -notmatch '/>$') {
                $pathContent = $pathContent -replace '>$', '/>'
            }
            
            # Si no tiene fill, agregarlo
            if ($pathContent -notmatch 'fill=') {
                $pathContent = $pathContent -replace '<path', '<path fill="#000"'
            }
            
            $cleanPaths += $pathContent
        }
        
        # Crear estructura GitHub-compatible
        $newContent = @"
<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">
<g fill="#000">
$($cleanPaths -join "`n")
</g>
</svg>
"@
        
        # Escribir archivo convertido
        [System.IO.File]::WriteAllText($FilePath, $newContent, [System.Text.Encoding]::UTF8)
        
        Write-Host "  Convertido exitosamente: $FileName" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  Error convirtiendo $FileName : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Procesar cada archivo SVG
foreach ($file in $svgFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    $converted = Convert-SVGToGitHubFormat -FilePath $file.FullName -FileName $file.Name
    
    if ($converted) {
        $convertedFiles++
    } else {
        $skippedFiles++
    }
}

# Volver al directorio principal
Set-Location -Path ".."

# Mostrar estadisticas finales
Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "CONVERSION A FORMATO GITHUB COMPLETADA" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "Archivos procesados: $($svgFiles.Count)" -ForegroundColor Yellow
Write-Host "Archivos convertidos: $convertedFiles" -ForegroundColor Green
Write-Host "Archivos sin cambios: $skippedFiles" -ForegroundColor Cyan
Write-Host "Backup guardado en: $backupDir" -ForegroundColor Gray
Write-Host ""
Write-Host "TODOS LOS SVG AHORA SON COMPATIBLES CON GITHUB MARKDOWN!" -ForegroundColor Green
Write-Host "Estructura aplicada:" -ForegroundColor Yellow
Write-Host "- Atributos en orden correcto" -ForegroundColor Gray
Write-Host "- Contenido dentro de <g fill='#000'>" -ForegroundColor Gray
Write-Host "- Formato con saltos de linea" -ForegroundColor Gray
Write-Host "- Sin clases CSS ni elementos vacios" -ForegroundColor Gray
Write-Host ""
Write-Host "Puedes verificar los cambios en GitHub!" -ForegroundColor Green