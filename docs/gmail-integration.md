# Gmail-Integration für Scholli

> Status: 🔲 Konfiguration in Langdock erforderlich
> Gmail: `britta.rade3101@gmail.com`

## Überblick

Die Gmail-Integration ermöglicht zwei Richtungen:

```
┌──────────────────────────────────────────────────────────────┐
│                    GMAIL INTEGRATION                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  EINGEHEND (Trigger):                                        │
│  Mieter-Mail → Gmail → Integration Trigger → Agent-Chat     │
│                                                              │
│  AUSGEHEND (Action):                                         │
│  Agent → Workflow → Gmail Action → Mail an Mieter/Abteilung  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 1. Ausgehend: Workflow sendet Mails

### Verwendung im Workflow

Der "Scholli Mail Workflow" nutzt eine **Gmail Action Node** um:

1. **Bestätigungsmail an Mieter** — "Dein Anliegen wurde aufgenommen"
2. **Auftragsmail an Fachabteilung** — Strukturierte Zusammenfassung des Anliegens

### Mail-Templates

#### An Mieter (Bestätigung)

```
Betreff: Dein Anliegen bei der Freien Scholle — {{problem_category}}

Hallo {{name}},

wir haben dein Anliegen aufgenommen:

📋 Zusammenfassung: {{user_message}}
🏠 Adresse: {{address}} {{apartment_unit}}
📧 Rückmeldung an: {{email}}

Unsere Fachabteilung kümmert sich darum. Du erhältst eine Rückmeldung,
sobald es Neuigkeiten gibt.

Freundliche Grüße,
Scholli — Dein digitaler Assistent der Freien Scholle
```

#### An Fachabteilung (Auftrag)

```
Betreff: [Scholli] Neues Anliegen: {{problem_category}} — {{name}}

Neues Mieter-Anliegen via Scholli:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Mieter: {{name}}
🏠 Adresse: {{address}}, Wohnung {{apartment_unit}}
📧 E-Mail: {{email}}
📱 Telefon: {{phone}}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Anliegen:
{{user_message}}

⚡ Dringlichkeit: {{urgency}}
📅 Seit wann: {{since_when}}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Automatisch erstellt von Scholli | Session: {{session_id}}
```

### Empfänger-Mapping

| Agent / Kategorie | Empfänger-Mail | Hinweis |
|-------------------|---------------|---------|
| TBB (Reparaturen) | `tbb@freiescholle.de` | ⚠️ Platzhalter — echte Adresse einsetzen |
| Vermietung | `vermietung@freiescholle.de` | ⚠️ Platzhalter |
| Mitglieder | `mitglieder@freiescholle.de` | ⚠️ Platzhalter |
| Rechnungswesen | `rechnungswesen@freiescholle.de` | ⚠️ Platzhalter |
| HSG | `hsg@freiescholle.de` | ⚠️ Platzhalter |
| Öffentlichkeitsarbeit | `presse@freiescholle.de` | ⚠️ Platzhalter |

> ⚠️ **TODO:** Echte E-Mail-Adressen der Fachabteilungen eintragen!

---

## 2. Eingehend: Mails triggern Agenten

### Konzept

Ein **Integration Trigger** mit Gmail-Polling erkennt neue Mails im Postfach und startet einen Workflow oder Agent-Chat.

### Trigger-Konfiguration

```
Trigger: Neue Mail in Gmail Inbox
Filter: Absender enthält "@" (alle externen Mails)
Aktion: Starte Router-Agent mit Mail-Inhalt als Input
```

### Polling-Logik (Langdock Integration Trigger)

```javascript
// Polling-Code für Gmail Integration Trigger
const response = await fetch(
  'https://gmail.googleapis.com/gmail/v1/users/me/messages?q=is:unread after:' + 
  Math.floor(new Date(lastPollTime).getTime() / 1000),
  { headers: { 'Authorization': 'Bearer ' + secrets.GMAIL_TOKEN } }
);

if (!response.ok) throw new Error('Gmail API error: ' + response.status);

const data = await response.json();
if (!data.messages) return [];

// Nur neue Mails seit letztem Poll
return data.messages.map(msg => ({
  id: msg.id,
  threadId: msg.threadId
}));
```

> ⚠️ **Hinweis:** Langdock hat eine native Gmail-Integration — die Polling-Logik oben ist nur als Fallback dokumentiert. Bevorzugt die Langdock-eigene Gmail-Integration nutzen!

---

## 3. Setup-Anleitung (Langdock UI)

### Schritt 1: Gmail-Integration aktivieren

1. Langdock → Settings → Integrations
2. "Gmail" suchen und aktivieren
3. OAuth-Flow mit `britta.rade3101@gmail.com` durchlaufen
4. Berechtigungen: Lesen + Senden

### Schritt 2: Ausgehende Mails (Action im Workflow)

1. Workflow "Scholli Mail Workflow" öffnen
2. Nach dem Agent-Node eine **Action Node** hinzufügen
3. Integration: Gmail → Action: "Send Email"
4. Felder mappen:
   - To: `{{trigger.output.email}}` (Mieter) ODER feste Abteilungs-Mail
   - Subject: Template (siehe oben)
   - Body: Template (siehe oben)

### Schritt 3: Eingehende Mails (Trigger)

1. Neuen Workflow erstellen ODER bestehenden erweitern
2. Trigger: Integration Trigger → Gmail → "New Email"
3. Bedingung: Nur ungelesene, externe Mails
4. Weiterleitung an Router-Agent

---

## 4. Sicherheit & Datenschutz

| Aspekt | Maßnahme |
|--------|----------|
| Zugangsdaten | OAuth via Langdock (kein Passwort gespeichert) |
| Personendaten | Nur innerhalb Langdock verarbeitet |
| Mail-Logging | Keine Speicherung der Mail-Inhalte außerhalb Langdock |
| Absender-Identität | Mails kommen von `britta.rade3101@gmail.com` |
| Spam-Schutz | Nur verifizierte Mieter-Anliegen triggern Mails |

---

## 5. Offene Punkte

- [ ] Echte Abteilungs-Mailadressen eintragen
- [ ] Gmail OAuth in Langdock einrichten
- [ ] Mail-Templates mit Freier Scholle abstimmen
- [ ] Entscheiden: Separate Gmail für Produktion? (statt privat)
- [ ] Rate Limits: Wie viele Mails pro Tag realistisch?
- [ ] Reply-Handling: Was passiert wenn Mieter auf Bestätigung antwortet?