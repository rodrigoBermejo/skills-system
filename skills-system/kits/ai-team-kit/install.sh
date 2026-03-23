#!/bin/bash
# =============================================================
# AI Team Kit — Instalador
# Copia skills y templates a un proyecto destino
# Uso: ./install.sh /ruta/a/tu/proyecto
# =============================================================

set -e

TARGET="${1:-.}"
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "Error: $TARGET no existe"
  exit 1
fi

echo "=== AI Team Kit — Instalando en: $TARGET ==="

# 1. Copiar skills
echo "[1/4] Copiando 10 skills..."
mkdir -p "$TARGET/skills"
cp -r "$KIT_DIR/skills/"* "$TARGET/skills/"
echo "  ✓ Skills copiados a $TARGET/skills/"

# 2. Copiar .mcp.json template (solo si no existe)
if [ ! -f "$TARGET/.mcp.json" ]; then
  echo "[2/4] Creando .mcp.json template..."
  cp "$KIT_DIR/templates/mcp-json-template.json" "$TARGET/.mcp.json"
  echo "  ✓ .mcp.json creado — EDITAR con tu SUPABASE_PROJECT_REF"
else
  echo "[2/4] .mcp.json ya existe — saltando"
fi

# 3. Mostrar snippet para .env
echo "[3/4] Agregar a tu .env.example:"
echo "  ---"
cat "$KIT_DIR/templates/env-snippet.txt"
echo "  ---"

# 4. Mostrar siguiente paso
echo "[4/4] Siguientes pasos:"
echo "  1. Editar .mcp.json con tu SUPABASE_PROJECT_REF"
echo "  2. Agregar variables de Supabase a .env"
echo "  3. Aplicar migracion: bootstrap/001-ai-memories-rag.sql"
echo "  4. Desplegar Edge Function: bootstrap/embed-memory.ts"
echo "  5. Agregar snippet a CLAUDE.md: templates/claude-md-snippet.md"
echo "  6. Agregar snippet a skills-catalog: templates/skills-catalog-snippet.md"
echo ""
echo "=== Listo! ==="
