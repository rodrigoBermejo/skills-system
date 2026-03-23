# Calculadora de costos LLM

Precios actualizados a marzo 2026. Verificar periodicamente.

---

## Precios por modelo (USD por 1M tokens)

| Modelo | Input | Output | Notas |
|---|---|---|---|
| **Claude 3.5 Haiku** | $0.80 | $4.00 | Mas barato de Anthropic, rapido |
| **Claude 3.5 Sonnet** | $3.00 | $15.00 | Balance costo/calidad |
| **Claude Opus 4** | $15.00 | $75.00 | Solo para tareas complejas |
| **GPT-4o-mini** | $0.15 | $0.60 | Mas barato del mercado |
| **GPT-4o** | $2.50 | $10.00 | Competidor de Sonnet |
| **text-embedding-3-small** | $0.02 | N/A | Embeddings 1536d |
| **text-embedding-3-large** | $0.13 | N/A | Embeddings 3072d |

---

## Formula de costo

```
Costo por llamada = (input_tokens / 1,000,000 × precio_input)
                  + (output_tokens / 1,000,000 × precio_output)

Costo mensual = costo_por_llamada × llamadas_por_dia × 30
```

---

## Ejemplos de calculo para RBloom

### Clasificador de leads (single-turn, Haiku)

```
System prompt: ~200 tokens
User message: ~50 tokens
Output: ~10 tokens (1 palabra)

Costo por llamada:
  Input: 250 / 1M × $0.80 = $0.0002
  Output: 10 / 1M × $4.00 = $0.00004
  Total: ~$0.00024 por clasificacion

Si 100 leads/dia:
  Mensual: $0.00024 × 100 × 30 = $0.72/mes
```

### Agente de atencion (multi-turn, Sonnet, 5 turns promedio)

```
System prompt: ~500 tokens
Historial promedio: ~1000 tokens (crece por turn)
Output promedio: ~200 tokens por turn

Costo por conversacion (5 turns):
  Total input: ~500 + 200 + 700 + 1200 + 1700 = ~4,300 tokens
  Total output: ~200 × 5 = ~1,000 tokens
  Input: 4300 / 1M × $3.00 = $0.013
  Output: 1000 / 1M × $15.00 = $0.015
  Total: ~$0.028 por conversacion

Si 50 conversaciones/dia:
  Mensual: $0.028 × 50 × 30 = $42/mes
```

### Embeddings para memoria RAG

```
Memoria promedio: ~200 tokens por memoria
Modelo: text-embedding-3-small

Costo por embedding: 200 / 1M × $0.02 = $0.000004

Si 100 memorias/mes:
  Mensual: $0.000004 × 100 = $0.0004/mes (practicamente gratis)
```

---

## Presupuestos sugeridos por vertical

| Vertical | Volumen estimado | Modelo base | Presupuesto mensual |
|---|---|---|---|
| Clinica pequena | 50 leads/dia, 20 conversaciones | Haiku + Sonnet | $15-30 |
| Barberia | 30 leads/dia, 15 conversaciones | Haiku + Haiku | $5-10 |
| Restaurante | 40 leads/dia, 25 conversaciones | Haiku + Sonnet | $20-40 |
| Inmobiliaria | 20 leads/dia, 10 conversaciones | Haiku + Sonnet | $10-20 |

---

## Alertas de costo

Configurar alertas cuando:
- Costo diario > 2× el promedio
- Una conversacion > $0.50 (posible loop)
- Tokens de output > 5× el promedio (posible prompt injection que genera texto largo)
