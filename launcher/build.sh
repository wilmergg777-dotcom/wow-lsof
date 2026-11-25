#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO Launcher — compila las 2 versiones (Windows + Linux)
#
# Requiere Go 1.21+ en el PATH. Para PUBLICAR UNA VERSIÓN NUEVA:
#   1) Sube launcherVersionCode (+1) y launcherVersionName en main.go
#   2) Ejecuta este script
#   3) Sube los 2 archivos por FTP a /launcher/ del servidor
#   4) Actualiza el bloque "launcher" de /apk/version.json
#      (urls + sha256, calculados por este script al final)
# ═══════════════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

echo "== Compilando launcher para Windows =="
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o AstroIO-Launcher-windows.exe .

echo "== Compilando launcher para Linux =="
GOOS=linux GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o AstroIO-Launcher-linux .

echo "== Compilando instalador Setup para Windows (Go, sin NSIS) =="
# El Setup lleva el launcher embebido (go:embed): copiarlo junto a su
# fuente y compilar. Exe 100% estático -> imposible el error Windows
# "la configuración en paralelo no es correcta" (SxS) del NSIS viejo.
cp AstroIO-Launcher-windows.exe setup/launcher.exe
(cd setup && GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-H=windowsgui -s -w" -o ../AstroIO-Setup-Windows.exe .)
rm -f setup/launcher.exe

echo ""
echo "== Archivos y SHA-256 para version.json =="
sha256sum AstroIO-Launcher-windows.exe AstroIO-Launcher-linux AstroIO-Setup-Windows.exe
