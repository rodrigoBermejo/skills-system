# Guia de estilo — Documentacion RBloom

---

## Tono y voz

- **Profesional pero cercano** — alineado con BRIEF-MARCA.md
- **Segunda persona:** "Puedes configurar..." no "El usuario puede configurar..."
- **Voz activa:** "Ejecuta el comando" no "El comando debe ser ejecutado"
- **Sin jerga innecesaria:** Si hay un termino simple, usarlo
- **Terminos tecnicos en ingles:** endpoint, webhook, middleware, token, etc.
- **Explicaciones en espanol**

---

## Formato

### Titulos
- `#` solo para titulo del documento
- `##` para secciones principales
- `###` para subsecciones
- No usar mas de 3 niveles

### Codigo
- Siempre especificar lenguaje: ```sql, ```typescript, ```bash
- Incluir comentarios solo cuando la logica no es obvia
- Ejemplo funcional > pseudocodigo

### Tablas
- Para estructuras de datos (schemas, configs, parametros)
- Columnas: Campo | Tipo | Requerido | Descripcion
- Alinear con `|` consistente

### Listas
- Numeradas: pasos secuenciales (orden importa)
- Guiones: items sin orden especifico
- Checkboxes: checklists y verificaciones

---

## Longitud maxima

| Tipo de doc | Max lineas | Razon |
|---|---|---|
| API endpoint | 30 | Un vistazo rapido |
| Runbook | 100 | Referencia en emergencia |
| README | 150 | Contexto para nuevo developer |
| ADR | 80 | Decision + razonamiento |
| Changelog entry | 1 | Escaneable |
| Spec | 200 | Completo pero no exhaustivo |

---

## Reglas de contenido

1. **Ejemplo primero** — mostrar el ejemplo, luego explicar
2. **No duplicar** — si algo esta documentado en otro lugar, enlazar
3. **Fecha siempre** — todo doc tiene fecha de creacion/actualizacion
4. **Links relativos** — usar rutas relativas al repo, no absolutas
5. **Sin emojis** — a menos que el usuario lo pida explicitamente
6. **Sin opiniones** — hechos y decisiones, no preferencias personales
