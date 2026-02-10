#!/bin/bash

# 🔧 Setup Script - Skills System
# Este script crea enlaces simbólicos (symlinks) desde la carpeta de skills
# hacia las carpetas de configuración de diferentes IAs (Antigravity, Claude, etc.)

set -e

echo "🚀 Iniciando configuración del sistema de skills..."

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Obtener directorio del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$PROJECT_DIR/skills"

echo -e "${BLUE}📁 Directorio del proyecto: $PROJECT_DIR${NC}"
echo -e "${BLUE}📚 Directorio de skills: $SKILLS_DIR${NC}"

# Función para crear symlink
create_symlink() {
    local target_dir=$1
    local link_name=$2
    
    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}⚙️  Creando symlink para $link_name...${NC}"
        
        # Crear directorio si no existe
        if [ ! -d "$target_dir/skills" ]; then
            ln -sf "$SKILLS_DIR" "$target_dir/skills"
            echo -e "${GREEN}✅ Symlink creado: $target_dir/skills -> $SKILLS_DIR${NC}"
        else
            echo -e "${YELLOW}⚠️  Symlink ya existe en $target_dir/skills${NC}"
        fi
    else
        echo -e "${YELLOW}⏭️  Directorio $target_dir no existe, saltando...${NC}"
    fi
}

# Crear directorio .antigravity si no existe
ANTIGRAVITY_DIR="$PROJECT_DIR/.antigravity"
if [ ! -d "$ANTIGRAVITY_DIR" ]; then
    echo -e "${BLUE}📂 Creando directorio .antigravity...${NC}"
    mkdir -p "$ANTIGRAVITY_DIR"
fi

# Crear symlinks para diferentes IAs
echo ""
echo -e "${BLUE}🔗 Creando symlinks para configuraciones de IA...${NC}"
echo ""

# Antigravity
create_symlink "$ANTIGRAVITY_DIR" "Antigravity"

# Claude (por si lo usas también)
CLAUDE_DIR="$PROJECT_DIR/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
fi
create_symlink "$CLAUDE_DIR" "Claude"

# Cursor (por si lo usas)
CURSOR_DIR="$PROJECT_DIR/.cursor"
if [ -d "$CURSOR_DIR" ]; then
    create_symlink "$CURSOR_DIR" "Cursor"
fi

# Verificar symlinks creados
echo ""
echo -e "${BLUE}🔍 Verificando symlinks creados:${NC}"
echo ""

if [ -L "$ANTIGRAVITY_DIR/skills" ]; then
    echo -e "${GREEN}✅ Antigravity: $(readlink $ANTIGRAVITY_DIR/skills)${NC}"
else
    echo -e "${YELLOW}⚠️  Antigravity: No configurado${NC}"
fi

if [ -L "$CLAUDE_DIR/skills" ]; then
    echo -e "${GREEN}✅ Claude: $(readlink $CLAUDE_DIR/skills)${NC}"
else
    echo -e "${YELLOW}⚠️  Claude: No configurado${NC}"
fi

# Crear archivo de configuración de Antigravity
ANTIGRAVITY_CONFIG="$ANTIGRAVITY_DIR/config.json"
if [ ! -f "$ANTIGRAVITY_CONFIG" ]; then
    echo ""
    echo -e "${BLUE}📝 Creando configuración de Antigravity...${NC}"
    cat > "$ANTIGRAVITY_CONFIG" << 'EOF'
{
  "skillsDirectory": "./skills",
  "autoLoadSkills": true,
  "agentsConfig": {
    "rootAgent": "./agents.md",
    "frontendAgent": "./frontend/agents.md",
    "backendAgent": "./backend/agents.md"
  },
  "enabledSkills": [
    "skill-creator",
    "react",
    "angular",
    "express-mongodb",
    "java-spring",
    "dotnet-sqlserver",
    "python-basics",
    "git-commits"
  ]
}
EOF
    echo -e "${GREEN}✅ Configuración creada: $ANTIGRAVITY_CONFIG${NC}"
fi

echo ""
echo -e "${GREEN}✨ ¡Setup completado exitosamente!${NC}"
echo ""
echo -e "${BLUE}📋 Próximos pasos:${NC}"
echo "   1. Ejecuta ./scripts/sync.sh para sincronizar skills"
echo "   2. Comienza a usar el sistema con: 'Leer /agents.md'"
echo "   3. Crea nuevas skills con la skill-creator"
echo ""
echo -e "${YELLOW}💡 Tip: Ejecuta este script cada vez que clones el proyecto${NC}"
