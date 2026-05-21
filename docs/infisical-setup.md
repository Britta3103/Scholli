# Infisical Setup für Scholli

Infisical läuft lokal als Docker-Container. Secrets (z.B. `LANGDOCK_API_KEY`) werden dort verwaltet und vom Deploy-Script automatisch abgerufen.

## Infisical starten

```powershell
cd C:\infisical
docker compose up -d
# Erreichbar unter: http://localhost:3000
```

## Einmalige Einrichtung (Browser)

1. **Browser öffnen:** http://localhost:3000
2. **Account erstellen** (oder einloggen)
3. **Neues Projekt anlegen:** Name `Scholli`
4. **Environment wechseln:** `prod`
5. **Secret hinzufügen:**
   - Key: `LANGDOCK_API_KEY`
   - Value: `<dein Langdock API Key>`
6. **Service Token erstellen** (für automatischen Zugriff ohne Browser-Login):
   - Projekt-Settings → Access Control → Service Tokens → Create Token
   - Environment: `prod`, Read-Berechtigung
   - Token kopieren und sicher aufbewahren

## CLI einrichten

```powershell
# Einmalig einloggen (öffnet Browser)
infisical login --domain http://localhost:3000

# Verbindung testen
infisical secrets get LANGDOCK_API_KEY --env prod --domain http://localhost:3000 --plain
```

## Service Token (alternativ zum Browser-Login)

```powershell
# Token als Umgebungsvariable setzen (für diese Session)
$env:INFISICAL_TOKEN = "st.<dein-token>"

# Oder dauerhaft in PowerShell-Profil eintragen:
Add-Content $PROFILE "`n`$env:INFISICAL_TOKEN = 'st.<dein-token>'"
```

## Deploy-Script verwenden

```powershell
cd C:\claude\Scholli

# Mit CLI-Login (nach infisical login)
.\scripts\deploy-agent.ps1 -AgentFolder agents\tbb

# Mit Service Token
$env:INFISICAL_TOKEN = "st.<dein-token>"
.\scripts\deploy-agent.ps1 -AgentFolder agents\tbb
```

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| "Could not fetch LANGDOCK_API_KEY" | `infisical login --domain http://localhost:3000` ausführen |
| Docker startet nicht | `docker compose -f C:\infisical\docker-compose.yml up -d` |
| Secret nicht gefunden | Im Browser prüfen ob Secret in `prod`-Environment liegt |
