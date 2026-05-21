# CLAUDE.md — Instructions for Claude Code

> This file configures Claude Code for the Scholli project.

## Project Context

**Scholli** is a fleet of specialized AI agents for "Freie Scholle", a housing association (Wohnungsbaugesellschaft) in Bielefeld, Germany (~5,000 units). The agents run on the **Langdock** platform and help tenants (Mieter) with daily issues.

## Architecture

```
Mieter → Scholli Router Agent → Spezialisierte Agenten → Workflows → Backend-Aktionen
```

- **Platform:** Langdock (langdock.com)
- **Agent API:** `https://api.langdock.com/agent/v1/...`
- **Workflow Engine:** Langdock (proprietary, UI-only, no code API)
- **Channel:** Langdock Chat (Web)
- **Target Users:** Tenants of Freie Scholle (German-speaking, simple language)

## Repository Structure

```
├── CLAUDE.md                           ← You are here (AI instructions)
├── README.md                           ← Project overview
├── docs/
│   ├── requirements.md                 ← Full requirements specification
│   ├── architecture.md                 ← Technical architecture
│   ├── langdock-api.md                 ← API reference
│   └── langdock-platform-reference.md  ← Complete Langdock docs (92 KB)
├── agents/
│   ├── _template/                      ← Template for new agents
│   │   ├── system-prompt.md
│   │   └── config.json
│   ├── router/                         ← Router agent (front door)
│   ├── vermietung/                     ← Rental/leasing agent
│   ├── tbb/                            ← Technical building management
│   ├── mitglieder/                     ← Membership/team services
│   ├── rechnungswesen/                 ← Accounting/billing
│   ├── hsg/                            ← Property maintenance
│   └── oeffentlichkeit/                ← Public relations
├── workflows/
│   ├── _template/
│   │   └── workflow-spec.md
│   └── scholli-mail-workflow.md
└── scripts/
    └── deploy-agent.ps1                ← Deploy prompt to Langdock API
```

## How to Work

### Creating a New Agent

1. Copy `agents/_template/` to `agents/<agent-name>/`
2. Edit `system-prompt.md` — this IS the agent's behavior definition
3. Edit `config.json` — model, temperature, capabilities
4. Test the prompt in Langdock UI first
5. Deploy via `scripts/deploy-agent.ps1` (updates draft)
6. Publish in Langdock UI

### Prompt Writing Rules

- Language: **German** (agents speak German to tenants)
- Style: friendly, short, professional, simple language
- ALWAYS define: role, goal, rules, forbidden actions, examples
- Use the template structure in `agents/_template/system-prompt.md`
- Max 40,000 characters per system prompt (Langdock limit)

### Workflow Design

Workflows CANNOT be created via API. Instead:
1. Document the workflow spec in `workflows/<name>/workflow-spec.md`
2. Use the Langdock Builder Chat to create it (paste the spec or n8n JSON)
3. Link workflow to agent via Actions in Langdock UI

### Key Conventions

- **German** for all user-facing text, prompts, and documentation
- **English** for code, config keys, file names, git commits
- Each agent has ONE clear responsibility (single-responsibility principle)
- The Router Agent decides which specialist handles the request
- Never expose internal processes to tenants
- Always collect minimum required info before triggering a workflow

## Langdock API Quick Reference

```bash
# Get agent
curl -H "Authorization: Bearer $KEY" "https://api.langdock.com/agent/v1/get?agentId=<UUID>"

# Update agent prompt (creates draft)
curl -X PATCH https://api.langdock.com/agent/v1/update \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"agentId": "<UUID>", "instruction": "..."}'

# Create new agent
curl -X POST https://api.langdock.com/agent/v1/create \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "...", "instruction": "...", "creativity": 0.1}'
```

⚠️ API updates create DRAFTS — must publish in Langdock UI.

## API Key

Stored in Azure Key Vault:
- Vault: `kv-cassini-ki-dev`
- Secret: `langdock-api-key`
- Scopes: All (Agenten, Completion, Embedding, Integrations, etc.)

## Important Limits

| Resource | Limit |
|----------|-------|
| Agent name | 1–80 chars |
| Agent description | max 500 chars |
| System prompt | max 40,000 chars |
| Temperature | 0.0–1.0 |
| Conversation starters | max 20, each 1–255 chars |
| Workflow steps per execution | max 2,000 |
| Workflow tool name | max 63 chars (auto-derived from workflow name) |

## Reference Docs

For complete Langdock documentation, see: `docs/langdock-platform-reference.md`
For architecture details, see: `docs/architecture.md`
For requirements, see: `docs/requirements.md`