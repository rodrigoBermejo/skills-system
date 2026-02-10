# Flask - Classic Python Web Framework

**Scope:** backend  
**Trigger:** cuando se trabaje con Flask, web apps Python clásicas, o se mencione desarrollo web tradicional con Python  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para crear aplicaciones web con Flask. Cubre desde apps simples hasta APIs REST, incluyendo blueprints, SQLAlchemy, Jinja2 templates, authentication con Flask-Login, y deployment.

## 🔧 Cuándo Usar Esta Skill

- Web apps tradicionales con templates
- APIs REST simples
- Microservicios ligeros
- Prototipos rápidos
- Apps que necesitan flexibilidad total
- Migrar de FastAPI cuando no necesitas async

## 📚 Contexto y Conocimiento

### Flask vs FastAPI

| Feature | Flask | FastAPI |
|---------|-------|---------|
| **Speed** | Bueno | Excelente |
| **Async** | Limitado | Nativo |
| **Docs** | Manual | Auto-generadas |
| **Learning Curve** | Fácil | Media |
| **Templates** | Jinja2 integrado | No incluido |
| **Flexibilidad** | Máxima | Alta |
| **Best for** | Web apps, prototipos | APIs modernas |

### Setup

```bash
pip install Flask
pip install Flask-SQLAlchemy
pip install Flask-Migrate
pip install Flask-Login
pip install python-dotenv

# Ejecutar
flask run
# o
python app.py
```

### Estructura de Proyecto

```
my_app/
├── app/
│   ├── __init__.py         # App factory
│   ├── models.py           # Database models
│   ├── forms.py            # WTForms
│   ├── routes/             # Blueprints
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── auth.py
│   │   └── api.py
│   ├── templates/          # Jinja2 templates
│   │   ├── base.html
│   │   └── index.html
│   └── static/             # CSS, JS, images
│       ├── css/
│       └── js/
├── migrations/             # Alembic migrations
├── tests/
├── .env
├── config.py
├── requirements.txt
└── run.py
```

## 🚀 Hello World

### Minimal App

```python
# app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello, World!'

@app.route('/user/<username>')
def show_user(username):
    return f'User: {username}'

if __name__ == '__main__':
    app.run(debug=True)
```

## 🏭 Application Factory

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from config import Config

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'
    
    # Register blueprints
    from app.routes.main import bp as main_bp
    from app.routes.auth import bp as auth_bp
    from app.routes.api import bp as api_bp
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api')
    
    return app

# config.py
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///app.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

# run.py
from app import create_app, db
from app.models import User

app = create_app()

@app.shell_context_processor
def make_shell_context():
    return {'db': db, 'User': User}

if __name__ == '__main__':
    app.run(debug=True)
```

## 🗄️ Database con SQLAlchemy

### Models

```python
# app/models.py
from app import db, login_manager
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(128))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    posts = db.relationship('Post', backref='author', lazy='dynamic')
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def __repr__(self):
        return f'<User {self.username}>'

class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    body = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    
    def __repr__(self):
        return f'<Post {self.title}>'

@login_manager.user_loader
def load_user(id):
    return User.query.get(int(id))
```

### Migrations

```bash
# Initialize migrations
flask db init

# Create migration
flask db migrate -m "Initial migration"

# Apply migration
flask db upgrade

# Downgrade
flask db downgrade
```

## 🛣️ Routes y Blueprints

### Main Routes

```python
# app/routes/main.py
from flask import Blueprint, render_template, request
from app.models import Post
from app import db

bp = Blueprint('main', __name__)

@bp.route('/')
@bp.route('/index')
def index():
    page = request.args.get('page', 1, type=int)
    posts = Post.query.order_by(Post.timestamp.desc()).paginate(
        page=page, per_page=10, error_out=False
    )
    return render_template('index.html', posts=posts)

@bp.route('/about')
def about():
    return render_template('about.html')
```

### Auth Routes

```python
# app/routes/auth.py
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_user, logout_user, current_user, login_required
from app import db
from app.models import User
from werkzeug.urls import url_parse

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = User.query.filter_by(email=email).first()
        if user:
            flash('Email already registered')
            return redirect(url_for('auth.register'))
        
        user = User(username=username, email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful!')
        return redirect(url_for('auth.login'))
    
    return render_template('auth/register.html')

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        remember = request.form.get('remember', False)
        
        user = User.query.filter_by(email=email).first()
        if user is None or not user.check_password(password):
            flash('Invalid email or password')
            return redirect(url_for('auth.login'))
        
        login_user(user, remember=remember)
        next_page = request.args.get('next')
        if not next_page or url_parse(next_page).netloc != '':
            next_page = url_for('main.index')
        return redirect(next_page)
    
    return render_template('auth/login.html')

@bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.index'))

@bp.route('/profile')
@login_required
def profile():
    return render_template('auth/profile.html')
```

## 📡 REST API

### API Routes

```python
# app/routes/api.py
from flask import Blueprint, jsonify, request
from flask_login import login_required, current_user
from app import db
from app.models import Post, User

bp = Blueprint('api', __name__)

@bp.route('/posts', methods=['GET'])
def get_posts():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    posts = Post.query.order_by(Post.timestamp.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'posts': [
            {
                'id': post.id,
                'title': post.title,
                'body': post.body,
                'author': post.author.username,
                'timestamp': post.timestamp.isoformat()
            }
            for post in posts.items
        ],
        'total': posts.total,
        'pages': posts.pages,
        'current_page': page
    })

@bp.route('/posts/<int:id>', methods=['GET'])
def get_post(id):
    post = Post.query.get_or_404(id)
    return jsonify({
        'id': post.id,
        'title': post.title,
        'body': post.body,
        'author': post.author.username,
        'timestamp': post.timestamp.isoformat()
    })

@bp.route('/posts', methods=['POST'])
@login_required
def create_post():
    data = request.get_json()
    
    if not data or 'title' not in data or 'body' not in data:
        return jsonify({'error': 'Missing required fields'}), 400
    
    post = Post(
        title=data['title'],
        body=data['body'],
        author=current_user
    )
    db.session.add(post)
    db.session.commit()
    
    return jsonify({
        'id': post.id,
        'title': post.title,
        'body': post.body,
        'author': post.author.username,
        'timestamp': post.timestamp.isoformat()
    }), 201

@bp.route('/posts/<int:id>', methods=['PUT'])
@login_required
def update_post(id):
    post = Post.query.get_or_404(id)
    
    if post.user_id != current_user.id:
        return jsonify({'error': 'Forbidden'}), 403
    
    data = request.get_json()
    post.title = data.get('title', post.title)
    post.body = data.get('body', post.body)
    db.session.commit()
    
    return jsonify({
        'id': post.id,
        'title': post.title,
        'body': post.body
    })

@bp.route('/posts/<int:id>', methods=['DELETE'])
@login_required
def delete_post(id):
    post = Post.query.get_or_404(id)
    
    if post.user_id != current_user.id:
        return jsonify({'error': 'Forbidden'}), 403
    
    db.session.delete(post)
    db.session.commit()
    
    return '', 204
```

## 🎨 Templates (Jinja2)

### Base Template

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}My App{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <nav>
        <a href="{{ url_for('main.index') }}">Home</a>
        {% if current_user.is_authenticated %}
            <a href="{{ url_for('auth.profile') }}">Profile</a>
            <a href="{{ url_for('auth.logout') }}">Logout</a>
        {% else %}
            <a href="{{ url_for('auth.login') }}">Login</a>
            <a href="{{ url_for('auth.register') }}">Register</a>
        {% endif %}
    </nav>
    
    {% with messages = get_flashed_messages() %}
        {% if messages %}
            <div class="messages">
                {% for message in messages %}
                    <div class="message">{{ message }}</div>
                {% endfor %}
            </div>
        {% endif %}
    {% endwith %}
    
    <main>
        {% block content %}{% endblock %}
    </main>
    
    <script src="{{ url_for('static', filename='js/main.js') }}"></script>
</body>
</html>
```

### Index Template

```html
<!-- templates/index.html -->
{% extends "base.html" %}

{% block title %}Home{% endblock %}

{% block content %}
<h1>Recent Posts</h1>

{% for post in posts.items %}
<article>
    <h2>{{ post.title }}</h2>
    <p>By {{ post.author.username }} on {{ post.timestamp.strftime('%Y-%m-%d') }}</p>
    <p>{{ post.body[:200] }}...</p>
    <a href="{{ url_for('main.post', id=post.id) }}">Read more</a>
</article>
{% endfor %}

<!-- Pagination -->
{% if posts.has_prev %}
    <a href="{{ url_for('main.index', page=posts.prev_num) }}">Previous</a>
{% endif %}
{% if posts.has_next %}
    <a href="{{ url_for('main.index', page=posts.next_num) }}">Next</a>
{% endif %}
{% endblock %}
```

## 🛡️ Error Handling

```python
# app/__init__.py (en create_app)

from flask import render_template

@app.errorhandler(404)
def not_found_error(error):
    return render_template('errors/404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('errors/500.html'), 500

# Para APIs
from flask import jsonify

@app.errorhandler(404)
def api_not_found(error):
    if request.path.startswith('/api/'):
        return jsonify({'error': 'Not found'}), 404
    return render_template('errors/404.html'), 404
```

## 🧪 Testing

```python
# tests/test_app.py
import unittest
from app import create_app, db
from app.models import User
from config import Config

class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite://'

class UserModelCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app(TestConfig)
        self.app_context = self.app.app_context()
        self.app_context.push()
        db.create_all()
    
    def tearDown(self):
        db.session.remove()
        db.drop_all()
        self.app_context.pop()
    
    def test_password_hashing(self):
        u = User(username='john')
        u.set_password('password')
        self.assertFalse(u.check_password('wrong'))
        self.assertTrue(u.check_password('password'))
    
    def test_user_creation(self):
        u = User(username='john', email='john@example.com')
        db.session.add(u)
        db.session.commit()
        
        self.assertEqual(User.query.count(), 1)
        self.assertEqual(User.query.first().username, 'john')

class RoutesCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app(TestConfig)
        self.client = self.app.test_client()
        self.app_context = self.app.app_context()
        self.app_context.push()
        db.create_all()
    
    def tearDown(self):
        db.session.remove()
        db.drop_all()
        self.app_context.pop()
    
    def test_index(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
    
    def test_api_posts(self):
        response = self.client.get('/api/posts')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('posts', data)

if __name__ == '__main__':
    unittest.main()
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| AssertionError: View function mapping is overwriting an existing endpoint | Endpoint duplicado | Usar unique endpoint names |
| RuntimeError: Working outside of application context | No app context | Usar app.app_context() |
| OperationalError: no such table | Migrations no aplicadas | flask db upgrade |
| 405 Method Not Allowed | HTTP method incorrecto | Agregar methods en @app.route |

## 📋 Checklist Production

- [ ] SECRET_KEY en env variable
- [ ] DEBUG = False
- [ ] Database production (PostgreSQL)
- [ ] CORS configurado si es API
- [ ] Error handling implementado
- [ ] Logging configurado
- [ ] Tests con >70% coverage
- [ ] Static files servidos correctamente
- [ ] Rate limiting (Flask-Limiter)
- [ ] HTTPS enabled

## 🎓 Best Practices

1. **Application Factory** - Usar create_app()
2. **Blueprints** - Organizar rutas
3. **Flask-Login** - Para authentication
4. **Flask-Migrate** - Para database migrations
5. **Environment Variables** - Para configuration
6. **WTForms** - Para validación de forms
7. **Flask-CORS** - Para APIs con CORS
8. **Error Handling** - Custom error pages
9. **Testing** - Unit + integration tests
10. **Logging** - Configurar logging

---

**Última actualización:** Fase 5 - Skills Python Stack  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Data Processing para análisis de datos
