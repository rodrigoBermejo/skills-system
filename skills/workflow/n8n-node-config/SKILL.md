# n8n Node Configuration Guide

**Scope:** workflow
**Trigger:** when configuring specific n8n nodes, setting up webhooks, HTTP requests, database operations, merge logic, AI agents, or debugging node-specific issues
**Tools:** mcp__claude_ai_n8n__get_workflow_details, mcp__claude_ai_n8n__search_workflows, bash, file_read
**Version:** 1.0.0

---

## Purpose

This skill provides per-node configuration guides for the most commonly used n8n nodes. Each section covers key parameters, common configurations, and gotchas. Use this as a quick reference when building or debugging workflows.

---

## Webhook Node

Receives incoming HTTP requests to trigger a workflow.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| HTTP Method | GET, POST, PUT, DELETE, PATCH, HEAD | POST is most common for receiving data |
| Path | Custom URL path | Appended to n8n base URL: `https://n8n.example.com/webhook/your-path` |
| Authentication | None, Basic Auth, Header Auth | Always use auth in production |
| Response Mode | Immediately, When Last Node Finishes | Affects caller timeout behavior |
| Response Code | 200, 201, 202, etc. | 202 for async processing, 200 for sync |
| Response Data | First Entry JSON, All Entries JSON, No Response Body | Match caller expectations |

### Common Configurations

**Sync API endpoint** (caller waits for result):
- Response Mode: When Last Node Finishes
- Response Code: 200
- Response Data: First Entry JSON

**Async receiver** (caller gets immediate acknowledgment):
- Response Mode: Immediately
- Response Code: 202
- Response Data: No Response Body (or `{"status": "accepted"}`)

**With authentication**:
- Authentication: Header Auth
- Header Name: `X-API-Key`
- Header Value: stored in n8n credentials

### Gotchas

- The webhook URL changes between test and production mode. Test mode uses `/webhook-test/`, production uses `/webhook/`.
- If "Response Mode" is "When Last Node Finishes" and the workflow takes too long, the caller may timeout.
- Binary data (file uploads) requires configuring the "Binary Property" option.
- Rate limiting is not built in -- implement it in your workflow or at the reverse proxy level.

---

## HTTP Request Node

Makes outbound HTTP requests to external APIs.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Method | GET, POST, PUT, PATCH, DELETE, HEAD | Match the API specification |
| URL | Full URL or expression | Use `$env` for base URLs |
| Authentication | Predefined Credential, Generic, None | Use predefined for managed services |
| Send Body | JSON, Form-Urlencoded, Form-Data, Raw | JSON is most common |
| Send Query Parameters | Key-value pairs | Automatically URL-encoded |
| Send Headers | Key-value pairs | Add custom headers here |

### Common Configurations

**REST API call with bearer token**:
- Authentication: Predefined Credential Type > Header Auth
- Method: GET
- URL: `{{ $env.API_URL }}/api/v1/users`

**POST with JSON body**:
- Method: POST
- Body Content Type: JSON
- Specify Body: Using Fields Below (or JSON expression)

**Pagination** (Options section):
- Pagination Mode: Response Contains Next URL / Offset-Based
- Max Pages: set a limit to prevent infinite loops

**Binary response** (downloading files):
- Options > Response Format: File
- Output the binary to a named property

### Retry on Failure

In Options:
- Retry On Fail: true
- Max Tries: 3
- Wait Between Tries: 1000 (ms)
- Only retry on specific status codes (429, 500, 502, 503)

### Gotchas

- URL encoding: special characters in query params must be encoded. Use expressions with `encodeURIComponent()`.
- Large responses may hit memory limits. Use streaming or pagination for large datasets.
- Self-signed certificates: set "Allow Unauthorized Certs" in options (dev only).
- Timeout: default is 300 seconds. Adjust in Options > Timeout for slow APIs.

---

## Postgres Node

Interacts with PostgreSQL databases.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Operation | Select, Insert, Update, Upsert, Delete, Execute Query | Choose based on the action needed |
| Schema | public (default) | Change if using custom schemas |
| Table | Table name | Required for all operations except Execute Query |
| Columns | Field mapping | Map n8n fields to database columns |

### Common Configurations

**Select with filter**:
- Operation: Select
- Return All: false
- Limit: 100
- Where conditions via Options > Where Clauses

**Insert**:
- Operation: Insert
- Columns: map fields from previous node
- Options > On Conflict: Do Nothing (for idempotency)

**Upsert** (insert or update):
- Operation: Upsert
- Columns: all fields to set
- Conflict columns: the unique key(s) to match on

**Execute Query** (custom SQL):
- Operation: Execute Query
- Query: parameterized SQL with `$1`, `$2` placeholders
- Query Parameters: array of values (prevents SQL injection)

```sql
-- Parameterized query example
SELECT * FROM users WHERE email = $1 AND status = $2
-- Parameters: {{ [$json.email, 'active'] }}
```

### Gotchas

- Always use parameterized queries in Execute Query mode. Never concatenate user input into SQL strings.
- Connection pooling: n8n manages connections. Avoid opening too many concurrent executions against the same database.
- Large result sets: use LIMIT and pagination. Fetching millions of rows will crash the workflow.
- Timestamps: PostgreSQL timestamps are in UTC. Convert to the desired timezone in n8n, not in the query.
- NULL handling: n8n sends JavaScript `null` as SQL NULL. Empty strings are not NULL.

---

## Set Node

Adds, modifies, or removes fields from items.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Mode | Manual Mapping, JSON | Manual for simple changes, JSON for complex restructuring |
| Fields | Name, Type, Value | Each field can be a fixed value or expression |
| Keep Only Set | true/false | If true, removes all fields not explicitly set |

### Common Configurations

**Add new fields** (keep existing):
- Keep Only Set: false
- Add fields with expressions referencing previous data

**Reshape data** (new structure):
- Keep Only Set: true
- Define all fields for the new structure

**Remove sensitive fields**:
- Keep Only Set: true
- Include only the fields you want to pass forward (exclude passwords, tokens)

### Gotchas

- "Keep Only Set" is destructive -- it drops all fields not listed. Double-check before enabling.
- Type coercion: setting a field as "Number" will fail if the expression returns a string. Convert explicitly.
- Empty values: setting a field to an empty string is different from not setting it.

---

## If Node

Conditional branching with two outputs: true and false.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Conditions | Value 1, Operation, Value 2 | Multiple conditions supported |
| Combine | AND, OR | How multiple conditions are evaluated |

### Common Configurations

**Check field exists and has value**:
- Value 1: `{{ $json.email }}`
- Operation: Is Not Empty

**Numeric comparison**:
- Value 1: `{{ $json.amount }}`
- Operation: Larger Than
- Value 2: `100`

**String matching**:
- Value 1: `{{ $json.status }}`
- Operation: Equal
- Value 2: `active`

**Multiple conditions (AND)**:
- Combine: AND
- Condition 1: status equals "active"
- Condition 2: amount greater than 0
- Condition 3: email is not empty

### Naming Convention

Name If nodes as questions:
- `Is Premium User?`
- `Has Valid Email?`
- `Is Error Response?`
- `Needs Approval?`

### Gotchas

- Type matters: comparing string `"100"` with number `100` may give unexpected results. Use explicit type conversion.
- Undefined vs null vs empty string: these are different. "Is Not Empty" catches empty strings but not null.
- The "true" output is the top connection, "false" is the bottom. Label them with sticky notes if ambiguous.

---

## Switch Node

Multi-branch routing based on conditions.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Mode | Rules, Expression | Rules for visual config, Expression for complex logic |
| Routing Rules | Conditions per output | Each output has its own condition |
| Fallback | Output index | Where items go if no rule matches |

### Common Configurations

**Route by status**:
- Rule 0: `$json.status` equals `"new"` -> Output 0
- Rule 1: `$json.status` equals `"in_progress"` -> Output 1
- Rule 2: `$json.status` equals `"completed"` -> Output 2
- Fallback: Output 3 (unknown status)

**Route by event type** (webhooks):
- Rule 0: `$json.event` equals `"payment.completed"`
- Rule 1: `$json.event` equals `"customer.created"`
- Rule 2: `$json.event` equals `"invoice.sent"`
- Fallback: log unknown event

### Naming Convention

Name Switch nodes as categories:
- `Route by Status`
- `Route by Event Type`
- `Route by Priority`

### Gotchas

- Items that match the first rule go to that output only -- subsequent rules are not evaluated for that item.
- Always configure a fallback to avoid silently dropping items.
- Order matters for performance: put the most frequently matched rule first.

---

## Merge Node

Combines data from multiple branches.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Mode | Append, Combine by Position, Combine by Field, Keep Key Matches, Remove Key Matches, Multiplex | Choose based on how data should be combined |

### Common Configurations

**Append** (concatenate items from both inputs):
- Mode: Append
- All items from Input 1 followed by all items from Input 2

**Combine by Field** (SQL JOIN equivalent):
- Mode: Combine by Field
- Input 1 Field: `email`
- Input 2 Field: `user_email`
- Outputs items that match on the specified fields

**Keep Key Matches** (INNER JOIN):
- Mode: Keep Key Matches
- Only outputs items where the key exists in both inputs

**Combine by Position** (zip):
- Mode: Combine by Position
- Pairs items 1:1 by index. If inputs have different lengths, extra items are dropped.

**Multiplex** (cross join):
- Mode: Multiplex
- Every item from Input 1 paired with every item from Input 2
- Warning: N x M items generated

### Gotchas

- The Merge node requires both inputs to have data before executing. If one branch produces no items, the Merge node may not fire (depending on mode).
- "Combine by Field" is case-sensitive by default.
- Large datasets with Multiplex can cause memory issues (1000 x 1000 = 1,000,000 items).
- Timing: both branches must complete before the Merge node executes.

---

## Split In Batches Node

Processes items in chunks.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Batch Size | Number | How many items per batch |
| Options > Reset | true/false | Whether to reset the batch counter |

### Common Configurations

**Process items one by one**:
- Batch Size: 1
- Connect output back to the processing chain, then back to Split In Batches

**Process in chunks of 50**:
- Batch Size: 50
- Add a Wait node after processing to respect rate limits

### Flow Structure

```
[Split In Batches] --> [Process Batch] --> [Wait 1s] --> [Loop back to Split In Batches]
                  |
                  +--> Done output (all batches processed)
```

### Gotchas

- The "Done" output fires after ALL batches are processed. Connect post-processing logic there.
- All items are loaded into memory at the start -- the batching is for processing, not memory optimization.
- If the workflow fails mid-batch, there is no built-in resume. Track progress externally.
- Do not modify the items array during processing -- it can break the batch counter.

---

## Wait Node

Pauses workflow execution.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Resume | After Time Interval, At Specified Time, On Webhook Call | How the workflow resumes |

### Common Configurations

**Fixed delay**:
- Resume: After Time Interval
- Amount: 5
- Unit: Seconds

**Wait for approval** (human-in-the-loop):
- Resume: On Webhook Call
- Use `$execution.resumeUrl` in the notification message
- Set a timeout in Options (e.g., 48 hours)

**Wait until specific time**:
- Resume: At Specified Time
- Date & Time: expression or fixed value

### Gotchas

- Paused executions consume memory/resources on the n8n instance.
- If n8n restarts, paused executions should resume (verify in your deployment).
- The resume webhook URL is single-use.
- Long waits (days) should use "On Webhook Call" mode, not "After Time Interval".

---

## Error Trigger Node

Catches errors from other workflows.

### Configuration

1. Create a dedicated workflow with Error Trigger as the start node.
2. In your main workflows, go to Settings > Error Workflow and select this error handling workflow.
3. The Error Trigger receives: workflow name, node name, error message, execution ID, timestamp.

### Common Pattern

```
[Error Trigger]
    |
[Set: Format Error Message] --> extract relevant fields
    |
[Slack: Send Alert] --> post to #alerts channel
    |
[Postgres: Log Error] --> insert into error_log table
```

### Gotchas

- The Error Trigger workflow itself should not have complex logic that might fail (keep it simple).
- If the Error Trigger workflow fails, there is no further escalation built in.
- Manual test executions do not trigger the Error Workflow by default.
- One Error Workflow can serve multiple main workflows.

---

## Execute Workflow (Sub-Workflow) Node

Calls another workflow as a sub-routine.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Source | Database (by ID), Parameter (by ID), URL | Database is most common |
| Workflow ID | ID or expression | Reference the sub-workflow |
| Mode | Wait for Sub-Workflow to Complete, Execute and Continue | Wait is default |

### Common Configurations

**Call sub-workflow and use result**:
- Mode: Wait for Sub-Workflow to Complete
- Pass input data via the node's input

**Fire-and-forget**:
- Mode: Execute and Continue (do not wait)
- Useful for async tasks like sending notifications

### Gotchas

- Data passed to sub-workflows is limited by memory. Pass IDs, not large payloads.
- Errors in sub-workflows propagate to the parent if in "Wait" mode.
- Circular references (A calls B, B calls A) will cause infinite loops.
- The sub-workflow must have an Execute Workflow Trigger or Manual Trigger as its start node.

---

## Schedule Trigger Node

Runs a workflow on a schedule.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Rule Type | Interval, Cron Expression | Interval for simple, Cron for complex |
| Interval | Every X minutes/hours/days | Minimum: 1 minute |
| Cron Expression | Standard cron format | 5 fields: minute hour day month weekday |

### Common Cron Expressions

| Expression | Meaning |
|---|---|
| `0 9 * * 1-5` | Every weekday at 9:00 AM |
| `*/15 * * * *` | Every 15 minutes |
| `0 0 * * *` | Every day at midnight |
| `0 0 1 * *` | First day of every month at midnight |
| `0 */2 * * *` | Every 2 hours |
| `30 8 * * 1` | Every Monday at 8:30 AM |

### Gotchas

- Timezone: the cron runs in the n8n instance's configured timezone. Set it explicitly in workflow settings.
- Overlapping executions: if a scheduled run takes longer than the interval, the next run starts anyway (parallel). Use workflow settings to disable overlap.
- n8n cloud has minimum interval limits. Self-hosted can run as frequently as needed.

---

## AI Agent Node

Orchestrates an LLM with tools, memory, and a system prompt.

### Key Parameters

| Parameter | Options | Notes |
|---|---|---|
| Agent Type | Tools Agent, OpenAI Functions Agent, ReAct Agent | Tools Agent is most common |
| Model | Connected LLM node | GPT-4, Claude, etc. |
| System Message | Text or expression | Define the agent's behavior |
| Max Iterations | Number | Prevent infinite loops (default: 10) |

### Common Configurations

**Basic agent with tools**:
- Connect an LLM model (e.g., OpenAI Chat Model)
- Connect tool nodes (HTTP Request Tool, Code Tool, etc.)
- Set System Message with role, instructions, and constraints
- Max Iterations: 10
- Return Intermediate Steps: true (for debugging)

**Agent with memory**:
- Connect a Memory node (Window Buffer Memory, Postgres Chat Memory)
- Set memory context window size

### System Prompt Best Practices

```
# Role
You are a [specific role] that [specific purpose].

# Instructions
1. [First instruction]
2. [Second instruction]

# Constraints
- Never [constraint]
- Always [constraint]

# Output Format
Respond in [format specification].
```

### Gotchas

- Always set `maxIterations` to prevent runaway agents.
- Set a timeout for the workflow to catch agents that get stuck in loops.
- Tool descriptions affect agent behavior significantly -- make them precise.
- Monitor token usage: agents can consume many tokens in multi-step reasoning.
- Test with prompt injection attacks before deploying customer-facing agents.
- Memory nodes persist conversation -- ensure cleanup for privacy.

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
