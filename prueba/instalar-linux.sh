#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO Launcher — instalador para Linux (fácil)
#
# Uso:   bash instalar-linux.sh
#   (opcional: bash instalar-linux.sh /ruta/AstroIO-Launcher-linux)
#
# Qué hace: busca el launcher descargado, lo copia a ~/.local/bin,
# instala el icono y crea la entrada "AstroIO" en el menú de apps.
# No necesita permisos de administrador (se instala por usuario).
# ═══════════════════════════════════════════════════════════════
set -e

B64_ICON="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"

verde='\033[0;32m'; amar='\033[0;33m'; rojo='\033[0;31m'; fin='\033[0m'
say(){ echo -e "${verde}==>${fin} $1"; }
warn(){ echo -e "${amar}==> ATENCIÓN:${fin} $1"; }
die(){ echo -e "${rojo}==> ERROR:${fin} $1"; exit 1; }

say "AstroIO — instalador del launcher para Linux"

# 1) Encontrar el binario del launcher
BIN_ARG="$1"
BIN=""
if [ -n "$BIN_ARG" ] && [ -f "$BIN_ARG" ]; then
  BIN="$BIN_ARG"
else
  for d in "$(cd "$(dirname "$0")" && pwd)" "$HOME/Descargas" "$HOME/Downloads" "$HOME/Desktop" "$HOME/Escritorio"; do
    [ -z "$d" ] && continue
    for cand in "$d/AstroIO-Launcher-linux" "$d/launcher/AstroIO-Launcher-linux"; do
      if [ -f "$cand" ]; then BIN="$cand"; break 2; fi
    done
  done
fi
[ -z "$BIN" ] && die "No encontré AstroIO-Launcher-linux.
    Descárgalo del Release de GitHub y guárdalo en la MISMA carpeta
    que este instalar-linux.sh (por ej. en Descargas), y vuelve a
    ejecutar:  bash instalar-linux.sh"

# 2) Carpetas de instalación por usuario
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons"

# 3) Copiar el launcher
DEST="$HOME/.local/bin/AstroIO-Launcher"
say "Instalando el launcher en $DEST"
install -m 755 "$BIN" "$DEST"

# 4) Icono
say "Instalando el icono"
printf '%s' "$B64_ICON" | base64 -d > "$HOME/.local/share/icons/astroio.png" 2>/dev/null \
  || printf '%s' "$B64_ICON" | base64 --decode > "$HOME/.local/share/icons/astroio.png"

# 5) Entrada en el menú de aplicaciones
say "Creando la entrada AstroIO en el menú de aplicaciones"
cat > "$HOME/.local/share/applications/astroio.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=AstroIO
Comment=Juego AstroIO
Exec=$DEST
Icon=$HOME/.local/share/icons/astroio.png
Terminal=false
Categories=Game;
StartupWMClass=AstroIO
EOF

# 5b) Entrada "Borrar datos" en el menú (igual que la APK)
cat > "$HOME/.local/share/applications/astroio-borrar-datos.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=AstroIO - Borrar datos
Comment=Borra sesión, caché y ajustes del juego AstroIO
Exec=$DEST --borrar-datos
Icon=$HOME/.local/share/icons/astroio.png
Terminal=false
Categories=Game;
EOF

# 6) Actualizar cachés de menú si existen
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t "$HOME/.local/share/icons" >/dev/null 2>&1 || true

echo ""
say "¡Listo! AstroIO quedó instalado."
echo    "    · Ábrelo desde el MENÚ DE APLICACIONES del sistema (categoría Juegos),"
echo    "      o desde la terminal con:  $DEST"
echo    "    · También hay una entrada \"AstroIO - Borrar datos\" (sesión, caché y ajustes)."
echo    "    · Se auto-actualiza solo al abrirse, igual que la APK."
