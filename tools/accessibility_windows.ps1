# Only inspect the root window of the child process started in the marked QA folder.
param([Parameter(Mandatory=$true)][string]$QaFolder)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$qaMarker = [IO.File]::ReadAllText((Join-Path $QaFolder '.praxis-qa-owned')).Replace("`r`n", "`n")
if ($qaMarker -cne "Generated private verification session`n") {
    throw 'Unrecognized QA session'
}
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
function Find-Control([string]$Name) {
    $result = $qaRoot.FindFirst([Windows.Automation.TreeScope]::Descendants,
        [Windows.Automation.PropertyCondition]::new([Windows.Automation.AutomationElement]::NameProperty, $Name))
    if ($null -eq $result) { throw "Missing own control: $Name" }
    return $result
}
function Invoke-Control([string]$Name) {
    (Find-Control $Name).GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
    Start-Sleep -Milliseconds 500
}
function Set-Control([string]$Name, [string]$Value) {
    (Find-Control $Name).GetCurrentPattern([Windows.Automation.ValuePattern]::Pattern).SetValue($Value)
    Start-Sleep -Milliseconds 500
}
function Snapshot([string]$Name) {
    $cache = [Windows.Automation.CacheRequest]::new()
    foreach ($property in @([Windows.Automation.AutomationElement]::NameProperty,
            [Windows.Automation.AutomationElement]::ControlTypeProperty,
            [Windows.Automation.AutomationElement]::IsKeyboardFocusableProperty,
            [Windows.Automation.AutomationElement]::IsEnabledProperty,
            [Windows.Automation.AutomationElement]::IsOffscreenProperty,
            [Windows.Automation.AutomationElement]::HelpTextProperty,
            [Windows.Automation.AutomationElement]::ProcessIdProperty)) { $cache.Add($property) }
    $active = $cache.Activate()
    try { $elements = $qaRoot.FindAll([Windows.Automation.TreeScope]::Subtree, [Windows.Automation.Condition]::TrueCondition) }
    finally { $active.Dispose() }
    if ($elements.Count -gt 5000) { throw 'Own accessibility tree exceeded its bound' }
    $rows = @()
    foreach ($element in $elements) {
        $current = $element.Cached
        if ($current.ProcessId -ne $qaProcess.Id) { throw 'Accessibility tree left the owned process' }
        $rows += @{name=$current.Name;role=$current.ControlType.ProgrammaticName;
            focusable=$current.IsKeyboardFocusable;enabled=$current.IsEnabled;
            offscreen=$current.IsOffscreen;help=$current.HelpText}
    }
    [IO.File]::WriteAllText((Join-Path $QaFolder "$Name.json"),
        (@{elements=$rows;count=$rows.Count} | ConvertTo-Json -Depth 6 -Compress))
}
$qaExecutable = Join-Path $QaFolder 'PraxisCorporis\PraxisCorporis.exe'
$qaProcess = [Diagnostics.Process]::new()
$qaProcess.StartInfo.FileName = $qaExecutable
$qaProcess.StartInfo.WorkingDirectory = Split-Path $qaExecutable
$qaProcess.StartInfo.UseShellExecute = $false
$qaProcess.StartInfo.RedirectStandardOutput = $true
$qaProcess.StartInfo.RedirectStandardError = $true
$qaProcess.StartInfo.EnvironmentVariables['APPDATA'] = Join-Path $QaFolder 'uia-data'
$qaProcess.StartInfo.EnvironmentVariables['LOCALAPPDATA'] = Join-Path $QaFolder 'uia-cache'
$qaProcess.StartInfo.Arguments = '--audio-driver Dummy --accessibility always --log-file "' + (Join-Path $QaFolder 'engine.log') + '"'
if (-not $qaProcess.Start()) { throw 'Own viewer did not start' }
$qaStdout = $qaProcess.StandardOutput.ReadToEndAsync()
$qaStderr = $qaProcess.StandardError.ReadToEndAsync()
[IO.File]::WriteAllText((Join-Path $QaFolder 'launched.json'),
    (@{pid=$qaProcess.Id;executable=$qaExecutable} | ConvertTo-Json -Compress))
try {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    while ($true) {
        $qaProcess.Refresh()
        if ($qaProcess.HasExited) { throw 'Own viewer exited before ready' }
        if ($qaProcess.MainWindowHandle -ne [IntPtr]::Zero -and
                $qaProcess.MainWindowTitle -eq 'Praxis Corporis · Female reference (HRA v1.1)') { break }
        if ($watch.ElapsedMilliseconds -gt 45000) { throw 'Own viewer did not finish loading' }
        Start-Sleep -Milliseconds 100
    }
    $qaRoot = [Windows.Automation.AutomationElement]::FromHandle($qaProcess.MainWindowHandle)
    Snapshot 'baseline'
    $surface = Find-Control '3D anatomy view'
    $surface.SetFocus()
    Start-Sleep -Milliseconds 500
    if (-not $surface.Current.HasKeyboardFocus) { throw '3D surface did not accept native keyboard focus' }
    Set-Control 'Find anatomy' 'anatomy.heart.valve.mitral'
    Snapshot 'search'
    (Find-Control 'List view').GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Toggle()
    Set-Control 'Find anatomy' ''
    Snapshot 'page-one'
    Invoke-Control 'Next anatomy records: Next'
    Snapshot 'page-two'
    Invoke-Control 'Previous anatomy records: Previous'
    Snapshot 'page-return'
    (Find-Control 'List view').GetCurrentPattern([Windows.Automation.TogglePattern]::Pattern).Toggle()
    Start-Sleep -Milliseconds 500
    Snapshot 'hierarchy-return'
    Invoke-Control 'Saved views'
    Snapshot 'library'
    Set-Control 'Find saved views' 'Accessibility second'
    Snapshot 'library-filter'
    Invoke-Control 'Close'
} finally {
    if (-not $qaProcess.HasExited) {
        # The saved-views dialog is exclusive. Close its own button before the root.
        if ($null -ne $qaRoot) {
            $close = $qaRoot.FindFirst([Windows.Automation.TreeScope]::Descendants,
                [Windows.Automation.PropertyCondition]::new([Windows.Automation.AutomationElement]::NameProperty, 'Close'))
            if ($null -ne $close) {
                $close.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
                Start-Sleep -Milliseconds 500
            }
        }
        if (-not $qaProcess.CloseMainWindow()) { throw 'Own viewer close request failed' }
        if (-not $qaProcess.WaitForExit(30000)) { throw 'Own viewer did not close' }
    }
    $qaProcess.WaitForExit()
    [IO.File]::WriteAllText((Join-Path $QaFolder 'stdout.log'), $qaStdout.Result)
    [IO.File]::WriteAllText((Join-Path $QaFolder 'stderr.log'), $qaStderr.Result)
    [IO.File]::WriteAllText((Join-Path $QaFolder 'exit.json'),
        (@{pid=$qaProcess.Id;exit_code=$qaProcess.ExitCode;closed=$qaProcess.HasExited} | ConvertTo-Json -Compress))
    $qaProcess.Dispose()
}
