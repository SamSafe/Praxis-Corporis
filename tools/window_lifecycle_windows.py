"""Check normal-launch desktop persistence against one owned Windows executable."""
from __future__ import annotations

import json
import hashlib
import pathlib
import shutil

SCRIPT = r'''$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PraxisWindowStateQA {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out Rect r);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out Rect r);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int w, int z, uint flags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int mode);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr h);
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint message, IntPtr w, IntPtr l);
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    public static int[] ClientSize(IntPtr h) { Rect r; if (!GetClientRect(h, out r)) throw new Exception("Client rectangle unavailable"); return new [] {r.Right-r.Left,r.Bottom-r.Top}; }
    public static void ResizeClient(IntPtr h, int width, int height) {
        Rect r; if (!GetWindowRect(h, out r)) throw new Exception("Window rectangle unavailable");
        int[] c=ClientSize(h);
        if (!SetWindowPos(h,IntPtr.Zero,0,0,width+r.Right-r.Left-c[0],height+r.Bottom-r.Top-c[1],0x16)) throw new Exception("Own window resize failed");
    }
}
'@
[void][PraxisWindowStateQA]::SetThreadDpiAwarenessContext([IntPtr](-4))
$folder = FOLDER
$output = OUTPUT
$executable = EXECUTABLE
[void][IO.Directory]::CreateDirectory($output)
$statePath = Join-Path $folder 'user-data\PraxisCorporisPrototype\window-state.json'
$script:active = $null
$script:lifecycleWatch = [Diagnostics.Stopwatch]::StartNew()
function Wait-For([scriptblock]$condition) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    while ($true) {
        if ($script:lifecycleWatch.ElapsedMilliseconds -gt 180000) { throw 'Own window lifecycle timed out' }
        if (& $condition) { return }
        if ($watch.ElapsedMilliseconds -gt 60000) { throw 'Own window lifecycle step timed out' }
        Start-Sleep -Milliseconds 100
    }
}
function Start-Viewer([string]$stage) {
    $p = [Diagnostics.Process]::new()
    $p.StartInfo.FileName = $executable
    $p.StartInfo.WorkingDirectory = Split-Path $executable
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.RedirectStandardOutput = $true
    $p.StartInfo.RedirectStandardError = $true
    $p.StartInfo.EnvironmentVariables['APPDATA'] = Join-Path $folder 'user-data'
    $p.StartInfo.EnvironmentVariables['LOCALAPPDATA'] = Join-Path $folder 'cache'
    $log = Join-Path $folder ($stage + '.log')
    $p.StartInfo.Arguments = '--audio-driver Dummy --log-file "' + $log + '"'
    if (-not $p.Start()) { throw 'Own viewer did not start' }
    $script:active = $p
    $stdout = $p.StandardOutput.ReadToEndAsync()
    $stderr = $p.StandardError.ReadToEndAsync()
    Wait-For {
        $p.Refresh()
        if ($p.HasExited) { throw ('Viewer exited before ready: ' + $p.ExitCode) }
        ($p.MainWindowHandle -ne [IntPtr]::Zero) -and (Test-Path $log) -and ((Get-Content -Raw -ErrorAction SilentlyContinue $log) -match 'Prepared 801 meshes')
    }
    return @{Process=$p;Stdout=$stdout;Stderr=$stderr;Stage=$stage;Log=$log}
}
function Close-Viewer($run) {
    if (-not [PraxisWindowStateQA]::PostMessage($run.Process.MainWindowHandle,0x10,[IntPtr]::Zero,[IntPtr]::Zero)) { throw 'Own viewer close request failed' }
    if (-not $run.Process.WaitForExit(30000)) { throw 'Own viewer did not close' }
    $text = $run.Stdout.Result + $run.Stderr.Result
    [IO.File]::WriteAllText((Join-Path $output ($run.Stage + '-stdout.log')), $text)
    Copy-Item $run.Log (Join-Path $output ($run.Stage + '.log'))
    if ($run.Process.ExitCode -ne 0 -or $text -match '(?m)^ERROR:|SCRIPT ERROR:') { throw 'Normal viewer launch reported an error' }
    $script:active = $null
    $run.Process.Dispose()
    if (-not (Test-Path $statePath)) { throw 'Normal shutdown did not save window layout' }
    $saved = Get-Content -Raw $statePath | ConvertFrom-Json
    Copy-Item $statePath (Join-Path $output ($run.Stage + '-state.json'))
    return $saved
}
try {
    if (Test-Path $statePath) { throw 'Lifecycle fixture must start without user window settings' }
    $first = Start-Viewer 'window-first'
    [void][PraxisWindowStateQA]::ShowWindow($first.Process.MainWindowHandle,9)
    Wait-For { -not [PraxisWindowStateQA]::IsZoomed($first.Process.MainWindowHandle) }
    [PraxisWindowStateQA]::ResizeClient($first.Process.MainWindowHandle,1300,800)
    Wait-For { $c=[PraxisWindowStateQA]::ClientSize($first.Process.MainWindowHandle); $c[0] -eq 1300 -and $c[1] -eq 800 }
    $firstSaved = Close-Viewer $first
    $second = Start-Viewer 'window-second'
    $reopenedSize = [PraxisWindowStateQA]::ClientSize($second.Process.MainWindowHandle)
    [void][PraxisWindowStateQA]::ShowWindow($second.Process.MainWindowHandle,3)
    Wait-For { [PraxisWindowStateQA]::IsZoomed($second.Process.MainWindowHandle) }
    Start-Sleep -Milliseconds 250
    $maximizedSaved = Close-Viewer $second
    $third = Start-Viewer 'window-third'
    $reopenedMaximized = [PraxisWindowStateQA]::IsZoomed($third.Process.MainWindowHandle)
    [void][PraxisWindowStateQA]::ShowWindow($third.Process.MainWindowHandle,9)
    Wait-For { $c=[PraxisWindowStateQA]::ClientSize($third.Process.MainWindowHandle); $c[0] -eq 1300 -and $c[1] -eq 800 }
    $unmaximizedSize = [PraxisWindowStateQA]::ClientSize($third.Process.MainWindowHandle)
    $finalSaved = Close-Viewer $third
    @{schema_version=1;first_saved=$firstSaved;reopened_size=$reopenedSize;maximized_saved=$maximizedSaved;reopened_maximized=$reopenedMaximized;unmaximized_size=$unmaximizedSize;final_saved=$finalSaved} | ConvertTo-Json -Depth 6 -Compress
} finally {
    if ($null -ne $script:active) {
        if (-not $script:active.HasExited) { $script:active.Kill(); [void]$script:active.WaitForExit(10000) }
        $script:active.Dispose()
    }
}
'''


def validate_observations(data: dict) -> None:
    if not isinstance(data, dict) or type(data.get('schema_version')) is not int or data['schema_version'] != 1:
        raise ValueError('Unsupported normal-window lifecycle observations')
    for key, maximized in [('first_saved', False), ('maximized_saved', True), ('final_saved', False)]:
        record = data.get(key, {})
        if (not isinstance(record, dict) or type(record.get('schema_version')) is not int or record['schema_version'] != 1 or record.get('size') != [1300, 800]
                or record.get('maximized') is not maximized):
            raise ValueError('Normal window layout was not retained: ' + key)
    if data.get('reopened_size') != [1300, 800] or data.get('unmaximized_size') != [1300, 800] or data.get('reopened_maximized') is not True:
        raise ValueError('Normal window reopen/maximize behavior differs from the saved layout')


def verify_lifecycle(args, session: pathlib.Path, folder: str, executable: str) -> dict:
    # Import at call time: the shared runner also imports this protocol module.
    from verify_windows import powershell, ps_literal, write_report
    if not pathlib.Path(args.output).is_dir():
        raise ValueError('A retained evidence folder is required')
    command = SCRIPT.replace('FOLDER', ps_literal(folder)).replace('OUTPUT', ps_literal(folder + '\\window-lifecycle-evidence')).replace('EXECUTABLE', ps_literal(executable))
    result = powershell(args, command, timeout=240)
    (args.output / 'window-lifecycle-runtime.log').write_text(result.stdout + result.stderr, encoding='utf-8')
    evidence = session / 'window-lifecycle-evidence'
    if evidence.is_dir():
        shutil.copytree(evidence, args.output / 'window-lifecycle')
    if result.returncode:
        raise RuntimeError('Normal window lifecycle failed; see window-lifecycle-runtime.log')
    observations = json.loads(result.stdout)
    validate_observations(observations)
    observations['protocol_sha256'] = hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest()
    write_report(args.output / 'window-lifecycle.json', observations)
    return observations
