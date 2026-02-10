# 🚀 Guía Rápida de Inicio

> **💡 Nuevo:** Ahora puedes instalar el sistema de skills **globalmente** y usarlo en todos tus proyectos.
> Ver [GLOBAL-SETUP.md](./GLOBAL-SETUP.md) para instrucciones completas.

---

## 🌍 Opción 1: Instalación Global (Recomendado)

### Una Sola Vez

```bash
cd ~/Development
git clone <repo-url> global-skills
cd global-skills
./scripts/install-global.sh
source ~/.zshrc  # o source ~/.bashrc
```

### En Cada Proyecto Nuevo

```bash
cd ~/Development/mi-proyecto
skills-init
```

**¡Listo!** Abre VS Code y chatea: `"Leer /agents.md"`

---

## 📦 Opción 2: Instalación Local (Por Proyecto)

## Paso 1: Setup Inicial (1 min)

```bash
# Navega a tu proyecto
cd tu-proyecto

# Copia la estructura de skills-system aquí

# Haz ejecutables los scripts
chmod +x scripts/*.sh

# Ejecuta setup
./scripts/setup.sh
```

**¿Qué hace esto?**
✅ Crea symlinks entre `/skills` y `.antigravity/skills`
✅ Configura Antigravity automáticamente
✅ Prepara el entorno

---

## Paso 2: Sincroniza Skills (30 seg)

```bash
./scripts/sync.sh
```

**¿Qué hace esto?**
✅ Lee todas las skills disponibles
✅ Las registra en los `agents.md` correctos según su scope
✅ Organiza el sistema automáticamente

---

## Paso 3: Primer Uso (1 min)

Abre VS Code con Antigravity y chatea:

```
Usuario: Leer /agents.md
```

El agente cargará el contexto del orquestador. ¡Listo para trabajar!

---

## 🎯 Ejemplos de Uso Inmediato

### Ejemplo 1: Crear Componente React

```
Usuario: Necesito un componente Card reutilizable para mostrar productos

Agente: Voy a leer la skill de React primero...
[Lee /skills/public/react/SKILL.md cuando exista]
[Explora estructura existente]
[Propone solución]
[Implementa]
```

### Ejemplo 2: Endpoint de API

```
Usuario: Necesito un endpoint GET /api/users que retorne todos los usuarios

Agente: Entendido, voy a:
1. Leer skill de express-mongodb
2. Verificar estructura actual
3. Crear el endpoint siguiendo patrones del proyecto
```

### Ejemplo 3: Crear Nueva Skill

```
Usuario: Quiero crear una skill para trabajar con TailwindCSS

Agente: [Lee /skills/examples/skill-creator/SKILL.md]
Perfecto, vamos a crear la skill. Necesito saber:
- ¿Es para frontend o global?
- ¿Qué aspectos quieres cubrir?
```

---

## 🧠 Conceptos Clave (2 min)

### 1. Agentes Especializados

- **Root (`/agents.md`)** → Orquestador, planifica y delega
- **Frontend (`/frontend/agents.md`)** → UI/UX, React, Angular
- **Backend (`/backend/agents.md`)** → APIs, bases de datos

### 2. Skills

- Contextos especializados que se cargan bajo demanda
- Evitan saturar al agente
- Se invocan explícitamente: "Lee la skill de X"

### 3. Scope

- `global` → Aplica a todo el proyecto
- `frontend` → Solo UI/UX
- `backend` → Solo APIs/DB

---

## 📋 Comandos Útiles

```bash
# Ver skills disponibles
ls -la skills/public/

# Ver estructura del proyecto
tree -L 2

# Re-ejecutar setup después de clonar
./scripts/setup.sh

# Sincronizar después de agregar skills
./scripts/sync.sh

# Crear nueva skill (dentro de VS Code con Antigravity)
"Usa la skill-creator para crear una skill de [tecnología]"
```

---

## 🎨 Stacks Disponibles

### MERN (Rápido)

```
Stack: MongoDB + Express + React + Node.js
Uso: Validación, MVPs, prototipos
```

### Java Enterprise (Robusto)

```
Stack: Java + Spring Boot + PostgreSQL/MySQL
Uso: APIs escalables, aplicaciones enterprise
```

### .NET Enterprise (Robusto)

```
Stack: C# + .NET Core + SQL Server
Uso: Aplicaciones enterprise, sistemas corporativos
```

### Python (En exploración)

```
Stack: Python + FastAPI/Flask
Uso: APIs rápidas, data processing, ML
```

---

## ⚡ Tips Pro

1. **Siempre lee las skills explícitamente:**

   ```
   "Lee la skill de React antes de empezar"
   ```

2. **Explora antes de codificar:**

   ```
   "Muéstrame la estructura actual de componentes"
   ```

3. **Usa sub-agentes para tareas complejas:**

   ```
   "Implementa autenticación completa"
   [El orquestador crea SA-Backend y SA-Frontend]
   ```

4. **Mantén contexto limpio:**
   - Archivos agents.md: 250-500 líneas
   - Si crece mucho, delega más

---

## 🐛 Troubleshooting Rápido

### El agente no encuentra las skills

```bash
# Re-ejecuta setup
./scripts/setup.sh

# Verifica symlinks
ls -la .antigravity/skills
# Debe apuntar a ../skills
```

### Las skills no aparecen en agents.md

```bash
# Ejecuta sync
./scripts/sync.sh
```

### Quiero resetear todo

```bash
# Elimina configuración
rm -rf .antigravity/skills

# Re-ejecuta setup
./scripts/setup.sh
./scripts/sync.sh
```

---

## 🎯 Siguiente Nivel

Una vez familiarizado con lo básico:

1. **Fase 2:** Poblar skills MERN
   - Skill de React
   - Skill de Express + MongoDB
   - Skill de Node.js best practices

2. **Fase 3:** Skills Frontend avanzado
   - Angular
   - State Management
   - Testing

3. **Fase 4:** Skills Backend robusto
   - Java Spring Boot
   - .NET Core
   - Bases de datos

---

## 💡 Recuerda

> "Un agente no trabaja mejor con más contexto; al contrario, el exceso de información provoca alucinaciones."

**Mantén los archivos agents.md concisos (250-500 líneas)**
**Usa skills para contexto especializado**
**Delega tareas complejas a sub-agentes**

---

## 🚀 ¡Estás Listo!

```bash
# Setup ✅
./scripts/setup.sh

# Sync ✅
./scripts/sync.sh

# VS Code + Antigravity ✅
"Leer /agents.md y empecemos"
```

**¡Happy coding! 🎉**
