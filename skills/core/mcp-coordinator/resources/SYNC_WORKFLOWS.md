# Flujos de sincronizacion — Paso a paso

---

## Flujo 1: Nuevo feature con migracion DB

```
1. Desarrollar localmente (codigo + SQL)
2. Commit a rama feat/xxx

3. Aplicar migracion a Supabase:
   → mcp__claude_ai_Supabase__apply_migration
   → Verificar: list_tables

4. Generar tipos TS actualizados:
   → mcp__claude_ai_Supabase__generate_typescript_types

5. Si hay Edge Function:
   → mcp__claude_ai_Supabase__deploy_edge_function
   → Verificar: list_edge_functions

6. Test de integracion:
   → execute_sql con queries de prueba
   → Verificar datos insertados correctamente

7. Si todo pasa: merge PR
```

---

## Flujo 2: Nuevo workflow N8N

```
1. Escribir JSON del workflow localmente
2. Validar estructura con n8n-validation

3. Crear/actualizar workflow via n8n MCP:
   → Delegado a n8n-mcp-tools

4. Activar workflow

5. Test funcional:
   → Enviar webhook de prueba
   → Verificar ejecucion exitosa

6. Guardar JSON final en workflows/active/
7. Commit + PR
```

---

## Flujo 3: Debugging en produccion

```
1. Identificar sintoma (error, lentitud, datos incorrectos)

2. Revisar logs:
   → mcp__claude_ai_Supabase__get_logs
   → Filtrar por error level y timestamp reciente

3. Diagnostico SQL:
   → execute_sql: pg_stat_activity (conexiones activas)
   → execute_sql: pg_stat_statements (queries lentas)
   → execute_sql: query especifica del modulo afectado

4. Si es N8N:
   → Revisar execution history via n8n MCP

5. Identificar root cause

6. Si requiere fix:
   → Aplicar fix
   → Verificar con los mismos diagnosticos
   → Guardar patron en memoria (what-failed + solucion)
```

---

## Flujo 4: Rollback de migracion

```
⚠️ REQUIERE CONFIRMACION EXPLICITA DEL USUARIO

1. Identificar la migracion a revertir:
   → mcp__claude_ai_Supabase__list_migrations

2. Escribir SQL de rollback:
   - DROP TABLE IF EXISTS [tabla nueva]
   - ALTER TABLE [tabla modificada] DROP COLUMN [columna nueva]
   - DROP FUNCTION IF EXISTS [funcion nueva]

3. CONFIRMAR con el usuario antes de ejecutar

4. Ejecutar rollback:
   → mcp__claude_ai_Supabase__execute_sql

5. Verificar:
   → list_tables (tabla eliminada)
   → execute_sql (query de prueba)

6. Regenerar tipos TS:
   → generate_typescript_types
```

---

## Flujo 5: Sincronizar memoria RAG

```
1. Escribir memorias nuevas:
   → execute_sql: INSERT INTO ai_memories (...)

2. Invocar Edge Function para embeddings:
   → Si hay trigger automatico: no hacer nada
   → Si es manual: llamar embed-memory con el ID

3. Verificar embedding generado:
   → execute_sql: SELECT id, embedding IS NOT NULL FROM ai_memories WHERE id = 'xxx'

4. Test de retrieval:
   → execute_sql: busqueda por similitud con vector de prueba
```
