# Monorepo Structure — Estructura Canónica de Proyectos

**Scope:** workflow
**Trigger:** cuando se cree un proyecto nuevo, se mencione estructura de carpetas, reorganización, monorepo, workspace, o cuando un proyecto no tenga CLAUDE.md
**Tools:** view, file_create, str_replace, bash_tool
**Version:** 1.0.0

---

## Propósito

Este skill define la estructura canónica obligatoria para todos los proyectos, tanto SaaS multi-tenant como herramientas internas. Garantiza que cualquier desarrollador — incluyendo juniors — sepa exactamente dónde va cada cosa sin necesidad de preguntar.

---

## POLÍTICA DE VERSIONES LTS — NO NEGOCIABLE

**Regla:** Todo proyecto debe usar la versión LTS más reciente de cada tecnología. Si se detecta una versión desactualizada, **siempre proponer la migración** antes de continuar con la tarea.

### Cómo verificar versiones al entrar a un proyecto

```bash
# Node.js
node --version        # Debe ser LTS activo (verificar en nodejs.org/en/download)
cat .nvmrc            # o .node-version

# pnpm
pnpm --version        # Verificar pnpm.io

# TypeScript
cat package.json | grep typescript

# React
cat apps/web/package.json | grep '"react"'

# .NET
dotnet --version      # Verificar dotnet.microsoft.com/download

# PostgreSQL
psql --version        # Verificar postgresql.org/download
```

### Cómo proponer una migración

Si alguna dependencia está desactualizada, antes de continuar con la tarea original:

```markdown
⚠️ Versión desactualizada detectada

- Actual: Node.js 18.x (LTS expirado)
- Recomendado: Node.js 22.x (LTS activo)

¿Hacemos la migración ahora o la registro como deuda técnica en docs/adrs/?
```

No asumir. Preguntar si migrar ahora o documentar como ADR y continuar.

---

## ESTRUCTURA CANÓNICA

```
my-project/
├── apps/
│   ├── web/                  # React — frontend del tenant/usuario
│   ├── admin/                # React — panel interno de operaciones
│   ├── api/                  # Express — API principal
│   └── services/             # .NET u otros servicios/workers
│
├── packages/
│   ├── shared/               # Tipos, schemas Zod, utils compartidos entre apps
│   ├── ui/                   # Componentes React reutilizables
│   └── config/               # tsconfig, eslint, prettier base compartidos
│
├── automations/              # N8N workflows exportados + scripts de automatización
│
├── infra/
│   ├── docker/               # Dockerfiles por app y docker-compose
│   ├── scripts/              # Scripts de deploy, migraciones DB, seeds
│   └── env/                  # .env.example por app (NUNCA archivos .env reales)
│
├── docs/
│   ├── specs/                # SSDLC specs (un archivo por feature/bugfix)
│   ├── adrs/                 # Architecture Decision Records
│   ├── runbooks/             # Procedimientos operativos (deploy, rollback, incidentes)
│   └── onboarding.md         # Qué necesita saber un dev nuevo para arrancar
│
├── .claude/
│   ├── CLAUDE.md             # Contexto del proyecto para Claude (ver template abajo)
│   └── commands/             # Skills específicas de este proyecto
│
├── .github/
│   └── workflows/            # CI/CD pipelines
│
├── .gitignore
├── .nvmrc                    # Versión de Node.js del proyecto
├── package.json              # Workspace root (ver configuración abajo)
├── pnpm-workspace.yaml
└── turbo.json                # Opcional — si se usa Turborepo
```

---

## REGLAS: DÓNDE VA CADA COSA

| ¿Qué es? | ¿Dónde va? |
|----------|-----------|
| Pantalla o componente de usuario final | `apps/web/src/` |
| Pantalla o componente de operadores internos | `apps/admin/src/` |
| Endpoint REST / middleware | `apps/api/src/` |
| Worker, job, o servicio pesado | `apps/services/` |
| Tipo TypeScript usado en +1 app | `packages/shared/types/` |
| Schema de validación Zod compartido | `packages/shared/schemas/` |
| Función utilitaria usada en +1 app | `packages/shared/utils/` |
| Componente UI compartido entre web y admin | `packages/ui/` |
| Configuración de linting/formato | `packages/config/` |
| Workflow exportado de N8N | `automations/workflows/` |
| Script de automatización | `automations/scripts/` |
| Dockerfile de una app | `infra/docker/[nombre-app].Dockerfile` |
| Docker Compose para desarrollo local | `infra/docker/docker-compose.dev.yml` |
| Script de migración de DB | `infra/scripts/migrations/` |
| Spec de una feature o bugfix | `docs/specs/` |
| Decisión arquitectónica importante | `docs/adrs/` |
| Procedimiento de operación | `docs/runbooks/` |
| Variables de entorno de ejemplo | `infra/env/[nombre-app].env.example` |

---

## CONFIGURACIÓN PNPM WORKSPACES

### `pnpm-workspace.yaml` (raíz)
```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

### `package.json` (raíz)
```json
{
  "name": "my-project",
  "private": true,
  "engines": {
    "node": ">=22.0.0",
    "pnpm": ">=9.0.0"
  },
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test",
    "type-check": "turbo type-check",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,json,md}\""
  },
  "devDependencies": {
    "turbo": "latest",
    "prettier": "latest",
    "typescript": "latest"
  }
}
```

### `package.json` por app (ejemplo `apps/web`)
```json
{
  "name": "@my-project/web",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint src",
    "test": "vitest",
    "type-check": "tsc --noEmit"
  }
}
```

### Convención de nombres de packages internos
```
@[nombre-proyecto]/web
@[nombre-proyecto]/admin
@[nombre-proyecto]/api
@[nombre-proyecto]/shared
@[nombre-proyecto]/ui
```

Importar entre apps:
```ts
import { UserSchema } from '@my-project/shared'
import { Button } from '@my-project/ui'
```

---

## `.nvmrc` (raíz del proyecto)
```
22
```

Siempre apuntar al major LTS activo, no al patch exacto.

---

## TEMPLATE: `.claude/CLAUDE.md` por proyecto

Cada proyecto DEBE tener este archivo. Es lo primero que Claude lee.

```markdown
# [Nombre del Proyecto] — Contexto para Claude

## Stack
- Frontend: React [versión] + TypeScript + Vite
- Backend: Express [versión] + TypeScript / .NET [versión]
- Base de datos: PostgreSQL [versión]
- Automatización: N8N [versión]
- Package manager: pnpm [versión] (workspaces)
- Node.js: [versión LTS]

## Tipo de proyecto
- [ ] SaaS multi-tenant
- [ ] Herramienta interna

## Estructura
Ver skill `/monorepo-structure` para la estructura canónica.

## Comandos principales
\`\`\`bash
pnpm dev          # Levantar todo en desarrollo
pnpm build        # Build completo
pnpm test         # Tests
pnpm lint         # Lint
pnpm type-check   # Type check
\`\`\`

## Variables de entorno
- Ejemplos en `infra/env/`
- Nunca commitear `.env` reales

## Multi-tenancy
[Describir cómo se maneja el tenant: columna en DB, schema separado, subdominio, etc.]

## Convenciones específicas
[Cualquier decisión de este proyecto que se desvíe del estándar]

## Deuda técnica conocida
[Lista de ADRs o docs/specs con estado REJECTED o pendientes]
```

---

## CHECKLIST: Proyecto nuevo

```bash
# 1. Crear estructura
mkdir -p apps/{web,admin,api,services}
mkdir -p packages/{shared,ui,config}
mkdir -p automations/{workflows,scripts}
mkdir -p infra/{docker,scripts,env}
mkdir -p docs/{specs,adrs,runbooks}
mkdir -p .claude/commands
mkdir -p .github/workflows

# 2. Archivos raíz
touch pnpm-workspace.yaml
touch .nvmrc          # contenido: 22
touch .gitignore
touch package.json    # workspace root
touch turbo.json

# 3. Configuración Claude
touch .claude/CLAUDE.md   # Llenar con el template

# 4. Onboarding
touch docs/onboarding.md

# 5. Instalar
pnpm install
```

---

## CHECKLIST: Proyecto existente a migrar

1. **Auditar versiones** — identificar todo lo que está por debajo de LTS
2. **Crear ADR** en `docs/adrs/` para cada migración pendiente
3. **Crear estructura** de carpetas que falte sin mover código aún
4. **Mover gradualmente** — una app a la vez, con su spec en `docs/specs/`
5. **Crear `.claude/CLAUDE.md`** — documentar el estado actual, no el ideal
6. **Priorizar** con el CTO qué migrar primero vs qué queda como deuda técnica documentada

---

## MULTI-TENANCY: Decisiones que deben estar en `.claude/CLAUDE.md`

Documentar explícitamente cuál modelo usa el proyecto:

| Modelo | Descripción | Cuándo usar |
|--------|-------------|-------------|
| `row-level` | Columna `tenant_id` en cada tabla | Más simple, monorepo pequeño |
| `schema-per-tenant` | Schema de PostgreSQL por tenant | Aislamiento fuerte, +complejidad |
| `db-per-tenant` | Base de datos separada por tenant | Máximo aislamiento, costo alto |

El modelo elegido debe estar en un ADR en `docs/adrs/`.

---

*Aplicar en todos los proyectos nuevos. Para proyectos existentes, migrar incrementalmente con spec por cada movimiento.*
