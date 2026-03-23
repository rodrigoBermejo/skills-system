# AI Team Kit — Equipo de Desarrollo IA Autonomo

Kit reutilizable para convertir cualquier proyecto en un equipo de desarrollo IA de alto rendimiento.

## Que incluye

- **10 skills transversales** — orquestador, memoria RAG, SDD, MCP, docs, IA, research, seguridad, performance, UX
- **Migracion SQL** — tabla `ai_memories` con pgvector para memoria semantica
- **Edge Function** — `embed-memory` con Supabase AI gte-small (gratis)
- **Templates** — `.env.example`, `.mcp.json`, `CLAUDE.md` snippet, `skills-catalog` snippet

## Setup rapido (5 minutos)

### 1. Copiar skills al proyecto

```bash
cp -r kits/ai-team-kit/skills/* tu-proyecto/skills/
```

### 2. Configurar Supabase

Agregar a tu `.env`:
```
SUPABASE_PROJECT_REF=tu-project-ref
SUPABASE_URL=https://tu-project-ref.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

Crear `.mcp.json` en la raiz del proyecto:
```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=TU_PROJECT_REF&features=docs,account,database,debugging,development,functions,branching,storage"
    }
  }
}
```

### 3. Aplicar migracion RAG

Ejecutar `bootstrap/001-ai-memories-rag.sql` en Supabase:
- Via MCP: `mcp__claude_ai_Supabase__apply_migration`
- Via Dashboard: SQL Editor → pegar contenido
- Via CLI: `supabase db push`

### 4. Desplegar Edge Function

Ejecutar via MCP: `mcp__claude_ai_Supabase__deploy_edge_function`
- Nombre: `embed-memory`
- Codigo: `bootstrap/embed-memory.ts`

### 5. Agregar skills al CLAUDE.md

Copiar el snippet de `templates/claude-md-snippet.md` al CLAUDE.md de tu proyecto.

### 6. Agregar al skills-catalog

Copiar el snippet de `templates/skills-catalog-snippet.md` al archivo `.claude/skills-catalog.md`.

## Requisitos

- Supabase project (free tier funciona)
- Claude Code con MCP de Supabase configurado
- Git repository

## Skills incluidos

| Skill | Proposito |
|---|---|
| `orchestrator` | Cerebro: clasifica, coordina, mentoriza |
| `memory-manager` | Memoria RAG con pgvector |
| `sdd-open-spec` | Spec Driven Development |
| `mcp-coordinator` | Sincroniza MCPs |
| `documentation-expert` | API docs, runbooks, ADRs |
| `ai-automation-expert` | Agentes IA, prompts, costos |
| `research-expert` | Investigacion tecnica |
| `security-researcher` | Threat hunting ofensivo |
| `performance-monitor` | Observabilidad, diagnostico |
| `marketing-ux` | UX research, copy, funnels |

## Personalizacion

Cada skill usa `project = 'rbloom-automation'` por defecto. Para tu proyecto:

1. Buscar y reemplazar `rbloom-automation` por el nombre de tu proyecto en:
   - `skills/memory-manager/SKILL.md`
   - `bootstrap/001-ai-memories-rag.sql`

2. Actualizar `SUPABASE_PROJECT_REF` en:
   - `skills/mcp-coordinator/SKILL.md`
   - `skills/memory-manager/SKILL.md`
