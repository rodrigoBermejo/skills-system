# Patrones de uso — Supabase MCP

Patrones comunes para interactuar con Supabase via MCP.

---

## Aplicar migracion

```
Herramienta: mcp__claude_ai_Supabase__apply_migration
```

**Antes de aplicar:**
1. Leer el archivo SQL completo
2. Verificar que no hay DROP TABLE sin confirmacion
3. Verificar que usa IF NOT EXISTS donde aplique
4. Verificar que no hay datos hardcodeados sensibles

**Despues de aplicar:**
1. `list_tables` — verificar tablas nuevas/modificadas
2. `execute_sql` — query de prueba
3. `generate_typescript_types` — actualizar tipos si hubo cambios de schema

---

## Ejecutar SQL ad-hoc

```
Herramienta: mcp__claude_ai_Supabase__execute_sql
```

**Usos comunes:**
- Queries de diagnostico
- Seed data para testing
- Verificacion post-migracion
- Queries de la memoria RAG (ai_memories)

**Reglas:**
- NUNCA ejecutar DELETE sin WHERE
- NUNCA ejecutar DROP sin confirmacion explicita
- Preferir SELECT para diagnostico antes de modificar
- Usar parametros cuando sea posible

---

## Ver estado de tablas

```
Herramienta: mcp__claude_ai_Supabase__list_tables
```

**Cuando usar:**
- Despues de aplicar migracion
- Para verificar schema actual
- Antes de escribir queries (verificar columnas)

---

## Deploy Edge Function

```
Herramienta: mcp__claude_ai_Supabase__deploy_edge_function
```

**Proceso:**
1. Escribir codigo en TypeScript (Deno)
2. Verificar que no tiene secrets hardcodeados
3. Desplegar con nombre descriptivo
4. Verificar con `get_edge_function` o `list_edge_functions`

**Variables de entorno automaticas en Edge Functions:**
- `SUPABASE_URL` — URL del proyecto
- `SUPABASE_ANON_KEY` — Clave publica
- `SUPABASE_SERVICE_ROLE_KEY` — Clave con permisos totales

---

## Generar tipos TypeScript

```
Herramienta: mcp__claude_ai_Supabase__generate_typescript_types
```

**Cuando usar:**
- Despues de cada migracion que modifique schema
- Al inicio de un feature que toca la DB
- Para verificar que el codigo TypeScript esta alineado con la DB

---

## Ver logs

```
Herramienta: mcp__claude_ai_Supabase__get_logs
```

**Filtros utiles:**
- Por servicio: postgres, edge-functions, auth
- Por nivel: error, warn
- Por timestamp: ultimas N horas

---

## Performance advisors

```
Herramienta: mcp__claude_ai_Supabase__get_advisors
```

**Que reporta:**
- Indices faltantes o no usados
- Tablas sin RLS habilitado
- Queries lentas
- Recomendaciones de configuracion
