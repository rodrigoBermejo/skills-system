# Skill Creator - Creador de Skills

**Scope:** global  
**Trigger:** Cuando el usuario pida "crear una nueva skill", "hacer una skill de X" o mencione crear contexto especializado  
**Tools:** file_create, str_replace, view  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para crear nuevas skills siguiendo el formato y estructura correctos del sistema. Cada skill debe tener metadata clara, instrucciones precisas y estar bien documentada.

## 📋 Estructura de una Skill

Cada skill debe residir en una carpeta con el siguiente formato:

```
skills/
  ├── public/          (Skills compartidas y generales)
  ├── private/         (Skills personalizadas del usuario)
  └── examples/        (Skills de referencia)
      └── nombre-skill/
          ├── SKILL.md         (Archivo principal - OBLIGATORIO)
          ├── examples/        (Opcional: ejemplos de uso)
          ├── templates/       (Opcional: plantillas)
          └── docs/            (Opcional: documentación extra)
```

## 📝 Formato del Archivo SKILL.md

Cada archivo `SKILL.md` debe seguir esta estructura:

```markdown
# [Nombre de la Skill]

**Scope:** [frontend|backend|global]  
**Trigger:** [Cuándo debe activarse esta skill]  
**Tools:** [Herramientas necesarias: bash_tool, file_create, view, web_search, etc.]  
**Version:** [X.Y.Z]  

---

## 🎯 Propósito

[Descripción clara y concisa del objetivo de esta skill]

## 🔧 Cuándo Usar Esta Skill

[Lista de situaciones donde esta skill debe ser invocada]

- Situación 1
- Situación 2
- Situación 3

## 📚 Contexto y Conocimiento

[Información esencial que el agente necesita para usar esta skill efectivamente]

### Conceptos Clave
- Concepto 1: Explicación
- Concepto 2: Explicación

### Best Practices
1. Práctica 1
2. Práctica 2
3. Práctica 3

## 🚀 Flujo de Trabajo

[Paso a paso de cómo usar esta skill]

### Paso 1: [Nombre del paso]
[Descripción detallada]

### Paso 2: [Nombre del paso]
[Descripción detallada]

## 💻 Ejemplos de Código

[Ejemplos concretos y prácticos]

### Ejemplo 1: [Descripción]
```[lenguaje]
// Código de ejemplo
```

### Ejemplo 2: [Descripción]
```[lenguaje]
// Código de ejemplo
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Error 1 | Causa | Cómo resolverlo |
| Error 2 | Causa | Cómo resolverlo |

## 🔄 Integración con Otras Skills

[Cómo esta skill se relaciona con otras]

- **Skill A**: Úsala junto con esta cuando...
- **Skill B**: Esta skill debe ejecutarse antes de...

## 📋 Checklist de Validación

Antes de finalizar la tarea con esta skill:
- [ ] Item 1
- [ ] Item 2
- [ ] Item 3

## 📚 Referencias

- [Documentación oficial]
- [Tutoriales]
- [Recursos adicionales]

---

**Última actualización:** [Fecha]  
**Mantenedor:** [Nombre o rol]
```

## 🎨 Tipos de Scope

Define correctamente el scope de tu skill:

- **`frontend`** - Solo aplica a código de UI/UX (React, Angular, Vue)
- **`backend`** - Solo aplica a código de servidor/API (Express, Spring, .NET)
- **`global`** - Aplica a todo el proyecto (Git, Testing, DevOps)

## 🔍 Triggers Efectivos

Los triggers deben ser específicos y detectables. Buenos ejemplos:

✅ **Triggers buenos:**
- "cuando el usuario trabaje con React"
- "cuando se mencione autenticación JWT"
- "cuando se necesite crear una API RESTful"
- "cuando se pida crear componentes reutilizables"

❌ **Triggers vagos:**
- "cuando se programe"
- "cuando haya código"
- "siempre"

## 🛠️ Tools Disponibles

Especifica qué herramientas puede usar el agente con esta skill:

- **`view`** - Leer archivos y directorios
- **`file_create`** - Crear nuevos archivos
- **`str_replace`** - Editar archivos existentes
- **`bash_tool`** - Ejecutar comandos bash
- **`web_search`** - Buscar información en la web
- **`web_fetch`** - Obtener contenido de URLs

## 📏 Principios de Diseño de Skills

### 1. Concisión es Clave
- Máximo 500 líneas por skill
- Si crece mucho, divide en múltiples skills
- Solo incluye información esencial

### 2. Enfoque Específico
- Una skill = una responsabilidad
- No mezcles React con Express en la misma skill
- Mejor 5 skills pequeñas que 1 gigante

### 3. Ejemplos Prácticos
- Incluye código real, no pseudocódigo
- Muestra casos de uso completos
- Errores comunes con soluciones

### 4. Mantén Actualizada
- Versiona tus skills (semver)
- Actualiza cuando cambien las tecnologías
- Documenta cambios importantes

## 🚀 Proceso de Creación de una Skill

### Cuando el Usuario Pide Crear una Skill:

**Paso 1: Recopila Información**
```
Preguntas esenciales:
1. ¿Cuál es el propósito de esta skill?
2. ¿Para qué tecnología o proceso es?
3. ¿Cuándo debe activarse (trigger)?
4. ¿Es para frontend, backend o global (scope)?
5. ¿Qué herramientas necesita (tools)?
```

**Paso 2: Determina la Ubicación**
```
- Skills generales → /skills/public/
- Skills personalizadas → /skills/private/
- Skills de ejemplo → /skills/examples/
```

**Paso 3: Crea la Estructura**
```bash
mkdir -p /skills/[public|private]/[nombre-skill]
```

**Paso 4: Genera el SKILL.md**
Usa el template de arriba y llénalo con:
- Metadata correcta (scope, trigger, tools)
- Propósito claro
- Contexto necesario
- Ejemplos prácticos
- Checklist de validación

**Paso 5: Valida la Skill**
```
Verifica:
- [ ] SKILL.md existe y tiene metadata completa
- [ ] Scope está bien definido
- [ ] Trigger es específico y detectable
- [ ] Incluye ejemplos de código
- [ ] Tiene checklist de validación
- [ ] No excede 500 líneas
```

**Paso 6: Integra al Sistema**
```bash
# Ejecuta el script de sincronización
./scripts/sync.sh

# Esto automáticamente:
# 1. Lee la metadata de la skill
# 2. La registra en el agents.md correspondiente según su scope
```

## 💡 Ejemplo de Creación

**Usuario dice:** "Necesito una skill para trabajar con Express y MongoDB"

**Tú respondes:**

```
Perfecto, voy a crear una skill de Express + MongoDB.

Metadata:
- Nombre: express-mongodb
- Scope: backend
- Trigger: cuando se trabaje con Express, MongoDB o el stack MERN
- Tools: view, file_create, str_replace, bash_tool

¿Quieres que incluya:
1. Setup inicial de proyecto
2. Conexión a MongoDB
3. Estructura MVC
4. Autenticación JWT
5. Validaciones
6. Manejo de errores

O prefieres que sea más específica a un aspecto?
```

Luego procedes a crear el archivo con toda la información necesaria.

## 🔄 Actualización de Skills Existentes

Si necesitas actualizar una skill:

1. **Lee la skill actual** con `view`
2. **Identifica qué agregar/cambiar**
3. **Incrementa la versión** (1.0.0 → 1.1.0)
4. **Usa `str_replace`** para hacer cambios quirúrgicos
5. **Documenta los cambios** en el archivo

## ⚠️ Errores Comunes

| Error | Solución |
|-------|----------|
| Skill demasiado larga (>500 líneas) | Divide en múltiples skills específicas |
| Scope ambiguo | Define claramente: frontend, backend o global |
| Trigger vago | Hazlo específico y detectable |
| Sin ejemplos de código | Agrega casos de uso reales |
| Metadata incompleta | Verifica scope, trigger, tools y version |

## 📋 Checklist Final

Antes de marcar una skill como completa:
- [ ] Archivo SKILL.md creado en la ubicación correcta
- [ ] Metadata completa (scope, trigger, tools, version)
- [ ] Propósito claramente definido
- [ ] Al menos 2-3 ejemplos prácticos
- [ ] Checklist de validación incluida
- [ ] No excede 500 líneas
- [ ] Script sync.sh ejecutado para registrarla

---

**Última actualización:** Fase 1 - Estructura Base  
**Mantenedor:** Sistema de Skills
