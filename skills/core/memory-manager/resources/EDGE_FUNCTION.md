# Edge Function: embed-memory

Genera embeddings automaticamente cuando se inserta o actualiza una memoria.

---

## Codigo de la Edge Function

```typescript
// supabase/functions/embed-memory/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  try {
    const { id, content, title } = await req.json()

    if (!id || !content) {
      return new Response(
        JSON.stringify({ error: 'id and content are required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Texto a embedir: titulo + contenido para mejor contexto semantico
    const textToEmbed = `${title}\n\n${content}`

    // Generar embedding via Supabase AI (gte-small)
    // Alternativa: OpenAI text-embedding-3-small
    const embeddingResponse = await fetch(
      `${supabaseUrl}/functions/v1/embedding`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${supabaseKey}`
        },
        body: JSON.stringify({
          input: textToEmbed,
          model: 'gte-small'
        })
      }
    )

    // Fallback: si Supabase AI no esta disponible, usar OpenAI
    let embedding: number[]

    if (embeddingResponse.ok) {
      const data = await embeddingResponse.json()
      embedding = data.embedding
    } else {
      // Fallback a OpenAI
      const openaiKey = Deno.env.get('OPENAI_API_KEY')
      if (!openaiKey) {
        return new Response(
          JSON.stringify({ error: 'No embedding service available' }),
          { status: 503, headers: { 'Content-Type': 'application/json' } }
        )
      }

      const openaiResponse = await fetch(
        'https://api.openai.com/v1/embeddings',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${openaiKey}`
          },
          body: JSON.stringify({
            input: textToEmbed,
            model: 'text-embedding-3-small'
          })
        }
      )

      const openaiData = await openaiResponse.json()
      embedding = openaiData.data[0].embedding
    }

    // Actualizar la memoria con el embedding
    const supabase = createClient(supabaseUrl, supabaseKey)

    const { error } = await supabase
      .from('ai_memories')
      .update({ embedding })
      .eq('id', id)

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true, id, dimensions: embedding.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

---

## Alternativa: Database Webhook Trigger

Si se prefiere automatizar completamente (sin llamar manualmente a la Edge Function):

```sql
-- Crear webhook trigger que llama a la Edge Function al insertar
CREATE OR REPLACE FUNCTION notify_embed_memory()
RETURNS TRIGGER AS $$
BEGIN
  -- Notificar via pg_net (extension de Supabase)
  PERFORM net.http_post(
    url := current_setting('app.supabase_url') || '/functions/v1/embed-memory',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    ),
    body := jsonb_build_object(
      'id', NEW.id,
      'title', NEW.title,
      'content', NEW.content
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger en INSERT y UPDATE de contenido
CREATE TRIGGER trigger_embed_on_insert
  AFTER INSERT ON ai_memories
  FOR EACH ROW
  EXECUTE FUNCTION notify_embed_memory();

CREATE TRIGGER trigger_embed_on_update
  AFTER UPDATE OF content, title ON ai_memories
  FOR EACH ROW
  WHEN (OLD.content IS DISTINCT FROM NEW.content OR OLD.title IS DISTINCT FROM NEW.title)
  EXECUTE FUNCTION notify_embed_memory();
```

**Nota:** Esta alternativa requiere la extension `pg_net` habilitada en Supabase.

---

## Deploy via MCP

```
Usar: mcp__claude_ai_Supabase__deploy_edge_function
  name: embed-memory
  code: [contenido del archivo index.ts de arriba]
```

---

## Variables de entorno necesarias

| Variable | Donde | Valor |
|---|---|---|
| `SUPABASE_URL` | Automatica en Edge Functions | Ya disponible |
| `SUPABASE_SERVICE_ROLE_KEY` | Automatica en Edge Functions | Ya disponible |
| `OPENAI_API_KEY` | Secrets de Supabase (opcional) | Solo si se usa fallback OpenAI |

---

## Test de la Edge Function

```bash
# Invocar manualmente despues de insertar una memoria
curl -X POST https://TU_PROJECT_REF.supabase.co/functions/v1/embed-memory \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [ANON_KEY]" \
  -d '{"id": "[UUID_DE_LA_MEMORIA]", "title": "Test", "content": "Contenido de prueba"}'
```

Respuesta esperada:
```json
{"success": true, "id": "[UUID]", "dimensions": 384}
```
