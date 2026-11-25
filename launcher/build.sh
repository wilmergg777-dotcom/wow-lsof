#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO Launcher — compila las 3 piezas (launcher Win, launcher
# Linux y Setup Windows). El launcher es una app REAL:
#   - ventana propia con WebView2 en Windows (motor de Edge)
#   - imágenes del juego DENTRO del exe (como la APK: no gastan
#     datos) + caché de disco para el resto de estáticos
#   - atajo "Borrar datos" (--borrar-datos) como la APK
# Los exes de Windows llevan el icono incrustado (.syso con rsrc)
# y el Setup instala WebView2 si falta (bootstrapper de Microsoft).
#
# Requiere Go 1.21+ y conexión a Internet. Para PUBLICAR UNA
# VERSIÓN NUEVA: sube launcherVersionCode en main.go y deja que
# GitHub Actions ejecute este script en cada push.
# ═══════════════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

echo "== Dependencias Go (go-webview2 + x/sys) =="
go mod tidy

echo "== Copiando las imágenes del juego al launcher (no gastan datos) =="
# Las mismas carpetas que lleva la APK dentro (apk/copiar_assets.sh)
mkdir -p assets/game/styles/theme/gow
for d in gebaeude planeten img images mercado razas facciones premios; do
  if [ -d "../styles/theme/gow/$d" ]; then
    cp -r "../styles/theme/gow/$d" assets/game/styles/theme/gow/
  else
    echo "(aviso) no existe ../styles/theme/gow/$d, se omite"
  fi
done
du -sh assets/game

echo "== Descargando el instalador oficial de WebView2 (Microsoft) =="
curl -fsSL -o setup/webview2bootstrapper.exe "https://go.microsoft.com/fwlink/?LinkId=2124703"

echo "== Compilando launcher para Linux =="
GOOS=linux GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o AstroIO-Launcher-linux .

echo "== Incrustando icono en los ejecutables de Windows =="
# .syso junto a las fuentes: go build lo enlaza solo al compilar
# para Windows (así el exe, la ventana y los accesos tienen icono).
go run github.com/akavel/rsrc@latest -arch amd64 -ico assets/astroio.ico -o rsrc_windows_amd64.syso
cp rsrc_windows_amd64.syso setup/rsrc_windows_amd64.syso

echo "== Compilando launcher para Windows (ventana WebView2 propia) =="
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o AstroIO-Launcher-windows.exe .

echo "== Compilando instalador Setup para Windows (Go, sin NSIS) =="
# El Setup lleva el launcher + el instalador de WebView2 embebidos
# (go:embed). Exe 100% estático: imposible el error SxS del NSIS viejo.
cp AstroIO-Launcher-windows.exe setup/launcher.exe
(cd setup && GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o ../AstroIO-Setup-Windows.exe .)
rm -f rsrc_windows_amd64.syso setup/rsrc_windows_amd64.syso
rm -f setup/launcher.exe setup/webview2bootstrapper.exe

echo ""
echo "== Archivos y SHA-256 para version.json =="
sha256sum AstroIO-Launcher-windows.exe AstroIO-Launcher-linux AstroIO-Setup-Windows.exe
