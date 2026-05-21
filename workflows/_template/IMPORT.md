# Workflow importieren in Langdock

## Voraussetzungen

- Langdock-Account mit Workflow-Berechtigung
- Gmail-Integration in Langdock aktiviert (für Mail-Workflows)

## Import-Schritte

### 1. Builder-Chat öffnen

1. Gehe zu https://app.langdock.com/workflows/new
2. Klicke auf das **AI Chat-Symbol** (unten rechts im Canvas)

### 2. n8n-JSON hochladen

Schreibe im Chat:

```
Importiere diesen n8n-Workflow und erstelle ihn als Langdock-Workflow.
Behalte die deutschen Node-Namen bei.
```

Dann hänge die `workflow.json` Datei als Attachment an.

### 3. Prüfen & Anpassen

Der Builder erstellt den Workflow. Prüfe:

- [ ] Alle Nodes vorhanden?
- [ ] Connections korrekt?
- [ ] Form-Felder stimmen?
- [ ] Gmail-Integration verbunden? (ggf. OAuth neu authorisieren)
- [ ] E-Mail-Adressen korrekt?

### 4. Testen

1. Klicke "Run Once" (manuell)
2. Fülle das Formular testweise aus
3. Prüfe ob Mails ankommen

### 5. Publishen

1. Klicke "Publish"
2. Vergib eine Version (z.B. v1.0.0)

### 6. Mit Agent verknüpfen

1. Öffne den zugehörigen Agent
2. Agent Settings → Actions → Add Tool → Workflows
3. Wähle den neuen Workflow aus
4. Agent publishen

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| Builder erkennt JSON nicht | Sicherstellen dass es valides JSON ist (kein Markdown drumrum) |
| Gmail-Node fehlt | Gmail-Integration in Workspace Settings aktivieren |
| OAuth-Fehler | In Langdock Settings → Integrations → Gmail neu verbinden |
| Node-Typen nicht erkannt | Builder-Chat fragen: "Wandle den Code-Node in einen Langdock Code-Node um" |
| Routing falsch | Nach Import im Canvas die Connections manuell prüfen |