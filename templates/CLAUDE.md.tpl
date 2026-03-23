<!-- SKILLS_SYSTEM -->
## Protocolo de Desarrollo

Este proyecto opera bajo el protocolo **SSDLC** (Secure Software Development Life Cycle).
Protocolo completo: `.claude/skills/workflow/ssdlc/SKILL.md`

### Principios Rectores
- **Security by Design** — la seguridad es propiedad de cada linea de codigo
- **Shift Left** — detectar y resolver problemas lo mas temprano posible
- **Spec Driven Development** — nada se construye sin spec aprobado (ver skill `sdd-open-spec`)
- **Zero Trust** — validar todo input, servicio o entorno antes de confiar
- **Least Privilege** — solicitar solo los permisos minimos necesarios
- **Fail Securely** — los errores resultan en estado seguro, nunca en exposicion

### Sistema de Skills

Este proyecto usa el sistema de skills RBloom. Los skills estan en `.claude/skills/`:

| Categoria | Ruta | Proposito |
|-----------|------|-----------|
| Core | `.claude/skills/core/` | Orquestacion, memoria RAG, specs, seguridad, docs (10 skills) |
| Stack | `.claude/skills/stack/` | Best practices por tecnologia — React, Next.js, Spring, FastAPI, etc. (20 skills) |
| Workflow | `.claude/skills/workflow/` | SSDLC, roles SDLC, Git, CI/CD, n8n automation (19 skills) |

### Skills Core — Tabla de Referencia Rapida

| Situacion | Skill |
|---|---|
| Inicio de cualquier tarea compleja (M/L/XL) | `orchestrator` |
| Guardar/recuperar contexto entre sesiones (RAG pgvector) | `memory-manager` |
| Crear spec antes de codear (SDD) | `sdd-open-spec` |
| Coordinar MCPs (n8n, Supabase, postgres) | `mcp-coordinator` |
| Investigar antes de decidir | `research-expert` |
| UX research, copy, conversion | `marketing-ux` |
| Disenar agentes IA, optimizar costos LLM | `ai-automation-expert` |
| Diagnosticar/monitorear produccion | `performance-monitor` |
| Auditoria de seguridad proactiva | `security-researcher` |
| Documentar (API, runbooks, ADRs) | `documentation-expert` |

Ver catalogo completo en [.claude/skills-catalog.md](.claude/skills-catalog.md)

### Memoria (RAG)

Este proyecto usa Supabase pgvector para memoria semantica.
- Schema: `.claude/bootstrap/001-ai-memories-rag.sql`
- Edge function: `.claude/bootstrap/embed-memory.ts`
- Patrones de uso: ver skill `memory-manager`

### Reglas No Negociables
- Nunca hardcodear secrets, tokens, API keys o passwords
- Todos los inputs externos se validan antes de usar
- Los errores se capturan explicitamente, nunca se swallowean
- Tests son obligatorios para codigo nuevo
- Commits atomicos siguiendo Conventional Commits
<!-- /SKILLS_SYSTEM -->
