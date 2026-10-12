# Private Windows and Mac builds

These local ZIPs include the Godot runtime, both pinned HRA reference samples and
prepared geometry. Users need no Python, Godot editor, login or network connection.
When prepared at build time, packages also include the separate BodyParts3D male
bone study and its current/legacy source notices. Its coordinate frame is not
registered to the HRA bodies; its availability is explicit in the reference selector.
The atlas is partial and unreviewed; disease content and guided routes are absent.

## Run a build

The generated archives are excluded from Git:

- Windows x64: dist/PraxisCorporis-Windows-x64-private.zip
- Mac Intel/Apple Silicon: dist/PraxisCorporis-macOS-universal-private.zip

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
[Mac path guidance](https://docs.godotengine.org/en/stable/tutorials/export/running_on_macos.html).
The archive builder retains Unix executable metadata even when the build host lacks those bits.
The Mac bundle identifier is a private placeholder, local.praxiscorporis.prototype;
choose an owned, appropriate identifier before public distribution.

The presets use all project resources with explicit exclusions for anatomy,
documentation and tools. This reliably includes GDScript preload dependencies;
the bundle check caught their omission during the first selected-scene export.
The project enables ETC2/ASTC import support required by the Universal Mac exporter.
[Godot export options](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html),
[Mac export requirements](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html).

## Verification and limits

On the Linux development host, add --qa-linux:

```sh
python3 tools/build_native.py --godot /path/to/godot --qa-linux
```

This exports a temporary Linux runtime solely for bundle verification. It runs
outside the source project with isolated user data, loads every bundled reference from the
packed anatomy, tests inspection restoration and selection/camera history, confirms
the supplied heart component catalogue, tests isolated-part inspection and return
without changing stored anatomy settings, verifies local saved-view write/reopen/restore
using temporary random filenames, and checks that removing anatomy.pck produces a
clear failure. It also loads every reference from the Mac core resource pack
using the development engine; this verifies embedded content, not Mac OS execution.
Linux is not a release target.

The build also inspects actual executable headers: Windows x86_64 and both Mac
x86_64/arm64 slices. build-report.json records artifact sizes/hashes, anatomy-pack
hash, source commit/file hashes, engine version and test status. Build success and
binary inspection do not establish Windows/Mac runtime usability or performance.
The first actual Windows headless run passed both-body offline and inspection checks;
[Windows evidence](audit/windows-native-qa.json) records that specific artifact/host.
The subsequent [Windows rendering check](audit/windows-rendered-qa.json) also passed
on AMD Radeon graphics, with both chest captures inspected. Human mouse/trackpad,
sustained performance and Mac device trials remain open.
The retained [build report](audit/native-build-report.json) includes a source-snapshot
revision verified against its recorded file hashes.

The first target-device trial should exercise both bodies, skin reveal, chest
selection, local labels and label clicks, Back/Forward, orbit/pan/zoom, movement,
supplied-part browsing, Inspect alone/Return to context, original-position display,
undo/redo, restoration, and save/reopen. Confirm that
navigation preserves moved/hidden parts and that covered components stay available
in the tree. Record OS, machine, graphics device, loading times and failures.
Save and reopen an isolated part and confirm that its Return to context action works.
Trackpad gestures, smaller displays, larger text and sustained frame rate remain
unverified on target hardware. No testers have been contacted and no archives have
been published.

[PRIVATE_TRIAL_GUIDE.md](PRIVATE_TRIAL_GUIDE.md) provides concrete tasks and a local
findings template for the user's first trial and a later invited private group.

## Developer rendering check

The private runtime accepts --verify-rendered-bundle after the engine's -- separator.
This automated developer check needs a desktop display, loads every reference,
exercises the same offline inspection/saved-view checks and saves native-chest-female.png,
native-chest-male.png and (when included) native-bones-bodyparts-male-bones-study.png
to user://. It then exits. Use a dedicated test user-data directory; it does not
read or overwrite the user's named library or older quick-save slot. The ordinary
--verify-bundle check remains headless and does not capture images.

These checks verify startup, rendering and scripted actions. They do not establish
native mouse/trackpad usability, accessibility acceptance or sustained laptop FPS.
