# n8n Expressions Reference

**Scope:** workflow
**Trigger:** when writing expressions in n8n node fields, referencing data from other nodes, using built-in variables, or debugging expression errors
**Tools:** mcp__claude_ai_n8n__get_workflow_details, bash, file_read
**Version:** 1.0.0

---

## Purpose

This skill is a comprehensive reference for n8n expression syntax. Expressions allow you to dynamically reference data, transform values, and add conditional logic directly in node fields without writing a Code node. Use this when you need quick data manipulation inline.

## Basic Syntax

Expressions in n8n are wrapped in double curly braces: `{{ }}`. They are written in node field values to dynamically reference data.

```
{{ $json.fieldName }}
```

Everything inside `{{ }}` is evaluated as JavaScript. You can use any valid JavaScript expression.

### Where Expressions Work

- Any node field that shows the expression toggle (the `fx` button).
- Not available in Code node content (that is full JavaScript/Python).
- Available in HTTP Request URLs, headers, body, and query parameters.
- Available in Set node values, If node conditions, and most configuration fields.

## Data References

### Current Item Data

```
{{ $json.email }}                          // top-level field
{{ $json.user.name }}                      // nested field
{{ $json.items[0].id }}                    // array element
{{ $json["field with spaces"] }}           // field with special characters
{{ $json.user?.email }}                    // optional chaining (safe access)
{{ $json.amount ?? 0 }}                    // nullish coalescing (default value)
```

### Previous Node Data (by Name)

```
{{ $('Node Name').item.json.email }}       // current item from named node
{{ $('Fetch User').first().json.name }}    // first item from named node
{{ $('Fetch User').last().json.name }}     // last item from named node
{{ $('Fetch User').all() }}                // all items (returns array)
{{ $('Fetch User').all().length }}         // count of items
{{ $('Fetch User').item.json }}            // same item index as current
```

### Input Shortcuts

```
{{ $input.first().json.email }}            // first item from direct input
{{ $input.last().json.email }}             // last item from direct input
{{ $input.all() }}                         // all input items
{{ $input.item.json.email }}               // current item
```

## Built-In Variables

### Date and Time

```
{{ $now }}                                 // current DateTime (Luxon object)
{{ $now.toISO() }}                         // "2026-03-23T10:30:00.000-06:00"
{{ $now.toFormat('yyyy-MM-dd') }}          // "2026-03-23"
{{ $now.toFormat('dd/MM/yyyy HH:mm') }}    // "23/03/2026 10:30"
{{ $today }}                               // start of today (midnight)
{{ $today.toISO() }}                       // "2026-03-23T00:00:00.000-06:00"
```

### Workflow and Execution

```
{{ $workflow.id }}                          // workflow ID
{{ $workflow.name }}                        // workflow name
{{ $workflow.active }}                      // true/false
{{ $execution.id }}                         // current execution ID
{{ $execution.mode }}                       // "manual" or "production"
{{ $execution.resumeUrl }}                 // URL to resume (in Wait node)
```

### Environment and Variables

```
{{ $env.MY_API_KEY }}                      // environment variable
{{ $env.BASE_URL }}                        // environment variable
{{ $vars.myVariable }}                     // workflow variable (set in settings)
{{ $vars.defaultCurrency }}                // workflow variable
```

### Node Metadata

```
{{ $node.name }}                           // current node name
{{ $node.outputIndex }}                    // current output index
{{ $runIndex }}                            // current run index (for loops)
{{ $itemIndex }}                           // current item index
```

## Method Chaining

### String Methods

```
{{ $json.name.toUpperCase() }}             // "ALICE"
{{ $json.name.toLowerCase() }}             // "alice"
{{ $json.email.trim() }}                   // remove whitespace
{{ $json.name.split(' ')[0] }}             // first name
{{ $json.text.substring(0, 100) }}         // first 100 chars
{{ $json.slug.replace(/-/g, ' ') }}        // replace dashes with spaces
{{ $json.tags.includes('vip') }}           // boolean check
{{ $json.name.startsWith('Dr.') }}         // boolean check
{{ $json.url.match(/id=(\d+)/)?.[1] }}     // regex capture group
{{ $json.text.length }}                    // string length
```

### Number Methods

```
{{ $json.price.toFixed(2) }}               // "19.99"
{{ Math.round($json.amount) }}             // rounded integer
{{ Math.ceil($json.amount) }}              // round up
{{ Math.floor($json.amount) }}             // round down
{{ Math.max($json.a, $json.b) }}           // larger value
{{ Math.abs($json.balance) }}              // absolute value
{{ parseInt($json.stringNumber) }}         // string to integer
{{ parseFloat($json.stringDecimal) }}      // string to float
```

### Array Methods

```
{{ $json.items.length }}                   // count
{{ $json.items.filter(i => i.active) }}    // filter
{{ $json.items.map(i => i.name) }}         // extract field
{{ $json.items.find(i => i.id === 5) }}    // find single item
{{ $json.items.some(i => i.status === 'error') }}  // any match?
{{ $json.items.every(i => i.valid) }}      // all match?
{{ $json.tags.join(', ') }}                // array to string
{{ $json.items.slice(0, 5) }}              // first 5 items
{{ [...new Set($json.tags)] }}             // unique values
```

## Conditional Expressions

### Ternary Operator

```
{{ $json.status === 'active' ? 'Yes' : 'No' }}
{{ $json.amount > 1000 ? 'High Value' : 'Standard' }}
{{ $json.email ? $json.email : 'no-email@placeholder.com' }}
{{ $json.items?.length > 0 ? 'Has items' : 'Empty' }}
```

### Multi-Level Conditions

```
{{ $json.score >= 90 ? 'A' : $json.score >= 80 ? 'B' : $json.score >= 70 ? 'C' : 'F' }}
```

### Nullish Coalescing and Default Values

```
{{ $json.nickname ?? $json.name ?? 'Anonymous' }}
{{ $json.settings?.theme ?? 'light' }}
{{ $json.count || 0 }}                     // falsy fallback (0, '', null, undefined)
{{ $json.count ?? 0 }}                     // null/undefined fallback only
```

## Date Expressions

n8n uses Luxon for date operations. `$now` and `$today` return Luxon DateTime objects.

### Current Date Operations

```
{{ $now.toISO() }}                                    // full ISO string
{{ $now.toFormat('yyyy-MM-dd') }}                     // date only
{{ $now.toFormat('HH:mm:ss') }}                       // time only
{{ $now.toFormat('EEEE, MMMM d, yyyy') }}             // "Monday, March 23, 2026"
{{ $now.toMillis() }}                                 // Unix timestamp (ms)
{{ $now.toSeconds() }}                                // Unix timestamp (s)
```

### Date Arithmetic

```
{{ $now.minus({ days: 7 }).toISO() }}                 // 7 days ago
{{ $now.plus({ hours: 2 }).toISO() }}                 // 2 hours from now
{{ $now.minus({ months: 1 }).startOf('month').toISO() }}  // start of last month
{{ $now.endOf('week').toISO() }}                      // end of current week
{{ $now.startOf('day').toISO() }}                     // midnight today
{{ $today.plus({ days: 30 }).toFormat('yyyy-MM-dd') }} // 30 days from today
```

### Parsing Dates

```
{{ DateTime.fromISO($json.dateString) }}
{{ DateTime.fromISO($json.dateString).toFormat('dd/MM/yyyy') }}
{{ DateTime.fromFormat($json.date, 'MM/dd/yyyy').toISO() }}
{{ DateTime.fromMillis($json.timestamp).toISO() }}
{{ DateTime.fromSeconds($json.unixTimestamp).toISO() }}
```

### Date Comparisons

```
{{ DateTime.fromISO($json.expiresAt) < $now ? 'Expired' : 'Valid' }}
{{ DateTime.fromISO($json.createdAt).diff($now, 'days').days }}
{{ Math.abs(DateTime.fromISO($json.date).diff($now, 'hours').hours) }}
```

### Timezone Operations

```
{{ $now.setZone('America/Mexico_City').toFormat('HH:mm') }}
{{ $now.setZone('UTC').toISO() }}
{{ DateTime.fromISO($json.date).setZone('America/New_York').toFormat('yyyy-MM-dd HH:mm') }}
```

## Working with Arrays from Previous Nodes

```
// Count items from a previous node
{{ $('Fetch Users').all().length }}

// Get a specific item by index
{{ $('Fetch Users').all()[0].json.email }}

// Extract a field from all items
{{ $('Fetch Users').all().map(i => i.json.email).join(', ') }}

// Check if any item matches
{{ $('Fetch Users').all().some(i => i.json.role === 'admin') }}

// Sum a numeric field
{{ $('Fetch Orders').all().reduce((sum, i) => sum + i.json.amount, 0) }}

// Find a specific item
{{ $('Fetch Users').all().find(i => i.json.id === $json.userId)?.json.name ?? 'Unknown' }}
```

## Binary Data References

```
{{ $binary.data }}                         // binary data object
{{ $binary.file.fileName }}                // original file name
{{ $binary.file.mimeType }}                // MIME type
{{ $binary.file.fileSize }}                // size in bytes
{{ $binary.attachment.fileName }}           // named binary (when node outputs named binaries)
```

## Common Expression Recipes

### 1. Generate a Unique ID

```
{{ $now.toMillis() + '_' + Math.random().toString(36).substring(2, 9) }}
```

### 2. Capitalize First Letter

```
{{ $json.name.charAt(0).toUpperCase() + $json.name.slice(1).toLowerCase() }}
```

### 3. Extract Domain from Email

```
{{ $json.email.split('@')[1] }}
```

### 4. Format Currency

```
{{ '$' + $json.amount.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',') }}
```

### 5. Calculate Percentage

```
{{ Math.round(($json.completed / $json.total) * 100) + '%' }}
```

### 6. Build a URL with Query Parameters

```
{{ $env.API_URL + '/search?q=' + encodeURIComponent($json.query) + '&page=' + ($json.page || 1) }}
```

### 7. Conditional Field Inclusion

```
{{ JSON.stringify(Object.assign({name: $json.name}, $json.email ? {email: $json.email} : {})) }}
```

### 8. Time Ago (Approximate)

```
{{ Math.round(Math.abs(DateTime.fromISO($json.createdAt).diffNow('hours').hours)) + ' hours ago' }}
```

### 9. Mask Sensitive Data

```
{{ $json.email.replace(/(.{2}).*(@.*)/, '$1***$2') }}
```

### 10. Check Business Hours

```
{{ $now.setZone('America/Mexico_City').hour >= 9 && $now.setZone('America/Mexico_City').hour < 18 ? 'open' : 'closed' }}
```

### 11. Pluralize

```
{{ $json.count + ' ' + ($json.count === 1 ? 'item' : 'items') }}
```

### 12. Truncate Text with Ellipsis

```
{{ $json.description.length > 200 ? $json.description.substring(0, 197) + '...' : $json.description }}
```

### 13. Parse JSON String

```
{{ JSON.parse($json.jsonString).fieldName }}
```

### 14. Current Quarter

```
{{ 'Q' + Math.ceil($now.month / 3) + ' ' + $now.year }}
```

### 15. Weekday Check

```
{{ $now.weekday <= 5 ? 'weekday' : 'weekend' }}
```

### 16. Slug from Title

```
{{ $json.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') }}
```

### 17. Random Selection from Array

```
{{ $json.options[Math.floor(Math.random() * $json.options.length)] }}
```

### 18. Days Until Date

```
{{ Math.ceil(DateTime.fromISO($json.deadline).diff($now, 'days').days) }}
```

## Debugging Expressions

### Use a Set Node to Test

1. Add a Set node after the node whose data you want to inspect.
2. Add fields and write your expression in each field.
3. Run the workflow manually and check the Set node's output.
4. This lets you see the evaluated result without affecting downstream nodes.

### Common Debugging Steps

1. Start with a simple reference: `{{ $json }}` -- does data exist?
2. Add one level at a time: `{{ $json.user }}` then `{{ $json.user.email }}`.
3. Check the node name spelling: `{{ $('Fetch User') }}` -- exact match required (case-sensitive, including spaces).
4. Verify the data structure in the previous node's output panel.

## Common Errors and Fixes

| Error | Cause | Fix |
|---|---|---|
| `Cannot read property 'x' of undefined` | Field does not exist in the data | Use optional chaining: `$json.user?.email` |
| `$('Node Name') is not a function` | Node name does not match exactly | Check spelling, capitalization, and spaces |
| `TypeError: x is not a function` | Calling a method on wrong type | Verify the data type (string vs number vs array) |
| `Expression evaluation error` | Syntax error in expression | Check for unmatched brackets, quotes, or operators |
| `undefined` output | Referencing a field that does not exist | Use `$json.field ?? 'default'` for fallback |
| Empty string output | Field exists but is empty | Use `$json.field \|\| 'fallback'` for empty string fallback |
| `RangeError: Invalid time value` | Invalid date string passed to DateTime | Validate date format before parsing |
| Type coercion issues | Comparing string "5" with number 5 | Use explicit conversion: `Number($json.count)` or `String($json.id)` |

## Expression vs Code Node -- Decision Guide

| Scenario | Use Expression | Use Code Node |
|---|---|---|
| Reference a single field | Yes | No |
| Simple conditional | Yes (ternary) | No |
| String formatting | Yes | No |
| Date arithmetic | Yes | No |
| Loop over items | Maybe (array methods) | Yes (complex logic) |
| Multi-step transformation | No | Yes |
| External API call | No | Yes |
| Error handling with try/catch | No | Yes |
| Complex business logic | No | Yes |

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
