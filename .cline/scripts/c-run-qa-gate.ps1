<#
.SYNOPSIS
    Standalone QA & Sandbox Dry-Run Verification Runner (cline-run-qa-gate.ps1) for SUNY_COMMON_DEV.
    Executes Gate 1 (Code Guard & Prettier), Gate 2 (Dry-Run Deploy), Gate 3 (Optional PermSet Assign),
    and Gate 4 (Server-Side Apex Tests & >=85% Coverage).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .cline/scripts/run-qa-gate.ps1 -TestClasses "CaseCountSelectorTest"
    powershell -ExecutionPolicy Bypass -File .cline/scripts/run-qa-gate.ps1 -TargetFiles "force-app/main/default/classes/CaseCountSelector.cls" -TestClasses "CaseCountSelectorTest"
#>
param(
    [Parameter(Mandatory = $false)]
    [string[]]$TargetFiles = @(),

    [Parameter(Mandatory = $false)]
    [string[]]$TestClasses = @(),

    [Parameter(Mandatory = $false)]
    [string]$TargetOrg = "SUNY_COMMON_DEV",

    [Parameter(Mandatory = $false)]
    [string]$PermSetName = "",

    [Parameter(Mandatory = $false)]
    [switch]$SkipSandboxDeploy
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Defects = New-Object System.Collections.Generic.List[string]

if ($TargetFiles.Count -gt 0) {
    $TargetFiles = @($TargetFiles | Where-Object { Test-Path (Join-Path $WorkspaceRoot $_) })
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " SUNY_COMMON_DEV QA Evaluation Gate (Target Org: $TargetOrg)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------
# GATE 1: Code Guard (Rules) & Prettier Formatting Check
# ------------------------------------------------------------------
Write-Host "`n[Gate 1/4] Running Static Code Guard & Prettier Check..." -ForegroundColor Yellow
Push-Location $WorkspaceRoot
try {
    if ($TargetFiles.Count -gt 0) {
        $GuardOut = (& node "$PSScriptRoot/c-sf-pre-write-guard.js" @TargetFiles 2>&1) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            $Defects.Add("Static Guardrail Violation:`n$GuardOut")
        }
        $PrettierOut = (& npx prettier --check @TargetFiles 2>&1) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            $Defects.Add("Prettier Formatting Check Failed:`n$PrettierOut")
        } else {
            Write-Host "  [OK] Gate 1 Passed (Code Guard & Prettier)" -ForegroundColor Green
        }
    } else {
        Write-Host "  [OK] Gate 1 Skipped (No specific TargetFiles passed)" -ForegroundColor DarkGray
    }
} finally {
    Pop-Location
}

# ------------------------------------------------------------------
# GATE 2: Sandbox Dry-Run Deployment to SUNY_COMMON_DEV
# ------------------------------------------------------------------
$DeployPassed = $true
if (-not $SkipSandboxDeploy) {
    Write-Host "`n[Gate 2/4] Validating metadata via Dry-Run Deploy ($TargetOrg)..." -ForegroundColor Yellow
    Push-Location $WorkspaceRoot
    try {
        $DeployPaths = if ($TargetFiles.Count -gt 0) { $TargetFiles } else { @("force-app") }
        $DeployArgs = @("project", "deploy", "start", "--dry-run", "--target-org", $TargetOrg, "--json")
        foreach ($dp in $DeployPaths) {
            $DeployArgs += "--source-dir"
            $DeployArgs += $dp
        }
        $DeployRaw = (& sf @DeployArgs 2>&1) -join "`n"
        $DeployJson = $DeployRaw | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($DeployJson -and $DeployJson.status -eq 0) {
            Write-Host "  [OK] Gate 2 Passed (Dry-Run Deploy to $TargetOrg)" -ForegroundColor Green
        } else {
            $DeployPassed = $false
            $Failures = @()
            if ($DeployJson -and $DeployJson.result -and $DeployJson.result.details -and $DeployJson.result.details.componentFailures) {
                foreach ($cf in $DeployJson.result.details.componentFailures) {
                    $Failures += "- File: $($cf.fileName) (Line $($cf.lineNumber)): [$($cf.problemType)] $($cf.problem)"
                }
            }
            $FailSummary = if ($Failures.Count -gt 0) { $Failures -join "`n" } else { $DeployRaw }
            $Defects.Add("Dry-Run Deployment Failed ($TargetOrg):`n$FailSummary")
            Write-Host "  [FAIL] Gate 2 Failed (Dry-Run Deployment)" -ForegroundColor Red
        }
    } finally {
        Pop-Location
    }
}

# ------------------------------------------------------------------
# GATE 3: Permission Set Assignment (Optional)
# ------------------------------------------------------------------
if ($PermSetName -and $DeployPassed) {
    Write-Host "`n[Gate 3/4] Assigning Permission Set '$PermSetName' in $TargetOrg..." -ForegroundColor Yellow
    Push-Location $WorkspaceRoot
    try {
        & sf org assign permset --name $PermSetName --target-org $TargetOrg --json 2>&1 | Out-Null
    } catch {} finally {
        Pop-Location
    }
}

# ------------------------------------------------------------------
# GATE 4: Server-Side Apex Unit Tests & Coverage (>= 85%)
# ------------------------------------------------------------------
if ($TestClasses.Count -eq 0 -and $TargetFiles.Count -gt 0) {
    foreach ($tf in $TargetFiles) {
        if ($tf -match "([a-zA-Z0-9_]+Test)\.cls$") {
            $TestClasses += $Matches[1]
        }
    }
}

if ($TestClasses.Count -gt 0 -and $DeployPassed) {
    Write-Host "`n[Gate 4/4] Running Server-Side Apex Tests ($($TestClasses -join ', '))..." -ForegroundColor Yellow
    Push-Location $WorkspaceRoot
    try {
        $TestArgs = @("apex", "run", "test", "--code-coverage", "--synchronous", "--target-org", $TargetOrg, "--json")
        foreach ($tc in $TestClasses) {
            $TestArgs += "--tests"
            $TestArgs += $tc
        }
        $TestRaw = (& sf @TestArgs 2>&1) -join "`n"
        $TestJson = $TestRaw | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($TestJson -and $TestJson.result -and $TestJson.result.summary) {
            $Outcome = $TestJson.result.summary.outcome
            $OrgWideCov = $TestJson.result.summary.testRunCoverage
            $CovNum = 0
            if ($OrgWideCov -match "(\d+)") {
                $CovNum = [int]$Matches[1]
            }

            if ($Outcome -eq "Passed" -and $CovNum -ge 85) {
                Write-Host "  [OK] Gate 4 Passed (Outcome: $Outcome | Coverage: $CovNum%)" -ForegroundColor Green
            } else {
                $TestFailDetails = @()
                if ($TestJson.result.tests) {
                    foreach ($t in $TestJson.result.tests) {
                        if ($t.Outcome -ne "Pass") {
                            $TestFailDetails += "- $($t.FullName): $($t.Message) | StackTrace: $($t.StackTrace)"
                        }
                    }
                }
                if ($CovNum -lt 85) {
                    $TestFailDetails += "- Code coverage is $CovNum% (minimum required is 85%)."
                }
                $Defects.Add("Apex Unit Test / Coverage Gate Failed:`n$($TestFailDetails -join "`n")")
                Write-Host "  [FAIL] Gate 4 Failed (Outcome: $Outcome | Coverage: $CovNum%)" -ForegroundColor Red
            }
        } else {
            $Defects.Add("Apex Test Execution Error:`n$TestRaw")
        }
    } finally {
        Pop-Location
    }
}

if ($Defects.Count -eq 0) {
    Write-Host "`n==================================================================" -ForegroundColor Green
    Write-Host " [QA PASSED] All checks verified against $TargetOrg!" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n==================================================================" -ForegroundColor Red
    Write-Host " [QA FAILED] Detected $($Defects.Count) failure(s):" -ForegroundColor Red
    foreach ($d in $Defects) {
        Write-Host "`n$d" -ForegroundColor Yellow
    }
    Write-Host "==================================================================" -ForegroundColor Red
    exit 1
}


