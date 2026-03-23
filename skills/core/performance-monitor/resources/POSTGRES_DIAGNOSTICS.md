# Queries de diagnostico PostgreSQL avanzadas

---

## Performance

### Top queries por tiempo total

```sql
SELECT substring(query, 1, 80) as query_preview,
       calls,
       round(total_exec_time::numeric, 2) as total_ms,
       round(mean_exec_time::numeric, 2) as avg_ms,
       rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 15;
```

### Queries con mas rows procesadas

```sql
SELECT substring(query, 1, 80) as query_preview,
       calls, rows,
       round(rows::numeric / calls, 0) as avg_rows
FROM pg_stat_statements
WHERE calls > 10
ORDER BY rows DESC
LIMIT 10;
```

### Cache hit ratio (deberia ser > 99%)

```sql
SELECT
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit) as heap_hit,
  round(sum(heap_blks_hit)::numeric /
        (sum(heap_blks_hit) + sum(heap_blks_read)) * 100, 2) as cache_hit_pct
FROM pg_statio_user_tables;
```

### Indice hit ratio

```sql
SELECT
  sum(idx_blks_read) as idx_read,
  sum(idx_blks_hit) as idx_hit,
  round(sum(idx_blks_hit)::numeric /
        greatest(sum(idx_blks_hit) + sum(idx_blks_read), 1) * 100, 2) as idx_cache_hit_pct
FROM pg_statio_user_indexes;
```

---

## Conexiones

### Pool status

```sql
SELECT state, count(*),
       round(avg(extract(epoch from (now() - state_change)))::numeric, 1) as avg_seconds
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state
ORDER BY count DESC;
```

### Conexiones por aplicacion

```sql
SELECT application_name, state, count(*)
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY application_name, state
ORDER BY count DESC;
```

---

## Tablas

### Tamano total con indices

```sql
SELECT
  tablename,
  pg_size_pretty(pg_total_relation_size('public.' || tablename)) as total,
  pg_size_pretty(pg_relation_size('public.' || tablename)) as data,
  pg_size_pretty(pg_indexes_size('public.' || tablename)) as indexes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size('public.' || tablename) DESC;
```

### Actividad de tablas (reads vs writes)

```sql
SELECT relname,
       seq_scan, idx_scan,
       n_tup_ins as inserts,
       n_tup_upd as updates,
       n_tup_del as deletes,
       n_live_tup as live_rows
FROM pg_stat_user_tables
ORDER BY seq_scan + idx_scan DESC;
```

---

## Locks (bloqueos)

### Locks activos

```sql
SELECT blocked_locks.pid AS blocked_pid,
       blocked_activity.usename AS blocked_user,
       blocking_locks.pid AS blocking_pid,
       blocking_activity.usename AS blocking_user,
       blocked_activity.query AS blocked_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.relation = blocked_locks.relation
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```
