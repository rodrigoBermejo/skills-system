# SISTEMA ORQUESTADOR Y TRANSVERSALES

---

## orchestrator
**Cuando usarlo:** Punto de entrada para tareas complejas (M/L/XL). Clasifica solicitudes, decide que skills activar, coordina la secuencia, y actua como mentor/challenger.

| Recurso | Contenido |
|---|---|
| `skills/orchestrator/SKILL.md` | Protocolo de sesion, tabla de clasificacion, patron challenger, handoff protocol |
| `resources/DECISION_MATRIX.md` | Tabla de cuando usar cada skill con ejemplos reales |
| `resources/MENTOR_PATTERNS.md` | Socratic questioning, devil's advocate, 5 whys, trade-off analysis |

---

## memory-manager
**Cuando usarlo:** Al inicio de sesion (recuperar contexto) y al final (guardar decisiones). Memoria semantica RAG con Supabase pgvector.

| Recurso | Contenido |
|---|---|
| `skills/memory-manager/SKILL.md` | Tipos de memoria, queries SQL, protocolo read/write, reglas de higiene |
| `resources/SCHEMA.md` | Migracion SQL completa para ai_memories + pgvector |
| `resources/EDGE_FUNCTION.md` | Edge Function embed-memory (Supabase AI gte-small) |
| `resources/RETRIEVAL_PATTERNS.md` | Queries de retrieval por tipo de tarea |
| `resources/MEMORY_TYPES.md` | Definicion de cada tipo con ejemplos |

---

## sdd-open-spec
**Cuando usarlo:** Antes de construir cualquier feature. Convierte ideas en specs verificables.

| Recurso | Contenido |
|---|---|
| `skills/sdd-open-spec/SKILL.md` | Ciclo de vida del spec, 3 templates, checklist de calidad |
| `resources/SPEC_EXAMPLES.md` | 3 ejemplos reales completos |
| `resources/REVIEW_CHECKLIST.md` | Checklist extendido + anti-patrones |

---

## mcp-coordinator
**Cuando usarlo:** Deploy de migraciones, edge functions, workflows, debugging con logs.

| Recurso | Contenido |
|---|---|
| `skills/mcp-coordinator/SKILL.md` | Tabla de MCPs, referencia herramientas Supabase |
| `resources/SUPABASE_PATTERNS.md` | Patrones de uso del MCP Supabase |
| `resources/SYNC_WORKFLOWS.md` | Flujos paso a paso por tipo de cambio |

---

## documentation-expert
**Cuando usarlo:** Generar API docs, runbooks, ADRs, changelogs o READMEs.

| Recurso | Contenido |
|---|---|
| `skills/documentation-expert/SKILL.md` | Tipos de docs, principios, audiencias |
| `resources/TEMPLATES.md` | Templates para API endpoint, runbook, ADR, changelog |
| `resources/STYLE_GUIDE.md` | Guia de estilo de escritura tecnica |

---

## ai-automation-expert
**Cuando usarlo:** Disenar agentes IA, optimizar prompts, calcular costos, implementar RAG.

| Recurso | Contenido |
|---|---|
| `skills/ai-automation-expert/SKILL.md` | 5 patrones de agentes, seleccion de modelo, reglas de costo |
| `resources/PROMPT_PATTERNS.md` | 5 patrones de prompt engineering |
| `resources/COST_CALCULATOR.md` | Precios por modelo, formulas de costo |
| `resources/RAG_ARCHITECTURE.md` | Arquitectura RAG con pgvector |

---

## research-expert
**Cuando usarlo:** Decisiones tecnicas informadas, evaluacion de herramientas.

| Recurso | Contenido |
|---|---|
| `skills/research-expert/SKILL.md` | Proceso de investigacion, template de reporte |
| `resources/EVALUATION_FRAMEWORKS.md` | Frameworks de evaluacion por tipo |

---

## security-researcher
**Cuando usarlo:** Auditorias de seguridad proactivas, threat hunting.

| Recurso | Contenido |
|---|---|
| `skills/security-researcher/SKILL.md` | Metodologia STRIDE, checklist de ataque, severidades |
| `resources/ATTACK_VECTORS.md` | Vectores de ataque especificos del stack |
| `resources/OWASP_LLM_CHECKLIST.md` | OWASP Top 10 for LLM Applications |

---

## performance-monitor
**Cuando usarlo:** Diagnosticar problemas de performance, configurar monitoreo.

| Recurso | Contenido |
|---|---|
| `skills/performance-monitor/SKILL.md` | Herramientas, queries PostgreSQL, checklist observabilidad |
| `resources/POSTGRES_DIAGNOSTICS.md` | Queries avanzadas de diagnostico |
| `resources/LOGGING_STANDARDS.md` | Formato JSON estructurado, middleware logging |

---

## marketing-ux
**Cuando usarlo:** Mejorar conversion, copywriting, user journey, personas.

| Recurso | Contenido |
|---|---|
| `skills/marketing-ux/SKILL.md` | Capacidades, principios de copy |
| `resources/COPYWRITING_PATTERNS.md` | Headlines, CTAs, microcopy, copy por vertical |
| `resources/FUNNEL_TEMPLATES.md` | Templates de analisis de funnel |
