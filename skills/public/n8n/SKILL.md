# n8n - Automatización de Workflows

**Scope:** backend
**Trigger:** cuando se trabaje con n8n, automatización de flujos, workflows, integración de servicios o nodos de IA en n8n
**Tools:** view, file_create, bash_tool, web_search
**Version:** 1.0.0

---

## 🎯 Propósito

Esta skill proporciona las mejores prácticas y guías para diseñar, desarrollar y desplegar flujos de trabajo automatizados usando n8n, con un enfoque especial en la integración de agentes de IA y escalabilidad técnica.

## 🔧 Cuándo Usar Esta Skill

- Diseño de arquitecturas de automatización modulares.
- Integración de LLMs y agentes de IA en flujos de n8n.
- Configuración de manejo de errores y reintentos.
- Despliegue de n8n en modo producción (Queue Mode).

## 📚 Contexto y Conocimiento

### Conceptos Clave

- **Nodos:** Bloques fundamentales de construcción (Triggers, Actions).
- **Workflows:** Conjunto de nodos conectados que ejecutan una lógica.
- **Expressions:** Uso de JavaScript básico para manipular datos entre nodos.
- **Binary Data:** Manejo de archivos (imágenes, PDFs) dentro de los flujos.

### Best Practices

1. **Diseño Modular:** Usa "Execute Workflow" para reusar lógicas complejas.
2. **Naming Conventions:** Nombra cada nodo según su acción específica (ej: `Gmail: Get Latest`).
3. **Manejo de Errores:** Implementa un "Error Workflow" global para notificaciones.
4. **Seguridad:** Usa siempre variables de entorno y el gestor de credenciales nativo.

## 🚀 Flujo de Trabajo

### Paso 1: Planificación

Define el trigger (Webhook, Cron, Evento) y el output esperado. Mapea los servicios externos necesarios.

### Paso 2: Desarrollo e Iteración

Usa el editor visual para conectar nodos. Valida los datos en cada paso usando el panel de "Output".

### Paso 3: Integración de IA

Para flujos agenticos:

- Usa el nodo **AI Agent** con herramientas específicas.
- Define un **System Prompt** estructurado.
- Habilita "Return Intermediate Steps" para debugging.

## 💻 Ejemplos de Código

### Ejemplo 1: JavaScript en un nodo de Código (manipulación de datos)

```javascript
// Limpiar y formatear datos de entrada
return items.map((item) => {
  return {
    json: {
      email: item.json.email.toLowerCase().trim(),
      nombre: item.json.first_name + " " + item.json.last_name,
      fecha_procesado: new Date().toISOString(),
    },
  };
});
```

### Ejemplo 2: Prompt Estructurado para AI Agent

```markdown
# Role

Eres un asistente experto en triaje de soporte técnico.

# Tools

- `get_tickets`: Obtiene tickets abiertos.
- `update_ticket`: Actualiza el estado.

# Rules

- Responde siempre en formato JSON.
- Si el ticket es crítico, escala inmediatamente.
```

## ⚠️ Errores Comunes y Soluciones

| Error                    | Causa                              | Solución                                     |
| ------------------------ | ---------------------------------- | -------------------------------------------- |
| `Memory limit exceeded`  | Procesamiento de archivos grandes  | Aumenta `NODE_OPTIONS=--max-old-space-size`. |
| `Node execution timeout` | Llamadas a APIs lentas             | Aumenta el timeout en los settings del nodo. |
| `Invalid credentials`    | API Key expirada o mal configurada | Verifica el Credentials Manager.             |

## 🔄 Integración con Otras Skills

- **API Best Practices**: Úsala para diseñar webhooks recibidos por n8n.
- **Deployment**: Referencia para configurar Docker y Nginx para n8n.

## 📋 Checklist de Validación

- [ ] ¿El workflow es modular y fácil de leer?
- [ ] ¿Se han configurado los "Error Workflows"?
- [ ] ¿Las credenciales están seguras?
- [ ] ¿Se han validado los outputs de los nodos de IA?

## 📚 Referencias

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [n8n AI Nodes Guide](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.ai-agent/)

---

**Última actualización:** 2026-02-05
**Mantenedor:** Antigravity AI
