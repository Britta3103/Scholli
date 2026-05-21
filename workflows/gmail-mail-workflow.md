# Gmail Mail Workflow — Spezifikation

> Für Erstellung im Langdock Workflow Builder

## Zweck

Sendet nach abgeschlossenem Agent-Gespräch zwei Mails:
1. Bestätigung an den Mieter
2. Auftrags-Zusammenfassung an die zuständige Fachabteilung

## Trigger

**Form Trigger** (wird vom Agent aufgerufen)

### Input-Felder

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|-------------|
| `problem_category` | SELECT | ✅ | Kategorie: TBB, Vermietung, Mitglieder, Rechnungswesen, HSG, Öffentlichkeitsarbeit |
| `user_message` | MULTI_LINE_TEXT | ✅ | Zusammenfassung des Anliegens |
| `name` | TEXT | ✅ | Name des Mieters |
| `address` | TEXT | ✅ | Adresse |
| `apartment_unit` | TEXT | ❌ | Wohnungsnummer |
| `email` | EMAIL | ✅ | E-Mail des Mieters |
| `phone` | TEXT | ❌ | Telefonnummer |
| `urgency` | SELECT | ❌ | normal / hoch / dringend |
| `since_when` | TEXT | ❌ | Seit wann besteht das Problem |

## Workflow-Nodes

```
[Form Trigger]
       │
       ▼
[Condition: Dringlichkeit prüfen]
  ├─ urgency == "dringend" → Betreff-Prefix: "[DRINGEND]"
  └─ sonst → normaler Betreff
       │
       ▼
[Code Node: Empfänger-Routing]
  → Mapped problem_category auf Empfänger-Mail
       │
       ▼
[Action: Gmail — Mail an Fachabteilung senden]
  To: {{code.output.department_email}}
  Subject: [Scholli] {{problem_category}} — {{name}}
  Body: Auftrags-Template
       │
       ▼
[Action: Gmail — Bestätigung an Mieter senden]
  To: {{trigger.output.email}}
  Subject: Dein Anliegen bei der Freien Scholle
  Body: Bestätigungs-Template
       │
       ▼
[Output: Ergebnis]
  → "Anliegen wurde an {{department}} weitergeleitet.
     Bestätigung an {{email}} gesendet."
```

## Code Node: Empfänger-Routing

```javascript
// Mapping Kategorie → Abteilungs-Mail
const routing = {
  'TBB': 'tbb@freiescholle.de',
  'Vermietung': 'vermietung@freiescholle.de',
  'Mitglieder': 'mitglieder@freiescholle.de',
  'Rechnungswesen': 'rechnungswesen@freiescholle.de',
  'HSG': 'hsg@freiescholle.de',
  'Öffentlichkeitsarbeit': 'presse@freiescholle.de'
};

const category = inputs.problem_category;
const departmentEmail = routing[category] || 'info@freiescholle.de';

return {
  department_email: departmentEmail,
  department_name: category,
  is_urgent: inputs.urgency === 'dringend'
};
```

## Builder-Chat Prompt

> Diesen Text in den Langdock Workflow Builder-Chat einfügen um den Workflow zu erstellen:

```
Erstelle einen Workflow mit folgender Logik:

1. Form Trigger mit diesen Feldern:
   - problem_category (Dropdown: TBB, Vermietung, Mitglieder, Rechnungswesen, HSG, Öffentlichkeitsarbeit)
   - user_message (Mehrzeiliger Text, Pflicht)
   - name (Text, Pflicht)
   - address (Text, Pflicht)
   - apartment_unit (Text, optional)
   - email (E-Mail, Pflicht)
   - phone (Text, optional)
   - urgency (Dropdown: normal, hoch, dringend — optional)
   - since_when (Text, optional)

2. Code Node der die problem_category auf eine E-Mail-Adresse mapped

3. Gmail Action: Sende Mail an die gemappte Abteilungsadresse mit Betreff "[Scholli] {Kategorie} — {Name}" und einer strukturierten Zusammenfassung aller Felder

4. Gmail Action: Sende Bestätigungsmail an die Mieter-email mit freundlichem Text dass das Anliegen aufgenommen wurde

5. Output Node: Gib zurück welche Abteilung kontaktiert wurde
```

## Hinweise

- ⚠️ Abteilungs-Mails sind Platzhalter — vor Go-Live durch echte ersetzen
- Gmail-Integration muss in Langdock Settings aktiviert sein
- OAuth-Consent für `britta.rade3101@gmail.com` erforderlich
- Workflow nach Erstellung mit dem Scholli-Agent verknüpfen (Agent → Actions → Workflows)