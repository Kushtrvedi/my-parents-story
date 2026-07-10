# RE-YOU OS Release Pipeline
param(
  [string]$Action = "all",
  [switch]$SkipBuild,
  [switch]$SkipDeploy,
  [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"
$ROOT = Split-Path -Parent $PSScriptRoot
$API_URL = "https://discerning-abundance-production-68d7.up.railway.app"

function Step($name, $script) {
  Write-Host "==> $name" -ForegroundColor Cyan
  & $script
  if ($LASTEXITCODE -ne 0) { throw "Step failed: $name" }
  Write-Host "    OK" -ForegroundColor Green
}

function Build {
  Step "Build" { pnpm --filter @reyou/server... run build }
}

function Test {
  Step "Test" { pnpm --filter @reyou/server... run typecheck }
}

function Deploy {
  Step "Deploy to Railway" { railway up --detach --yes }
}

function WaitForDeploy {
  Write-Host "==> Waiting for deployment..." -ForegroundColor Cyan
  Start-Sleep -Seconds 90
}

function HealthCheck {
  Step "Health check" {
    $resp = curl.exe -s -f "$API_URL/api/health"
    if (-not $resp) { throw "Health check failed" }
  }
}

function StatusCheck {
  Step "Status check" {
    $resp = curl.exe -s -f "$API_URL/api/status"
    $status = ($resp | ConvertFrom-Json).status
    if ($status -ne "operational") { throw "Status: $status" }
  }
}

function BackupCheck {
  Step "Backup verification" {
    $resp = curl.exe -s -X POST "$API_URL/api/ops/backup"
    $backup = ($resp | ConvertFrom-Json).backup
    if (-not $backup) { throw "Backup failed" }
    Write-Host "    Backup: $($backup.id)" -ForegroundColor Green
  }
}

function VerifyAll {
  HealthCheck
  StatusCheck
  BackupCheck
}

function TagRelease {
  $version = if (Test-Path "$ROOT/package.json") { (Get-Content "$ROOT/package.json" | ConvertFrom-Json).version } else { "0.1.0" }
  $tag = "v$version-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  Step "Tag release ($tag)" { git tag -a $tag -m "Release $tag" }
  Step "Push tags" { git push origin --tags }
  Write-Host "    Tagged: $tag" -ForegroundColor Green
}

# ─── Main ───
Write-Host "RE-YOU OS Release Pipeline" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow

Push-Location $ROOT
try {
  switch ($Action) {
    "build" { Build }
    "deploy" { if (-not $SkipBuild) { Build }; Deploy; WaitForDeploy; if (-not $SkipVerify) { VerifyAll } }
    "verify" { VerifyAll }
    "tag" { TagRelease }
    default {
      if (-not $SkipBuild) { Build }
      Deploy
      WaitForDeploy
      if (-not $SkipVerify) { VerifyAll }
      TagRelease
    }
  }
  Write-Host "Done." -ForegroundColor Green
} catch {
  Write-Host "FAILED: $_" -ForegroundColor Red
  exit 1
} finally {
  Pop-Location
}
