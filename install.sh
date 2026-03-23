#!/bin/bash
# =============================================================
# Skills System — Instalador Universal
# Instala el sistema de skills RBloom en cualquier proyecto
#
# Uso local:  ./install.sh /ruta/a/tu/proyecto
# Uso remoto: curl -fsSL https://raw.githubusercontent.com/RBloomDev/skills-system/main/install.sh | bash -s -- /ruta
# =============================================================

set -e

# --- Colores ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Defaults ---
TARGET=""
INSTALL_CORE=false
INSTALL_STACK=false
INSTALL_WORKFLOW=false
INSTALL_ALL=true
STACK_FILTER=""
NO_BOOTSTRAP=false
SCRIPT_DIR=""
TEMP_CLONE=""

# --- Cleanup ---
cleanup() {
  if [ -n "$TEMP_CLONE" ] && [ -d "$TEMP_CLONE" ]; then
    rm -rf "$TEMP_CLONE"
  fi
}
trap cleanup EXIT

# --- Parse args ---
for arg in "$@"; do
  case "$arg" in
    --core)
      INSTALL_CORE=true
      INSTALL_ALL=false
      ;;
    --stack=*)
      INSTALL_STACK=true
      STACK_FILTER="${arg#--stack=}"
      INSTALL_ALL=false
      ;;
    --stack)
      INSTALL_STACK=true
      INSTALL_ALL=false
      ;;
    --workflow)
      INSTALL_WORKFLOW=true
      INSTALL_ALL=false
      ;;
    --all)
      INSTALL_ALL=true
      ;;
    --no-bootstrap)
      NO_BOOTSTRAP=true
      ;;
    --help|-h)
      echo "Skills System — Instalador"
      echo ""
      echo "Uso: ./install.sh [TARGET] [OPTIONS]"
      echo ""
      echo "Argumentos:"
      echo "  TARGET              Directorio destino (default: directorio actual)"
      echo ""
      echo "Opciones:"
      echo "  --core              Solo skills core (orchestrator, memory, sdd, etc.)"
      echo "  --stack             Todos los skills de stack (react, spring, fastapi, etc.)"
      echo "  --stack=x,y,z       Skills de stack especificos"
      echo "  --workflow           Solo skills de workflow (git, cicd, ssdlc, etc.)"
      echo "  --all               Todos los skills (default)"
      echo "  --no-bootstrap      No copiar archivos de Supabase RAG"
      echo "  -h, --help          Mostrar esta ayuda"
      echo ""
      echo "Ejemplos:"
      echo "  ./install.sh .                          # Instalar todo en dir actual"
      echo "  ./install.sh /path/to/project           # Instalar todo en proyecto"
      echo "  ./install.sh --core --workflow           # Solo core + workflow"
      echo "  ./install.sh --stack=react,fastapi       # Solo React y FastAPI"
      exit 0
      ;;
    -*)
      echo -e "${RED}Opcion desconocida: $arg${NC}"
      echo "Usa --help para ver opciones disponibles"
      exit 1
      ;;
    *)
      TARGET="$arg"
      ;;
  esac
done

# --- Detect source ---
# If running from the repo, use local files
# If running via curl/pipe, clone to temp dir
detect_source() {
  # Check if this script is inside the skills-system repo
  local script_path
  script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || script_path=""

  if [ -n "$script_path" ] && [ -d "$script_path/skills" ] && [ -d "$script_path/templates" ]; then
    SCRIPT_DIR="$script_path"
  else
    echo -e "${BLUE}Descargando skills-system...${NC}"
    TEMP_CLONE=$(mktemp -d)
    git clone --depth 1 --quiet https://github.com/RBloomDev/skills-system.git "$TEMP_CLONE"
    SCRIPT_DIR="$TEMP_CLONE"
    echo -e "${GREEN}Descarga completa${NC}"
  fi
}

detect_source

# --- Validate source ---
if [ ! -d "$SCRIPT_DIR/skills/core" ] || [ ! -d "$SCRIPT_DIR/skills/stack" ] || [ ! -d "$SCRIPT_DIR/skills/workflow" ]; then
  echo -e "${RED}Error: directorio fuente incompleto — faltan skills/core, skills/stack o skills/workflow${NC}"
  exit 1
fi

# --- Resolve target ---
TARGET="${TARGET:-.}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
  echo -e "${RED}Error: directorio '$TARGET' no existe${NC}"
  exit 1
}

# --- Apply defaults ---
if $INSTALL_ALL; then
  INSTALL_CORE=true
  INSTALL_STACK=true
  INSTALL_WORKFLOW=true
fi

# --- Source paths ---
SKILLS_SRC="$SCRIPT_DIR/skills"
BOOTSTRAP_SRC="$SCRIPT_DIR/bootstrap"
TEMPLATES_SRC="$SCRIPT_DIR/templates"

# --- Counters ---
CORE_COUNT=0
STACK_COUNT=0
WORKFLOW_COUNT=0

echo ""
echo -e "${BLUE}=== Skills System — Instalando en: $TARGET ===${NC}"
echo ""

# --- Step 1: Create directory structure ---
mkdir -p "$TARGET/.claude/skills/core"
mkdir -p "$TARGET/.claude/skills/stack"
mkdir -p "$TARGET/.claude/skills/workflow"

# --- Step 2: Copy core skills ---
if $INSTALL_CORE && [ -d "$SKILLS_SRC/core" ]; then
  echo -e "${BLUE}[1/6] Instalando skills core...${NC}"
  for skill_dir in "$SKILLS_SRC/core"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      cp -r "${skill_dir%/}" "$TARGET/.claude/skills/core/"
      echo -e "  ${GREEN}+${NC} core/$skill_name"
      CORE_COUNT=$((CORE_COUNT + 1))
    fi
  done
else
  echo -e "${YELLOW}[1/6] Saltando skills core${NC}"
fi

# --- Step 3: Copy stack skills ---
if $INSTALL_STACK && [ -d "$SKILLS_SRC/stack" ]; then
  echo -e "${BLUE}[2/6] Instalando skills stack...${NC}"
  if [ -n "$STACK_FILTER" ]; then
    IFS=',' read -ra STACKS <<< "$STACK_FILTER"
    for s in "${STACKS[@]}"; do
      s=$(echo "$s" | xargs)  # trim whitespace
      if [ -d "$SKILLS_SRC/stack/$s" ]; then
        cp -r "$SKILLS_SRC/stack/$s/" "$TARGET/.claude/skills/stack/$s"
        echo -e "  ${GREEN}+${NC} stack/$s"
        STACK_COUNT=$((STACK_COUNT + 1))
      else
        echo -e "  ${YELLOW}!${NC} stack/$s no encontrado — disponibles:"
        ls "$SKILLS_SRC/stack/" | sed 's/^/    /'
      fi
    done
  else
    for skill_dir in "$SKILLS_SRC/stack"/*/; do
      if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        cp -r "${skill_dir%/}" "$TARGET/.claude/skills/stack/"
        echo -e "  ${GREEN}+${NC} stack/$skill_name"
        STACK_COUNT=$((STACK_COUNT + 1))
      fi
    done
  fi
else
  echo -e "${YELLOW}[2/6] Saltando skills stack${NC}"
fi

# --- Step 4: Copy workflow skills ---
if $INSTALL_WORKFLOW && [ -d "$SKILLS_SRC/workflow" ]; then
  echo -e "${BLUE}[3/6] Instalando skills workflow...${NC}"
  for skill_dir in "$SKILLS_SRC/workflow"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      cp -r "${skill_dir%/}" "$TARGET/.claude/skills/workflow/"
      echo -e "  ${GREEN}+${NC} workflow/$skill_name"
      WORKFLOW_COUNT=$((WORKFLOW_COUNT + 1))
    fi
  done
else
  echo -e "${YELLOW}[3/6] Saltando skills workflow${NC}"
fi

# --- Step 5: Generate CLAUDE.md ---
echo -e "${BLUE}[4/6] Configurando CLAUDE.md...${NC}"
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$TEMPLATES_SRC/CLAUDE.md.tpl" "$TARGET/CLAUDE.md"
  echo -e "  ${GREEN}+${NC} CLAUDE.md creado"
else
  if ! grep -q "<!-- SKILLS_SYSTEM -->" "$TARGET/CLAUDE.md"; then
    echo "" >> "$TARGET/CLAUDE.md"
    cat "$TEMPLATES_SRC/CLAUDE.md.tpl" >> "$TARGET/CLAUDE.md"
    echo -e "  ${GREEN}+${NC} Seccion skills-system agregada a CLAUDE.md existente"
  else
    echo -e "  ${YELLOW}=${NC} CLAUDE.md ya tiene seccion skills-system"
  fi
fi

# --- Step 6: Generate skills catalog ---
echo -e "${BLUE}[5/6] Generando catalogo de skills...${NC}"
CATALOG="$TARGET/.claude/skills-catalog.md"
cat > "$CATALOG" << 'CATALOG_HEADER'
# Skills Catalog

> Auto-generado por skills-system install.sh

CATALOG_HEADER

# Core skills
if [ -d "$TARGET/.claude/skills/core" ] && [ "$(ls -A "$TARGET/.claude/skills/core" 2>/dev/null)" ]; then
  echo "## Core" >> "$CATALOG"
  echo "" >> "$CATALOG"
  echo "| Skill | Descripcion |" >> "$CATALOG"
  echo "|---|---|" >> "$CATALOG"
  for skill_dir in "$TARGET/.claude/skills/core"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      name=$(basename "$skill_dir")
      # Extract first line after "## " that looks like purpose
      trigger=$(grep -i 'Trigger:' "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/.*Trigger:\*\*//' | sed 's/\*\*//g' | xargs)
      [ -z "$trigger" ] && trigger="-"
      echo "| \`$name\` | $trigger |" >> "$CATALOG"
    fi
  done
  echo "" >> "$CATALOG"
fi

# Stack skills
if [ -d "$TARGET/.claude/skills/stack" ] && [ "$(ls -A "$TARGET/.claude/skills/stack" 2>/dev/null)" ]; then
  echo "## Stack" >> "$CATALOG"
  echo "" >> "$CATALOG"
  echo "| Skill | Scope | Descripcion |" >> "$CATALOG"
  echo "|---|---|---|" >> "$CATALOG"
  for skill_dir in "$TARGET/.claude/skills/stack"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      name=$(basename "$skill_dir")
      scope=$(grep -i 'Scope:' "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/.*Scope:\*\*//' | sed 's/\*\*//g' | xargs)
      trigger=$(grep -i 'Trigger:' "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/.*Trigger:\*\*//' | sed 's/\*\*//g' | xargs)
      [ -z "$scope" ] && scope="-"
      [ -z "$trigger" ] && trigger="-"
      echo "| \`$name\` | $scope | $trigger |" >> "$CATALOG"
    fi
  done
  echo "" >> "$CATALOG"
fi

# Workflow skills
if [ -d "$TARGET/.claude/skills/workflow" ] && [ "$(ls -A "$TARGET/.claude/skills/workflow" 2>/dev/null)" ]; then
  echo "## Workflow" >> "$CATALOG"
  echo "" >> "$CATALOG"
  echo "| Skill | Descripcion |" >> "$CATALOG"
  echo "|---|---|" >> "$CATALOG"
  for skill_dir in "$TARGET/.claude/skills/workflow"/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
      name=$(basename "$skill_dir")
      trigger=$(grep -i 'Trigger:' "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/.*Trigger:\*\*//' | sed 's/\*\*//g' | xargs)
      [ -z "$trigger" ] && trigger="-"
      echo "| \`$name\` | $trigger |" >> "$CATALOG"
    fi
  done
  echo "" >> "$CATALOG"
fi

echo -e "  ${GREEN}+${NC} .claude/skills-catalog.md generado"

# --- Step 7: Setup .mcp.json ---
echo -e "${BLUE}[6/6] Configurando Supabase...${NC}"
if [ ! -f "$TARGET/.mcp.json" ]; then
  cp "$TEMPLATES_SRC/mcp.json.tpl" "$TARGET/.mcp.json"
  echo -e "  ${GREEN}+${NC} .mcp.json creado — EDITAR con tu SUPABASE_PROJECT_REF"
else
  echo -e "  ${YELLOW}=${NC} .mcp.json ya existe"
fi

# --- Step 8: Bootstrap Supabase RAG ---
if ! $NO_BOOTSTRAP && [ -d "$BOOTSTRAP_SRC" ]; then
  mkdir -p "$TARGET/.claude/bootstrap"
  cp "$BOOTSTRAP_SRC/"* "$TARGET/.claude/bootstrap/"
  echo -e "  ${GREEN}+${NC} Bootstrap RAG copiado a .claude/bootstrap/"
else
  echo -e "  ${YELLOW}=${NC} Bootstrap RAG saltado"
fi

# --- Summary ---
TOTAL=$((CORE_COUNT + STACK_COUNT + WORKFLOW_COUNT))

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Skills System instalado exitosamente${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "  ${BLUE}Skills instalados:${NC} $TOTAL total"
echo -e "    Core:     $CORE_COUNT"
echo -e "    Stack:    $STACK_COUNT"
echo -e "    Workflow: $WORKFLOW_COUNT"
echo ""
echo -e "  ${BLUE}Archivos creados en:${NC}"
echo "    $TARGET/CLAUDE.md"
echo "    $TARGET/.claude/skills/"
echo "    $TARGET/.claude/skills-catalog.md"
echo "    $TARGET/.claude/bootstrap/"
echo "    $TARGET/.mcp.json"
echo ""
echo -e "${YELLOW}Siguientes pasos:${NC}"
echo "  1. Editar .mcp.json con tu SUPABASE_PROJECT_REF"
echo "  2. Agregar variables de Supabase a .env:"
echo "     SUPABASE_PROJECT_REF=tu-project-ref"
echo "     SUPABASE_URL=https://tu-project-ref.supabase.co"
echo "     SUPABASE_ANON_KEY=eyJ..."
echo "     SUPABASE_SERVICE_ROLE_KEY=eyJ..."
echo "  3. Aplicar migracion SQL: .claude/bootstrap/001-ai-memories-rag.sql"
echo "  4. Deploy Edge Function: .claude/bootstrap/embed-memory.ts"
echo "  5. Revisar y personalizar CLAUDE.md para tu proyecto"
echo ""
