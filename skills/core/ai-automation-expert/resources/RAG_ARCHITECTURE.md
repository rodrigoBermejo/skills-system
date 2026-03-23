# Arquitectura RAG con Supabase pgvector

Patrones de Retrieval Augmented Generation usando el stack del proyecto.

---

## Arquitectura base

```
1. INGEST: Documento → Chunks → Embeddings → Supabase pgvector
2. QUERY:  Pregunta → Embedding → Similarity search → Top-K chunks
3. GENERATE: Pregunta + Chunks relevantes → LLM → Respuesta
```

---

## Paso 1: Ingestion

### Chunking strategy

```
Documento largo → dividir en chunks de 500-1000 tokens
Overlap: 100 tokens entre chunks (evitar cortar contexto)
```

**Reglas de chunking:**
- Respetar limites de parrafo/seccion
- Cada chunk debe ser auto-contenido (entendible sin contexto)
- Metadata por chunk: documento_origen, seccion, posicion

### Generar embeddings

```sql
-- Insertar chunk con metadata
INSERT INTO [tabla_rag] (content, metadata, embedding)
VALUES (
  'Texto del chunk...',
  '{"source": "faq.md", "section": "precios"}',
  -- embedding generado por Edge Function o API
);
```

---

## Paso 2: Retrieval

### Query basica

```sql
SELECT content, metadata,
       1 - (embedding <=> $1::vector) AS similarity
FROM [tabla_rag]
WHERE similarity > 0.5  -- umbral minimo
ORDER BY embedding <=> $1::vector
LIMIT 5;
```

### Query con filtros

```sql
-- Solo buscar en una seccion especifica
SELECT content, metadata,
       1 - (embedding <=> $1::vector) AS similarity
FROM [tabla_rag]
WHERE metadata->>'section' = 'precios'
ORDER BY embedding <=> $1::vector
LIMIT 3;
```

---

## Paso 3: Generation

### Prompt con contexto RAG

```
Eres un asistente de [negocio]. Responde la pregunta del usuario
usando SOLO la informacion proporcionada en el CONTEXTO.

Si la informacion no esta en el contexto, di "No tengo esa informacion,
te conecto con un agente humano."

CONTEXTO:
---
{chunks_relevantes}
---

PREGUNTA: {pregunta_usuario}

RESPUESTA:
```

---

## Casos de uso en RBloom

### 1. FAQ automatizado por vertical

```
Ingestion:
- Cargar FAQ del negocio (servicios, precios, horarios)
- Chunk por pregunta-respuesta (natural)
- Embedir y guardar en tabla faq_embeddings por tenant

Query:
- Contacto pregunta algo por WhatsApp
- Generar embedding de la pregunta
- Buscar top 3 chunks similares filtrado por tenant_id
- Pasar a LLM con prompt RAG

Modelo: Haiku (respuestas cortas basadas en contexto)
```

### 2. Memoria de conversacion a largo plazo

```
Ya implementado en ai_memories:
- Cada memoria es un "documento" con embedding
- Retrieval por similitud semantica
- Usado por memory-manager skill
```

### 3. Base de conocimiento interna

```
Ingestion:
- Documentacion del proyecto (ARQUITECTURA, specs, ADRs)
- Chunk por seccion
- Actualizar embeddings cuando cambia el documento

Query:
- Agente necesita contexto sobre el proyecto
- Buscar chunks relevantes
- Incluir en context window del LLM
```

---

## Tabla para RAG por tenant

```sql
CREATE TABLE tenant_knowledge (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  source TEXT NOT NULL,          -- 'faq', 'servicios', 'politicas'
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding vector(1536),
  created_at TIMESTAMPTZ DEFAULT now(),
  is_active BOOLEAN DEFAULT true
);

CREATE INDEX idx_knowledge_tenant ON tenant_knowledge(tenant_id) WHERE is_active = true;
```

---

## Metricas de calidad RAG

| Metrica | Como medir | Umbral |
|---|---|---|
| Relevancia de chunks | Similarity score promedio | > 0.6 |
| Respuestas "no se" | % de respuestas sin contexto | < 20% |
| Latencia end-to-end | Tiempo desde pregunta hasta respuesta | < 3s |
| Costo por query | Embedding + LLM call | < $0.01 |
