# Angular - Enterprise Frontend Framework

**Scope:** frontend  
**Trigger:** cuando se trabaje con Angular, se creen componentes Angular, servicios, o se mencione desarrollo enterprise con Angular  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## 🎯 Propósito

Esta skill te guía para crear aplicaciones Angular modernas (v17+) siguiendo las mejores prácticas de arquitectura enterprise. Cubre desde setup hasta patrones avanzados con standalone components, signals, RxJS, y arquitectura escalable.

## 🔧 Cuándo Usar Esta Skill

- Crear proyectos Angular enterprise desde cero
- Desarrollar componentes con standalone components
- Implementar servicios e inyección de dependencias
- Configurar routing con lazy loading
- Manejar estado con signals y services
- Trabajar con RxJS y observables
- Implementar forms reactivos
- Integrar con APIs backend
- Arquitectura modular escalable

## 📚 Contexto y Conocimiento

### Versión Actual
Angular 17+ (con standalone components por defecto)

### Setup de Proyecto

```bash
# Instalar Angular CLI
npm install -g @angular/cli@latest

# Crear nuevo proyecto
ng new my-app

# Opciones recomendadas:
# - Routing: Yes
# - Stylesheet: SCSS
# - SSR: No (a menos que necesites SEO)
# - Standalone: Yes (por defecto en v17+)

cd my-app
ng serve
```

### Estructura de Proyecto Angular

```
src/
├── app/
│   ├── core/                # Servicios singleton y guards
│   │   ├── services/
│   │   ├── guards/
│   │   ├── interceptors/
│   │   └── models/
│   ├── shared/              # Componentes/pipes/directives compartidos
│   │   ├── components/
│   │   ├── directives/
│   │   └── pipes/
│   ├── features/            # Módulos de features
│   │   ├── auth/
│   │   ├── dashboard/
│   │   └── products/
│   ├── app.component.ts     # Root component
│   ├── app.config.ts        # App configuration
│   └── app.routes.ts        # Routes definition
├── assets/                  # Imágenes, fonts, etc
├── environments/            # Environment configs
└── styles.scss             # Global styles
```

## 🚀 Flujo de Trabajo

### 1. Crear Componente Standalone

```bash
ng generate component components/user-profile --standalone
```

**user-profile.component.ts:**
```typescript
import { Component, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="profile-card">
      <img [src]="user.avatar" [alt]="user.name">
      <h2>{{ user.name }}</h2>
      <p>{{ user.email }}</p>
      <button (click)="onEdit()">Edit Profile</button>
    </div>
  `,
  styles: [`
    .profile-card {
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 8px;
    }
  `]
})
export class UserProfileComponent implements OnInit {
  @Input() user!: User;

  ngOnInit() {
    console.log('Component initialized', this.user);
  }

  onEdit() {
    console.log('Edit clicked');
  }
}

interface User {
  name: string;
  email: string;
  avatar: string;
}
```

### 2. Signals para State Management

**Angular 16+ introduce signals como alternativa a RxJS para estado reactivo:**

```typescript
import { Component, signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div>
      <h2>Count: {{ count() }}</h2>
      <h3>Double: {{ doubleCount() }}</h3>
      <button (click)="increment()">+</button>
      <button (click)="decrement()">-</button>
      <button (click)="reset()">Reset</button>
    </div>
  `
})
export class CounterComponent {
  // Signal - estado reactivo
  count = signal(0);
  
  // Computed - valor derivado
  doubleCount = computed(() => this.count() * 2);
  
  // Effect - side effect cuando cambia el signal
  constructor() {
    effect(() => {
      console.log('Count changed to:', this.count());
      // Guardar en localStorage
      localStorage.setItem('count', this.count().toString());
    });
  }
  
  increment() {
    this.count.update(value => value + 1);
  }
  
  decrement() {
    this.count.update(value => value - 1);
  }
  
  reset() {
    this.count.set(0);
  }
}
```

### 3. Servicios e Inyección de Dependencias

**Crear servicio:**
```bash
ng generate service services/user
```

**user.service.ts:**
```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, tap, catchError, of } from 'rxjs';
import { environment } from '../../environments/environment';

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'user' | 'admin';
}

@Injectable({
  providedIn: 'root' // Singleton en toda la app
})
export class UserService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/users`;
  
  // Estado privado con BehaviorSubject
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  
  // Observable público
  currentUser$ = this.currentUserSubject.asObservable();
  
  // Getter del valor actual
  get currentUserValue(): User | null {
    return this.currentUserSubject.value;
  }
  
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }
  
  getUserById(id: string): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }
  
  createUser(user: Partial<User>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }
  
  updateUser(id: string, user: Partial<User>): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, user);
  }
  
  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
  
  login(email: string, password: string): Observable<User> {
    return this.http.post<User>(`${this.apiUrl}/login`, { email, password })
      .pipe(
        tap(user => {
          this.currentUserSubject.next(user);
          localStorage.setItem('currentUser', JSON.stringify(user));
        }),
        catchError(error => {
          console.error('Login failed:', error);
          return of(error);
        })
      );
  }
  
  logout(): void {
    this.currentUserSubject.next(null);
    localStorage.removeItem('currentUser');
  }
}
```

**Usar servicio en componente:**
```typescript
import { Component, OnInit, inject } from '@angular/core';
import { UserService, User } from './services/user.service';

@Component({
  selector: 'app-users',
  standalone: true,
  template: `
    <div *ngIf="users$ | async as users">
      <div *ngFor="let user of users">
        {{ user.name }} - {{ user.email }}
      </div>
    </div>
  `
})
export class UsersComponent implements OnInit {
  private userService = inject(UserService);
  users$ = this.userService.getUsers();
  
  ngOnInit() {
    // El subscribe se maneja automáticamente con async pipe
  }
}
```

### 4. Routing con Lazy Loading

**app.routes.ts:**
```typescript
import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/home',
    pathMatch: 'full'
  },
  {
    path: 'home',
    loadComponent: () => import('./features/home/home.component')
      .then(m => m.HomeComponent)
  },
  {
    path: 'auth',
    loadChildren: () => import('./features/auth/auth.routes')
      .then(m => m.AUTH_ROUTES)
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.component')
      .then(m => m.DashboardComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'products',
    loadChildren: () => import('./features/products/products.routes')
      .then(m => m.PRODUCT_ROUTES),
    canActivate: [AuthGuard]
  },
  {
    path: '**',
    loadComponent: () => import('./shared/components/not-found/not-found.component')
      .then(m => m.NotFoundComponent)
  }
];
```

**Auth Guard:**
```typescript
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { UserService } from '../services/user.service';
import { map } from 'rxjs';

export const AuthGuard: CanActivateFn = (route, state) => {
  const userService = inject(UserService);
  const router = inject(Router);
  
  return userService.currentUser$.pipe(
    map(user => {
      if (user) {
        return true;
      }
      
      // Redirect to login
      router.navigate(['/auth/login'], { 
        queryParams: { returnUrl: state.url }
      });
      return false;
    })
  );
};
```

### 5. Reactive Forms

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
      <div>
        <label for="name">Name:</label>
        <input 
          id="name" 
          formControlName="name"
          [class.error]="name?.invalid && name?.touched"
        >
        <div *ngIf="name?.invalid && name?.touched" class="error-message">
          <span *ngIf="name?.errors?.['required']">Name is required</span>
          <span *ngIf="name?.errors?.['minlength']">
            Name must be at least 3 characters
          </span>
        </div>
      </div>

      <div>
        <label for="email">Email:</label>
        <input 
          id="email" 
          type="email" 
          formControlName="email"
          [class.error]="email?.invalid && email?.touched"
        >
        <div *ngIf="email?.invalid && email?.touched" class="error-message">
          <span *ngIf="email?.errors?.['required']">Email is required</span>
          <span *ngIf="email?.errors?.['email']">Invalid email format</span>
        </div>
      </div>

      <div formGroupName="address">
        <label for="street">Street:</label>
        <input id="street" formControlName="street">
        
        <label for="city">City:</label>
        <input id="city" formControlName="city">
      </div>

      <button 
        type="submit" 
        [disabled]="userForm.invalid || userForm.pristine"
      >
        Submit
      </button>
    </form>

    <pre>{{ userForm.value | json }}</pre>
  `
})
export class UserFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  
  userForm!: FormGroup;
  
  ngOnInit() {
    this.userForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      address: this.fb.group({
        street: [''],
        city: ['', Validators.required]
      })
    });
    
    // Subscribe to value changes
    this.userForm.valueChanges.subscribe(value => {
      console.log('Form changed:', value);
    });
  }
  
  // Getters para template
  get name() {
    return this.userForm.get('name');
  }
  
  get email() {
    return this.userForm.get('email');
  }
  
  onSubmit() {
    if (this.userForm.valid) {
      console.log('Form submitted:', this.userForm.value);
      // Enviar al backend
    }
  }
}
```

### 6. HTTP Interceptor

**auth.interceptor.ts:**
```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  
  // Agregar token a todas las requests
  const token = localStorage.getItem('token');
  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  // Handle errors
  return next(req).pipe(
    catchError(error => {
      if (error.status === 401) {
        localStorage.removeItem('token');
        router.navigate(['/auth/login']);
      }
      return throwError(() => error);
    })
  );
};

// Registrar en app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor])
    )
  ]
};
```

## 🎨 Patrones Comunes

### 1. Smart vs Presentational Components

**Smart Component (Container):**
```typescript
// Maneja lógica y estado
@Component({
  selector: 'app-user-list-container',
  standalone: true,
  imports: [UserListComponent],
  template: `
    <app-user-list
      [users]="users$ | async"
      [loading]="loading"
      (userSelected)="onUserSelected($event)"
      (userDeleted)="onUserDeleted($event)"
    />
  `
})
export class UserListContainerComponent {
  private userService = inject(UserService);
  
  users$ = this.userService.getUsers();
  loading = false;
  
  onUserSelected(user: User) {
    // Navigate or show details
  }
  
  onUserDeleted(userId: string) {
    this.userService.deleteUser(userId).subscribe();
  }
}
```

**Presentational Component (Dumb):**
```typescript
// Solo presenta datos
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngIf="loading">Loading...</div>
    <div *ngFor="let user of users">
      <h3 (click)="userSelected.emit(user)">{{ user.name }}</h3>
      <button (click)="userDeleted.emit(user.id)">Delete</button>
    </div>
  `
})
export class UserListComponent {
  @Input() users: User[] = [];
  @Input() loading = false;
  @Output() userSelected = new EventEmitter<User>();
  @Output() userDeleted = new EventEmitter<string>();
}
```

### 2. RxJS Operators

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { 
  map, 
  filter, 
  debounceTime, 
  distinctUntilChanged,
  switchMap,
  catchError,
  tap
} from 'rxjs/operators';
import { FormControl } from '@angular/forms';
import { of } from 'rxjs';

@Component({
  selector: 'app-search',
  template: `
    <input [formControl]="searchControl" placeholder="Search users...">
    <div *ngFor="let user of users$ | async">
      {{ user.name }}
    </div>
  `
})
export class SearchComponent implements OnInit {
  private userService = inject(UserService);
  
  searchControl = new FormControl('');
  users$!: Observable<User[]>;
  
  ngOnInit() {
    this.users$ = this.searchControl.valueChanges.pipe(
      debounceTime(300),              // Wait 300ms after last keystroke
      distinctUntilChanged(),          // Only if value changed
      filter(term => term.length >= 3), // Only search if 3+ chars
      tap(() => console.log('Searching...')),
      switchMap(term =>                // Cancel previous request
        this.userService.searchUsers(term).pipe(
          catchError(error => {
            console.error(error);
            return of([]);             // Return empty array on error
          })
        )
      ),
      map(users => users.slice(0, 10)) // Limit to 10 results
    );
  }
}
```

### 3. Custom Pipes

```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'timeAgo',
  standalone: true
})
export class TimeAgoPipe implements PipeTransform {
  transform(value: Date | string): string {
    const date = new Date(value);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);
    
    if (seconds < 60) return 'just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)} minutes ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)} hours ago`;
    return `${Math.floor(seconds / 86400)} days ago`;
  }
}

// Uso en template
// {{ post.createdAt | timeAgo }}
```

### 4. Custom Directives

```typescript
import { Directive, ElementRef, HostListener, Input } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true
})
export class HighlightDirective {
  @Input() appHighlight = 'yellow';
  @Input() defaultColor = 'transparent';
  
  constructor(private el: ElementRef) {}
  
  @HostListener('mouseenter') onMouseEnter() {
    this.highlight(this.appHighlight);
  }
  
  @HostListener('mouseleave') onMouseLeave() {
    this.highlight(this.defaultColor);
  }
  
  private highlight(color: string) {
    this.el.nativeElement.style.backgroundColor = color;
  }
}

// Uso en template
// <p appHighlight="lightblue">Hover over me!</p>
```

## ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Memory leak con subscriptions | No unsubscribe | Usar async pipe o takeUntil |
| ExpressionChangedAfterItHasBeenCheckedError | Cambiar estado en ngAfterViewInit | Usar ChangeDetectorRef o setTimeout |
| Can't resolve module | Import incorrecto | Verificar imports en standalone components |
| Circular dependency | Imports circulares | Reorganizar estructura o usar interfaces |
| Route not loading | Lazy load mal configurado | Verificar import dinámico |

### Solución a Memory Leaks

```typescript
import { Component, OnDestroy } from '@angular/core';
import { Subject, takeUntil } from 'rxjs';

@Component({/*...*/})
export class MyComponent implements OnDestroy {
  private destroy$ = new Subject<void>();
  
  ngOnInit() {
    // ✅ BIEN - Se limpia automáticamente
    this.userService.getUsers()
      .pipe(takeUntil(this.destroy$))
      .subscribe(users => {
        // Handle users
      });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}

// O mejor aún, usar async pipe:
// users$ = this.userService.getUsers();
// <div *ngFor="let user of users$ | async">
```

## 📋 Checklist de Validación

Antes de finalizar un componente Angular:
- [ ] Standalone component con imports necesarios
- [ ] OnDestroy implementado si hay subscriptions
- [ ] Async pipe usado en lugar de subscribe manual
- [ ] Tipos TypeScript definidos (interfaces)
- [ ] Validaciones en forms reactivos
- [ ] Error handling en HTTP calls
- [ ] Loading states implementados
- [ ] Guards para rutas protegidas
- [ ] Lazy loading para módulos grandes
- [ ] Change detection strategy optimizada (OnPush)

## 🎓 Best Practices

1. **Usar standalone components** - Nueva arquitectura por defecto
2. **Signals para estado local** - Más simple que RxJS
3. **Async pipe everywhere** - Evita memory leaks
4. **OnPush change detection** - Mejor performance
5. **Lazy loading** - Carga bajo demanda
6. **Typed forms** - Type safety en forms
7. **Smart/Dumb pattern** - Separar lógica de presentación
8. **Single responsibility** - Un propósito por servicio/componente
9. **trackBy en ngFor** - Optimizar listas
10. **providedIn: 'root'** - Servicios singleton

---

**Última actualización:** Fase 3 - Skills Frontend Avanzado  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Integrar con State Management para apps complejas
