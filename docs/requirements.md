# Requirements Specification — Scholli Agenten-Flotte

> Version: 1.0 | Datum: 2026-05-21 | Autoren: Sven Rosemann, Britta

---

## 1. Projektziel

Entwicklung einer Flotte spezialisierter KI-Agenten für die **Freie Scholle eG** (Wohnungsbaugenossenschaft, Bielefeld, ~5.000 Wohneinheiten), die Mietern bei alltäglichen Anliegen helfen.

## 2. Stakeholder

| Rolle | Person/Gruppe | Kontext |
|-------|--------------|---------|
| Product Owner | Britta | Entwickelt Agenten mit Claude Code |
| Technical Lead | Sven Rosemann (Cassini AG) | Architektur, API, Infrastruktur |
| Endnutzer | Mieter der Freien Scholle | Deutschsprachig, alle Altersgruppen |
| IT Admin | Benni | Interne IT, Microsoft-Stack |
| Empfänger | Hausverwaltung (Fachabteilungen) | Erhalten die weitergeleiteten Anliegen |

## 3. Systemkontext

### 3.1 IT-Umgebung Freie Scholle

| Komponente | Status |
|-----------|--------|
| Active Directory | On-Premise |
| Microsoft Stack | Intranet/Extranet-Struktur |
| M365 / Entra | ❌ Nicht vorhanden |
| CRM | Wodis (ERP für Wohnungswirtschaft) |
| Cloud-Readiness | Gering |

### 3.2 Plattform

- **Langdock** (SaaS) — Agenten + Workflows
- **Channel:** Langdock Chat (Web) — ggf. später weitere
- **Deployment:** Langdock Cloud (kein Self-Hosting nötig)

---

## 4. Agenten-Architektur

### 4.1 Strategie: Spezialisierte Agenten

```
┌─────────────────────────────────────────────────────────────┐
│                     MIETER (Chat)                           │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                   ROUTER AGENT                               │
│  Erkennt Anliegen-Typ → leitet an Spezialisten weiter       │
└──┬────────┬────────┬────────┬────────┬────────┬─────────────┘
   ▼        ▼        ▼        ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
│Vermie│ │ TBB  │ │Mitgl.│ │Rechn.│ │ HSG  │ │ ÖA   │
│tung  │ │      │ │      │ │wesen │ │      │ │      │
└──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘ └──┬───┘
   ▼        ▼        ▼        ▼        ▼        ▼
┌──────────────────────────────────────────────────────────────┐
│                    WORKFLOWS                                 │
│  Mail-Workflow │ Dokument-Workflow │ CRM-Workflow (MVP+)     │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 Agenten-Übersicht

| # | Agent | Kürzel | Verantwortung |
|---|-------|--------|--------------|
| 0 | **Router** | `router` | Erkennt Anliegen, leitet an Spezialisten weiter |
| 1 | **Vermietung** | `vermietung` | Wohnungssuche, Tausch, Kündigung, Status |
| 2 | **TBB** (Techn. Betrieb & Bauen) | `tbb` | Reparaturen, Schäden, Schlüssel, Schimmel |
| 3 | **Mitglieder & Verträge** | `mitglieder` | Namensänderung, Personenzahl, Dokumente, Termine |
| 4 | **Rechnungswesen** | `rechnungswesen` | Bankdaten, Nebenkosten, Dividende, Spareinrichtung |
| 5 | **Hauswirtschaft (HSG)** | `hsg` | Garten, Rasen, Außenanlagen |
| 6 | **Öffentlichkeitsarbeit** | `oeffentlichkeit` | Mieterzeitung, Newsletter, Events |

---

## 5. Use Cases je Agent

### 5.1 Router Agent

| UC-ID | Use Case | Weiterleitung an |
|-------|----------|-----------------|
| R-01 | Erkennt Anliegen-Kategorie | Zuständigen Spezialisten |
| R-02 | Begrüßt Mieter | — |
| R-03 | Fragt bei Unklarheit nach | — |
| R-04 | Fallback: kein passender Agent | Allgemeine Info + Kontaktdaten |

### 5.2 Vermietung

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| V-01 | Freie Wohnung suchen (5 Zimmer etc.) | Zimmerzahl, ggf. Bestandsmieter? | Info-Antwort oder Weiterleitung |
| V-02 | Bestandsmieter → interner Bereich | Mieterstatus prüfen | Verweis auf Extranet |
| V-03 | Wohnung tauschen | Name, aktuelle Wohnung, Wunschwohnung | Mail an Vermietung |
| V-04 | Kündigungsfrist erfragen | — | Info-Antwort (Standard: 3 Monate) |
| V-05 | Nachmieter vorschlagen | Name, Kontakt Nachmieter | Mail an Vermietung |
| V-06 | Kündigungsstatus abfragen | Name, Kündigungsdatum | Mail an Vermietung (Statusfrage) |

### 5.3 TBB (Technischer Betrieb & Bauen)

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| T-01 | Wasserschaden melden | Adresse, Wohnung, Beschreibung, Dringlichkeit | Mail an TBB (dringend) |
| T-02 | Wasserhahn tropft | Adresse, Wohnung | Mail an TBB |
| T-03 | Toilette verstopft | Adresse, Wohnung, seit wann | Mail an TBB (dringend) |
| T-04 | Fenster klemmt | Adresse, Wohnung, welches Fenster | Mail an TBB |
| T-05 | Schlüssel nachbestellen | Name, Adresse, Schlüsseltyp | Mail an TBB + Kostenhinweis |
| T-06 | Schimmel melden | Adresse, Wohnung, Raum, **Foto-Upload** | Mail an TBB + Foto-Anhang |

### 5.4 Mitglieder & Verträge

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| M-01 | Personenanzahl ändern | Name, Wohnung, neue Anzahl | Mail an Mitgliederverwaltung |
| M-02 | Namensänderung (Hochzeit) | Alter Name, neuer Name, Nachweis | Mail + Dokument-Anforderung |
| M-03 | Mietbescheinigung anfordern | Name, Wohnung, Zweck | Mail an Mitgliederverwaltung |
| M-04 | Dokumentenkopie anfordern | Name, welches Dokument | Mail an Mitgliederverwaltung |
| M-05 | Kündigungsfrist Genossenschaftsanteile | — | Info-Antwort + Formular anbieten |
| M-06 | Termin Vertragsunterschrift buchen | Name, gewünschter Zeitraum | Terminbuchung (Workflow) |

### 5.5 Rechnungswesen

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| F-01 | Bankverbindung ändern | Name, neue IBAN | Mail an Rechnungswesen |
| F-02 | NK-Guthaben Auszahlungstermin | Name, Abrechnungsjahr | Info oder Mail |
| F-03 | Nebenkostenabrechnung erklären | Name, konkreter Posten | Info-Antwort (FAQ) |
| F-04 | Dividende Auszahlungstermin | — | Info-Antwort (jährlich festgelegt) |
| F-05 | Strom in NK enthalten? | — | Info-Antwort (Nein, separat) |
| F-06 | Was ist die Spareinrichtung? | — | Info-Antwort |
| F-07 | Sparkonditionen aktuell | — | Info-Antwort (aus Knowledge Base) |
| F-08 | Sparen ohne Mitgliedschaft? | — | Info-Antwort (Nein, nur Mitglieder) |

### 5.6 Hauswirtschaft (HSG)

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| H-01 | Rasenmäh-Frequenz | Adresse/Anlage | Info-Antwort |
| H-02 | Eigene Bepflanzung erlaubt? | Adresse, was gepflanzt werden soll | Info + ggf. Genehmigungshinweis |

### 5.7 Öffentlichkeitsarbeit

| UC-ID | Use Case | Pflichtinfos | Backend-Aktion |
|-------|----------|-------------|----------------|
| O-01 | Mieterzeitung verfügbar? | — | Info + Link/PDF |
| O-02 | Newsletter abonnieren | E-Mail-Adresse | Newsletter-Anmeldung |

---

## 6. Backend-Aktionen (Workflows)

### 6.1 MVP — Workflow-Typen

| # | Workflow | Trigger | Output |
|---|---------|---------|--------|
| W-01 | **Zusammenfassungs-Mail** | Agent → Workflow | Mail an Mieter (Bestätigung) + Mail an Fachabteilung (Auftrag) |
| W-02 | **Dokument-Erstellung** | Agent → Workflow | Generiertes Dokument (z.B. Mietbescheinigung-Anforderung) |
| W-03 | **Info-Antwort** | Agent direkt | Keine Backend-Aktion, Agent antwortet aus Knowledge Base |

### 6.2 Post-MVP

| # | Workflow | Beschreibung |
|---|---------|-------------|
| W-04 | **CRM-Eintrag (Wodis)** | Vorgang in Wodis anlegen (erfordert API/Integration) |
| W-05 | **Terminbuchung** | Termin in Outlook/Kalender buchen |
| W-06 | **Newsletter-Workflow** | Mieterzeitung/Newsletter erstellen und versenden |

---

## 7. Datenfluss

### 7.1 Pflichtfelder (global)

Jeder Agent sammelt mindestens:

| Feld | Pflicht | Beschreibung |
|------|---------|-------------|
| `name` | ✅ | Name des Mieters |
| `address` | ✅ | Adresse / Siedlung |
| `apartment_unit` | ❌ | Wohnungsnummer |
| `email` | ✅ | E-Mail für Rückmeldung |
| `problem_category` | ✅ | Automatisch vom Router gesetzt |
| `problem_description` | ✅ | Freitext-Zusammenfassung |

### 7.2 Zusätzliche Felder je Agent

| Agent | Zusatzfelder |
|-------|-------------|
| TBB | `urgency`, `since_when`, `photos` (Upload) |
| Vermietung | `room_count`, `is_existing_tenant`, `desired_move_date` |
| Mitglieder | `document_type`, `preferred_date` |
| Rechnungswesen | `iban`, `billing_year`, `specific_item` |

---

## 8. Nicht-funktionale Anforderungen

| NFR | Anforderung |
|-----|-------------|
| Sprache | Deutsch, einfache Sprache, freundlich |
| Antwortzeit | < 10 Sekunden |
| Verfügbarkeit | Langdock SaaS SLA |
| Datenschutz | Keine Speicherung personenbezogener Daten außerhalb Langdock |
| Sicherheit | Keine internen Prozesse dem Mieter offenlegen |
| Barrierefreiheit | Einfache Sprache, klare Struktur |
| Skalierbarkeit | Neue Agenten/Use Cases ohne Code-Änderung hinzufügbar |

---

## 9. Knowledge Base (geplant)

| Thema | Quelle | Format |
|-------|--------|--------|
| FAQ Nebenkosten | Freie Scholle intern | Markdown/PDF |
| Spareinrichtung Konditionen | Aktueller Flyer | PDF |
| Kündigungsfristen | Satzung | Markdown |
| Kontaktdaten Fachabteilungen | Intern | Tabelle |
| Mieterzeitung Archiv | Website | PDF-Links |

---

## 10. Rollout-Plan

| Phase | Scope | Ziel |
|-------|-------|------|
| **Phase 1 (MVP)** | Router + TBB + Vermietung | Proof of Concept, 2 Spezialistenagenten |
| **Phase 2** | + Mitglieder + Rechnungswesen | Kernprozesse abgedeckt |
| **Phase 3** | + HSG + Öffentlichkeit + Wodis-Integration | Vollständige Flotte |
| **Phase 4** | Weitere Channels (Teams, WhatsApp) | Multi-Channel |

---

## 11. Offene Fragen

- [ ] Welche E-Mail-Adressen erhalten die Auftrags-Mails je Abteilung?
- [ ] Gibt es eine Wodis-API oder nur manuelle Eingabe?
- [ ] Soll der Mieter eine Bestätigungsmail bekommen?
- [ ] Foto-Upload: Wie kommt das Bild an die Fachabteilung?
- [ ] Knowledge Base: Wer pflegt die Inhalte?
- [ ] Gibt es eine Vertretungsregelung (Abwesenheit)?
- [ ] Soll es Öffnungszeiten geben oder 24/7?

---

## 12. Akzeptanzkriterien (MVP)

- [ ] Router erkennt mind. 90% der Anliegen korrekt
- [ ] TBB-Agent sammelt alle Pflichtinfos in max. 4 Rückfragen
- [ ] Mail-Workflow sendet korrekte Zusammenfassung an richtige Abteilung
- [ ] Mieter erhält Bestätigung dass Anliegen weitergeleitet wurde
- [ ] Kein Anliegen geht verloren (immer Weiterleitung oder Fallback)
- [ ] Agent offenbart nie interne Systeme/Prozesse