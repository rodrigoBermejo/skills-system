#!/bin/bash

# 🚀 Project Skills Initialization Script
# Este script inicializa el sistema de skills en un proyecto nuevo

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Inicializando Sistema de Skills en el Proyecto${NC}"
echo ""

# Verificar que estamos en un directorio de proyecto
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo -e "${BLUE}📁 Proyecto: $PROJECT_NAME${NC}"
echo -e "${BLUE}📍 Ubicación: $PROJECT_DIR${NC}"
echo ""

# Verificar que existe el directorio de skills globales
GLOBAL_SKILLS_DIR="${GLOBAL_SKILLS_DIR:-$HOME/Development/global-skills}"

if [ ! -d "$GLOBAL_SKILLS_DIR" ]; then
    echo -e "${RED}❌ Error: No se encontró el directorio de skills globales${NC}"
    echo -e "${YELLOW}💡 Ejecuta primero: cd ~/Development/global-skills && ./scripts/install-global.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Skills globales encontradas en: $GLOBAL_SKILLS_DIR${NC}"
echo ""

# Preguntar confirmación
read -p "¿Deseas inicializar skills en este proyecto? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Inicialización cancelada${NC}"
    exit 0
fi

# 1. Crear directorio .antigravity si no existe
echo -e "${BLUE}📂 Configurando .antigravity...${NC}"
ANTIGRAVITY_DIR="$PROJECT_DIR/.antigravity"
mkdir -p "$ANTIGRAVITY_DIR"

# 2. Crear symlink a skills globales
if [ -L "$ANTIGRAVITY_DIR/skills" ]; then
    echo -e "${YELLOW}⚠️  Symlink a skills ya existe${NC}"
    CURRENT_LINK=$(readlink "$ANTIGRAVITY_DIR/skills")
    echo -e "${YELLOW}   Apunta a: $CURRENT_LINK${NC}"
else
    ln -sf "$GLOBAL_SKILLS_DIR/skills/public" "$ANTIGRAVITY_DIR/skills"
    echo -e "${GREEN}✅ Symlink creado: .antigravity/skills -> $GLOBAL_SKILLS_DIR/skills/public${NC}"
fi

# 3. Crear directorio de skills privadas del proyecto
echo ""
echo -e "${BLUE}📂 Configurando skills privadas del proyecto...${NC}"
mkdir -p "$PROJECT_DIR/skills/private"
echo -e "${GREEN}✅ Directorio creado: skills/private/${NC}"

# Crear README en skills/private
cat > "$PROJECT_DIR/skills/private/README.md" << 'EOF'
# Skills Privadas del Proyecto

Este directorio contiene skills específicas de este proyecto que no se comparten globalmente.

## Estructura

```
skills/private/
├── mi-skill-custom/
│   └── SKILL.md
└── otra-skill/
    └── SKILL.md
```

## Crear una Nueva Skill Privada

1. Usa el comando en Antigravity: "Usa la skill-creator para crear una skill de [tecnología]"
2. Especifica que debe ser una skill privada
3. La skill se creará en `skills/private/[nombre]/`

## Diferencia entre Skills Globales y Privadas

- **Globales** (`~/.antigravity/skills/`): Compartidas entre todos tus proyectos
- **Privadas** (`./skills/private/`): Específicas de este proyecto únicamente
EOF

# 4. Copiar templates de agents.md si no existen
echo ""
echo -e "${BLUE}📝 Configurando archivos de agentes...${NC}"

# agents.md principal
if [ ! -f "$PROJECT_DIR/agents.md" ]; then
    cp "$GLOBAL_SKILLS_DIR/agents.md" "$PROJECT_DIR/agents.md"
    echo -e "${GREEN}✅ Creado: agents.md${NC}"
else
    echo -e "${YELLOW}⚠️  agents.md ya existe, no se sobrescribe${NC}"
fi

# frontend/agents.md
if [ ! -d "$PROJECT_DIR/frontend" ]; then
    mkdir -p "$PROJECT_DIR/frontend"
fi

if [ ! -f "$PROJECT_DIR/frontend/agents.md" ]; then
    if [ -f "$GLOBAL_SKILLS_DIR/frontend/agents.md" ]; then
        cp "$GLOBAL_SKILLS_DIR/frontend/agents.md" "$PROJECT_DIR/frontend/agents.md"
        echo -e "${GREEN}✅ Creado: frontend/agents.md${NC}"
    else
        # Crear un template básico si no existe en global-skills
        cat > "$PROJECT_DIR/frontend/agents.md" << 'EOF'
# 🎨 Frontend Agent

Agente especializado en desarrollo frontend.

## Responsabilidades

- Implementación de componentes UI
- Gestión de estado
- Integración con APIs
- Testing de componentes

## Skills Disponibles

<!-- Las skills se sincronizarán automáticamente con skills-sync -->

EOF
        echo -e "${GREEN}✅ Creado: frontend/agents.md (template básico)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  frontend/agents.md ya existe, no se sobrescribe${NC}"
fi

# backend/agents.md
if [ ! -d "$PROJECT_DIR/backend" ]; then
    mkdir -p "$PROJECT_DIR/backend"
fi

if [ ! -f "$PROJECT_DIR/backend/agents.md" ]; then
    if [ -f "$GLOBAL_SKILLS_DIR/backend/agents.md" ]; then
        cp "$GLOBAL_SKILLS_DIR/backend/agents.md" "$PROJECT_DIR/backend/agents.md"
        echo -e "${GREEN}✅ Creado: backend/agents.md${NC}"
    else
        # Crear un template básico si no existe en global-skills
        cat > "$PROJECT_DIR/backend/agents.md" << 'EOF'
# ⚙️ Backend Agent

Agente especializado en desarrollo backend.

## Responsabilidades

- Implementación de APIs
- Gestión de bases de datos
- Autenticación y autorización
- Testing de endpoints

## Skills Disponibles

<!-- Las skills se sincronizarán automáticamente con skills-sync -->

EOF
        echo -e "${GREEN}✅ Creado: backend/agents.md (template básico)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  backend/agents.md ya existe, no se sobrescribe${NC}"
fi

# 5. Crear .gitignore si no existe
echo ""
echo -e "${BLUE}📝 Configurando .gitignore...${NC}"

if [ ! -f "$PROJECT_DIR/.gitignore" ]; then
    cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Antigravity
.antigravity/

# Skills privadas (opcional - descomenta si no quieres versionar)
# skills/private/

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.log
EOF
    echo -e "${GREEN}✅ Creado: .gitignore${NC}"
else
    # Verificar si .antigravity está en .gitignore
    if ! grep -q ".antigravity" "$PROJECT_DIR/.gitignore"; then
        echo "" >> "$PROJECT_DIR/.gitignore"
        echo "# Antigravity" >> "$PROJECT_DIR/.gitignore"
        echo ".antigravity/" >> "$PROJECT_DIR/.gitignore"
        echo -e "${GREEN}✅ Agregado .antigravity/ a .gitignore${NC}"
    else
        echo -e "${YELLOW}⚠️  .gitignore ya contiene .antigravity${NC}"
    fi
fi

# 6. Ejecutar sincronización de skills
echo ""
echo -e "${BLUE}🔄 Sincronizando skills...${NC}"
if [ -f "$GLOBAL_SKILLS_DIR/scripts/sync.sh" ]; then
    bash "$GLOBAL_SKILLS_DIR/scripts/sync.sh"
else
    echo -e "${YELLOW}⚠️  Script de sincronización no encontrado${NC}"
fi

# Resumen
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ ¡Proyecto Inicializado Exitosamente!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📁 Estructura creada:${NC}"
echo "   ├── .antigravity/"
echo "   │   └── skills -> $GLOBAL_SKILLS_DIR/skills/public"
echo "   ├── skills/"
echo "   │   └── private/"
echo "   ├── agents.md"
echo "   ├── frontend/"
echo "   │   └── agents.md"
echo "   └── backend/"
echo "       └── agents.md"
echo ""
echo -e "${BLUE}🎯 Próximos pasos:${NC}"
echo -e "   1. ${YELLOW}Abre VS Code con Antigravity${NC}"
echo -e "   2. ${YELLOW}Chatea:${NC} 'Leer /agents.md'"
echo -e "   3. ${YELLOW}Comienza a desarrollar${NC} con skills globales disponibles"
echo ""
echo -e "${BLUE}💡 Comandos útiles:${NC}"
echo -e "   ${YELLOW}skills-sync${NC}      → Re-sincronizar skills"
echo -e "   ${YELLOW}skills-list${NC}      → Ver skills globales disponibles"
echo -e "   ${YELLOW}skills-validate${NC}  → Validar estructura de skills"
echo ""
