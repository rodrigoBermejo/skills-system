# n8n Code Node -- Python

**Scope:** workflow
**Trigger:** when writing Python in n8n Code nodes, performing data transformations with Python, or choosing between Python and JavaScript for n8n code
**Tools:** mcp__claude_ai_n8n__get_workflow_details, bash, file_read
**Version:** 1.0.0

---

## Purpose

This skill covers Python patterns for n8n Code nodes. It explains when to choose Python over JavaScript, available libraries, data access patterns, common transformations, and limitations of the Python runtime in n8n.

## When to Use Python vs JavaScript in n8n

### Choose Python When

- The developer is more comfortable with Python than JavaScript.
- The transformation logic benefits from Python syntax (list comprehensions, dict operations).
- The workflow processes text data that benefits from Python's string handling.
- The logic involves mathematical calculations or statistical operations.
- You are porting existing Python code into an n8n workflow.

### Choose JavaScript When

- You need access to Luxon (date library) -- not available in Python.
- You need access to lodash -- not available in Python.
- You need to work with n8n binary data extensively.
- Performance is critical (JavaScript runs natively in n8n's Node.js runtime).
- You need `fetch()` for HTTP calls from code (Python has limited HTTP options in n8n).
- The rest of the team uses JavaScript for all code nodes (consistency).

## Data Access

### Input Data

```python
# All items from the previous node
all_items = _input.all()

# First item only
first_item = _input.first()

# Current item (in "Run Once for Each Item" mode)
current_item = _input.item

# Access a specific field
email = _input.first().json["email"]

# Safe access for potentially missing fields
name = _input.first().json.get("name", "Unknown")
```

### Referencing Other Nodes

```python
# Access output from a named node
user_data = _node["Fetch User"].json
all_orders = _node["Get Orders"].all()
```

### Execution Context

```python
import os

# Environment variables
api_url = os.environ.get("API_BASE_URL", "https://default.api.com")

# Note: $workflow.staticData, $execution, and $vars are not directly
# available in Python. Use JavaScript Code nodes for those features,
# or pass the values as input from a previous Set/Code node.
```

## Output Format

The Python Code node must return a list of dictionaries. Each dictionary must have a `json` key.

### Run Once for All Items

```python
# Return multiple items
return [
    {"json": {"name": "Alice", "role": "admin"}},
    {"json": {"name": "Bob", "role": "user"}}
]

# Transform all input items
return [
    {
        "json": {
            "fullName": f"{item.json['firstName']} {item.json['lastName']}",
            "email": item.json["email"].lower()
        }
    }
    for item in _input.all()
]
```

### Run Once for Each Item

```python
from datetime import datetime

# Return the transformed current item
return {
    "json": {
        **_input.item.json,
        "processedAt": datetime.utcnow().isoformat()
    }
}
```

## Available Libraries

The Python Code node in n8n has access to Python's standard library. Commonly used modules:

| Module | Use Case |
|---|---|
| `json` | Parse and serialize JSON strings |
| `datetime` | Date and time manipulation |
| `re` | Regular expressions |
| `math` | Mathematical functions |
| `hashlib` | Hashing (MD5, SHA256) |
| `base64` | Base64 encoding/decoding |
| `urllib.parse` | URL parsing and encoding |
| `collections` | Counter, defaultdict, OrderedDict |
| `itertools` | Iteration utilities |
| `uuid` | Generate UUIDs |
| `html` | HTML escaping |
| `textwrap` | Text wrapping and indentation |

## Common Transformations

### Map -- Transform Each Item

```python
return [
    {
        "json": {
            "id": item.json["id"],
            "displayName": f"{item.json['first_name']} {item.json['last_name']}",
            "email": item.json["email"].lower().strip(),
            "isActive": item.json["status"] == "active"
        }
    }
    for item in _input.all()
]
```

### Filter -- Keep Items Matching a Condition

```python
return [
    item
    for item in _input.all()
    if item.json.get("amount", 0) > 100
    and item.json.get("status") == "completed"
]
```

### Group By

```python
from collections import defaultdict

groups = defaultdict(list)
for item in _input.all():
    key = item.json["category"]
    groups[key].append(item.json)

return [
    {
        "json": {
            "category": category,
            "count": len(items),
            "totalAmount": sum(i.get("amount", 0) for i in items),
            "items": items
        }
    }
    for category, items in groups.items()
]
```

### Aggregate -- Summarize All Items

```python
items = _input.all()
amounts = [item.json.get("amount", 0) for item in items]

return [{
    "json": {
        "totalAmount": sum(amounts),
        "averageAmount": sum(amounts) / len(amounts) if amounts else 0,
        "minAmount": min(amounts) if amounts else 0,
        "maxAmount": max(amounts) if amounts else 0,
        "itemCount": len(items)
    }
}]
```

### Flatten Nested Arrays

```python
# Input: [{"json": {"orders": [{"id": 1}, {"id": 2}]}}]
# Output: [{"json": {"id": 1}}, {"json": {"id": 2}}]
return [
    {"json": order}
    for item in _input.all()
    for order in item.json.get("orders", [])
]
```

### Deduplicate

```python
seen = set()
unique = []
for item in _input.all():
    key = item.json["email"].lower()
    if key not in seen:
        seen.add(key)
        unique.append(item)
return unique
```

### Sort

```python
from datetime import datetime

items = list(_input.all())
items.sort(
    key=lambda x: datetime.fromisoformat(x.json["createdAt"].replace("Z", "+00:00")),
    reverse=True
)
return items
```

## Date Handling with datetime

```python
from datetime import datetime, timedelta, timezone

# Current time (UTC)
now = datetime.now(timezone.utc)

# Parse ISO format
date = datetime.fromisoformat("2026-03-23T10:30:00+00:00")

# Parse custom format
date = datetime.strptime("23/03/2026", "%d/%m/%Y")

# Format
formatted = now.strftime("%Y-%m-%d")          # "2026-03-23"
human = now.strftime("%B %d, %Y")             # "March 23, 2026"
iso = now.isoformat()                          # "2026-03-23T10:30:00+00:00"

# Arithmetic
yesterday = now - timedelta(days=1)
next_week = now + timedelta(weeks=1)
hours_ago = now - timedelta(hours=6)

# Compare
is_future = date > now
days_diff = (date - now).days

# Start/end of day
start_of_day = now.replace(hour=0, minute=0, second=0, microsecond=0)
end_of_day = now.replace(hour=23, minute=59, second=59, microsecond=999999)

# Business hours check
hour = now.hour
is_business_hours = 9 <= hour < 18
is_weekday = now.weekday() < 5  # 0=Mon, 6=Sun
```

## Text Processing

### Regex Operations

```python
import re

text = _input.first().json["content"]

# Extract email addresses
emails = re.findall(r'[\w.-]+@[\w.-]+\.\w+', text)

# Extract numbers
numbers = [int(n) for n in re.findall(r'\d+', text)]

# Replace patterns
cleaned = re.sub(r'<[^>]*>', '', text)  # strip HTML tags
masked = re.sub(r'(\d{3})\d{4}(\d{3})', r'\1****\2', phone)

# Split on multiple delimiters
parts = re.split(r'[,;\s]+', text)

# Validate format
is_valid_email = bool(re.match(r'^[\w.-]+@[\w.-]+\.\w+$', email))
```

### String Manipulation

```python
import unicodedata

# Slug generation
def slugify(text):
    text = unicodedata.normalize('NFD', text)
    text = text.encode('ascii', 'ignore').decode('ascii')
    text = re.sub(r'[^a-z0-9]+', '-', text.lower())
    return text.strip('-')

# Truncate
def truncate(text, max_length=100):
    if len(text) <= max_length:
        return text
    return text[:max_length - 3] + "..."

# Title case with exceptions
def title_case(text):
    exceptions = {'of', 'the', 'and', 'in', 'on', 'at', 'to', 'for'}
    words = text.lower().split()
    return ' '.join(
        w if i > 0 and w in exceptions else w.capitalize()
        for i, w in enumerate(words)
    )

# Clean whitespace
cleaned = ' '.join(text.split())  # collapse multiple spaces
```

## API Calls with urllib

```python
import urllib.request
import urllib.parse
import json

# GET request
url = "https://api.example.com/users"
headers = {
    "Authorization": f"Bearer {_input.first().json['token']}",
    "Content-Type": "application/json"
}

req = urllib.request.Request(url, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        return [{"json": user} for user in data["users"]]
except urllib.error.HTTPError as e:
    return [{"json": {"error": f"HTTP {e.code}", "message": e.read().decode()}}]
except urllib.error.URLError as e:
    return [{"json": {"error": "connection_error", "message": str(e.reason)}}]
```

```python
# POST request
url = "https://api.example.com/orders"
payload = json.dumps({
    "customerId": _input.first().json["customerId"],
    "items": _input.first().json["items"]
}).encode()

req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
try:
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode())
        return [{"json": result}]
except urllib.error.HTTPError as e:
    error_body = e.read().decode()
    return [{"json": {"error": f"HTTP {e.code}", "body": error_body}}]
```

## Error Handling

```python
# Structured error handling
try:
    items = _input.all()

    if not items:
        raise ValueError("No input items received")

    results = []
    for item in items:
        # Validate required fields
        required = ["email", "name", "amount"]
        missing = [f for f in required if f not in item.json or item.json[f] is None]
        if missing:
            results.append({
                "json": {
                    "success": False,
                    "error": f"Missing fields: {', '.join(missing)}",
                    "original": item.json
                }
            })
            continue

        # Process valid item
        results.append({
            "json": {
                "success": True,
                "data": transform(item.json)
            }
        })

    return results

except Exception as e:
    return [{
        "json": {
            "success": False,
            "error": str(e),
            "errorType": type(e).__name__
        }
    }]
```

## Limitations

1. **No pip install**: You cannot install external packages. Only the standard library is available.
2. **No pandas/numpy**: These are not included. Use built-in list and dict operations instead.
3. **Limited HTTP**: Use `urllib` for HTTP calls. No `requests` library.
4. **No file system access**: You cannot read/write files on the n8n server.
5. **No $workflow.staticData**: Persistent state between executions is not directly accessible from Python. Use a database or pass via input.
6. **No Luxon**: Date handling must use Python's `datetime` module.
7. **Memory limits**: Same as JavaScript -- large datasets may cause out-of-memory errors.
8. **Execution timeout**: Long-running Python code may be terminated.

### When to Use External API + Webhook Instead

If your Python logic requires:
- External packages (pandas, scikit-learn, beautifulsoup)
- GPU computing
- Large file processing
- Long-running tasks (minutes)

Then deploy the Python code as a separate API (FastAPI, Flask) and call it from n8n via HTTP Request node or webhook.

## Practical Examples

### Data Cleaning Pipeline

```python
import re
from datetime import datetime

def clean_record(record):
    return {
        "name": ' '.join(record.get("name", "").split()).title(),
        "email": record.get("email", "").lower().strip(),
        "phone": re.sub(r'[^\d+]', '', record.get("phone", "")),
        "amount": float(record.get("amount", 0)),
        "date": datetime.strptime(
            record["date"], "%m/%d/%Y"
        ).strftime("%Y-%m-%d") if record.get("date") else None,
        "tags": [
            t.strip().lower()
            for t in record.get("tags", "").split(",")
            if t.strip()
        ]
    }

return [
    {"json": clean_record(item.json)}
    for item in _input.all()
]
```

### Generate Summary Statistics

```python
from collections import Counter
from datetime import datetime

items = [item.json for item in _input.all()]

# Status distribution
status_counts = Counter(i.get("status") for i in items)

# Revenue by category
revenue_by_cat = {}
for item in items:
    cat = item.get("category", "uncategorized")
    revenue_by_cat[cat] = revenue_by_cat.get(cat, 0) + item.get("amount", 0)

# Time analysis
dates = [
    datetime.fromisoformat(i["createdAt"].replace("Z", "+00:00"))
    for i in items if i.get("createdAt")
]
date_range = (max(dates) - min(dates)).days if dates else 0

return [{
    "json": {
        "totalRecords": len(items),
        "statusDistribution": dict(status_counts),
        "revenueByCategory": revenue_by_cat,
        "totalRevenue": sum(revenue_by_cat.values()),
        "dateRangeDays": date_range,
        "generatedAt": datetime.utcnow().isoformat()
    }
}]
```

### Build Markdown Report

```python
items = _input.all()
total = sum(item.json.get("amount", 0) for item in items)

lines = [
    "# Weekly Sales Report",
    "",
    f"**Period:** {_input.first().json.get('periodStart', 'N/A')} to {_input.first().json.get('periodEnd', 'N/A')}",
    f"**Total Revenue:** ${total:,.2f}",
    f"**Total Orders:** {len(items)}",
    f"**Average Order:** ${total / len(items):,.2f}" if items else "",
    "",
    "## Top Orders",
    "",
    "| Customer | Amount | Status |",
    "|---|---|---|",
]

sorted_items = sorted(items, key=lambda x: x.json.get("amount", 0), reverse=True)
for item in sorted_items[:10]:
    d = item.json
    lines.append(f"| {d.get('customer', 'N/A')} | ${d.get('amount', 0):,.2f} | {d.get('status', 'N/A')} |")

return [{"json": {"report": '\n'.join(lines)}}]
```

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
