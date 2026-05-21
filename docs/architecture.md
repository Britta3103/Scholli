# Architektur & Langdock-Plattform

## Langdock Workflow Engine

### Engine-Typ
**Proprietäre Custom-Engine** — keine bekannte Open-Source-Basis (kein Temporal, n8n, Inngest, Zapier).

### Architektur-Übersicht

```
┌─────────────────────────────────────────────────────────┐
│                    LANGDOCK WORKFLOWS                    │
├───────────────────────────┬─────────────────────────────┤
│      TRIGGER LAYER        │       EXECUTION LAYER       │
│  ┌─────────────────────┐  │  ┌──────────────────────┐  │
│  │ Manual / Form       │  │  │ Visual Canvas Engine │  │
│  │ Scheduled (Cron)    │──┼─►│ Sequential + Parallel│  │
│  │ Webhook (HTTP POST) │  │  │ Node-DAG-Execution   │  │
│  │ Integration Polling │  │  │ Max 2.000 Steps      │  │
│  └─────────────────────┘  │  └──────────────────────┘  │
├───────────────────────────┼─────────────────────────────┤
│      VERSIONING           │       SANDBOX               │
│  Draft v0 → v1.0.0+      │  JS + Python Code Nodes    │
│  Semantic Versioning      │  Sandboxed (kein FS, kein  │
│  Immutable Published      │  eval, kein process)       │
├───────────────────────────┴─────────────────────────────┤
│                  COST CONTROL                           │
│  Workspace Limit: 0–100.000 EUR/Monat                  │
│  Default per Workflow: 25 USD/Monat                    │
│  Max per Workflow: konfigurierbar (bis 10.000 USD)     │
└─────────────────────────────────────────────────────────┘
```

## Verfügbare Node-Typen

### Trigger-Nodes (5)

| Node | Beschreibung | Chat-triggerable? |
|------|-------------|-------------------|
| Manual Trigger | On-Demand per Button | ✅ |
| Form Trigger | Custom-Web-Form mit Validierung | ✅ |
| Scheduled Trigger | Zeitgesteuert (Cron) | ✅ |
| Webhook Trigger | Externer HTTP POST → `app.langdock.com/api/hooks/workflows/{ID}` | ❌ |
| Integration Trigger | Events aus Apps (Polling-basiert) | ❌ |

### Processing-Nodes (14)

| Node | Beschreibung |
|------|-------------|
| Agent | KI-Analyse/Generierung, strukturierter Output (JSON-Schema) |
| Code | JavaScript oder Python in Sandbox |
| HTTP Request | Externe API-Calls (GET/POST/PUT/PATCH/DELETE) |
| Condition | If/Else via JS-Expressions oder AI-Prompt |
| Loop | Array-Iteration, optional parallel, max 200–2000 Items |
| Delay | Pause (1s bis 24h) |
| Guardrails | PII-Detection, Moderation, Jailbreak, Hallucination |
| Web Search | Internet-Recherche |
| File Search | Semantische Suche in Knowledge Folders |
| Image Generation | Text-zu-Bild |
| Action | Integration-Actions (Slack, Jira, E-Mail, etc.) |
| Human in the Loop | Manuelle Freigabe (Workflow pausiert) |
| Send Notification | Langdock-Inbox-Nachricht |
| Output | Finales Ergebnis persistieren |

## Agent-zu-Workflow-Triggering

### Mechanismus

1. **Konfiguration:** Agent Builder → Actions → Add Tool → Tab: Workflows → Workflow auswählen
2. **Tool-Name:** Automatisch abgeleitet: `"Scholli Mail Workflow"` → `workflow_scholli_mail_workflow`
3. **Input-Schema:** Bei Form-Trigger werden Formular-Felder als Tool-Parameter exponiert
4. **Bestätigung:** ⚠️ IMMER User-Confirmation erforderlich (kein Auto-Execute)
5. **Limit:** Max 1 Workflow-Call pro Agent-Response

### Einschränkungen

- Webhook/Integration-Trigger-Workflows sind NICHT aus dem Chat triggerable
- Mobile App: Workflow-Trigger nicht verfügbar
- Sub-Agents können keine Workflows triggern (Loop-Prevention)

## Variable-Syntax in Workflows

```handlebars
{{node_name.output.field_name}}           // Standard
{{agent.output.structured.priority}}      // Structured Output
{{trigger.output.user?.email}}            // Optional Chaining
{{http_request.output.data.items[0]}}     // Array-Zugriff
```

## Deployment-Modell

- **SaaS:** `app.langdock.com`
- **Enterprise:** Dedicated Deployment (`<deployment-url>/api/public`)
- **Pricing:** Workflows sind Add-On zu Chat & Agents (per Workflow-Run)