# Frameworks de evaluacion

---

## Tool / Library evaluation

| Criterio | Peso | Preguntas |
|---|---|---|
| Funcionalidad | 25% | ¿Cubre el caso de uso? ¿Features que faltan? |
| Costo | 20% | Free tier? Pricing escala? Hidden costs? |
| Madurez | 15% | Version estable? Ultima release? Issues abiertos? |
| Integracion | 15% | Compatible con nuestro stack (TS, Express, Next.js)? |
| Documentacion | 10% | Ejemplos? API reference? Tutoriales? |
| Comunidad | 10% | GitHub stars? Stack Overflow? Discord activo? |
| Lock-in | 5% | Se puede migrar? Formato propietario? |

---

## Service / API evaluation

| Criterio | Peso | Preguntas |
|---|---|---|
| Funcionalidad | 20% | Endpoints que necesitamos? Limitaciones? |
| Pricing | 20% | Free tier? Por request? Por volumen? |
| Reliability | 15% | SLA? Uptime historico? Status page? |
| Latencia | 15% | Tiempo de respuesta? Regiones? CDN? |
| Seguridad | 10% | SOC2? GDPR? Encryption at rest? |
| Documentacion | 10% | SDK oficial? Ejemplos? Webhooks? |
| Soporte | 10% | Email? Chat? Response time? |

---

## Architecture pattern evaluation

| Criterio | Peso | Preguntas |
|---|---|---|
| Complejidad | 25% | ¿Cuanto cuesta implementar y mantener? |
| Escalabilidad | 20% | ¿Soporta 10x crecimiento? |
| Resiliencia | 20% | ¿Que pasa si un componente falla? |
| Performance | 15% | Latencia? Throughput? |
| Operabilidad | 10% | ¿Facil de monitorear y debuggear? |
| Reversibilidad | 10% | ¿Se puede cambiar despues? |

---

## Scoring

```
Score = Σ (peso_criterio × calificacion_1_a_10)

Calificacion:
  1-3: No cumple / problematico
  4-6: Cumple parcialmente / aceptable
  7-9: Cumple bien / recomendable
  10:  Excepcional / mejor en su clase
```
