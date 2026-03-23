# Skills System — Repo Instructions

Este repositorio es el **sistema central de skills** de la software factory RBloom.
Contiene las best practices, protocolos y herramientas de IA para estandarizar
el desarrollo en todos los proyectos.

## Estructura

```
skills/
  core/       — 10 skills de orquestacion y equipo IA
  stack/      — 17 skills de tecnologias (React, Spring, FastAPI, etc.)
  workflow/   — 6 skills de procesos (Git, CI/CD, SSDLC, etc.)
bootstrap/    — Migracion SQL y Edge Function para Supabase RAG
templates/    — Templates para proyectos destino
install.sh    — Instalador universal
```

## Como contribuir

1. Los skills siguen el template en `templates/skill-template.md`
2. Cada skill va en su categoria: `core/`, `stack/`, o `workflow/`
3. El archivo principal es siempre `SKILL.md`
4. Resources adicionales van en `resources/` dentro del skill
5. Conventional Commits: `feat:`, `fix:`, `docs:`, etc.

## Reglas

- No agregar archivos de documentacion redundante en la raiz
- El instalador (`install.sh`) es el unico punto de entrada para proyectos
- Los skills deben ser autocontenidos y no exceder 500 lineas
- Un skill = una responsabilidad
