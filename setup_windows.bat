@echo off
setlocal
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found on PATH.
  exit /b 1
)

call flutter pub get
if errorlevel 1 exit /b 1

call dart run flutter_native_splash:create
if errorlevel 1 exit /b 1

echo.
echo Davochain native splash generated successfully.
echo You can now run: flutter run
endlocal
