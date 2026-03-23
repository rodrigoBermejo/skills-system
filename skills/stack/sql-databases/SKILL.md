# SQL Databases - PostgreSQL, MySQL, SQL Server

**Scope:** backend  
**Trigger:** cuando se trabaje con bases de datos SQL, PostgreSQL, MySQL, SQL Server, diseño de schemas relacionales, o queries SQL  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## Proposito

Esta skill te guía para diseñar y trabajar con bases de datos SQL relacionales. Cubre PostgreSQL, MySQL y SQL Server, incluyendo diseño de schemas, normalización, índices, queries complejas, transacciones y optimización.

## Cuando Usar Esta Skill

- Diseñar schemas de bases de datos relacionales
- Elegir entre PostgreSQL, MySQL o SQL Server
- Escribir queries SQL optimizadas
- Implementar relaciones (1:1, 1:N, N:M)
- Crear índices para performance
- Trabajar con transacciones
- Migrar datos entre bases de datos
- Optimizar queries lentas

## Contexto y Conocimiento

### Comparativa de Bases de Datos SQL

| Feature | PostgreSQL | MySQL | SQL Server |
|---------|------------|-------|------------|
| **Licencia** | Open Source (MIT) | Open Source (GPL) / Commercial | Microsoft (Comercial) |
| **Mejor para** | Apps complejas, analytics | Web apps, read-heavy | Enterprise, Windows |
| **JSON Support** | Excelente (JSONB) | Bueno | Bueno |
| **Full-text search** | Excelente | Bueno | Excelente |
| **Window Functions** | Sí | Sí (8.0+) | Sí |
| **Extensibilidad** | Excelente | Limitada | Limitada |
| **Performance** | Muy buena | Excelente (read) | Muy buena |
| **ACID** | Completo | Completo (InnoDB) | Completo |
| **Replication** | Sí | Sí | Sí |
| **Cloud** | AWS RDS, Azure | AWS RDS, Azure | Azure SQL |

### Cuándo Usar Cada Una

**PostgreSQL:**
- ✅ Aplicaciones complejas con lógica en DB
- ✅ Analytics y data warehousing
- ✅ Necesitas JSONB y tipos avanzados
- ✅ Full-text search robusto
- ✅ Cumplimiento SQL standard estricto

**MySQL:**
- ✅ Web applications (WordPress, etc.)
- ✅ Read-heavy workloads
- ✅ Simplicidad y facilidad de uso
- ✅ Replication master-slave
- ✅ Compatible con muchos hostings

**SQL Server:**
- ✅ Entornos enterprise Windows
- ✅ Integración con .NET y Azure
- ✅ Business Intelligence (SSRS, SSIS)
- ✅ Soporte enterprise de Microsoft
- ✅ Herramientas GUI robustas

## Diseno de Schema

### Normalización

**Primera Forma Normal (1NF):**
```sql
-- ❌ MAL - Valores múltiples en una columna
CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    products VARCHAR(500)  -- "Product1, Product2, Product3"
);

-- ✅ BIEN - Valores atómicos
CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    product_name VARCHAR(100)
);
```

**Segunda Forma Normal (2NF):**
```sql
-- ❌ MAL - Dependencias parciales
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    product_name VARCHAR(100),    -- Depende solo de product_id
    product_price DECIMAL(10,2),  -- Depende solo de product_id
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- ✅ BIEN - Separar entidades
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT REFERENCES products(id),
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);
```

**Tercera Forma Normal (3NF):**
```sql
-- ❌ MAL - Dependencias transitivas
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),  -- Depende de department_id, no de id
    department_location VARCHAR(100)
);

-- ✅ BIEN - Eliminar dependencias transitivas
CREATE TABLE departments (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT REFERENCES departments(id)
);
```

### Tipos de Relaciones

**1:1 (One-to-One):**
```sql
-- Usuario y Perfil (1:1)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    bio TEXT,
    avatar_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**1:N (One-to-Many):**
```sql
-- Usuario y Posts (1:N)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index para queries frecuentes
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

**N:M (Many-to-Many):**
```sql
-- Estudiantes y Cursos (N:M) con tabla intermedia
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE
);

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade DECIMAL(3,2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Indexes para lookups
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
```

## Queries Esenciales

### CRUD Operations

```sql
-- CREATE
INSERT INTO users (username, email, password_hash)
VALUES ('john_doe', 'john@example.com', 'hashed_password');

-- Insertar múltiples
INSERT INTO products (name, price, stock)
VALUES 
    ('Product A', 29.99, 100),
    ('Product B', 49.99, 50),
    ('Product C', 19.99, 200);

-- READ
SELECT * FROM users WHERE id = 1;

-- Con JOIN
SELECT u.username, p.title, p.created_at
FROM users u
INNER JOIN posts p ON u.id = p.user_id
WHERE u.id = 1
ORDER BY p.created_at DESC;

-- UPDATE
UPDATE users
SET email = 'newemail@example.com',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- DELETE
DELETE FROM posts WHERE id = 5;

-- DELETE con JOIN (PostgreSQL)
DELETE FROM order_items oi
USING orders o
WHERE oi.order_id = o.id
  AND o.status = 'cancelled';
```

### JOINs

```sql
-- INNER JOIN - Solo registros con match
SELECT u.username, p.title
FROM users u
INNER JOIN posts p ON u.id = p.user_id;

-- LEFT JOIN - Todos los users, incluso sin posts
SELECT u.username, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.username;

-- RIGHT JOIN - Todos los posts, incluso sin user
SELECT u.username, p.title
FROM users u
RIGHT JOIN posts p ON u.id = p.user_id;

-- FULL OUTER JOIN - Todos los registros de ambas tablas
SELECT u.username, p.title
FROM users u
FULL OUTER JOIN posts p ON u.id = p.user_id;

-- SELF JOIN - Empleados y sus managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### Aggregations

```sql
-- COUNT, SUM, AVG, MIN, MAX
SELECT 
    COUNT(*) as total_orders,
    SUM(total_amount) as revenue,
    AVG(total_amount) as avg_order_value,
    MIN(total_amount) as min_order,
    MAX(total_amount) as max_order
FROM orders
WHERE status = 'completed';

-- GROUP BY
SELECT 
    user_id,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent
FROM orders
GROUP BY user_id
HAVING SUM(total_amount) > 1000
ORDER BY total_spent DESC;

-- GROUP BY con múltiples columnas
SELECT 
    DATE_TRUNC('month', created_at) as month,
    status,
    COUNT(*) as count
FROM orders
GROUP BY DATE_TRUNC('month', created_at), status
ORDER BY month DESC, status;
```

### Window Functions

```sql
-- ROW_NUMBER - Numerar filas
SELECT 
    name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- RANK - Con empates
SELECT 
    name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;

-- Running total
SELECT 
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Moving average
SELECT 
    date,
    revenue,
    AVG(revenue) OVER (
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7days
FROM daily_revenue;
```

### Subqueries

```sql
-- Subquery en WHERE
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery en FROM
SELECT dept, avg_salary
FROM (
    SELECT department as dept, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department
) dept_salaries
WHERE avg_salary > 50000;

-- EXISTS
SELECT u.username
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
    AND o.total_amount > 1000
);

-- NOT EXISTS
SELECT p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.id
);
```

### Common Table Expressions (CTEs)

```sql
-- CTE simple
WITH high_value_customers AS (
    SELECT user_id, SUM(total_amount) as lifetime_value
    FROM orders
    GROUP BY user_id
    HAVING SUM(total_amount) > 5000
)
SELECT u.username, hvc.lifetime_value
FROM users u
INNER JOIN high_value_customers hvc ON u.id = hvc.user_id;

-- CTE recursivo - Árbol de categorías
WITH RECURSIVE category_tree AS (
    -- Anchor: categorías raíz
    SELECT id, name, parent_id, 1 as level
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursión: hijos
    SELECT c.id, c.name, c.parent_id, ct.level + 1
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY level, name;
```

## Indices y Performance

### Tipos de Índices

```sql
-- B-Tree Index (default) - Para comparaciones
CREATE INDEX idx_users_email ON users(email);

-- Composite Index - Para múltiples columnas
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial Index - Solo parte de los datos
CREATE INDEX idx_active_users ON users(email) 
WHERE status = 'active';

-- Unique Index
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);

-- Full-text Index (PostgreSQL)
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', content));

-- JSON Index (PostgreSQL)
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);
```

### Cuándo Usar Índices

```
✅ USA índices cuando:
- Columnas en WHERE frecuentemente
- Columnas en JOIN
- Columnas en ORDER BY
- Foreign keys
- Columnas con alta cardinalidad

❌ NO uses índices cuando:
- Tabla muy pequeña (<1000 rows)
- Columna cambia frecuentemente
- Baja cardinalidad (ej: género)
- Queries hacen full table scan anyway
```

### Analizar Queries

**PostgreSQL:**
```sql
EXPLAIN ANALYZE
SELECT u.username, COUNT(p.id)
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.username;

-- Ver índices usados
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

**MySQL:**
```sql
EXPLAIN
SELECT u.username, COUNT(p.id)
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.username;

-- Ver índices no usados
SELECT 
    t.table_schema,
    t.table_name,
    s.index_name
FROM information_schema.tables t
INNER JOIN information_schema.statistics s 
    ON s.table_schema = t.table_schema 
    AND s.table_name = t.table_name
WHERE t.table_schema NOT IN ('mysql', 'information_schema', 'performance_schema')
    AND s.index_name NOT IN ('PRIMARY')
ORDER BY t.table_name, s.index_name;
```

## Transacciones

```sql
-- Transaction básica
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- Si todo está bien
COMMIT;

-- Si algo falla
-- ROLLBACK;
```

**Con manejo de errores (PostgreSQL):**
```sql
DO $$
BEGIN
    -- Intentar la transacción
    UPDATE accounts SET balance = balance - 100 WHERE id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE id = 2;
    
    -- Verificar saldo
    IF (SELECT balance FROM accounts WHERE id = 1) < 0 THEN
        RAISE EXCEPTION 'Insufficient funds';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaction failed: %', SQLERRM;
        -- El ROLLBACK es automático en excepciones
END $$;
```

**Niveles de Aislamiento:**
```sql
-- READ UNCOMMITTED (más permisivo)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- READ COMMITTED (default en PostgreSQL y SQL Server)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ (default en MySQL InnoDB)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE (más restrictivo)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

## Seguridad

```sql
-- Crear usuario
CREATE USER app_user WITH PASSWORD 'secure_password';

-- Crear database
CREATE DATABASE myapp_db OWNER app_user;

-- Otorgar permisos
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Revocar permisos
REVOKE DELETE ON users FROM app_user;

-- Rol para aplicación (mejores prácticas)
CREATE ROLE app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;

CREATE USER readonly_user WITH PASSWORD 'password';
GRANT app_readonly TO readonly_user;
```

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Slow queries | Sin índices | Analizar con EXPLAIN, agregar índices |
| Deadlocks | Locks en orden diferente | Ordenar queries consistentemente |
| N+1 queries | Fetch en loops | Usar JOINs o batch loading |
| Cartesian product | JOIN sin ON | Siempre especificar condición JOIN |
| Index not used | Funciones en WHERE | Usar functional index o reescribir |

## Checklist de Diseno

- [ ] Normalizado hasta 3NF (mínimo)
- [ ] Primary keys en todas las tablas
- [ ] Foreign keys con ON DELETE/UPDATE
- [ ] Índices en foreign keys
- [ ] Índices en columnas de búsqueda
- [ ] Constraints (NOT NULL, UNIQUE, CHECK)
- [ ] Default values apropiados
- [ ] Timestamps (created_at, updated_at)
- [ ] Migrations versionadas
- [ ] Backups configurados

## Best Practices

1. **Normalización** - Al menos 3NF para evitar redundancia
2. **Índices estratégicos** - No indexar todo
3. **Foreign keys** - ALWAYS con constraints
4. **Transactions** - Para operaciones múltiples
5. **Prepared statements** - Prevenir SQL injection
6. **Connection pooling** - Reusar conexiones
7. **Migrations** - Versionar cambios de schema
8. **Backups** - Automáticos y testeados
9. **Monitoring** - Query performance logs
10. **Documentation** - Comentarios en schema

---

**Última actualización:** Fase 4 - Skills Backend Robusto  
**Mantenedor:** Sistema de Skills  
**Siguiente:** API Best Practices para completar backend enterprise
