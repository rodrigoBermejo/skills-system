# Auth and Security - Application Security Patterns

**Scope:** backend
**Trigger:** cuando se implemente autenticacion, autorizacion, JWT, OAuth, permisos, RBAC, o seguridad de aplicacion
**Tools:** view, file_create, str_replace, bash_tool
**Version:** 1.0.0

---

## Proposito

Esta skill cubre los patrones de autenticacion, autorizacion y seguridad de aplicaciones web. Incluye JWT, OAuth 2.0, RBAC, manejo de sesiones, proteccion contra vulnerabilidades comunes, y configuraciones de seguridad de infraestructura.

## Cuando Usar Esta Skill

- Implementar login/registro con JWT o sesiones
- Configurar OAuth 2.0 / OpenID Connect con proveedores externos
- Disenar modelo de permisos (RBAC)
- Proteger endpoints con middleware de autorizacion
- Configurar CORS, CSRF, headers de seguridad
- Auditar vulnerabilidades comunes (XSS, SQL injection, IDOR)
- Revisar almacenamiento seguro de credenciales

## Contexto y Conocimiento

### Autenticacion vs Autorizacion

| Concepto        | Pregunta que responde | Ejemplo                      |
|-----------------|----------------------|------------------------------|
| Autenticacion   | Quien eres?          | Login con email/password     |
| Autorizacion    | Que puedes hacer?    | Solo admins pueden borrar    |

Primero autenticas, luego autorizas. Nunca mezclar ambos conceptos en la misma capa.

---

## JWT (JSON Web Tokens)

### Estructura del Token

```
Header.Payload.Signature

Header:  { "alg": "HS256", "typ": "JWT" }
Payload: { "sub": "user123", "role": "admin", "exp": 1700000000 }
Signature: HMACSHA256(base64(header) + "." + base64(payload), secret)
```

### Access Token + Refresh Token Flow

```
Cliente                        Servidor
  |                               |
  |--- POST /auth/login --------->|
  |    { email, password }        |
  |                               |-- Validar credenciales
  |<-- 200 ----------------------|
  |    { accessToken (15min),     |
  |      refreshToken (7d) }      |
  |                               |
  |--- GET /api/data ------------>|
  |    Authorization: Bearer AT   |
  |<-- 200 data ------------------|
  |                               |
  |--- (AT expira) -------------->|
  |<-- 401 Unauthorized ----------|
  |                               |
  |--- POST /auth/refresh ------->|
  |    { refreshToken }           |
  |<-- 200 { new AT, new RT } ----|
```

### Implementacion Node.js (Express)

```typescript
import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!;
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;

interface TokenPayload {
  sub: string;
  role: string;
}

// Generar tokens
function generateTokens(user: { id: string; role: string }) {
  const accessToken = jwt.sign(
    { sub: user.id, role: user.role },
    ACCESS_SECRET,
    { expiresIn: "15m" }
  );

  const refreshToken = jwt.sign(
    { sub: user.id },
    REFRESH_SECRET,
    { expiresIn: "7d" }
  );

  return { accessToken, refreshToken };
}

// Middleware de autenticacion
function authenticate(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Token requerido" });
  }

  try {
    const token = header.split(" ")[1];
    const payload = jwt.verify(token, ACCESS_SECRET) as TokenPayload;
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ error: "Token invalido o expirado" });
  }
}

// Endpoint de refresh
app.post("/auth/refresh", async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: "Token requerido" });

  try {
    const payload = jwt.verify(refreshToken, REFRESH_SECRET) as { sub: string };

    // Verificar que el refresh token no esta revocado
    const isRevoked = await db.revokedToken.findUnique({
      where: { token: refreshToken },
    });
    if (isRevoked) return res.status(401).json({ error: "Token revocado" });

    const user = await db.user.findUnique({ where: { id: payload.sub } });
    if (!user) return res.status(401).json({ error: "Usuario no encontrado" });

    // Revocar el refresh token usado (rotation)
    await db.revokedToken.create({ data: { token: refreshToken } });

    const tokens = generateTokens(user);
    return res.json(tokens);
  } catch {
    return res.status(401).json({ error: "Refresh token invalido" });
  }
});
```

### Almacenamiento de Tokens

| Metodo               | Seguridad XSS | Seguridad CSRF | Recomendacion       |
|----------------------|---------------|----------------|---------------------|
| httpOnly cookie      | Seguro        | Vulnerable*    | Recomendado + CSRF  |
| localStorage         | Vulnerable    | Seguro         | No recomendado      |
| sessionStorage       | Vulnerable    | Seguro         | No recomendado      |
| Memory (variable JS) | Seguro        | Seguro         | Se pierde al refrescar |

*Mitigar CSRF con SameSite=Strict y token CSRF.

```typescript
// Enviar access token como httpOnly cookie
res.cookie("accessToken", accessToken, {
  httpOnly: true,      // No accesible desde JavaScript
  secure: true,        // Solo HTTPS
  sameSite: "strict",  // Proteccion CSRF
  maxAge: 15 * 60 * 1000, // 15 minutos
  path: "/",
});
```

---

## OAuth 2.0 / OpenID Connect

### Authorization Code Flow con PKCE (para SPAs)

```
Usuario    SPA (Cliente)         Auth Server          Resource Server
  |           |                       |                       |
  |--click--->|                       |                       |
  |           |--generar code_verifier + code_challenge       |
  |           |                       |                       |
  |           |---/authorize?-------->|                       |
  |           |   response_type=code  |                       |
  |           |   code_challenge=...  |                       |
  |           |   code_challenge_method=S256                  |
  |           |                       |                       |
  |<----------redirect a login--------|                       |
  |--credenciales-------------------->|                       |
  |<----------redirect con code-------|                       |
  |           |                       |                       |
  |           |---POST /token-------->|                       |
  |           |   code + code_verifier|                       |
  |           |<--access_token--------|                       |
  |           |                       |                       |
  |           |---GET /api/resource---|---------------------->|
  |           |   Bearer access_token |                       |
  |           |<--data----------------|<----------------------|
```

### Integracion con Proveedor (ejemplo Google)

```typescript
// Configuracion
const GOOGLE_CONFIG = {
  clientId: process.env.GOOGLE_CLIENT_ID!,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
  redirectUri: `${process.env.APP_URL}/auth/google/callback`,
  authUrl: "https://accounts.google.com/o/oauth2/v2/auth",
  tokenUrl: "https://oauth2.googleapis.com/token",
  userInfoUrl: "https://www.googleapis.com/oauth2/v2/userinfo",
};

// Paso 1: Redirigir al usuario
app.get("/auth/google", (req, res) => {
  const params = new URLSearchParams({
    client_id: GOOGLE_CONFIG.clientId,
    redirect_uri: GOOGLE_CONFIG.redirectUri,
    response_type: "code",
    scope: "openid email profile",
    access_type: "offline",
    prompt: "consent",
  });

  res.redirect(`${GOOGLE_CONFIG.authUrl}?${params}`);
});

// Paso 2: Callback — intercambiar code por token
app.get("/auth/google/callback", async (req, res) => {
  const { code } = req.query;

  const tokenRes = await fetch(GOOGLE_CONFIG.tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code: code as string,
      client_id: GOOGLE_CONFIG.clientId,
      client_secret: GOOGLE_CONFIG.clientSecret,
      redirect_uri: GOOGLE_CONFIG.redirectUri,
      grant_type: "authorization_code",
    }),
  });

  const { access_token } = await tokenRes.json();

  // Obtener info del usuario
  const userRes = await fetch(GOOGLE_CONFIG.userInfoUrl, {
    headers: { Authorization: `Bearer ${access_token}` },
  });
  const profile = await userRes.json();

  // Crear o actualizar usuario en tu DB
  const user = await upsertUser(profile);
  const tokens = generateTokens(user);

  // Redirigir con sesion activa
  res.cookie("accessToken", tokens.accessToken, { httpOnly: true, secure: true });
  res.redirect("/dashboard");
});
```

---

## Manejo de Sesiones

### Server-side Sessions vs JWT Stateless

| Aspecto            | Server-side Sessions     | JWT Stateless           |
|--------------------|--------------------------|-------------------------|
| Estado en servidor | Si (Redis, DB)           | No                      |
| Revocacion         | Inmediata                | Dificil (blacklist)     |
| Escalabilidad      | Requiere store compartido| Facil de escalar        |
| Tamano de payload  | Solo session ID          | Toda la info en token   |

### Prevencion de Session Fixation

```typescript
// Siempre regenerar session ID despues del login
app.post("/login", async (req, res) => {
  const user = await authenticate(req.body);

  // Regenerar sesion para prevenir fixation
  req.session.regenerate((err) => {
    if (err) return res.status(500).json({ error: "Session error" });
    req.session.userId = user.id;
    req.session.role = user.role;
    res.json({ message: "Login exitoso" });
  });
});
```

### Timeouts

- **Idle timeout:** Expira la sesion despues de N minutos de inactividad (ej: 30 min).
- **Absolute timeout:** Expira la sesion despues de N horas sin importar actividad (ej: 8 horas).

---

## RBAC (Role-Based Access Control)

### Modelo de Datos

```sql
-- Roles
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) UNIQUE NOT NULL,   -- 'admin', 'editor', 'viewer'
  description TEXT
);

-- Permisos
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resource VARCHAR(100) NOT NULL,     -- 'posts', 'users', 'billing'
  action VARCHAR(50) NOT NULL,        -- 'create', 'read', 'update', 'delete'
  UNIQUE(resource, action)
);

-- Relacion roles <-> permisos
CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID REFERENCES permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- Relacion usuarios <-> roles
CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);
```

### Middleware de Autorizacion (Express)

```typescript
function authorize(resource: string, action: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user.sub;

    const hasPermission = await db.query(`
      SELECT 1 FROM user_roles ur
      JOIN role_permissions rp ON ur.role_id = rp.role_id
      JOIN permissions p ON rp.permission_id = p.id
      WHERE ur.user_id = $1
        AND p.resource = $2
        AND p.action = $3
      LIMIT 1
    `, [userId, resource, action]);

    if (!hasPermission.rows.length) {
      return res.status(403).json({ error: "Sin permiso" });
    }

    next();
  };
}

// Uso
app.delete("/api/posts/:id",
  authenticate,
  authorize("posts", "delete"),
  deletePostHandler
);
```

### Middleware de Autorizacion (FastAPI)

```python
from fastapi import Depends, HTTPException, status
from functools import wraps

async def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = verify_token(token)
    user = await db.users.find_one({"id": payload["sub"]})
    if not user:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")
    return user

def require_permission(resource: str, action: str):
    async def permission_checker(user = Depends(get_current_user)):
        has_perm = await db.check_permission(user["id"], resource, action)
        if not has_perm:
            raise HTTPException(status_code=403, detail="Sin permiso")
        return user
    return permission_checker

# Uso
@app.delete("/api/posts/{post_id}")
async def delete_post(
    post_id: str,
    user = Depends(require_permission("posts", "delete"))
):
    await db.posts.delete_one({"id": post_id})
    return {"message": "Post eliminado"}
```

---

## Seguridad de Passwords

### Hashing (Nunca MD5, nunca SHA para passwords)

```typescript
import bcrypt from "bcrypt";

const SALT_ROUNDS = 12; // 10-12 es bueno, mas es mas lento

// Hashear al registrar
async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

// Verificar al hacer login
async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

```python
# Python con Argon2 (recomendado sobre bcrypt)
from argon2 import PasswordHasher

ph = PasswordHasher()

hashed = ph.hash("user_password")
try:
    ph.verify(hashed, "user_password")  # True
except argon2.exceptions.VerifyMismatchError:
    # Password incorrecto
    pass
```

### Politicas de Password

- **Minimo 8 caracteres** (NIST recomienda minimo, no maximo artificialmente bajo).
- **Longitud > complejidad**: "correct-horse-battery-staple" es mejor que "P@ssw0rd!".
- **Verificar contra listas de passwords comprometidos** (Have I Been Pwned API).
- **No forzar cambios periodicos** (NIST 800-63B).

### Rate Limiting en Login

```typescript
import rateLimit from "express-rate-limit";

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutos
  max: 5,                     // 5 intentos por ventana
  message: { error: "Demasiados intentos. Intenta en 15 minutos." },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.body.email || req.ip, // Limitar por email o IP
});

app.post("/auth/login", loginLimiter, loginHandler);
```

---

## CORS

```typescript
import cors from "cors";

// Configuracion correcta — nunca usar origin: "*" en produccion con credenciales
app.use(cors({
  origin: [
    "https://miapp.com",
    "https://admin.miapp.com",
  ],
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,     // Permitir cookies cross-origin
  maxAge: 86400,          // Cache preflight 24h
}));
```

---

## Proteccion CSRF

```typescript
import csrf from "csurf";
import cookieParser from "cookie-parser";

app.use(cookieParser());
app.use(csrf({ cookie: { httpOnly: true, secure: true, sameSite: "strict" } }));

// Enviar token CSRF al cliente
app.get("/api/csrf-token", (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// El cliente debe enviar el token en el header X-CSRF-Token
```

---

## Security Headers

```typescript
import helmet from "helmet";

app.use(helmet());

// O configuracion granular:
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "https://cdn.trusted.com"],
      styleSrc: ["'self'", "'unsafe-inline'"],  // Evitar unsafe-inline si es posible
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.miapp.com"],
    },
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  referrerPolicy: { policy: "strict-origin-when-cross-origin" },
}));
```

---

## Validacion y Sanitizacion de Input

```typescript
import { z } from "zod";

// Siempre validar input del usuario con un schema
const CreateUserSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(8).max(128),
  name: z.string().min(1).max(100).trim(),
});

app.post("/api/users", async (req, res) => {
  const result = CreateUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ errors: result.error.flatten() });
  }

  const { email, password, name } = result.data;
  // Proceder con datos validados...
});
```

---

## Vulnerabilidades Comunes y Prevencion

### XSS (Cross-Site Scripting)

```typescript
// MAL — inyeccion directa de HTML
element.innerHTML = userInput;

// BIEN — usar textContent o frameworks con auto-escape
element.textContent = userInput;

// En React: dangerouslySetInnerHTML solo con sanitizacion
import DOMPurify from "dompurify";
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(content) }} />
```

### SQL Injection

```typescript
// MAL — concatenacion de strings
const query = `SELECT * FROM users WHERE email = '${email}'`;

// BIEN — queries parametrizadas
const result = await db.query(
  "SELECT * FROM users WHERE email = $1",
  [email]
);

// BIEN — usar ORM (Prisma, Drizzle, etc.)
const user = await prisma.user.findUnique({ where: { email } });
```

### IDOR (Insecure Direct Object Reference)

```typescript
// MAL — confiar en el ID del request sin verificar propiedad
app.get("/api/orders/:id", async (req, res) => {
  const order = await db.order.findUnique({ where: { id: req.params.id } });
  res.json(order); // Cualquier usuario puede ver cualquier orden
});

// BIEN — verificar que el recurso pertenece al usuario
app.get("/api/orders/:id", authenticate, async (req, res) => {
  const order = await db.order.findUnique({
    where: { id: req.params.id, userId: req.user.sub },
  });
  if (!order) return res.status(404).json({ error: "No encontrado" });
  res.json(order);
});
```

---

## Anti-patrones

- Almacenar passwords en texto plano o con MD5/SHA.
- Guardar JWT en localStorage (vulnerable a XSS).
- No implementar rate limiting en endpoints de login.
- Usar `origin: "*"` en CORS con `credentials: true`.
- Confiar en validaciones del cliente sin validar en el servidor.
- Incluir informacion sensible en el payload del JWT (passwords, PII).
- No rotar refresh tokens (permite reutilizacion de tokens robados).
- Hardcodear secretos en el codigo fuente.
- No implementar HTTPS en produccion.
- Exponer stack traces o errores internos al usuario.
