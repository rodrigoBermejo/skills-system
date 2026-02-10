# 💡 Ejemplos Prácticos de Uso

Este documento muestra ejemplos reales de cómo usar el sistema de skills en diferentes escenarios.

---

## 📚 Tabla de Contenidos
- [Ejemplo 1: Proyecto MERN desde Cero](#ejemplo-1-proyecto-mern-desde-cero)
- [Ejemplo 2: Agregar Feature a Proyecto Existente](#ejemplo-2-agregar-feature-a-proyecto-existente)
- [Ejemplo 3: Refactoring con Sub-Agentes](#ejemplo-3-refactoring-con-sub-agentes)
- [Ejemplo 4: Crear Skill Personalizada](#ejemplo-4-crear-skill-personalizada)
- [Ejemplo 5: Debugging Guiado](#ejemplo-5-debugging-guiado)

---

## Ejemplo 1: Proyecto MERN desde Cero

### Contexto
Usuario quiere crear una aplicación de gestión de tareas con el stack MERN.

### Conversación

```
Usuario: Quiero crear una aplicación de tareas con MERN. 
Necesito login, CRUD de tareas, y dashboard.

Agente Orquestador:
Perfecto, voy a planificar este proyecto MERN completo.

📋 Plan de Implementación:
1. Backend con Express + MongoDB
2. Frontend con React
3. Autenticación con JWT
4. CRUD completo de tareas

Déjame empezar leyendo las skills necesarias...

[Lee /skills/public/express-mongodb/SKILL.md]
[Lee /skills/public/react/SKILL.md]

Ahora voy a crear sub-agentes especializados:
- SA-Backend: Configurar API
- SA-Frontend: Configurar UI

¿Quieres que proceda?
```

```
Usuario: Sí, adelante

Agente:
🚀 Iniciando implementación...

🔧 SA-Backend (Paso 1):
[Explora estructura de carpetas]
[Crea estructura backend]
✅ Completado: 
   - Express server configurado
   - MongoDB conectado
   - Modelos: User, Task
   - Routes: /auth, /tasks
   - Middleware: auth, validation

🎨 SA-Frontend (Paso 2):
[Crea estructura frontend]
✅ Completado:
   - React app con Vite
   - Components: Login, TaskList, TaskForm
   - Services: authService, taskService
   - Context: AuthContext
   - Routes configuradas

📋 Resumen Final:
✅ Backend funcionando en puerto 5000
✅ Frontend funcionando en puerto 3000
✅ Autenticación JWT implementada
✅ CRUD completo de tareas

Archivos creados:
backend/
  ├── server.js
  ├── models/
  ├── routes/
  ├── controllers/
  └── middleware/

frontend/
  ├── src/
  │   ├── components/
  │   ├── services/
  │   ├── context/
  │   └── App.jsx

¿Quieres que agregue alguna funcionalidad adicional?
```

---

## Ejemplo 2: Agregar Feature a Proyecto Existente

### Contexto
Proyecto MERN existente. Usuario quiere agregar sistema de comentarios a las tareas.

### Conversación

```
Usuario: Tengo un proyecto de tareas. 
Quiero que cada tarea pueda tener comentarios.

Agente Orquestador:
Entendido. Voy a agregar un sistema de comentarios.

Primero déjame explorar la estructura actual...

[view /backend/models/]
[view /frontend/src/components/]

Veo que tienes:
- Backend: User, Task models
- Frontend: TaskList, TaskForm components

📋 Plan para Comentarios:
1. Backend: Modelo Comment + endpoints
2. Frontend: Componente CommentList + CommentForm
3. Integración con Task existente

Leo la skill de express-mongodb para seguir tus patrones...
[Lee /skills/public/express-mongodb/SKILL.md]

Procedo a implementar:
```

```
Agente (continúa):
🔧 Backend implementado:
✅ models/Comment.js creado
✅ routes/comments.js creado
✅ controllers/commentController.js creado
✅ Model Task actualizado con relación a comments

🎨 Frontend implementado:
✅ components/CommentList.jsx creado
✅ components/CommentForm.jsx creado
✅ services/commentService.js creado
✅ TaskCard actualizado con sección de comentarios

🧪 Testing sugerido:
- POST /api/tasks/:id/comments - Crear comentario
- GET /api/tasks/:id/comments - Listar comentarios
- DELETE /api/comments/:id - Eliminar comentario

Todo implementado siguiendo los patrones existentes del proyecto.
¿Quieres que agregue validaciones adicionales?
```

---

## Ejemplo 3: Refactoring con Sub-Agentes

### Contexto
Proyecto grande que necesita refactoring para mejorar estructura y performance.

### Conversación

```
Usuario: Mi proyecto está creciendo mucho. 
Necesito refactorizar para mejor organización y performance.

Agente Orquestador:
Perfecto. Un refactoring completo es una tarea compleja 
que requiere coordinación. Voy a usar sub-agentes especializados.

Déjame primero analizar el proyecto...
[Explora estructura completa]

Identifico áreas de mejora:
1. Backend: Controllers muy largos (>300 líneas)
2. Frontend: Components con lógica repetida
3. Sin separación de servicios
4. Props drilling en varios niveles

📋 Plan de Refactoring:
- SA-Backend: Extraer services layer
- SA-Frontend: Crear custom hooks
- SA-Performance: Optimizar queries y renders

Leo las skills necesarias...
[Lee /skills/public/express-mongodb/SKILL.md]
[Lee /skills/public/react/SKILL.md]
[Lee /skills/public/nodejs-best-practices/SKILL.md]

Creando sub-agentes...
```

```
🔧 SA-Backend (Refactoring Backend):
Tarea: Extraer lógica de negocio a services

[Analiza controllers actuales]
[Identifica lógica de negocio]

✅ Cambios realizados:
   - Creada carpeta services/
   - UserService: lógica de users
   - TaskService: lógica de tasks
   - Controllers ahora son thin (solo routing)
   - Mejora testabilidad

Antes: controllers/taskController.js (250 líneas)
Después: 
  - controllers/taskController.js (80 líneas)
  - services/taskService.js (120 líneas)

---

🎨 SA-Frontend (Refactoring Frontend):
Tarea: Eliminar lógica repetida con custom hooks

[Analiza components]
[Identifica patrones repetidos]

✅ Cambios realizados:
   - hooks/useAuth.js: manejo de autenticación
   - hooks/useFetch.js: llamadas API genéricas
   - hooks/useForm.js: manejo de formularios
   - Components refactorizados para usar hooks

Antes: Lógica duplicada en 8 componentes
Después: 3 custom hooks reutilizables

---

⚡ SA-Performance (Optimización):
Tarea: Mejorar performance general

Backend:
✅ Índices agregados en MongoDB
✅ Queries optimizadas con select()
✅ Paginación implementada
✅ Cache con Redis (recomendado)

Frontend:
✅ React.memo en componentes pesados
✅ useMemo para cálculos costosos
✅ useCallback para funciones
✅ Lazy loading de rutas

---

📊 Resumen del Refactoring:

Backend:
- Arquitectura más limpia (MVC → MVC + Services)
- Controllers reducidos 60% en líneas
- Testabilidad mejorada
- Queries 40% más rápidas (con índices)

Frontend:
- Código reducido 30% (eliminando duplicación)
- 3 custom hooks reutilizables
- Renders reducidos (memoization)
- Loading time 25% más rápido

⚠️ Testing necesario:
- [ ] Unit tests de services
- [ ] Integration tests de endpoints
- [ ] Component tests con nuevos hooks
- [ ] E2E regression testing

¿Quieres que proceda con el testing?
```

---

## Ejemplo 4: Crear Skill Personalizada

### Contexto
Usuario trabaja frecuentemente con GraphQL y quiere una skill dedicada.

### Conversación

```
Usuario: Trabajo mucho con GraphQL. 
¿Puedes crear una skill para eso?

Agente Orquestador:
¡Por supuesto! Voy a usar la skill-creator para esto.

[Lee /skills/examples/skill-creator/SKILL.md]

📋 Información necesaria para la skill de GraphQL:

1. ¿Scope? 
   → backend (GraphQL APIs)

2. ¿Trigger?
   → "cuando se trabaje con GraphQL, Apollo Server, o resolvers"

3. ¿Tools necesarios?
   → view, file_create, str_replace, bash_tool

4. ¿Qué aspectos cubrir?
   → Setup, schemas, resolvers, mutations, subscriptions

¿Confirmas estos detalles?
```

```
Usuario: Sí, perfecto. También agregale Apollo Client para el frontend.

Agente:
Excelente, voy a crear dos skills complementarias:
1. graphql-backend (scope: backend)
2. graphql-frontend (scope: frontend)

Creando skills...

✅ Skill Backend creada:
   📁 /skills/public/graphql-backend/SKILL.md
   
   Contenido:
   - Setup Apollo Server
   - Definición de schemas (SDL)
   - Resolvers patterns
   - Mutations y Queries
   - Subscriptions (WebSockets)
   - DataLoaders para N+1
   - Error handling
   - Authentication con context
   - Ejemplos prácticos

✅ Skill Frontend creada:
   📁 /skills/public/graphql-frontend/SKILL.md
   
   Contenido:
   - Setup Apollo Client
   - Queries con useQuery
   - Mutations con useMutation
   - Cache management
   - Optimistic updates
   - Subscriptions
   - Error handling
   - Ejemplos con React

Sincronizando con agents.md...
[Ejecuta sync script internamente]

✅ Skills registradas:
   - graphql-backend → backend/agents.md
   - graphql-frontend → frontend/agents.md

¡Listo! Ahora puedes invocar estas skills:
"Lee la skill de graphql-backend"
"Usa la skill de graphql-frontend para crear queries"
```

---

## Ejemplo 5: Debugging Guiado

### Contexto
Usuario tiene un error 500 en un endpoint y no sabe por qué.

### Conversación

```
Usuario: Tengo un error 500 en GET /api/tasks/:id
No sé qué está pasando.

Agente Orquestador:
Voy a ayudarte a debuggear esto sistemáticamente.

Déjame leer la skill de express-mongodb para entender tus patrones...
[Lee /skills/public/express-mongodb/SKILL.md]

Ahora voy a analizar:

🔍 Paso 1: Ver el código del endpoint
[view /backend/routes/tasks.js]
[view /backend/controllers/taskController.js]

Veo que el endpoint llama a `getTaskById` en el controller.

🔍 Paso 2: Analizar el controller
[view /backend/controllers/taskController.js líneas del handler]

```javascript
const getTaskById = async (req, res) => {
  const task = await Task.findById(req.params.id);
  res.json(task);
};
```

🚨 Problema identificado:
1. No hay try-catch (error no capturado)
2. No valida si task existe (puede ser null)
3. No valida formato del ID

📋 Solución propuesta:
```

```
Agente (continúa):
Voy a arreglar el endpoint siguiendo best practices:

```javascript
const getTaskById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Validar formato de ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ 
        success: false,
        message: 'ID de tarea inválido' 
      });
    }
    
    const task = await Task.findById(id);
    
    // Verificar si existe
    if (!task) {
      return res.status(404).json({ 
        success: false,
        message: 'Tarea no encontrada' 
      });
    }
    
    res.status(200).json({ 
      success: true,
      data: task 
    });
    
  } catch (error) {
    next(error); // Pasa al middleware de error
  }
};
```

✅ Cambios aplicados:
1. Try-catch agregado
2. Validación de ID
3. Verificación de existencia
4. Status codes apropiados
5. Respuestas consistentes

🧪 Testing:
- ID inválido → 400 Bad Request
- ID válido no encontrado → 404 Not Found
- ID válido encontrado → 200 OK

¿Quieres que implemente lo mismo en otros endpoints?
```

---

## 📝 Patrones Comunes en los Ejemplos

### Patrón 1: Análisis → Planificación → Ejecución
```
1. Usuario describe necesidad
2. Agente lee skills relevantes
3. Agente explora contexto actual
4. Agente propone plan
5. Usuario aprueba
6. Agente ejecuta con sub-agentes si es complejo
```

### Patrón 2: Skill-First Approach
```
Antes de cualquier implementación:
1. Identificar tecnología/área
2. Leer skill correspondiente
3. Aplicar patrones de la skill
4. Mantener consistencia
```

### Patrón 3: Sub-Agentes para Complejidad
```
Tarea simple → Agente único
Tarea media → Orquestador + 1-2 sub-agentes
Tarea compleja → Orquestador + 3+ sub-agentes

Cada SA:
- Contexto aislado
- Tarea específica
- Devuelve solo resumen
```

### Patrón 4: Validación Progresiva
```
1. Proponer cambios
2. Usuario confirma
3. Implementar incrementalmente
4. Validar cada paso
5. Siguiente incremento
```

---

## 🎯 Tips para Mejores Resultados

### 1. Sé Específico
❌ "Hazme una app"
✅ "Crea una app MERN de gestión de inventario con login y CRUD de productos"

### 2. Confirma Planes
❌ Dejar que el agente implemente sin revisar
✅ Revisar el plan propuesto antes de aprobar

### 3. Usa Skills Explícitamente
❌ "Crea un componente React"
✅ "Lee la skill de React y crea un componente siguiendo esos patrones"

### 4. Divide Tareas Grandes
❌ "Refactoriza todo el proyecto"
✅ "Refactoriza el backend primero, luego el frontend"

### 5. Verifica Incremental
❌ Implementar todo y probar al final
✅ Implementar → probar → siguiente feature

---

## 🚀 Próximos Pasos

Ahora que has visto estos ejemplos:

1. **Prueba el Quickstart**
   ```bash
   ./scripts/setup.sh
   ./scripts/sync.sh
   ```

2. **Experimenta con Conversaciones Simples**
   - "Leer /agents.md"
   - "Crea un componente Button"

3. **Escala a Proyectos Reales**
   - Usa el sistema en tu próximo proyecto
   - Crea skills personalizadas para tus necesidades

4. **Contribuye**
   - Comparte tus skills útiles
   - Mejora las existentes

---

**¿Listo para empezar? ¡Prueba el Quickstart! 🎉**
