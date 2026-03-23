# Patrones de Retrieval

Queries de recuperacion de memorias segun el contexto de la tarea.

---

## Por tipo de tarea

### Feature nuevo

```sql
-- Buscar decisiones de arquitectura y patrones relevantes
SELECT type, title, content, metadata,
       1 - (embedding <=> $1::vector) AS similarity
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND type IN ('decision', 'context', 'pattern')
ORDER BY embedding <=> $1::vector
LIMIT 10;
```

### Bug fix

```sql
-- Buscar patrones fallidos y sesiones recientes
SELECT type, title, content, metadata
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND type IN ('pattern', 'session', 'reference')
ORDER BY embedding <=> $1::vector
LIMIT 10;
```

### Arquitectura / Decision

```sql
-- Buscar decisiones previas y patrones
SELECT type, title, content, metadata
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND type IN ('decision', 'pattern')
ORDER BY embedding <=> $1::vector
LIMIT 15;
```

### Inicio de sesion (contexto general)

```sql
-- Obtener estado actual del proyecto + ultimas sesiones
SELECT type, title, content, metadata, updated_at
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND type IN ('context', 'session')
ORDER BY
  CASE WHEN type = 'context' THEN 0 ELSE 1 END,
  updated_at DESC
LIMIT 10;
```

---

## Por modulo

```sql
-- Buscar memorias de un modulo especifico
SELECT type, title, content, metadata
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND metadata->>'modulo' = 'inbox'
ORDER BY updated_at DESC
LIMIT 10;
```

---

## Por tags

```sql
-- Buscar memorias con un tag especifico
SELECT type, title, content, metadata
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND metadata->'tags' ? 'seguridad'
ORDER BY updated_at DESC
LIMIT 10;
```

---

## Busqueda combinada (semantica + filtros)

```sql
-- Buscar por similitud DENTRO de un tipo y modulo
SELECT type, title, content, metadata,
       1 - (embedding <=> $1::vector) AS similarity
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND type = 'decision'
  AND metadata->>'modulo' = 'auth'
ORDER BY embedding <=> $1::vector
LIMIT 5;
```

---

## Fallback sin embeddings

Cuando no hay embeddings disponibles o la Edge Function no esta activa:

```sql
-- Busqueda por texto completo (ILIKE)
SELECT type, title, content, metadata
FROM ai_memories
WHERE is_active = true
  AND project = 'MI_PROYECTO'
  AND (
    title ILIKE '%' || $1 || '%'
    OR content ILIKE '%' || $1 || '%'
  )
ORDER BY updated_at DESC
LIMIT 10;
```

---

## Estadisticas de memoria

```sql
-- Conteo por tipo
SELECT type, COUNT(*) as total,
       COUNT(*) FILTER (WHERE embedding IS NOT NULL) as con_embedding
FROM ai_memories
WHERE is_active = true AND project = 'MI_PROYECTO'
GROUP BY type
ORDER BY total DESC;

-- Memorias proximas a expirar
SELECT type, title, expires_at
FROM ai_memories
WHERE is_active = true
  AND expires_at IS NOT NULL
  AND expires_at < now() + interval '7 days'
ORDER BY expires_at;
```

---

## Tips de retrieval

1. **Siempre incluir tipo en el filtro** — reduce el espacio de busqueda
2. **Combinar semantica + filtros** — embedding para relevancia, metadata para precision
3. **Limit conservador** — 5-10 resultados es suficiente, mas genera ruido
4. **Verificar similarity** — si similarity < 0.5, los resultados no son confiables
5. **Fallback a ILIKE** — si no hay embeddings, busqueda de texto funciona para terminos exactos
