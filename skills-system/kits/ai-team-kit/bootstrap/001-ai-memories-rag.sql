-- ============================================================
-- AI Team Kit — Migracion: Sistema de Memoria Semantica RAG
-- Copiar a tu proyecto y aplicar via Supabase MCP o Dashboard
-- ============================================================

-- 1. Extensiones
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- 2. Tabla de memorias con embeddings
CREATE TABLE IF NOT EXISTS ai_memories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  project TEXT NOT NULL DEFAULT 'mi-proyecto',  -- CAMBIAR por nombre de tu proyecto
  type TEXT NOT NULL CHECK (type IN (
    'decision', 'pattern', 'session', 'context', 'reference', 'feedback'
  )),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding vector(384),  -- gte-small de Supabase AI (gratis)
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  CONSTRAINT title_not_empty CHECK (char_length(title) > 0),
  CONSTRAINT content_not_empty CHECK (char_length(content) > 0),
  CONSTRAINT title_max_length CHECK (char_length(title) <= 200)
);

-- 3. Indices
CREATE INDEX IF NOT EXISTS idx_memories_type ON ai_memories(type) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_memories_project ON ai_memories(project) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_memories_created ON ai_memories(created_at DESC) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_memories_type_project ON ai_memories(project, type) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_memories_metadata ON ai_memories USING GIN (metadata);

-- 4. Auto-update de updated_at
CREATE OR REPLACE FUNCTION update_ai_memories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_ai_memories_updated_at ON ai_memories;
CREATE TRIGGER trigger_ai_memories_updated_at
  BEFORE UPDATE ON ai_memories
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_memories_updated_at();

-- 5. Auto-embedding via Edge Function (requiere deploy de embed-memory)
-- IMPORTANTE: Reemplazar PROJECT_REF y ANON_KEY con tus valores
CREATE OR REPLACE FUNCTION request_embedding()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM extensions.http_post(
    'https://PROJECT_REF.supabase.co/functions/v1/embed-memory',  -- CAMBIAR PROJECT_REF
    jsonb_build_object('id', NEW.id, 'title', NEW.title, 'content', NEW.content)::text,
    'application/json'
  );
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'embed-memory call failed: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_embed_on_insert ON ai_memories;
CREATE TRIGGER trigger_embed_on_insert
  AFTER INSERT ON ai_memories
  FOR EACH ROW
  EXECUTE FUNCTION request_embedding();

DROP TRIGGER IF EXISTS trigger_embed_on_update ON ai_memories;
CREATE TRIGGER trigger_embed_on_update
  AFTER UPDATE OF content, title ON ai_memories
  FOR EACH ROW
  WHEN (OLD.content IS DISTINCT FROM NEW.content OR OLD.title IS DISTINCT FROM NEW.title)
  EXECUTE FUNCTION request_embedding();
