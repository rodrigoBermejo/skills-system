# OWASP Top 10 for LLM Applications — RBloom

Checklist adaptado al stack del proyecto.

---

## LLM01: Prompt Injection

**Riesgo en RBloom:** ALTO — mensajes de WhatsApp van directo a agentes IA.

- [ ] System prompts tienen defensa explicita contra injection
- [ ] Input del usuario se trata como DATOS, nunca como INSTRUCCIONES
- [ ] El agente no puede ejecutar acciones destructivas sin confirmacion
- [ ] System prompt no se filtra con ninguna tecnica conocida

---

## LLM02: Insecure Output Handling

**Riesgo en RBloom:** MEDIO — respuestas del LLM se envian por WhatsApp y se muestran en inbox.

- [ ] Output del LLM se sanitiza antes de enviar por WhatsApp
- [ ] Output no se ejecuta como codigo en ningun lado
- [ ] Si el output incluye URLs, se validan antes de enviar

---

## LLM03: Training Data Poisoning

**Riesgo en RBloom:** BAJO — usamos APIs, no entrenamos modelos propios.

- [ ] No aplica directamente (usamos Claude/GPT via API)
- [ ] Si se implementa fine-tuning: validar datos de entrenamiento

---

## LLM04: Model Denial of Service

**Riesgo en RBloom:** MEDIO — un atacante podria generar conversaciones costosas.

- [ ] Limite de tokens por conversacion definido
- [ ] Limite de turns por conversacion definido
- [ ] Rate limiting por contacto (no solo por IP)
- [ ] Alerta si costo diario > 2× promedio

---

## LLM05: Supply Chain Vulnerabilities

**Riesgo en RBloom:** BAJO — dependemos de APIs establecidas.

- [ ] Solo usar modelos de proveedores confiables (Anthropic, OpenAI)
- [ ] No descargar modelos de fuentes no verificadas
- [ ] Mantener SDKs actualizados

---

## LLM06: Sensitive Information Disclosure

**Riesgo en RBloom:** ALTO — el agente tiene acceso a datos del negocio.

- [ ] System prompt no incluye datos sensibles del negocio
- [ ] El agente no puede acceder a datos de otros tenants
- [ ] Datos personales (telefono, email) no se incluyen en prompts innecesariamente
- [ ] Logs de conversaciones no exponen datos sensibles

---

## LLM07: Insecure Plugin Design

**Riesgo en RBloom:** MEDIO — agentes tool-using en n8n.

- [ ] Cada tool tiene permisos minimos (Least Capability)
- [ ] Tools no pueden modificar datos de otros tenants
- [ ] Tools destructivos requieren confirmacion humana
- [ ] Max 3-4 tools por agente

---

## LLM08: Excessive Agency

**Riesgo en RBloom:** MEDIO — agentes que agendan citas, envian mensajes.

- [ ] Acciones irreversibles requieren Human in the Loop
- [ ] Agente no puede enviar mas de N mensajes por hora
- [ ] Agente no puede modificar datos sin confirmacion
- [ ] Max iterations definido para tool-using agents

---

## LLM09: Overreliance

**Riesgo en RBloom:** MEDIO — operadores confian en las respuestas del agente.

- [ ] Respuestas del agente claramente marcadas como "generadas por IA"
- [ ] Escalamiento a humano cuando confianza es baja
- [ ] El agente dice "no se" en vez de inventar

---

## LLM10: Model Theft

**Riesgo en RBloom:** BAJO — no tenemos modelos propios.

- [ ] API keys almacenadas en n8n credentials, no en codigo
- [ ] System prompts no expuestos en repositorios publicos
- [ ] Rate limiting para evitar extraccion sistematica de respuestas
