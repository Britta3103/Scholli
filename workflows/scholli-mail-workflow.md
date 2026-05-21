# Scholli Mail Workflow

> Workflow-ID: `8723e518-81bd-4672-9591-a6b67d685fa4`
> [In Langdock öffnen](https://app.langdock.com/workflows/8723e518-81bd-4672-9591-a6b67d685fa4)

## Zweck

Nimmt die vom Scholli-Agent gesammelten Mieter-Informationen entgegen und leitet sie intern weiter (per E-Mail oder anderer Aktion).

## Trigger

Der Workflow wird vom **Scholli Agent** getriggert, wenn alle Pflichtinformationen vorliegen:

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|-------------|
| `user_message` | string | ✅ | Originalanliegen des Mieters |
| `name` | string | ✅ | Name des Mieters |
| `address` | string | ✅ | Adresse / Wohnort |
| `apartment_unit` | string | ❌ | Wohnungsnummer (falls bekannt) |
| `email` | string | ✅ | E-Mail-Adresse des Mieters |
| `phone` | string | ❌ | Telefonnummer |
| `key_type` | string | ❌ | Art des Schlüssels (bei Schlüsselproblemen) |
| `reason` | string | ❌ | Grund/Ursache |
| `urgency` | string | ❌ | Dringlichkeit |
| `since_when` | string | ❌ | Seit wann besteht das Problem |
| `session_id` | string | ❌ | Chat-Session-ID |

## Aktueller Status

⚠️ **Workflow-Details sind nur über die Langdock UI einsehbar** — keine API zum Abfragen der Node-Konfiguration.

### Bekannte Fakten

- Wird intern vom Agent via Tool-Call `workflow_scholli_mail_workflow` aufgerufen
- User-Bestätigung ist IMMER erforderlich vor Ausführung
- Vermutlich enthält er einen Mail-Versand-Node (Name deutet darauf hin)

## Programmatischer Aufruf (falls Webhook-Trigger konfiguriert)

```bash
curl -X POST https://app.langdock.com/api/hooks/workflows/8723e518-81bd-4672-9591-a6b67d685fa4 \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: <SECRET>" \
  -d '{
    "user_message": "Meine Heizung funktioniert nicht mehr",
    "name": "Max Müller",
    "address": "Schollstraße 5, 33615 Bielefeld",
    "apartment_unit": "3. OG links",
    "email": "max.mueller@example.com",
    "urgency": "hoch",
    "since_when": "seit gestern Abend"
  }'
```

## Nächste Schritte

- [ ] Workflow-Nodes in der UI dokumentieren (Screenshot oder manuelle Erfassung)
- [ ] Webhook-Trigger hinzufügen für externen Aufruf
- [ ] Builder-Prompt oder n8n-JSON für gewünschte Änderungen erstellen
- [ ] Testen: Agent → Workflow → Mail-Zustellung verifizieren