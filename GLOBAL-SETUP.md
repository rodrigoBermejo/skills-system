# 🌍 Configuración Global del Sistema de Skills

Esta guía te muestra cómo instalar el sistema de skills **una sola vez** y reutilizarlo en **todos tus proyectos**.

---

## 🎯 ¿Qué es el Sistema Global?

En lugar de copiar las skills en cada proyecto, tendrás:

- **📦 Repositorio central** en `~/Development/global-skills`
- **🔗 Symlinks automáticos** en cada proyecto
- **⚡ Comandos globales** disponibles en cualquier lugar
- **🔄 Actualizaciones centralizadas** - un `git pull` actualiza todos los proyectos

---

## 📋 Instalación (Una Sola Vez)

### Paso 1: Clonar el Repositorio

```bash
cd ~/Development
git clone <repo-url> global-skills
cd global-skills
```

### Paso 2: Instalar Globalmente

```bash
./scripts/install-global.sh
```

**¿Qué hace esto?**
✅ Copia el sistema a `~/Development/global-skills`
✅ Agrega alias a tu `.zshrc` o `.bashrc`
✅ Hace disponibles los comandos globales

### Paso 3: Recargar Shell

```bash
source ~/.zshrc  # o source ~/.bashrc
```

### Paso 4: Verificar Instalación

```bash
skills-list
```

Deberías ver la lista de skills disponibles.

---

## 🚀 Uso en Proyectos

### Inicializar un Proyecto Nuevo

```bash
# 1. Ve a tu proyecto
cd ~/Development/mi-proyecto

# 2. Inicializa skills
skills-init

# 3. Listo! Abre VS Code con Antigravity
code .
```

**¿Qué hace `skills-init`?**
✅ Crea `.antigravity/skills` → symlink a skills globales
✅ Crea `skills/private/` para skills del proyecto
✅ Copia templates de `agents.md`
✅ Configura `.gitignore`
✅ Sincroniza skills automáticamente

### Usar en un Proyecto Existente

Si ya tienes un proyecto con el sistema anterior:

```bash
cd ~/Development/mi-proyecto-existente
skills-init
```

El script detectará archivos existentes y no los sobrescribirá.

---

## 🎨 Comandos Globales Disponibles

| Comando           | Descripción                              |
| ----------------- | ---------------------------------------- |
| `skills-init`     | Inicializar skills en el proyecto actual |
| `skills-sync`     | Re-sincronizar skills con agents.md      |
| `skills-validate` | Validar estructura de skills             |
| `skills-cd`       | Ir al directorio de skills globales      |
| `skills-list`     | Ver skills globales disponibles          |

---

## 📁 Estructura Resultante

Después de ejecutar `skills-init` en un proyecto:

```
mi-proyecto/
├── .antigravity/
│   └── skills -> ~/Development/global-skills/skills/public  # Symlink
├── skills/
│   └── private/          # Skills específicas del proyecto
├── agents.md             # Orquestador principal
├── frontend/
│   └── agents.md         # Agente de frontend
└── backend/
    └── agents.md         # Agente de backend
```

---

## 🔄 Actualizar Skills Globales

```bash
# Opción 1: Desde cualquier lugar
skills-cd
git pull

# Opción 2: Directamente
cd ~/Development/global-skills
git pull
```

**Todos los proyectos se actualizan automáticamente** gracias a los symlinks.

---

## 🎯 Flujo de Trabajo Completo

### Primera Vez (Instalación Global)

```bash
# 1. Clonar
cd ~/Development
git clone <repo-url> global-skills
cd global-skills

# 2. Instalar
./scripts/install-global.sh

# 3. Recargar shell
source ~/.zshrc
```

### En Cada Proyecto Nuevo

```bash
# 1. Ir al proyecto
cd ~/Development/mi-nuevo-proyecto

# 2. Inicializar
skills-init

# 3. Trabajar con Antigravity
code .
# Chatea: "Leer /agents.md"
```

---

## 💡 Skills Privadas vs Globales

### Skills Globales (`~/Development/global-skills/skills/public/`)

- Compartidas entre **todos** tus proyectos
- Versionadas en Git
- Actualizaciones centralizadas
- Ejemplos: React, Express, n8n, Java Spring

### Skills Privadas (`./skills/private/`)

- Específicas de **un solo** proyecto
- No se comparten con otros proyectos
- Útiles para:
  - Configuraciones específicas del proyecto
  - Integraciones custom
  - Reglas de negocio particulares

### Crear una Skill Privada

En Antigravity:

```
Usuario: Usa la skill-creator para crear una skill de [tecnología]
Agente: ¿Debe ser global o privada del proyecto?
Usuario: Privada
```

La skill se creará en `./skills/private/[nombre]/`

---

## 🐛 Troubleshooting

### Los comandos `skills-*` no funcionan

```bash
# Verifica que los alias estén cargados
cat ~/.zshrc | grep "Skills System"

# Si no aparecen, re-ejecuta la instalación
cd ~/Development/global-skills
./scripts/install-global.sh

# Recarga el shell
source ~/.zshrc
```

### El symlink no apunta correctamente

```bash
# Verifica el symlink
ls -la .antigravity/skills

# Debe mostrar:
# .antigravity/skills -> /Users/tu-usuario/Development/global-skills/skills/public

# Si no es correcto, re-inicializa
skills-init
```

### Las skills no aparecen en agents.md

```bash
# Re-sincroniza
skills-sync
```

### Quiero resetear un proyecto

```bash
# Elimina configuración
rm -rf .antigravity
rm -rf skills

# Re-inicializa
skills-init
```

---

## 🎓 Ejemplos de Uso

### Ejemplo 1: Proyecto React + Express

```bash
cd ~/Development/mi-app-fullstack
skills-init

# En Antigravity:
# "Leer /agents.md"
# "Necesito un componente Card en React"
# El agente cargará automáticamente la skill de React
```

### Ejemplo 2: Proyecto Java Spring

```bash
cd ~/Development/mi-api-java
skills-init

# En Antigravity:
# "Leer /agents.md"
# "Necesito un endpoint REST para usuarios"
# El agente cargará automáticamente la skill de Java Spring
```

### Ejemplo 3: Múltiples Proyectos

```bash
# Proyecto 1
cd ~/Development/proyecto-1
skills-init

# Proyecto 2
cd ~/Development/proyecto-2
skills-init

# Actualizar skills globales
skills-cd
git pull

# Ambos proyectos se actualizan automáticamente
```

---

## 🚀 Ventajas del Sistema Global

✅ **DRY (Don't Repeat Yourself)** - Skills en un solo lugar
✅ **Actualizaciones instantáneas** - Un `git pull` actualiza todos los proyectos
✅ **Onboarding rápido** - `skills-init` en cualquier proyecto nuevo
✅ **Flexibilidad** - Skills privadas cuando las necesites
✅ **Versionado** - Control de versiones centralizado
✅ **Consistencia** - Mismas prácticas en todos los proyectos

---

## 📚 Recursos Adicionales

- [QUICKSTART.md](./QUICKSTART.md) - Guía rápida de 5 minutos
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Arquitectura del sistema
- [EXAMPLES.md](./EXAMPLES.md) - Ejemplos de uso avanzado
- [agents.md](./agents.md) - Configuración del orquestador

---

## 🎉 ¡Listo!

Ahora tienes un sistema de skills global que puedes usar en **todos tus proyectos**.

```bash
# Instalar (una vez)
./scripts/install-global.sh

# Usar (en cada proyecto)
skills-init

# Actualizar (cuando quieras)
skills-cd && git pull
```

**¡Happy coding! 🚀**
