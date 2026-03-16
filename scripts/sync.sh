#!/bin/bash

# 🔄 Automated Sync Script - Skills System
# Este script lee la metadata de cada skill e inyecta la referencia
# en el agents.md correspondiente usando marcadores HTML.

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$PROJECT_DIR/skills"

# Archivos de destino
ROOT_AGENTS="$PROJECT_DIR/agents.md"
FRONTEND_AGENTS="$PROJECT_DIR/frontend/agents.md"
BACKEND_AGENTS="$PROJECT_DIR/backend/agents.md"

# Archivos temporales para acumular skills por scope
TMP_GLOBAL=$(mktemp)
TMP_FRONTEND=$(mktemp)
TMP_BACKEND=$(mktemp)

# Limpiar temporales al salir
trap "rm -f $TMP_GLOBAL $TMP_FRONTEND $TMP_BACKEND" EXIT

echo -e "${BLUE}🔄 Sincronizando skills con agents.md...${NC}"
echo ""

extract_metadata() {
    local skill_file=$1
    local metadata_key=$2
    grep -i "^\*\*$metadata_key:\*\*" "$skill_file" | sed "s/^\*\*$metadata_key:\*\*//" | xargs
}

process_skill() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local relative_path=${skill_file#$PROJECT_DIR/}

    local scope=$(extract_metadata "$skill_file" "Scope")
    local trigger=$(extract_metadata "$skill_file" "Trigger")

    [ -z "$scope" ] && scope="global"

    local ref="- \`$skill_name\` → $trigger (Ver: /$relative_path)"

    # Convertir a minúsculas compatible con bash antiguo (masOS)
    local scope_lower=$(echo "$scope" | tr '[:upper:]' '[:lower:]')

    case "$scope_lower" in
        "frontend"|"ui")
            echo "$ref" >> "$TMP_FRONTEND"
            ;;
        "backend"|"api")
            echo "$ref" >> "$TMP_BACKEND"
            ;;
        *)
            echo "$ref" >> "$TMP_GLOBAL"
            ;;
    esac
}

# Recolectar todas las skills
while IFS= read -r skill; do
    process_skill "$skill"
done < <(find "$SKILLS_DIR" -name "SKILL.md")

# Función para actualizar un archivo agents.md
update_agents() {
    local target_file=$1
    local content_file=$2
    local label=$3

    if [ ! -f "$target_file" ]; then
        echo -e "${RED}❌ Archivo no encontrado: $target_file${NC}"
        return
    fi

    if ! grep -q "<!-- SKILLS_START -->" "$target_file"; then
        echo -e "${YELLOW}⚠️  Faltan marcadores en $(basename $target_file). Saltando...${NC}"
        return
    fi

    echo -e "${BLUE}📝 Actualizando $(basename $target_file)...${NC}"

    # Crear archivo temporal para la actualización
    local tmp_update=$(mktemp)

    # Extraer parte inicial
    sed -n '1,/<!-- SKILLS_START -->/p' "$target_file" > "$tmp_update"

    # Insertar contenido
    cat "$content_file" >> "$tmp_update"

    # Extraer parte final
    sed -n '/<!-- SKILLS_END -->/,$p' "$target_file" >> "$tmp_update"

    mv "$tmp_update" "$target_file"
    echo -e "${GREEN}✅ $(basename $target_file) actualizado.${NC}"
}

# Ejecutar actualizaciones
update_agents "$ROOT_AGENTS" "$TMP_GLOBAL" "ROOT"
update_agents "$FRONTEND_AGENTS" "$TMP_FRONTEND" "FRONTEND"
update_agents "$BACKEND_AGENTS" "$TMP_BACKEND" "BACKEND"

echo ""
echo -e "${GREEN}✨ Sincronización completada exitosamente.${NC}"

# ─────────────────────────────────────────────
# Sync global: copiar skills a ~/.claude/commands/
# ─────────────────────────────────────────────
GLOBAL_COMMANDS_DIR="$HOME/.claude/commands"

if [ ! -d "$GLOBAL_COMMANDS_DIR" ]; then
    mkdir -p "$GLOBAL_COMMANDS_DIR"
fi

echo ""
echo -e "${BLUE}🌐 Sincronizando skills globales → $GLOBAL_COMMANDS_DIR${NC}"

sync_count=0
while IFS= read -r skill_file; do
    skill_name=$(basename "$(dirname "$skill_file")")
    dest="$GLOBAL_COMMANDS_DIR/$skill_name.md"
    cp "$skill_file" "$dest"
    echo -e "  ${GREEN}✓${NC} $skill_name.md"
    ((sync_count++))
done < <(find "$SKILLS_DIR" -name "SKILL.md")

echo ""
echo -e "${GREEN}✨ $sync_count skills sincronizadas globalmente en ~/.claude/commands/${NC}"
