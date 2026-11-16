# PesaTrack Error Fix Script
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "PesaTrack Error Fix Script" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean
Write-Host "Step 1: Cleaning Flutter build artifacts..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Done!" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter pub get failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Done!" -ForegroundColor Green
Write-Host ""

# Step 3: Analyze
Write-Host "Step 3: Running analysis..." -ForegroundColor Yellow
flutter analyze 2>&1 | Tee-Object -FilePath "analysis_output.txt"
Write-Host "Analysis complete. Output saved to analysis_output.txt" -ForegroundColor Green
Write-Host ""

# Step 4: Show first few errors
Write-Host "Step 4: First errors found:" -ForegroundColor Yellow
Get-Content "analysis_output.txt" | Select-String "error" | Select-Object -First 10
Write-Host ""

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Fix script complete!" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check analysis_output.txt for the FIRST error listed"
Write-Host "2. Run 'flutterfire configure' to generate Firebase credentials"
Write-Host "3. Reload VS Code (Close and reopen)"
Write-Host ""

Read-Host "Press Enter to exit"
