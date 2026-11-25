#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO Launcher — compila las 3 piezas (launcher Win, launcher
# Linux y Setup Windows). Los exes de Windows llevan el icono del
# juego incrustado (recurso .syso generado con rsrc).
#
# Requiere Go 1.21+ en el PATH. Para PUBLICAR UNA VERSIÓN NUEVA:
#   1) Sube launcherVersionCode (+1) y launcherVersionName en main.go
#   2) Ejecuta este script (o deja que lo haga GitHub Actions)
#   3) Sube los 3 archivos por FTP a /launcher/ del servidor
#   4) Sube el version.json regenerado por el workflow a /apk/
# ═══════════════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

echo "== Compilando launcher para Linux =="
GOOS=linux GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o AstroIO-Launcher-linux .

echo "== Incrustando icono en los ejecutables de Windows =="
# .syso junto a las fuentes: go build lo enlaza solo al compilar
# para Windows (así el exe y los accesos directos tienen icono).
go run github.com/akavel/rsrc@latest -arch amd64 -ico assets/astroio.ico -o rsrc_windows_amd64.syso
cp rsrc_windows_amd64.syso setup/rsrc_windows_amd64.syso

echo "== Compilando launcher para Windows =="
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o AstroIO-Launcher-windows.exe .

echo "== Compilando instalador Setup para Windows (Go, sin NSIS) =="
# El Setup lleva el launcher embebido (go:embed): copiarlo junto a su
# fuente y compilar. Exe 100% estático -> imposible el error Windows
# "la configuración en paralelo no es correcta" (SxS) del NSIS viejo.
cp AstroIO-Launcher-windows.exe setup/launcher.exe
(cd setup && GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o ../AstroIO-Setup-Windows.exe .)
rm -f rsrc_windows_amd64.syso setup/rsrc_windows_amd64.syso

echo ""
echo "== Archivos y SHA-256 para version.json =="
sha256sum AstroIO-Launcher-windows.exe AstroIO-Launcher-linux AstroIO-Setup-Windows.exe
