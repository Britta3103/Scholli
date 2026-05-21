# Langdock Platform Documentation (AI Reference)

> Compiled: 2025-05-21 | Source: docs.langdock.com | Base URL: https://api.langdock.com

---

## Table of Contents

1. [Platform Overview](#1-platform-overview)
2. [Agents](#2-agents)
   - 2.1 Introduction to Agents
   - 2.2 Agent Configuration
   - 2.3 Subagents
   - 2.4 Agent Form Fields
   - 2.5 Sharing Agents with API Keys
3. [Workflows](#3-workflows)
   - 3.1 Introduction & Core Concepts
   - 3.2 Workflow Builder
   - 3.3 Field Modes
   - 3.4 Variable Usage & Data Flow
   - 3.5 Trigger Nodes
   - 3.6 Processing Nodes
   - 3.7 Human in the Loop
   - 3.8 Cost Management
   - 3.9 Triggering Workflows from Chat
4. [Integrations](#4-integrations)
   - 4.1 Overview
   - 4.2 Creating Custom Integrations
   - 4.3 Sandbox Utility Functions
5. [Knowledge Folders](#5-knowledge-folders)
6. [API Reference (Complete)](#6-api-reference-complete)
   - 6.1 Authentication & Base URLs
   - 6.2 Agent Completions API
   - 6.3 Agent CRUD API (Create, Get, Update, Publish, Disable)
   - 6.4 Models API
   - 6.5 Upload Attachment API
   - 6.6 Integrations API
   - 6.7 Knowledge Folder API
7. [Pricing](#7-pricing)

---

## 1. Platform Overview

Langdock is an enterprise AI platform with three core products:

- **Chat & Agents** — AI-powered conversations and custom chatbots with persistent context, knowledge, and tool integrations. Seat-based pricing.
- **Workflows** — Multi-step automation engine connecting agents, integrations, and logic. Add-on priced by monthly runs.
- **API** — Programmatic access to all AI capabilities. Usage-based token pricing.

### Key Architectural Concepts

| Concept | Description |
|---------|-------------|
| **Agents** | Specialized chatbots with saved instructions, knowledge, and tools. Can be deployed in chat, Slack, Teams, or via API. |
| **Workflows** | Visual automation graph of nodes triggered by events, schedules, forms, or webhooks. |
| **Integrations** | Pre-built or custom connectors to external tools (Slack, Jira, Salesforce, etc.). Provide **actions** (do things) and **triggers** (react to events). |
| **Knowledge Folders** | Document collections (PDFs, Word, Markdown, etc.) that are embedded for semantic search. |
| **Skills** | Reusable instruction sets that activate automatically in chat. |

### Base URLs

| Deployment | Base URL |
|------------|----------|
| Langdock Cloud | `https://api.langdock.com` |
| Dedicated (self-hosted) | `https://<your-domain>/api/public` |

### Authentication

All API requests use a Bearer token:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://api.langdock.com/agent/v1/chat/completions
```

> **Security Note:** The Langdock API must be accessed from a secure backend. Browser-origin requests are intentionally blocked to prevent API key exposure.

### Rate Limits

- Default: **500 RPM** (requests per minute), **60,000 TPM** (tokens per minute) — per model
- Rate limits are workspace-level, not per API key
- `429 Too Many Requests` is returned when exceeded
- BYOK workspaces can configure custom limits per model in Settings → Models

---

## 2. Agents

### 2.1 Introduction to Agents

Agents are specialized chatbots configured for specific use cases. They work like regular chat, but with **saved context** (instructions, knowledge, tools) so you don't repeat setup.

**Use cases:**
- **Internal agents** — Used by team members in the platform, Slack, or Teams
- **External agents** — Shared via API for custom interfaces; usage-based pricing (no Langdock license required for end users)

**Access channels:**
- Langdock web platform (chat interface)
- Slack (via Slack Bot integration)
- Microsoft Teams (via Teams Bot)
- API (programmatic access, build your own UI)

### 2.2 Agent Configuration

Navigate to **Agents** → create or select an agent. The configuration panel contains:

#### Identity

| Property | Limit |
|----------|-------|
| Agent name | 80 characters |
| Agent description | 500 characters |
| Agent instructions (system prompt) | 40,000 characters |
| Emoji icon | 16 characters |

#### Input Type

- **Prompt (Default)** — Standard chat input. Supports conversation starters (pre-set prompts users can click).
- **Form** — Structured input collected before the conversation. Guides users, reduces ambiguity.

#### Knowledge

Attach files directly (up to 20 files) or connect via integrations. Files can be sourced from:
- Direct upload from computer
- Integration-linked files (SharePoint, Google Drive, Confluence)
- Knowledge Folders (embedded document collections)

**Source Access Restriction** — When enabled, agent can cite documents but users cannot open source files. Requires admin to enable at workspace level first.

#### Actions (Tools)

| Category | Examples |
|----------|---------|
| **Capabilities** | Web Search, Image Generation, Data Analysis (Python), Canvas |
| **Integration Actions** | Create email drafts, update CRM, create tickets, post to Slack |
| **Folders** | Attach document collections for knowledge retrieval |
| **Other Agents** | Attach subagents to delegate specialized tasks |

> **Note:** Deep Research is only available in regular chat, not agents.

#### Model & Creativity

- **Model** — Choose any model available in your workspace (OpenAI, Anthropic, Google, Mistral, etc.)
- **Creativity** — Temperature slider 0–1:
  - `0–0.3`: Deterministic, consistent (coding, factual tasks)
  - `0.4–0.7`: Balanced (general use, default 0.7)
  - `0.8–1.0`: Creative (brainstorming, writing)

#### Publishing & Versioning

- Changes are saved as **drafts** — do not affect users until published
- Click **Publish** in top-right to make current draft the active version
- The Agent API endpoints always use the **active (published)** version
- If never published, API returns current draft

#### Analytics & Logging

- **Analytics tab** — Usage metrics, message counts, user activity
- **Feedback tab** — User feedback on responses
- **Tracing (Langfuse)** — Requires admin to enable "Allow assistant logs" in workspace settings. Then set Tracing cloud URL (default: `https://cloud.langfuse.com`)

### 2.3 Subagents

Subagents let you attach one agent to another, creating a delegation hierarchy.

**How it works:**
1. Parent agent decides to delegate a task
2. Sends a prompt to the subagent (only the prompt — not full conversation history)
3. Subagent runs independently with its own instructions, knowledge, model
4. Returns result to parent agent

**Key rules:**
- Only editors/owners of an agent can attach it as a subagent
- No nesting: subagents cannot call other subagents
- If user lacks access to a subagent, they see an "access denied" message in-conversation
- Everyone with access to the parent agent can use its subagents

**When to use:**
- Instructions for single agent are getting too long/complex
- Different tasks need different models or knowledge bases
- You want to reuse existing well-configured agents

**Adding subagents:** Open agent → **Actions** tab → **Subagents** in sidebar → select agents to attach.

### 2.4 Agent Form Fields

When `inputType` is set to **Form**, agents collect structured input before conversation.

**Field Types:**

| Type | Best For | Notes |
|------|----------|-------|
| `TEXT` | Names, IDs, short phrases | Single line |
| `MULTI_LINE_TEXT` | Descriptions, feedback, long context | Multi-line textarea |
| `NUMBER` | Quantities, amounts, ratings | Numeric only |
| `CHECKBOX` | Boolean yes/no, agreements | True/false |
| `FILE` | Documents, images | One file field per form |
| `SELECT` | Category, priority, fixed choices | Dropdown; define options |
| `DATE` | Deadlines, event dates | Date picker |
| `EMAIL` | Contact addresses | Format validated; optional domain restriction |

**Field Properties:**

| Property | Limit | Description |
|----------|-------|-------------|
| Label | 255 chars | Display name shown to users |
| Description | 512 chars | Help text |
| Options (Select) | 255 chars each | Available choices |
| File Types | 255 chars | Comma-separated extensions (e.g., `.pdf, .docx`) |
| Maximum fields | 25 | Per agent |

**Email domain restriction:** Set `emailDomain` to restrict to a specific org domain (e.g., `langdock.com`).

### 2.5 Sharing Agents with API Keys

1. Go to **Workspace Settings** → **API** (under Products) → **Create API key**
2. Enter name, select scopes (minimum: `ASSISTANT_API` or `AGENT_API`), confirm
3. Copy key immediately (not shown again)
4. Go to **Agents** → open the agent → click **Share** (top-right)
5. Search for the API key by name → add it
6. Only workspace admins can connect an agent with an API key

**Getting the Agent ID:** From the URL when editing: `https://app.langdock.com/agents/AGENT_ID/edit`

---

## 3. Workflows

### 3.1 Introduction & Core Concepts

Workflows are visual multi-step automations where you chain nodes to create end-to-end processes. They run automatically based on triggers.

**What makes workflows different from Chat/Agents:**
- Run 24/7 without human intervention
- Combine multiple AI agents, custom logic, external APIs
- Support conditional routing, loops, parallel execution
- Event-driven (form, schedule, webhook, integration event)

**Activation:** Workflows must be enabled by an admin in workspace settings. May require subscription upgrade and consume AI credits.

#### Nodes

A **node** is the fundamental building block — each does one thing. Nodes are connected visually to define execution flow.

**Node anatomy:**
- **Header** — Node type + name. Play button for individual testing.
- **Input tab** — Data the node received (visible after run)
- **Output tab** — Data the node produced (visible after run)
- **Configuration panel** — Settings panel (open by clicking node)

#### Execution Patterns

**Sequential:** Nodes execute one after another following connections.

**Parallel:** When multiple nodes connect from a single source, they run simultaneously.

```
              → Send Email →
Trigger →    → Create Ticket →    → Continue
              → Update Database →
```

**Error Handling per node:**
| Strategy | Behavior |
|----------|----------|
| **Fail workflow** (default) | Stop everything, mark run as failed |
| **Continue workflow** | Log error, keep going |
| **Error callback** | Route to error-handling nodes via red error handle |

#### Versioning

| Version | Description |
|---------|-------------|
| **Draft (v0)** | Working sandbox. Changes here don't affect production. |
| **Published (v1.0.0, etc.)** | Immutable snapshot. Triggers only fire against active published versions. |

**Version bump types when publishing:**
- **Patch** (1.0.0 → 1.0.1): Bug fixes
- **Minor** (1.0.0 → 1.1.0): New features
- **Major** (1.0.0 → 2.0.0): Breaking changes

#### Workflow States

| State | Description |
|-------|-------------|
| **Not deployed** | Draft only; no triggers fire |
| **On** | Published, responding to triggers in production |
| **Off** | Disabled; no triggers fire but workflow exists |

#### Testing

- **Individual node test**: Click play button on node → runs that node only
- **Full workflow test**: "Test run" button on trigger → runs entire workflow with sample data (doesn't mark events as processed)
- **Replay events**: Test with data from previous real runs (form submissions, webhook calls, integration events)
- After any run: click nodes to see Input, Output, Messages (agents), Logs (code), Usage (credits)

### 3.2 Workflow Builder

The AI-powered workflow creation assistant. Access from Workflows page → button in bottom-left corner.

**How to use:**
1. Open Workflow Builder chat
2. Describe your automation in natural language
3. AI generates complete workflow with nodes and connections
4. Review generated workflow and fill in specifics (auth, specific channels, etc.)
5. Iterate via chat: "Add error handling", "Change the trigger to hourly"

**Example prompts:**
```
Build an automation that runs every Monday to pull sales reports from 
Salesforce and generates a summary

Create a workflow triggered by a form submission that validates the 
data and adds it to a Google Sheet

Set up a workflow that monitors Gmail for customer emails, uses AI to 
detect feature requests, and labels them automatically
```

**Error fixing:** If a run fails, click "Fix in chat" to automatically send the error to the Workflow Builder for debugging.

**Preferences:** Set preferred tools (email, CRM, issue tracker) so the AI uses them by default. Add custom instructions for how the AI should help you.

**Chat History:** Access previous workflow-building conversations via the history icon (top-right of builder).

**Import from other tools:** Export workflows from other tools as JSON → import into Workflow Builder chat → AI recreates them.

### 3.3 Field Modes

Every node field can be configured in one of three modes:

| Mode | AI Credits | Control | Best For |
|------|------------|---------|----------|
| **Manual** | No | High | Direct values, templates, variables (default) |
| **AI Prompt** | Yes | Medium | Content generation, summarization, transformation |
| **Auto** | Yes | Low | Prototyping, variable/dynamic structures |

#### Manual Mode

Specify exact values — static text, variables, or combinations.

```handlebars
{{node_name.output.field_name}}
{{trigger.output.email}}
Hello {{trigger.output.name}}, your order {{trigger.output.order_id}} is ready
```

#### AI Prompt Mode

Give natural language instructions for AI to generate content.

```
Write a friendly response to {{trigger.output.message}},
addressing their concern about {{agent.output.structured.issue_category}}.
```

#### Auto Mode

AI analyzes context from previous nodes and determines the value automatically. Least predictable; best for prototyping.

### 3.4 Variable Usage & Data Flow

Variables carry data between nodes. Every completed node produces output accessible in downstream nodes.

#### Syntax

```handlebars
{{node_name.output.property}}
{{node_name.output.nested.field}}
{{node_name.output.array[0].property}}
```

| Use Case | Syntax | Example |
|----------|--------|---------|
| Basic field | `{{node.output.field}}` | `{{trigger.output.email}}` |
| Nested object | `{{node.output.obj.prop}}` | `{{user.output.profile.age}}` |
| Array element | `{{node.output.array[i]}}` | `{{items.output.list[0]}}` |
| Nested in array | `{{node.output.array[0].prop}}` | `{{orders.output.items[0].price}}` |
| Entire array | `{{node.output.array}}` | `{{trigger.output.tags}}` |
| Agent structured output | `{{agent.output.structured.field}}` | `{{analyze.output.structured.summary}}` |
| Agent messages (no schema) | `{{agent.output.messages}}` | — |
| Optional chaining | `{{node.output.field?.prop}}` | `{{trigger.output.user?.email}}` |

**Type `{{` in any field** to see a dropdown of all available variables from upstream nodes.

#### Node Renaming

When you rename a node, **all variable references update automatically** throughout the workflow.

#### In Code Nodes (JavaScript)

```javascript
const email = trigger.output.email;
const priority = analyze.output.structured?.priority || "medium";
return { email, priority };
```

#### In Condition Expressions

Wrap entire expression in `{{ }}`:
```handlebars
{{ trigger.output.amount > 1000 }}
{{ agent.output.structured.priority === "high" }}
{{ trigger.output.email.includes("@company.com") }}
```

#### Troubleshooting Variables

| Problem | Cause | Solution |
|---------|-------|----------|
| Variable not in autocomplete | Node not connected, or is downstream | Connect node upstream |
| `undefined` / `null` | Source node failed or empty data | Use `?.` optional chaining or defaults |
| Wrong type | Data type mismatch | Check Output tab of source node after test run |

### 3.5 Trigger Nodes

Triggers are the starting point of every workflow. Only one trigger per workflow.

---

#### Manual Trigger

Runs workflow on-demand with a button click. No configuration required.

**Best for:** Testing, ad-hoc processing, administrative tasks, human-initiated processes.

**Output:** No output (just starts execution)

**Chat support:** Yes — appears in `@`-mention menu in chat.

---

#### Form Trigger

Creates a public web form that starts the workflow on submission.

**Best for:** Feedback forms, intake forms, applications, data collection from non-technical users.

**Configuration:**
- **Form Title** — Shown at top of form
- **Description** — Optional instructions
- **Thank You Message** — Shown after submission

**Field Types:**

| Type | Use Case |
|------|---------|
| `Text` | Name, title |
| `Long Text` | Feedback, descriptions |
| `Number` | Quantity, amount |
| `Email` | Contact email (with optional domain restriction) |
| `Date` | Due dates, event dates |
| `Dropdown` | Category, priority, department |
| `Checkbox` | Agreements, preferences |
| `File Upload` | Documents, images |

**Field Configuration:**
- `Field Name` — Internal identifier (use `snake_case`)
- `Label` — Display text for users
- `Description` — Optional help text
- `Required` — Whether field must be filled
- `Domain Restriction` — For Email fields, restrict to one email domain

**Form URL:** Click "Copy URL" on the trigger node. Share or embed in website:
```html
<iframe src="https://app.langdock.com/workflows/forms/abc123" 
        width="100%" height="600" frameborder="0"></iframe>
```

**Accessing form data:**
```handlebars
{{trigger.output.name}}
{{trigger.output.email}}
{{trigger.output.feedback}}
{{trigger.output.product}}

<!-- File upload fields -->
{{trigger.output.resume.filename}}
{{trigger.output.resume.mimeType}}
{{trigger.output.resume.size}}
```

**Chat support:** Yes — form fields rendered inline in chat. FILE fields auto-filled from conversation attachments (single: most recent; multi: up to 10 recent).

---

#### Scheduled Trigger

Runs workflow automatically on a recurring schedule.

**Best for:** Daily reports, data syncs, recurring maintenance, time-based monitoring.

**Configuration:**
- **Schedule** — Visual builder (every N minutes/hours/days/weeks/months) or cron expression
- **Timezone** — Defaults to account timezone

**Cron format:** `minute hour day-of-month month day-of-week`

| Schedule | Cron |
|----------|------|
| Every day at 9 AM | `0 9 * * *` |
| Every hour | `0 * * * *` |
| Every Monday at 8 AM | `0 8 * * 1` |
| First of month at midnight | `0 0 1 * *` |
| Every 15 minutes | `*/15 * * * *` |

**Chat support:** Yes — can also be triggered on-demand from chat.

**Note:** Workflow must be deployed (active/published) for scheduled triggers to fire. Reaching monthly spending limit deactivates scheduled workflows.

---

#### Webhook Trigger

Provides a unique HTTP endpoint that external systems call via `POST` to start the workflow.

**Best for:** Real-time integrations, external system events, custom API-driven workflows.

**Authentication methods:**

| Method | How It Works |
|--------|-------------|
| **No authentication** | Public endpoint; good for testing |
| **Header** | Send secret via `X-Webhook-Secret` HTTP header (recommended) |
| **Query parameter** | Append `?secret=...` to URL (legacy) |

**Making requests:**
```bash
# No authentication
curl -X POST https://app.langdock.com/api/hooks/workflows/YOUR_WORKFLOW_ID \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'

# Header authentication (recommended)
curl -X POST https://app.langdock.com/api/hooks/workflows/YOUR_WORKFLOW_ID \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: YOUR_SECRET" \
  -d '{"key": "value"}'

# Query parameter authentication (legacy)
curl -X POST "https://app.langdock.com/api/hooks/workflows/YOUR_WORKFLOW_ID?secret=YOUR_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

**Response:** Always `202 Accepted` immediately. Workflow processes asynchronously.

**Accessing webhook data:**
```handlebars
{{trigger.output.body.user_id}}         <!-- JSON body field -->
{{trigger.output.body.event_type}}
{{trigger.output.query.source}}         <!-- URL query parameter -->
```

**Webhook response codes:**

| Code | Meaning |
|------|---------|
| 202 | Accepted — workflow queued |
| 400 | Bad Request — invalid ID, format, or secret |
| 404 | Not Found |
| 429 | Too Many Requests — rate limit or spending cap |
| 500 | Server Error |

**Chat support:** No — must be triggered by external HTTP call.

---

#### Integration Trigger

Starts workflow when events occur in connected applications.

**Best for:** Responding to Slack messages, new emails, CRM changes, calendar events, file uploads.

**Supported integrations with event triggers:**

| Category | Integration | Events |
|----------|-------------|--------|
| **Communication** | Slack | New channel message, DM, reaction |
| | Microsoft Teams | New channel/chat message, mention, meeting transcript |
| | Gmail | New email, search match, label change |
| | Outlook | New email, folder match, shared inbox |
| **Productivity** | Notion, Jira, Confluence | Various record events |
| | Microsoft Planner | Task events |
| **Storage** | Google Drive | New/updated file or folder |
| **CRM** | Salesforce | New lead, contact, account, opportunity |
| | HubSpot | New deal, form submission, note, list add |
| **Calendar** | Google Calendar / Outlook | New event, event start |
| | Calendly | Booking events |
| **Developer** | GitHub | PR, issue, commit, release, path changes |
| **Finance** | Stripe | Payment success/fail, subscription events |

> **Note:** Integrations like Google Sheets, Asana, Airtable, Linear, Monday.com are available as **actions** (in workflow steps) but NOT as triggers. Use Scheduled Trigger to poll these.

**Configuration steps:**
1. Select integration
2. Choose event type
3. Configure event filters (channel, folder, search query, etc.)
4. Configure trigger parameters (polling interval, etc.)
5. Connect account (OAuth if required)

**Accessing event data:**
```handlebars
<!-- Gmail example -->
{{trigger.output.subject}}
{{trigger.output.from}}
{{trigger.output.body}}
{{trigger.output.has_attachments}}
```

**Chat support:** No — must be triggered by external integration event.

### 3.6 Processing Nodes

---

#### Agent Node

Executes an AI agent to analyze, generate, classify, or extract data.

**Best for:** Content analysis, categorization, data extraction, summarization, decision-making, translation.

**NOT ideal for:** Simple math/transformations (use Code), direct API calls (use HTTP Request).

**Configuration:**

| Setting | Description |
|---------|-------------|
| **Agent** | Use existing workspace agent OR create new agent for this workflow |
| **Instructions** | System prompt with task description; can include `{{variables}}` |
| **Input** | Data passed to agent prompt |
| **Model** | LLM to use |
| **Structured Output** | Define expected JSON schema (strongly recommended) |
| **Max Steps** | Max tool call steps (default: 25; range: 1–100+) |
| **Tools** | Web search, Python execution, integration actions, folders, subagents |
| **Connection Overrides** | Override which connection to use for specific tools |
| **Error Handling** | Stop (default), Callback, Continue |

**Structured Output — strongly recommended:**
1. Enable "Structured Output"
2. Define fields: name, type (string/number/boolean/array), description
3. Agent's response guaranteed to match this schema

```json
{
  "sentiment": "positive",
  "category": "product_feedback",
  "priority": "medium",
  "summary": "Customer loves the new feature",
  "action_needed": false
}
```

**Accessing output:**
```handlebars
<!-- With structured output schema -->
{{agent_node_name.output.structured.sentiment}}
{{agent_node_name.output.structured.category}}
{{agent_node_name.output.structured.tags[0]}}

<!-- Without schema -->
{{agent_node_name.output.messages}}
```

**Prompt engineering tips:**
```
# Be explicit:
❌ "Analyze this text"
✅ "Analyze this customer feedback and categorize as: bug, feature_request, or question"

# Provide context:
You are analyzing customer support tickets for a SaaS company.
Urgency: Urgent=system down/data loss, High=blocking work, Medium=has workaround, Low=question

# Use examples:
Example 1: "Can't log in, getting 500 error" → Urgent
Example 2: "How do I export data?" → Low
Now categorize: {{trigger.output.issue}}

# Constrain output:
Respond with ONLY one of these categories: bug, feature, question
Do not explain your reasoning.
```

---

#### Code Node

Execute custom JavaScript or Python for data transformation, validation, calculations.

**Best for:** Math, data formatting, JSON manipulation, validation, date operations, filtering.

**NOT ideal for:** AI analysis (Agent), external API calls (HTTP Request), complex conditions (Condition).

**Configuration:**
- **Language** — JavaScript or Python
- **Code Editor** — Write transformation logic
- Previous node outputs are available as variables (shown at top of editor)

**JavaScript examples:**

```javascript
// Calculate statistics
const scores = agent.output.structured.scores || [];
const average = scores.reduce((a, b) => a + b, 0) / scores.length;
return {
  average_score: average.toFixed(2),
  grade: average >= 90 ? "A" : average >= 80 ? "B" : "C"
};

// Validate and clean data
const email = trigger.output.email || "";
if (!email.includes("@")) throw new Error("Invalid email format");
return {
  email: email.trim().toLowerCase(),
  validated: true
};

// Filter and transform arrays
const customers = trigger.output.customers || [];
const active = customers.filter(c => c.status === "active");
return {
  customers: active.map(c => ({
    id: c.id,
    name: `${c.firstName} ${c.lastName}`.trim(),
    tier: c.totalSpent > 1000 ? "premium" : "standard"
  })),
  total: active.length
};

// Date operations
const now = new Date();
const daysUntil = Math.ceil((new Date(event.date) - now) / (1000 * 60 * 60 * 24));
return { daysUntil, isThisWeek: daysUntil >= 0 && daysUntil <= 7 };
```

**Python examples:**

```python
# Access previous node outputs as variables
agent_output = agent.get("output", {})
scores = agent_output.get("structured", {}).get("scores", [])

# Use print() for logging
print(f"Processing {len(scores)} scores")

# Return dict as output
return {
    "average": sum(scores) / len(scores) if scores else 0,
    "count": len(scores)
}
```

**Python file output:**
```python
import csv
with open("output.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["name", "email"])
    # ...
return {"file_name": "output.csv"}
# Files saved to working dir available as:
# {{code_node_name.output._files[0]._metadata.name}}
```

**Accessing Code node output:**
```handlebars
{{code_node_name.output.customer}}
{{code_node_name.output.total}}
{{code_node_name.output._files[0]._metadata.name}}
```

**JavaScript utilities available:**
- `ld.request()` — HTTP requests
- `ld.log()` — Debug logging
- Data conversions: CSV, Parquet, Arrow formats
- Standard JS: JSON, Date, Math, Array, Object methods

**Python capabilities:**
- Pre-installed: pandas, numpy, openpyxl, pypdf, csv, datetime, etc.
- No internet access from Python
- `ld.*` utilities NOT available in Python

---

#### HTTP Request Node

Make HTTP requests to external APIs.

**Best for:** Custom API integrations, fetching data, sending webhooks, connecting services without native integrations.

**Configuration:**

| Field | Options | Description |
|-------|---------|-------------|
| **URL** | Manual/Auto/Prompt | Target API endpoint; supports `{{variables}}` |
| **Method** | GET, POST, PUT, PATCH, DELETE | HTTP verb |
| **Headers** | Key-value pairs | Auth headers, Content-Type, etc. |
| **Query Parameters** | Key-value pairs | URL params (cleaner than embedding in URL) |
| **Body** | JSON (POST/PUT/PATCH) | Request payload with variable support |

**Import from cURL:** Paste a cURL command to auto-populate all fields.

**Examples:**
```
# GET with auth
Method: GET
URL: https://api.crm.com/users/{{trigger.output.user_id}}
Headers: Authorization: Bearer YOUR_TOKEN

# POST with body
Method: POST
URL: https://api.system.com/records
Headers: Content-Type: application/json
Body:
{
  "title": "{{trigger.output.title}}",
  "category": "{{agent.output.structured.category}}"
}
```

**Accessing response:**
```handlebars
{{http_node.output.status}}              <!-- Status code: 200, 404, etc. -->
{{http_node.output.data}}                <!-- Response body -->
{{http_node.output.data.user.name}}      <!-- Nested data -->
{{http_node.output.data.items[0].id}}    <!-- Array items -->
{{http_node.output.headers}}            <!-- Response headers -->
```

**Error checking:**
```handlebars
{{ http_node.output.status === 200 }}    <!-- Success -->
{{ http_node.output.status >= 400 }}     <!-- Error -->
```

---

#### Condition Node

Route execution down different paths based on conditions.

**Best for:** Approval workflows, priority routing, data validation, A/B paths, if-then-else logic.

**Configuration:**

| Setting | Description |
|---------|-------------|
| **Model** | AI model for Prompt AI mode conditions |
| **Conditions** | List of named conditions, each with a mode |
| **Allow Multiple** | If enabled, ALL matching conditions execute (default: first match wins) |
| **Force Select** | (Prompt AI only) Always select at least one branch |

**Manual Mode — expressions in `{{ }}`:**
```handlebars
{{ trigger.output.amount > 1000 }}
{{ agent.output.structured.priority === "high" }}
{{ trigger.output.email.includes("@company.com") }}
{{ trigger.output.tags.includes("urgent") }}
{{ status === "approved" && score > 80 }}
```

**Manual operators:**
- Comparison: `===`, `!==`, `>`, `<`, `>=`, `<=`
- Logical: `&&`, `||`, `!`
- String: `.includes()`, `.startsWith()`, `.endsWith()`
- Existence: `{{ trigger.output.field }}` (truthy check)

**Prompt AI Mode — natural language:**
```
Determine if this customer message requires urgent attention based on:
- Keywords like "urgent", "emergency", "asap"
- Angry or frustrated tone
- Mention of high-priority issues
Context: {{trigger.output.message}}
```

**Best practices:**
- Always add a final `{{ true }}` condition to catch unmatched cases
- Order conditions top-to-bottom (first match wins by default)
- Use Manual for simple checks; Prompt AI for nuanced evaluation
- Name conditions clearly: "If High Priority" not "Condition 1"

---

#### Loop Node

Iterate over arrays, processing each item with the same node chain.

**Best for:** Batch processing, processing multiple records, generating individual reports.

**Configuration:**

| Setting | Description |
|---------|-------------|
| **Input Array** | Variable pointing to array to iterate |
| **Max Iterations** | Safety limit (default: 200, max: 2000) |
| **Concurrency** | Off (sequential, default) or On (parallel) |
| **Collect Outputs** | Gather all iteration results into final array |

**Accessing current item inside loop:**
```handlebars
{{ loop_slug.output.currentItem }}            <!-- Full current item -->
{{ loop_slug.output.currentItem.name }}       <!-- Item property -->
{{ loop_slug.output.currentIndex }}           <!-- 0-based index -->
{{ loop_slug.output.total }}                  <!-- Total items -->
```

**Collecting outputs (when enabled):**
```handlebars
{{ loop_end.output.iterations }}              <!-- All iteration data -->
{{ loop_end.output.iterations[0].item }}      <!-- First item's input -->
{{ loop_end.output.iterations[0].executions }}<!-- Nodes executed in first iteration -->
{{ loop_end.output.total }}                   <!-- Count -->
```

**Collected output structure:**
```json
{
  "iterations": [
    {
      "index": 0,
      "item": { "original": "data" },
      "executions": [
        {
          "nodeId": "abc123",
          "nodeSlug": "agent",
          "nodeType": "agent",
          "input": {},
          "output": { "result": "processed" }
        }
      ]
    }
  ],
  "total": 10
}
```

> **Cost Warning:** Loops with AI agents multiply costs. 100 items × $0.10/agent call = $10/run.

**Concurrency:** When enabled, all iterations run simultaneously (much faster, but iterations may complete out of order — don't use if later iterations depend on earlier ones).

---

#### Delay Node

Add a pause between 1 second and 24 hours.

**Best for:** API rate limiting, waiting for external processing, retry delays, exponential backoff.

**Configuration:**
- **Duration** — 1 second to 24 hours (seconds, minutes, or hours)
- Default: 5 seconds

**Use cases:**
```
# Retry with backoff
HTTP Request → [Error] → Delay: 5s → HTTP Request (retry) → [Error] → Delay: 15s → Final retry

# Wait for processing
Action: Submit doc → Delay: 1 min → HTTP: Fetch result → Agent: Analyze

# Rate limiting in loops
Loop: 100 items → HTTP Request → Delay: 1s (prevents API throttle)
```

**Limitations:**
- Min: 1 second, Max: 24 hours
- Cannot be cancelled once started
- For delays >few hours, consider Scheduled Trigger restart instead
- Delays themselves are free (no cost)

---

#### Action Node

Execute operations in connected integrations (send messages, create records, etc.).

**Best for:** Creating/updating records, sending messages, triggering actions in Slack/Gmail/Sheets/CRM/etc.

**Configuration:**
1. Select integration (Slack, Google Sheets, Notion, etc.)
2. Choose action (Send message, Create record, Add row, etc.)
3. Select connection (if multiple connected accounts)
4. Map fields using Manual, Auto, or Prompt modes
5. Configure action-specific settings

**Requires Confirmation:** When enabled, workflow pauses and waits for user approval before executing. Useful for high-impact actions.

**Field modes per action field:**

| Mode | When to Use |
|------|-------------|
| Manual | Know exactly what value to use; use `{{variables}}` |
| Auto | Value depends on workflow context |
| Prompt | Need AI to generate the value |

**Example:**
```handlebars
Slack: Send Message
Channel: #support
Message: New ticket #{{trigger.output.ticket_id}}
Priority: {{agent.output.structured.priority}}
```

---

#### File Search Node

Query knowledge folders for relevant document content.

**Best for:** RAG (Retrieval Augmented Generation), knowledge base search, document validation, context enrichment.

**Configuration:**

| Setting | Options | Description |
|---------|---------|-------------|
| **Folder** | Select from workspace | Knowledge folder to search |
| **Search Query** | Manual/Auto/Prompt | Query to find relevant content |
| **Max Results** | Number (default: 10) | Maximum results to return |

**Search query examples:**
```handlebars
<!-- Manual mode -->
{{trigger.output.customer_question}}
Find information about {{trigger.output.product_name}} pricing

<!-- Prompt mode -->
Generate a search query to find info about: {{trigger.output.question}}
```

**Accessing results:**
```handlebars
{{file_search.output.results}}
{{file_search.output.results[0].text}}
{{file_search.output.results[0].similarity}}    <!-- 0-1 relevance score -->
{{file_search.output.results[0].fileName}}
{{file_search.output.results[0].fileUrl}}
{{file_search.output.results[0].mimeType}}
{{file_search.output.results[0].fileId}}
```

**Result structure fields:**
- `text` — Relevant text chunk from document
- `similarity` — Relevance score (0–1, higher = more relevant)
- `fileName` — Source file name
- `fileUrl` — URL to source file
- `mimeType` — MIME type
- `subsource` — Additional source reference
- `pageCount` — Number of pages in file

**Using in Agent prompt:**
```handlebars
Context from knowledge base:
{{file_search.output.results}}

Based on the above context, answer:
{{trigger.output.question}}
```

**Limitations:**
- Supports document files (PDF, Word, Markdown, HTML, etc.)
- CSV/Excel files cannot be uploaded to folders
- Only searches within selected folder
- Document changes require reprocessing before appearing in results

---

#### Web Search Node

Search the internet and retrieve relevant results.

**Best for:** Fact-checking, current events, market research, real-time information.

**Configuration:**
- **Query** — Manual, Automatic (AI-generated), or Prompt mode
- **Number of Results** — Default: 5

**Output structure per result:**

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Page title |
| `url` | string | Page URL |
| `text` | string | Text snippet/preview |
| `type` | string | Always `"website-preview"` |

**Accessing results:**
```handlebars
{{web_search.output[0].title}}
{{web_search.output[0].url}}
{{web_search.output[0].text}}
```

---

#### Guardrails Node

Validate content with AI-powered safety, accuracy, and compliance checks.

**Best for:** Content moderation, PII detection, hallucination checking, jailbreak prevention, brand compliance.

**Configuration:**
- **Input** — Content to validate (Manual/Auto/Prompt)
- **Model** — AI model for evaluation
- **Enable guardrails** — Check individual guardrails below

**Available Guardrails:**

| Guardrail | Detects | Recommended Threshold |
|-----------|---------|----------------------|
| **PII Detection** | Names, emails, phones, SSNs, credit cards | 0.7–0.8 |
| **Moderation** | Hate speech, violence, adult content, harassment | 0.6 |
| **Jailbreak Detection** | Prompt injection, "ignore previous instructions" | 0.7–0.75 |
| **Hallucination Detection** | False/unverifiable information vs. reference data | 0.6–0.7 |
| **Custom Evaluation** | Any natural language criteria | Varies |

**Confidence threshold behavior:**

| Threshold | Strictness |
|-----------|-----------|
| 0.3–0.5 | Lenient — avoid false positives |
| 0.6–0.7 | Balanced — recommended for most cases |
| 0.8–0.9 | Strict — high-risk scenarios |
| 0.9–1.0 | Very strict — obvious violations only |

**When a guardrail fails:** Node fails → workflow stops (unless error handling configured). Use error callback to route to manual review.

---

#### Send Notification Node

Send in-app notifications to Langdock inbox.

**Recipients:**
- Manual/Form triggers → user who triggered the workflow
- Scheduled/Webhook/Integration triggers → workflow owner (creator)

**Configuration:**
- **Message** — Manual, Auto, or Prompt mode. Supports markdown and `{{variables}}`.

**Example notification:**
```handlebars
🚨 **High Priority Customer Feedback**

**Customer:** {{trigger.output.customer_name}}
**Email:** {{trigger.output.email}}
**Category:** {{agent.output.structured.category}}
**Summary:** {{agent.output.structured.summary}}

**Action Required:** Please respond within 1 hour.
```

> **Note:** To notify external recipients (Slack, email), use the Action node instead.

---

#### Output Node

Capture and persist a value as the workflow run's final result.

**Key behaviors:**
- Terminal node — has input handle but no output handle
- Output is stored under the node's **slug** (auto-generated from node name in camelCase)
- Multiple Output nodes produce multiple keys in the run's output object
- When workflow is triggered from chat, output appears directly in the chat message

**Configuration:**
- **Value** — Template expression (Manual mode only)
- **Slug** — Auto-generated; must be unique if multiple Output nodes

**Example:**
```handlebars
**Priority:** {{agent.output.structured.priority}}
**Category:** {{agent.output.structured.category}}
**Suggested response:**

{{agent.output.structured.draft_reply}}
```

**Multiple outputs example:**
```json
{
  "summary": "Q1 revenue grew by 12%...",
  "actionItems": "1. Schedule board review\n2. Update forecast"
}
```

**Chat integration:** If workflow lacks an Output node, chat shows generic "completed" status instead of detailed result.

---

#### Image Generation Node

Generate images from text prompts using AI image models.

**Configuration:**

| Setting | Options | Description |
|---------|---------|-------------|
| **Prompt** | Manual/Auto/Prompt | Text description of desired image |
| **Image Model** | Model selector | DALL-E, Stable Diffusion, etc. |
| **Aspect Ratio** | Square (1:1), Landscape (16:9), Portrait (9:16) | Output dimensions |
| **Style** | Auto, Photorealistic, Digital Art, Oil Painting, Watercolor, Sketch, Anime, 3D Render, Minimalist, Cinematic | Visual style |

**Note on dual models:** When using Auto/Prompt AI mode, two models are involved:
- **Prompt Generation Model** (LLM) — Creates optimized image prompt
- **Image Model** — Generates the actual image

**Accessing output:**
```handlebars
{{image_gen.output.imageUrl}}            <!-- Signed URL (valid 1 week) -->
{{image_gen.output.attachmentId}}        <!-- Attachment ID -->
{{image_gen.output.prompt}}              <!-- Prompt used -->
{{image_gen.output.aspectRatio}}         <!-- Aspect ratio used -->
{{image_gen.output._metadata.mimeType}} <!-- Always "image/png" -->
```

**Output JSON structure:**
```json
{
  "path": "/mnt/data/filename.png",
  "_metadata": {
    "name": "filename.png",
    "mimeType": "image/png",
    "sizeInKb": 245,
    "attachmentId": "abc123"
  },
  "imageUrl": "https://...",
  "attachmentId": "abc123",
  "prompt": "Your prompt here",
  "aspectRatio": "square"
}
```

**Limitations:**
- Timeout: 60 seconds
- Format: Always PNG
- No image-to-image (reference images not supported)
- Signed URLs expire after 1 week

---

### 3.7 Human in the Loop

Pause workflow execution and require manual approval before proceeding.

**How it works:**
1. Workflow reaches approval step → execution pauses
2. Editors receive notification
3. Editor reviews and approves (or declines)
4. Workflow resumes (or stops if declined)

**Who can approve:** Anyone with **editor** access to the workflow.

**Use cases:**
- Financial transactions over a threshold
- Data deletion (irreversible operations)
- Customer communications requiring review
- Production system changes
- Compliance-sensitive actions

**Smart pattern — conditional approval:**
```
Agent: Calculate invoice amount

Condition: Amount > $5000?
├─ Yes → Approval: Review high-value payment
│        → Action: Create payment
└─ No → Action: Create payment (auto-approved)
```

**Best practices:**
- Only use for truly sensitive actions (not every step)
- Provide enough context at the approval step (amounts, recipients, previews)
- Plan for who on the team can approve time-sensitive workflows
- Test approval flow to ensure notifications arrive correctly

---

### 3.8 Cost Management

#### What Costs Credits

| Node Type | Cost |
|-----------|------|
| Agent node | Credits per token (model-dependent) |
| Web Search | Small fee per search |
| Image Generation | Model credits per image |
| Action, Code, Condition, Loop, Delay, HTTP, Notification | **Free** |

#### Monitoring Costs

- **Per-node**: After run, each node shows cost badge in footer (hover for token breakdown)
- **Per-run**: Click any run in Runs tab → total cost + per-node breakdown
- **Aggregate**: History panel shows total runs, nodes executed, total cost, average cost/run

#### Setting Cost Limits (per workflow)

In workflow **Settings** panel:

| Limit | Description |
|-------|-------------|
| **Monthly Limit** | Max spend per month (new runs blocked when reached; scheduled workflows deactivated) |
| **Per-Execution Limit** | Stops a single run if it exceeds this amount (catches runaway loops) |
| **Hourly Rate Limit** | Max executions per hour (prevents trigger floods) |
| **Alert Thresholds** | Email notifications at custom amounts + built-in at 50%/90% of monthly limit |

#### Workspace-Level Limits (Admin-set)

| Setting | Description |
|---------|-------------|
| **Workspace Spend Cap** | Max total spend across all workflows (default: €500/month) |
| **Max Monthly Limit Per Workflow** | Caps what users can set as their workflow's limit |
| **Monthly Run Limit** | Max total workflow executions per month (plan-based) |

**Hierarchy:** Workspace limits override workflow limits. Users cannot set their workflow limit above admin's max.

#### Optimization Strategies

```
# Use smaller models for simple tasks
Extract email from text → small model ✅
Complex reasoning → large model ✅
Date formatting → Code node (free) ✅

# Filter before sending to AI
Trigger (100 items) → Code: filter relevant (20 items) → Agent (20 items, not 100)

# Progressive enhancement
Data → Quick code check → [Simple] → Done
                        → [Complex] → AI analysis

# Smart loops — don't process everything with AI
Loop (100 items) → Code: is relevant? → [Yes] → Agent
                                       → [No] → Skip
```

#### Estimating Costs Before Launch

```
Average cost per run: $0.13 (from test runs)
Expected monthly runs: 1,000
Estimated monthly cost: $130
Buffer (20%): $26
Set monthly limit: $160
Set per-run limit: $1.00 (catches anomalies)
```

### 3.9 Triggering Workflows from Chat

Workflows can be triggered directly from Langdock chat conversations.

**Two methods:**

| Method | How |
|--------|-----|
| **@-mention** | Type `@` in chat → select workflow from Workflows section |
| **Agent with workflows** | Agent has workflows as actions → AI decides when to call them |

#### Supported Trigger Types in Chat

| Trigger | In Chat? | Notes |
|---------|----------|-------|
| Manual | ✅ Yes | Simple confirm-and-run |
| Form | ✅ Yes | Form fields rendered inline; FILE fields auto-filled |
| Scheduled | ✅ Yes | Can be triggered on-demand |
| Webhook | ❌ No | External HTTP only |
| Integration | ❌ No | External event only |

**Requirements for @-mention:**
- Workflow belongs to your workspace
- You have access (public, workspace-wide, or shared)
- Workflow is **active** (published)
- Supported trigger type

#### Confirmation Flow

Every chat-triggered workflow requires explicit confirmation before execution.

- **Manual/Scheduled**: Compact panel with "Trigger" / "Decline" buttons
- **Form**: Form fields rendered inline; click "Trigger" or "Decline"

After confirmation, live status:

| State | What You See |
|-------|-------------|
| Running | Animated "Running [name]..." indicator |
| Completed | "Ran [name] in X seconds" + output below |
| Failed | Red error panel with failure message and node name |
| Declined | Amber "Workflow declined" notice |

Output appears inline from the **Output node**. If no Output node → generic "completed" message.

#### Attaching Workflows to Agents

1. Open agent in **Agent Builder**
2. Go to **Actions** section
3. Click **Add Tool** → **Workflows** tab
4. Select workflow to attach

The workflow becomes a tool the agent can call. Tool name is derived from workflow name (e.g., "Summarize Report" → `workflow_summarize_report`, max 63 chars).

For **form-trigger** workflows: form field definitions become the tool's input schema. AI fills form fields from conversation context.

#### Access Control

| Workflow access | Can trigger from chat? |
|-----------------|----------------------|
| Public | Yes — all workspace members |
| Workspace | Yes — all workspace members |
| Private (shared with you) | Yes |
| Private (not shared) | No — Access Denied at execution time |

**Note for agent-attached workflows:** Access check happens at execution time, not when you open the agent. If denied: "You do not have access to the [workflow name] workflow" message.

#### Limitations

| Limitation | Details |
|------------|---------|
| Mobile | Workflows cannot be triggered from mobile app |
| A2A | Sub-agents in Agent-to-Agent cannot trigger workflows |
| File pre-fill cap | Max 10 conversation attachments for FILE fields |
| Tool name length | Max 63 characters (provider constraint) |
| One call per response | AI calls workflow only once per reply |
| Always requires confirmation | No auto-execute mode |

---

## 4. Integrations

### 4.1 Overview

Integrations connect Langdock to the tools your team already uses. They provide:

- **Actions** — Functions agents and workflows can call (create ticket, send email, get data)
- **Triggers** — Event monitors that start workflows (new email, file uploaded)

**Pre-built integrations available for:** Slack, Teams, Gmail, Outlook, Google Drive, Salesforce, HubSpot, Jira, Confluence, Notion, GitHub, Stripe, Google Calendar, Databricks, Looker, Metabase, ServiceNow, Zoom, Ashby, Azure AI Search, Google Maps, Microsoft Entra, Luma, and many more.

**Custom integrations:** Build your own connector to any API-enabled tool.

**Connections:** When you authenticate with an integration, you create a **connection**. Connections can be:
- Personal (only you)
- Shared (pre-selected for agents/workflows used by others)

### 4.2 Creating Custom Integrations

Custom integrations let you connect any API-enabled tool.

#### Step 1: Create Integration

In [integrations menu](https://app.langdock.com/integrations) → **Add integration** → specify name, upload icon, add description → **Save**

#### Step 2: Configure Authentication

**No authentication (public APIs):** Select `None`.

**API Key authentication:**
1. Select "API Key" auth type
2. Add custom input fields (e.g., `api_key`, `base_url`) — users fill these when connecting
3. Optionally add auth test code to validate credentials

Auth test code example:
```javascript
const response = await ld.request({
  method: 'GET',
  url: data.auth.base_url + '/me',
  headers: { 'Authorization': 'Bearer ' + data.auth.api_key }
});
if (!response.ok) throw new Error('Invalid credentials');
return { success: true };
```

**OAuth 2.0:**
1. Select "OAuth" auth type
2. Add optional custom input fields (extra params beyond client ID/secret)
3. Create OAuth client in target application, enable required APIs
4. Set Authorization URL (change `BASE_URL` in template):
   ```javascript
   return `https://accounts.google.com/o/oauth2/v2/auth?client_id=${env.CLIENT_ID}&response_type=code&scope=${data.input.scope}&access_type=offline&redirect_uri=${encodeURIComponent(data.input.redirectUrl)}&state=${data.input.state}&prompt=consent`;
   ```
5. Define OAuth scopes (space or comma-separated per API docs)
6. Set Access Token URL and Refresh Token URL:
   ```javascript
   const tokenUrl = 'https://oauth2.googleapis.com/token';
   ```
7. Enter Client ID and Client Secret in Langdock
8. Set test endpoint to validate auth

**Auth code environment variables:**
- `data.auth.{fieldId}` — Values from auth fields users filled in
- `data.input.redirectUrl`, `data.input.state`, `data.input.scope` — OAuth flow params
- `env.CLIENT_ID`, `env.CLIENT_SECRET` — OAuth credentials

#### Step 3: Build Actions

Actions are capabilities that agents and workflows can execute.

**Action types:**
- **Regular Actions** — Standard CRUD operations, data fetch, notifications
- **Native Actions** — File search/download (requires special output format)

**Input field types for actions:**

| Type | Purpose |
|------|---------|
| `TEXT` | Short text (single line) |
| `MULTI_LINE_TEXT` | Long text (multi-line) |
| `NUMBER` | Numeric input |
| `BOOLEAN` | True/false toggle |
| `SELECT` | Dropdown with options |
| `FILE` | File upload |
| `OBJECT` | JSON object |
| `PASSWORD` | Hidden/sensitive input |
| `ID` | Identifier input |

**Action code environment:**
- `data.input.{fieldId}` — Input field values
- `data.auth.{fieldId}` — Auth field values (credentials)
- `ld.request()` — HTTP requests
- `ld.log()` — Debug logging
- Standard JavaScript built-ins

**Example action — create ticket:**
```javascript
if (!data.input.title) return { error: "Title is required" };

const response = await ld.request({
  method: "POST",
  url: "https://api.ticketing-service.com/tickets",
  headers: {
    Authorization: `Bearer ${data.auth.api_key}`,
    "Content-Type": "application/json",
  },
  body: {
    title: data.input.title,
    description: data.input.description || "",
    priority: data.input.priority || "medium",
  },
});

if (response.status === 201) {
  return {
    success: true,
    ticketId: response.json.id,
    url: response.json.url,
    message: `Created ticket #${response.json.id}: ${data.input.title}`,
  };
} else {
  throw new Error(`API returned status ${response.status}`);
}
```

**Returning files from actions:**
```javascript
return {
  files: {
    fileName: `export-${Date.now()}.csv`,
    mimeType: "text/csv",
    text: csvContent,       // use 'text' for UTF-8, 'base64' for binary
  },
  success: true,
  exported: data.length,
};
```

**File input in actions (FILE field type):**
```javascript
const document = data.input.document; // FileData object
// document.mimeType, document.fileName, document.base64
```

**Native action output format (Search Files):**
```typescript
{
  url: string,
  documentId: string,
  title: string,
  mimeType: string,
  author?: { id: string, name: string },
  lastSeenByUser: Date,
  createdDate: Date,
  lastModifiedByAnyone: Date,
  parent?: { id: string, title?: string, url?: string }
}
```

#### Step 4: Build Triggers

Triggers monitor external systems and fire when events occur.

**Required return format:**
```javascript
return [
  {
    id: "unique_event_id",       // Required: unique identifier
    timestamp: "2024-01-15T...", // Required: ISO timestamp
    data: {
      // Your event data
      eventType: "new_email",
      subject: "Important message",
      from: "sender@example.com",
    },
  },
];
```

**Polling trigger code environment:**
- `data.input.{fieldId}` — Input field values
- `data.auth.{fieldId}` — Auth credentials
- `lastPollTime` — Timestamp of last successful poll
- `ld.request()`, `ld.log()` — Utilities

**Example trigger — new email:**
```javascript
const response = await ld.request({
  method: "GET",
  url: "https://api.email-service.com/messages",
  headers: { Authorization: `Bearer ${data.auth.access_token}` },
  params: {
    since: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
    limit: 10,
  },
});

const emails = response.json.messages || [];
return emails.map((email) => ({
  id: email.id,
  timestamp: email.receivedAt,
  data: {
    subject: email.subject,
    from: email.from,
    body: email.body,
    isRead: email.isRead,
  },
}));
```

**Trigger with file attachments:**
```javascript
const attachments = [];
for (const attachment of email.attachments) {
  const fileResponse = await ld.request({
    method: "GET",
    url: `https://api.email-service.com/attachments/${attachment.id}`,
    headers: { Authorization: `Bearer ${data.auth.access_token}` },
    responseType: "stream",
  });
  
  attachments.push({
    fileName: attachment.filename,
    mimeType: attachment.mimeType,
    base64: Buffer.from(fileResponse.buffer).toString("base64"),
  });
}

return [{
  id: email.id,
  timestamp: email.receivedAt,
  data: { subject: email.subject, files: attachments }
}];
```

> **Note:** The trigger builder currently supports **polling triggers** only. Webhook (REST_HOOK) triggers are available via the API but not yet in the UI.

### 4.3 Sandbox Utility Functions

Built-in JavaScript utilities available in custom integration code, action code, trigger code, and workflow code nodes (not Python).

#### `ld.request()` — HTTP Requests

```typescript
// Parameters
{
  method: string;           // 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'
  url: string;
  headers?: object;
  params?: object;          // URL query parameters
  body?: object | string;   // Auto-stringified if object
  responseType?: string;    // 'json' (default), 'text', 'stream', 'binary'
}

// Returns (default)
{ status: number, headers: object, json: any, text: string }

// Returns (stream/binary)
{ status: number, headers: object, buffer: ArrayBuffer, success: boolean }
```

Examples:
```javascript
// GET request
const response = await ld.request({
  method: "GET",
  url: "https://api.example.com/users/123",
  headers: { Authorization: `Bearer ${data.auth.access_token}` },
});
return response.json;

// POST with body
const response = await ld.request({
  method: "POST",
  url: "https://api.example.com/tickets",
  headers: { "Content-Type": "application/json" },
  body: { title: data.input.title, priority: "high" },
});

// File download
const response = await ld.request({
  method: "GET",
  url: `https://api.example.com/files/${data.input.fileId}/download`,
  headers: { Authorization: `Bearer ${data.auth.access_token}` },
  responseType: "stream",
});
const bytes = new Uint8Array(response.buffer);
const base64 = btoa(String.fromCharCode(...bytes));
return { files: { fileName: "doc.pdf", mimeType: "application/pdf", base64 } };
```

#### `ld.awsRequest()` — AWS SigV4-Signed Requests

```javascript
const response = await ld.awsRequest({
  method: "PUT",
  url: `https://my-bucket.s3.us-east-1.amazonaws.com/${data.input.fileName}`,
  headers: { "Content-Type": data.input.mimeType },
  body: Buffer.from(data.input.file.base64, "base64"),
  region: "us-east-1",
  service: "s3",
  credentials: {
    accessKeyId: data.auth.aws_access_key_id,
    secretAccessKey: data.auth.aws_secret_access_key,
  },
});
```

#### Data Format Conversions

```javascript
// CSV → Parquet
const result = await ld.csv2parquet(csvText, { compression: "gzip" });
// result.base64, result.success

// Parquet → CSV
const result = await ld.parquet2csv(base64Parquet);
// result.base64, result.success

// Arrow → Parquet
const parquetBase64 = await ld.arrow2parquet(arrowBuffer, { compression: "snappy" });

// JSON array → CSV
const csvText = await ld.json2csv([{ name: "Alice", age: 30 }, ...]);
```

#### SQL Validation

```javascript
// Validate non-empty, single statement SQL
ld.validateSqlQuery(query);      // Throws if invalid

// Enforce read-only (SELECT only)
ld.ensureReadOnlySqlQuery(query); // Throws if INSERT/UPDATE/DELETE
```

#### Cryptography

```javascript
// RSA-SHA256 signing (for JWT, OAuth)
const result = ld.signWithRS256(signingInput, data.auth.private_key, {
  encoding: "base64",  // or "hex"
});
// result.signature
```

#### Utility Functions

```javascript
// Debug logging (visible in test output)
ld.log("Starting:", data.input);

// Wait/pause (0-30000ms)
await ld.wait(2000); // 2 second pause

// Base64 encoding/decoding (global, no import needed)
const encoded = btoa("hello world");
const decoded = atob(encoded);
```

---

## 5. Knowledge Folders

Knowledge Folders (now called **Folders**) are collections of documents embedded for semantic search. Find them in **Library → Folders**.

### Supported File Types

- PDF (`.pdf`) — up to 256MB
- Word Documents (`.doc`, `.docx`)
- Text files (`.txt`)
- Markdown (`.md`)
- HTML (`.html`)
- PowerPoint (`.pptx`, `.ppt`)

> **Not supported:** CSV, Excel, and executable files.

### Processing Status

When a file is uploaded, it goes through these stages:

| Status | Description |
|--------|-------------|
| `UPLOADING` | File is being uploaded |
| `UPLOADED` | Uploaded, queued for processing |
| `EXTRACTING` | Text extraction in progress |
| `EMBEDDING` | Vector embeddings being generated |
| `SYNCED` | Ready for search ✅ |
| `ACTION_FAILED` | Processing action failed ❌ |
| `EXTRACTION_FAILED` | Text extraction failed ❌ |
| `EMBEDDING_FAILED` | Embedding generation failed ❌ |
| `TIMEOUT` | Processing timed out ❌ |

### Sharing with API

1. Create API key with `KNOWLEDGE_FOLDER_API` scope
2. Open the folder → Share → search for API key by name
3. Choose role: **User** (search access) or **Editor** (upload + manage)

---

## 6. API Reference (Complete)

### 6.1 Authentication & Base URLs

```
Base URL (Cloud):      https://api.langdock.com
Base URL (Dedicated):  https://<your-domain>/api/public

Authentication header: Authorization: Bearer YOUR_API_KEY
```

**API Key Scopes:**

| Scope | Access |
|-------|--------|
| `ASSISTANT_API` | Legacy assistant completions + list integrations |
| `AGENT_API` | Agent CRUD and completions |
| `KNOWLEDGE_FOLDER_API` | Knowledge folder read/write + upload attachments |
| `INTEGRATION_API` | Create/manage custom integrations |

Create API keys in: **Workspace Settings → Products → API**

---

### 6.2 Agent Completions API

Send messages to an agent and receive a response.

**Endpoint:** `POST https://api.langdock.com/agent/v1/chat/completions`

**Required scope:** `AGENT_API` (agent must be shared with API key)

**Request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agentId` | string | One of agentId/agent | ID of existing agent |
| `agent` | object | One of agentId/agent | Inline temporary agent config |
| `messages` | array | Yes | Array of UIMessage objects |
| `stream` | boolean | No | Enable streaming (default: false) |
| `output` | object | No | Structured output format spec |
| `maxSteps` | integer | No | Max tool steps (1–20) |
| `imageResponseFormat` | string | No | `"url"` or `"b64_json"` for generated images |

> **Non-streaming timeout:** 100 seconds. Use `stream: true` for long-running agents.

**UIMessage format:**
```typescript
interface UIMessage {
  id: string;          // Unique message ID
  role: 'user' | 'assistant' | 'system';
  parts: MessagePart[];
  metadata?: {
    attachments?: string[];  // Array of attachment UUIDs
  };
}
```

**User message part types:**

| Type | Fields |
|------|--------|
| `text` | `type: "text"`, `text: string` |
| `file` | `type: "file"`, `mediaType: string`, `url: string`, `filename?: string` |

**Assistant message part types (include in history for multi-turn):**

| Type | Key Fields |
|------|-----------|
| `text` | `type: "text"`, `text: string` |
| `reasoning` | `type: "reasoning"`, `text: string` |
| `tool-{name}` | `toolCallId`, `state`, `input?`, `output?`, `errorText?` |
| `source-url` | `sourceId`, `url`, `title?` |
| `source-document` | `sourceId`, `mediaType`, `title`, `filename?` |

**Inline agent configuration (when using `agent` parameter):**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Agent name (max 64 chars) |
| `instructions` | string | System prompt (max 16,384 chars) |
| `description` | string | Description (max 256 chars) |
| `temperature` | number | 0–1 |
| `model` | string | Model ID (from Models API) |
| `capabilities` | object | `{webSearch, dataAnalyst, imageGeneration, canvas}` |
| `knowledgeFolderIds` | string[] | Folder IDs |

> **Warning:** Inline `agent` field uses `instructions` (plural) and `temperature`, while CRUD endpoints use `instruction` (singular) and `creativity`. These field names differ.

**Structured output parameter:**

| Field | Type | Description |
|-------|------|-------------|
| `type` | "object" \| "array" \| "enum" | Output structure type |
| `schema` | object | JSON Schema for object/array |
| `enum` | string[] | Allowed values for enum type |

**Tool usage note:** For agent tools to work via API, the integration connection must be set to "preselected connection" (shared). Tools with "Require human confirmation" do NOT work via API.

**Attaching files to messages:**
1. Upload via Upload Attachment API → get `attachmentId` (UUID)
2. Include in message: `metadata: { attachments: ["uuid-here"] }`

> Do NOT use `type: "file"` parts for uploaded attachments — that is reserved for inline data URIs.

**Complete example — existing agent with attachment:**
```javascript
const response = await fetch(
  "https://api.langdock.com/agent/v1/chat/completions",
  {
    method: "POST",
    headers: {
      "Authorization": "Bearer YOUR_API_KEY",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      agentId: "agent_123",
      messages: [
        {
          id: "msg_1",
          role: "user",
          parts: [{ type: "text", text: "Analyze this document for me" }],
          metadata: {
            attachments: ["550e8400-e29b-41d4-a716-446655440000"]
          }
        }
      ]
    })
  }
);
const data = await response.json();
console.log(data.messages[0].content); // Agent's text response
```

**Temporary agent with structured output:**
```javascript
const response = await fetch(
  "https://api.langdock.com/agent/v1/chat/completions",
  {
    method: "POST",
    headers: {
      "Authorization": "Bearer YOUR_API_KEY",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      agent: {
        name: "Weather Agent",
        instructions: "You are a helpful weather agent",
        model: "gpt-5",
        capabilities: { webSearch: true }
      },
      messages: [{
        id: "msg_1",
        role: "user",
        parts: [{ type: "text", text: "Weather in Paris, Berlin, and London?" }]
      }],
      output: {
        type: "array",
        schema: {
          type: "object",
          properties: {
            weather: {
              type: "object",
              properties: {
                city: { type: "string" },
                tempInCelsius: { type: "number" },
                tempInFahrenheit: { type: "number" }
              },
              required: ["city", "tempInCelsius", "tempInFahrenheit"]
            }
          }
        }
      }
    })
  }
);
const data = await response.json();
console.log(data.output); // Array of weather objects
```

**Streaming with Vercel AI SDK `useChat`:**
```typescript
'use client';
import { useChat } from '@ai-sdk/react';

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: 'https://api.langdock.com/agent/v1/chat/completions',
    headers: { 'Authorization': `Bearer ${process.env.NEXT_PUBLIC_LANGDOCK_API_KEY}` },
    body: { agentId: 'your-agent-id' }
  });
  // render messages, input form...
}
```

**Streaming manual handling:**
```javascript
const response = await fetch('https://api.langdock.com/agent/v1/chat/completions', {
  method: 'POST',
  headers: { 'Authorization': 'Bearer YOUR_API_KEY', 'Content-Type': 'application/json' },
  body: JSON.stringify({ agentId: 'agent_123', messages: [...], stream: true }),
});
const reader = response.body.getReader();
const decoder = new TextDecoder();
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(decoder.decode(value)); // Process streaming chunks
}
```

**Response format:**
```typescript
{
  messages: Array<{
    id: string;
    role: "assistant";
    content: string;  // Agent's text response
  }>;
  output?: object | array | string;  // Only when output parameter was provided
}
```

**Error codes:**
| Code | Meaning |
|------|---------|
| 400 | Invalid params, malformed messages, agent not found, not shared with API key |
| 401 | Invalid/missing API key |
| 429 | Rate limit exceeded (500 RPM / 60k TPM default) |
| 500 | Server error |

---

### 6.3 Agent CRUD API

#### Create Agent

**Endpoint:** `POST https://api.langdock.com/agent/v1/create`

**Required scope:** `AGENT_API`

**Request parameters:**

| Parameter | Type | Required | Limit | Description |
|-----------|------|----------|-------|-------------|
| `name` | string | Yes | 1–80 chars | Agent name |
| `description` | string | No | max 500 chars | What the agent does |
| `emoji` | string | No | max 16 chars | Emoji icon (e.g., "🤖") |
| `instruction` | string | No | max 40,000 chars | System prompt |
| `inputType` | string | No | — | "PROMPT" (default) or "STRUCTURED" |
| `model` | string | No | — | Model ID from Models API; workspace default if omitted |
| `creativity` | number | No | 0–1 | Temperature (default: 0.3) |
| `conversationStarters` | string[] | No | max 20, each 1–255 chars | Suggested prompts |
| `actions` | array | No | — | Array of `{actionId, requiresConfirmation?}` |
| `inputFields` | array | No | — | Form fields (for STRUCTURED input type) |
| `attachments` | string[] | No | — | Attachment UUIDs |
| `webSearch` | boolean | No | — | Enable web search (default: false) |
| `imageGeneration` | boolean | No | — | Enable image generation (default: false) |
| `dataAnalyst` | boolean | No | — | Enable Python code interpreter (default: false) |
| `canvas` | boolean | No | — | Enable canvas (default: false) |
| `extendedThinking` | boolean | No | — | Enable extended thinking (default: false) |

**Input fields (for STRUCTURED inputType):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slug` | string | Yes | Unique identifier |
| `type` | string | Yes | TEXT, MULTI_LINE_TEXT, NUMBER, CHECKBOX, FILE, SELECT, DATE, EMAIL |
| `label` | string | Yes | Display label |
| `description` | string | No | Help text |
| `required` | boolean | No | Default: false |
| `order` | number | Yes | Display order (0-indexed) |
| `options` | string[] | No | For SELECT type |
| `fileTypes` | string | No | Allowed file types for FILE type (nullable) |
| `emailDomain` | string | No | Allowed domain for EMAIL type |

**Example:**
```javascript
const response = await axios.post(
  "https://api.langdock.com/agent/v1/create",
  {
    name: "Document Analyzer",
    description: "Analyzes and summarizes documents",
    emoji: "📄",
    instruction: "You are a helpful agent that analyzes documents and provides clear summaries.",
    creativity: 0.5,
    conversationStarters: ["Summarize this document", "What are the key points?"],
    dataAnalyst: true,
    webSearch: false
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
console.log("Agent created:", response.data.agent.id);
```

**Success response (201):**
```typescript
{
  status: "success";
  message: "Agent created successfully";
  agent: {
    id: string;
    name: string;
    description: string;
    instruction: string;
    emojiIcon: string;
    model: string;
    temperature: number;
    conversationStarters: string[];
    inputType: "PROMPT" | "STRUCTURED";
    webSearchEnabled: boolean;
    imageGenerationEnabled: boolean;
    codeInterpreterEnabled: boolean;
    canvasEnabled: boolean;
    extendedThinking: boolean;
    actions: Array<{ actionId: string; requiresConfirmation: boolean }>;
    inputFields: Array<{ slug, type, label, description, required, order, options, fileTypes, emailDomain }>;
    attachments: string[];
    createdAt: string;
    updatedAt: string;
  };
}
```

**Notes:**
- Created agents are automatically shared with the creating API key
- API key creator becomes owner
- Pre-selected OAuth connections NOT supported via API; users must configure OAuth in UI

**Error codes:** 400 (invalid params), 401 (bad key), 403 (insufficient permissions / requires AGENT_API scope), 429 (rate limit), 500 (server error)

---

#### Get Agent

**Endpoint:** `GET https://api.langdock.com/agent/v1/get?agentId=UUID`

**Required scope:** `AGENT_API`

Returns the agent's **active (published)** version. If never published, returns current draft.

```javascript
const response = await axios.get(
  "https://api.langdock.com/agent/v1/get",
  {
    params: { agentId: "550e8400-e29b-41d4-a716-446655440000" },
    headers: { Authorization: "Bearer YOUR_API_KEY" }
  }
);
console.log(response.data.agent);
```

**Success response (200):** Same `agent` object structure as Create.

**Error codes:** 400 (invalid ID), 401 (bad key), 403 (no access), 404 (not found), 500

---

#### Update Agent

**Endpoint:** `PATCH https://api.langdock.com/agent/v1/update`

**Required scope:** `AGENT_API`

Updates the agent's **draft** only. Changes are not visible until published.

**Key behaviors:**
- Only provided fields are updated (partial update)
- **Array fields replace entirely:** `actions`, `inputFields`, `conversationStarters`, `attachments` — always provide complete desired array
- Send `[]` to remove all items in an array field
- Send `null` for `emoji` to clear it
- Send `""` for `description` or `instruction` to clear them

**Request parameters:** Same as Create, plus `agentId` (required). `agentId` is the only truly required field.

```javascript
const response = await axios.patch(
  "https://api.langdock.com/agent/v1/update",
  {
    agentId: "550e8400-e29b-41d4-a716-446655440000",
    name: "Advanced Document Analyzer",
    creativity: 0.7
    // Only these fields will change; others stay as-is
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
```

**Success response (200):** Same `agent` object structure.

**Error codes:** 400, 401, 403, 404, 429, 500

---

#### Publish Agent

**Endpoint:** `POST https://api.langdock.com/agent/v1/publish`

Promotes the current draft to a new active version (like clicking "Update" in the UI).

**Request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agentId` | string | Yes | Agent UUID |
| `description` | string | No | max 100 chars — change description shown in version history |

```javascript
const response = await axios.post(
  "https://api.langdock.com/agent/v1/publish",
  {
    agentId: "550e8400-e29b-41d4-a716-446655440000",
    description: "Tightened the system prompt"
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
console.log("Published version:", response.data.version);
```

**Success response (200):**
```typescript
{
  status: "success";
  message: "Agent published successfully";
  version: {
    id: string;        // UUID of new version
    version: number;   // Monotonically increasing version number
    createdAt: string; // ISO 8601 timestamp
  };
}
```

**Error codes:**
| Code | Meaning |
|------|---------|
| 400 | Invalid request body |
| 401 | Bad API key |
| 403 | No edit access, wrong workspace, or resource is a project |
| 409 | No draft changes to publish |
| 429 | Rate limit |

---

#### Disable/Enable Agent

**Endpoint:** `PATCH https://api.langdock.com/agent/v1/disable`

**Request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `agentId` | string | Yes | Agent UUID |
| `disabled` | boolean | Yes | `true` = disable, `false` = enable |

```javascript
// Disable
await axios.patch("https://api.langdock.com/agent/v1/disable",
  { agentId: "uuid", disabled: true },
  { headers: { Authorization: "Bearer YOUR_API_KEY" } }
);

// Re-enable
await axios.patch("https://api.langdock.com/agent/v1/disable",
  { agentId: "uuid", disabled: false },
  { headers: { Authorization: "Bearer YOUR_API_KEY" } }
);
```

**Behavior when disabled:**
- Users cannot start new conversations
- Agent hidden from library for regular users
- Admins can still view/manage
- Can be re-enabled anytime

**Success response (200):**
```typescript
{ status: "success"; message: "Agent disabled successfully" | "Agent enabled successfully" }
```

**Error codes:** 400, 401, 403, 404, 429

---

### 6.4 Models API

**Endpoint:** `GET https://api.langdock.com/agent/v1/models`

Returns available models for use with the Agent API.

```javascript
const response = await axios.get("https://api.langdock.com/agent/v1/models", {
  headers: { Authorization: "Bearer YOUR_API_KEY" }
});
console.log(response.data.data); // Array of model objects
```

**Response:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "gpt-5",
      "object": "model",
      "created": 1686935735000,
      "region": "eu",
      "supportsExtendedThinking": false
    }
  ]
}
```

**Model fields:**

| Field | Description |
|-------|-------------|
| `id` | Model ID to use in `model` field of agent config |
| `object` | Always `"model"` |
| `created` | Unix timestamp (ms) |
| `region` | Where model is available (`"eu"`, `"us"`, `"global"`) |
| `supportsExtendedThinking` | Whether model supports extended thinking mode |

---

### 6.5 Upload Attachment API

**Endpoint:** `POST https://api.langdock.com/attachment/v1/upload`

**Required scope:** `KNOWLEDGE_FOLDER_API`

**Request format:** `multipart/form-data`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | File | Yes | The file to upload |

```javascript
const FormData = require("form-data");
const fs = require("fs");

const form = new FormData();
form.append("file", fs.createReadStream("example.pdf"));

const response = await axios.post(
  "https://api.langdock.com/attachment/v1/upload",
  form,
  {
    headers: { ...form.getHeaders(), Authorization: "Bearer YOUR_API_KEY" }
  }
);

console.log(response.data);
// {
//   attachmentId: "550e8400-e29b-41d4-a716-446655440000",
//   file: { name: "example.pdf", mimeType: "application/pdf", sizeInBytes: 1234567 }
// }
```

**Using the attachmentId:**
- **Per-message** (recommended): `metadata: { attachments: ["uuid"] }` on individual message
- **Agent-level**: `attachments: ["uuid"]` when creating/updating agent

---

### 6.6 Integrations API

**Base URL:** `https://api.langdock.com`

**Required scope:** `INTEGRATION_API` (for all endpoints except list, which also accepts `ASSISTANT_API`)

#### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/integrations/v1/get` | List all integrations |
| `POST` | `/integrations/v1/create` | Create a new integration |
| `GET` | `/integrations/v1/{integrationId}` | Get integration details |
| `PATCH` | `/integrations/v1/{integrationId}` | Update integration |
| `PATCH` | `/integrations/v1/{integrationId}/auth` | Update auth configuration |
| `POST` | `/integrations/v1/{integrationId}/actions/create` | Create an action |
| `PUT` | `/integrations/v1/{integrationId}/actions/{actionId}` | Update an action |
| `DELETE` | `/integrations/v1/{integrationId}/actions/{actionId}` | Delete an action |
| `POST` | `/integrations/v1/{integrationId}/triggers/create` | Create a trigger |
| `PUT` | `/integrations/v1/{integrationId}/triggers/{triggerId}` | Update a trigger |
| `DELETE` | `/integrations/v1/{integrationId}/triggers/{triggerId}` | Delete a trigger |

---

#### Create Integration

**Endpoint:** `POST https://api.langdock.com/integrations/v1/create`

| Parameter | Type | Required | Limit |
|-----------|------|----------|-------|
| `name` | string | Yes | max 40 chars |
| `description` | string | No | max 90 chars |

```javascript
const response = await axios.post(
  "https://api.langdock.com/integrations/v1/create",
  { name: "My Custom Integration", description: "Connects to my internal API" },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
const integrationId = response.data.integration.id;
```

**Success (201):** `{ integration: { id, name, description, createdAt } }`

---

#### Update Auth Configuration

**Endpoint:** `PATCH https://api.langdock.com/integrations/v1/{integrationId}/auth`

> **Warning:** Changing `authType` **deletes all existing user connections**.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `authType` | string | Yes | `NONE`, `API_KEY`, `OAUTH`, `OAUTH_DCR` |
| `authFields` | array | No | Fields users fill when connecting |
| `authTestCode` | string | No | JS code to validate credentials (max 1,000 chars) |
| `oauthClient` | object | No | OAuth config (for OAUTH/OAUTH_DCR only) |

**Auth field schema:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `slug` | string | Yes | Unique ID (max 100 chars) |
| `label` | string | Yes | Display label (max 100 chars) |
| `type` | string | Yes | TEXT, MULTI_LINE_TEXT, PASSWORD, NUMBER, EMBEDDING_MODEL |
| `description` | string | No | Help text (max 500 chars) |
| `placeholder` | string | No | Placeholder text (max 200 chars) |
| `required` | boolean | No | Default: false |

**OAuth client schema:**

| Property | Description |
|----------|-------------|
| `scopes` | Space-separated OAuth scopes (max 2,000 chars) |
| `authUrl` | Authorization endpoint URL |
| `tokenUrl` | Token endpoint URL |
| `clientId` | OAuth client ID (max 500 chars) |
| `clientSecret` | OAuth client secret (max 500 chars; write-only) |
| `label` | Connect button label (max 100 chars) |
| `authorizationCode` | Custom auth code (max 1,000 chars) |
| `accessTokenCode` | Custom token code (max 1,000 chars) |
| `refreshTokenCode` | Custom refresh code (max 1,000 chars) |

> OAuth credentials are write-only — never returned in API responses.

**Example — API key auth:**
```javascript
await axios.patch(
  `https://api.langdock.com/integrations/v1/${integrationId}/auth`,
  {
    authType: "API_KEY",
    authFields: [
      { slug: "api_key", label: "API Key", type: "PASSWORD", required: true },
      { slug: "base_url", label: "Base URL", type: "TEXT", required: true }
    ],
    authTestCode: `
      const response = await fetch(secrets.base_url + '/me', {
        headers: { 'Authorization': 'Bearer ' + secrets.api_key }
      });
      if (!response.ok) throw new Error('Invalid credentials');
    `
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
```

**Auth field behavior:** Auth fields are fully replaced on every call.

---

#### Create Action

**Endpoint:** `POST https://api.langdock.com/integrations/v1/{integrationId}/actions/create`

| Parameter | Type | Required | Limit |
|-----------|------|----------|-------|
| `name` | string | Yes | max 100 chars |
| `description` | string | No | max 1,000 chars |
| `code` | string | No | JS code, max 40,000 chars |
| `inputFields` | array | No | Array of input field objects |

**Input field schema:**

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `label` | string | Yes | Display label (max 100 chars) |
| `type` | string | No | TEXT, MULTI_LINE_TEXT, NUMBER, BOOLEAN, SELECT, PASSWORD, VECTOR, OBJECT, FILE, ID |
| `description` | string | No | Help text (max 500 chars) |
| `placeholder` | string | No | max 200 chars |
| `required` | boolean | No | Default: false |
| `options` | array | No | For SELECT fields: `[{label, value}]` |
| `allowMultiSelect` | boolean | No | Allow multiple SELECT choices |
| `contextActionId` | string | No | UUID of action for dynamic options |

```javascript
const response = await axios.post(
  `https://api.langdock.com/integrations/v1/${integrationId}/actions/create`,
  {
    name: "Get User Data",
    description: "Retrieves user information by user ID",
    code: `
      const response = await fetch('https://api.example.com/users/' + inputs.userId, {
        headers: { 'Authorization': 'Bearer ' + secrets.API_TOKEN }
      });
      if (!response.ok) throw new Error('User not found');
      return await response.json();
    `,
    inputFields: [
      { label: "User ID", type: "TEXT", description: "The user's unique ID", required: true },
      { label: "Include Details", type: "BOOLEAN", required: false }
    ]
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
```

**Success (201):**
```typescript
{
  action: {
    id: string;
    name: string;
    slug: string;  // Auto-generated URL-friendly identifier
    description: string;
    code: string | null;
    order: number;
    inputFields: Array<{ slug, label, type, description, placeholder, required, order, options, allowMultiSelect, contextActionId }>;
  }
}
```

**Error codes:** 400, 401, 403, 404, 409 (name already exists), 429, 500

**Action code environment:**
- `inputs.{fieldSlug}` — Input field values (auto-populated by agent/user)
- `secrets.{authFieldSlug}` — Auth credentials from connected user
- `fetch` — Standard fetch API
- Standard JS built-ins

---

#### Create Trigger

**Endpoint:** `POST https://api.langdock.com/integrations/v1/{integrationId}/triggers/create`

| Parameter | Type | Required | Limit |
|-----------|------|----------|-------|
| `name` | string | Yes | max 100 chars |
| `description` | string | No | max 90 chars |
| `pollingCode` | string | No | JS polling code, max 1,000 chars |
| `inputFields` | array | No | Same schema as action inputFields |

```javascript
await axios.post(
  `https://api.langdock.com/integrations/v1/${integrationId}/triggers/create`,
  {
    name: "New Issue Created",
    description: "Triggers when a new issue is created",
    pollingCode: `
      const response = await fetch('https://api.example.com/issues?since=' + lastPollTime, {
        headers: { 'Authorization': 'Bearer ' + secrets.API_TOKEN }
      });
      const issues = await response.json();
      return issues.map(issue => ({
        id: issue.id,
        timestamp: issue.created_at,
        data: { title: issue.title, description: issue.description }
      }));
    `,
    inputFields: [
      { label: "Project ID", type: "TEXT", required: true },
      { label: "Priority Filter", type: "SELECT",
        options: [{label: "All", value: "all"}, {label: "High", value: "high"}] }
    ]
  },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
```

**Trigger polling code environment:**
- `inputs.{fieldSlug}` — User-configured field values
- `secrets.{authFieldSlug}` — Auth credentials
- `lastPollTime` — Timestamp of last successful poll (for incremental fetch)
- `fetch` — Standard fetch API

**Required return format:**
```javascript
return [
  {
    id: "unique_event_id",        // Required: unique identifier
    timestamp: "2024-01-15T...", // Required: ISO 8601
    data: { /* your event data */ }
  }
];
```

Each returned event triggers the associated workflow or agent conversation.

---

### 6.7 Knowledge Folder API

**Required scope:** `KNOWLEDGE_FOLDER_API`

Folders must be shared with the API key first (see [Sharing](#sharing-with-api)).

---

#### Upload File to Folder

**Endpoint:** `POST https://api.langdock.com/knowledge/{folderId}`

**Format:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | file | Yes | File to upload (max 256MB) |
| `url` | string | No | Source URL to associate with file |

```bash
# cURL
curl -X POST "https://api.langdock.com/knowledge/{folderId}" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -F "file=@/path/to/document.pdf"
```

```javascript
const form = new FormData();
form.append("file", fs.createReadStream(filePath));
const response = await axios.post(
  `https://api.langdock.com/knowledge/${folderId}`,
  form,
  { headers: { Authorization: "Bearer YOUR_API_KEY", ...form.getHeaders() } }
);
```

**Success (200):**
```json
{
  "status": "success",
  "result": {
    "id": "att_abc123def456",
    "name": "quarterly-report.pdf",
    "mimeType": "application/pdf",
    "createdAt": "2025-01-15T10:30:00.000Z",
    "updatedAt": "2025-01-15T10:30:00.000Z",
    "url": null
  }
}
```

**Async variant:** `POST /knowledge/{folderId}/upload-async` — returns `202 Accepted` immediately. Poll `result.statusUrl` to check `syncStatus: SYNCED`.

**Error codes:** 400 (invalid file/type), 401, 403 (no access), 404 (folder not found), 408 (timeout), 413 (>256MB), 429, 500

---

#### List Files in Folder

**Endpoint:** `GET https://api.langdock.com/knowledge/{folderId}/list`

```javascript
const response = await axios.get(
  `https://api.langdock.com/knowledge/${folderId}/list`,
  { headers: { Authorization: "Bearer YOUR_API_KEY" } }
);
```

**Success (200):**
```typescript
{
  status: "success";
  result: Array<{
    id: string;
    name: string;
    mimeType: string;
    createdAt: string;
    updatedAt: string;
    url: string | null;
    path: string | null;
    syncStatus: string;       // UPLOADING | UPLOADED | EXTRACTING | EMBEDDING | SYNCED | *_FAILED | TIMEOUT
    pageCount: number | null;
    summary: string | null;
    externalId: string | null;
    syncParams: object | null;
  }>;
}
```

**Get single file:** `GET /knowledge/{folderId}/{attachmentId}`

**Polling for processing completion:**
```javascript
async function waitForProcessing(folderId, attachmentId, maxAttempts = 30) {
  for (let i = 0; i < maxAttempts; i++) {
    const files = await listFiles(folderId);
    const file = files.result.find(f => f.id === attachmentId);
    if (!file) throw new Error("File not found");
    if (file.syncStatus === "SYNCED") return file;
    if (["ACTION_FAILED", "EXTRACTION_FAILED", "EMBEDDING_FAILED", "TIMEOUT"]
        .includes(file.syncStatus)) throw new Error(`Failed: ${file.syncStatus}`);
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  throw new Error("Processing timeout");
}
```

---

#### Search Knowledge Folders

**Endpoint:** `POST https://api.langdock.com/knowledge/search`

Semantic search across **all** folders shared with your API key.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Natural language search query |

```javascript
const response = await axios.post(
  "https://api.langdock.com/knowledge/search",
  { query: "What are the Q4 revenue projections?" },
  { headers: { Authorization: "Bearer YOUR_API_KEY", "Content-Type": "application/json" } }
);
```

**How it works:**
1. Query embedded using workspace's default embedding model
2. Vector similarity search across all shared folder documents
3. Filtered by relevance threshold, re-ranked by LLM
4. Only highest-scoring chunk per document returned

**Success (200):**
```json
{
  "status": "success",
  "result": [
    {
      "id": "chunk_abc123",
      "text": "Q4 revenue projections indicate a 15% increase...",
      "similarity": 0.89,
      "subsource": "att_xyz789",
      "subname": "quarterly-report-2024.pdf",
      "url": "https://example.com/reports/q4-2024",
      "index": 0
    }
  ]
}
```

**Result fields:**

| Field | Description |
|-------|-------------|
| `id` | Unique chunk ID |
| `text` | Relevant text content |
| `similarity` | Relevance score 0–1 (higher = more relevant) |
| `subsource` | Attachment ID |
| `subname` | Filename |
| `url` | Source URL (if provided during upload) |
| `index` | 0-based result index |

**RAG pattern:**
```javascript
async function answerWithContext(question) {
  const searchResults = await searchKnowledge(question);
  const context = searchResults.result
    .map(chunk => `Source: ${chunk.subname}\n${chunk.text}`)
    .join("\n\n---\n\n");
  const prompt = `Based on the following context:\n\n${context}\n\nAnswer: ${question}`;
  return callLLM(prompt);
}
```

---

#### Delete Attachment

**Endpoint:** `DELETE https://api.langdock.com/knowledge/{folderId}/{attachmentId}`

> **Warning:** Permanent deletion. File and all embeddings removed and cannot be recovered.

```bash
curl -X DELETE "https://api.langdock.com/knowledge/{folderId}/{attachmentId}" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**Success (200):** `{ "status": "success", "message": "Attachment deleted" }`

---

#### Update Attachment (Replace File)

**Endpoint:** `PATCH https://api.langdock.com/knowledge/{folderId}`

**Format:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `attachmentId` | string | Yes | ID of attachment to replace |
| `file` | file | Yes | New file (max 256MB) |
| `url` | string | No | New source URL |

```javascript
const form = new FormData();
form.append("attachmentId", attachmentId);
form.append("file", fs.createReadStream(newFilePath));
const response = await axios.patch(
  `https://api.langdock.com/knowledge/${folderId}`,
  form,
  { headers: { Authorization: "Bearer YOUR_API_KEY", ...form.getHeaders() } }
);
```

**Success (200):** Same structure as Upload File response.

---

## 7. Pricing

### Overview

Langdock has three separately priced products:

| Product | Pricing Model |
|---------|--------------|
| **Chat & Agents** | Per-seat, with volume discounts |
| **Workflows** | Add-on, priced by monthly runs |
| **API** | Usage-based per token |

### Chat & Agents

**AI Models:**
- **Included** — Usage covered in seat price. Simple, predictable billing.
- **BYOK (Bring Your Own Key)** — You provide API keys; pay model providers directly.

**Subscriptions:**
- **Business** — Up to 1,000 users. Includes SSO, SCIM, all features.
- **Enterprise** — 1,000+ users. Dedicated deployment option, custom support.

**Plans (within Business subscription):**
- **Business** — Standard usage limits
- **Business Max** — 5× the limits of Business (higher per-seat price)

**Extra Usage:** For "AI Models Included" workspaces — enables continued usage after limits are reached, at usage-based pricing.

**Volume discounts (annual billing saves additional 20%):**
- Seats 1–50: Base rate
- Seats 51–250: First discount tier
- Seats 251–550: Second tier
- Seats 551+: Highest tier

### Workflows

Add-on to Chat & Agents. Priced by monthly workflow runs.

| Plan | Description |
|------|-------------|
| Starter | Included with Chat & Agents; monthly run allocation |
| Business | Higher volumes, annual discount options |
| Custom | Tailored for high-volume needs |

All plans: **unlimited workflow steps and users**.

> **Important:** Workflow AI usage (Agent nodes) is NOT included in seat pricing. AI tokens consumed by workflows are billed usage-based, even if you have "AI Models Included" for Chat.

**Workspace cost controls:**
- Default workspace spend cap: €500/month (configurable by admin)
- Per-workflow monthly limits
- Per-execution limits
- Hourly rate limits

### API

Usage-based per token. Rates match model provider prices. 40+ AI models available. No minimum commitment.

### Enterprise

For 1,000+ user organizations:
- Dedicated deployment (on-premise or private cloud; minimum 5,000 users)
- Custom support, SLAs, dedicated account management
- Custom onboarding, training, workshops

---

*Document compiled from docs.langdock.com — covers all major workflow nodes, agent configuration and API, integrations API, knowledge folder API, and platform overview. For the most current information, refer to https://docs.langdock.com/llms.txt.*