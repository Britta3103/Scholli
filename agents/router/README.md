# Router Agent

> Status: 🔲 Noch nicht implementiert

Der Router-Agent ist der Einstiegspunkt für alle Mieter-Anfragen.
Er erkennt die Anliegen-Kategorie und leitet an den zuständigen Spezialisten weiter.

## Routing-Logik

| Erkennt | Weiterleitung an |
|---------|-----------------|
| Reparatur, Schaden, Schlüssel, Schimmel | → TBB Agent |
| Wohnung suchen, Kündigung, Tausch | → Vermietung Agent |
| Namensänderung, Dokumente, Termine | → Mitglieder Agent |
| Nebenkosten, Bank, Dividende, Sparen | → Rechnungswesen Agent |
| Garten, Rasen, Außenanlage | → HSG Agent |
| Zeitung, Newsletter | → Öffentlichkeitsarbeit Agent |
| Unklar / kein Match | → Allgemeine Info + Kontaktdaten |

## Nächste Schritte

- [ ] System-Prompt schreiben
- [ ] In Langdock anlegen
- [ ] Routing testen mit Beispiel-Anfragen