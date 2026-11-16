@echo off
echo ====================================
echo PesaTrack Error Fix Script
echo ====================================
echo.

echo Step 1: Cleaning Flutter build artifacts...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)
echo Done!
echo.

echo Step 2: Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)
echo Done!
echo.

echo Step 3: Running analysis...
call flutter analyze > analysis_output.txt 2>&1
echo Analysis complete. Check analysis_output.txt for details.
echo.

echo Step 4: Checking for first error...
type analysis_output.txt | findstr /N "error" | more
echo.

echo ====================================
echo Fix script complete!
echo ====================================
echo.
echo Next steps:
echo 1. Check analysis_output.txt for the FIRST error listed
echo 2. Run 'flutterfire configure' to generate Firebase credentials
echo 3. Reload VS Code (Close and reopen)
echo.
pause
