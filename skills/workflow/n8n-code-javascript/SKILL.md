# n8n Code Node -- JavaScript

**Scope:** workflow
**Trigger:** when writing JavaScript in n8n Code nodes, transforming data, calling APIs from code, or debugging code node issues
**Tools:** mcp__claude_ai_n8n__get_workflow_details, bash, file_read
**Version:** 1.0.0

---

## Purpose

This skill covers JavaScript patterns for n8n Code nodes. It explains when to use code vs built-in nodes, how to access data, output format requirements, common transformations, and debugging techniques.

## When to Use Code Node vs Built-In Nodes

Use a Code node when:
- The built-in nodes cannot express the transformation you need.
- You need to combine data from multiple sources with custom logic.
- Complex conditional logic goes beyond what If/Switch nodes handle.
- You need string manipulation, regex, or custom calculations.
- You are restructuring deeply nested JSON.

Use built-in nodes when:
- A Set node can handle the field mapping.
- The If/Switch node covers your branching needs.
- The Item Lists node can sort, limit, or summarize.
- An Expression in a node field achieves the result.

Rule of thumb: if you can do it without code, do it without code. Code nodes are harder to maintain and debug for non-developers.

## Data Access

### Input Data

```javascript
// All items from the previous node
const allItems = $input.all();

// First item only
const firstItem = $input.first();

// Current item (in "Run Once for Each Item" mode)
const currentItem = $input.item;

// Access a specific field
const email = $input.first().json.email;

// Access from a specific named node
const userData = $('Fetch User').first().json;
const allOrders = $('Get Orders').all();
```

### Item Structure

Every item in n8n is an object with a `json` property and optionally a `binary` property:

```javascript
{
  json: {
    name: "Alice",
    email: "alice@example.com"
  },
  binary: {
    attachment: {
      data: "base64string...",
      mimeType: "application/pdf",
      fileName: "report.pdf"
    }
  }
}
```

### Execution Context

```javascript
// Workflow static data (persists between executions)
const lastRun = $workflow.staticData.lastRun;
$workflow.staticData.lastRun = new Date().toISOString();

// Environment variables
const apiUrl = $env.API_BASE_URL;

// Workflow metadata
const workflowId = $workflow.id;
const workflowName = $workflow.name;

// Execution metadata
const executionId = $execution.id;
const executionMode = $execution.mode; // "manual" or "production"

// Current node info
const nodeName = $node.name;

// Workflow variables (set in workflow settings)
const myVar = $vars.myVariable;
```

## Output Format

The Code node must return an array of items. Each item must have a `json` property.

### Run Once for All Items (default mode)

```javascript
// Return multiple items
return [
  { json: { name: "Alice", role: "admin" } },
  { json: { name: "Bob", role: "user" } }
];

// Transform all input items
return $input.all().map(item => ({
  json: {
    fullName: `${item.json.firstName} ${item.json.lastName}`,
    email: item.json.email.toLowerCase()
  }
}));
```

### Run Once for Each Item

```javascript
// Return the transformed current item
return {
  json: {
    ...($input.item.json),
    processedAt: new Date().toISOString()
  }
};
```

### Multiple Outputs

```javascript
// Send items to different outputs (max 4 outputs configurable)
// Output 0: valid items, Output 1: invalid items
const valid = [];
const invalid = [];

for (const item of $input.all()) {
  if (item.json.email && item.json.email.includes('@')) {
    valid.push(item);
  } else {
    invalid.push({ json: { ...item.json, error: 'Invalid email' } });
  }
}

return [valid, invalid];
```

## Common Transformations

### Map -- Transform Each Item

```javascript
return $input.all().map(item => ({
  json: {
    id: item.json.id,
    displayName: `${item.json.first_name} ${item.json.last_name}`,
    email: item.json.email.toLowerCase().trim(),
    isActive: item.json.status === 'active'
  }
}));
```

### Filter -- Keep Items Matching a Condition

```javascript
return $input.all().filter(item =>
  item.json.amount > 100 && item.json.status === 'completed'
);
```

### Reduce -- Aggregate Into a Single Item

```javascript
const total = $input.all().reduce((sum, item) =>
  sum + item.json.amount, 0
);

const count = $input.all().length;

return [{
  json: {
    totalAmount: total,
    averageAmount: total / count,
    itemCount: count
  }
}];
```

### Group By

```javascript
const grouped = {};

for (const item of $input.all()) {
  const key = item.json.category;
  if (!grouped[key]) {
    grouped[key] = [];
  }
  grouped[key].push(item.json);
}

return Object.entries(grouped).map(([category, items]) => ({
  json: {
    category,
    count: items.length,
    items
  }
}));
```

### Flatten Nested Arrays

```javascript
// Input: [{ json: { orders: [{id:1}, {id:2}] } }]
// Output: [{ json: {id:1} }, { json: {id:2} }]
return $input.all().flatMap(item =>
  item.json.orders.map(order => ({ json: order }))
);
```

### Deduplicate

```javascript
const seen = new Set();
return $input.all().filter(item => {
  const key = item.json.email.toLowerCase();
  if (seen.has(key)) return false;
  seen.add(key);
  return true;
});
```

### Sort

```javascript
return [...$input.all()].sort((a, b) =>
  new Date(b.json.createdAt) - new Date(a.json.createdAt)
);
```

## Date Handling with Luxon

Luxon is built into n8n and available in all Code nodes as `DateTime`.

```javascript
const { DateTime } = require('luxon');

// Current time
const now = DateTime.now();
const utcNow = DateTime.utc();

// Parse a date string
const date = DateTime.fromISO('2026-03-23T10:30:00Z');
const fromFormat = DateTime.fromFormat('23/03/2026', 'dd/MM/yyyy');

// Format
const formatted = now.toFormat('yyyy-MM-dd'); // "2026-03-23"
const human = now.toLocaleString(DateTime.DATE_FULL); // "March 23, 2026"
const iso = now.toISO(); // "2026-03-23T10:30:00.000-06:00"

// Time zones
const mexico = now.setZone('America/Mexico_City');
const tokyo = now.setZone('Asia/Tokyo');

// Arithmetic
const yesterday = now.minus({ days: 1 });
const nextWeek = now.plus({ weeks: 1 });
const startOfMonth = now.startOf('month');
const endOfDay = now.endOf('day');

// Compare
const isAfter = date1 > date2; // uses native comparison
const diff = date1.diff(date2, 'days').days; // difference in days

// Business logic example: is within business hours?
const hour = now.setZone('America/Mexico_City').hour;
const isBusinessHours = hour >= 9 && hour < 18;
const isWeekday = now.weekday <= 5; // 1=Mon, 7=Sun
```

## String Manipulation

```javascript
// Regex extraction
const email = text.match(/[\w.-]+@[\w.-]+\.\w+/)?.[0] || null;
const numbers = text.match(/\d+/g)?.map(Number) || [];

// Template literals for building messages
const message = `Order #${orderId} from ${customerName} totaling $${amount.toFixed(2)}`;

// Slug generation
const slug = title
  .toLowerCase()
  .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // remove accents
  .replace(/[^a-z0-9]+/g, '-')
  .replace(/^-|-$/g, '');

// Truncate with ellipsis
const truncated = text.length > 100 ? text.substring(0, 97) + '...' : text;

// Split and clean
const tags = rawTags.split(',').map(t => t.trim()).filter(Boolean);

// Replace patterns
const sanitized = html.replace(/<[^>]*>/g, ''); // strip HTML tags
const masked = phone.replace(/(\d{3})\d{4}(\d{3})/, '$1****$2');
```

## API Calls with Fetch

The Code node in n8n supports the `fetch` API (available in newer versions) or you can use the built-in `$http` helper.

### GET Request

```javascript
const response = await fetch('https://api.example.com/users', {
  headers: {
    'Authorization': `Bearer ${$env.API_TOKEN}`,
    'Content-Type': 'application/json'
  }
});

if (!response.ok) {
  throw new Error(`API error: ${response.status} ${response.statusText}`);
}

const data = await response.json();
return data.users.map(user => ({ json: user }));
```

### POST Request

```javascript
const response = await fetch('https://api.example.com/orders', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${$env.API_TOKEN}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    customerId: $input.first().json.customerId,
    items: $input.first().json.items
  })
});

if (!response.ok) {
  const errorBody = await response.text();
  throw new Error(`API error ${response.status}: ${errorBody}`);
}

const result = await response.json();
return [{ json: result }];
```

### Error Handling in API Calls

```javascript
try {
  const response = await fetch(url, options);

  if (response.status === 429) {
    // Rate limited -- return error for retry pattern
    return [{ json: { error: 'rate_limited', retryAfter: response.headers.get('Retry-After') } }];
  }

  if (!response.ok) {
    return [{ json: { error: `http_${response.status}`, message: await response.text() } }];
  }

  return [{ json: await response.json() }];
} catch (err) {
  return [{ json: { error: 'network_error', message: err.message } }];
}
```

## Working with Binary Data

```javascript
// Read binary data from previous node
const binaryData = $input.first().binary.file;
const buffer = Buffer.from(binaryData.data, 'base64');
const text = buffer.toString('utf-8');

// Create binary output
const csvContent = 'name,email\nAlice,alice@example.com\nBob,bob@example.com';
const base64 = Buffer.from(csvContent).toString('base64');

return [{
  json: { fileName: 'export.csv' },
  binary: {
    file: {
      data: base64,
      mimeType: 'text/csv',
      fileName: 'export.csv'
    }
  }
}];
```

## Error Handling Patterns

### Try/Catch with Structured Errors

```javascript
try {
  const result = processData($input.all());
  return [{ json: { success: true, data: result } }];
} catch (error) {
  // Return error as data (for downstream handling)
  return [{
    json: {
      success: false,
      error: error.message,
      stack: error.stack,
      node: $node.name,
      executionId: $execution.id
    }
  }];
}
```

### Input Validation

```javascript
const items = $input.all();

if (items.length === 0) {
  throw new Error('No input items received');
}

const required = ['email', 'name', 'amount'];
for (const item of items) {
  for (const field of required) {
    if (item.json[field] === undefined || item.json[field] === null) {
      throw new Error(`Missing required field: ${field} in item ${JSON.stringify(item.json)}`);
    }
  }
}
```

## Performance Tips

- Avoid N+1 patterns: do not make an API call inside a loop. Fetch all data first, then process.
- Use `Map` objects instead of plain objects for frequent key lookups on large datasets.
- For large arrays, prefer `for...of` loops over `.map()` -- less memory allocation.
- Be aware of n8n's memory limits: do not load entire large files into memory.
- Use `$input.first()` instead of `$input.all()[0]` -- it is optimized.
- Avoid `JSON.parse(JSON.stringify(obj))` for deep cloning. Use structured clone or spread operators.

## Debugging Tips

- `console.log()` output is visible in the execution data panel under "Output" for the Code node.
- Return intermediate data as items during development to inspect values.
- Use `$execution.mode` to add debug-only logic: `if ($execution.mode === 'manual') { ... }`.
- Test complex logic outside n8n first (Node.js REPL or a simple script).
- Break complex Code nodes into multiple smaller ones for easier debugging.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Forgetting to return | Always return an array of `{ json: {} }` objects |
| Returning plain objects | Wrap in `{ json: ... }` -- `return [{ json: myData }]` |
| Using `items` variable directly | Use `$input.all()` in modern n8n (v1+) |
| Modifying input items in place | Create new objects instead of mutating input |
| Accessing undefined nested properties | Use optional chaining: `item.json.user?.email` |
| Not handling empty arrays | Check `$input.all().length` before processing |
| Synchronous code for async operations | Use `await` with fetch and other async APIs |

## Practical Examples

### Transform API Response to Flat Records

```javascript
// Input: nested API response with pagination metadata
// Output: flat list of user records
const response = $input.first().json;

return response.data.users.map(user => ({
  json: {
    id: user.id,
    name: `${user.profile.firstName} ${user.profile.lastName}`,
    email: user.contact.email,
    plan: user.subscription?.plan || 'free',
    signupDate: DateTime.fromISO(user.createdAt).toFormat('yyyy-MM-dd'),
    isActive: user.status === 'active'
  }
}));
```

### Merge Two Datasets by Key

```javascript
// Merge contacts from CRM with orders from database
const contacts = $('Fetch Contacts').all();
const orders = $('Fetch Orders').all();

// Build a lookup map from orders
const ordersByEmail = new Map();
for (const order of orders) {
  const email = order.json.email.toLowerCase();
  if (!ordersByEmail.has(email)) {
    ordersByEmail.set(email, []);
  }
  ordersByEmail.get(email).push(order.json);
}

// Merge
return contacts.map(contact => {
  const email = contact.json.email.toLowerCase();
  const contactOrders = ordersByEmail.get(email) || [];
  return {
    json: {
      ...contact.json,
      orderCount: contactOrders.length,
      totalSpent: contactOrders.reduce((sum, o) => sum + o.amount, 0),
      lastOrderDate: contactOrders.length > 0
        ? contactOrders.sort((a, b) => new Date(b.date) - new Date(a.date))[0].date
        : null
    }
  };
});
```

### Calculate Business Logic

```javascript
// Calculate pricing tiers, discounts, and tax
return $input.all().map(item => {
  const { quantity, unitPrice, customerType, country } = item.json;

  // Volume discount
  let discount = 0;
  if (quantity >= 100) discount = 0.15;
  else if (quantity >= 50) discount = 0.10;
  else if (quantity >= 20) discount = 0.05;

  // Customer type discount (stackable)
  if (customerType === 'wholesale') discount += 0.05;

  const subtotal = quantity * unitPrice;
  const discountAmount = subtotal * discount;
  const afterDiscount = subtotal - discountAmount;

  // Tax by country
  const taxRates = { MX: 0.16, US: 0.08, DE: 0.19, GB: 0.20 };
  const taxRate = taxRates[country] || 0;
  const tax = afterDiscount * taxRate;
  const total = afterDiscount + tax;

  return {
    json: {
      ...item.json,
      subtotal: Math.round(subtotal * 100) / 100,
      discount: `${(discount * 100).toFixed(0)}%`,
      discountAmount: Math.round(discountAmount * 100) / 100,
      taxRate: `${(taxRate * 100).toFixed(0)}%`,
      tax: Math.round(tax * 100) / 100,
      total: Math.round(total * 100) / 100
    }
  };
});
```

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
