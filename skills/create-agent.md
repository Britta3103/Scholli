# /create-agent — Neuen Langdock-Agenten erstellen

> Dieser Skill erstellt einen neuen spezialisierten Agenten für die Scholli-Flotte.

## Trigger

- `/create-agent <name>` (z.B. `/create-agent vermietung`)
- "erstelle einen neuen Agenten"
- "neuen Agenten anlegen"

## Voraussetzungen

- Langdock API Key mit `AGENT_API` Scope
- Key Vault: `kv-cassini-ki-dev` → Secret: `langdock-api-key`

## Steps

### 1. Agentenname und Bereich bestimmen

Frage den User (falls nicht angegeben):
- Name des Agenten (z.B. "Vermietung", "TBB", "Rechnungswesen")
- Kurzbeschreibung (1 Satz)
- Emoji

### 2. System-Prompt erstellen

Nutze das Template aus `agents/_template/system-prompt.md` und fülle es mit:
- Use Cases aus `docs/requirements.md` (passende Sektion)
- Pflichtfelder für diesen Agenten
- Workflow-Name (falls bekannt)
- Beispieldialoge (mind. 2)

Speichere den Prompt unter: `agents/<name>/system-prompt.md`

### 3. Config erstellen

Erstelle `agents/<name>/config.json` basierend auf `agents/_template/config.json`:

```json
{
  "agentId": null,
  "name": "Scholli <Bereich>",
  "description": "<Kurzbeschreibung>",
  "emoji": "<Emoji>",
  "model": null,
  "creativity": 0.1,
  "inputType": "PROMPT",
  "webSearch": false,
  "imageGeneration": false,
  "dataAnalyst": false,
  "canvas": false,
  "extendedThinking": false,
  "conversationStarters": ["<2-3 Beispiel-Fragen>"],
  "actions": [],
  "workflows": []
}
```

### 4. Agent in Langdock erstellen (API)

```powershell
$secret = az keyvault secret show --vault-name kv-cassini-ki-dev --name langdock-api-key --query value -o tsv
$headers = @{ "Authorization" = "Bearer $secret"; "Content-Type" = "application/json" }

$prompt = Get-Content "agents/<name>/system-prompt.md" -Raw
# Extrahiere nur den Prompt-Block (zwischen den ``` Markern)
$promptMatch = [regex]::Match($prompt, '(?s)```\n(.+?)\n```')
$systemPrompt = $promptMatch.Groups[1].Value

$config = Get-Content "agents/<name>/config.json" | ConvertFrom-Json

$body = @{
    name = $config.name
    description = $config.description
    emoji = $config.emoji
    instruction = $systemPrompt
    creativity = $config.creativity
    inputType = $config.inputType
    webSearch = $config.webSearch
    imageGeneration = $config.imageGeneration
    dataAnalyst = $config.dataAnalyst
    canvas = $config.canvas
    extendedThinking = $config.extendedThinking
    conversationStarters = $config.conversationStarters
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod -Uri "https://api.langdock.com/agent/v1/create" `
    -Headers $headers -Method Post -Body $body -ContentType "application/json"

Write-Host "✅ Agent erstellt: $($response.agent.id)"
Write-Host "→ https://app.langdock.com/agents/$($response.agent.id)/edit"
```

### 5. Agent-ID zurückschreiben

Aktualisiere `agents/<name>/config.json` mit der erhaltenen `agentId`.

### 6. README aktualisieren

Aktualisiere `agents/<name>/README.md`:
- Status: 🔲 → ✅
- Agent-ID eintragen
- Link zur Langdock UI

### 7. Committen

```bash
git add agents/<name>/
git commit -m "agents: create <name> agent with system prompt and config"
```

## Rules

- Temperature IMMER auf 0.1 setzen (konsistentes Verhalten)
- System-Prompt MUSS die Scholli-Konventionen einhalten (siehe Template)
- Agent-Name Prefix: immer "Scholli" (z.B. "Scholli Vermietung")
- NIEMALS den API Key loggen oder committen
- Nach API-Erstellung: Agent ist Draft — User informieren dass Publish in UI nötig ist
- Workflow-Verknüpfung separat in Langdock UI (nicht über diese API möglich)

## Checklist

- [ ] System-Prompt nach Template erstellt
- [ ] Config.json mit korrekten Werten
- [ ] API-Call erfolgreich → Agent-ID erhalten
- [ ] Agent-ID in config.json eingetragen
- [ ] README aktualisiert
- [ ] Dateien committet
- [ ] User über Draft-Status informiert

## Example

```
User: /create-agent rechnungswesen

→ Erstellt agents/rechnungswesen/system-prompt.md (aus Requirements Sektion 5.5)
→ Erstellt agents/rechnungswesen/config.json
→ Ruft Langdock API auf → Agent-ID: "abc-123-..."
→ Aktualisiert config.json mit ID
→ Committed alles
→ Meldet: "✅ Agent 'Scholli Rechnungswesen' erstellt (Draft).
   → Langdock UI: https://app.langdock.com/agents/abc-123-.../edit
   → Nächster Schritt: In Langdock publishen und Workflow verknüpfen."
```