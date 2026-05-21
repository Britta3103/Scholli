# /create-workflow — Workflow als n8n-JSON generieren

> Dieser Skill generiert Langdock-kompatible Workflows im n8n-JSON-Format,
> die über den Langdock Builder-Chat importiert werden können.

## Trigger

- `/create-workflow <name>` (z.B. `/create-workflow schimmel-meldung`)
- "erstelle einen Workflow"
- "baue einen Flow für..."
- "neuer Workflow"

## Kontext

Langdock hat keine Workflow-API. Workflows werden in der UI erstellt.
**ABER:** Der Langdock Builder-Chat kann n8n-JSON interpretieren und in native Langdock-Workflows umwandeln.

Workflow: User beschreibt → Claude generiert n8n-JSON → User lädt es im Builder-Chat hoch → Langdock erstellt den Workflow.

## Steps

### 1. Anforderungen klären

Frage den User:
- Was soll der Workflow tun? (Zweck)
- Welcher Trigger? (Form/Manual/Scheduled/Webhook)
- Welche Input-Felder?
- Welche Aktionen? (Mail senden, HTTP-Call, Dokument erstellen, etc.)
- Welche Bedingungen/Verzweigungen?
- Welcher Agent soll den Workflow nutzen?

### 2. Workflow-Spec erstellen

Erstelle `workflows/<name>/workflow-spec.md` mit:
- Zweck
- Trigger + Input-Felder
- Node-Flow (Diagramm)
- Logik je Node
- Output

### 3. n8n-JSON generieren

Erstelle `workflows/<name>/workflow.json` im n8n-Format.

**n8n JSON-Struktur:**

```json
{
  "name": "Workflow-Name",
  "nodes": [
    {
      "id": "uuid",
      "name": "Node-Name",
      "type": "n8n-nodes-base.<type>",
      "position": [x, y],
      "parameters": { ... },
      "typeVersion": 1
    }
  ],
  "connections": {
    "Node-Name": {
      "main": [
        [
          { "node": "Nächster-Node", "type": "main", "index": 0 }
        ]
      ]
    }
  },
  "settings": {
    "executionOrder": "v1"
  }
}
```

### 4. Node-Type Mapping (n8n → Langdock)

| n8n Node Type | Langdock Equivalent | Hinweis |
|---------------|--------------------| --------|
| `n8n-nodes-base.formTrigger` | Form Trigger | Felder werden als Input-Schema |
| `n8n-nodes-base.manualTrigger` | Manual Trigger | — |
| `n8n-nodes-base.scheduleTrigger` | Scheduled Trigger | Cron-Expression |
| `n8n-nodes-base.webhook` | Webhook Trigger | URL wird von Langdock generiert |
| `n8n-nodes-base.if` | Condition Node | Expressions |
| `n8n-nodes-base.code` | Code Node | JS oder Python |
| `n8n-nodes-base.httpRequest` | HTTP Request Node | Method + URL + Body |
| `n8n-nodes-base.gmail` | Gmail Action | Send/Read |
| `n8n-nodes-base.slack` | Slack Action | Send Message |
| `n8n-nodes-base.set` | Code Node (einfach) | Variable setzen |
| `n8n-nodes-base.merge` | — | Ggf. in Code Node abbilden |
| `n8n-nodes-base.wait` | Delay Node | Zeitdauer |
| `n8n-nodes-base.respondToWebhook` | Output Node | — |
| `n8n-nodes-base.openAi` | Agent Node | Prompt + Model |

### 5. Generierungsregeln

Beim Erstellen des n8n-JSON beachten:

- **IDs:** UUIDs generieren (Format: `xxxxxxxx-xxxx-4xxx-xxxx-xxxxxxxxxxxx`)
- **Positionen:** Nodes horizontal anordnen (x += 300 pro Stufe, y = 300 als Baseline)
- **Connections:** Immer `"main": [[{"node": "...", "type": "main", "index": 0}]]`
- **Parameter-Expressions:** n8n nutzt `={{ $json.fieldName }}` — das versteht der Langdock-Import
- **Kommentare:** `"notes"` Feld am Node nutzen für Erklärungen
- **Naming:** Deutsche, beschreibende Node-Namen (der Langdock-Import übernimmt sie)

### 6. Import-Anleitung erstellen

Erstelle `workflows/<name>/IMPORT.md`:

```markdown
## Import in Langdock

1. Öffne den Langdock Workflow Builder: https://app.langdock.com/workflows/new
2. Klicke auf den **Chat-Builder** (AI-Symbol unten rechts)
3. Schreibe: "Importiere diesen n8n-Workflow" und hänge `workflow.json` an
4. Prüfe den generierten Workflow
5. Passe ggf. die Gmail-Integration an (OAuth neu verbinden)
6. Teste mit "Run Once"
7. Publish
```

### 7. Committen

```bash
git add workflows/<name>/
git commit -m "workflows: add <name> workflow (n8n format for Langdock import)"
```

## Rules

- JSON muss valides n8n-Format sein (v1 execution order)
- Jeder Node braucht eine eindeutige `id` (UUID) und einen `name`
- Connections müssen bidirektional konsistent sein
- Keine Credentials/Secrets im JSON — Langdock fragt OAuth beim Import ab
- Form-Trigger-Felder müssen zu den Agent-Pflichtfeldern passen (siehe requirements.md)
- Deutsche Node-Namen verwenden
- Code Nodes: JavaScript bevorzugen (besserer Langdock-Support)
- Bei Gmail-Nodes: `operation: "send"` und `toList`, `subject`, `message` als Parameter

## n8n Node Templates

### Form Trigger

```json
{
  "id": "trigger-uuid",
  "name": "Formular-Eingang",
  "type": "n8n-nodes-base.formTrigger",
  "position": [0, 300],
  "parameters": {
    "formTitle": "Mieter-Anliegen",
    "formFields": {
      "values": [
        { "fieldLabel": "Name", "fieldType": "text", "requiredField": true },
        { "fieldLabel": "E-Mail", "fieldType": "email", "requiredField": true },
        { "fieldLabel": "Adresse", "fieldType": "text", "requiredField": true },
        { "fieldLabel": "Wohnung", "fieldType": "text", "requiredField": false },
        { "fieldLabel": "Anliegen", "fieldType": "textarea", "requiredField": true },
        { "fieldLabel": "Kategorie", "fieldType": "dropdown", "fieldOptions": { "values": [
          { "option": "TBB" }, { "option": "Vermietung" }, { "option": "Mitglieder" },
          { "option": "Rechnungswesen" }, { "option": "HSG" }
        ]}, "requiredField": true },
        { "fieldLabel": "Dringlichkeit", "fieldType": "dropdown", "fieldOptions": { "values": [
          { "option": "normal" }, { "option": "hoch" }, { "option": "dringend" }
        ]}, "requiredField": false }
      ]
    }
  },
  "typeVersion": 2
}
```

### Code Node (Routing)

```json
{
  "id": "code-uuid",
  "name": "Empfänger-Routing",
  "type": "n8n-nodes-base.code",
  "position": [300, 300],
  "parameters": {
    "language": "javaScript",
    "jsCode": "const routing = {\n  'TBB': 'tbb@freiescholle.de',\n  'Vermietung': 'vermietung@freiescholle.de',\n  'Mitglieder': 'mitglieder@freiescholle.de',\n  'Rechnungswesen': 'rechnungswesen@freiescholle.de',\n  'HSG': 'hsg@freiescholle.de'\n};\n\nconst category = $input.item.json['Kategorie'];\nconst email = routing[category] || 'info@freiescholle.de';\n\nreturn [{ json: { ...items[0].json, department_email: email, department: category } }];"
  },
  "typeVersion": 2
}
```

### Gmail Send Node

```json
{
  "id": "gmail-uuid",
  "name": "Mail an Fachabteilung",
  "type": "n8n-nodes-base.gmail",
  "position": [600, 300],
  "parameters": {
    "operation": "send",
    "sendTo": "={{ $json.department_email }}",
    "subject": "=[Scholli] {{ $json.Kategorie }} — {{ $json.Name }}",
    "message": "=Neues Mieter-Anliegen:\n\n👤 {{ $json.Name }}\n🏠 {{ $json.Adresse }}, Whg. {{ $json.Wohnung }}\n📧 {{ $json['E-Mail'] }}\n\n📋 Anliegen:\n{{ $json.Anliegen }}\n\n⚡ Dringlichkeit: {{ $json.Dringlichkeit }}",
    "options": {}
  },
  "typeVersion": 2
}
```

### Condition Node (If)

```json
{
  "id": "if-uuid",
  "name": "Dringlichkeit prüfen",
  "type": "n8n-nodes-base.if",
  "position": [300, 300],
  "parameters": {
    "conditions": {
      "options": { "caseSensitive": false },
      "combinator": "and",
      "conditions": [
        {
          "leftValue": "={{ $json.Dringlichkeit }}",
          "rightValue": "dringend",
          "operator": { "type": "string", "operation": "equals" }
        }
      ]
    }
  },
  "typeVersion": 2
}
```

## Checklist

- [ ] Workflow-Spec erstellt (workflows/<name>/workflow-spec.md)
- [ ] n8n-JSON generiert (workflows/<name>/workflow.json)
- [ ] JSON ist valide (keine Syntax-Fehler)
- [ ] Alle Node-Connections korrekt
- [ ] Import-Anleitung erstellt (workflows/<name>/IMPORT.md)
- [ ] Dateien committet
- [ ] User informiert über Import-Prozess in Langdock

## Example

```
User: /create-workflow schimmel-meldung

→ Erstellt workflows/schimmel-meldung/workflow-spec.md
→ Erstellt workflows/schimmel-meldung/workflow.json (n8n-Format):
   Form Trigger (Name, Adresse, Raum, Foto) → Code (Routing) → Gmail (an TBB + Bestätigung)
→ Erstellt workflows/schimmel-meldung/IMPORT.md
→ Meldet: "✅ Workflow 'Schimmel-Meldung' als n8n-JSON generiert.
   → Datei: workflows/schimmel-meldung/workflow.json
   → Import: In Langdock Builder-Chat hochladen (siehe IMPORT.md)"
```