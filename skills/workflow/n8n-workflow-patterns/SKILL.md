# n8n Workflow Patterns

**Scope:** workflow
**Trigger:** when designing n8n workflow architecture, choosing between patterns, or building complex multi-step automations
**Tools:** mcp__claude_ai_n8n__search_workflows, mcp__claude_ai_n8n__get_workflow_details, mcp__claude_ai_n8n__execute_workflow
**Version:** 1.0.0

---

## Purpose

This skill catalogs the most common architectural patterns for n8n workflows. Each pattern includes when to use it, a structural overview, implementation notes, gotchas, and a practical example. Use this as a reference when designing new workflows or refactoring existing ones.

## Pattern Index

1. Fan-Out / Fan-In
2. Polling
3. Retry with Exponential Backoff
4. Error-First (Fail Fast)
5. Sub-Workflow Composition
6. Queue (Webhook + Worker)
7. Batch Processing
8. Event-Driven Routing
9. Human-in-the-Loop
10. Idempotency

---

## 1. Fan-Out / Fan-In Pattern

### When to Use
- You have a list of items that each need independent processing.
- Processing can happen in parallel (no item depends on another).
- You need to aggregate results after all items are processed.

### Structure

```
[Trigger]
    |
[Get Items] --> returns N items
    |
[Split In Batches] --> processes items individually
    |
[Process Single Item] --> API call, transform, enrich
    |
[Merge Results] --> aggregate back into a single dataset
    |
[Output] --> store, send, or return
```

### Implementation Notes

- Use the Split In Batches node to iterate through items.
- Each item passes through the processing branch individually.
- After processing, use the Merge node in "Append" mode to collect results.
- For true parallel execution, use multiple branches from the trigger and Merge with "Wait for All".

### Gotchas

- n8n processes items sequentially within a single execution (not truly parallel threads).
- If one item fails with "Continue On Fail" disabled, the entire batch stops.
- Memory usage scales with the number of items -- monitor for large datasets.
- Rate limits on external APIs can cause failures at scale; add Wait nodes.

### Example: Enrich a List of Contacts

```
[Schedule Trigger] --> daily at 9 AM
    |
[Postgres: Fetch New Contacts] --> SELECT * WHERE enriched = false
    |
[Split In Batches] --> batch size 1
    |
[HTTP Request: Call Clearbit API] --> enrich each contact
    |
[Set: Map Enriched Fields]
    |
[Postgres: Update Contact] --> SET enriched = true
    |
[Aggregate: Count Processed]
    |
[Slack: Send Summary] --> "Enriched 47 contacts today"
```

---

## 2. Polling Pattern

### When to Use
- The source system does not support webhooks.
- You need to detect new or changed records periodically.
- You want to process changes in near-real-time without event infrastructure.

### Structure

```
[Schedule Trigger] --> every 5 minutes
    |
[Fetch Records] --> GET from API with since_timestamp or cursor
    |
[Filter: New Items Only] --> compare with last known state
    |
[Process New Items]
    |
[Update Cursor] --> store last processed ID or timestamp
```

### Implementation Notes

- Store the cursor (last processed timestamp or ID) in a database, n8n static data, or a Set node with workflow static data.
- Use `$workflow.staticData` to persist state between executions without an external store.
- Set the polling interval based on how quickly you need to detect changes and API rate limits.

### Gotchas

- If the workflow fails before updating the cursor, you may reprocess items (ensure idempotency).
- Polling too frequently wastes resources and may hit rate limits.
- Polling too infrequently may miss items if the source has a limited history window.
- Clock drift between systems can cause items to be missed or duplicated.

### Example: Poll a REST API for New Orders

```
[Schedule Trigger] --> every 2 minutes
    |
[Code: Get Last Cursor] --> $workflow.staticData.lastOrderId || 0
    |
[HTTP Request: GET /api/orders?since_id={{cursor}}]
    |
[If: Has New Orders?] --> $json.orders.length > 0
    |
  True: [Split In Batches] --> process each order
    |     |
    |   [HTTP Request: POST to Fulfillment API]
    |     |
    |   [Code: Update Cursor] --> $workflow.staticData.lastOrderId = lastId
    |
  False: [No Operation] --> skip
```

---

## 3. Retry with Exponential Backoff

### When to Use
- External API calls may fail due to transient errors (429, 500, 503).
- You want automatic recovery without manual intervention.
- The failure is likely temporary and will resolve on its own.

### Structure

```
[Action Node] --> with "Continue On Fail" enabled
    |
[If: Has Error?]
    |
  True: [Code: Calculate Backoff] --> attempt * 2 seconds
    |     |
    |   [If: Max Retries Reached?]
    |     |
    |   False: [Wait] --> dynamic delay
    |     |     |
    |     |   [Loop back to Action Node]
    |     |
    |   True: [Send Error Notification]
    |
  False: [Continue Normal Flow]
```

### Implementation Notes

- Built-in retry: Many nodes (HTTP Request, Postgres) have a "Retry On Fail" setting in their options. Use this first before building custom retry logic.
- Custom retry: Use a Code node to track attempt count in `$workflow.staticData` and calculate backoff delay.
- Backoff formula: `delay = baseDelay * Math.pow(2, attemptNumber)` with a cap (e.g., 60 seconds max).

### Gotchas

- Always set a maximum retry count (3-5) to avoid infinite loops.
- Distinguish between retryable errors (429, 500, 503, ECONNRESET) and permanent errors (400, 401, 404).
- Reset retry counters after a successful attempt.
- Log each retry attempt for debugging.

### Example: HTTP Request with Custom Retry

```javascript
// Code node: Calculate Backoff
const maxRetries = 3;
const baseDelay = 2; // seconds
const attempt = $workflow.staticData.retryAttempt || 0;

if ($json.error && attempt < maxRetries) {
  $workflow.staticData.retryAttempt = attempt + 1;
  const delay = baseDelay * Math.pow(2, attempt);
  return [{ json: { retry: true, delay, attempt: attempt + 1 } }];
} else if ($json.error) {
  $workflow.staticData.retryAttempt = 0;
  return [{ json: { retry: false, error: $json.error, exhausted: true } }];
} else {
  $workflow.staticData.retryAttempt = 0;
  return [{ json: { retry: false, success: true, data: $json } }];
}
```

---

## 4. Error-First Pattern (Fail Fast)

### When to Use
- The workflow depends on preconditions (valid input, available service, correct permissions).
- You want to catch problems early before expensive operations.
- Clear error messages are more important than partial execution.

### Structure

```
[Trigger]
    |
[Validate Input] --> check required fields, formats, types
    |
[If: Valid?]
    |
  False: [Set: Error Response] --> clear error message
    |     |
    |   [Respond to Webhook] --> 400 Bad Request
    |
  True: [Check Service Health] --> ping external API
    |
  [If: Service Available?]
    |
    False: [Set: Error Response] --> "Service unavailable"
      |     |
      |   [Respond to Webhook] --> 503
      |
    True: [Process Request] --> main logic starts here
```

### Implementation Notes

- Place all validation at the beginning of the workflow, before any external calls.
- Return specific error messages: "Field 'email' is required" not "Validation failed".
- For webhook workflows, always respond with appropriate HTTP status codes.
- Use the Switch node for multi-condition validation routing.

### Gotchas

- Do not validate inside the processing loop -- validate once upfront.
- Remember to handle both missing fields and wrong types (string vs number).
- For AI agent workflows, validate the prompt length and format before sending to the LLM.
- Validation errors should not trigger the Error Trigger workflow (they are expected).

---

## 5. Sub-Workflow Composition

### When to Use
- A block of logic appears in multiple workflows.
- A single workflow exceeds 20-25 nodes and becomes hard to read.
- Different team members own different parts of the process.
- You want to test components independently.

### Structure

```
[Main Workflow]
    |
[Execute Workflow: Validate Input]  --> sub-workflow 1
    |
[Execute Workflow: Enrich Data]     --> sub-workflow 2
    |
[Execute Workflow: Send Notifications] --> sub-workflow 3
    |
[Set: Final Response]
```

### Implementation Notes

- Pass data to sub-workflows via the Execute Workflow node's input.
- Sub-workflows receive data in their Manual Trigger or Execute Workflow Trigger node.
- Sub-workflows return data via their last node's output.
- Name sub-workflows with `[Sub]` prefix: `[Sub] Validate Contact Data`.
- Document the input/output contract with a Sticky Note at the start of each sub-workflow.

### Gotchas

- Sub-workflow calls are synchronous by default -- the parent waits for the child to complete.
- Error handling: errors in sub-workflows propagate to the parent unless caught.
- Credential access: sub-workflows need their own credential references.
- Avoid deep nesting: main -> sub -> sub -> sub becomes hard to debug (max 2-3 levels).
- Data size: large payloads passed between workflows consume memory; pass IDs instead of full objects when possible.

---

## 6. Queue Pattern (Webhook + Worker)

### When to Use
- You need to decouple ingestion from processing.
- The processing step is slow or resource-intensive.
- You want to respond to the caller immediately, then process in the background.
- You need to handle bursts of traffic without overwhelming downstream services.

### Structure

```
Workflow 1: Receiver
[Webhook Trigger] --> receives request
    |
[Respond to Webhook] --> 202 Accepted (immediately)
    |
[Postgres: Insert Into Queue Table] --> store payload

Workflow 2: Worker
[Schedule Trigger] --> every 30 seconds
    |
[Postgres: Fetch Pending Items] --> SELECT ... WHERE status = 'pending' LIMIT 10
    |
[If: Has Items?]
    |
  True: [Split In Batches]
    |     |
    |   [Process Item]
    |     |
    |   [Postgres: Update Status] --> SET status = 'completed'
    |
  False: [No Operation]
```

### Implementation Notes

- The queue table should have: id, payload (JSONB), status, created_at, processed_at, error_message.
- Use `SELECT ... FOR UPDATE SKIP LOCKED` to prevent concurrent workers from picking the same item.
- Set a maximum processing time and mark stale items as "failed" for retry.

### Gotchas

- Without proper locking, duplicate processing can occur with multiple workers.
- Monitor queue depth -- if it grows continuously, your worker is too slow.
- Add a dead letter mechanism: after N failed attempts, move the item to a "dead" status and alert.
- Clean up completed items periodically to prevent table bloat.

---

## 7. Batch Processing

### When to Use
- You have a large dataset that cannot be processed in a single execution.
- API rate limits require you to process items in chunks.
- Memory constraints prevent loading all items at once.
- You need progress tracking for long-running processes.

### Structure

```
[Trigger]
    |
[Fetch All IDs] --> lightweight query, just IDs
    |
[Split In Batches] --> batch size 50
    |
[Fetch Batch Details] --> load full data for this batch only
    |
[Process Batch]
    |
[Wait] --> respect rate limits between batches
    |
[Loop back to Split In Batches]
    |
[Aggregate Results]
    |
[Send Summary Report]
```

### Implementation Notes

- Choose batch size based on API rate limits and memory constraints.
- Add a Wait node between batches to respect rate limits (e.g., 1 second per batch of 50).
- Track progress using `$workflow.staticData` or a database.
- For very large datasets (100K+ items), consider splitting across multiple scheduled executions.

### Gotchas

- The Split In Batches node processes all items in a single execution -- it does not create separate executions.
- If the workflow fails mid-batch, you need a way to resume from where it stopped.
- Memory usage: even with batching, all items are loaded into memory initially. Fetch only IDs first.
- Execution timeout: long-running workflows may hit n8n's execution timeout. Adjust in settings or split into multiple executions.

---

## 8. Event-Driven Routing

### When to Use
- A single webhook receives different types of events.
- You need to route each event type to different processing logic.
- The event source uses a single callback URL (e.g., Stripe webhooks, GitHub webhooks).

### Structure

```
[Webhook Trigger]
    |
[Switch: Route by Event Type] --> $json.event or $json.action
    |
  "payment.completed": [Process Payment]
  "payment.failed":    [Handle Failed Payment]
  "customer.created":  [Onboard Customer]
  "invoice.created":   [Generate Invoice]
  fallback:            [Log Unknown Event]
```

### Implementation Notes

- Use the Switch node with conditions matching the event type field.
- Always include a fallback/default branch for unknown event types.
- Log the raw event payload for debugging unknown events.
- Respond to the webhook immediately (200 OK) before processing to avoid timeout issues with the sender.

### Gotchas

- Webhook senders often retry on non-2xx responses, which can cause duplicate processing.
- Validate the webhook signature/secret to prevent spoofed events.
- Some services send the same event multiple times -- ensure idempotent processing.
- Order of Switch conditions matters for performance: put most frequent events first.

---

## 9. Human-in-the-Loop

### When to Use
- A decision requires human judgment (approve/reject, review content).
- Regulatory requirements mandate human approval before proceeding.
- AI-generated content needs review before publication.
- High-value operations (refunds, deletions) need authorization.

### Structure

```
[Trigger]
    |
[Process Data]
    |
[Send Approval Request] --> Slack, email, or custom form with unique approval URL
    |
[Wait] --> Wait node in "Resume on Webhook" mode
    |
[If: Approved?]
    |
  True: [Execute Approved Action]
    |
  False: [Send Rejection Notification]
```

### Implementation Notes

- The Wait node generates a unique resume URL that can be called to continue the workflow.
- Embed the resume URL in the approval message (Slack button, email link).
- Include both "Approve" and "Reject" URLs with different query parameters.
- Set a timeout on the Wait node: if no response within 48 hours, auto-reject or escalate.
- The workflow execution is paused (not polling) during the wait -- no resources consumed.

### Gotchas

- Paused executions count toward n8n's execution limit. Monitor and clean up stale ones.
- The resume URL is single-use -- clicking it twice will fail on the second click.
- If n8n restarts while an execution is paused, it should resume (verify in self-hosted setups).
- Include enough context in the approval message so the reviewer does not need to look elsewhere.
- Set expiration: do not let approvals wait indefinitely.

---

## 10. Idempotency Patterns

### When to Use
- The workflow may receive duplicate triggers (webhook retries, duplicate events).
- The workflow is processing items from a queue that might be dequeued twice.
- You need to guarantee that running the same input twice produces the same result without side effects.

### Structure

```
[Trigger]
    |
[Generate Idempotency Key] --> hash of unique fields (e.g., order_id + event_type)
    |
[Check: Already Processed?] --> lookup key in database or cache
    |
  Yes: [Skip] --> return 200 OK, do nothing
    |
  No: [Process Item]
      |
    [Store Idempotency Key] --> mark as processed
      |
    [Return Result]
```

### Implementation Notes

- The idempotency key should be derived from the input data, not generated randomly.
- Good key candidates: event ID, order ID, combination of entity ID + action + timestamp.
- Store processed keys in a database table with a TTL (e.g., keep for 7 days).
- For webhook-triggered workflows, many services include an event ID in the payload -- use it.

### Check-Before-Write Pattern

Before creating a record, check if it already exists:

```
[If: Record Exists?] --> query by unique identifier
    |
  True: [Update Existing Record] --> or skip entirely
    |
  False: [Create New Record]
```

### Deduplication Key Pattern

For batch processing, deduplicate before processing:

```
[Fetch Items]
    |
[Code: Remove Duplicates] --> filter by unique key
    |
[Process Unique Items]
```

```javascript
// Code node: Deduplicate by email
const seen = new Set();
const unique = [];
for (const item of $input.all()) {
  const key = item.json.email.toLowerCase();
  if (!seen.has(key)) {
    seen.add(key);
    unique.push(item);
  }
}
return unique;
```

### Gotchas

- Database-level unique constraints are the strongest guarantee -- application-level checks have race conditions.
- Use `INSERT ... ON CONFLICT DO NOTHING` (Postgres) for atomic check-and-write.
- TTL on idempotency keys: too short risks allowing duplicates, too long wastes storage.
- In distributed systems, idempotency must be at the database level, not in-memory.

---

## Choosing the Right Pattern

| Scenario | Pattern |
|---|---|
| Process a list of items independently | Fan-Out / Fan-In |
| Detect changes in a system without webhooks | Polling |
| Handle transient API failures | Retry with Backoff |
| Validate input before expensive operations | Error-First |
| Reuse logic across workflows | Sub-Workflow |
| Decouple fast ingestion from slow processing | Queue |
| Process large datasets respecting rate limits | Batch Processing |
| Route different event types from one source | Event-Driven Routing |
| Require human approval mid-workflow | Human-in-the-Loop |
| Prevent duplicate processing | Idempotency |

## Combining Patterns

Most production workflows combine multiple patterns. Common combinations:

- **Webhook + Error-First + Queue**: Validate input, respond immediately, queue for processing.
- **Polling + Batch + Idempotency**: Poll for changes, process in batches, skip already-processed items.
- **Fan-Out + Retry + Sub-Workflow**: Split items, process each with retry logic in a sub-workflow.
- **Event-Driven + Human-in-the-Loop**: Route events, require approval for high-risk actions.

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
