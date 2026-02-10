# 🤖 Sistema de Skills para Agentes IA

Sistema completo de arquitectura de agentes con skills especializadas para **VS Code + Antigravity**, diseñado para transformar el simple _coding_ con IA en ingeniería de software robusta y escalable.

Basado en la metodología de **Gentleman Programming** para desarrollo con IA.

---

## 📋 Tabla de Contenidos

- [¿Qué es Este Sistema?](#-qué-es-este-sistema)
- [Instalación Rápida](#-instalación-rápida)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Cómo Funciona](#-cómo-funciona)
- [Uso Básico](#-uso-básico)
- [Crear Nuevas Skills](#-crear-nuevas-skills)
- [Stack Tecnológico](#-stack-tecnológico)
- [Roadmap](#-roadmap)

---

## 🎯 ¿Qué es Este Sistema?

Este es un sistema de **arquitectura de agentes** que te permite trabajar con IA de forma profesional y escalable mediante:

### 🧠 **Agentes Especializados**

- **Orquestador Root** - Planifica y delega tareas complejas
- **Agente Frontend** - Especialista en UI/UX (React, Angular)
- **Agente Backend** - Especialista en APIs y datos (Express, Java, .NET)

### 📚 **Sistema de Skills**

- Contextos reducidos y específicos que se cargan solo cuando son necesarios
- Evita saturar al agente con información irrelevante
- Mantiene la calidad y reduce alucinaciones

### ⚙️ **Automatización**

- Scripts que configuran automáticamente el entorno
- Sincronización de skills con los agentes correctos
- Compatible con múltiples IAs (Antigravity, Claude, Cursor)

---

## 🚀 Instalación Rápida

> **💡 Nuevo:** Sistema de instalación global disponible. Instala una vez, usa en todos tus proyectos.

### 🌍 Opción 1: Instalación Global (Recomendado)

**Una sola vez:**

```bash
cd ~/Development
git clone <repo-url> global-skills
cd global-skills
./scripts/install-global.sh
source ~/.zshrc  # o source ~/.bashrc
```

**En cada proyecto nuevo:**

```bash
cd ~/Development/mi-proyecto
skills-init
```

Ver [GLOBAL-SETUP.md](./GLOBAL-SETUP.md) para documentación completa.

---

### 📦 Opción 2: Instalación Local (Por Proyecto)

### Prerequisitos

- VS Code con extensión Antigravity instalada
- Git
- Bash (Linux/Mac) o Git Bash (Windows)

### Setup en 3 Pasos

1. **Clona o crea este sistema en tu proyecto:**

```bash
# Si es un proyecto nuevo
mkdir mi-proyecto && cd mi-proyecto
# Copia la estructura de este sistema aquí
```

2. **Ejecuta el script de setup:**

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
```

Este script:

- ✅ Crea enlaces simbólicos entre `/skills` y `.antigravity/skills`
- ✅ Genera configuración para Antigravity
- ✅ Configura el entorno automáticamente

3. **Sincroniza las skills:**

```bash
./scripts/sync.sh
```

Este script:

- ✅ Lee la metadata de cada skill
- ✅ Las registra en los `agents.md` correspondientes
- ✅ Organiza todo según el scope de cada skill

---

## 📁 Estructura del Proyecto

```
mi-proyecto/
├── agents.md                    # 🤖 Orquestador Root
├── frontend/
│   ├── agents.md               # 🎨 Agente Frontend
│   └── src/                    # Código frontend
├── backend/
│   ├── agents.md               # ⚙️ Agente Backend
│   └── src/                    # Código backend
├── skills/
│   ├── public/                 # Skills compartidas
│   │   ├── react/
│   │   ├── express-mongodb/
│   │   └── ...
│   ├── private/                # Skills personalizadas
│   └── examples/               # Skills de referencia
│       └── skill-creator/
├── scripts/
│   ├── setup.sh               # Configuración inicial
│   └── sync.sh                # Sincronización de skills
├── .antigravity/
│   ├── config.json            # Config de Antigravity
│   └── skills/                # Symlink → /skills
└── README.md
```

---

## 🧠 Cómo Funciona

### 1. **Arquitectura Jerárquica**

```
Usuario
   ↓
Orquestador Root (agents.md)
   ↓
┌──────────────┬──────────────┐
│              │              │
Agente         Agente         Agente
Frontend       Backend        [Custom]
   ↓              ↓
Skills         Skills
```

### 2. **Sistema de Skills**

Las skills son contextos especializados que se cargan bajo demanda:

```markdown
# Skill: react

**Scope:** frontend
**Trigger:** cuando se trabaje con React
**Tools:** view, file_create, str_replace

## Propósito

Guiar al agente para crear componentes React siguiendo best practices...
```

### 3. **Scope y Delegación**

- **Scope: `global`** → Se registra en `agents.md` root
- **Scope: `frontend`** → Se registra en `frontend/agents.md`
- **Scope: `backend`** → Se registra en `backend/agents.md`

### 4. **Flujo de Trabajo Típico**

```
1. Usuario: "Necesito un login con JWT"
2. Orquestador analiza: requiere frontend + backend
3. Invoca skill "react" para frontend
4. Invoca skill "express-mongodb" para backend
5. Delega a agentes especializados
6. Integra resultados
```

---

## 💻 Uso Básico

### Empezar a Trabajar

En VS Code con Antigravity, simplemente chatea:

```
Usuario: Leer /agents.md

[El agente lee el contexto y está listo]

Usuario: Necesito crear un endpoint de registro de usuarios

Agente: Entendido. Voy a:
1. Leer la skill de express-mongodb
2. Verificar estructura existente
3. Implementar el endpoint
...
```

### Invocar Skills Explícitamente

```
Usuario: Lee la skill de React antes de empezar

Agente: [Lee /skills/public/react/SKILL.md]
Perfecto, tengo el contexto de React. ¿Qué componente necesitas?
```

### Trabajar con Sub-Agentes

```
Usuario: Implementa autenticación completa

Agente Orquestador:
Plan:
1. SA-Backend: Endpoints de auth
2. SA-Frontend: UI de login
3. Verifico integración

[Delega y coordina]
```

---

## 🎨 Crear Nuevas Skills

### Opción 1: Usar la Skill Creator

```
Usuario: Quiero crear una skill para trabajar con Python y FastAPI

Agente: [Lee /skills/examples/skill-creator/SKILL.md]
Perfecto, voy a crear la skill. Necesito saber:
- ¿Es para backend?
- ¿Qué aspectos quieres cubrir?
...
```

### Opción 2: Manual

1. **Crea la carpeta:**

```bash
mkdir -p skills/public/python-fastapi
```

2. **Crea el archivo SKILL.md:**

```bash
touch skills/public/python-fastapi/SKILL.md
```

3. **Llena con el template:**

```markdown
# Python FastAPI

**Scope:** backend
**Trigger:** cuando se trabaje con Python o FastAPI
**Tools:** view, file_create, bash_tool
**Version:** 1.0.0

## 🎯 Propósito

...
```

4. **Sincroniza:**

```bash
./scripts/sync.sh
```

---

## 🛠️ Stack Tecnológico

### Frontend

- ⚛️ **React** (última versión)
- 🅰️ **Angular** (última versión)
- 🎨 **Tailwind CSS**
- 📦 **State Management:** Redux, Zustand

### Backend

#### Proyectos Rápidos (MERN)

- 🟢 **Node.js + Express**
- 🍃 **MongoDB**
- 🔐 **JWT Authentication**

#### Proyectos Robustos

- ☕ **Java + Spring Boot** con PostgreSQL/MySQL
- 🔷 **C# .NET Core** con SQL Server
- 🎯 **APIs RESTful robustas**

#### Explorando

- 🐍 **Python** (FastAPI, Flask)

---

## 🗓️ Roadmap

### ✅ Fase 1: Estructura Base (COMPLETADO)

- [x] Archivo `agents.md` root
- [x] Agentes de frontend y backend
- [x] Scripts de setup y sync
- [x] Skill Creator
- [x] Configuración de Antigravity

### ✅ Fase 2: Skills Fundamentales MERN (COMPLETADO)

- [x] Skill de React
- [x] Skill de Express + MongoDB
- [x] Skill de Node.js best practices
- [x] Skill de MongoDB Patterns

### ✅ Fase 3: Skills de Frontend Avanzado (COMPLETADO)

- [x] Skill de Angular
- [x] Skill de State Management (Redux, Zustand, NgRx)
- [x] Skill de Frontend Design (UI/UX patterns)
- [x] Skill de Frontend Testing (Jest, RTL, Cypress)

### ✅ Fase 4: Skills de Backend Robusto (COMPLETADO)

- [x] Skill de Java + Spring Boot
- [x] Skill de .NET Core
- [x] Skill de SQL Databases (PostgreSQL, MySQL, SQL Server)
- [x] Skill de API Best Practices

### ✅ Fase 5: Skills de Python (COMPLETADO)

- [x] Skill de Python fundamentals (Python Basics)
- [x] Skill de FastAPI
- [x] Skill de Flask
- [x] Skill de Data processing (pandas, numpy)

### ✅ Fase 6: Skills de Workflow (COMPLETADO) 🎉

- [x] Skill de Git & commits semánticos (Git Workflow)
- [x] Skill de Testing strategies
- [x] Skill de CI/CD (GitHub Actions, GitLab CI, Jenkins)
- [x] Skill de Deployment (Docker, Kubernetes, Cloud)

## 🎉 ¡SISTEMA 100% COMPLETO!

**Total: 21 skills** cubriendo todo el stack de desarrollo moderno desde frontend hasta deployment.

---

## 📚 Recursos Adicionales

### Documentación

- [Guía de Creación de Skills](skills/examples/skill-creator/SKILL.md)
- [Metodología Gentleman Programming](https://www.youtube.com/@Gentleman.Programming)

### Scripts

- `setup.sh` - Configuración inicial del sistema
- `sync.sh` - Sincroniza skills con agents.md

### Configuración

- `.antigravity/config.json` - Configuración de Antigravity
- `agents.md` - Orquestador principal

---

## 🤝 Contribuir

Este sistema está diseñado para crecer. Para agregar nuevas skills:

1. Crea tu skill en `/skills/private/` o `/skills/public/`
2. Sigue el formato de `skill-creator`
3. Ejecuta `./scripts/sync.sh`
4. Prueba con tu agente

---

## 📝 Notas Importantes

### Principios de Diseño

- **Menos es más:** Archivos agents.md de 250-500 líneas
- **Especialización:** Una skill = una responsabilidad
- **Context Management:** Usa skills para no saturar el contexto
- **Delegación:** Sub-agentes para tareas complejas

### Tips

- Siempre lee las skills explícitamente
- Explora antes de codificar
- Mantén consistencia con la cultura del código
- Usa sub-agentes para tareas complejas

---

## 📄 Licencia

MIT License - Siéntete libre de usar y modificar

---

## 🎯 Siguiente Paso

```bash
# Ejecuta setup
./scripts/setup.sh

# Luego en VS Code con Antigravity:
"Leer /agents.md y empecemos a trabajar"
```

**¡Feliz coding con IA! 🚀**
