#!/bin/bash
set -euo pipefail

FRONTEND_DIR="/var/www/Royalbet/packages/frontend"
APACHE_DIR="/var/www/royalbet-frontend"

cd "$FRONTEND_DIR"

echo "📂 CWD: $(pwd)"

# 🛑 VALIDACIÓN: el package.json debe ser del frontend
if ! grep -q '"name": *"frontend"' package.json 2>/dev/null; then
  echo "❌ ERROR: package.json NO es del frontend (¿lo sobrescribió backend-up?)."
  echo "Contenido actual:"
  cat package.json
  echo ""
  echo "🔧 Repara con el comando del PASO 1 del chat."
  exit 1
fi

if ! grep -q '"build"' package.json; then
  echo "❌ ERROR: package.json no tiene script 'build'."
  exit 1
fi

chmod -R +x node_modules/.bin/ 2>/dev/null || true

echo "🧹 1. Limpiando basura macOS..."
find src -name "._*" -delete 2>/dev/null || true
find src -name ".__*" -delete 2>/dev/null || true

echo "🔍 2. Verificando codificación..."
find src -type f \( -name "*.jsx" -o -name "*.js" -o -name "*.css" -o -name "*.html" -o -name "*.json" \) -print0 2>/dev/null | while IFS= read -r -d '' file; do
    if ! iconv -f UTF-8 -t UTF-8 "$file" > /dev/null 2>&1; then
        echo "⚠️  Convirtiendo a UTF-8: $file"
        cp "$file" "${file}.bak"
        iconv -f WINDOWS-1252 -t UTF-8 "${file}.bak" > "$file"
        rm "${file}.bak"
    fi
done

echo "📦 3. Compilando frontend..."
npm run build

echo "🚀 4. Desplegando en Apache..."
sudo rm -rf "$APACHE_DIR"/*
sudo cp -r dist/* "$APACHE_DIR"/
sudo chown -R www-data:www-data "$APACHE_DIR"/

echo "✅ ¡Frontend actualizado! Ctrl+F5 en el navegador."
