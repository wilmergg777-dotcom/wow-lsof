@echo off
REM ═══════════════════════════════════════════════════════════════
REM AstroIO — copia las imagenes del juego a los assets de la APK
REM Uso: doble clic (desde la carpeta apk) antes de compilar en
REM Android Studio. GitHub Actions lo hace automaticamente.
REM ═══════════════════════════════════════════════════════════════
cd /d %~dp0
set DEST=android\app\src\main\assets\game\styles\theme\gow
if not exist "%DEST%" mkdir "%DEST%"

for %%d in (gebaeude planeten img images mercado razas facciones premios) do (
  if exist "..\styles\theme\gow\%%d" (
    echo Copiando %%d ...
    xcopy /E /I /Y "..\styles\theme\gow\%%d" "%DEST%\%%d" >nul
  ) else (
    echo (aviso) no existe ..\styles\theme\gow\%%d , se omite
  )
)

echo.
echo Assets copiados en %DEST%
pause
