# Estandares de logging — RBloom

---

## Formato de log estructurado (JSON)

```json
{
  "timestamp": "2026-03-23T15:30:00.000Z",
  "level": "info | warn | error",
  "service": "api | web | n8n",
  "method": "POST",
  "path": "/api/auth/login",
  "status": 200,
  "duration_ms": 45,
  "tenant_id": "uuid",
  "user_id": "uuid",
  "request_id": "uuid",
  "message": "Login exitoso"
}
```

---

## Que loguear (por nivel)

### info
- Request completado (metodo, ruta, status, duracion)
- Login/logout exitoso
- Feature activado (onboarding completado, campana lanzada)

### warn
- Rate limit alcanzado
- Request lento (> 1 segundo)
- Token a punto de expirar
- Retry de operacion externa

### error
- Request fallido (4xx, 5xx)
- Error de DB (connection lost, query failed)
- Error de API externa (OpenPay, WhatsApp timeout)
- Error de agente IA (token limit exceeded)

---

## Que NO loguear (NUNCA)

- Passwords (ni hasheados)
- Tokens JWT completos (solo ultimos 8 chars)
- Numeros de tarjeta
- wa_access_token
- Contenido de mensajes de WhatsApp (privacidad)
- Stack traces en responses al cliente (solo en server logs)

---

## Request logging middleware (Express)

```typescript
// Patron recomendado para Express
app.use((req, res, next) => {
  const start = Date.now();
  const requestId = crypto.randomUUID();
  req.requestId = requestId;

  res.on('finish', () => {
    const duration = Date.now() - start;
    const log = {
      timestamp: new Date().toISOString(),
      level: res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info',
      service: 'api',
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration_ms: duration,
      request_id: requestId,
      tenant_id: req.user?.tenant_id,
      user_id: req.user?.id
    };

    if (duration > 1000) log.level = 'warn';
    console.log(JSON.stringify(log));
  });

  next();
});
```

---

## Alertas recomendadas

| Condicion | Nivel | Accion |
|---|---|---|
| Error rate > 5% en 5 min | Critical | Investigar inmediato |
| P95 latency > 2s | High | Revisar queries lentas |
| DB connections > 80% pool | High | Posible leak de conexiones |
| Rate limit hits > 100/min | Medium | Posible ataque o mal uso |
| Disk usage > 80% | High | Limpiar logs / scale storage |
