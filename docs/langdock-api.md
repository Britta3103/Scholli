# Langdock API — Referenz für Scholli

## Authentifizierung

```
Authorization: Bearer <API_KEY>
```

API Key: Azure Key Vault `kv-cassini-ki-dev` → Secret `langdock-api-key`
Scopes: Agenten API, Completion API, Embedding API, Wissensordner API, Integrations API, Usage Export API, User Management API, Audit Log API

## Agent-Endpunkte

| Aktion | Method | Endpoint |
|--------|--------|----------|
| Agent abrufen | GET | `/agent/v1/get?agentId={uuid}` |
| Agent updaten | PATCH | `/agent/v1/update` |
| Agent erstellen | POST | `/agent/v1/create` |
| Agent publishen | POST | `/agent/v1/publish` |
| Agent deaktivieren | POST | `/agent/v1/disable` |
| Modelle listen | GET | `/agent/v1/{agentId}/models` |
| Attachment hochladen | POST | `/agent/v1/{agentId}/attachments` |

### Agent abrufen

```bash
curl -H "Authorization: Bearer $KEY" \
  "https://api.langdock.com/agent/v1/get?agentId=a1b11586-0e78-4e5a-b36d-bfe7c9995ee8"
```

### Agent updaten (Partial Update)

```bash
curl -X PATCH https://api.langdock.com/agent/v1/update \
  -H "Authorization: Bearer $KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentId": "a1b11586-0e78-4e5a-b36d-bfe7c9995ee8",
    "instruction": "Neuer System-Prompt...",
    "creativity": 0.2
  }'
```

⚠️ **Wichtig:** Updates landen als **Draft** — Publishing muss in der UI bestätigt werden.
⚠️ **Array-Felder** (`actions`, `inputFields`, `conversationStarters`, `attachments`) werden komplett ersetzt, nicht gemergt!

### Verfügbare Update-Felder

| Parameter | Typ | Beschreibung |
|-----------|-----|-------------|
| `agentId` | string (UUID) | Pflicht |
| `name` | string | 1–80 Zeichen |
| `description` | string | Max 500 Zeichen |
| `instruction` | string | System-Prompt, max 40.000 Zeichen |
| `model` | string | Model-Deployment-Name |
| `creativity` | number | Temperature 0–1 |
| `conversationStarters` | string[] | Max 20, je 1–255 Zeichen |
| `actions` | array | Integration-Actions |
| `webSearch` | boolean | Web-Suche aktivieren |
| `imageGeneration` | boolean | Bildgenerierung |
| `dataAnalyst` | boolean | Code-Interpreter |
| `extendedThinking` | boolean | Extended Thinking Mode |

## Integrations-Endpunkte

| Aktion | Method | Endpoint |
|--------|--------|----------|
| Alle listen | GET | `/integrations/v1/get` |
| Details | GET | `/integrations/v1/{id}` |
| Erstellen | POST | `/integrations/v1/create` |
| Updaten | PATCH | `/integrations/v1/{id}` |
| Action erstellen | POST | `/integrations/v1/{id}/actions/create` |
| Trigger erstellen | POST | `/integrations/v1/{id}/triggers/create` |
| Auth konfigurieren | PATCH | `/integrations/v1/{id}/auth` |

## Workflow-Zugriff (limitiert)

### Was geht:

**Webhook-Trigger (einziger direkter Aufruf):**
```bash
curl -X POST https://app.langdock.com/api/hooks/workflows/8723e518-81bd-4672-9591-a6b67d685fa4 \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: YOUR_SECRET" \
  -d '{"name": "Max Müller", "problem": "Heizung defekt", "address": "Musterstr. 1"}'
```
→ Response: `202 Accepted` (async)

### Was NICHT geht:

- ❌ Workflows per API listen/lesen/erstellen/bearbeiten
- ❌ Workflow-Runs abfragen
- ❌ Workflow-as-Code (kein YAML/JSON-Schema)

## Workaround: Workflow programmatisch beeinflussen

1. **Agent-Prompt steuert** was an den Workflow übergeben wird (hier pflegbar)
2. **Webhook-Trigger** ermöglicht externen Aufruf (wenn im Workflow konfiguriert)
3. **n8n-JSON oder Builder-Prompt** generieren → in Langdock Builder-Chat einspeisen
4. **Custom Integration** als HTTP-Action → eigenes Backend kontrolliert Logik