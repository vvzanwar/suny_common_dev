<#
.SYNOPSIS
    Safe, Token-Efficient Sandbox Database & Schema Bridge (Cline -> SUNY_COMMON_DEV)
.DESCRIPTION
    Provides read-only database communication with the SUNY_COMMON_DEV sandbox:
    1. -Query "<SOQL>"       : Executes a read-only SOQL query (enforces SELECT-only and auto-caps unbounded rows to save context tokens).
    2. -ToolingApi           : Runs the SOQL query against the Salesforce Tooling API (e.g., EntityDefinition, FieldDefinition, ApexClass).
    3. -Describe "<SObject>" : Retrieves live SObject schema metadata from SUNY_COMMON_DEV in a compact, token-efficient table (with optional -FieldFilter).
    4. -OrgLimits            : Fetches live governor/org limits from SUNY_COMMON_DEV.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -Query "SELECT Id, Name, Status FROM IndividualApplication LIMIT 10"
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -Describe "IndividualApplication" -FieldFilter "Status"
#>
param(
    [Parameter(Mandatory = $false)]
    [string]$Query = "",

    [Parameter(Mandatory = $false)]
    [switch]$ToolingApi,

    [Parameter(Mandatory = $false)]
    [string]$Describe = "",

    [Parameter(Mandatory = $false)]
    [string]$FieldFilter = "",

    [Parameter(Mandatory = $false)]
    [switch]$OrgLimits,

    [Parameter(Mandatory = $false)]
    [string]$TargetOrg = "SUNY_COMMON_DEV",

    [Parameter(Mandatory = $false)]
    [int]$MaxRows = 50
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TelemetryPath = Join-Path $WorkspaceRoot ".cline\telemetry\events.json"

function Write-Telemetry {
    param([string]$Action, [string]$Target, [string]$Status)
    if (Test-Path $TelemetryPath) {
        try {
            $events = Get-Content $TelemetryPath -Raw | ConvertFrom-Json
            if ($null -eq $events) { $events = @() }
            elseif ($events -isnot [System.Array]) { $events = @($events) }
            $events += [PSCustomObject]@{
                timestamp  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                event_type = "org_db_communication"
                action     = $Action
                target     = $Target
                org        = $TargetOrg
                status     = $Status
            }
            $events | ConvertTo-Json -Depth 5 | Set-Content -Path $TelemetryPath -Encoding UTF8
        } catch {
            # Ignore telemetry write errors
        }
    }
}

# ---------------------------------------------------------------------------
# Mode 1: SOQL Query (-Query)
# ---------------------------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($Query)) {
    $trimmedQuery = $Query.Trim()

    # Safety Guard: Block any non-SELECT statements
    if ($trimmedQuery -notmatch "^(?i)SELECT\s+") {
        Write-Error "[BLOCKED] Only read-only SELECT queries are permitted via query-org.ps1. Received: $trimmedQuery"
        exit 1
    }

    # Token Guard: Auto-append LIMIT if missing on non-aggregate queries
    $hasLimit = $trimmedQuery -match "(?i)\bLIMIT\s+\d+\s*$"
    $isAggregate = $trimmedQuery -match "(?i)\bSELECT\s+(COUNT|SUM|AVG|MIN|MAX)\s*\(" -and $trimmedQuery -notmatch "(?i)\bGROUP\s+BY\b"
    if (-not $hasLimit -and -not $isAggregate) {
        $trimmedQuery = "$trimmedQuery LIMIT $MaxRows"
        Write-Host "[TOKEN-GUARD] No LIMIT clause detected; auto-appended 'LIMIT $MaxRows' to protect context window." -ForegroundColor Yellow
    }

    $apiMode = if ($ToolingApi) { "Tooling API" } else { "Standard Data API" }
    Write-Host "[DB-QUERY] ($apiMode -> $TargetOrg): $trimmedQuery" -ForegroundColor Cyan

    $sfArgs = @("data", "query", "--query", $trimmedQuery, "--target-org", $TargetOrg, "--json")
    if ($ToolingApi) {
        $sfArgs += "--use-tooling-api"
    }

    $rawJson = & sf @sfArgs 2>&1 | Out-String
    try {
        $parsed = $rawJson | ConvertFrom-Json
    } catch {
        Write-Telemetry -Action "soql_query" -Target $trimmedQuery -Status "parse_error"
        Write-Error "[DB-ERROR] Failed to parse sf data query JSON output:`n$rawJson"
        exit 1
    }

    if ($parsed.status -ne 0) {
        Write-Telemetry -Action "soql_query" -Target $trimmedQuery -Status "query_error"
        Write-Error "[DB-ERROR] $($parsed.name): $($parsed.message)"
        exit 1
    }

    Write-Telemetry -Action "soql_query" -Target $trimmedQuery -Status "success"
    $totalSize = $parsed.result.totalSize
    $records = $parsed.result.records

    Write-Host "[OK] Total Matching Records: $totalSize (Showing: $($records.Count))" -ForegroundColor Green
    if ($records.Count -gt 0) {
        # Strip Salesforce 'attributes' metadata property for clean, low-token output
        $cleanRecords = foreach ($rec in $records) {
            $obj = [ordered]@{}
            foreach ($prop in $rec.PSObject.Properties) {
                if ($prop.Name -ne "attributes") {
                    $obj[$prop.Name] = $prop.Value
                }
            }
            [PSCustomObject]$obj
        }
        $cleanRecords | Format-Table -AutoSize | Out-String | Write-Host
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Mode 2: SObject Schema Describe (-Describe)
# ---------------------------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($Describe)) {
    $sObjectName = $Describe.Trim()
    $localDocPath = Join-Path $WorkspaceRoot "docs\objects\$sObjectName.md"
    if (Test-Path $localDocPath) {
        Write-Host "[TIP] Local schema doc also exists at docs/objects/$sObjectName.md (0-token read)." -ForegroundColor Yellow
    }

    Write-Host "[DB-DESCRIBE] Fetching live schema for '$sObjectName' from $TargetOrg..." -ForegroundColor Cyan
    $rawJson = & sf sobject describe --sobject $sObjectName --target-org $TargetOrg --json 2>&1 | Out-String
    try {
        $parsed = $rawJson | ConvertFrom-Json
    } catch {
        Write-Telemetry -Action "sobject_describe" -Target $sObjectName -Status "parse_error"
        Write-Error "[DB-ERROR] Failed to parse sf sobject describe JSON:`n$rawJson"
        exit 1
    }

    if ($parsed.status -ne 0) {
        Write-Telemetry -Action "sobject_describe" -Target $sObjectName -Status "describe_error"
        Write-Error "[DB-ERROR] $($parsed.name): $($parsed.message)"
        exit 1
    }

    Write-Telemetry -Action "sobject_describe" -Target $sObjectName -Status "success"
    $fields = $parsed.result.fields
    if (-not [string]::IsNullOrWhiteSpace($FieldFilter)) {
        $fields = $fields | Where-Object {
            $_.name -match $FieldFilter -or $_.label -match $FieldFilter -or $_.type -match $FieldFilter
        }
    }

    $compactFields = foreach ($f in $fields) {
        $refTo = if ($f.referenceTo -and $f.referenceTo.Count -gt 0) { ($f.referenceTo -join ",") } else { "" }
        [PSCustomObject]@{
            APIName     = $f.name
            Label       = $f.label
            Type        = $f.type
            Required    = (-not $f.nillable -and -not $f.defaultedOnCreate)
            Custom      = $f.custom
            ReferenceTo = $refTo
        }
    }

    Write-Host "[OK] SObject: $($parsed.result.name) ($($parsed.result.label)) | KeyPrefix: $($parsed.result.keyPrefix) | Custom: $($parsed.result.custom) | Matching Fields: $($compactFields.Count)" -ForegroundColor Green
    $compactFields | Sort-Object APIName | Format-Table -AutoSize | Out-String | Write-Host
    exit 0
}

# ---------------------------------------------------------------------------
# Mode 3: Org Governor Limits (-OrgLimits)
# ---------------------------------------------------------------------------
if ($OrgLimits) {
    Write-Host "[DB-LIMITS] Fetching live org limits from $TargetOrg..." -ForegroundColor Cyan
    & sf org list limits --target-org $TargetOrg
    Write-Telemetry -Action "org_limits" -Target "limits" -Status "success"
    exit 0
}

Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  1. SOQL Query   : powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -Query `"SELECT Id, Name FROM Account LIMIT 10`""
Write-Host "  2. Tooling API  : powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -Query `"SELECT Id, Name FROM ApexClass LIMIT 10`" -ToolingApi"
Write-Host "  3. Describe Obj : powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -Describe `"IndividualApplication`" -FieldFilter `"Status`""
Write-Host "  4. Org Limits   : powershell -ExecutionPolicy Bypass -File scripts/cline/cline-query-org.ps1 -OrgLimits"
exit 0

