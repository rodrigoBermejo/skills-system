# FastAPI - Modern Python API Framework

**Scope:** backend  
**Trigger:** cuando se trabaje con FastAPI, APIs modernas en Python, APIs asíncronas, o se mencione desarrollo de APIs rápidas con Python  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para crear APIs RESTful modernas y rápidas con FastAPI. Cubre desde setup hasta producción, incluyendo async/await, Pydantic models, dependency injection, authentication, database integration con SQLAlchemy y deployment.

## 🔧 Cuándo Usar Esta Skill

- Crear APIs REST modernas y rápidas
- Microservicios con Python
- APIs con documentación automática
- Backend para SPAs (React, Angular)
- APIs asíncronas de alto rendimiento
- Reemplazo moderno para Flask/Django REST

## 📚 Contexto y Conocimiento

### Por Qué FastAPI

- ✅ **Rápido** - Uno de los frameworks Python más rápidos
- ✅ **Type hints** - Validación automática con Pydantic
- ✅ **Docs automáticas** - Swagger UI y ReDoc incluidos
- ✅ **Async** - Soporte nativo para async/await
- ✅ **Modern** - Python 3.7+ features
- ✅ **Production-ready** - Usado por Microsoft, Uber, Netflix

### Versiones
- **Python:** 3.10+ (recomendado)
- **FastAPI:** 0.100+
- **Pydantic:** 2.x
- **SQLAlchemy:** 2.0+ (async)
- **Uvicorn:** Latest (ASGI server)

### Setup

```bash
# Crear proyecto
mkdir my_api && cd my_api
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalar FastAPI y deps
pip install "fastapi[all]"  # Incluye uvicorn, pydantic, etc
pip install sqlalchemy asyncpg  # Database
pip install python-jose[cryptography] passlib[bcrypt]  # JWT
pip install python-multipart  # Form data

# Ejecutar
uvicorn main:app --reload
```

### Estructura de Proyecto

```
my_api/
├── app/
│   ├── __init__.py
│   ├── main.py              # Entry point
│   ├── config.py            # Configuration
│   ├── database.py          # DB setup
│   ├── models/              # SQLAlchemy models
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/             # Pydantic schemas
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routers/             # API routes
│   │   ├── __init__.py
│   │   ├── users.py
│   │   └── auth.py
│   ├── services/            # Business logic
│   │   ├── __init__.py
│   │   └── user_service.py
│   └── dependencies.py      # Dependency injection
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── .env
├── requirements.txt
└── README.md
```

## 🚀 Hello World

### Minimal App

```python
# main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}
```

**Ejecutar:**
```bash
uvicorn main:app --reload
# Docs: http://localhost:8000/docs
# ReDoc: http://localhost:8000/redoc
```

## 🎨 Pydantic Schemas

### Request/Response Models

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)
    is_active: bool = True

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class UserUpdate(BaseModel):
    email: EmailStr | None = None
    username: str | None = Field(None, min_length=3, max_length=50)
    is_active: bool | None = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True  # Pydantic v2

class UserLogin(BaseModel):
    email: EmailStr
    password: str

# Uso en endpoint
from fastapi import FastAPI, HTTPStatus

app = FastAPI()

@app.post("/users", response_model=UserResponse, status_code=HTTPStatus.CREATED)
async def create_user(user: UserCreate):
    # Create user logic
    return UserResponse(
        id=1,
        email=user.email,
        username=user.username,
        is_active=user.is_active,
        created_at=datetime.now()
    )
```

### Validación Avanzada

```python
from pydantic import BaseModel, validator, root_validator
from typing import List

class Product(BaseModel):
    name: str
    price: float = Field(..., gt=0)  # Greater than 0
    stock: int = Field(..., ge=0)    # Greater or equal 0
    tags: List[str] = []
    
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.title()
    
    @validator('tags')
    def tags_must_be_unique(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('Tags must be unique')
        return v
    
    @root_validator
    def check_stock_for_price(cls, values):
        price, stock = values.get('price'), values.get('stock')
        if price and price > 1000 and stock and stock < 5:
            raise ValueError('Expensive items need more stock')
        return values
```

## 🗄️ Database con SQLAlchemy 2.0 (Async)

### Configuration

```python
# database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.ext.asyncio import async_sessionmaker
from sqlalchemy.orm import declarative_base
from typing import AsyncGenerator

DATABASE_URL = "postgresql+asyncpg://user:password@localhost/dbname"

engine = create_async_engine(
    DATABASE_URL,
    echo=True,
    future=True
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

Base = declarative_base()

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Models (SQLAlchemy)

```python
# models/user.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

### CRUD Operations

```python
# services/user_service.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.models.user import User
from app.schemas.user import UserCreate
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserService:
    @staticmethod
    async def get_all(db: AsyncSession) -> List[User]:
        result = await db.execute(select(User))
        return result.scalars().all()
    
    @staticmethod
    async def get_by_id(db: AsyncSession, user_id: int) -> User | None:
        result = await db.execute(
            select(User).filter(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_by_email(db: AsyncSession, email: str) -> User | None:
        result = await db.execute(
            select(User).filter(User.email == email)
        )
        return result.scalar_one_or_none()
    
    @staticmethod
    async def create(db: AsyncSession, user_data: UserCreate) -> User:
        hashed_password = pwd_context.hash(user_data.password)
        db_user = User(
            email=user_data.email,
            username=user_data.username,
            hashed_password=hashed_password,
            is_active=user_data.is_active
        )
        db.add(db_user)
        await db.flush()
        await db.refresh(db_user)
        return db_user
    
    @staticmethod
    async def update(db: AsyncSession, user_id: int, user_data: dict) -> User | None:
        result = await db.execute(
            select(User).filter(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        if not user:
            return None
        
        for key, value in user_data.items():
            if value is not None:
                setattr(user, key, value)
        
        await db.flush()
        await db.refresh(user)
        return user
    
    @staticmethod
    async def delete(db: AsyncSession, user_id: int) -> bool:
        result = await db.execute(
            select(User).filter(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        if not user:
            return False
        
        await db.delete(user)
        return True
```

## 🛣️ Routers

### User Router

```python
# routers/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.database import get_db
from app.schemas.user import UserCreate, UserResponse, UserUpdate
from app.services.user_service import UserService

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/", response_model=List[UserResponse])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    users = await UserService.get_all(db)
    return users[skip:skip + limit]

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    user = await UserService.get_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    # Check if email exists
    existing = await UserService.get_by_email(db, user_data.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    user = await UserService.create(db, user_data)
    return user

@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: AsyncSession = Depends(get_db)
):
    updated = await UserService.update(
        db,
        user_id,
        user_data.model_dump(exclude_unset=True)
    )
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return updated

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    deleted = await UserService.delete(db, user_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return None
```

## 🔐 Authentication con JWT

### JWT Utils

```python
# dependencies.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

SECRET_KEY = "your-secret-key-here"  # Use env variable
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = await UserService.get_by_email(db, email)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
```

### Auth Router

```python
# routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from passlib.context import CryptContext

router = APIRouter(prefix="/auth", tags=["auth"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.post("/login")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    user = await UserService.get_by_email(db, form_data.username)
    if not user or not pwd_context.verify(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(
        data={"sub": user.email},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_active_user)):
    return current_user
```

### Protected Routes

```python
@router.get("/protected", response_model=UserResponse)
async def protected_route(
    current_user: User = Depends(get_current_active_user)
):
    return current_user

# Role-based
def require_role(role: str):
    async def role_checker(user: User = Depends(get_current_active_user)):
        if user.role != role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        return user
    return role_checker

@router.delete("/admin/users/{user_id}")
async def admin_delete_user(
    user_id: int,
    admin: User = Depends(require_role("admin"))
):
    # Delete logic
    pass
```

## 🎯 Main App Setup

```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, auth
from app.database import engine, Base

app = FastAPI(
    title="My API",
    description="API with FastAPI",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Production: specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users.router)
app.include_router(auth.router)

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@app.on_event("shutdown")
async def shutdown():
    await engine.dispose()

@app.get("/")
async def root():
    return {"message": "Welcome to My API"}
```

## 🧪 Testing

```python
# tests/test_main.py
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to My API"}

def test_create_user():
    response = client.post(
        "/users",
        json={
            "email": "test@example.com",
            "username": "testuser",
            "password": "password123"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_login():
    response = client.post(
        "/auth/login",
        data={"username": "test@example.com", "password": "password123"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| 422 Unprocessable Entity | Validación Pydantic falló | Verificar request body |
| RuntimeError: no running event loop | Async mal usado | Usar async/await consistentemente |
| asyncpg.exceptions | DB connection | Verificar DATABASE_URL |
| ImportError | Paquete no instalado | pip install paquete |

## 📋 Checklist Production

- [ ] Async database access
- [ ] JWT authentication
- [ ] CORS configurado
- [ ] Environment variables
- [ ] Error handling global
- [ ] Logging configurado
- [ ] Tests con >70% coverage
- [ ] Rate limiting (slowapi)
- [ ] API documentation
- [ ] Docker container

## 🎓 Best Practices

1. **Async everywhere** - Usar async/await para I/O
2. **Pydantic models** - Para validación automática
3. **Dependency injection** - Para DB, auth, etc
4. **Type hints** - En todo el código
5. **Router separation** - Un archivo por recurso
6. **Service layer** - Separar lógica de negocio
7. **Environment variables** - Para secrets
8. **Testing** - Unit + integration tests
9. **Documentation** - FastAPI auto-genera docs
10. **Logging** - Usar logging, no print

---

**Última actualización:** Fase 5 - Skills Python Stack  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Flask para web apps tradicionales
