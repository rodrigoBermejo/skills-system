#!/bin/bash

# 🌍 Global Skills Installation Script
# Este script instala el sistema de skills de manera global para reutilizarlo en todos tus proyectos

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌍 Instalación Global del Sistema de Skills${NC}"
echo ""

# Detectar shell del usuario
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo -e "${RED}❌ No se encontró .zshrc ni .bashrc${NC}"
    exit 1
fi

echo -e "${BLUE}📝 Shell detectado: $SHELL_NAME${NC}"
echo -e "${BLUE}📝 Archivo de configuración: $SHELL_RC${NC}"
echo ""

# Obtener directorio actual (donde está el script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Directorio de instalación global
GLOBAL_SKILLS_DIR="$HOME/Development/global-skills"

echo -e "${YELLOW}📦 Directorio de origen: $SOURCE_DIR${NC}"
echo -e "${YELLOW}🎯 Directorio de instalación: $GLOBAL_SKILLS_DIR${NC}"
echo ""

# Preguntar confirmación
read -p "¿Deseas continuar con la instalación? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Instalación cancelada${NC}"
    exit 0
fi

# Crear directorio Development si no existe
if [ ! -d "$HOME/Development" ]; then
    echo -e "${BLUE}📁 Creando directorio ~/Development...${NC}"
    mkdir -p "$HOME/Development"
fi

# Copiar o actualizar el sistema de skills
if [ -d "$GLOBAL_SKILLS_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio $GLOBAL_SKILLS_DIR ya existe${NC}"
    read -p "¿Deseas actualizarlo? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔄 Actualizando sistema de skills...${NC}"
        rsync -av --exclude='.git' --exclude='node_modules' "$SOURCE_DIR/" "$GLOBAL_SKILLS_DIR/"
        echo -e "${GREEN}✅ Sistema actualizado${NC}"
    else
        echo -e "${YELLOW}⏭️  Saltando actualización${NC}"
    fi
else
    echo -e "${BLUE}📦 Copiando sistema de skills a $GLOBAL_SKILLS_DIR...${NC}"
    cp -r "$SOURCE_DIR" "$GLOBAL_SKILLS_DIR"
    echo -e "${GREEN}✅ Sistema copiado${NC}"
fi

# Hacer ejecutables los scripts
echo ""
echo -e "${BLUE}🔧 Configurando permisos de scripts...${NC}"
chmod +x "$GLOBAL_SKILLS_DIR/scripts/"*.sh
echo -e "${GREEN}✅ Permisos configurados${NC}"

# Agregar alias al archivo de configuración del shell
echo ""
echo -e "${BLUE}🔗 Configurando alias globales...${NC}"

# Verificar si los alias ya existen
if grep -q "# Skills System - Global Aliases" "$SHELL_RC"; then
    echo -e "${YELLOW}⚠️  Los alias ya existen en $SHELL_RC${NC}"
    read -p "¿Deseas actualizarlos? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Eliminar sección antigua
        sed -i.bak '/# Skills System - Global Aliases/,/# End Skills System/d' "$SHELL_RC"
        echo -e "${BLUE}🔄 Alias antiguos eliminados${NC}"
    else
        echo -e "${YELLOW}⏭️  Manteniendo alias existentes${NC}"
        SKIP_ALIASES=true
    fi
fi

if [ "$SKIP_ALIASES" != "true" ]; then
    cat >> "$SHELL_RC" << 'EOF'

# Skills System - Global Aliases
export GLOBAL_SKILLS_DIR="$HOME/Development/global-skills"

# Inicializar skills en un proyecto nuevo
alias skills-init='bash $GLOBAL_SKILLS_DIR/scripts/init-project.sh'

# Sincronizar skills en el proyecto actual
alias skills-sync='bash $GLOBAL_SKILLS_DIR/scripts/sync.sh'

# Validar skills en el proyecto actual
alias skills-validate='bash $GLOBAL_SKILLS_DIR/scripts/validate_skills.sh'

# Ir al directorio de skills globales
alias skills-cd='cd $GLOBAL_SKILLS_DIR'

# Ver skills disponibles
alias skills-list='ls -la $GLOBAL_SKILLS_DIR/skills/public/'

# End Skills System
EOF
    echo -e "${GREEN}✅ Alias agregados a $SHELL_RC${NC}"
fi

# Resumen de instalación
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ ¡Instalación Global Completada!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📍 Ubicación:${NC} $GLOBAL_SKILLS_DIR"
echo ""
echo -e "${BLUE}🎯 Comandos disponibles:${NC}"
echo -e "   ${YELLOW}skills-init${NC}      → Inicializar skills en un proyecto nuevo"
echo -e "   ${YELLOW}skills-sync${NC}      → Sincronizar skills en el proyecto actual"
echo -e "   ${YELLOW}skills-validate${NC}  → Validar estructura de skills"
echo -e "   ${YELLOW}skills-cd${NC}        → Ir al directorio de skills globales"
echo -e "   ${YELLOW}skills-list${NC}      → Ver skills disponibles"
echo ""
echo -e "${BLUE}📋 Próximos pasos:${NC}"
echo -e "   1. ${YELLOW}Recarga tu shell:${NC} source $SHELL_RC"
echo -e "   2. ${YELLOW}Ve a cualquier proyecto:${NC} cd ~/Development/mi-proyecto"
echo -e "   3. ${YELLOW}Inicializa skills:${NC} skills-init"
echo -e "   4. ${YELLOW}Comienza a trabajar:${NC} 'Leer /agents.md'"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} Ejecuta 'skills-init' en cada proyecto nuevo para configurarlo automáticamente"
echo ""
