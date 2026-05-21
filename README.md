# Scholli 🏠

**Frontdesk-Agent für die Wohnungsbaugesellschaft "Freie Scholle"**

Scholli ist ein KI-gestützter Chat-Agent auf der [Langdock](https://langdock.com)-Plattform, der Mietern bei ihren täglichen Anliegen hilft.

## Überblick

| Eigenschaft | Wert |
|-------------|------|
| Plattform | [Langdock](https://app.langdock.com) |
| Agent-ID | `a1b11586-0e78-4e5a-b36d-bfe7c9995ee8` |
| Workflow-ID | `8723e518-81bd-4672-9591-a6b67d685fa4` |
| Modell | Workspace-Default |
| Temperature | 0.1 |
| Erstellt | 17.05.2026 |

## Architektur

```
Mieter (Chat) → Scholli Agent → Scholli Mail Workflow → Interne Weiterleitung
```

1. **Scholli Agent** nimmt Anliegen entgegen und fragt fehlende Infos ab
2. Bei vollständigen Angaben triggert der Agent den **Scholli Mail Workflow**
3. Der Workflow verarbeitet die strukturierten Daten und leitet intern weiter

## Repository-Struktur

```
├── README.md                    # Dieses Dokument
├── docs/
│   ├── architecture.md          # Technische Architektur & Langdock-Plattform
│   └── langdock-api.md          # API-Referenz & Zugriffsmöglichkeiten
├── agent/
│   └── system-prompt.md         # Aktueller System-Prompt des Agents
└── workflows/
    └── scholli-mail-workflow.md  # Workflow-Dokumentation
```

## Zugriff

- **Agent API:** `GET/PATCH https://api.langdock.com/agent/v1/...`
- **Workflow:** Nur über UI oder Webhook-Trigger
- **API Key:** Azure Key Vault `kv-cassini-ki-dev` → Secret `langdock-api-key`

## Entwicklung

Workflows können nicht direkt per API erstellt werden. Stattdessen:

1. Agent-Prompt hier pflegen → per API deployen
2. Workflow-Änderungen als n8n-kompatibles JSON oder Builder-Prompt vorbereiten
3. In Langdock Builder-Chat einspeisen

## Links

- [Langdock Agent UI](https://app.langdock.com/agents/a1b11586-0e78-4e5a-b36d-bfe7c9995ee8/edit)
- [Langdock Workflow UI](https://app.langdock.com/workflows/8723e518-81bd-4672-9591-a6b67d685fa4)
- [Langdock API Docs](https://docs.langdock.com/api-endpoints/api-introduction)