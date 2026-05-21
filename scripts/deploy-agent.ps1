<#
.SYNOPSIS
    Deploys or updates a Scholli agent to Langdock via API.

.DESCRIPTION
    Reads the system-prompt.md and config.json from an agent directory,
    then creates or updates the agent in Langdock.

.PARAMETER AgentPath
    Path to the agent directory (e.g., "agents/tbb")

.PARAMETER Action
    "create" (new agent) or "update" (existing agent). Default: auto-detect from config.json agentId.

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

# --- Load config ---
$configPath = Join-Path $AgentPath "config.json"
$promptPath = Join-Path $AgentPath "system-prompt.md"

if (-not (Test-Path $configPath)) { throw "config.json not found at $configPath" }
if (-not (Test-Path $promptPath)) { throw "system-prompt.md not found at $promptPath" }

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$promptRaw = Get-Content $promptPath -Raw

# Extract prompt block (between ``` markers)
if ($promptRaw -match '(?s)```\n(.+?)\n```') {
    $systemPrompt = $Matches[1]
} else {
    # Fallback: use full content after "## System-Prompt" heading
    $systemPrompt = $promptRaw -replace '(?s)^.*?## System-Prompt\s*\n', '' -replace '(?s)\n---.*$', ''
}

Write-Host "📋 Agent: $($config.name)"
Write-Host "📝 Prompt-Länge: $($systemPrompt.Length) Zeichen"

# --- Get API Key ---
$secret = az keyvault secret show --vault-name kv-cassini-ki-dev --name langdock-api-key --query value -o tsv 2>$null
if (-not $secret) { throw "Could not retrieve langdock-api-key from Key Vault" }
$apiHeaders = @{ "Authorization" = "Bearer $secret"; "Content-Type" = "application/json" }

# --- Determine action ---
if ($Action -eq "auto") {
    $Action = if ($config.agentId) { "update" } else { "create" }
}
Write-Host "🎯 Action: $Action"

# --- Build request body ---
$body = @{
    name = $config.name
    description = $config.description
    emoji = $config.emoji
    instruction = $systemPrompt
    creativity = $config.creativity
    inputType = $config.inputType
    webSearch = $config.webSearch
    imageGeneration = $config.imageGeneration
    dataAnalyst = $config.dataAnalyst
    canvas = $config.canvas
    extendedThinking = $config.extendedThinking
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
    Write-Host "✅ Agent erstellt: $agentId"
    Write-Host "→ https://app.langdock.com/agents/$agentId/edit"

    # Write back agent ID to config
    $config.agentId = $agentId
    $config | ConvertTo-Json -Depth 5 | Set-Content $configPath -Encoding UTF8
    Write-Host "📝 Agent-ID in config.json gespeichert"

} elseif ($Action -eq "update") {
    $response = Invoke-RestMethod -Uri "https://api.langdock.com/agent/v1/update" `
        -Headers $apiHeaders -Method Patch -Body $bodyJson -ContentType "application/json"

    Write-Host "✅ Agent aktualisiert (Draft): $($config.agentId)"
    Write-Host "→ https://app.langdock.com/agents/$($config.agentId)/edit"
}

Write-Host ""
Write-Host "⚠️  WICHTIG: Agent ist als DRAFT gespeichert."
Write-Host "   → Zum Veröffentlichen in der Langdock UI 'Publish' klicken."