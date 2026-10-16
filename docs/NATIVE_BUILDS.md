# Private Windows and Mac builds

These local ZIPs include the Godot runtime, both pinned HRA reference samples and
prepared geometry. Users need no Python, Godot editor, login or network connection.
When prepared at build time, packages also include the separate BodyParts3D male
bone study and its current/legacy source notices. Its coordinate frame is not
registered to the HRA bodies; its availability is explicit in the reference selector.
The atlas is partial and unreviewed; pathological geometry and physiological simulation are absent.
The latest [study workspace](STUDY_WORKSPACE.md) adds a reversible chest teaching guide,
draft learning cards, a sourced heart/lung route, precise keyboard movement,
portable views and four independent spinal source studies.

## Run a build

The generated archives are excluded from Git:

- Windows x64: dist/draft-study-improvements/PraxisCorporis-Windows-x64-private.zip
- Mac Intel/Apple Silicon: dist/draft-study-improvements/PraxisCorporis-macOS-universal-private.zip

Earlier archives retain their previous source identities and their review-label
corrections. Use the draft-study-improvements build report when verifying the new archives.
[Fixed package and native verification](audit/DRAFT_CONTENT_VERIFICATION.md) records
their exact hashes, seven-reference Windows checks and remaining Mac/human limits.

Extract the complete ZIP. In its PraxisCorporis folder, open PraxisCorporis.exe
on Windows or PraxisCorporis.app on Mac. On Windows, keep anatomy.pck beside the
executable; it contains both reference bodies and the compiled scenes. The Mac app
contains anatomy inside its signed bundle, so moving the .app preserves its data.

START_HERE.txt describes controls. NOTICES/ retains atlas credits, CC BY 4.0 terms,
and the engine's licence/third-party notices. Saved views go to the app's local
user-data directory, outside this folder.

The Windows executable is unsigned. The Mac app uses Godot's built-in ad-hoc
signature and is not notarized. macOS may require explicit approval for a private
download; follow [Godot's Mac app guidance](https://docs.godotengine.org/en/stable/tutorials/export/running_on_macos.html).
Public signing/notarization and release eligibility remain separate work. Do not
describe these packages as public-ready installers.

## Build from source

Use Godot 4.7.2 Standard with the matching official export templates installed
through Editor > Manage Export Templates. The pinned archive and notice hashes are
in [toolchain_manifest.json](../content/toolchain_manifest.json).
First fetch and prepare anatomy using [PROTOTYPE.md](PROTOTYPE.md), then:

```sh
python3 tools/build_native.py --godot /path/to/godot
```

On Windows, use the Python executable and full Godot executable path available on
that machine. --platform windows or --platform macos builds a single target.
--output sets the artifact folder, defaulting to dist/. The build script performs
no publishing or uploads.

The builder packages pinned original GLBs, prepared scenes and retained atlas
notices into anatomy.pck for Windows. A local editor export plugin inserts these
files into the Mac core resource pack before Godot signs the app. This avoids
dependence on neighbouring files when Gatekeeper relocates a downloaded app.
Prepared geometry and small groups of exact picking shapes are separate resources;
their manifest, source hash, engine version and complete mesh mapping must agree.
The preparation tool builds these groups offline, and both exporters require the
complete set. [Loading comparison](audit/LOADING_OPTIMIZATION.md).
[Mac path guidance](https://docs.godotengine.org/en/stable/tutorials/export/running_on_macos.html).
The archive builder retains Unix executable metadata even when the build host lacks those bits.
The Mac bundle identifier is a private placeholder, local.praxiscorporis.prototype;
choose an owned, appropriate identifier before public distribution.

The presets use all project resources with explicit exclusions for anatomy,
documentation, tools and generated `dist`/`build` output. This reliably includes GDScript preload dependencies;
the bundle check caught their omission during the first selected-scene export.
The project enables ETC2/ASTC import support required by the Universal Mac exporter.
[Godot export options](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html),
[Mac export requirements](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html).

## Verification and limits

Audit the recorded archives against their sizes/hashes, all ZIP-entry CRCs,
executable architectures and source commit. The audit compares each retained notice
with that commit, requires the complete recorded runtime source set, checks the Windows
companion anatomy fingerprint, and checks Mac execute modes, embedded-pack size and
resource-seal presence. It reads committed Git objects, so later working-copy changes
do not silently redefine an earlier package:

```sh
python3 tools/audit_native.py --output dist/native-artifact-audit.json
```

Use a new evidence path. `--build-report` and `--artifact-dir` can select another
recorded build. This command does not run the app, verify a public signature or prove
the contents of the Mac resource pack; runtime/content checks remain separate.

On the Linux development host, add --qa-linux:

```sh
python3 tools/build_native.py --godot /path/to/godot --qa-linux
```

This exports a temporary Linux runtime solely for bundle verification. It runs
outside the source project with isolated user data, loads every bundled reference from the
packed anatomy, tests inspection restoration and selection/camera history, confirms
the supplied heart component catalogue, tests isolated-part inspection and return
without changing stored anatomy settings, verifies local saved-view and multiline-note write/reopen/restore
using temporary random filenames, and checks that removing anatomy.pck produces a
clear failure. Source-search checks resolve actual ontology IDs, select the matching geometry and
preserve inspection state; rendered verification also saves native-search-<reference>.png.
Developer checks do not read or change the system clipboard. Loading checks observe interface frames and deliberately reject a bad cached mesh
mapping while preserving the prior exploration. Focused keyboard navigation and panel collapse are checked without
changing anatomy state. It also loads every reference from the Mac core resource pack
using the development engine; this verifies embedded content, not Mac OS execution.
Linux is not a release target.

The build also inspects actual executable headers: Windows x86_64 and both Mac
x86_64/arm64 slices. build-report.json records artifact sizes/hashes, anatomy-pack
hash, source commit/file hashes, engine version and test status. Build success and
binary inspection do not establish Windows/Mac runtime usability or performance.
The first actual Windows headless run passed both-body offline and inspection checks;
[Windows evidence](audit/windows-native-qa.json) records that specific artifact/host.
The subsequent [Windows rendering check](audit/windows-rendered-qa.json) also passed
on AMD Radeon graphics, with both chest captures inspected. The later [loading check](audit/windows-loading-qa.json) verifies actual UI process
frames and failed-replacement preservation in the rebuilt Windows package. The latest [study-note check](audit/windows-study-notes-qa.json) also verifies the
rendered note editor and reopened text for every reference. The subsequent
[source-search check](audit/windows-source-search-qa.json) passed on the native AMD
host through the repository verifier, including both HRA valves and the source femur.
Human mouse/trackpad and Mac device trials remain open. Subsequent display-pixel
checks and the [focused full-HD trial](audit/WINDOWS_FULLHD_PROFILE.md) establish
full-resolution rendering for the measured eight scenes on this Windows host only.
The retained [build report](audit/native-build-report.json) includes a source-snapshot
revision verified against its recorded file hashes.
The `33071c1` packages retain expanded Explore actions, including labels,
inspection, saved views, credited export and rendering quality. Their actual Windows
workflows pass with all 24 captures inspected; see the
[expanded-controls evidence](audit/EXPANDED_CONTROLS_VERIFICATION.md). Actual Mac
execution and human picker/input acceptance remain open.
The `cc705b8` packages also offer six camera presets and source direction cues.
Every reference passes the presets on native Windows; all 27 captures were inspected.
[Orientation verification](audit/ORIENTATION_VERIFICATION.md) binds the result to the
new ZIPs and source metadata. Actual Mac and human acceptance remain open.
The `b9c23b4` packages add selection-bound Actions beside anatomy in both
workspace modes, including corner access for hidden/off-screen parts. All native
Windows workflows pass for every reference; 36 captures were inspected (the nine
new menu captures also individually at full size). [Part-action evidence](audit/PART_ACTIONS_VERIFICATION.md)
records the final artifacts and retained initial failed QA attempt. Actual Mac and
human usability/input acceptance remain open.
The earlier grouped-picking packages passed the same actual Windows rendered
workflows with [retained captures](audit/windows-grouped-selection-viewer-qa.json).
Their matched loading diagnostic is documented in the
[loading comparison](audit/LOADING_OPTIMIZATION.md). Representative Windows/Mac
hardware and additional workload acceptance remain open.

The first target-device trial should exercise both bodies, skin reveal, chest
selection, local labels and label clicks, Back/Forward, orbit/pan/zoom, movement,
supplied-part browsing, Inspect alone/Return to context, original-position display,
undo/redo, restoration, and save/reopen. Confirm that
navigation preserves moved/hidden parts and that covered components stay available
in the tree. Record OS, machine, graphics device, loading times and failures.
Save and reopen an isolated part and confirm that its Return to context action works.
Trackpad gestures, larger text and human usability remain unverified on target
hardware. Scripted checks include compact layouts and repeated full-resolution
Windows frame cadence; they do not supply that human evidence. No testers have been contacted and no archives have
been published.

[PRIVATE_TRIAL_GUIDE.md](PRIVATE_TRIAL_GUIDE.md) provides concrete tasks and a local
findings template for the user's first trial and a later invited private group.

## Reproduce Windows verification

Use Python 3.10+ on Windows from the repository folder after a private build:

```powershell
python tools/verify_windows.py
```

The verifier matches the Windows ZIP to `dist/build-report.json`, checks extracted
architecture/content, and runs the actual release executable in a generated Windows
temporary session. Only the child process receives isolated APPDATA/LOCALAPPDATA;
the user's saved views/notes remain untouched. It retains logs, capture hashes/images,
actual engine/renderer, source revision, reference counts and whole-process memory
observations under a new `dist/windows-qa-.../` folder. Successful native staging is
removed after those artifacts are copied. Failed sessions are kept for inspection;
the error prints their location. The process timeout applies only to its own child.
No execution-policy or system-setting change is performed.

Use `--mode headless` for the offline checks without rendering. Rendered mode requires
a desktop display. `--output` must name a new folder; existing reports are never
replaced. `--archive` and `--build-report` select another matching private artifact.
The verifier rejects missing workflow markers, runtime errors, wrong engine versions,
missing captures and archive/hash mismatches rather than treating an exit alone as
complete evidence.

The WSL bridge was exercised on the development host with native Windows PowerShell:

```sh
python3 tools/verify_windows.py \
  --powershell /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe \
  --output dist/windows-qa-my-trial
```

The bridge starts the Windows release executable and verifies actual Windows rendering;
it does not substitute the Linux editor for target execution. Direct Windows Python
caller setup remains to be exercised on another machine. These are scripted checks,
with human input, clipboard, native OS picker and sustained-performance acceptance
still covered by [PRIVATE_TRIAL_GUIDE.md](PRIVATE_TRIAL_GUIDE.md).

## Developer rendering check

The private runtime accepts --verify-rendered-bundle after the engine's -- separator.
This automated developer check needs a desktop display, loads every reference,
exercises the same offline inspection/saved-view checks and saves native-chest-female.png,
native-chest-male.png and (when included) native-bones-bodyparts-male-bones-study.png
to user://, then exits. It also writes native-export-<reference>.png,
exercising the screenshot composer/writer with embedded source/status credits. These
scripted checks also save native-expanded-<reference>.png, native-expanded-menu-<reference>.png
and native-expanded-export-<reference>.png. Expanded controls toggle labels/quality
and save/reopen/restore through the local browser with fresh temporary filenames;
the credited expanded export uses the same screenshot composer/writer.
The checks save native-study-notes-<reference>.png after editing, saving
and reopening notes through the local editor, alongside native-loading-<reference>.png while retaining the prior
scene during a deliberately rejected replacement. They do not operate the native OS file picker; that remains a human trial.
Use a dedicated test user-data directory: repeated runs replace these developer
capture filenames. The verifier does not
read or overwrite the user's named library or older quick-save slot. The ordinary
--verify-bundle check remains headless and does not capture images.

These checks verify startup, rendering and scripted actions. They do not establish
native mouse/trackpad usability, accessibility acceptance or sustained laptop FPS.

## Developer rendering profile

Private exports exclude generated `dist`/`build` output alongside tests, tools, docs
and editor addons. Both runtime verification and profiling reject exported developer
resources and print `PASS private export resource boundary` for a clean native pack.

Use the explicit `--profile-rendered-bundle` user argument to sample every bundled
reference. Defaults are a 1440 × 900 window, one-second warmup, five-second sample and
one repetition. For example, from the extracted Windows
folder:

```powershell
.\PraxisCorporis.exe --audio-driver Dummy -- --profile-rendered-bundle
```

Use a dedicated test user-data directory. Profiling writes `user://render-profile.json`,
then exits; it never accesses the named-view library or quick-save slot. Ordinary
launches do not profile or collect telemetry. Headless mode is rejected.

Each scene has a stationary warmup and scripted orbit at 0.5 rad/s.
HRA scenes are whole body, chest with faded lungs/local labels, and an isolated supplied
valve. The separate study measures whole bones and an isolated source femur. The report
retains raw frame intervals, counts/duration, average cadence, nearest-rank interval
percentiles, counts above 33.33/100 ms, viewport size, source hashes and graphics/CPU identity.
Load observations include source verification in both the outer wall-time figure and
`verified_prepared_scene_seconds`; UI process frames and loader yields are recorded.
Raw load process intervals include partial start/end boundaries and sum to the outer
wall time. Stage events and the next post-draw delay make loading stalls inspectable.
Earlier profile artifacts used `prepared_scene_seconds` for the post-verification
preparation interval. Compare measurements with their recorded source revision.

Validate the raw measurements and print their summary with:

```sh
python3 tools/summarize_profile.py /path/to/render-profile.json
```

Request longer repeated measurements directly with:

```powershell
.\PraxisCorporis.exe --audio-driver Dummy -- --profile-rendered-bundle --profile-seconds=60 --profile-warmup=2 --profile-repetitions=3 --profile-window=1920x1080
```

Options accept 1–120 sample seconds, 0.25–10 warmup seconds, 1–3 repetitions and
1100 × 720 through 3840 × 2160 windows. Unknown, duplicate or invalid profile options
fail before loading anatomy. Actual window dimensions must match the request.

`--profile-view=expanded` measures the full client-window anatomy view;
`--profile-view=workspace` retains panels. `--profile-resolution=native`, `75` or `50`
selects the rendered pixel fraction. Defaults are workspace/native. Schema-3 evidence
requires actual display and buffer dimensions to match those choices; expanded/native
at a 1920 × 1080 window must render exactly 1920 × 1080 pixels. Historical schema-1/2
profiles remain independently readable. A small developer progress file records the
last completed sample; full raw evidence is written at completion or interruption.

```sh
python3 tools/profile_windows.py \
  --powershell /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe \
  --seconds 60 --warmup 2 --repetitions 3 --window 1920x1080 \
  --view expanded --resolution native --output dist/windows-full-resolution-trial
```

The normal native verifier now checks Native/75%/50% display mapping and expanded-view
restoration for every reference. Rendered verification additionally reads the actual
3D texture dimensions and retains `native-expanded-<reference>.png` alongside the
existing workflow captures. Human input and Mac hardware checks remain separate.

The retained [first full-HD sustained trial](audit/WINDOWS_FULLHD_PROFILE.md) completed
all 24 one-minute samples at actual 1920 × 1080 3D resolution with focus held throughout.
Average frame cadence ranged from 59.5 to 59.9 FPS on the native Ryzen/Radeon host.
This meets the proposed 30-FPS baseline for the eight measured scenes on that machine;
representative devices, additional workloads and Mac execution remain open.
Every repetition reloads each reference and reconstructs the ordinary scene before
profiling. The 3D viewport dimensions are recorded separately from the entire window.
Developer profiling fixes its own window's bounds and disables its resize controls.
Window and 3D viewport sizes are checked before and throughout each sample; a change
stops the run and writes `render-profile-rejected.json` with available partial evidence.
Ordinary launches retain their resize controls. The profiler does not change host
power settings or force a window to remain foreground.

The repository runner extracts an exact matching archive into generated native staging,
isolates user data, records host/driver/power identity, observes its own process memory,
validates all raw measurements and retains logs/reports before removing successful
staging. It requires Python 3.10+ for QA; the application itself does not require Python.
Run on Windows with native Python:

```powershell
python tools/profile_windows.py --seconds 60 --warmup 2 --repetitions 3 --window 1920x1080
```

From this WSL development environment, supply the native PowerShell path:

```sh
python3 tools/profile_windows.py --seconds 60 --warmup 2 --repetitions 3 --window 1920x1080 \
  --powershell /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe \
  --output dist/windows-profile-sustained
```

Use a new output folder; existing evidence is never replaced. `--context` can record
operator observations about power source, foreground use and background work. The
runner changes no execution policy, power settings or unrelated processes. Long runs
allow time for the requested samples and loading, with an own-process timeout.
Raw schema 2 profiles require every declared scene/repetition and load; the independent
summary tool also accepts the earlier schema 1 diagnostic evidence.
`attempt.json` records archive/source/tool/host identity before launch. Failed runs keep
raw or partial profiles and native staging for diagnosis. The summary's explicit
`--allow-window-variation` option checks diagnostic arithmetic without passing a
fixed-window trial; native profile verification always requires exact dimensions.

Create a reviewable Markdown baseline from the raw profile and its matching native
evidence. This checks the raw-file fingerprint and independently recomputed scene
summary, retains outliers, and reports ranges across repetitions without pooling
percentiles. Choose a new destination:

```sh
python3 tools/report_profile.py dist/windows-profile-sustained/render-profile.json \
  --evidence dist/windows-profile-sustained/report.json \
  --output dist/windows-profile-sustained/observations.md
```

These frame-callback observations include scheduling/VSync and do not measure
GPU timestamps or presentation latency. Cache, power state and background load are
uncontrolled. Even a longer run on one host leaves the representative laptop and Mac
acceptance gates open. The original eight-scene and expanded sixteen-scene suites omit the additional label-density,
moved-organ and saved-view workloads in [the protocol](PERFORMANCE_PROTOCOL.md).
Process working-set/private-memory observations must be recorded by the host separately;
they are neither GPU memory nor Godot's optional debug memory counters.
