# [WORKFLOW-NAME] — Workflow Spec

> Status: TODO
> Abteilung: [ABTEILUNG]
> Erstellt: [DATUM]

## Zweck

[Beschreibe in 1-2 Sätzen, was dieser Workflow tut und warum er existiert.]

## Trigger

- **Typ:** `form` | `manual`
- **Ausgelöst von:** Agent „[AGENT-NAME]"
- **Bedingung:** Alle Pflichtfelder sind vollständig

## Input-Felder

| Feldname         | Typ    | Pflicht | Beschreibung                    |
|------------------|--------|---------|---------------------------------|
| `user_message`   | string | ✅      | Zusammenfassung des Anliegens   |
| `name`           | string | ✅      | Name des Mieters                |
| `address`        | string | ✅      | Adresse / Wohnort               |
| `apartment_unit` | string | ❌      | Wohnungsnummer, falls bekannt   |
| `email`          | string | ✅      | E-Mail-Adresse des Mieters      |
| `phone`          | string | ❌      | Telefonnummer (optional)        |
| `[FELD]`         | string | ❌      | [Beschreibung]                  |

## Workflow-Schritte

1. **[SCHRITT 1]** — [Beschreibung, z.B. "E-Mail an Fachabteilung senden"]
2. **[SCHRITT 2]** — [Beschreibung]
3. **[SCHRITT 3 optional]** — [Beschreibung]

## Output / Antwort an Agent

```
[Beispiel-Antwort die der Workflow zurückgibt, z.B. "Mail erfolgreich gesendet an ...]
```

## Langdock Builder Anweisung

Füge diese Beschreibung in den Langdock Builder Chat ein, um den Workflow zu erstellen:

```
Erstelle einen Workflow mit dem Namen „[WORKFLOW-NAME]".

Trigger: Form-Trigger mit folgenden Feldern:
- user_message (Text, Pflicht)
- name (Text, Pflicht)
- address (Text, Pflicht)
- apartment_unit (Text, optional)
- email (Text, Pflicht)
- phone (Text, optional)

Schritte:
1. [Schritt 1 auf Deutsch beschreiben]
2. [Schritt 2 auf Deutsch beschreiben]

Rückgabe: Bestätigungstext auf Deutsch.
```

## Hinweise

- Workflow-Name darf max. 63 Zeichen haben (wegen Tool-Name-Limit in Langdock)
- Nach Erstellung: Workflow in Langdock UI mit dem zugehörigen Agenten verknüpfen (Actions → Workflows)
- Workflow-ID nach Erstellung hier eintragen und in `agents/[AGENT]/config.json` übernehmen
