<#
.SYNOPSIS
    Mobile Responsiveness Audit & Fix for DG Sports Club HTML files
#>

# Get all HTML files
$rootFiles = Get-ChildItem -Path "C:\Manthan\Dg Sports CLub" -Filter "*.html" -Recurse
$allFiles = $rootFiles

Write-Host "Found $($allFiles.Count) HTML files to audit" -ForegroundColor Cyan

$results = @()

foreach ($file in $allFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileName = $file.Name
    
    $fixesApplied = @()
    
    # 1. Ensure viewport meta tag exists
    if ($content -notmatch 'name="viewport"') {
        $content = $content -replace '(<head>)', '$1`n    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>'
        $fixesApplied += "Added viewport meta tag"
    }
    
    # 2. Ensure body has overflow-x-hidden
    if ($content -notmatch 'overflow-x-hidden') {
        if ($content -match '<body class="([^"]*)"') {
            $content = $content -replace '<body class="([^"]*)"', '<body class="$1 overflow-x-hidden"'
        } elseif ($content -match '<body>') {
            $content = $content -replace '<body>', '<body class="overflow-x-hidden">'
        } else {
            $content = $content -replace '<body ', '<body class="overflow-x-hidden" '
        }
        $fixesApplied += "Added overflow-x-hidden to body"
    }
    
    # 3. Fix blog category filter tabs - make horizontally scrollable on mobile
    # Pattern: <div class="flex flex-wrap gap-2 mb-10" role="tablist">
    if ($content -match 'class="flex flex-wrap gap-2 mb-10" role="tablist"') {
        $content = $content -replace 'class="flex flex-wrap gap-2 mb-10" role="tablist"', 'class="flex gap-2 mb-10 overflow-x-auto pb-2" role="tablist"'
        $fixesApplied += "Fixed category filter tabs for horizontal scroll on mobile"
    }
    
    # 4. Fix activities page filter buttons - make horizontally scrollable on mobile
    # Pattern: <div class="flex flex-wrap gap-3 mb-10">
    if ($content -match 'class="flex flex-wrap gap-3 mb-10">' -and $content -match 'filter-btn') {
        $content = $content -replace 'class="flex flex-wrap gap-3 mb-10">', 'class="flex gap-3 mb-10 overflow-x-auto pb-2">'
        $fixesApplied += "Fixed activities filter buttons for horizontal scroll on mobile"
    }
    
    # 5. Ensure tables have responsive wrapper
    if ($content -match '<table>' -and $content -notmatch 'overflow-x-auto">\s*<table>') {
        $content = $content -replace '(?s)(<table>)', '<div class="overflow-x-auto">$1'
        $content = $content -replace '(?s)(</table>)', '$1</div>'
        $fixesApplied += "Wrapped tables in responsive overflow container"
    }
    
    # 6. Fix blog post TOC sidebar - add mobile toggle button
    if ($content -match 'toc-sidebar' -and $content -notmatch 'toc-toggle') {
        # Find the aside with toc-sidebar class and add toggle before it
        $pattern = '(<aside[^>]*toc-sidebar[^>]*>)'
        if ($content -match $pattern) {
            $toggleBtn = '<button class="toc-toggle" aria-label="Toggle table of contents" aria-expanded="false" aria-controls="toc-sidebar"><span class="material-symbols-outlined">menu_book</span> Table of Contents <span class="material-symbols-outlined">expand_more</span></button>'
            $content = $content -replace $pattern, $toggleBtn + '$1'
            $fixesApplied += "Added TOC mobile toggle button"
        }
    }
    
    # 7. Ensure mobile menu has proper aria attributes
    if ($content -match 'id="mobile-menu-btn"' -and $content -notmatch 'aria-expanded="false"') {
        $content = $content -replace 'id="mobile-menu-btn"', 'id="mobile-menu-btn" aria-expanded="false" aria-controls="mobile-menu"'
        $fixesApplied += "Added ARIA attributes to mobile menu button"
    }
    
    # 8. Ensure reading progress bar exists on blog posts
    $isBlogPost = $fileName -match '^blog/' -and $fileName -notmatch 'index\.html$' -and $fileName -notmatch 'category/'
    if ($isBlogPost -and $content -notmatch 'reading-progress') {
        # Add after <body> tag
        $content = $content -replace '(<body[^>]*>)', '$1`n    <div class="reading-progress" id="reading-progress"></div>'
        # Add script before </body>
        $progressScript = @"
    <script>
    window.addEventListener('scroll', () => {
        const bar = document.getElementById('reading-progress');
        if (bar) {
            const h = document.documentElement.scrollHeight - window.innerHeight;
            bar.style.width = (window.scrollY / h * 100) + '%';
        }
    });
    </script>
"@
        $content = $content -replace '(</body>)', $progressScript + '$1'
        $fixesApplied += "Added reading progress bar"
    }
    
    # 9. Ensure WhatsApp float has proper mobile positioning (add bottom padding on mobile)
    if ($content -match 'whatsapp-float' -and $content -notmatch 'pb-20') {
        # This is handled in CSS, but we can add a class to body
        if ($content -match '<body class="([^"]*)"') {
            $content = $content -replace '<body class="([^"]*)"', '<body class="$1 has-whatsapp-float"'
        } else {
            $content = $content -replace '<body>', '<body class="has-whatsapp-float">'
        }
        $fixesApplied += "Added has-whatsapp-float class to body"
    }
    
    # 10. Ensure form inputs have proper mobile sizing - add min-height
    if ($content -match '<input' -and $content -notmatch 'min-h-\[44px\]') {
        $content = $content -replace '(<input[^>]*class=")([^"]*)"', '$1$2 min-h-[44px]"'
        $fixesApplied += "Added min-height 44px to form inputs"
    }
    
    # 11. Ensure select elements have proper mobile sizing
    if ($content -match '<select' -and $content -notmatch 'min-h-\[44px\]') {
        $content = $content -replace '(<select[^>]*class=")([^"]*)"', '$1$2 min-h-[44px]"'
        $fixesApplied += "Added min-height 44px to select elements"
    }
    
    # 12. Ensure textarea has proper mobile sizing
    if ($content -match '<textarea' -and $content -notmatch 'min-h-\[44px\]') {
        $content = $content -replace '(<textarea[^>]*class=")([^"]*)"', '$1$2 min-h-[44px]"'
        $fixesApplied += "Added min-height 44px to textarea elements"
    }
    
    # 13. Ensure buttons have proper touch target size
    if ($content -match '<button' -and $content -notmatch 'min-h-\[44px\]') {
        $content = $content -replace '(<button[^>]*class=")([^"]*)"', '$1$2 min-h-[44px] min-w-[44px]"'
        $fixesApplied += "Added min 44x44px touch target to buttons"
    }
    
    # 14. Ensure anchor tags that are buttons have touch target
    if ($content -match 'class="[^"]*btn[^"]*"' -and $content -notmatch 'min-h-\[44px\]') {
        $content = $content -replace '(class="[^"]*btn[^"]*)"', '$1 min-h-[44px] min-w-[44px]"'
        $fixesApplied += "Added min 44x44px touch target to button links"
    }
    
    # Write if changes made
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $results += [PSCustomObject]@{
            File = $fileName
            Fixes = $fixesApplied -join "; "
            Status = "FIXED"
        }
        Write-Host "  FIXED: $fileName - $($fixesApplied.Count) fixes" -ForegroundColor Green
    } else {
        $results += [PSCustomObject]@{
            File = $fileName
            Fixes = "No changes needed"
            Status = "OK"
        }
        Write-Host "  OK: $fileName" -ForegroundColor Gray
    }
}

# Summary
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
$fixed = $results | Where-Object { $_.Status -eq "FIXED" }
$ok = $results | Where-Object { $_.Status -eq "OK" }
Write-Host "Files fixed: $($fixed.Count)" -ForegroundColor Green
Write-Host "Files OK: $($ok.Count)" -ForegroundColor Gray

if ($fixed.Count -gt 0) {
    Write-Host "`nFixed files:" -ForegroundColor Cyan
    $fixed | Format-Table -AutoSize
}

Write-Host "`nCreating mobile-patches.css..." -ForegroundColor Cyan