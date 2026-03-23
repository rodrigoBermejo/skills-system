# State Management - Redux, Zustand, NgRx

**Scope:** frontend  
**Trigger:** cuando se necesite manejar estado global, se mencione Redux, Zustand, NgRx, o state management en aplicaciones complejas  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## Proposito

Esta skill te guía para implementar state management efectivo en aplicaciones frontend. Cubre Redux Toolkit (React), Zustand (React), NgRx (Angular), y cuándo usar cada solución según la complejidad de tu aplicación.

## Cuando Usar Esta Skill

- Estado compartido entre múltiples componentes
- Estado que necesita persistirse
- Lógica de negocio compleja
- Side effects (API calls, timers)
- Debugging de flujo de datos
- Aplicaciones enterprise con estado complejo
- Necesidad de time-travel debugging

## Contexto y Conocimiento

### Cuándo NO Necesitas State Management

```
❌ NO uses state management para:
- Estado local de un componente
- Formularios simples
- UI state temporal (modales, tooltips)
- Props drilling de 1-2 niveles

✅ Context API o props son suficientes
```

### Cuándo SÍ Necesitas State Management

```
✅ USA state management para:
- Estado compartido por 5+ componentes
- Estado que necesita persistencia
- Lógica de negocio compleja
- Cache de API calls
- Optimistic updates
- Undo/redo functionality
```

### Comparativa de Soluciones

| Feature | Context API | Zustand | Redux Toolkit | NgRx |
|---------|-------------|---------|---------------|------|
| Complejidad | Baja | Baja | Media | Alta |
| Boilerplate | Mínimo | Mínimo | Medio | Alto |
| DevTools | No | Sí | Sí | Sí |
| TypeScript | Bueno | Excelente | Excelente | Excelente |
| Learning Curve | Fácil | Fácil | Media | Alta |
| Middleware | No | Sí | Sí | Sí |
| Best for | Apps pequeñas | Apps pequeñas-medianas | Apps medianas-grandes | Apps enterprise Angular |

## Zustand (React - Recomendado para Apps Nuevas)

### Por Qué Zustand

- ✅ API súper simple
- ✅ Mínimo boilerplate
- ✅ Excelente con TypeScript
- ✅ Hooks nativos
- ✅ No necesita Provider
- ✅ Middleware incluidos

### Setup

```bash
npm install zustand
```

### Store Básico

```typescript
// stores/userStore.ts
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  user: User | null;
  users: User[];
  loading: boolean;
  error: string | null;
  
  // Actions
  setUser: (user: User) => void;
  setUsers: (users: User[]) => void;
  fetchUsers: () => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useUserStore = create<UserState>((set, get) => ({
  user: null,
  users: [],
  loading: false,
  error: null,
  
  setUser: (user) => set({ user }),
  
  setUsers: (users) => set({ users }),
  
  fetchUsers: async () => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/users');
      const users = await response.json();
      set({ users, loading: false });
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
    }
  },
  
  login: async (email, password) => {
    set({ loading: true, error: null });
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      
      if (!response.ok) throw new Error('Login failed');
      
      const user = await response.json();
      set({ user, loading: false });
      localStorage.setItem('user', JSON.stringify(user));
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
    }
  },
  
  logout: () => {
    set({ user: null });
    localStorage.removeItem('user');
  },
}));
```

### Usar Store en Componentes

```typescript
import { useUserStore } from './stores/userStore';

// Componente que usa el store
function UserProfile() {
  // Seleccionar solo lo que necesitas (evita re-renders)
  const user = useUserStore(state => state.user);
  const logout = useUserStore(state => state.logout);
  
  if (!user) return <div>Please login</div>;
  
  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={logout}>Logout</button>
    </div>
  );
}

function UserList() {
  const users = useUserStore(state => state.users);
  const loading = useUserStore(state => state.loading);
  const fetchUsers = useUserStore(state => state.fetchUsers);
  
  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
```

### Zustand con Middleware

```typescript
import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
}

export const useCounterStore = create<CounterState>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((state) => ({ count: state.count + 1 })),
        decrement: () => set((state) => ({ count: state.count - 1 })),
      }),
      {
        name: 'counter-storage', // localStorage key
      }
    )
  )
);
```

### Slices Pattern (Zustand)

```typescript
// stores/slices/userSlice.ts
export interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
  clearUser: () => void;
}

export const createUserSlice = (set: any): UserSlice => ({
  user: null,
  setUser: (user) => set({ user }),
  clearUser: () => set({ user: null }),
});

// stores/slices/cartSlice.ts
export interface CartSlice {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
}

export const createCartSlice = (set: any): CartSlice => ({
  items: [],
  addItem: (item) => set((state) => ({ 
    items: [...state.items, item] 
  })),
  removeItem: (id) => set((state) => ({ 
    items: state.items.filter(item => item.id !== id) 
  })),
});

// stores/index.ts
import { create } from 'zustand';
import { createUserSlice, UserSlice } from './slices/userSlice';
import { createCartSlice, CartSlice } from './slices/cartSlice';

type StoreState = UserSlice & CartSlice;

export const useStore = create<StoreState>()((...a) => ({
  ...createUserSlice(...a),
  ...createCartSlice(...a),
}));
```

## Redux Toolkit (React - Apps Enterprise)

### Por Qué Redux Toolkit

- ✅ Standard de la industria
- ✅ DevTools potentes
- ✅ Excelente para apps grandes
- ✅ Middleware ecosystem
- ✅ Time-travel debugging

### Setup

```bash
npm install @reduxjs/toolkit react-redux
```

### Store Setup

```typescript
// store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import userReducer from './slices/userSlice';
import productReducer from './slices/productSlice';

export const store = configureStore({
  reducer: {
    user: userReducer,
    products: productReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// App.tsx
import { Provider } from 'react-redux';
import { store } from './store';

function App() {
  return (
    <Provider store={store}>
      <YourApp />
    </Provider>
  );
}
```

### Slice con Redux Toolkit

```typescript
// store/slices/userSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  user: User | null;
  users: User[];
  loading: boolean;
  error: string | null;
}

const initialState: UserState = {
  user: null,
  users: [],
  loading: false,
  error: null,
};

// Async thunk para API calls
export const fetchUsers = createAsyncThunk(
  'user/fetchUsers',
  async () => {
    const response = await fetch('/api/users');
    return response.json();
  }
);

export const loginUser = createAsyncThunk(
  'user/login',
  async ({ email, password }: { email: string; password: string }) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    
    if (!response.ok) throw new Error('Login failed');
    return response.json();
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      state.user = action.payload;
    },
    logout: (state) => {
      state.user = null;
      localStorage.removeItem('user');
    },
  },
  extraReducers: (builder) => {
    // fetchUsers
    builder.addCase(fetchUsers.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(fetchUsers.fulfilled, (state, action) => {
      state.loading = false;
      state.users = action.payload;
    });
    builder.addCase(fetchUsers.rejected, (state, action) => {
      state.loading = false;
      state.error = action.error.message || 'Failed to fetch users';
    });
    
    // loginUser
    builder.addCase(loginUser.fulfilled, (state, action) => {
      state.user = action.payload;
      localStorage.setItem('user', JSON.stringify(action.payload));
    });
  },
});

export const { setUser, logout } = userSlice.actions;
export default userSlice.reducer;
```

### Hooks Tipados

```typescript
// store/hooks.ts
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import type { RootState, AppDispatch } from './index';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

### Usar Redux en Componentes

```typescript
import { useEffect } from 'react';
import { useAppDispatch, useAppSelector } from './store/hooks';
import { fetchUsers, logout } from './store/slices/userSlice';

function UserProfile() {
  const user = useAppSelector(state => state.user.user);
  const dispatch = useAppDispatch();
  
  const handleLogout = () => {
    dispatch(logout());
  };
  
  if (!user) return <div>Please login</div>;
  
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
}

function UserList() {
  const { users, loading, error } = useAppSelector(state => state.user);
  const dispatch = useAppDispatch();
  
  useEffect(() => {
    dispatch(fetchUsers());
  }, [dispatch]);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  
  return (
    <div>
      {users.map(user => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  );
}
```

## NgRx (Angular Enterprise)

### Por Qué NgRx

- ✅ Standard para Angular enterprise
- ✅ RxJS integration
- ✅ Immutability enforced
- ✅ Effects para side effects
- ✅ Router integration

### Setup

```bash
ng add @ngrx/store
ng add @ngrx/effects
ng add @ngrx/store-devtools
```

### State, Actions, Reducer

```typescript
// state/user/user.state.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export interface UserState {
  user: User | null;
  users: User[];
  loading: boolean;
  error: string | null;
}

export const initialState: UserState = {
  user: null,
  users: [],
  loading: false,
  error: null,
};

// state/user/user.actions.ts
import { createAction, props } from '@ngrx/store';

export const loadUsers = createAction('[User] Load Users');
export const loadUsersSuccess = createAction(
  '[User] Load Users Success',
  props<{ users: User[] }>()
);
export const loadUsersFailure = createAction(
  '[User] Load Users Failure',
  props<{ error: string }>()
);

export const login = createAction(
  '[User] Login',
  props<{ email: string; password: string }>()
);
export const loginSuccess = createAction(
  '[User] Login Success',
  props<{ user: User }>()
);
export const loginFailure = createAction(
  '[User] Login Failure',
  props<{ error: string }>()
);

export const logout = createAction('[User] Logout');

// state/user/user.reducer.ts
import { createReducer, on } from '@ngrx/store';
import * as UserActions from './user.actions';

export const userReducer = createReducer(
  initialState,
  
  on(UserActions.loadUsers, (state) => ({
    ...state,
    loading: true,
    error: null,
  })),
  
  on(UserActions.loadUsersSuccess, (state, { users }) => ({
    ...state,
    users,
    loading: false,
  })),
  
  on(UserActions.loadUsersFailure, (state, { error }) => ({
    ...state,
    error,
    loading: false,
  })),
  
  on(UserActions.loginSuccess, (state, { user }) => ({
    ...state,
    user,
    loading: false,
  })),
  
  on(UserActions.logout, (state) => ({
    ...state,
    user: null,
  }))
);
```

### Effects (Side Effects)

```typescript
// state/user/user.effects.ts
import { Injectable, inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, catchError, exhaustMap, tap } from 'rxjs/operators';
import * as UserActions from './user.actions';
import { UserService } from '../../services/user.service';
import { Router } from '@angular/router';

@Injectable()
export class UserEffects {
  private actions$ = inject(Actions);
  private userService = inject(UserService);
  private router = inject(Router);
  
  loadUsers$ = createEffect(() =>
    this.actions$.pipe(
      ofType(UserActions.loadUsers),
      exhaustMap(() =>
        this.userService.getUsers().pipe(
          map(users => UserActions.loadUsersSuccess({ users })),
          catchError(error => of(UserActions.loadUsersFailure({ 
            error: error.message 
          })))
        )
      )
    )
  );
  
  login$ = createEffect(() =>
    this.actions$.pipe(
      ofType(UserActions.login),
      exhaustMap(({ email, password }) =>
        this.userService.login(email, password).pipe(
          map(user => UserActions.loginSuccess({ user })),
          catchError(error => of(UserActions.loginFailure({ 
            error: error.message 
          })))
        )
      )
    )
  );
  
  loginSuccess$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(UserActions.loginSuccess),
        tap(({ user }) => {
          localStorage.setItem('user', JSON.stringify(user));
          this.router.navigate(['/dashboard']);
        })
      ),
    { dispatch: false }
  );
  
  logout$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(UserActions.logout),
        tap(() => {
          localStorage.removeItem('user');
          this.router.navigate(['/login']);
        })
      ),
    { dispatch: false }
  );
}
```

### Selectors

```typescript
// state/user/user.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { UserState } from './user.state';

export const selectUserState = createFeatureSelector<UserState>('user');

export const selectCurrentUser = createSelector(
  selectUserState,
  (state) => state.user
);

export const selectAllUsers = createSelector(
  selectUserState,
  (state) => state.users
);

export const selectUsersLoading = createSelector(
  selectUserState,
  (state) => state.loading
);

export const selectUsersError = createSelector(
  selectUserState,
  (state) => state.error
);

// Selector compuesto
export const selectUserById = (id: string) => createSelector(
  selectAllUsers,
  (users) => users.find(user => user.id === id)
);
```

### Usar Store en Componentes

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { Observable } from 'rxjs';
import * as UserActions from './state/user/user.actions';
import * as UserSelectors from './state/user/user.selectors';

@Component({
  selector: 'app-user-list',
  template: `
    <div *ngIf="loading$ | async">Loading...</div>
    <div *ngIf="error$ | async as error">{{ error }}</div>
    
    <div *ngFor="let user of users$ | async">
      {{ user.name }}
    </div>
  `
})
export class UserListComponent implements OnInit {
  private store = inject(Store);
  
  users$ = this.store.select(UserSelectors.selectAllUsers);
  loading$ = this.store.select(UserSelectors.selectUsersLoading);
  error$ = this.store.select(UserSelectors.selectUsersError);
  
  ngOnInit() {
    this.store.dispatch(UserActions.loadUsers());
  }
}
```

## Patrones Avanzados

### Optimistic Updates

```typescript
// Zustand
addTodo: async (text) => {
  const tempId = Date.now().toString();
  const tempTodo = { id: tempId, text, completed: false };
  
  // Optimistic update
  set(state => ({ todos: [...state.todos, tempTodo] }));
  
  try {
    const response = await fetch('/api/todos', {
      method: 'POST',
      body: JSON.stringify({ text }),
    });
    const todo = await response.json();
    
    // Replace temp with real
    set(state => ({
      todos: state.todos.map(t => t.id === tempId ? todo : t)
    }));
  } catch (error) {
    // Revert on error
    set(state => ({
      todos: state.todos.filter(t => t.id !== tempId)
    }));
  }
}
```

### Normalized State

```typescript
interface NormalizedState {
  users: {
    byId: Record<string, User>;
    allIds: string[];
  };
  posts: {
    byId: Record<string, Post>;
    allIds: string[];
  };
}

// Helpers
const addUser = (state, user) => {
  state.users.byId[user.id] = user;
  if (!state.users.allIds.includes(user.id)) {
    state.users.allIds.push(user.id);
  }
};

const getUser = (state, id) => state.users.byId[id];
const getAllUsers = (state) => 
  state.users.allIds.map(id => state.users.byId[id]);
```

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Too many re-renders | No memoizar selectors | Usar selectors con createSelector |
| Stale state | Estado mutado directamente | Usar spread operator o immer |
| Actions no dispatchean | Olvidar return en thunk | Verificar async thunks |
| Store no persiste | Middleware mal configurado | Verificar persist config |

## Checklist de Validacion

- [ ] Estado es immutable (no mutaciones directas)
- [ ] Selectors memoizados (evitan re-renders)
- [ ] Actions tienen nombres descriptivos
- [ ] Loading y error states manejados
- [ ] DevTools configuradas
- [ ] TypeScript types definidos
- [ ] Side effects en lugares correctos (effects/thunks)
- [ ] Estado normalizado si es necesario
- [ ] Persist configurado si se requiere

## Best Practices

1. **Empieza simple** - Context API → Zustand → Redux según complejidad
2. **No sobre-ingenierizar** - No todo debe estar en el store global
3. **Normalizar estado** - Para datos relacionales complejos
4. **Selectors everywhere** - No acceder state directamente
5. **Un source of truth** - Estado derivado en selectors
6. **Immutability** - Nunca mutar estado directamente
7. **TypeScript** - Tipos en todo (state, actions, selectors)
8. **DevTools** - Úsalas para debugging

---

**Última actualización:** Fase 3 - Skills Frontend Avanzado  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Complementar con Frontend Design para UIs profesionales
