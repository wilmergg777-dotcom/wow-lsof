#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO Launcher — instalador para Linux
# Copia el launcher al sistema y crea el acceso en el menú de apps
#
# Uso:  bash instalar-linux.sh
# ═══════════════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"

BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
mkdir -p "$BIN" "$APPS"

cp -f AstroIO-Launcher-linux "$BIN/astroio-launcher"
chmod +x "$BIN/astroio-launcher"

cat > "$APPS/astroio.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=AstroIO
Comment=Launcher del juego AstroIO
Exec=$BIN/astroio-launcher
Terminal=false
Categories=Game;
StartupNotify=true
EOF

echo ""
echo "Instalado:"
echo "  - Ejecutable : $BIN/astroio-launcher"
echo "  - Acceso     : $APPS/astroio.desktop  (aparece como 'AstroIO' en el menú de aplicaciones)"
echo ""
echo "También puedes ejecutarlo desde terminal:  astroio-launcher"
