# Review Checklist — Spec Quality Gate

Checklist extendido para revisar specs antes de aprobarlos.

---

## Gate obligatorio (todos deben pasar)

- [ ] **Entradas definidas** — Se sabe exactamente que dispara esta funcionalidad
- [ ] **Salidas definidas** — Se sabe exactamente que produce
- [ ] **Limites claros** — INCLUYE y NO INCLUYE estan especificados
- [ ] **CAs minimos** — Al menos 3 criterios de aceptacion
- [ ] **CA negativo** — Al menos 1 CA para caso de error/fallo
- [ ] **CAs verificables** — Cada CA tiene Given/When/Then concreto (no "funciona bien")
- [ ] **Seguridad** — Al menos 1 amenaza identificada con su control
- [ ] **Dependencias** — Requiere y Bloquea estan identificados
- [ ] **Fallos definidos** — Que pasa si la API externa falla, si la DB no responde, etc.

---

## Anti-patrones en specs (rechazar si se encuentran)

| Anti-patron | Ejemplo malo | Correccion |
|---|---|---|
| CA ambiguo | "El sistema funciona correctamente" | "El endpoint retorna 200 con { data: [...] } y status 'active'" |
| Scope infinito | Sin seccion "NO INCLUYE" | Agregar limites explicitos |
| Sin caso negativo | Solo happy path | Agregar CA para input invalido, sin permisos, API caida |
| Seguridad ignorada | Sin seccion de seguridad | Identificar al menos 1 amenaza STRIDE |
| Dependencia implicita | "Asume que auth funciona" | Listar explicitamente: "Requiere: Auth (Fase 1) completado" |
| UI sin wireframe | "Agregar pantalla de settings" | Incluir wireframe textual o flujo de pantallas |
| IA sin limites | "Usar Claude para responder" | Especificar: modelo, max_tokens, system prompt, herramientas |
| Copy-paste de otro spec | Secciones irrelevantes copiadas | Escribir desde cero para el contexto especifico |

---

## Preguntas challenger para review

### Completitud
- "Si le doy este spec a un developer que no conoce el proyecto, ¿puede construirlo sin hacerme preguntas?"
- "¿Que pasa si el usuario hace algo inesperado?"
- "¿Que pasa a las 3am cuando nadie esta monitoreando?"

### Seguridad
- "¿Un usuario puede ver datos de otro tenant?"
- "¿Que pasa si el input es malicioso?"
- "¿Los datos sensibles estan protegidos?"

### Scope
- "¿Esto es lo MINIMO necesario para validar la idea?"
- "¿Se puede partir en algo mas pequeno?"
- "¿Hay algo aqui que deberia ser un spec separado?"

### Consistencia
- "¿Este spec contradice alguna decision previa (ADR)?"
- "¿Sigue los patrones ya establecidos en el proyecto?"
- "¿Reutiliza componentes existentes donde puede?"
