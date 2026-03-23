# Skills System

Sistema de skills para estandarizar el desarrollo de software en todos los proyectos de la factory. Incluye best practices, protocolos SSDLC, agentes IA orquestados y memoria semantica RAG.

## Instalacion

### Desde clon local

```bash
git clone https://github.com/RBloomDev/skills-system.git
./skills-system/install.sh /ruta/a/tu/proyecto
```

### Via curl

```bash
curl -fsSL https://raw.githubusercontent.com/RBloomDev/skills-system/main/install.sh | bash -s -- /ruta/a/tu/proyecto
```

### Opciones

```
./install.sh                          # Instalar todo en dir actual
./install.sh /path/to/project         # Instalar todo en proyecto
./install.sh --core                   # Solo skills core
./install.sh --stack=react,fastapi    # Skills de stack especificos
./install.sh --workflow               # Solo skills de workflow
./install.sh --no-bootstrap           # Sin Supabase RAG
```

## Que se instala

El instalador crea esta estructura en tu proyecto:

```
tu-proyecto/
├── CLAUDE.md                         # Protocolo SSDLC + tabla de skills
├── .mcp.json                         # Configuracion Supabase MCP
└── .claude/
    ├── skills-catalog.md             # Catalogo auto-generado
    ├── bootstrap/
    │   ├── 001-ai-memories-rag.sql   # Migracion pgvector
    │   └── embed-memory.ts           # Edge Function embeddings
    └── skills/
        ├── core/                     # Orquestacion y equipo IA
        ├── stack/                    # Best practices por tecnologia
        └── workflow/                 # Procesos y metodologia
```

## Skills disponibles (49 total)

### Core (10) — Orquestacion y equipo IA
orchestrator, memory-manager, sdd-open-spec, mcp-coordinator, documentation-expert, ai-automation-expert, research-expert, security-researcher, performance-monitor, marketing-ux

### Stack (20) — Best practices por tecnologia
react, angular, nextjs, frontend-design, frontend-testing, state-management, express-mongodb, fastapi, flask, python-basics, java-spring, dotnet-core, nodejs-best-practices, mongodb-patterns, sql-databases, data-processing, api-best-practices, auth-security, payment-integrations, monorepo-structure

### Workflow (19) — Procesos, roles SDLC y automatizacion
ssdlc, git-workflow, cicd, deployment, testing-strategies, sdlc-product-owner, sdlc-ux-designer, sdlc-qa-engineer, sdlc-tech-lead, sdlc-devops-engineer, sdlc-scrum-master, n8n, n8n-workflow-patterns, n8n-code-javascript, n8n-code-python, n8n-expressions, n8n-node-config, n8n-validation, n8n-mcp-tools

## Post-instalacion

1. Editar `.mcp.json` con tu `SUPABASE_PROJECT_REF`
2. Agregar variables de Supabase a `.env`
3. Aplicar migracion: `.claude/bootstrap/001-ai-memories-rag.sql`
4. Deploy Edge Function: `.claude/bootstrap/embed-memory.ts`
5. Personalizar `CLAUDE.md` para tu proyecto
