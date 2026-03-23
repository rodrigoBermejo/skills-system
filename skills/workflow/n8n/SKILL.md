# n8n - Workflow Automation Fundamentals

**Scope:** workflow
**Trigger:** when working with n8n, workflow automation, service integration, or AI agents in n8n
**Tools:** mcp__claude_ai_n8n__search_workflows, mcp__claude_ai_n8n__get_workflow_details, mcp__claude_ai_n8n__execute_workflow, bash, file_read, file_write
**Version:** 1.0.0

---

## Purpose

This skill provides the foundational knowledge and best practices for designing, building, testing, deploying, and monitoring automated workflows using n8n. It covers architecture decisions, naming conventions, credential management, error handling, and the full workflow lifecycle.

## When to Use This Skill

- Designing new automation workflows from scratch.
- Evaluating whether n8n is the right tool for an automation need.
- Establishing team conventions for n8n projects.
- Onboarding developers to n8n-based automation.
- Integrating AI agents and LLMs into workflows.
- Setting up error handling and monitoring for production workflows.

## What is n8n

n8n is an open-source workflow automation platform that connects services, APIs, and custom logic through a visual node-based editor. It runs as a Node.js application and can be self-hosted or used as a cloud service.

### When to Use n8n vs Custom Code

Use n8n when:
- The task is primarily connecting existing APIs and services.
- Visual representation of the flow aids understanding and maintenance.
- Non-developers need to understand or modify the automation.
- You need built-in credential management and retry logic.
- The workflow involves human-in-the-loop steps (wait, approval).
- Rapid prototyping of integrations is more valuable than raw performance.

Use custom code when:
- Sub-millisecond latency is required.
- The logic is purely computational with no external service calls.
- The data volume exceeds what n8n can handle in memory (millions of rows).
- You need fine-grained control over concurrency and threading.
- The automation is a core part of your application (not a side process).

## Workflow Lifecycle

### Phase 1 -- Design

Before opening the n8n editor:

1. Define the trigger: what event starts this workflow (webhook, schedule, manual, event).
2. Define the expected output: what should happen when the workflow completes.
3. Map external services: list every API, database, or service the workflow touches.
4. Identify failure modes: what can go wrong at each step.
5. Determine data volume: how many items will flow through per execution.
6. Decide on execution mode: one-off, scheduled, event-driven, or always-on.

### Phase 2 -- Build

1. Start with the trigger node.
2. Build the happy path first -- get data flowing end to end.
3. Add error handling after the happy path works.
4. Name every node descriptively (see naming conventions below).
5. Add sticky notes to explain non-obvious logic.
6. Use sub-workflows for reusable or complex sections.

### Phase 3 -- Test

1. Run manually with representative test data.
2. Test edge cases: empty arrays, null values, large payloads, special characters.
3. Test error paths: simulate API failures, invalid credentials, timeout scenarios.
4. Verify idempotency: running the same data twice should not cause duplicates.
5. Check rate limits: ensure the workflow respects API rate limits.

### Phase 4 -- Deploy

1. Export workflow JSON and store in version control.
2. Remove any hardcoded test data or debug nodes.
3. Verify all credentials point to production environment.
4. Activate the workflow.
5. Run a smoke test with known good data.

### Phase 5 -- Monitor

1. Set up the Error Trigger workflow to send notifications on failure.
2. Review execution logs periodically.
3. Monitor external service health (API status pages).
4. Track execution counts and durations for performance regression.
5. Audit credential expiration dates.

## Node Categories

### Trigger Nodes
Start a workflow execution. Only one trigger per workflow.
- **Webhook**: receives HTTP requests (POST, GET, PUT, DELETE).
- **Schedule Trigger**: runs on a cron schedule or interval.
- **Manual Trigger**: for testing or on-demand execution.
- **Event Triggers**: service-specific (e.g., Gmail Trigger, Slack Trigger).
- **Error Trigger**: fires when another workflow fails.

### Action Nodes
Perform operations on external services.
- **HTTP Request**: call any REST API.
- **Service nodes**: Gmail, Slack, Notion, Airtable, Postgres, etc.
- **Execute Workflow**: call a sub-workflow.

### Flow Control Nodes
Control execution logic.
- **If**: conditional branching (true/false).
- **Switch**: multi-branch routing based on conditions.
- **Merge**: combine data from multiple branches.
- **Split In Batches**: process items in chunks.
- **Wait**: pause execution (fixed time, webhook, or datetime).
- **Loop Over Items**: iterate through items with sub-logic.

### AI Nodes
Build AI-powered automations.
- **AI Agent**: orchestrates LLM with tools, memory, and system prompts.
- **LLM Chain**: simple prompt-response without tool use.
- **Embedding nodes**: generate vector embeddings.
- **Vector Store nodes**: store and retrieve from vector databases.
- **Memory nodes**: conversation memory for agents.
- **Tool nodes**: define tools the AI agent can call.

### Code Nodes
Custom logic when built-in nodes are insufficient.
- **Code (JavaScript)**: full Node.js environment with access to Luxon, lodash.
- **Code (Python)**: Python runtime for data transformation.
- See sibling skills `n8n-code-javascript` and `n8n-code-python` for details.

### Data Transformation Nodes
Reshape data between nodes.
- **Set**: add, modify, or remove fields.
- **Rename Keys**: rename JSON keys.
- **Item Lists**: sort, limit, summarize items.
- **Aggregate**: combine multiple items into one.
- **Date & Time**: parse, format, and manipulate dates.

## Credential Management

### Naming Convention

All credentials must follow this format:

```
[Service]_[Environment]_[Purpose]
```

Examples:
- `Postgres_Prod_MainDB`
- `OpenAI_Prod_AgentKey`
- `Slack_Dev_Notifications`
- `Gmail_Prod_SupportInbox`
- `Stripe_Staging_Payments`

### Rules

1. Never hardcode API keys, tokens, or passwords in Code nodes or expressions.
2. Always use the n8n credential system -- it encrypts secrets at rest.
3. Create separate credentials per environment (dev, staging, prod).
4. Document credential owners and expiration dates.
5. Rotate credentials on a schedule; update in n8n immediately after rotation.
6. Use environment variables (`$env.MY_VAR`) for non-secret configuration.
7. Restrict credential sharing to the workflows that need them.

## Error Handling Architecture

### Error Trigger Workflow

Every n8n instance must have a global error handling workflow:

1. Create a workflow with an Error Trigger node as the start.
2. Extract error details: workflow name, node name, error message, execution ID.
3. Send notification (Slack, email, PagerDuty) with actionable context.
4. Optionally log to a database for tracking and SLA metrics.

### Try/Catch Pattern

For critical sections within a workflow:

1. Enable "Continue On Fail" on the node that might fail.
2. After the node, add an If node to check for errors:
   - Condition: `{{ $json.error }}` is not empty.
3. True branch: handle the error (retry, log, notify).
4. False branch: continue normal execution.

### Retry Strategy

For transient failures (API rate limits, network issues):

1. Use the built-in retry option on HTTP Request nodes (Settings > Retry On Fail).
2. Set retry count (2-3 attempts) and wait interval (1-5 seconds).
3. For custom retry logic, use a loop with Wait node and exponential backoff.
4. Always set a maximum retry count to avoid infinite loops.

## Naming Conventions

### Workflow Names

Format: `[Domain] -- [Verb] [Object] ([Env])`

Examples:
- `Sales -- Sync New Leads (Prod)`
- `Support -- Classify Incoming Tickets (Prod)`
- `Marketing -- Send Weekly Newsletter (Staging)`
- `Internal -- Backup Database (Prod)`
- `Finance -- Generate Monthly Report (Prod)`

Rules:
- Domain maps to a business area or team.
- Verb is an action: Sync, Process, Send, Generate, Classify, Monitor, Backup.
- Object describes what is being acted upon.
- Environment in parentheses at the end.

### Node Names

Format: `[Verb] [Object]`

Examples:
- `Fetch New Orders`
- `Filter Active Users`
- `Send Slack Alert`
- `Transform API Response`
- `Check Duplicate`
- `Insert Into Postgres`

Rules:
- Every node must be renamed from its default (e.g., "HTTP Request" becomes "Fetch User Profile").
- Use present tense verbs.
- Be specific enough that someone can understand the workflow without opening each node.
- For If nodes, name them as questions: `Is Premium User?`
- For Switch nodes, name them as categories: `Route by Status`

## Sub-Workflows vs Monolithic Workflows

### When to Use Sub-Workflows

- A block of logic is reused across multiple workflows.
- The workflow exceeds 20-25 nodes (readability threshold).
- A section has independent error handling needs.
- Different team members own different parts of the logic.
- A section needs different execution settings (timeout, memory).

### When to Keep It as One Workflow

- The logic is linear with fewer than 15 nodes.
- There is no reuse potential.
- Data passing between sub-workflows adds unnecessary complexity.
- The workflow needs to be understood as a single unit.

### Sub-Workflow Guidelines

1. Name sub-workflows with a `[Sub]` prefix: `[Sub] Enrich Contact Data`.
2. Define clear input/output contracts.
3. Document expected input format in a Sticky Note at the start.
4. Return structured data, not raw API responses.
5. Handle errors internally -- do not let raw errors bubble up to the parent.

## Version Control

### Workflow Export and Storage

1. Export workflow JSON from n8n (Settings > Download).
2. Store in the project repository under `workflows/n8n/`.
3. One JSON file per workflow, named to match the workflow.
4. Remove execution data and personal info from exported JSON.
5. Commit with a descriptive message: "feat: add lead enrichment sub-workflow".

### Deployment Strategies

**Manual**: Export JSON, import in target n8n instance. Suitable for small teams.

**CI/CD Pipeline**: Push JSON to git, CI validates (no hardcoded secrets, schema valid), CD deploys via n8n API or MCP. Suitable for teams with multiple environments.

**MCP-Based**: Use the n8n MCP server to deploy workflows programmatically from AI assistants. See sibling skill `n8n-mcp-tools` for details.

### Deployment Checklist

1. Workflow JSON is committed to version control.
2. No hardcoded secrets in the JSON (grep for `password`, `token`, `key`).
3. Credentials reference names that exist in the target environment.
4. Environment-specific URLs use `$env` variables.
5. Error workflow is configured in workflow settings.
6. Workflow has been tested in staging before production deploy.

## Integration with Sibling Skills

This is the foundational n8n skill. For specific topics, refer to:

- **n8n-workflow-patterns**: Common architectural patterns (fan-out, polling, retry, queue).
- **n8n-code-javascript**: JavaScript Code node patterns and recipes.
- **n8n-code-python**: Python Code node patterns and recipes.
- **n8n-expressions**: Expression syntax reference and recipes.
- **n8n-node-config**: Per-node configuration guides for the most-used nodes.
- **n8n-validation**: Pre-publish validation checklist and testing strategies.
- **n8n-mcp-tools**: Using MCP to manage n8n workflows programmatically.

## Resources

- `resources/SSDLC_N8N.md` -- Full Secure Software Development Lifecycle protocol for n8n workflows. Covers threat modeling, security controls, and audit procedures.
- [n8n Official Documentation](https://docs.n8n.io/)
- [n8n Community Workflows](https://n8n.io/workflows)
- [n8n AI Agent Documentation](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.ai-agent/)

## Common Errors and Solutions

| Error | Cause | Solution |
|---|---|---|
| `Memory limit exceeded` | Processing large files or datasets | Increase `NODE_OPTIONS=--max-old-space-size` or split data into batches |
| `Node execution timeout` | Slow API calls or large processing | Increase timeout in node settings, consider async patterns |
| `Invalid credentials` | Expired or misconfigured API key | Verify in Credentials Manager, check expiration, re-authenticate |
| `ECONNREFUSED` | Target service is down or wrong URL | Verify service health, check URL/port, ensure network access |
| `429 Too Many Requests` | Rate limit exceeded | Add Wait node, reduce batch size, implement exponential backoff |
| `Workflow could not be started` | Missing trigger or inactive workflow | Verify trigger node exists and workflow is activated |
| `Expression error` | Invalid reference to node or field | Check node name spelling, verify field exists in previous node output |

## Validation Checklist

- [ ] Every node has a descriptive name following `[Verb] [Object]` convention.
- [ ] Error Trigger workflow is configured in workflow settings.
- [ ] All credentials use the n8n credential system (no hardcoded secrets).
- [ ] Sensitive data is not logged or exposed in node output.
- [ ] Rate limits are respected with appropriate waits or batch sizes.
- [ ] Sub-workflows have documented input/output contracts.
- [ ] Workflow JSON is exported and committed to version control.
- [ ] AI agents have `maxIterations` and timeout configured.
- [ ] Webhook URLs are environment-appropriate (not using localhost in prod).
- [ ] Sticky notes explain non-obvious logic.

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
