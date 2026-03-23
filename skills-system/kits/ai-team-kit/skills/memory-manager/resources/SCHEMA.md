# Schema: ai_memories (Supabase pgvector)

Migracion completa para el sistema de memoria RAG.

---

## Migracion SQL

```sql
-- ============================================================
-- Migracion: Sistema de Memoria Semantica RAG
-- Proyecto: rbloom-automation
-- Dependencia: extension pgvector
-- ============================================================

-- 1. Habilitar extension pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Tabla principal de memorias
CREATE TABLE IF NOT EXISTS ai_memories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identificacion
  project TEXT NOT NULL DEFAULT 'mi-proyecto',
  type TEXT NOT NULL CHECK (type IN (
    'decision',   -- decisiones de arquitectura, tools, trade-offs
    'pattern',    -- patrones exitosos o fallidos con razon
    'session',    -- resumenes de sesion de trabajo
    'context',    -- estado del proyecto, avance, bloqueantes
    'reference',  -- config de servicios, setup, credenciales (nombres)
    'feedback'    -- correcciones del usuario, preferencias
  )),

  -- Contenido
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',

  -- Embedding para busqueda semantica
  embedding vector(384),

  -- Lifecycle
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ,       -- TTL opcional (null = sin expiracion)
  is_active BOOLEAN DEFAULT true,

  -- Constraints
  CONSTRAINT title_not_empty CHECK (char_length(title) > 0),
  CONSTRAINT content_not_empty CHECK (char_length(content) > 0),
  CONSTRAINT title_max_length CHECK (char_length(title) <= 200)
);

-- 3. Comentarios de tabla
COMMENT ON TABLE ai_memories IS 'Memoria semantica RAG para agentes IA del proyecto rbloom-automation';
COMMENT ON COLUMN ai_memories.type IS 'Tipo de memoria: decision, pattern, session, context, reference, feedback';
COMMENT ON COLUMN ai_memories.embedding IS 'Vector de 1536 dimensiones generado por Edge Function embed-memory';
COMMENT ON COLUMN ai_memories.metadata IS 'JSONB con modulo, fase, tags, related_spec, severity';

-- 4. Indices para busqueda semantica
-- Nota: ivfflat requiere datos existentes para ser optimo.
-- Para tablas con < 1000 rows, usar busqueda exacta (sin indice ivfflat).
-- Cuando la tabla supere 1000 rows, crear:
-- CREATE INDEX idx_memories_embedding ON ai_memories
--   USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- 5. Indices para filtrado rapido
CREATE INDEX idx_memories_type ON ai_memories(type) WHERE is_active = true;
CREATE INDEX idx_memories_project ON ai_memories(project) WHERE is_active = true;
CREATE INDEX idx_memories_created ON ai_memories(created_at DESC) WHERE is_active = true;
CREATE INDEX idx_memories_type_project ON ai_memories(project, type) WHERE is_active = true;

-- 6. Indice GIN para busqueda en metadata JSONB
CREATE INDEX idx_memories_metadata ON ai_memories USING GIN (metadata);

-- 7. Indice para busqueda de texto (fallback sin embeddings)
CREATE INDEX idx_memories_title_trgm ON ai_memories USING GIN (title gin_trgm_ops);

-- Nota: si la extension pg_trgm no esta disponible, usar ILIKE como fallback

-- 8. Funcion para actualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_ai_memories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ai_memories_updated_at
  BEFORE UPDATE ON ai_memories
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_memories_updated_at();

-- 9. RLS (Row Level Security) - opcional si se usan multiples proyectos
-- ALTER TABLE ai_memories ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "project_isolation" ON ai_memories
--   USING (project = current_setting('app.current_project', true));
```

---

## Verificacion post-migracion

```sql
-- Verificar que la tabla existe
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ai_memories'
ORDER BY ordinal_position;

-- Verificar que pgvector esta habilitado
SELECT * FROM pg_extension WHERE extname = 'vector';

-- Verificar indices
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'ai_memories';

-- Test de insercion
INSERT INTO ai_memories (project, type, title, content, metadata)
VALUES (
  'rbloom-automation',
  'context',
  'Test de migracion',
  'QUE: Se creo la tabla ai_memories con pgvector.\nPOR QUE: Verificar que la migracion funciona.\nCOMO APLICAR: Eliminar esta memoria despues del test.',
  '{"test": true}'
)
RETURNING id, type, title, created_at;
```

---

## Notas de mantenimiento

- **VACUUM:** Ejecutar periodicamente para limpiar dead tuples despues de updates/deletes masivos
- **Indice ivfflat:** Crear cuando la tabla supere 1000 rows para optimizar busquedas vectoriales
- **pg_trgm:** Si no esta disponible, las busquedas de texto usan ILIKE (mas lento pero funcional)
