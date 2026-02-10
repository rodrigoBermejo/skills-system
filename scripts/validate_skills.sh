#!/bin/bash

# ✅ Skill Validation Script
# Comprueba que todas las skills sigan el formato y estándares del sistema.

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$PROJECT_DIR/skills"

echo -e "${BLUE}🔍 Iniciando validación de skills en $SKILLS_DIR...${NC}"
echo ""

TOTAL_SKILLS=0
ERRORS=0
WARNINGS=0

validate_skill() {
    local skill_file=$1
    local skill_name=$(basename $(dirname "$skill_file"))
    local error_found=0

    echo -e "${BLUE}📦 Validando: $skill_name${NC}"

    # 1. Verificar metadatos requeridos
    for key in "Scope" "Trigger" "Tools" "Version"; do
        if ! grep -qEi "^\*\*$key:\*\*" "$skill_file"; then
            echo -e "   ${RED}❌ Falta metadato: $key${NC}"
            error_found=1
        fi
    done

    # 2. Verificar secciones obligatorias
    for section in "## 🎯 Propósito" "## 🔧 Cuándo Usar" "## 🚀 Flujo de Trabajo" "## 💻 Ejemplos"; do
        if ! grep -qF "$section" "$skill_file"; then
            echo -e "   ${YELLOW}⚠️  Falta sección recomendada: $section${NC}"
            ((WARNINGS++))
        fi
    done

    # 3. Verificar conteo de líneas
    LINE_COUNT=$(wc -l < "$skill_file")
    if [ "$LINE_COUNT" -gt 500 ]; then
        echo -e "   ${YELLOW}⚠️  Skill muy larga: $LINE_COUNT líneas (recomendado < 500)${NC}"
        ((WARNINGS++))
    fi

    if [ $error_found -eq 1 ]; then
        ((ERRORS++))
    fi
    ((TOTAL_SKILLS++))
    echo ""
}

# Buscar skills
while IFS= read -r skill; do
    validate_skill "$skill"
done < <(find "$SKILLS_DIR" -name "SKILL.md")

# Resumen final
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Resumen de Validación:${NC}"
echo "   ✅ Total skills procesadas: $TOTAL_SKILLS"
echo -e "   ${RED}❌ Errores críticos: $ERRORS${NC}"
echo -e "   ${YELLOW}⚠️  Advertencias: $WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✘ La validación falló. Por favor corrige los errores críticos.${NC}"
    exit 1
else
    echo -e "${GREEN}✔ ¡Todas las skills son válidas!${NC}"
    exit 0
fi
