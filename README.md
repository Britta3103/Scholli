# Scholli 🏠

**Agenten-Flotte für die Wohnungsbaugesellschaft "Freie Scholle" (Bielefeld)**

> 5.000 Wohneinheiten | Langdock-Plattform | Spezialisierte KI-Agenten

## Was ist Scholli?

Scholli ist eine Flotte von KI-Agenten, die Mietern der Freien Scholle bei alltäglichen Anliegen hilft — von Reparaturmeldungen über Kündigungsfragen bis zur Nebenkostenabrechnung.

## Architektur

```
Mieter (Chat) → Router Agent → Spezialist → Workflow → Fachabteilung
```

### Agenten-Flotte

| # | Agent | Status | Aufgabe |
|---|-------|--------|---------|
| 0 | 🎯 Router | 🔲 TODO | Erkennt Anliegen, leitet weiter |
| 1 | 🏘️ Vermietung | 🔲 TODO | Wohnungssuche, Kündigung, Tausch |
| 2 | 🔧 TBB | ✅ v1 vorhanden | Reparaturen, Schäden, Schlüssel |
| 3 | 📋 Mitglieder | 🔲 TODO | Namensänderung, Dokumente, Termine |
| 4 | 💰 Rechnungswesen | 🔲 TODO | Nebenkosten, Bank, Spareinrichtung |
| 5 | 🌿 HSG | 🔲 TODO | Garten, Außenanlagen |
| 6 | 📰 Öffentlichkeitsarbeit | 🔲 TODO | Mieterzeitung, Newsletter |

## Quick Start (für Britta mit Claude Code)

### 1. Repo klonen
```bash
git clone https://github.com/Britta3103/Scholli.git
cd Scholli
```

### 2. Neuen Agent erstellen
```bash
# Template kopieren
cp -r agents/_template agents/mein-agent

# System-Prompt bearbeiten
# → agents/mein-agent/system-prompt.md

# Config anpassen
# → agents/mein-agent/config.json
```

### 3. Agent in Langdock anlegen
- Langdock UI → Agents → Create
- System-Prompt einfügen
- Workflow verknüpfen (Actions → Workflows)
- Testen!

### 4. Optional: Per API deployen
```bash
# Siehe scripts/deploy-agent.ps1
```

## Dokumentation

| Dokument | Beschreibung |
|----------|-------------|
| [Requirements](docs/requirements.md) | Vollständige Anforderungsspezifikation |
| [Architecture](docs/architecture.md) | Technische Architektur & Node-Typen |
| [Langdock API](docs/langdock-api.md) | API-Referenz mit Beispielen |
| [Platform Reference](docs/langdock-platform-reference.md) | Komplette Langdock-Doku (92 KB) |
| [CLAUDE.md](CLAUDE.md) | AI-Instructions für Claude Code |

## Entwicklungs-Workflow

```
1. Prompt schreiben (agents/<name>/system-prompt.md)
2. Im Langdock Chat testen
3. Iterieren bis Verhalten stimmt
4. Workflow in Langdock Builder erstellen
5. Agent + Workflow verknüpfen
6. End-to-End testen
7. Committen & dokumentieren
```

## Links

- [Langdock Platform](https://app.langdock.com)
- [Scholli Agent (TBB v1)](https://app.langdock.com/agents/a1b11586-0e78-4e5a-b36d-bfe7c9995ee8/edit)
- [Scholli Mail Workflow](https://app.langdock.com/workflows/8723e518-81bd-4672-9591-a6b67d685fa4)
- [Langdock API Docs](https://docs.langdock.com)

---

*Entwickelt von Sven Rosemann (Cassini AG) & Britta*