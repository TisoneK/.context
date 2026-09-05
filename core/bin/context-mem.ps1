#!/usr/bin/env pwsh
# context-mem.ps1 — Windows port of context-mem (memory-registry hygiene).
#
# Update-in-place files hold ONE entry per key: correct an entry by editing
# its row/block, never by appending a second one (its prior value is in git
# history). This is the opposite of the append-only logs. 'check' flags
# duplicate keys in system/ai-models.md (key = Agent, Model) and
# system/environments.md (key = the "Identify by:" line).

[CmdletBinding()]
param(
  [Parameter(Position = 0)] [string] $Command = '',
  [Parameter(ValueFromRemainingArguments = $true)] [string[]] $RestArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Say { param([string]$Message) Write-Output $Message }
function ErrLine { param([string]$Message) [Console]::Error.WriteLine("context-mem: $Message") }
function Die { param([string]$Message) ErrLine $Message; exit 2 }

$scriptDir = $PSScriptRoot
$coreDir = (Resolve-Path (Join-Path $scriptDir '..')).Path
$contextDir = Split-Path -Parent $coreDir
$memoryDir = Join-Path $contextDir 'memory'

function Usage {
  @(
    'context-mem check — flag duplicate keys in the update-in-place registries:',
    '  system/ai-models.md     key = (Agent, Model)   — one row per pair',
    '  system/environments.md  key = "Identify by:"    — one block per env',
    'Correct in place (edit the entry); never append a duplicate.',
    'Exit codes: 0 clean, 1 duplicate key, 2 usage/error'
  ) | ForEach-Object { Say $_ }
  exit 2
}

function Check-AiModels {
  $f = Join-Path $memoryDir 'system/ai-models.md'
  if (-not (Test-Path -LiteralPath $f)) { return $true }
  $seen = @{}; $where = @{}; $ln = 0
  foreach ($raw in Get-Content -LiteralPath $f) {
    $ln++
    $line = $raw.TrimEnd("`r")
    if ($line -notmatch '^\s*\|') { continue }
    $cells = $line.Split('|')
    if ($cells.Count -lt 6) { continue }
    $a = $cells[1].Trim(); $m = $cells[2].Trim()
    $fs = $cells[3].Trim(); $ls = $cells[4].Trim(); $s = $cells[5].Trim()
    if ($fs -match '^\d{4}-\d{2}-\d{2}$' -and $ls -match '^\d{4}-\d{2}-\d{2}$' -and $s -match '^\d+$') {
      $key = "$a`t$m"
      if ($seen.ContainsKey($key)) { $seen[$key]++; $where[$key] += " $ln" }
      else { $seen[$key] = 1; $where[$key] = "$ln" }
    }
  }
  $dup = $false
  foreach ($k in $seen.Keys) {
    if ($seen[$k] -gt 1) {
      $parts = $k.Split("`t")
      ErrLine ('DUP ai-models.md: {0} rows for agent="{1}" model="{2}" (lines {3}) — merge into one row; sessions accumulate, old values are in git history' -f $seen[$k], $parts[0], $parts[1], $where[$k].Trim())
      $dup = $true
    }
  }
  return (-not $dup)
}

function Check-Environments {
  $f = Join-Path $memoryDir 'system/environments.md'
  if (-not (Test-Path -LiteralPath $f)) { return $true }
  $seen = @{}; $where = @{}; $ln = 0
  foreach ($raw in Get-Content -LiteralPath $f) {
    $ln++
    $line = $raw.TrimEnd("`r")
    if ($line -notmatch '^\s*-\s*\*\*Identify by:\*\*') { continue }
    $v = ($line -replace '^\s*-\s*\*\*Identify by:\*\*\s*', '').Trim()
    if ($v -eq '' -or $v -match '^<') { continue }
    if ($seen.ContainsKey($v)) { $seen[$v]++; $where[$v] += " $ln" }
    else { $seen[$v] = 1; $where[$v] = "$ln" }
  }
  $dup = $false
  foreach ($k in $seen.Keys) {
    if ($seen[$k] -gt 1) {
      ErrLine ('DUP environments.md: {0} blocks with Identify by="{1}" (lines {2}) — merge into one block; keep the latest facts, old ones are in git history' -f $seen[$k], $k, $where[$k].Trim())
      $dup = $true
    }
  }
  return (-not $dup)
}

switch ($Command) {
  'check' {
    if (-not (Test-Path -LiteralPath $memoryDir)) { Say 'context-mem: no memory dir (nothing to check)'; exit 0 }
    $ok1 = Check-AiModels
    $ok2 = Check-Environments
    if ($ok1 -and $ok2) { Say 'memory check passed: no duplicate keys in the update-in-place registries'; exit 0 }
    ErrLine 'memory check failed: a registry has more than one entry for a key — correct in place (edit the entry), do not append a duplicate'
    exit 1
  }
  { $_ -in @('', '-h', '--help', 'help') } { Usage }
  default { Die "unknown command '$Command' (try: context-mem.ps1 help)" }
}
