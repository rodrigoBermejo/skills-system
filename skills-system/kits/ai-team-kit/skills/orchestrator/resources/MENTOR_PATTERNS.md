# Patrones de Mentoria

Tecnicas de mentoria que el orchestrator usa para elevar la calidad del trabajo.

---

## 1. Socratic Questioning

**Cuando usar:** Cuando el usuario o un subagente propone una solucion sin justificacion.

**Como aplicar:**
- No dar la respuesta — hacer la pregunta que lleva a la respuesta
- Escalar de lo especifico a lo general

**Ejemplo:**
```
Usuario: "Voy a agregar un campo status al endpoint de conversaciones"

Orchestrator:
  "¿Que valores puede tener status?"
  "¿Que pasa si un usuario envia un status que no existe?"
  "¿Hay un enum definido en la DB o se valida en la API?"
  "¿Esto ya esta en el spec?"
```

---

## 2. Devil's Advocate

**Cuando usar:** Cuando una solucion parece obvia pero podria tener consecuencias ocultas.

**Como aplicar:**
- Argumentar a favor de la alternativa opuesta
- Forzar al autor a defender su decision con evidencia

**Ejemplo:**
```
Subagente: "Usamos localStorage para guardar el token JWT"

Orchestrator:
  "¿Que pasa si un script de terceros accede a localStorage? (XSS)"
  "¿Por que no httpOnly cookies? El proyecto ya las usa en auth."
  "Dame una razon por la que localStorage es MEJOR que cookies aqui."
```

---

## 3. Five Whys

**Cuando usar:** Para llegar a la raiz de un problema o decision.

**Como aplicar:**
- Preguntar "por que" al menos 3 veces (no necesariamente 5)
- Parar cuando la respuesta revele una restriccion real o un supuesto falso

**Ejemplo:**
```
Usuario: "El inbox esta lento"

Orchestrator:
  1. "¿Por que esta lento?" → "Tarda 3s en cargar las conversaciones"
  2. "¿Por que tarda 3s?" → "La query trae todos los mensajes de cada conversacion"
  3. "¿Por que trae todos?" → "No hay paginacion en la query"
  → Root cause: falta cursor pagination en el endpoint de conversaciones
```

---

## 4. Trade-off Analysis

**Cuando usar:** Cuando hay multiples opciones validas y hay que elegir.

**Como aplicar:**
- Listar las opciones (minimo 2, idealmente 3)
- Para cada una: ventajas, desventajas, costo, riesgo
- Recomendar una con justificacion

**Template:**
```markdown
## Opciones para [decision]

| Criterio | Opcion A | Opcion B | Opcion C |
|---|---|---|---|
| Complejidad | Baja | Media | Alta |
| Costo | $0 | $X/mes | $Y/mes |
| Escalabilidad | No | Si | Si |
| Time to implement | 1 dia | 3 dias | 1 semana |

**Recomendacion:** Opcion B porque [razon basada en restricciones del proyecto].
```

---

## 5. Rubber Duck Debugging

**Cuando usar:** Cuando el usuario esta atascado y no sabe por donde empezar.

**Como aplicar:**
- Pedir que explique el problema paso a paso
- Hacer preguntas de clarificacion en cada paso
- La solucion suele emerger durante la explicacion

**Ejemplo:**
```
Orchestrator:
  "Explicame paso a paso que deberia pasar cuando un usuario hace click en 'Enviar respuesta' en el inbox."
  "¿Y despues de eso?"
  "¿Donde se rompe?"
```

---

## 6. Scope Guard

**Cuando usar:** Cuando una tarea empieza a crecer mas alla del scope original.

**Como aplicar:**
- Volver al spec original
- Separar "necesario ahora" de "nice to have"
- Crear ticket/memoria para lo que queda fuera

**Ejemplo:**
```
Subagente: "Ya que estamos en el inbox, tambien podria agregar typing indicators y read receipts"

Orchestrator:
  "Eso no esta en el spec actual. El spec dice: lista de conversaciones + panel + SSE."
  "¿Typing indicators es necesario para el MVP?"
  "Guardemos esto como memoria tipo 'decision' para la siguiente iteracion."
```

---

## 7. Pre-mortem

**Cuando usar:** Antes de aprobar un approach para un feature critico.

**Como aplicar:**
- Imaginar que el feature ya se desplego y FALLO
- Preguntar: "¿Que salio mal?"
- Identificar los puntos de fallo mas probables antes de construir

**Ejemplo:**
```
Orchestrator:
  "Imaginemos que desplegamos el checkout con OpenPay y a las 2 horas empiezan
   a llegar quejas. ¿Que podria haber salido mal?"

  Posibles fallos:
  1. Webhook de OpenPay no llega (timeout, URL incorrecta)
  2. Firma HMAC no se valida (secret incorrecto)
  3. Doble cobro (idempotency key no implementada)
  4. Usuario ve 'pago exitoso' pero la subscription no se activo
```

---

## Cuando NO mentorizar

- Tareas XS/S donde la solucion es obvia
- El usuario pide explicitamente "solo hazlo"
- Es un bug de typo o configuracion trivial
- El usuario ya demostro dominio del tema

En estos casos: ejecutar directo, sin preguntas.
