# Script para generar iconos disabled y actualizar README
param()

$iconsDir = "icons"
$readmePath = "README.md"

# Obtener todos los iconos principales (sin _white ni _disabled)
$mainIcons = Get-ChildItem -Path $iconsDir -Name "*.svg" | Where-Object {
    $_ -notmatch "_white\.svg$" -and $_ -notmatch "_disabled\.svg$"
} | Sort-Object

Write-Host "Generando iconos disabled para $($mainIcons.Count) iconos..."

foreach ($icon in $mainIcons) {
    $iconPath = Join-Path $iconsDir $icon
    $disabledPath = Join-Path $iconsDir ($icon -replace "\.svg$", "_disabled.svg")
    
    # Leer el contenido del icono original
    $content = Get-Content $iconPath -Raw
    
    # Reemplazar todos los fill="#000" y fill="#fff" con fill="#ced4da"
    $disabledContent = $content -replace 'fill="#000"', 'fill="#ced4da"'
    $disabledContent = $disabledContent -replace 'fill="#fff"', 'fill="#ced4da"'
    $disabledContent = $disabledContent -replace '<g fill="#000">', '<g fill="#ced4da">'
    $disabledContent = $disabledContent -replace '<g fill="#fff">', '<g fill="#ced4da">'
    
    # Escribir el archivo disabled
    $disabledContent | Out-File -FilePath $disabledPath -Encoding UTF8 -NoNewline
    
    Write-Host "Generado: $disabledPath"
}

Write-Host "`nActualizando README..."

# Generar el nuevo contenido del README
$readmeContent = @"
# Iconss 
| Icon | name 　　　　　　　　　　　　　　　　　　　　　　| SVG | White | Disabled |
| :-: | :- | :-: | :-: | :-: |
"@

foreach ($icon in $mainIcons) {
    $baseName = $icon -replace "\.svg$", ""
    $displayName = $baseName -replace "^icn_", ""
    
    $whitePath = $icon -replace "\.svg$", "_white.svg"
    $disabledPath = $icon -replace "\.svg$", "_disabled.svg"
    
    $readmeContent += "|"
    $readmeContent += " ![${icon}](/icons/${icon})"
    $readmeContent += " | ``${displayName}``"
    $readmeContent += " |  [.svg](/icons/${icon})"
    $readmeContent += " | ![${whitePath}](/icons/${whitePath}#gh-dark-mode-only)"
    $readmeContent += " | ![${disabledPath}](/icons/${disabledPath})"
    $readmeContent += " |`n"
}

# Escribir el nuevo README
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8 -NoNewline

Write-Host "README actualizado con $($mainIcons.Count) iconos y 4 columnas (Icon, SVG, White, Disabled)"
Write-Host "¡Proceso completado!"