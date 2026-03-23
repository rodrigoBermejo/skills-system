# n8n MCP Tools

**Scope:** workflow
**Trigger:** when managing n8n workflows programmatically, deploying workflows via MCP, searching or discovering workflows, or building CI/CD for n8n
**Tools:** mcp__claude_ai_n8n__search_workflows, mcp__claude_ai_n8n__get_workflow_details, mcp__claude_ai_n8n__execute_workflow, bash, file_read, file_write
**Version:** 1.0.0

---

## Purpose

This skill covers using the Model Context Protocol (MCP) to manage n8n workflows programmatically from AI assistants like Claude. It explains available operations, deployment pipelines, search and discovery patterns, and security considerations.

## What MCP Enables

MCP (Model Context Protocol) provides a standardized interface for AI assistants to interact with external tools and services. The n8n MCP server exposes n8n's workflow management API as tools that Claude and other assistants can call directly.

This means you can:
- Search for existing workflows by name or tag.
- Read workflow details (full JSON structure, settings, node configuration).
- Execute workflows manually and retrieve results.
- Manage workflow lifecycle without opening the n8n UI.
- Build automated deployment pipelines driven by AI assistants.

## Available MCP Operations

### Search Workflows

Find workflows by name, tag, or keyword.

**Tool:** `mcp__claude_ai_n8n__search_workflows`

**Use cases:**
- Find all workflows related to a specific domain (e.g., "sales", "support").
- Verify a workflow exists before referencing it in another workflow.
- Audit all active workflows.
- Find workflows that need updating after an API change.

**Best practices:**
- Search by domain prefix: workflows named `Sales -- *` can be found by searching "Sales".
- Use tags for categorical search: "production", "staging", "deprecated".
- Combine search with details retrieval to understand what a workflow does.

### Get Workflow Details

Retrieve the full JSON structure of a workflow, including nodes, connections, and settings.

**Tool:** `mcp__claude_ai_n8n__get_workflow_details`

**Use cases:**
- Inspect a workflow's node configuration without opening the UI.
- Export workflow JSON for version control.
- Audit a workflow for security issues (hardcoded secrets, missing error handling).
- Understand a workflow's logic to document it or modify it.

**What the response includes:**
- Workflow metadata: name, ID, active status, tags, creation date.
- Nodes: type, name, position, parameters, credentials.
- Connections: how nodes are linked.
- Settings: error workflow, timezone, execution timeout.

### Execute Workflow

Trigger a workflow manually and optionally pass input data.

**Tool:** `mcp__claude_ai_n8n__execute_workflow`

**Use cases:**
- Run a smoke test after deployment.
- Trigger a data processing workflow on demand.
- Execute a utility workflow (e.g., "generate report", "sync data").
- Test a workflow with specific input data.

**Best practices:**
- Always pass test data that matches the workflow's expected input format.
- Check execution results for errors before marking a deployment as successful.
- Use execution mode awareness: the workflow can check `$execution.mode` to behave differently for manual vs production runs.

## Workflow Management via MCP

### Discovery and Audit

Use MCP to build a complete picture of your n8n instance:

1. **List all workflows:**
   Search with a broad term or empty query to get all workflows.

2. **Categorize by status:**
   Filter results by active/inactive status.

3. **Check for issues:**
   For each workflow, get details and verify:
   - Error workflow is configured.
   - No hardcoded credentials in node parameters.
   - All nodes have descriptive names.
   - AI agents have maxIterations set.

4. **Generate an inventory:**
   Create a document listing all workflows, their triggers, and their purposes.

### Workflow Analysis

When you need to understand what a workflow does:

1. Get workflow details via MCP.
2. Identify the trigger node (webhook, schedule, event).
3. Trace the node connections from trigger to final output.
4. List all external services the workflow interacts with.
5. Identify error handling paths.
6. Document the workflow's purpose and data flow.

## Deployment Pipeline

### Overview

A production deployment pipeline for n8n workflows:

```
Developer --> Git (commit JSON) --> CI (validate) --> CD (deploy via MCP) --> Smoke Test
```

### Step 1: Export and Commit

```bash
# Export workflow JSON from n8n (via UI or API)
# Save to the repository
workflows/
  n8n/
    sales--sync-new-leads.json
    support--classify-tickets.json
    internal--backup-database.json
```

Naming convention for JSON files: lowercase version of the workflow name with dashes.

### Step 2: CI Validation

Automated checks in the CI pipeline:

```bash
# Check for hardcoded secrets
grep -rlE '"(Bearer|sk-|password|apiKey|secret)[^"]*"' workflows/n8n/*.json && exit 1

# Validate JSON structure
for file in workflows/n8n/*.json; do
  python3 -c "import json; json.load(open('$file'))" || exit 1
done

# Custom validation rules
node scripts/validate-n8n-workflow.js workflows/n8n/*.json
```

Validation rules to enforce:
- No nodes with default names.
- Error workflow is configured.
- No hardcoded URLs pointing to localhost or development environments.
- AI agents have maxIterations configured.
- All credential references use names that exist in the target environment.

### Step 3: Deploy via MCP

After CI passes, deploy the workflow to the n8n instance:

1. Use MCP to search for the existing workflow by name.
2. If it exists, update it with the new JSON.
3. If it does not exist, create it.
4. Activate the workflow.

### Step 4: Smoke Test via MCP

After deployment, run a smoke test:

1. Use MCP to execute the workflow with known test data.
2. Check the execution result for success.
3. Verify external system state if applicable.
4. If the smoke test fails, deactivate the workflow and alert the team.

### Rollback Procedure

If a deployed workflow causes issues:

1. Deactivate the current workflow via MCP or n8n UI.
2. Retrieve the previous version from git (`git log` + `git show`).
3. Deploy the previous version.
4. Activate the reverted workflow.
5. Run a smoke test on the reverted version.

## Searching and Discovery

### Find Workflows by Domain

```
Search: "Sales"
Result: All workflows with "Sales" in the name
  - Sales -- Sync New Leads (Prod)
  - Sales -- Enrich Contact Data (Prod)
  - [Sub] Sales -- Calculate Lead Score
```

### Find Active Workflows

Search all workflows and filter by active status to get a picture of what is running in production.

### Check Workflow Execution History

After finding a workflow, you can:
1. Get its details to understand the configuration.
2. Execute it manually to test.
3. Review recent execution logs via the n8n UI for patterns.

### Dependency Mapping

For workflows that call sub-workflows:

1. Get details of the main workflow.
2. Find all Execute Workflow nodes.
3. For each, get the referenced workflow's details.
4. Build a dependency tree.

This is critical before deleting or modifying sub-workflows -- you need to know what depends on them.

## Integration with Other Skills

### With n8n-validation

Before deploying via MCP:
1. Export the workflow JSON.
2. Run it through the validation checklist from `n8n-validation`.
3. Only deploy if all checks pass.

### With n8n-workflow-patterns

When creating new workflows via MCP:
1. Reference the appropriate pattern from `n8n-workflow-patterns`.
2. Build the JSON structure following the pattern.
3. Deploy and test via MCP.

### With Version Control

The recommended workflow for team collaboration:

1. Developer modifies a workflow in the n8n editor (dev instance).
2. Exports the JSON and commits to git with a descriptive message.
3. Creates a PR for team review.
4. After approval, CI validates and CD deploys to production via MCP.
5. Smoke test runs automatically.

## Security Considerations

### API Key Management

- The MCP server requires an n8n API key to authenticate.
- Store the API key securely (environment variable, not in code).
- Use a dedicated API key for MCP with minimal required permissions.
- Rotate the API key on a schedule (quarterly minimum).
- Audit API key usage via n8n logs.

### Permission Scoping

- Create a dedicated n8n user for MCP operations.
- Grant only the permissions needed: read workflows, execute workflows, update workflows.
- Do not grant delete permissions to the MCP user unless explicitly needed.
- Separate keys for read-only (monitoring) and read-write (deployment) operations.

### Credential Protection

- Workflow JSON exported via MCP does not include credential values (only credential names/IDs).
- Credential values remain encrypted in n8n's credential store.
- When deploying a workflow, it references credentials by name -- the credentials must already exist in the target instance.
- Never pass credential values through MCP tools.

## Anti-Patterns

### Deploying Without Validation

**Problem:** Pushing workflow JSON directly to production without checks.
**Risk:** Hardcoded secrets, missing error handling, broken references.
**Fix:** Always run validation checks before deployment. Automate in CI.

### No Version Control

**Problem:** Modifying workflows directly in the production n8n editor.
**Risk:** No audit trail, no rollback capability, no team visibility.
**Fix:** All changes go through git. Production is read-only (deployed via CI/CD).

### Manual Edits in Production

**Problem:** "Quick fixes" made directly in the production instance.
**Risk:** Changes are lost on next deployment, not reviewed, not tested.
**Fix:** Establish a policy: all changes go through the dev instance -> git -> CI/CD pipeline.

### No Smoke Tests After Deploy

**Problem:** Deploying and assuming it works.
**Risk:** Silent failures discovered hours or days later.
**Fix:** Automated smoke test after every deployment via MCP execute.

### Single Monolithic Error Workflow

**Problem:** One Error Workflow that handles all types of errors the same way.
**Risk:** Alert fatigue, missed critical errors.
**Fix:** Route errors by severity. Critical errors page on-call. Warnings go to a log channel.

### Ignoring Execution Limits

**Problem:** Deploying workflows without considering n8n's execution concurrency limits.
**Risk:** Queue backlog, dropped executions, degraded performance.
**Fix:** Monitor execution queue depth. Scale workers if using Queue Mode. Set workflow-level concurrency limits.

---

**Last updated:** 2026-03-23
**Maintainer:** RBloom Dev
