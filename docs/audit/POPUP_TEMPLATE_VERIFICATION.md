# Linux popup-template diagnostic

Checked on 2026-10-16 with Godot `4.7.2.stable.official.ed1daf0bf`.

The Find anatomy build exposed errors interleaved into progress lines in the
temporary Linux exported runtime. A raw rerun reports 334 errors while still
emitting its final success marker and exiting zero. The errors concern internal
root-window `focus_entered`/`tree_exited` connections during popup use.
[Raw diagnostic log](find-anatomy-linux-template-errors.log.txt).
This run is **failed evidence**, not a verified Linux result.

A separate app creates one MenuButton, adds one item, and opens/hides its popup
twelve times. It contains no anatomy-viewer code or data. The source project
passes without errors on the development engine. Its Linux release export reports
46 errors, both headless and on the software-rendered desktop. Waiting a frame
between actions does not remove them. These observations isolate the reproduction
from the viewer but do not identify the engine's underlying defect.

[Exact project inputs, logs and hashes](popup-template-repro/report.json).
The source files have `.txt` suffixes to keep them inert in this repository.
Copy them into a disposable directory with the suffixes removed, import with the
matching development engine, and export the `Linux Popup Probe` preset to a path
outside that directory. Run the exported executable with `--headless
--audio-driver Dummy`; add `-- --settle` to wait between actions. A displayed run
omits `--headless`.

The stricter build runner rejects a real run of this reproduction despite its
success marker and zero exit status. It now requires exact completion markers
for Linux bundle and Mac-content checks and rejects all `ERROR:` messages and
ObjectDB leaks. Native Windows parsing also rejects interleaved errors and
requires Find anatomy evidence for each reference when present in the recorded
source. Parser regressions are included in the 65 passing Python checks.
[Python log](find-anatomy-python.log.txt).

The temporary `dist/find-anatomy-improvements/` packages and their build report
are superseded: that runner accepted the Linux workflow markers without rejecting
every error. Earlier Linux pass labels have the same qualification; historical
reports remain unchanged. This does not change the identity of those artifacts
or redefine their separately retained Windows and shutdown evidence.

The current build uses `--qa-mac-content` to check Mac data independently, followed
by native Windows execution. Linux remains outside the release targets, and
`--qa-linux` remains strict rather than treating these errors as acceptable.
Actual Mac execution and human platform acceptance remain pending.
