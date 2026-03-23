# Skills Catalog

---

# CORE — Orquestacion y Transversales

---

## orchestrator
**Cuando usarlo:** Punto de entrada para tareas complejas (M/L/XL). Clasifica solicitudes, decide que skills activar, coordina la secuencia, y actua como mentor/challenger.

| Recurso | Contenido |
|---|---|
| `skills/core/orchestrator/SKILL.md` | Protocolo de sesion, tabla de clasificacion, patron challenger, handoff protocol |
| `resources/DECISION_MATRIX.md` | Tabla de cuando usar cada skill con ejemplos reales |
| `resources/MENTOR_PATTERNS.md` | Socratic questioning, devil's advocate, 5 whys, trade-off analysis |

---

## memory-manager
**Cuando usarlo:** Al inicio de sesion (recuperar contexto) y al final (guardar decisiones). Memoria semantica RAG con Supabase pgvector.

| Recurso | Contenido |
|---|---|
| `skills/core/memory-manager/SKILL.md` | Tipos de memoria, queries SQL, protocolo read/write, reglas de higiene |
| `resources/SCHEMA.md` | Migracion SQL completa para ai_memories + pgvector |
| `resources/EDGE_FUNCTION.md` | Edge Function embed-memory (Supabase AI gte-small) |
| `resources/RETRIEVAL_PATTERNS.md` | Queries de retrieval por tipo de tarea |
| `resources/MEMORY_TYPES.md` | Definicion de cada tipo con ejemplos |

---

## sdd-open-spec
**Cuando usarlo:** Antes de construir cualquier feature. Convierte ideas en specs verificables.

| Recurso | Contenido |
|---|---|
| `skills/core/sdd-open-spec/SKILL.md` | Ciclo de vida del spec, 3 templates, checklist de calidad |
| `resources/SPEC_EXAMPLES.md` | 3 ejemplos reales completos |
| `resources/REVIEW_CHECKLIST.md` | Checklist extendido + anti-patrones |

---

## mcp-coordinator
**Cuando usarlo:** Deploy de migraciones, edge functions, workflows, debugging con logs.

| Recurso | Contenido |
|---|---|
| `skills/core/mcp-coordinator/SKILL.md` | Tabla de MCPs, referencia herramientas Supabase |
| `resources/SUPABASE_PATTERNS.md` | Patrones de uso del MCP Supabase |
| `resources/SYNC_WORKFLOWS.md` | Flujos paso a paso por tipo de cambio |

---

## documentation-expert
**Cuando usarlo:** Generar API docs, runbooks, ADRs, changelogs o READMEs.

| Recurso | Contenido |
|---|---|
| `skills/core/documentation-expert/SKILL.md` | Tipos de docs, principios, audiencias |
| `resources/TEMPLATES.md` | Templates para API endpoint, runbook, ADR, changelog |
| `resources/STYLE_GUIDE.md` | Guia de estilo de escritura tecnica |

---

## ai-automation-expert
**Cuando usarlo:** Disenar agentes IA, optimizar prompts, calcular costos, implementar RAG.

| Recurso | Contenido |
|---|---|
| `skills/core/ai-automation-expert/SKILL.md` | 5 patrones de agentes, seleccion de modelo, reglas de costo |
| `resources/PROMPT_PATTERNS.md` | 5 patrones de prompt engineering |
| `resources/COST_CALCULATOR.md` | Precios por modelo, formulas de costo |
| `resources/RAG_ARCHITECTURE.md` | Arquitectura RAG con pgvector |

---

## research-expert
**Cuando usarlo:** Decisiones tecnicas informadas, evaluacion de herramientas.

| Recurso | Contenido |
|---|---|
| `skills/core/research-expert/SKILL.md` | Proceso de investigacion, template de reporte |
| `resources/EVALUATION_FRAMEWORKS.md` | Frameworks de evaluacion por tipo |

---

## security-researcher
**Cuando usarlo:** Auditorias de seguridad proactivas, threat hunting.

| Recurso | Contenido |
|---|---|
| `skills/core/security-researcher/SKILL.md` | Metodologia STRIDE, checklist de ataque, severidades |
| `resources/ATTACK_VECTORS.md` | Vectores de ataque especificos del stack |
| `resources/OWASP_LLM_CHECKLIST.md` | OWASP Top 10 for LLM Applications |

---

## performance-monitor
**Cuando usarlo:** Diagnosticar problemas de performance, configurar monitoreo.

| Recurso | Contenido |
|---|---|
| `skills/core/performance-monitor/SKILL.md` | Herramientas, queries PostgreSQL, checklist observabilidad |
| `resources/POSTGRES_DIAGNOSTICS.md` | Queries avanzadas de diagnostico |
| `resources/LOGGING_STANDARDS.md` | Formato JSON estructurado, middleware logging |

---

## marketing-ux
**Cuando usarlo:** Mejorar conversion, copywriting, user journey, personas.

| Recurso | Contenido |
|---|---|
| `skills/core/marketing-ux/SKILL.md` | Capacidades, principios de copy |
| `resources/COPYWRITING_PATTERNS.md` | Headlines, CTAs, microcopy, copy por vertical |
| `resources/FUNNEL_TEMPLATES.md` | Templates de analisis de funnel |

---

# STACK — Best Practices por Tecnologia

---

## Frontend
| Skill | Ruta | Cuando usarlo |
|---|---|---|
| react | `skills/stack/react/SKILL.md` | React 18+, hooks, componentes, Vite |
| angular | `skills/stack/angular/SKILL.md` | Angular 17+, standalone components, signals |
| frontend-design | `skills/stack/frontend-design/SKILL.md` | UI/UX, atomic design, Tailwind, Material UI |
| frontend-testing | `skills/stack/frontend-testing/SKILL.md` | Jest, RTL, Cypress, Playwright |
| state-management | `skills/stack/state-management/SKILL.md` | Redux, Zustand, NgRx, Context API |

## Backend
| Skill | Ruta | Cuando usarlo |
|---|---|---|
| express-mongodb | `skills/stack/express-mongodb/SKILL.md` | MERN stack, JWT, Mongoose, REST APIs |
| java-spring | `skills/stack/java-spring/SKILL.md` | Spring Boot 3+, JPA, Spring Security |
| dotnet-core | `skills/stack/dotnet-core/SKILL.md` | .NET 8+, Entity Framework, ASP.NET |
| fastapi | `skills/stack/fastapi/SKILL.md` | Python async APIs, Pydantic, SQLAlchemy |
| flask | `skills/stack/flask/SKILL.md` | Python web framework tradicional |
| nodejs-best-practices | `skills/stack/nodejs-best-practices/SKILL.md` | Node.js patterns, async, performance |
| api-best-practices | `skills/stack/api-best-practices/SKILL.md` | REST design, versionado, error handling |

## Databases
| Skill | Ruta | Cuando usarlo |
|---|---|---|
| mongodb-patterns | `skills/stack/mongodb-patterns/SKILL.md` | Document schemas, queries, indexing |
| sql-databases | `skills/stack/sql-databases/SKILL.md` | PostgreSQL, MySQL, SQL Server |

## Data & Python
| Skill | Ruta | Cuando usarlo |
|---|---|---|
| python-basics | `skills/stack/python-basics/SKILL.md` | Python fundamentals y patterns |
| data-processing | `skills/stack/data-processing/SKILL.md` | Pandas, NumPy, data science |

## Structure
| Skill | Ruta | Cuando usarlo |
|---|---|---|
| monorepo-structure | `skills/stack/monorepo-structure/SKILL.md` | pnpm workspaces, estructura canonica, LTS |

---

# WORKFLOW — Procesos y Metodologia

---

| Skill | Ruta | Cuando usarlo |
|---|---|---|
| ssdlc | `skills/workflow/ssdlc/SKILL.md` | Protocolo obligatorio antes de cualquier desarrollo |
| git-workflow | `skills/workflow/git-workflow/SKILL.md` | Commits, branching, semantic versioning |
| cicd | `skills/workflow/cicd/SKILL.md` | GitHub Actions, GitLab CI, Jenkins |
| deployment | `skills/workflow/deployment/SKILL.md` | Docker, Kubernetes, cloud deployment |
| testing-strategies | `skills/workflow/testing-strategies/SKILL.md` | QA planning, test pyramids, CI integration |
| n8n | `skills/workflow/n8n/SKILL.md` | Workflow automation, SSDLC para n8n |
