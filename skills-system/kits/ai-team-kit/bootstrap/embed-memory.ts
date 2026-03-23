// Edge Function: embed-memory
// Genera embeddings con Supabase AI gte-small (384 dims, gratis)
// Deploy via: mcp__claude_ai_Supabase__deploy_edge_function

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req: Request) => {
  try {
    const { id, content, title } = await req.json();

    if (!id || !content) {
      return new Response(
        JSON.stringify({ error: "id and content are required" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const textToEmbed = title ? `${title}\n\n${content}` : content;

    // @ts-ignore - Supabase.ai is available in Edge Runtime
    const session = new Supabase.ai.Session("gte-small");
    const embedding = await session.run(textToEmbed, {
      mean_pool: true,
      normalize: true,
    });

    const embeddingArray = Array.from(embedding);

    const supabase = createClient(supabaseUrl, supabaseKey);
    const { error } = await supabase
      .from("ai_memories")
      .update({ embedding: embeddingArray })
      .eq("id", id);

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        id,
        dimensions: embeddingArray.length,
        model: "gte-small",
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
