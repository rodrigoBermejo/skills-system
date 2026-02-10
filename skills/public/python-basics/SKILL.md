# Python Basics - Modern Python Development

**Scope:** backend  
**Trigger:** cuando se trabaje con Python, se mencione desarrollo Python, scripting, o fundamentos de Python  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para desarrollar con Python moderno (3.10+). Cubre desde fundamentos hasta patrones avanzados, type hints, async/await, manejo de archivos, testing con pytest y mejores prácticas para código production-ready.

## 🔧 Cuándo Usar Esta Skill

- Empezar con Python desde cero
- Scripting y automatización
- Data processing básico
- APIs backend (base para FastAPI/Flask)
- Testing con pytest
- Type hints y código mantenible

## 📚 Contexto y Conocimiento

### Versiones
- **Python:** 3.10+ (recomendado 3.11 o 3.12)
- **Gestor de paquetes:** pip + venv o poetry
- **Testing:** pytest
- **Linting:** ruff o black + mypy

### Setup de Ambiente

```bash
# Verificar versión
python --version  # o python3 --version

# Crear virtual environment
python -m venv venv

# Activar venv
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar paquetes
pip install pytest black mypy ruff

# Crear requirements.txt
pip freeze > requirements.txt

# Instalar desde requirements
pip install -r requirements.txt
```

### Estructura de Proyecto

```
my_project/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── utils/
│   │   ├── __init__.py
│   │   └── helpers.py
│   └── models/
│       ├── __init__.py
│       └── user.py
├── tests/
│   ├── __init__.py
│   ├── test_main.py
│   └── test_utils.py
├── .gitignore
├── requirements.txt
├── pyproject.toml
└── README.md
```

## 🚀 Fundamentos

### Variables y Tipos

```python
# Type hints (Python 3.10+)
name: str = "John"
age: int = 30
height: float = 1.75
is_active: bool = True
items: list[str] = ["apple", "banana"]
user: dict[str, int] = {"age": 30, "score": 100}

# Type hints avanzados
from typing import Optional, Union, Any

def greet(name: str, age: Optional[int] = None) -> str:
    if age:
        return f"Hello {name}, you are {age} years old"
    return f"Hello {name}"

# Union types (Python 3.10+)
def process(value: int | str) -> str:
    return str(value)

# None type
result: str | None = None
```

### Strings

```python
# f-strings (recomendado)
name = "Alice"
age = 25
message = f"Hello {name}, you are {age} years old"

# Multiline strings
text = """
This is a
multiline string
"""

# String methods
text = "  Hello World  "
text.strip()           # "Hello World"
text.lower()           # "  hello world  "
text.upper()           # "  HELLO WORLD  "
text.replace("o", "0") # "  Hell0 W0rld  "
text.split()           # ["Hello", "World"]

# String formatting
"{:,.2f}".format(1234.5678)  # "1,234.57"
f"{1234.5678:,.2f}"          # "1,234.57"
```

### Collections

```python
# Lists (mutable, ordered)
numbers: list[int] = [1, 2, 3, 4, 5]
numbers.append(6)
numbers.extend([7, 8])
numbers.pop()              # Remove last
numbers.remove(3)          # Remove by value
numbers.insert(0, 0)       # Insert at index

# List comprehensions
squares = [x**2 for x in range(10)]
evens = [x for x in range(10) if x % 2 == 0]

# Tuples (immutable)
point: tuple[int, int] = (10, 20)
x, y = point  # Unpacking

# Sets (unique, unordered)
unique_numbers: set[int] = {1, 2, 3, 3, 4}  # {1, 2, 3, 4}
unique_numbers.add(5)
unique_numbers.remove(2)

# Dictionaries
user: dict[str, any] = {
    "name": "John",
    "age": 30,
    "email": "john@example.com"
}
user["age"] = 31
user.get("phone", "N/A")  # Default value

# Dict comprehensions
squared = {x: x**2 for x in range(5)}
```

### Control Flow

```python
# if/elif/else
age = 18
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teenager")
else:
    print("Child")

# Ternary operator
status = "Adult" if age >= 18 else "Minor"

# for loops
for i in range(5):
    print(i)

for item in ["a", "b", "c"]:
    print(item)

for index, item in enumerate(["a", "b", "c"]):
    print(f"{index}: {item}")

# while loops
count = 0
while count < 5:
    print(count)
    count += 1

# break and continue
for i in range(10):
    if i == 5:
        break
    if i % 2 == 0:
        continue
    print(i)
```

## 🎨 Funciones

### Funciones Básicas

```python
def greet(name: str) -> str:
    """Greet a person by name."""
    return f"Hello, {name}!"

# Default arguments
def power(base: int, exponent: int = 2) -> int:
    return base ** exponent

# *args y **kwargs
def sum_all(*args: int) -> int:
    return sum(args)

def build_user(**kwargs: any) -> dict:
    return {
        "name": kwargs.get("name", "Unknown"),
        "age": kwargs.get("age", 0),
        **kwargs
    }

# Llamadas
result = sum_all(1, 2, 3, 4, 5)  # 15
user = build_user(name="John", age=30, email="john@example.com")
```

### Lambda Functions

```python
# Lambda simple
square = lambda x: x**2

# Con map, filter, reduce
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x**2, numbers))
evens = list(filter(lambda x: x % 2 == 0, numbers))

from functools import reduce
total = reduce(lambda x, y: x + y, numbers)  # 15
```

### Decorators

```python
from functools import wraps
import time

def timer(func):
    """Decorator to time function execution."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.2f}s")
        return result
    return wrapper

@timer
def slow_function():
    time.sleep(1)
    return "Done"

# Decorator con argumentos
def retry(times: int = 3):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for i in range(times):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if i == times - 1:
                        raise
                    print(f"Retry {i + 1}/{times}")
            return None
        return wrapper
    return decorator

@retry(times=3)
def unstable_function():
    # Might fail
    pass
```

## 🏗️ Clases y OOP

### Clases Básicas

```python
from dataclasses import dataclass
from datetime import datetime

class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
        self.created_at = datetime.now()
    
    def greet(self) -> str:
        return f"Hello, I'm {self.name}"
    
    def __str__(self) -> str:
        return f"User({self.name}, {self.email})"
    
    def __repr__(self) -> str:
        return f"User(name={self.name!r}, email={self.email!r})"

# Uso
user = User("John", "john@example.com")
print(user.greet())
```

### Dataclasses (Recomendado)

```python
@dataclass
class Product:
    name: str
    price: float
    stock: int = 0
    
    def total_value(self) -> float:
        return self.price * self.stock
    
    def is_available(self) -> bool:
        return self.stock > 0

# Uso
product = Product("Laptop", 999.99, 10)
print(product.total_value())  # 9999.90
```

### Herencia

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    def __init__(self, name: str):
        self.name = name
    
    @abstractmethod
    def make_sound(self) -> str:
        pass

class Dog(Animal):
    def make_sound(self) -> str:
        return "Woof!"

class Cat(Animal):
    def make_sound(self) -> str:
        return "Meow!"

# Uso
dog = Dog("Rex")
print(f"{dog.name} says {dog.make_sound()}")
```

### Properties

```python
class Circle:
    def __init__(self, radius: float):
        self._radius = radius
    
    @property
    def radius(self) -> float:
        return self._radius
    
    @radius.setter
    def radius(self, value: float) -> None:
        if value < 0:
            raise ValueError("Radius must be positive")
        self._radius = value
    
    @property
    def area(self) -> float:
        return 3.14159 * self._radius ** 2

# Uso
circle = Circle(5)
print(circle.area)  # 78.53975
circle.radius = 10
print(circle.area)  # 314.159
```

## 📂 Archivos y Context Managers

### Lectura/Escritura

```python
# Leer archivo
with open("data.txt", "r") as file:
    content = file.read()

# Leer línea por línea
with open("data.txt", "r") as file:
    for line in file:
        print(line.strip())

# Escribir archivo
with open("output.txt", "w") as file:
    file.write("Hello World\n")

# Append
with open("log.txt", "a") as file:
    file.write(f"{datetime.now()}: Event happened\n")

# JSON
import json

# Escribir JSON
data = {"name": "John", "age": 30}
with open("data.json", "w") as file:
    json.dump(data, file, indent=2)

# Leer JSON
with open("data.json", "r") as file:
    data = json.load(file)

# CSV
import csv

# Escribir CSV
with open("users.csv", "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["Name", "Age"])
    writer.writerow(["John", 30])
    writer.writerow(["Jane", 25])

# Leer CSV
with open("users.csv", "r") as file:
    reader = csv.DictReader(file)
    for row in reader:
        print(f"{row['Name']}: {row['Age']}")
```

### Custom Context Managers

```python
from contextlib import contextmanager

@contextmanager
def timer_context(name: str):
    start = time.time()
    print(f"Starting {name}")
    try:
        yield
    finally:
        end = time.time()
        print(f"{name} took {end - start:.2f}s")

# Uso
with timer_context("Data processing"):
    # Do work
    time.sleep(1)
```

## ⚡ Async/Await

```python
import asyncio
from typing import List

async def fetch_data(id: int) -> dict:
    """Simulate API call."""
    await asyncio.sleep(1)
    return {"id": id, "data": f"Data for {id}"}

async def fetch_all(ids: List[int]) -> List[dict]:
    """Fetch multiple items concurrently."""
    tasks = [fetch_data(id) for id in ids]
    return await asyncio.gather(*tasks)

# Run async code
async def main():
    results = await fetch_all([1, 2, 3, 4, 5])
    print(results)

# Python 3.7+
asyncio.run(main())

# Async context managers
class AsyncDatabase:
    async def __aenter__(self):
        print("Connecting to database")
        await asyncio.sleep(0.1)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print("Closing database connection")
        await asyncio.sleep(0.1)
    
    async def query(self, sql: str):
        await asyncio.sleep(0.1)
        return [{"id": 1, "name": "John"}]

async def use_db():
    async with AsyncDatabase() as db:
        results = await db.query("SELECT * FROM users")
        print(results)
```

## 🧪 Testing con pytest

```python
# test_calculator.py
def add(a: int, b: int) -> int:
    return a + b

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

# Parametrized tests
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-1, 1, 0),
    (0, 0, 0),
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected

# Fixtures
@pytest.fixture
def sample_user():
    return {"name": "John", "age": 30}

def test_user_name(sample_user):
    assert sample_user["name"] == "John"

# Exception testing
def divide(a: int, b: int) -> float:
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def test_divide_by_zero():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)

# Mocking
from unittest.mock import Mock, patch

def test_with_mock():
    mock_api = Mock()
    mock_api.get_data.return_value = {"status": "ok"}
    
    result = mock_api.get_data()
    assert result["status"] == "ok"
    mock_api.get_data.assert_called_once()
```

## 🛠️ Manejo de Errores

```python
# Try/except básico
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
except Exception as e:
    print(f"Error: {e}")
else:
    print("No errors")
finally:
    print("Always executed")

# Custom exceptions
class ValidationError(Exception):
    """Custom validation error."""
    pass

def validate_age(age: int) -> None:
    if age < 0:
        raise ValidationError("Age cannot be negative")
    if age > 150:
        raise ValidationError("Age is unrealistic")

try:
    validate_age(-5)
except ValidationError as e:
    print(f"Validation failed: {e}")

# Context manager for error handling
from contextlib import suppress

# Ignore specific errors
with suppress(FileNotFoundError):
    with open("nonexistent.txt") as f:
        content = f.read()
```

## 📊 Patrones Comunes

### Singleton

```python
class Database:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

db1 = Database()
db2 = Database()
assert db1 is db2  # Same instance
```

### Factory

```python
from abc import ABC, abstractmethod

class Animal(ABC):
    @abstractmethod
    def speak(self) -> str:
        pass

class Dog(Animal):
    def speak(self) -> str:
        return "Woof!"

class Cat(Animal):
    def speak(self) -> str:
        return "Meow!"

class AnimalFactory:
    @staticmethod
    def create(animal_type: str) -> Animal:
        if animal_type == "dog":
            return Dog()
        elif animal_type == "cat":
            return Cat()
        raise ValueError(f"Unknown animal type: {animal_type}")

# Uso
animal = AnimalFactory.create("dog")
print(animal.speak())  # "Woof!"
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| IndentationError | Indentación inconsistente | Usar 4 espacios, no tabs |
| NameError | Variable no definida | Verificar nombre y scope |
| TypeError | Tipo incorrecto | Usar type hints, verificar tipos |
| AttributeError | Atributo no existe | Verificar objeto y atributos |
| ImportError | Módulo no encontrado | Instalar paquete con pip |

## 📋 Checklist de Validación

- [ ] Type hints en funciones y variables
- [ ] Docstrings en funciones/clases
- [ ] Virtual environment creado
- [ ] requirements.txt actualizado
- [ ] Tests con pytest
- [ ] Código formateado (black/ruff)
- [ ] Sin errores de mypy
- [ ] .gitignore configurado
- [ ] Error handling apropiado
- [ ] Logging implementado

## 🎓 Best Practices

1. **Type Hints** - Siempre usar en funciones públicas
2. **Dataclasses** - Para clases de datos simples
3. **f-strings** - Para formateo de strings
4. **Context Managers** - Para recursos (archivos, conexiones)
5. **List Comprehensions** - Para transformaciones simples
6. **pytest** - Para testing
7. **Virtual Environments** - Siempre
8. **PEP 8** - Seguir guía de estilo
9. **Docstrings** - Documentar funciones públicas
10. **Logging** - Usar logging, no print

---

**Última actualización:** Fase 5 - Skills Python Stack  
**Mantenedor:** Sistema de Skills  
**Siguiente:** FastAPI para APIs modernas
