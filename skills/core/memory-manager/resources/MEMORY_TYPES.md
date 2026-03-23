# Tipos de Memoria — Definicion y Ejemplos

---

## decision

**Que guardar:** Decisiones de arquitectura, eleccion de herramientas, trade-offs evaluados.
**Cuando guardar:** Despues de tomar una decision que afecta el codigo, stack o proceso.
**TTL:** Sin expiracion (las decisiones son permanentes hasta que se reviertan).
**Max activas:** 100

### Ejemplo

```json
{
  "type": "decision",
  "title": "SSE sobre WebSockets para el inbox",
  "content": "QUE: Se eligio Server-Sent Events en vez de WebSockets para el inbox en tiempo real.\nPOR QUE: SSE es mas simple (unidireccional), no requiere libreria extra, y Express lo soporta nativo. El inbox solo necesita push del servidor al cliente.\nCOMO APLICAR: Para features de real-time unidireccional, preferir SSE. Si se necesita bidireccional (ej: chat con typing indicators), reevaluar WebSockets.",
  "metadata": {
    "modulo": "inbox",
    "fase": "fase-4",
    "tags": ["arquitectura", "real-time"],
    "severity": "important"
  }
}
```

---

## pattern

**Que guardar:** Patrones que funcionaron o fallaron, con la razon.
**Cuando guardar:** Despues de descubrir algo que funciona bien (replicar) o algo que falla (evitar).
**TTL:** Sin expiracion.
**Max activas:** 50

### Ejemplo (exitoso)

```json
{
  "type": "pattern",
  "title": "Validacion Zod en boundary API elimina bugs de tipo",
  "content": "QUE: Validar con Zod en el entry point de cada endpoint elimina toda una categoria de bugs.\nPOR QUE: TypeScript no valida en runtime. Zod convierte inputs desconocidos en tipos seguros antes de tocar la logica.\nCOMO APLICAR: Todo endpoint POST/PUT debe tener validateBody(schema) como primer middleware. El schema vive en schemas/.",
  "metadata": {
    "modulo": "api",
    "tags": ["patron-exitoso", "validacion", "typescript"],
    "severity": "important"
  }
}
```

### Ejemplo (fallido)

```json
{
  "type": "pattern",
  "title": "Mockear DB en tests de integracion da falsa confianza",
  "content": "QUE: Los tests con DB mockeada pasaban pero la migracion en produccion fallo.\nPOR QUE: El mock no refleja constraints reales (CHECK, UNIQUE, foreign keys). La divergencia se acumula.\nCOMO APLICAR: Tests de integracion SIEMPRE contra DB real (Docker). Solo mockear servicios externos (OpenPay, WhatsApp).",
  "metadata": {
    "modulo": "testing",
    "tags": ["patron-fallido", "testing", "base-de-datos"],
    "severity": "critical"
  }
}
```

---

## session

**Que guardar:** Resumen de lo hecho en la sesion, decisiones tomadas, pendientes.
**Cuando guardar:** Al final de cada sesion de trabajo.
**TTL:** 90 dias (las sesiones antiguas pierden relevancia).
**Max activas:** 30

### Ejemplo

```json
{
  "type": "session",
  "title": "Sesion 2026-03-23: Sistema de skills y memoria RAG",
  "content": "QUE: Se disenaron 10 skills nuevos para el sistema orquestador. Se creo la infraestructura de memoria RAG con pgvector.\nPOR QUE: El proyecto necesita un sistema autonomo de desarrollo IA con memoria persistente.\nCOMO APLICAR: Siguiente sesion debe continuar con Wave 2 (sdd-open-spec, mcp-coordinator, documentation-expert).",
  "metadata": {
    "fecha": "2026-03-23",
    "tags": ["skills", "memoria", "rag"],
    "pendientes": ["Wave 2", "deploy edge function", "test de retrieval"]
  },
  "expires_at": "2026-06-21T00:00:00Z"
}
```

---

## context

**Que guardar:** Estado actual del proyecto, fases, avance, bloqueantes.
**Cuando guardar:** Cada vez que hay un avance significativo. ACTUALIZAR, no acumular.
**TTL:** Sin expiracion (pero se sobreescribe).
**Max activas:** 10

### Ejemplo

```json
{
  "type": "context",
  "title": "Estado del proyecto rbloom-automation",
  "content": "QUE: Plataforma web 95% completa (6 fases). Automatizaciones N8N: 2 de 8 flows activos.\nPOR QUE: MVP orientado a vertical salud como primer cliente.\nCOMO APLICAR: Priorizar flows P1 de vertical-salud (02-bienvenida, 03-agendado, 07-atencion-ia).",
  "metadata": {
    "plataforma_pct": 95,
    "n8n_flows_activos": 2,
    "n8n_flows_total": 8,
    "vertical_activa": "salud",
    "bloqueantes": []
  }
}
```

---

## reference

**Que guardar:** Configuraciones de servicios, nombres de credenciales, setup.
**Cuando guardar:** Al configurar algo nuevo o descubrir una referencia util.
**TTL:** Sin expiracion.
**Max activas:** 30

### Ejemplo

```json
{
  "type": "reference",
  "title": "Supabase MCP configurado en VSCode global",
  "content": "QUE: El MCP de Supabase esta en C:\\Users\\rodri\\.claude\\mcp.json como stdio.\nPOR QUE: Disponible en todos los workspaces sin configuracion adicional.\nCOMO APLICAR: Si el MCP no aparece, pedir al usuario que reconecte desde VSCode. Project ref: TU_PROJECT_REF.",
  "metadata": {
    "servicio": "supabase",
    "tipo_config": "mcp",
    "tags": ["infraestructura", "mcp"]
  }
}
```

---

## feedback

**Que guardar:** Correcciones del usuario, preferencias de trabajo, cosas que le molestan o gustan.
**Cuando guardar:** Cuando el usuario corrige un approach o confirma uno no obvio.
**TTL:** Sin expiracion.
**Max activas:** 50

### Ejemplo

```json
{
  "type": "feedback",
  "title": "Usuario prefiere RAG sobre archivos planos para memoria",
  "content": "QUE: Al proponer archivos planos para memoria, el usuario pidio un servicio RAG.\nPOR QUE: Quiere busqueda semantica, no solo indexacion manual.\nCOMO APLICAR: Para cualquier sistema de persistencia de conocimiento, proponer RAG primero. El usuario valora soluciones escalables sobre simples.",
  "metadata": {
    "tags": ["preferencia", "arquitectura"],
    "severity": "important"
  }
}
```
