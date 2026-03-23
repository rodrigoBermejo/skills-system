# Frontend Testing - Jest, RTL, Cypress

**Scope:** frontend  
**Trigger:** cuando se necesite testing de frontend, se mencione Jest, React Testing Library, Cypress, Playwright, o testing strategies  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## Proposito

Esta skill te guía para implementar testing completo en aplicaciones frontend. Cubre unit tests con Jest, component tests con React Testing Library, integration tests y e2e tests con Cypress/Playwright.

## Cuando Usar Esta Skill

- Configurar testing en proyectos nuevos
- Escribir unit tests para funciones/hooks
- Testar componentes React/Angular
- Implementar integration tests
- Configurar e2e tests
- CI/CD pipeline con tests
- TDD (Test-Driven Development)
- Aumentar coverage de tests

## Contexto y Conocimiento

### Testing Pyramid

```
       /\
      /E2E\        ← Pocos, lentos, caros
     /------\
    /  Int   \     ← Algunos, medianos
   /----------\
  /    Unit    \   ← Muchos, rápidos, baratos
 /--------------\
```

**Distribución recomendada:**
- 70% Unit tests
- 20% Integration tests
- 10% E2E tests

### Testing Trophy (Moderna)

```
       /\
      /E2E\
     /------\
    /  Int   \      ← Énfasis aquí
   /----------\
  /    Unit    \
 /--------------\
  Static Analysis
```

## Jest - Unit Testing

### Setup

```bash
npm install -D jest @types/jest
npm install -D @testing-library/react @testing-library/jest-dom
npm install -D @testing-library/user-event
```

**jest.config.js:**
```javascript
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.ts'],
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
```

**setupTests.ts:**
```typescript
import '@testing-library/jest-dom';
```

### Testing Funciones Puras

```typescript
// utils/math.ts
export const add = (a: number, b: number) => a + b;
export const multiply = (a: number, b: number) => a * b;

export const calculateDiscount = (price: number, discount: number) => {
  if (discount < 0 || discount > 100) {
    throw new Error('Invalid discount percentage');
  }
  return price * (1 - discount / 100);
};

// utils/math.test.ts
import { add, multiply, calculateDiscount } from './math';

describe('Math utilities', () => {
  describe('add', () => {
    it('should add two positive numbers', () => {
      expect(add(2, 3)).toBe(5);
    });
    
    it('should add negative numbers', () => {
      expect(add(-2, -3)).toBe(-5);
    });
    
    it('should add zero', () => {
      expect(add(5, 0)).toBe(5);
    });
  });
  
  describe('calculateDiscount', () => {
    it('should calculate 10% discount', () => {
      expect(calculateDiscount(100, 10)).toBe(90);
    });
    
    it('should throw error for invalid discount', () => {
      expect(() => calculateDiscount(100, 150)).toThrow('Invalid discount percentage');
    });
    
    it('should handle 0% discount', () => {
      expect(calculateDiscount(100, 0)).toBe(100);
    });
  });
});
```

### Testing Custom Hooks

```typescript
// hooks/useCounter.ts
import { useState } from 'react';

export const useCounter = (initialValue = 0) => {
  const [count, setCount] = useState(initialValue);
  
  const increment = () => setCount(c => c + 1);
  const decrement = () => setCount(c => c - 1);
  const reset = () => setCount(initialValue);
  
  return { count, increment, decrement, reset };
};

// hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('should initialize with default value', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });
  
  it('should initialize with custom value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });
  
  it('should increment count', () => {
    const { result } = renderHook(() => useCounter());
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });
  
  it('should decrement count', () => {
    const { result } = renderHook(() => useCounter(5));
    
    act(() => {
      result.current.decrement();
    });
    
    expect(result.current.count).toBe(4);
  });
  
  it('should reset to initial value', () => {
    const { result } = renderHook(() => useCounter(10));
    
    act(() => {
      result.current.increment();
      result.current.increment();
      result.current.reset();
    });
    
    expect(result.current.count).toBe(10);
  });
});
```

## React Testing Library

### Principios de RTL

```
"The more your tests resemble the way your software is used,
the more confidence they can give you."

1. Test behavior, not implementation
2. Query by accessibility (role, label, text)
3. No test IDs unless necessary
4. User interactions (click, type, etc.)
```

### Testing Componentes

```typescript
// Button.tsx
interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ 
  onClick, 
  children, 
  disabled 
}) => {
  return (
    <button 
      onClick={onClick} 
      disabled={disabled}
      className="btn"
    >
      {children}
    </button>
  );
};

// Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('should render children', () => {
    render(<Button onClick={() => {}}>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
  
  it('should call onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    
    fireEvent.click(screen.getByText('Click'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('should not call onClick when disabled', () => {
    const handleClick = jest.fn();
    render(
      <Button onClick={handleClick} disabled>
        Click
      </Button>
    );
    
    fireEvent.click(screen.getByText('Click'));
    
    expect(handleClick).not.toHaveBeenCalled();
  });
});
```

### Testing Forms

```typescript
// LoginForm.tsx
interface LoginFormProps {
  onSubmit: (email: string, password: string) => void;
}

export const LoginForm: React.FC<LoginFormProps> = ({ onSubmit }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(email, password);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        aria-label="Email"
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        aria-label="Password"
      />
      <button type="submit">Login</button>
    </form>
  );
};

// LoginForm.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('should submit with email and password', async () => {
    const user = userEvent.setup();
    const handleSubmit = jest.fn();
    
    render(<LoginForm onSubmit={handleSubmit} />);
    
    // Type in inputs
    await user.type(screen.getByLabelText('Email'), 'test@example.com');
    await user.type(screen.getByLabelText('Password'), 'password123');
    
    // Submit form
    await user.click(screen.getByRole('button', { name: 'Login' }));
    
    expect(handleSubmit).toHaveBeenCalledWith('test@example.com', 'password123');
  });
  
  it('should clear inputs after submit', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={() => {}} />);
    
    await user.type(screen.getByLabelText('Email'), 'test@example.com');
    await user.type(screen.getByLabelText('Password'), 'pass');
    await user.click(screen.getByRole('button', { name: 'Login' }));
    
    expect(screen.getByLabelText('Email')).toHaveValue('');
    expect(screen.getByLabelText('Password')).toHaveValue('');
  });
});
```

### Testing Async Components

```typescript
// UserList.tsx
export const UserList: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    fetch('/api/users')
      .then(res => res.json())
      .then(data => {
        setUsers(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
};

// UserList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { UserList } from './UserList';

// Mock fetch
global.fetch = jest.fn();

describe('UserList', () => {
  beforeEach(() => {
    (fetch as jest.Mock).mockClear();
  });
  
  it('should show loading state', () => {
    (fetch as jest.Mock).mockImplementation(() => 
      new Promise(() => {}) // Never resolves
    );
    
    render(<UserList />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
  
  it('should display users after loading', async () => {
    const mockUsers = [
      { id: '1', name: 'John' },
      { id: '2', name: 'Jane' },
    ];
    
    (fetch as jest.Mock).mockResolvedValue({
      json: async () => mockUsers,
    });
    
    render(<UserList />);
    
    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument();
      expect(screen.getByText('Jane')).toBeInTheDocument();
    });
  });
  
  it('should display error message on failure', async () => {
    (fetch as jest.Mock).mockRejectedValue(
      new Error('Network error')
    );
    
    render(<UserList />);
    
    await waitFor(() => {
      expect(screen.getByText(/Error: Network error/)).toBeInTheDocument();
    });
  });
});
```

### Queries en RTL

```typescript
// Prioridad de queries (de mejor a peor):

// 1. getByRole - Más accesible
screen.getByRole('button', { name: 'Submit' });
screen.getByRole('textbox', { name: 'Email' });

// 2. getByLabelText - Para forms
screen.getByLabelText('Email');

// 3. getByPlaceholderText
screen.getByPlaceholderText('Enter email');

// 4. getByText - Para contenido
screen.getByText('Hello World');
screen.getByText(/hello/i); // Case insensitive

// 5. getByTestId - Último recurso
screen.getByTestId('custom-element');

// Variants:
// getBy* - Throws if not found
// queryBy* - Returns null if not found
// findBy* - Async, waits for element
```

## Cypress - E2E Testing

### Setup

```bash
npm install -D cypress
npx cypress open
```

**cypress.config.ts:**
```typescript
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
  },
});
```

### Test E2E Completo

```typescript
// cypress/e2e/login.cy.ts
describe('Login Flow', () => {
  beforeEach(() => {
    cy.visit('/login');
  });
  
  it('should login successfully with valid credentials', () => {
    // Type in form
    cy.get('input[name="email"]').type('user@example.com');
    cy.get('input[name="password"]').type('password123');
    
    // Submit
    cy.get('button[type="submit"]').click();
    
    // Assert redirect and welcome message
    cy.url().should('include', '/dashboard');
    cy.contains('Welcome, User').should('be.visible');
  });
  
  it('should show error with invalid credentials', () => {
    cy.get('input[name="email"]').type('wrong@example.com');
    cy.get('input[name="password"]').type('wrongpass');
    cy.get('button[type="submit"]').click();
    
    cy.contains('Invalid credentials').should('be.visible');
    cy.url().should('include', '/login'); // Stays on login page
  });
  
  it('should validate email format', () => {
    cy.get('input[name="email"]').type('invalid-email');
    cy.get('input[name="password"]').type('password123');
    cy.get('button[type="submit"]').click();
    
    cy.contains('Invalid email format').should('be.visible');
  });
});

// cypress/e2e/user-crud.cy.ts
describe('User CRUD', () => {
  beforeEach(() => {
    // Login first
    cy.login('admin@example.com', 'admin123');
    cy.visit('/users');
  });
  
  it('should create a new user', () => {
    cy.contains('Add User').click();
    
    cy.get('input[name="name"]').type('John Doe');
    cy.get('input[name="email"]').type('john@example.com');
    cy.get('select[name="role"]').select('user');
    
    cy.get('button[type="submit"]').click();
    
    // Verify user appears in list
    cy.contains('John Doe').should('be.visible');
    cy.contains('john@example.com').should('be.visible');
  });
  
  it('should edit existing user', () => {
    cy.contains('John Doe')
      .parent()
      .find('button[aria-label="Edit"]')
      .click();
    
    cy.get('input[name="name"]').clear().type('Jane Doe');
    cy.get('button[type="submit"]').click();
    
    cy.contains('Jane Doe').should('be.visible');
    cy.contains('John Doe').should('not.exist');
  });
  
  it('should delete user', () => {
    cy.contains('Jane Doe')
      .parent()
      .find('button[aria-label="Delete"]')
      .click();
    
    // Confirm deletion
    cy.contains('Are you sure?').should('be.visible');
    cy.contains('button', 'Confirm').click();
    
    cy.contains('Jane Doe').should('not.exist');
  });
});
```

### Custom Commands

```typescript
// cypress/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      login(email: string, password: string): Chainable<void>;
      getBySel(selector: string): Chainable<JQuery<HTMLElement>>;
    }
  }
}

Cypress.Commands.add('login', (email, password) => {
  cy.session([email, password], () => {
    cy.visit('/login');
    cy.get('input[name="email"]').type(email);
    cy.get('input[name="password"]').type(password);
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});

Cypress.Commands.add('getBySel', (selector) => {
  return cy.get(`[data-cy="${selector}"]`);
});
```

## Playwright (Alternativa a Cypress)

### Setup

```bash
npm init playwright@latest
```

### Test con Playwright

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL(/dashboard/);
    await expect(page.locator('text=Welcome')).toBeVisible();
  });
  
  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[name="email"]', 'wrong@example.com');
    await page.fill('input[name="password"]', 'wrong');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('text=Invalid credentials')).toBeVisible();
  });
});
```

## Testing Strategies

### TDD (Test-Driven Development)

```
1. Red: Write failing test
2. Green: Write minimal code to pass
3. Refactor: Improve code quality
```

```typescript
// 1. RED - Write test first
describe('add', () => {
  it('should add two numbers', () => {
    expect(add(2, 3)).toBe(5);
  });
});

// 2. GREEN - Minimal implementation
export const add = (a: number, b: number) => a + b;

// 3. REFACTOR - Improve if needed
export const add = (a: number, b: number): number => {
  if (!Number.isFinite(a) || !Number.isFinite(b)) {
    throw new Error('Invalid input');
  }
  return a + b;
};
```

### Coverage Goals

```json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Tests pasan localmente pero fallan en CI | Environment differences | Usar setup consistency |
| Flaky tests | Race conditions | Usar waitFor, proper async |
| Slow tests | Too many e2e tests | Balance test pyramid |
| False positives | Testing implementation | Test user behavior |

## Checklist de Validacion

- [ ] Coverage > 70% (unit + integration)
- [ ] Critical paths tienen e2e tests
- [ ] Tests corren en < 1 minuto (unit)
- [ ] No flaky tests
- [ ] CI/CD ejecuta tests automáticamente
- [ ] Tests documentan comportamiento esperado
- [ ] Mocks apropiados para external dependencies
- [ ] Accessibility tests incluidos

## Best Practices

1. **Test behavior, not implementation** - Usuario perspective
2. **AAA Pattern** - Arrange, Act, Assert
3. **One assertion per test** - Tests focused
4. **Descriptive test names** - Clear what's being tested
5. **Independent tests** - No dependencies entre tests
6. **Fast tests** - Optimize for speed
7. **Realistic data** - Use factories/fixtures
8. **Clean up** - afterEach cleanup

---

**Última actualización:** Fase 3 - Skills Frontend Avanzado  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Aplicar testing en proyectos reales para calidad asegurada
