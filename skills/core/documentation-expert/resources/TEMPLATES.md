# Templates de documentacion

---

## API Endpoint

```markdown
### [METHOD] /api/[ruta]

[1 oracion: que hace]

**Auth:** [Si/No — tipo: Bearer token, Cookie]

**Body:**
| Campo | Tipo | Requerido | Validacion |
|---|---|---|---|
| campo1 | string | Si | min 3, max 100 |

**Response 200:**
```json
{ "data": { ... } }
```

**Errores:**
| Codigo | Cuando |
|---|---|
| 400 | Body invalido |
| 401 | Sin autenticacion |
| 403 | Sin permisos |

**Ejemplo:**
```bash
curl -X [METHOD] http://localhost:3000/api/[ruta] \
  -H "Authorization: Bearer [TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{ ... }'
```
```

---

## Runbook

```markdown
# Runbook: [Nombre]

## Que hace
[1-2 oraciones]

## Como verificar que funciona
- [ ] [check 1]
- [ ] [check 2]

## Troubleshooting

### Sintoma: [descripcion]
**Causa probable:** [causa]
**Solucion:**
1. [paso]
2. [paso]

## Metricas
| Metrica | Normal | Alerta |
|---|---|---|
| [metrica] | [rango] | [umbral] |

## Escalamiento
- L1: [quien]
- L2: [quien]
```

---

## ADR (Architecture Decision Record)

```markdown
# ADR-[N]: [Titulo]

## Fecha
YYYY-MM-DD

## Estado
[PROPUESTO | ACEPTADO | DEPRECADO | REEMPLAZADO por ADR-X]

## Contexto
[Problema + por que importa resolverlo ahora]

## Alternativas
1. **[Opcion A]** — [pros] / [contras]
2. **[Opcion B]** — [pros] / [contras]

## Decision
[La decision en 1 oracion]

## Consecuencias
- Positivas: [beneficio]
- Negativas: [trade-off]
- Reevaluar cuando: [condicion]
```

---

## Changelog (Keep a Changelog)

```markdown
# Changelog

## [X.Y.Z] - YYYY-MM-DD

### Added
- [feature nueva]

### Changed
- [cambio a feature existente]

### Fixed
- [bug corregido]

### Security
- [fix de seguridad]
```

---

## README de modulo

```markdown
# [Nombre del modulo]

[1-2 oraciones: que hace]

## Quick Start

```bash
[comando para levantar/usar]
```

## Estructura

```
modulo/
├── src/
│   ├── ...
```

## Configuracion

| Variable | Descripcion | Default |
|---|---|---|
| VAR_1 | ... | ... |

## API

[Link a docs de API si aplica]
```
