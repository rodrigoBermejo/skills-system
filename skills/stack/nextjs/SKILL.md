# Next.js - Modern Full-Stack React Framework

**Scope:** frontend
**Trigger:** cuando se trabaje con Next.js, App Router, SSR, SSG, o routing avanzado en React
**Tools:** view, file_create, str_replace, bash_tool
**Version:** 1.0.0

---

## Proposito

Esta skill cubre el desarrollo con Next.js 14+ usando App Router exclusivamente. No cubre Pages Router (legacy). Incluye estructura de proyecto, routing, Server Components, data fetching, API routes, middleware, SEO, deployment y patrones de rendimiento.

## Cuando Usar Esta Skill

- Crear proyectos Next.js con App Router
- Configurar routing avanzado (layouts, grupos, rutas paralelas)
- Decidir entre Server Components y Client Components
- Implementar data fetching con Server Actions
- Crear API routes y middleware
- Optimizar SEO con metadata
- Configurar deployment (Vercel, Docker, standalone)
- Resolver errores comunes (hydration mismatch, boundaries)

## Contexto y Conocimiento

### Version Actual

Next.js 14+ con App Router (siempre usar la ultima version estable).

### Setup del Proyecto

```bash
npx create-next-app@latest my-app \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

cd my-app
npm run dev
```

### Estructura Recomendada de Proyecto

```
src/
├── app/                    # App Router — cada carpeta es una ruta
│   ├── layout.tsx          # Root layout (obligatorio)
│   ├── page.tsx            # Pagina raiz /
│   ├── loading.tsx         # UI de carga (Suspense automatico)
│   ├── error.tsx           # Error boundary de la ruta
│   ├── not-found.tsx       # Pagina 404 personalizada
│   ├── global-error.tsx    # Error boundary global (incluye html/body)
│   ├── (marketing)/        # Route group — no afecta URL
│   │   ├── about/page.tsx
│   │   └── pricing/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx      # Layout anidado
│   │   ├── page.tsx
│   │   └── settings/page.tsx
│   ├── blog/
│   │   ├── page.tsx
│   │   └── [slug]/page.tsx # Ruta dinamica
│   └── api/
│       └── webhook/route.ts # API route handler
├── components/
│   ├── ui/                 # Componentes UI reutilizables
│   ├── forms/              # Componentes de formulario
│   └── layouts/            # Componentes de layout compartidos
├── lib/                    # Utilidades, helpers, configuraciones
│   ├── db.ts
│   ├── auth.ts
│   └── utils.ts
├── types/                  # TypeScript types/interfaces
├── hooks/                  # Custom React hooks
├── middleware.ts           # Middleware global (raiz de src/)
└── public/                 # Archivos estaticos
    ├── images/
    └── favicon.ico
```

### Regla critica: No mover middleware.ts dentro de app/

`middleware.ts` va en la raiz de `src/` (o raiz del proyecto si no usas `src/`). Nunca dentro de `app/`.

---

## Routing

### Archivos Especiales por Ruta

| Archivo         | Proposito                                         |
|-----------------|---------------------------------------------------|
| `page.tsx`      | UI unica de la ruta — la hace accesible           |
| `layout.tsx`    | UI compartida entre rutas hijas — no se re-renderiza |
| `loading.tsx`   | Fallback de Suspense automatico                   |
| `error.tsx`     | Error boundary de la ruta (debe ser Client Component) |
| `not-found.tsx` | UI para `notFound()` de esta ruta                 |
| `route.ts`      | API endpoint (GET, POST, etc.) — sin UI           |

### Layouts

```tsx
// app/layout.tsx — Root Layout (obligatorio, incluye html y body)
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: { default: "Mi App", template: "%s | Mi App" },
  description: "Descripcion de la aplicacion",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
```

```tsx
// app/dashboard/layout.tsx — Layout anidado
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <aside><Sidebar /></aside>
      <main className="flex-1">{children}</main>
    </div>
  );
}
```

### Rutas Dinamicas

```tsx
// app/blog/[slug]/page.tsx
interface Props {
  params: Promise<{ slug: string }>;
}

export default async function BlogPost({ params }: Props) {
  const { slug } = await params;
  const post = await getPost(slug);
  return <article>{post.content}</article>;
}

// Generar paginas estaticas para rutas dinamicas
export async function generateStaticParams() {
  const posts = await getAllPosts();
  return posts.map((post) => ({ slug: post.slug }));
}
```

### Route Groups

```
app/
├── (auth)/          # Grupo — no aparece en la URL
│   ├── layout.tsx   # Layout compartido solo para auth
│   ├── login/page.tsx    # /login
│   └── register/page.tsx # /register
├── (main)/
│   ├── layout.tsx   # Layout diferente para el resto
│   └── dashboard/page.tsx # /dashboard
```

### Rutas Paralelas

```
app/
├── @modal/
│   └── login/page.tsx
├── @feed/
│   └── page.tsx
├── layout.tsx       # Recibe ambos slots como props
└── page.tsx
```

```tsx
// app/layout.tsx con rutas paralelas
export default function Layout({
  children,
  modal,
  feed,
}: {
  children: React.ReactNode;
  modal: React.ReactNode;
  feed: React.ReactNode;
}) {
  return (
    <>
      {children}
      {modal}
      {feed}
    </>
  );
}
```

---

## Server Components vs Client Components

### Regla por Defecto

Todo componente en App Router es **Server Component** por defecto. Solo marca `"use client"` cuando sea necesario.

### Cuando Usar Cada Uno

| Server Component (default)           | Client Component ("use client")         |
|--------------------------------------|-----------------------------------------|
| Fetch de datos                       | useState, useEffect, hooks de estado    |
| Acceso a backend (DB, filesystem)    | Event handlers (onClick, onChange)       |
| Tokens, API keys (seguros)           | APIs del navegador (localStorage, etc.) |
| Dependencias grandes (no van al bundle) | Interactividad del usuario           |
| Sin interactividad                   | Componentes de terceros con hooks       |

### Patron: Empujar "use client" hacia abajo

```tsx
// app/dashboard/page.tsx — Server Component (fetch de datos)
import { InteractiveChart } from "@/components/interactive-chart";

export default async function Dashboard() {
  const data = await fetchAnalytics(); // Esto corre en el servidor

  return (
    <div>
      <h1>Dashboard</h1>
      {/* Solo el chart necesita interactividad */}
      <InteractiveChart data={data} />
    </div>
  );
}
```

```tsx
// components/interactive-chart.tsx — Client Component
"use client";

import { useState } from "react";

export function InteractiveChart({ data }: { data: AnalyticsData }) {
  const [range, setRange] = useState("7d");
  // Logica interactiva aqui...
}
```

### Error Comun: Hydration Mismatch

Ocurre cuando el HTML del servidor difiere del render del cliente.

```tsx
// MAL — genera diferente HTML en server vs client
"use client";
export function Greeting() {
  return <p>Son las {new Date().toLocaleTimeString()}</p>;
}

// BIEN — suprimir hydration warning o usar useEffect
"use client";
import { useState, useEffect } from "react";

export function Greeting() {
  const [time, setTime] = useState<string | null>(null);

  useEffect(() => {
    setTime(new Date().toLocaleTimeString());
  }, []);

  if (!time) return <p>Cargando hora...</p>;
  return <p>Son las {time}</p>;
}
```

---

## Data Fetching

### Fetch en Server Components

```tsx
// app/products/page.tsx — fetch directo (no necesita useEffect)
async function getProducts() {
  const res = await fetch("https://api.example.com/products", {
    next: { revalidate: 3600 }, // ISR: revalidar cada hora
  });
  if (!res.ok) throw new Error("Failed to fetch products");
  return res.json();
}

export default async function ProductsPage() {
  const products = await getProducts();
  return <ProductList products={products} />;
}
```

### Server Actions

```tsx
// app/actions.ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  await db.post.create({ data: { title, content } });

  revalidatePath("/blog");
  redirect("/blog");
}
```

```tsx
// app/blog/new/page.tsx — usar Server Action en formulario
import { createPost } from "@/app/actions";

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Crear Post</button>
    </form>
  );
}
```

---

## API Routes (Route Handlers)

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const page = searchParams.get("page") ?? "1";

  const users = await db.user.findMany({
    skip: (Number(page) - 1) * 10,
    take: 10,
  });

  return NextResponse.json({ users, page });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const user = await db.user.create({ data: body });

  return NextResponse.json(user, { status: 201 });
}
```

```tsx
// app/api/users/[id]/route.ts — ruta dinamica
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const user = await db.user.findUnique({ where: { id } });

  if (!user) {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }

  return NextResponse.json(user);
}
```

---

## Middleware

```tsx
// src/middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // Verificar autenticacion
  const token = request.cookies.get("session")?.value;

  if (!token && request.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  // Agregar headers personalizados
  const response = NextResponse.next();
  response.headers.set("x-custom-header", "value");
  return response;
}

// Configurar en que rutas aplica
export const config = {
  matcher: ["/dashboard/:path*", "/api/:path*"],
};
```

---

## Metadata y SEO

```tsx
// app/layout.tsx — metadata estatica
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: { default: "Mi App", template: "%s | Mi App" },
  description: "Descripcion del sitio",
  openGraph: {
    type: "website",
    locale: "es_MX",
    siteName: "Mi App",
  },
};
```

```tsx
// app/blog/[slug]/page.tsx — metadata dinamica
import type { Metadata } from "next";

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: { images: [post.coverImage] },
  };
}
```

```tsx
// app/sitemap.ts
import type { MetadataRoute } from "next";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const posts = await getAllPosts();

  return [
    { url: "https://example.com", lastModified: new Date() },
    ...posts.map((post) => ({
      url: `https://example.com/blog/${post.slug}`,
      lastModified: post.updatedAt,
    })),
  ];
}
```

---

## Image Optimization

```tsx
import Image from "next/image";

// Imagen local — importar directamente
import heroImage from "@/public/images/hero.jpg";

export function Hero() {
  return (
    <Image
      src={heroImage}
      alt="Hero image"
      placeholder="blur"     // Blur-up automatico para imagenes locales
      priority               // Cargar inmediato (above the fold)
    />
  );
}

// Imagen remota — requiere configuracion
export function Avatar({ src }: { src: string }) {
  return (
    <Image
      src={src}
      alt="Avatar"
      width={48}
      height={48}
      className="rounded-full"
    />
  );
}
```

```js
// next.config.js — permitir dominios remotos
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "cdn.example.com" },
      { protocol: "https", hostname: "avatars.githubusercontent.com" },
    ],
  },
};

module.exports = nextConfig;
```

---

## Variables de Entorno

```
# .env.local (nunca commitear)
DATABASE_URL=postgresql://...       # Solo servidor
API_SECRET=abc123                   # Solo servidor
NEXT_PUBLIC_API_URL=https://...     # Disponible en cliente Y servidor
```

Regla: Solo variables con prefijo `NEXT_PUBLIC_` son accesibles en Client Components. Las demas solo estan disponibles en Server Components, Server Actions, y Route Handlers.

---

## Performance

### Streaming con Suspense

```tsx
import { Suspense } from "react";

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />  {/* Server Component asincrono */}
      </Suspense>
      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />
      </Suspense>
    </div>
  );
}
```

### Loading UI Automatico

```tsx
// app/dashboard/loading.tsx — se muestra automaticamente mientras page.tsx carga
export default function Loading() {
  return <DashboardSkeleton />;
}
```

### Parallel Data Fetching

```tsx
export default async function Dashboard() {
  // MAL — secuencial (waterfall)
  const user = await getUser();
  const posts = await getPosts();

  // BIEN — paralelo
  const [user, posts] = await Promise.all([
    getUser(),
    getPosts(),
  ]);

  return <DashboardView user={user} posts={posts} />;
}
```

---

## Deployment

### Vercel (Recomendado)

```bash
npm i -g vercel
vercel
```

### Docker (Standalone)

```js
// next.config.js
const nextConfig = {
  output: "standalone",
};
```

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["node", "server.js"]
```

---

## Best Practices

1. **Colocacion:** Mantener archivos relacionados juntos. Components usados solo en una ruta van en la carpeta de esa ruta.
2. **Path aliases:** Siempre usar `@/` para imports absolutos. Evitar `../../../`.
3. **Barrel exports:** Usar `index.ts` en carpetas de componentes para imports limpios.
4. **Server-first:** Mantener la mayor parte de la logica en Server Components. Solo marcar `"use client"` cuando sea estrictamente necesario.
5. **Cache y revalidacion:** Usar `revalidatePath` y `revalidateTag` para invalidar cache de forma granular.
6. **Error boundaries:** Siempre incluir `error.tsx` en rutas criticas. Debe ser Client Component.
7. **Loading states:** Preferir `loading.tsx` por ruta sobre spinners manuales.

---

## Anti-patrones

- Usar Pages Router en proyectos nuevos (legacy).
- Poner `"use client"` en el layout raiz (rompe Server Components en toda la app).
- Hacer fetch en Client Components cuando se puede hacer en Server Components.
- No manejar estados de error — siempre incluir `error.tsx`.
- Usar `getServerSideProps` / `getStaticProps` (eso es Pages Router, no App Router).
- Ignorar `loading.tsx` y dejar pantallas en blanco durante navegacion.
- Commitear `.env.local` al repositorio.
