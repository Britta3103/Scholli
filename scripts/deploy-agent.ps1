<#
.SYNOPSIS
    Deploys or updates a Scholli agent to Langdock via API.

.DESCRIPTION
    Reads the system-prompt.md and config.json from an agent directory,
    then creates or updates the agent in Langdock.
    API key is fetched automatically from Infisical (http://localhost:3000).

.PARAMETER AgentPath
    Path to the agent directory (e.g., "agents/tbb")

.PARAMETER Action
    "create" (new agent), "update" (existing agent), or "auto" (default: detect from config.json agentId).

.EXAMPLE
    .\scripts\deploy-agent.ps1 -AgentPath "agents/vermietung"
    .\scripts\deploy-agent.ps1 -AgentPath "agents/tbb" -Action update
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$AgentPath,

    [ValidateSet("create", "update", "auto")]
    [string]$Action = "auto"
)

$ErrorActionPreference = "Stop"

$INFISICAL_DOMAIN     = "http://localhost:3000"
$INFISICAL_PROJECT_ID = "ebf00661-5253-4008-850f-c241d9fb0af3"
$INFISICAL_ENV        = "prod"

# --- Load config ---
$configPath = Join-Path $AgentPath "config.json"
$promptPath = Join-Path $AgentPath "system-prompt.md"

if (-not (Test-Path $configPath)) { throw "config.json not found at $configPath" }
if (-not (Test-Path $promptPath)) { throw "system-prompt.md not found at $promptPath" }

$config    = Get-Content $configPath -Raw | ConvertFrom-Json
$promptRaw = Get-Content $promptPath -Raw

# Extract prompt block (between ``` markers)
if ($promptRaw -match '(?s)```\r?\n(.+?)\r?\n```') {
    $systemPrompt = $Matches[1].Trim()
} else {
    # Fallback: use full content after "## System-Prompt" heading
    $systemPrompt = $promptRaw -replace '(?s)^.*?## System-Prompt\s*\r?\n', '' -replace '(?s)\n---.*$', ''
}

Write-Host "Agent: $($config.name)"
Write-Host "Prompt-Laenge: $($systemPrompt.Length) Zeichen"

# --- Get API Key from Infisical ---
Write-Host "Fetching LANGDOCK_API_KEY from Infisical..."

$infisicalArgs = @(
    "secrets", "get", "LANGDOCK_API_KEY",
    "--projectId", $INFISICAL_PROJECT_ID,
    "--env", $INFISICAL_ENV,
    "--path", "/",
    "--plain",
    "--silent",
    "--domain", $INFISICAL_DOMAIN
)
if ($env:INFISICAL_TOKEN) {
    $infisicalArgs += "--token", $env:INFISICAL_TOKEN
}

$secret = (& infisical @infisicalArgs 2>&1).Trim()
if ($LASTEXITCODE -ne 0 -or -not $secret) {
    throw "Could not retrieve LANGDOCK_API_KEY from Infisical. Run: infisical login --domain $INFISICAL_DOMAIN"
}

$apiHeaders = @{ "Authorization" = "Bearer $secret"; "Content-Type" = "application/json" }

# --- Determine action ---
if ($Action -eq "auto") {
    $Action = if ($config.agentId) { "update" } else { "create" }
}
Write-Host "Action: $Action"

# --- Build request body ---
$body = @{
    name                 = $config.name
    description          = $config.description
    emoji                = $config.emoji
    instruction          = $systemPrompt
    creativity           = $config.creativity
    inputType            = $config.inputType
    webSearch            = $config.webSearch
    imageGeneration      = $config.imageGeneration
    dataAnalyst          = $config.dataAnalyst
    canvas               = $config.canvas
    extendedThinking     = $config.extendedThinking
    conversationStarters = $config.conversationStarters
}

if ($Action -eq "update") {
    $body["agentId"] = $config.agentId
}

$bodyJson = $body | ConvertTo-Json -Depth 5

# --- API Call ---
if ($Action -eq "create") {
    $response = Invoke-RestMethod -Uri "https://api.langdock.com/agent/v1/create" `
        -Headers $apiHeaders -Method Post -Body $bodyJson -ContentType "application/json"

    $agentId = $response.agent.id
    Write-Host "Agent erstellt: $agentId"
    Write-Host "-> https://app.langdock.com/agents/$agentId/edit"

    # Write back agent ID to config.json
    $config.agentId = $agentId
    $config | ConvertTo-Json -Depth 5 | Set-Content $configPath -Encoding UTF8
    Write-Host "Agent-ID in config.json gespeichert"

} elseif ($Action -eq "update") {
    $response = Invoke-RestMethod -Uri "https://api.langdock.com/agent/v1/update" `
        -Headers $apiHeaders -Method Patch -Body $bodyJson -ContentType "application/json"

    Write-Host "Agent aktualisiert (Draft): $($config.agentId)"
    Write-Host "-> https://app.langdock.com/agents/$($config.agentId)/edit"
}

Write-Host ""
Write-Host "WICHTIG: Agent ist als DRAFT gespeichert."
Write-Host "   -> Zum Veroeffentlichen in der Langdock UI 'Publish' klicken."
