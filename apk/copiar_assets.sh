#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# AstroIO — copia las imágenes del juego a los assets de la APK
# para que la app no las descargue de Internet (ahorro de datos).
#
# Uso:  bash apk/copiar_assets.sh          (desde la raíz del repo)
# GitHub Actions lo ejecuta automáticamente antes de compilar.
# ═══════════════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
SRC="$ROOT/styles/theme/gow"
DEST="android/app/src/main/assets/game/styles/theme/gow"

mkdir -p "$DEST"

DIRS="gebaeude planeten img images mercado razas facciones premios"

for d in $DIRS; do
    if [ -d "$SRC/$d" ]; then
        echo "Copiando $d ..."
        cp -r "$SRC/$d" "$DEST/"
    else
        echo "(aviso) no existe $SRC/$d, se omite"
    fi
done

echo ""
echo "Assets del juego listos en: apk/android/app/src/main/assets/game/styles/theme/gow"
du -sh "$DEST" || true
