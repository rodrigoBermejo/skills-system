# 🏗️ Arquitectura del Sistema de Skills

Este documento explica visualmente cómo funciona el sistema de skills y agentes.

---

## 📊 Vista General del Sistema

```
┌─────────────────────────────────────────────────────────┐
│                     USUARIO                              │
│                  (VS Code + Antigravity)                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Solicitud
                     ▼
┌─────────────────────────────────────────────────────────┐
│            ORQUESTADOR ROOT (agents.md)                  │
│  • Analiza la solicitud                                  │
│  • Identifica skills necesarias                          │
│  • Planifica ejecución                                   │
│  • Delega a agentes especializados                       │
└──────────┬──────────────────────┬───────────────────────┘
           │                      │
           │                      │
     ┌─────▼─────┐          ┌────▼──────┐
     │  AGENTE   │          │  AGENTE   │
     │ FRONTEND  │          │  BACKEND  │
     │           │          │           │
     │ (React,   │          │ (Express, │
     │  Angular) │          │  Java,    │
     │           │          │  .NET)    │
     └─────┬─────┘          └────┬──────┘
           │                     │
           │ Invoca              │ Invoca
           │ Skills              │ Skills
           ▼                     ▼
     ┌──────────┐          ┌──────────┐
     │  SKILLS  │          │  SKILLS  │
     │ Frontend │          │ Backend  │
     └──────────┘          └──────────┘
```

---

## 🧠 Flujo de Decisión del Orquestador

```
SOLICITUD RECIBIDA
      │
      ▼
┌─────────────┐
│  ¿Simple?   │───── SÍ ───→ Responde directamente
└──────┬──────┘
       │ NO
       ▼
┌──────────────────┐
│  ¿Necesita       │───── NO ───→ Usa conocimiento base
│  Skills?         │
└──────┬───────────┘
       │ SÍ
       ▼
┌──────────────────┐
│  Identifica      │
│  Skills          │
│  necesarias      │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Lee Skills      │
│  explícitamente  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  ¿Tarea          │───── NO ───→ Ejecuta directamente
│  compleja?       │
└──────┬───────────┘
       │ SÍ
       ▼
┌──────────────────┐
│  Crea            │
│  Sub-Agentes     │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Coordina        │
│  ejecución       │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Integra         │
│  resultados      │
└──────────────────┘
```

---

## 📚 Arquitectura de Skills

### Estructura de Carpetas

```
skills/
├── public/              ← Skills compartidas y genéricas
│   ├── react/
│   │   ├── SKILL.md    ← Archivo principal
│   │   ├── examples/   ← Ejemplos opcionales
│   │   └── templates/  ← Plantillas opcionales
│   │
│   ├── express-mongodb/
│   │   └── SKILL.md
│   │
│   ├── angular/
│   │   └── SKILL.md
│   │
│   └── ...
│
├── private/             ← Skills personalizadas del usuario
│   ├── mi-skill-custom/
│   │   └── SKILL.md
│   └── ...
│
└── examples/            ← Skills de referencia
    └── skill-creator/
        └── SKILL.md
```

### Metadata de una Skill

```markdown
# Nombre de la Skill

**Scope:** [frontend|backend|global]
**Trigger:** [Cuándo activarse]
**Tools:** [Herramientas permitidas]
**Version:** [X.Y.Z]

┌──────────────────────────────────┐
│     🎯 Propósito                 │  ← Qué hace esta skill
├──────────────────────────────────┤
│     🔧 Cuándo Usar               │  ← Situaciones de uso
├──────────────────────────────────┤
│     📚 Contexto                  │  ← Knowledge necesario
├──────────────────────────────────┤
│     🚀 Flujo de Trabajo          │  ← Pasos a seguir
├──────────────────────────────────┤
│     💻 Ejemplos                  │  ← Código real
├──────────────────────────────────┤
│     ⚠️  Errores Comunes          │  ← Pitfalls a evitar
└──────────────────────────────────┘
```

---

## 🔄 Sistema de Sincronización

### Antes del Sync

```
skills/public/react/SKILL.md
  Scope: frontend
  Trigger: cuando se trabaje con React

agents.md (root)
  [No conoce la skill de React]

frontend/agents.md
  [No conoce la skill de React]
```

### Ejecutando Sync

```bash
./scripts/sync.sh

1. Lee skills/public/react/SKILL.md
2. Extrae metadata: scope=frontend
3. Identifica target: frontend/agents.md
4. Inyecta referencia en el target
```

### Después del Sync

```
skills/public/react/SKILL.md
  Scope: frontend
  Trigger: cuando se trabaje con React

agents.md (root)
  [Sin cambios]

frontend/agents.md
  ✅ Skills Disponibles:
     - react → Framework React (Ver: /skills/public/react/SKILL.md)
```

---

## 🎭 Sistema de Sub-Agentes

### Anatomía de un Sub-Agente

```
┌────────────────────────────────────────┐
│         ORQUESTADOR ROOT               │
│                                        │
│  Tarea compleja: "Implementar login"  │
│                                        │
│  Crea sub-agentes:                    │
└────────┬───────────────────┬──────────┘
         │                   │
         │                   │
    ┌────▼────┐         ┌────▼────┐
    │ SA-Back │         │ SA-Front│
    │         │         │         │
    │ Contexto│         │ Contexto│
    │ aislado │         │ aislado │
    │         │         │         │
    │ Tarea:  │         │ Tarea:  │
    │ API JWT │         │ UI Login│
    └────┬────┘         └────┬────┘
         │                   │
         │ Devuelve          │ Devuelve
         │ RESUMEN           │ RESUMEN
         │ (no detalles)     │ (no detalles)
         │                   │
    ┌────▼───────────────────▼──────┐
    │     ORQUESTADOR ROOT          │
    │                               │
    │  Integra ambos resúmenes     │
    │  Verifica coherencia         │
    │  Responde al usuario         │
    └───────────────────────────────┘
```

### Beneficios de los Sub-Agentes

```
SIN Sub-Agentes:
┌─────────────────────────────────┐
│   Contexto del Orquestador      │
│                                 │
│   • Planificación               │
│   • Detalles de backend ↓↓↓    │  ← Contexto saturado
│   • Detalles de frontend ↓↓↓   │  ← Alucinaciones
│   • Errores de integración     │
│   • ... demasiada info ...     │
└─────────────────────────────────┘

CON Sub-Agentes:
┌─────────────────────────────────┐
│   Contexto del Orquestador      │
│                                 │
│   • Planificación               │
│   • Resumen backend: ✓ Done    │  ← Contexto limpio
│   • Resumen frontend: ✓ Done   │  ← Sin alucinaciones
│   • Integración verificada     │
└─────────────────────────────────┘
```

---

## 🛠️ Arquitectura de Scripts

### setup.sh - Configuración Inicial

```
Ejecución: ./scripts/setup.sh

Pasos:
1. Detecta directorio del proyecto
   ↓
2. Crea directorio .antigravity/ (si no existe)
   ↓
3. Crea symlink:
   .antigravity/skills → ../skills
   ↓
4. Crea config.json en .antigravity/
   ↓
5. Verifica configuración
   ↓
✅ Sistema listo

Resultado:
┌─────────────────────────┐
│  skills/                │
│    └── public/          │
│         └── react/      │
│              └── SKILL.md │
└─────────────────────────┘
          ↑
          │ symlink
          │
┌─────────────────────────┐
│  .antigravity/          │
│    ├── skills/ ──────┘  │
│    └── config.json      │
└─────────────────────────┘
```

### sync.sh - Sincronización de Skills

```
Ejecución: ./scripts/sync.sh

Para cada SKILL.md encontrada:
1. Lee archivo
   ↓
2. Extrae metadata
   • scope: frontend/backend/global
   • trigger: cuándo activarse
   ↓
3. Determina target según scope:
   frontend → frontend/agents.md
   backend  → backend/agents.md
   global   → agents.md
   ↓
4. Verifica si ya está registrada
   NO → Agrega referencia
   SÍ → Skip
   ↓
5. Siguiente skill
   ↓
✅ Todas sincronizadas
```

---

## 🎯 Stack Tecnológico Soportado

```
┌─────────────────────────────────────────────────────┐
│                  FRONTEND                            │
├─────────────────────────────────────────────────────┤
│  React (latest)         │  State Management         │
│  Angular (latest)       │  • Redux Toolkit          │
│  TypeScript            │  • Zustand                │
│  Tailwind CSS          │  • Context API            │
│  Material UI           │  • NgRx (Angular)         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                  BACKEND                             │
├─────────────────────────────────────────────────────┤
│  MERN (Rápido)         │  Enterprise (Robusto)     │
│  • Node.js             │  • Java Spring Boot       │
│  • Express             │  • .NET Core              │
│  • MongoDB             │  • PostgreSQL             │
│  • JWT Auth            │  • MySQL / SQL Server     │
│                        │                            │
│  Python (Explorando)   │                           │
│  • FastAPI             │                           │
│  • Flask               │                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                  WORKFLOW                            │
├─────────────────────────────────────────────────────┤
│  Git & Commits         │  Testing                  │
│  CI/CD                 │  Deployment               │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Flujo de Datos Completo

```
1. USUARIO SOLICITA
   "Crear login con JWT"
         │
         ▼
2. ORQUESTADOR ANALIZA
   • ¿Qué stacks involucra?
   • ¿Qué skills necesito?
   • ¿Es complejo?
         │
         ▼
3. LEE SKILLS
   [view /skills/public/express-mongodb/SKILL.md]
   [view /skills/public/react/SKILL.md]
         │
         ▼
4. PLANIFICA
   Plan:
   - Backend: User model + JWT
   - Frontend: Login form + auth guard
         │
         ▼
5. CREA SUB-AGENTES
   SA-Backend:
   • Contexto: Express, MongoDB, JWT
   • Tarea: API de autenticación
   
   SA-Frontend:
   • Contexto: React, axios, routing
   • Tarea: UI de login
         │
         ▼
6. EJECUTA EN PARALELO
   SA-Backend           SA-Frontend
   [implementa API]     [implementa UI]
         │                    │
         │                    │
         └────────┬───────────┘
                  ▼
7. INTEGRA RESULTADOS
   • Backend API ✓
   • Frontend UI ✓
   • Validación de integración ✓
         │
         ▼
8. RESPONDE A USUARIO
   "Login implementado:
    - POST /api/auth/register
    - POST /api/auth/login
    - LoginForm component
    - Auth guard en routes"
```

---

## 🔐 Context Management

### Problema: Context Overflow

```
❌ SIN Sistema de Skills:
┌──────────────────────────────────────────┐
│  Contexto del Agente (SATURADO)         │
│                                          │
│  • Toda la info de React                │
│  • Toda la info de Express              │
│  • Toda la info de MongoDB              │
│  • Toda la info de JWT                  │
│  • Toda la info de Testing              │
│  • Toda la info de Deployment           │
│  • ...                                  │
│                                          │
│  Resultado: ALUCINACIONES ↓↓↓           │
└──────────────────────────────────────────┘
```

### Solución: Skills On-Demand

```
✅ CON Sistema de Skills:
┌──────────────────────────────────────────┐
│  Contexto del Orquestador (LIMPIO)      │
│                                          │
│  • Planificación                        │
│  • Referencias a skills                 │
│  • Estado actual                        │
│                                          │
│  Cuando necesita React:                 │
│  [Carga /skills/public/react/SKILL.md] │
│                                          │
│  Cuando necesita Express:               │
│  [Carga /skills/public/express-mongodb/│
│   SKILL.md]                             │
│                                          │
│  Resultado: PRECISIÓN ✓✓✓               │
└──────────────────────────────────────────┘
```

---

## 🎯 Principios de Diseño

### 1. Separación de Responsabilidades

```
Orquestador Root
    ├── Planificación ✓
    ├── Delegación ✓
    └── Integración ✓
    ❌ NO implementa

Agente Frontend
    ├── UI/UX ✓
    └── Client-side ✓
    ❌ NO toca backend

Agente Backend
    ├── APIs ✓
    └── Data ✓
    ❌ NO toca frontend
```

### 2. Concisión del Contexto

```
Tamaño ideal de agents.md: 250-500 líneas

Si crece demasiado:
    ├── Delega más contenido a skills
    ├── Divide en sub-agentes
    └── Refactoriza estructura
```

### 3. Skills Específicas

```
Una skill = Una responsabilidad

✅ BIEN:
    ├── react/SKILL.md (solo React)
    ├── express-mongodb/SKILL.md (solo MERN backend)
    └── git-commits/SKILL.md (solo Git)

❌ MAL:
    └── fullstack/SKILL.md (React + Express + MongoDB + Git...)
```

---

**Esta arquitectura permite:**
- ✅ Contexto limpio y manejable
- ✅ Skills reutilizables y especializadas
- ✅ Delegación inteligente con sub-agentes
- ✅ Escalabilidad para proyectos grandes
- ✅ Mantenimiento sencillo

**Resultado: IA que programa como ingeniero, no como script** 🚀
