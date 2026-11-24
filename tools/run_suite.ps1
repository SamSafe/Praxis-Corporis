# Run the headless Godot smoke suite on Windows (the Linux runner's equivalent).
#
#   powershell -ExecutionPolicy Bypass -File tools\run_suite.ps1 [-Godot PATH] [-Out DIR] [-Only NAME,...]
#
# Each tests\*_smoke.gd runs in its own engine process with a 25-minute limit; its
# output goes to OUT\<name>.log and "<exit code> <name>" lines to OUT\summary.txt.
# APPDATA points at build\dev-environment for the engine so the suite never reads or
# writes the real %APPDATA%\PraxisCorporisPrototype saved views and preferences.
param(
    [string]$Godot = "",
    [string]$Out = "",
    [string[]]$Only = @(),
    [int]$TimeoutSeconds = 1500
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (-not $Godot) {
    $Godot = Join-Path $root "build\toolchain\engine\Godot_v4.7.2-stable_win64_console.exe"
}
if (-not (Test-Path $Godot)) { throw "Godot not found at $Godot; pass -Godot." }
if (-not $Out) { $Out = Join-Path $root "build\suite" }
New-Item -ItemType Directory -Force $Out | Out-Null
$appdata = Join-Path $root "build\dev-environment\appdata"
New-Item -ItemType Directory -Force $appdata | Out-Null

$tests = Get-ChildItem (Join-Path $root "tests") -Filter "*_smoke.gd" | Sort-Object Name
$Only = @($Only | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($Only.Count) {
    $tests = @($tests | Where-Object { $Only -contains $_.BaseName })
    $unknown = $Only | Where-Object { -not (Test-Path (Join-Path $root "tests\$_.gd")) }
    if ($unknown) { throw "No such smoke test: $($unknown -join ', ')" }
}
if (-not $tests.Count) { throw "No smoke tests selected." }
$summary = Join-Path $Out "summary.txt"
Set-Content $summary "" -Encoding utf8 -NoNewline
$failed = @()
$savedAppData = $env:APPDATA
try {
    $env:APPDATA = $appdata
    foreach ($t in $tests) {
        $name = $t.BaseName
        $log = Join-Path $Out "$name.log"
        $started = Get-Date
        $p = Start-Process -FilePath $Godot -ArgumentList @("--headless", "--path", "`"$root`"", "--script", "tests/$($t.Name)") `
            -RedirectStandardOutput $log -RedirectStandardError "$log.err" -NoNewWindow -PassThru
        $null = $p.Handle  # keeps the handle so ExitCode is available after exit
        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
            $p.Kill(); $p.WaitForExit(); $code = 124
        } else { $code = $p.ExitCode }
        if (Test-Path "$log.err") { Get-Content "$log.err" | Add-Content $log; Remove-Item "$log.err" }
        $seconds = [int]((Get-Date) - $started).TotalSeconds
        Add-Content $summary "$code $name" -Encoding utf8
        Write-Host ("{0,-4} {1} ({2}s)" -f $code, $name, $seconds)
        if ($code -ne 0) { $failed += $name }
    }
} finally {
    $env:APPDATA = $savedAppData
}
Add-Content $summary "DONE" -Encoding utf8
if ($failed.Count) { Write-Host "FAILED: $($failed -join ', ')"; exit 1 }
Write-Host "All $($tests.Count) smoke tests passed."
