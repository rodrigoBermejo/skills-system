# Decision Matrix — Cuando usar cada skill

Tabla extendida con ejemplos reales del proyecto rbloom-automation.

---

## Skills por dominio

### N8N (Automatizaciones)

| Situacion real | Skill(s) | Ejemplo |
|---|---|---|
| Construir workflow desde cero | `n8n-core` + `n8n-workflow-patterns` | "Crear el flow de bienvenida-calificacion para vertical-salud" |
| Configurar un nodo especifico | `n8n-node-configuration` | "Configurar el nodo Postgres para insertar con RETURNING" |
| Escribir logica en Code node | `n8n-code-javascript` | "Parsear la respuesta de OpenAI y extraer JSON" |
| Escribir expresiones en campos | `n8n-expression-syntax` | "Acceder al body del webhook en un campo Set" |
| Validar antes de publicar | `n8n-validation-expert` | "Revisar el workflow antes de deploy" |
| Buscar nodos o templates via MCP | `n8n-mcp-tools-expert` | "Buscar si hay un nodo de WhatsApp Business" |
| Escribir Python en Code node | `n8n-code-python` | "Calcular hash SHA-256 del webhook payload" |

### Plataforma Web

| Situacion real | Skill(s) | Ejemplo |
|---|---|---|
| Pagina Next.js nueva | `platform-nextjs` | "Crear la pagina de settings del dashboard" |
| Endpoint Express nuevo | `platform-express-api` | "Agregar endpoint para listar contactos" |
| Componente UI | `platform-ui-system` | "Crear componente de tabla paginada" |
| Auth, JWT, permisos | `platform-security` | "Agregar role guard para admin" |
| Query PostgreSQL | `platform-postgres` | "Implementar cursor pagination en conversaciones" |
| Integracion OpenPay | `platform-openpay` | "Agregar webhook de pago exitoso" |

### SDLC (Proceso)

| Situacion real | Skill(s) | Ejemplo |
|---|---|---|
| Definir que construir | `sdlc-product-owner` | "Crear spec para feature de reportes" |
| Disenar UX/wireframe | `sdlc-ux-designer` | "Wireframe para el wizard de onboarding" |
| Escribir tests | `sdlc-qa-engineer` | "Plan de tests para el modulo de campanas" |
| Code review | `sdlc-tech-lead` | "Review del PR de inbox real-time" |
| Deploy a produccion | `sdlc-devops-engineer` | "Configurar Docker Compose para produccion" |
| Planificar sprint | `sdlc-scrum-master` | "Planificar sprint 4 del MVP" |

### Orquestador y Transversales

| Situacion real | Skill(s) | Ejemplo |
|---|---|---|
| Cualquier tarea compleja | `orchestrator` | "Necesito agregar un modulo de reportes completo" |
| Guardar/recuperar contexto | `memory-manager` | "Que decidimos sobre el sistema de pagos?" |
| Crear spec antes de codear | `sdd-open-spec` | "Quiero construir notificaciones push" |
| Sincronizar con Supabase/n8n | `mcp-coordinator` | "Aplicar la migracion a Supabase" |
| Investigar alternativa tecnica | `research-expert` | "Que gateway de pago soporta SPEI mejor?" |
| Mejorar UX/conversion | `marketing-ux` | "Optimizar el funnel de la landing" |
| Disenar agente IA | `ai-automation-expert` | "Disenar el agente de atencion al cliente" |
| Diagnosticar lentitud | `performance-monitor` | "El inbox tarda 5s en cargar" |
| Auditar seguridad | `security-researcher` | "Revisar si hay vulnerabilidades en el checkout" |
| Documentar | `documentation-expert` | "Crear documentacion de la API para partners" |

---

## Combinaciones frecuentes

| Escenario | Cadena de skills |
|---|---|
| Feature completo (plataforma) | `orchestrator` → `sdd-open-spec` → `sdlc-product-owner` → `sdlc-ux-designer` → `platform-nextjs` + `platform-express-api` → `sdlc-qa-engineer` → `sdlc-tech-lead` |
| Workflow N8N nuevo | `orchestrator` → `sdd-open-spec` → `n8n-core` → `n8n-workflow-patterns` → `n8n-code-javascript` → `n8n-validation-expert` → `mcp-coordinator` |
| Bug fix rapido | `orchestrator` → skill tecnico → `sdlc-qa-engineer` |
| Decision arquitectural | `orchestrator` → `research-expert` → `sdlc-tech-lead` (ADR) → `memory-manager` |
| Optimizacion performance | `orchestrator` → `performance-monitor` → skill tecnico → `sdlc-tech-lead` |
| Audit de seguridad | `orchestrator` → `security-researcher` → `platform-security` → `sdlc-tech-lead` |
| Deploy completo | `orchestrator` → `sdlc-qa-engineer` → `mcp-coordinator` → `sdlc-devops-engineer` |

---

## Cuando NO usar un skill

| Situacion | Hacer en vez de skill |
|---|---|
| Pregunta simple de 1 linea | Responder directamente |
| Typo en un archivo | Editar directamente |
| Leer un archivo para entender | Read tool directo |
| Git status, commit, push | Bash directo |
| Instalar una dependencia | Bash directo |
