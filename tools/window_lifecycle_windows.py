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
$referencePath = Join-Path $folder 'user-data\PraxisCorporisPrototype\reference-state.json'
$referenceCases = REFERENCE_CASES | ConvertFrom-Json
$script:referenceRecords = @()
$script:referenceTitles = @()
$script:referenceWrites = @()
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
function Seed-Reference($record) {
    [void][IO.Directory]::CreateDirectory((Split-Path $referencePath))
    [IO.File]::WriteAllText($referencePath, ($record | ConvertTo-Json -Compress))
}
function Record-Reference($run) {
    $script:referenceRecords += @(Get-Content -Raw $referencePath | ConvertFrom-Json)
    $script:referenceTitles += @($run.Title)
    $script:referenceWrites += @($run.ReferenceWritten)
}
function Start-Viewer([string]$stage, [string]$expectedTitle = '') {
    $referenceBefore = if ($null -ne $referenceCases) { [IO.File]::GetLastWriteTimeUtc($referencePath).Ticks } else { 0 }
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
    if (-not $p.WaitForInputIdle(30000)) { throw 'Own viewer GUI did not become idle' }
    Wait-For {
        $p.Refresh()
        if ($p.HasExited) { throw ('Viewer exited before ready: ' + $p.ExitCode) }
        $p.MainWindowHandle -ne [IntPtr]::Zero
    }
    if ($expectedTitle) {
        Wait-For {
            $p.Refresh()
            if ($p.HasExited) { throw ('Viewer exited before reference ready: ' + $p.ExitCode) }
            $p.MainWindowTitle -eq $expectedTitle
        }
    }
    return @{Process=$p;Stdout=$stdout;Stderr=$stderr;Stage=$stage;Log=$log;Title=$p.MainWindowTitle;ReferenceBefore=$referenceBefore}
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
    if ($null -ne $referenceCases) {
        if (-not (Test-Path $referencePath)) { throw 'Normal shutdown did not save its reference' }
        Copy-Item $referencePath (Join-Path $output ($run.Stage + '-reference.json'))
        $run.ReferenceWritten = [IO.File]::GetLastWriteTimeUtc($referencePath).Ticks -ne $run.ReferenceBefore
    }
    return $saved
}
try {
    if (Test-Path $statePath) { throw 'Lifecycle fixture must start without user window settings' }
    $maleTitle = ''
    if ($null -ne $referenceCases) {
        if (Test-Path $referencePath) { throw 'Lifecycle fixture must start without user reference settings' }
        Seed-Reference $referenceCases.male.record
        $maleTitle = $referenceCases.male.title
    }
    $first = Start-Viewer 'window-first' $maleTitle
    [void][PraxisWindowStateQA]::ShowWindow($first.Process.MainWindowHandle,9)
    Wait-For { -not [PraxisWindowStateQA]::IsZoomed($first.Process.MainWindowHandle) }
    [PraxisWindowStateQA]::ResizeClient($first.Process.MainWindowHandle,1300,800)
    Wait-For { $c=[PraxisWindowStateQA]::ClientSize($first.Process.MainWindowHandle); $c[0] -eq 1300 -and $c[1] -eq 800 }
    $firstSaved = Close-Viewer $first
    if ($null -ne $referenceCases) { Record-Reference $first }
    $second = Start-Viewer 'window-second' $maleTitle
    Wait-For { $c=[PraxisWindowStateQA]::ClientSize($second.Process.MainWindowHandle); $c[0] -eq 1300 -and $c[1] -eq 800 }
    $reopenedSize = [PraxisWindowStateQA]::ClientSize($second.Process.MainWindowHandle)
    [void][PraxisWindowStateQA]::ShowWindow($second.Process.MainWindowHandle,3)
    Wait-For { [PraxisWindowStateQA]::IsZoomed($second.Process.MainWindowHandle) }
    Start-Sleep -Milliseconds 250
    $maximizedSaved = Close-Viewer $second
    $studyTitle = ''
    if ($null -ne $referenceCases) {
        Record-Reference $second
        Seed-Reference $referenceCases.study.record
        $studyTitle = $referenceCases.study.title
    }
    $third = Start-Viewer 'window-third' $studyTitle
    Wait-For { [PraxisWindowStateQA]::IsZoomed($third.Process.MainWindowHandle) }
    $reopenedMaximized = [PraxisWindowStateQA]::IsZoomed($third.Process.MainWindowHandle)
    [void][PraxisWindowStateQA]::ShowWindow($third.Process.MainWindowHandle,9)
    Wait-For { $c=[PraxisWindowStateQA]::ClientSize($third.Process.MainWindowHandle); $c[0] -eq 1300 -and $c[1] -eq 800 }
    $unmaximizedSize = [PraxisWindowStateQA]::ClientSize($third.Process.MainWindowHandle)
    $finalSaved = Close-Viewer $third
    $observations = @{schema_version=1;first_saved=$firstSaved;reopened_size=$reopenedSize;maximized_saved=$maximizedSaved;reopened_maximized=$reopenedMaximized;unmaximized_size=$unmaximizedSize;final_saved=$finalSaved}
    if ($null -ne $referenceCases) {
        Record-Reference $third
        Seed-Reference $referenceCases.unavailable
        $fallback = Start-Viewer 'reference-fallback' $referenceCases.female.title
        [void](Close-Viewer $fallback)
        Record-Reference $fallback
        $observations['reference_startup'] = @{saved=$script:referenceRecords;titles=$script:referenceTitles;written=$script:referenceWrites}
    }
    $observations | ConvertTo-Json -Depth 8 -Compress
} finally {
    if ($null -ne $script:active) {
        if (-not $script:active.HasExited) { $script:active.Kill(); [void]$script:active.WaitForExit(10000) }
        $script:active.Dispose()
    }
}
'''


def reference_cases(bodies: list[dict]) -> dict:
    cases = {}
    for key, identity in [('male', 'male'), ('female', 'female'), ('study', 'hra-v1-2-female-cord-study')]:
        body = next((body for body in bodies if body['id'] == identity), None)
        if body is None:
            raise ValueError('Startup verification source is missing: ' + identity)
        cases[key] = {'record': {'schema_version': 1, 'body_id': identity, 'source_sha256': body['sha256']},
                      'title': 'Praxis Corporis · ' + body.get('short_label', body['label'])}
    cases['unavailable'] = {'schema_version': 1, 'body_id': 'not-installed', 'source_sha256': '0' * 64}
    return cases


def validate_observations(data: dict, references: dict | None = None) -> None:
    if not isinstance(data, dict) or type(data.get('schema_version')) is not int or data['schema_version'] != 1:
        raise ValueError('Unsupported normal-window lifecycle observations')
    for key, maximized in [('first_saved', False), ('maximized_saved', True), ('final_saved', False)]:
        record = data.get(key, {})
        if (not isinstance(record, dict) or type(record.get('schema_version')) is not int or record['schema_version'] != 1 or record.get('size') != [1300, 800]
                or record.get('maximized') is not maximized):
            raise ValueError('Normal window layout was not retained: ' + key)
    if data.get('reopened_size') != [1300, 800] or data.get('unmaximized_size') != [1300, 800] or data.get('reopened_maximized') is not True:
        raise ValueError('Normal window reopen/maximize behavior differs from the saved layout')
    if references is not None:
        observed = data.get('reference_startup')
        expected = [references[key] for key in ['male', 'male', 'study', 'female']]
        if not isinstance(observed, dict) or observed.get('titles') != [case['title'] for case in expected]:
            raise ValueError('Normal startup did not open its expected reference titles')
        written = observed.get('written')
        if not isinstance(written, list) or len(written) != 4 or not all(value is True for value in written):
            raise ValueError('Normal shutdown did not write a fresh startup-reference file')
        records = observed.get('saved')
        if not isinstance(records, list) or len(records) != 4:
            raise ValueError('Normal startup reference records are incomplete')
        for record, case in zip(records, expected):
            if not isinstance(record, dict) or type(record.get('schema_version')) is not int or record != case['record']:
                raise ValueError('Normal shutdown did not retain its completed source identity')


def verify_lifecycle(args, session: pathlib.Path, folder: str, executable: str, references: dict | None = None) -> dict:
    # Import at call time: the shared runner also imports this protocol module.
    from verify_windows import powershell, ps_literal, write_report
    if not pathlib.Path(args.output).is_dir():
        raise ValueError('A retained evidence folder is required')
    command = SCRIPT.replace('FOLDER', ps_literal(folder)).replace('OUTPUT', ps_literal(folder + '\\window-lifecycle-evidence')).replace('EXECUTABLE', ps_literal(executable)).replace('REFERENCE_CASES', ps_literal(json.dumps(references)))
    result = powershell(args, command, timeout=240)
    (args.output / 'window-lifecycle-runtime.log').write_text(result.stdout + result.stderr, encoding='utf-8')
    evidence = session / 'window-lifecycle-evidence'
    if evidence.is_dir():
        shutil.copytree(evidence, args.output / 'window-lifecycle')
    if result.returncode:
        raise RuntimeError('Normal window lifecycle failed; see window-lifecycle-runtime.log')
    observations = json.loads(result.stdout)
    validate_observations(observations, references)
    observations['protocol_sha256'] = hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest()
    write_report(args.output / 'window-lifecycle.json', observations)
    return observations
