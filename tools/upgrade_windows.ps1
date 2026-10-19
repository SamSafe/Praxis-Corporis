# Exercise only an owned private app window and its generated shared data folder.
param([Parameter(Mandatory=$true)][string]$QaFolder,
      [Parameter(Mandatory=$true)][string]$JobFile)
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
if ([IO.File]::ReadAllText((Join-Path $QaFolder '.praxis-qa-owned')).Replace("`r`n","`n") -cne "Generated private verification session`n") {throw 'Unrecognized QA session'}
$job=Get-Content -Raw -Encoding UTF8 $JobFile | ConvertFrom-Json
$runFolder=Join-Path $QaFolder ('runs\'+$job.tag)
[void][IO.Directory]::CreateDirectory($runFolder)
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public static class PraxisUpgradeInput {
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int Left,Top,Right,Bottom;}
 [DllImport("user32.dll",EntryPoint="PostMessageW",CharSet=CharSet.Unicode)] public static extern bool PostMessage(IntPtr h,uint m,IntPtr w,IntPtr l);
 [DllImport("user32.dll",EntryPoint="MapVirtualKeyW")] public static extern uint MapVirtualKey(uint k,uint m);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr c);
}
'@
[void][PraxisUpgradeInput]::SetThreadDpiAwarenessContext([IntPtr](-4))
function Find-Optional([string]$Name) {
 $element=$qaRoot.FindFirst([Windows.Automation.TreeScope]::Descendants,[Windows.Automation.PropertyCondition]::new([Windows.Automation.AutomationElement]::NameProperty,$Name))
 if ($null -ne $element -and $element.Current.ProcessId -ne $qaProcess.Id) {throw 'Control left the owned process'}
 return $element
}
function Control([string]$Name,[bool]$Enabled=$true) {
 $watch=[Diagnostics.Stopwatch]::StartNew()
 while ($true) {
  if ($qaProcess.HasExited) {throw 'Owned app exited during a control action'}
  $element=Find-Optional $Name
  if ($null -ne $element -and ((-not $Enabled) -or $element.Current.IsEnabled)) {return $element}
  if ($watch.ElapsedMilliseconds -gt 30000) {
   $rows=@()
   foreach ($item in $qaRoot.FindAll([Windows.Automation.TreeScope]::Subtree,[Windows.Automation.Condition]::TrueCondition)) {
    if ($item.Current.ProcessId -ne $qaProcess.Id) {throw 'Diagnostic tree left the owned process'}
    $rows+=@{name=$item.Current.Name;enabled=$item.Current.IsEnabled;focused=$item.Current.HasKeyboardFocus;role=$item.Current.ControlType.ProgrammaticName}
   }
   [IO.File]::WriteAllText((Join-Path $runFolder 'failed-control.json'),(@{requested=$Name;elements=$rows}|ConvertTo-Json -Depth 5 -Compress))
   throw "Own control not ready: $Name"
  }
  Start-Sleep -Milliseconds 100
 }
}
function Invoke-Control([string]$Name) {
 (Control $Name).GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
 Start-Sleep -Milliseconds 250
}
function Value-Control([string]$Name,[string]$Value) {
 (Control $Name).GetCurrentPattern([Windows.Automation.ValuePattern]::Pattern).SetValue($Value)
 Start-Sleep -Milliseconds 250
}
function Focus-Control([string]$Name) {
 $element=Control $Name
 [void][PraxisUpgradeInput]::SetForegroundWindow($qaProcess.MainWindowHandle)
 $element.SetFocus()
 $watch=[Diagnostics.Stopwatch]::StartNew()
 while (-not $element.Current.HasKeyboardFocus) {
  if ($watch.ElapsedMilliseconds -gt 5000) {throw "Own focus did not settle: $Name"}
  [void][PraxisUpgradeInput]::SetForegroundWindow($qaProcess.MainWindowHandle)
  $element.SetFocus()
  Start-Sleep -Milliseconds 100
 }
 Start-Sleep -Milliseconds 100
}
function Own-Message([uint32]$Message,[long]$Value,[long]$Bits) {
 [uint32]$owner=0
 [void][PraxisUpgradeInput]::GetWindowThreadProcessId($qaProcess.MainWindowHandle,[ref]$owner)
 if ($owner -ne $qaProcess.Id -or $qaProcess.HasExited) {throw 'Owned input target changed'}
 if (-not [PraxisUpgradeInput]::PostMessage($qaProcess.MainWindowHandle,$Message,[IntPtr]::new($Value),[IntPtr]::new($Bits))) {throw 'Owned window message failed'}
}
function Own-Key([int]$Key) {
 [long]$bits=([long][PraxisUpgradeInput]::MapVirtualKey($Key,0) -shl 16) -bor 1
 Own-Message 0x100 $Key $bits
 Own-Message 0x101 $Key ($bits -bor 0xc0000000L)
 Start-Sleep -Milliseconds 300
}
function Scroll-Details {
 # Wheel coordinates come from this process's own visible details action.
 # PostMessage targets that same HWND and does not move the system pointer.
 $anchor=Control 'Focus'
 $bounds=$anchor.Current.BoundingRectangle
 [long]$x=[Math]::Round($bounds.X+$bounds.Width/2)
 [long]$y=[Math]::Round($bounds.Y+$bounds.Height/2)
 Own-Message 0x20a (-360L*65536L) (($y -shl 16) -bor ($x -band 65535L))
 Start-Sleep -Milliseconds 500
}
function Open-Library {
 Invoke-Control 'Saved views'
 # A full local enumeration asks the provider for the newly opened subtree.
 [void]$qaRoot.FindAll([Windows.Automation.TreeScope]::Subtree,[Windows.Automation.Condition]::TrueCondition)
 [void](Control 'Saved view name')
 [void](Control 'Find saved views')
}
function Save-Capture([object]$Case) {
 Open-Library
 Value-Control 'Saved view name' $Case.name
 Invoke-Control 'Save current view'
 Focus-Control 'Study notes'
 foreach ($character in $Case.note.ToCharArray()) {
  if ([int]$character -eq 10) {Own-Key 0x0d}
  elseif ([int]$character -eq 45) {
   # Pair OEM punctuation's key and character events for normal native input.
   [long]$bits=([long][PraxisUpgradeInput]::MapVirtualKey(0xbd,0) -shl 16) -bor 1
   Own-Message 0x100 0xbd $bits
   Own-Message 0x102 45 $bits
   Own-Message 0x101 0xbd ($bits -bor 0xc0000000L)
   Start-Sleep -Milliseconds 20
  }
  elseif ([int]$character -ne 13) {Own-Message 0x102 ([int]$character) 1;Start-Sleep -Milliseconds 10}
 }
 [void](Control 'Save notes')
 Invoke-Control 'Save notes'
 Invoke-Control 'Close'
}
function Record-Step([object]$Case) {
 $script:qaCompleted+=@{name=$Case.name;reference=$Case.id;restored=$Case.restore_name}
 [IO.File]::WriteAllText((Join-Path $runFolder 'progress.json'),(@{completed=$script:qaCompleted}|ConvertTo-Json -Depth 5 -Compress))
}
$qaProcess=[Diagnostics.Process]::new()
$executable=Join-Path $QaFolder ($job.version+'\PraxisCorporis\PraxisCorporis.exe')
$qaProcess.StartInfo.FileName=$executable
$qaProcess.StartInfo.WorkingDirectory=Split-Path $executable
$qaProcess.StartInfo.UseShellExecute=$false
$qaProcess.StartInfo.RedirectStandardOutput=$true
$qaProcess.StartInfo.RedirectStandardError=$true
$qaProcess.StartInfo.EnvironmentVariables['APPDATA']=Join-Path $QaFolder 'shared-data'
$qaProcess.StartInfo.EnvironmentVariables['LOCALAPPDATA']=Join-Path $QaFolder 'shared-cache'
$qaProcess.StartInfo.Arguments='--audio-driver Dummy --accessibility always --log-file "'+(Join-Path $runFolder 'engine.log')+'"'
$script:qaCompleted=@();$started=$false;$qaRoot=$null
try {
 $started=$qaProcess.Start()
 if (-not $started) {throw 'Owned app did not start'}
 $stdout=$qaProcess.StandardOutput.ReadToEndAsync();$stderr=$qaProcess.StandardError.ReadToEndAsync()
 [IO.File]::WriteAllText((Join-Path $runFolder 'launched.json'),(@{pid=$qaProcess.Id;executable=$executable}|ConvertTo-Json -Compress))
 $watch=[Diagnostics.Stopwatch]::StartNew()
 while ($true) {
  $qaProcess.Refresh()
  if ($qaProcess.HasExited) {throw 'Owned app exited before ready'}
  if ($qaProcess.MainWindowHandle -ne [IntPtr]::Zero -and $qaProcess.MainWindowTitle -eq $job.ready_title) {break}
  if ($watch.ElapsedMilliseconds -gt 60000) {throw 'Owned app did not load its remembered reference'}
  Start-Sleep -Milliseconds 100
 }
 $qaRoot=[Windows.Automation.AutomationElement]::FromHandle($qaProcess.MainWindowHandle)
 $rect=[PraxisUpgradeInput+Rect]::new()
 if (-not [PraxisUpgradeInput]::GetClientRect($qaProcess.MainWindowHandle,[ref]$rect)) {throw 'Own client size unavailable'}
 [IO.File]::WriteAllText((Join-Path $runFolder 'ready.json'),(@{title=$qaProcess.MainWindowTitle;client_size=@(($rect.Right-$rect.Left),($rect.Bottom-$rect.Top))}|ConvertTo-Json -Compress))
 foreach ($case in $job.cases) {
  if ($job.action -eq 'baseline') {
   if ($case.id -in @('female','male')) {Invoke-Control 'Show chest'}
   Value-Control 'Find anatomy' $case.leaf
   Focus-Control 'Find anatomy'
   Own-Key 0x0d
   # Native providers omit controls clipped by the scrollable details panel.
   Scroll-Details
   Invoke-Control 'Fade'
   Invoke-Control 'Inspect alone'
   [void](Control 'Return to context')
   $move=Control 'Move selected';$toggle=$null
   if ($move.TryGetCurrentPattern([Windows.Automation.TogglePattern]::Pattern,[ref]$toggle)) {$toggle.Toggle()} else {$move.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()}
   Focus-Control '3D anatomy view'
   Own-Key 0x4c
  } else {
   Open-Library
   Value-Control 'Find saved views' $case.restore_name
   Focus-Control 'Find saved views'
   Own-Key 0x0d
   Invoke-Control 'Restore'
   [void](Control ('Restored “'+$case.restore_name+'”') $false)
  }
  Save-Capture $case
  Record-Step $case
 }
 } finally {
 $shutdownError=$null;$forced=$false
 try {
  if ($started -and -not $qaProcess.HasExited) {
   if ($null -ne $qaRoot) {
    # Every note in this generated profile is fictional QA data.
    $save=Find-Optional 'Save all notes'
    if ($null -ne $save -and $save.Current.IsEnabled) {$save.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke();Start-Sleep -Milliseconds 250}
    $close=Find-Optional 'Close'
    if ($null -ne $close) {$close.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke();Start-Sleep -Milliseconds 250}
   }
   if (-not $qaProcess.CloseMainWindow()) {throw 'Own close request failed'}
   if (-not $qaProcess.WaitForExit(30000)) {throw 'Own app failed to close normally'}
  }
 } catch {$shutdownError=$_}
 finally {
  if ($started -and -not $qaProcess.HasExited) {$forced=$true;$qaProcess.Kill();[void]$qaProcess.WaitForExit(10000)}
  if ($started -and $qaProcess.HasExited) {
   $qaProcess.WaitForExit()
   [IO.File]::WriteAllText((Join-Path $runFolder 'stdout.log'),$stdout.Result)
   [IO.File]::WriteAllText((Join-Path $runFolder 'stderr.log'),$stderr.Result)
   [IO.File]::WriteAllText((Join-Path $runFolder 'exit.json'),(@{closed=$qaProcess.HasExited;exit_code=$qaProcess.ExitCode;forced=$forced;completed=$script:qaCompleted.Count}|ConvertTo-Json -Compress))
  }
  $qaProcess.Dispose()
 }
 if ($null -ne $shutdownError) {throw $shutdownError}
}
