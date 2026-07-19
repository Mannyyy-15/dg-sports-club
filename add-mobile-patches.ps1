# Add mobile-patches.css to all HTML files
$files = Get-ChildItem -Path "C:\Manthan\Dg Sports CLub" -Filter "*.html" -Recurse

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if mobile-patches.css is already linked
    if ($content -notmatch 'mobile-patches\.css') {
        # Find the last stylesheet link and add mobile-patches after it
        if ($content -match '(<link rel="stylesheet" href="[^"]*custom\.css"[^>]*>)') {
            $content = $content -replace '(<link rel="stylesheet" href="[^"]*custom\.css"[^>]*>)', '$1`n    <link rel="stylesheet" href="assets/css/mobile-patches.css"/>'
        } elseif ($content -match '(<link rel="stylesheet" href="[^"]*blog\.css"[^>]*>)') {
            $content = $content -replace '(<link rel="stylesheet" href="[^"]*blog\.css"[^>]*>)', '$1`n    <link rel="stylesheet" href="../../assets/css/mobile-patches.css"/>'
        } elseif ($content -match '(<link rel="stylesheet" href="[^"]*style\.css"[^>]*>)') {
            $content = $content -replace '(<link rel="stylesheet" href="[^"]*style\.css"[^>]*>)', '$1`n    <link rel="stylesheet" href="assets/css/mobile-patches.css"/>'
        }
        
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Added mobile-patches.css to $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "Already has mobile-patches.css: $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`nDone!" -ForegroundColor Cyan