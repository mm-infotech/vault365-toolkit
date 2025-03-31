
<#
.SYNOPSIS
Vault365 Git pre-commit hook: Prevents commits that violate schema or folder policy.
#>

$schemaPath = "C:\Vault365\_Meta\Schema\Vault365_Schema_Final.json"
$vaultPath = "C:\Vault365"

# Fail if schema is missing
if (-Not (Test-Path $schemaPath)) {
    Write-Error "❌ Schema not found at $schemaPath. Cannot continue commit."
    exit 1
}

# Run validator script
$validatorScript = "C:\Vault365\_Meta\Scripts\Test-Vault365Schema.ps1"
if (-Not (Test-Path $validatorScript)) {
    Write-Error "❌ Schema validator not found at $validatorScript."
    exit 1
}

Write-Output "🔍 Running Vault365 schema validation..."
& $validatorScript

# Check validation log for errors
$logPath = "C:\Vault365\_Meta\Logs\SchemaValidationReport.txt"
if (Test-Path $logPath) {
    $errors = Get-Content $logPath | Where-Object { $_ -match "❌|⚠️" }
    if ($errors) {
        Write-Error "❌ Commit blocked: Schema violations detected:"
        $errors | ForEach-Object { Write-Error " - $_" }
        exit 1
    }
}

Write-Output "✅ Schema validation passed. Proceeding with commit."
exit 0
