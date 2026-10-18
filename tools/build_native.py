"""Build self-contained private desktop ZIPs; never publish or upload artifacts."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import shutil
import stat
import struct
import subprocess
import tempfile
import zipfile
import uuid

from native_sources import SNAPSHOT_VERSION, discover_sources, identity_record

ROOT = pathlib.Path(__file__).resolve().parents[1]


def sha256(path: pathlib.Path) -> str:
    checksum = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(1024 * 1024):
            checksum.update(block)
    return checksum.hexdigest()


def run(command: list[str], cwd: pathlib.Path = ROOT, env: dict | None = None,
        required_marker: str | None = None, timeout: int = 120,
        expected_identity: dict | None = None) -> None:
    try:
        result = subprocess.run(command, cwd=cwd, env=env, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=timeout)
    except subprocess.TimeoutExpired as error:
        output = error.stdout.decode(errors="replace") if isinstance(error.stdout, bytes) else (error.stdout or "")
        raise RuntimeError(f"Build step timed out: {command[0]}\n{output}") from error
    incomplete = required_marker is not None and (result.stdout.splitlines().count(required_marker) != 1
                  or re.search(r'ERROR:|ObjectDB instance.*leaked|^Leaked instance:', result.stdout, re.M))
    if expected_identity is not None:
        identities = re.findall(r'^PASS private build identity: (.+)$', result.stdout, re.M)
        incomplete = incomplete or len(identities) != 1 or json.loads(identities[0]) != expected_identity
    if result.returncode or "SCRIPT ERROR:" in result.stdout or incomplete:
        raise RuntimeError(f"Command failed ({result.returncode}): {command[0]}\n{result.stdout}")
    # Keep successful build output compact; retained reports describe verified results.
    for line in result.stdout.splitlines():
        if line.startswith(("PASS ", "Anatomy package complete:")):
            print(line, flush=True)


def check_loading_shutdown(prefix: list[str], cwd: pathlib.Path, env: dict) -> list[str]:
    cases = ['initial/anatomy', 'replacement/selection']
    for case in cases:
        arguments = ['--verify-loading-shutdown', '--shutdown-stage=' + case.split('/')[1]]
        if case.startswith('replacement/'):
            arguments.append('--shutdown-replacement')
        staged = 'true' if case.startswith('replacement/') else 'false'
        marker = f'PASS loading shutdown: {case} · resource true · worker false · staged {staged}'
        run(prefix + ['--'] + arguments, cwd=cwd, env=env, required_marker=marker)
    return cases


def unpack_zip(archive: pathlib.Path, destination: pathlib.Path) -> dict[str, int]:
    modes = {}
    with zipfile.ZipFile(archive) as package:
        for info in package.infolist():
            path = (destination / info.filename).resolve()
            if not path.is_relative_to(destination.resolve()):
                raise ValueError("Archive entry escapes its destination")
            mode = info.external_attr >> 16
            if stat.S_ISLNK(mode):
                raise ValueError("Unexpected symbolic link in native export")
            if info.is_dir():
                path.mkdir(parents=True, exist_ok=True)
                continue
            path.parent.mkdir(parents=True, exist_ok=True)
            with package.open(info) as source, path.open("wb") as target:
                shutil.copyfileobj(source, target)
            path.chmod((mode & 0o777) or 0o644)
            modes[info.filename] = (mode & 0o777) or 0o644
    return modes


def make_zip(folder: pathlib.Path, destination: pathlib.Path, modes: dict[str, int] | None = None) -> None:
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as package:
        for path in sorted(folder.rglob("*")):
            if path.is_file():
                relative = path.relative_to(folder).as_posix()
                info = zipfile.ZipInfo.from_file(path, arcname=f"{folder.name}/{relative}")
                info.create_system = 3
                mode = (modes or {}).get(relative, path.stat().st_mode & 0o777)
                info.external_attr = (stat.S_IFREG | mode) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                with path.open("rb") as source, package.open(info, "w") as target:
                    shutil.copyfileobj(source, target)


def binary_architectures(path: pathlib.Path) -> list[str]:
    with path.open("rb") as stream:
        header = stream.read(64)
        if header[:2] == b"MZ":
            offset = struct.unpack_from("<I", header, 60)[0]
            stream.seek(offset)
            signature, machine = struct.unpack("<4sH", stream.read(6))
            if signature != b"PE\0\0" or machine != 0x8664:
                raise ValueError("Expected a Windows x86_64 executable")
            return ["x86_64"]
        magic, count = struct.unpack_from(">II", header)
        if magic not in (0xCAFEBABE, 0xCAFEBABF) or count > 16:
            raise ValueError("Expected a Universal Mach-O executable")
        stream.seek(8)
        stride = 20 if magic == 0xCAFEBABE else 32
        names = {0x01000007: "x86_64", 0x0100000C: "arm64"}
        architectures = []
        for _ in range(count):
            cpu = struct.unpack_from(">I", stream.read(stride))[0]
            architectures.append(names.get(cpu, str(cpu)))
        if set(architectures) != {"x86_64", "arm64"}:
            raise ValueError("Mac export must contain Intel and Apple Silicon slices")
        return architectures


def add_notices(folder: pathlib.Path, platform: str, identity: dict) -> None:
    notices = folder / "NOTICES"
    notices.mkdir()
    for name in ["HRA-LICENSE.txt", "HRA-README.md", "Godot-LICENSE.txt", "Godot-COPYRIGHT.txt"]:
        shutil.copyfile(ROOT / "third_party" / name, notices / name)
    for name in ["BodyParts3D-README.html", "BodyParts3D-CURRENT-LICENSE.html", "BodyParts3D-LEGACY-OBJ-NOTICE.txt"]:
        if (ROOT / "third_party" / name).exists():
            shutil.copyfile(ROOT / "third_party" / name, notices / name)
    shutil.copyfile(ROOT / "ATTRIBUTIONS.md", notices / "ATTRIBUTIONS.md")
    (folder / "START_HERE.txt").write_text(
        "PRAXIS CORPORIS — PRIVATE ANATOMY PROTOTYPE\n\n"
        + f"Version: {identity['application_version']}\nBuild ID: {identity['build_id']}\n"
        + f"Source revision: {identity['source_revision']}\nSource inputs SHA-256: {identity['source_snapshot_sha256']}\n\n"
        + "Sources inside the app shows this identity. Include the build ID with trial observations.\n\n"
        + ("Open PraxisCorporis.exe.\n" if platform == "windows" else "Open PraxisCorporis.app.\n")
        + ("Extract this complete folder first. Keep anatomy.pck beside the executable.\n" if platform == "windows" else
           "Extract the ZIP first. Anatomy is included inside the application bundle.\n")
        + "Python and the Godot editor are not required; exploration works offline.\n\n"
        "Drag to orbit; Shift/right-drag to pan; scroll or pinch to zoom.\n"
        "Fine wheel amounts produce smaller zoom changes. Equal opposite wheel/key steps restore framing within the zoom limits.\n"
        "Leaving the app or 3D focus stops a drag. Existing edits remain available to Undo.\n"
        "Tab/click to focus the 3D view: arrows orbit, Shift-arrows pan, +/- zoom, F focuses, Home shows the body.\n"
        "M toggles Move; I/J/K/L move up/left/down/right, U/O toward/away. Press for 5 mm; Shift for 1 mm. Undo reverses a step.\n"
        "View toggles either side panel; Expand anatomy or F11 fills the window, and Escape returns.\n"
        "Expanded Explore keeps labels, inspection, Move/Undo/Redo, saved views and Screenshot available.\n"
        "Tab focuses View or Explore; Enter opens its menu and Escape closes it before returning.\n"
        "View selects Native, 75% or 50% 3D resolution; geometry and UI labels remain intact.\n"
        "Camera views rotates around the current focus; the direction cue uses the body's left/right sides.\n"
        "Screenshot saves a PNG of the workspace with source credits and prototype status inside the image.\n"
        "Enable Local part labels to identify exposed supplied parts; click a label to focus.\n"
        "Inspect alone temporarily reveals selected geometry; choose supplied parts in the panel.\n"
        "Return to context restores the prior body view and preserves inspection edits.\n"
        "Back/Forward (Alt + Left/Right) restore selections and camera views without resetting inspection.\n"
        "Peel away skin, choose Show chest, or select anatomy in the list.\n"
        "Heart <-> lungs follows a sourced conceptual route with either lung branch and explicit anatomy gaps. Finish restores your setup.\n"
        "Study Next/Previous retain keyboard focus. At a lung branch, Tab reaches the other choice; Enter follows the focused choice. Finish returns focus to 3D.\n"
        "Search names/source IDs; Enter selects the first ranked result. Copy source record retains the reference identity.\n"
        "Ctrl/Cmd+F opens anatomy search and reveals its panel. Escape clears the query; press again to return focus to 3D.\n"
        "List view browses every catalogue record. Previous/Next changes pages without selecting anatomy.\n"
        "Saved views searches names, notes, references and selected anatomy names/IDs. This reference narrows the library to the current reference.\n"
        "Coverage opens with its group list focused. Tab reaches selectable inventory text; Page Up/Down scroll and Escape closes it.\n"
        "Explore supplied group and successful saved/previous-quick-save restoration return keyboard focus to anatomy, so camera keys work immediately.\n"
        "If included, Male bones / BodyParts3D study is a separate source reference, unregistered to HRA.\n"
        "Move selected enables inspection displacement; blue overlays mark original positions.\n"
        "Undo/Redo reverses or reapplies inspection changes. Restore returns original anatomy.\n"
        "Repeating visibility/Restore or applying the same saved anatomy keeps Undo/Redo when the anatomy is already in that state.\n"
        "Movement that reaches no new position keeps Undo/Redo too. Undo/Redo ends an active pointer drag; start a fresh gesture to continue moving.\n"
        "Switching Move on or off ends the held gesture too. Press again to begin a deliberate move or camera drag.\n"
        "A keyboard move ends the pointer gesture first, keeping the drag and keyboard step independently undoable.\n"
        "Saved views keeps named local exploration setups and your study notes outside this folder.\n\n"
        "In Saved views, search names and notes with Ctrl+F; Enter selects a match. Escape clears a focused search.\n"
        "Saved views > Export all views backs up your views and notes to JSON; Import previews compatibility and keeps existing views.\n"
        "Export includes unfinished notes, including hidden drafts, without saving/discarding them. It can preserve this window's work when a newer library blocks Save.\n"
        "Damaged text encoding in libraries, imports and backups is rejected without replacing note characters; valid Unicode and UTF-8 BOM files remain supported.\n"
        "Import preview: Page Up/Down reads the list; Ctrl/Cmd+A selects it. Tab reaches Import/Cancel; Escape cancels without changing your library.\n"
        "Guided chest offers six reversible steps, including a separated chamber teaching view. Finish restores your starting setup.\n"
        "Heart/lung study cards include primary-source links and retain draft/review status. Source and mesh details expands technical identity.\n"
        "Study links are keyboard reachable. If the system cannot open a source in your browser, a selectable address stays available in the app.\n"
        "Read study card opens a larger selectable text/source reader. In expanded anatomy use Explore > Read study card; related anatomy links keep its reading action focused.\n"
        "Related conditions offers sourced aortic-stenosis and mitral-regurgitation summaries; Inspect reference anatomy reveals the supplied valve.\n"
        "Learning text remains draft; assistant cross-checks do not establish human source or medical review.\n"
        "View > Preferences adjusts text size. Panel layout, 3D resolution and label preferences are remembered on this computer.\n"
        "Teal outlines identify keyboard focus. Anatomy lists reveal their selected structure when focused; unavailable actions use muted labels.\n"
        "The desktop window size and maximized state are remembered after a normal close. Saved anatomy views remain independent.\n"
        "A normal close also remembers the last successfully loaded reference. Startup opens its default view; named saved views keep anatomy edits and notes.\n"
        "When replacing an open reference, Cancel opening keeps the current view and study step. The current reading step may finish before controls resume.\n"
        "Female/male spinal-cord and vertebra source studies use separate v1.2 files; they are not registered to United bodies.\n\n"
        "Both reference bodies are included. This is a partial, unreviewed atlas.\n"
        "Pathological geometry and physiological simulation are unavailable. Medical review and public release remain pending.\n"
        "Human input/performance acceptance and Mac hardware execution remain open.\n"
        + ("The Windows executable is unsigned.\n" if platform == "windows" else
           "The Mac app has an ad-hoc signature and is not notarized.\n")
        + "Credits, source licences and engine notices are in NOTICES/.\n",
        encoding="utf-8",
    )


def ensure_unchanged_sources(recorded: dict, root: pathlib.Path = ROOT) -> None:
    """Reject runtime files that no longer match the build's recorded inputs."""
    for relative, expected in recorded.items():
        path = root / relative
        if not path.is_file() or sha256(path) != expected:
            raise ValueError("Runtime source changed during build: " + relative
                             + ". Rebuild before using these archives.")
    actual = discover_sources(root)
    if actual != set(recorded):
        changed = sorted(actual ^ set(recorded))
        raise ValueError("Runtime source file set changed during build: " + ", ".join(changed[:5])
                         + ". Import the project, retain generated UIDs and rebuild before using these archives.")


def build(args: argparse.Namespace) -> dict:
    version = subprocess.check_output([args.godot, "--version"], text=True, timeout=10).strip()
    if not version.startswith("4.7.2."):
        raise ValueError("Use the pinned Godot 4.7.2 Standard build and matching export templates")
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"engine": version, "content_pack": "hra-united-v1-1-prototype-1", "artifacts": [],
              "target_device_testing": "pending", "publication": "local private artifacts only"}
    report["source_revision"] = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    report["source_snapshot_version"] = SNAPSHOT_VERSION
    report["source_hashes"] = {name: sha256(ROOT / name) for name in sorted(discover_sources(ROOT))}
    report['build_identity'] = identity_record(report, (ROOT / 'export_presets.cfg').read_text(), uuid.uuid4().hex)
    export_environment = os.environ.copy()
    export_environment['PRAXIS_PRIVATE_BUILD_IDENTITY'] = json.dumps(report['build_identity'], separators=(',', ':'))
    export_marker = 'PASS private build identity resource: ' + report['build_identity']['build_id']
    with tempfile.TemporaryDirectory(prefix="native-build-", dir=args.output) as workspace:
        temporary = pathlib.Path(workspace)
        data_pack = temporary / "anatomy.pck"
        print("Packing prepared anatomy…", flush=True)
        run([args.godot, "--headless", "--path", str(ROOT), "--script", "tools/pack_anatomy.gd", "--", f"--output={data_pack}"])
        report["anatomy_package"] = {"bytes": data_pack.stat().st_size, "sha256": sha256(data_pack)}
        qa_environment = os.environ.copy()
        qa_environment.update({
            "XDG_DATA_HOME": str(temporary / "qa-user-data"),
            "XDG_CONFIG_HOME": str(temporary / "qa-config"),
            "XDG_CACHE_HOME": str(temporary / "qa-cache"),
        })
        if args.qa_linux:
            qa = temporary / "qa"
            qa.mkdir()
            executable = qa / "PraxisCorporis.x86_64"
            print("Exporting and checking the Linux QA runtime…", flush=True)
            run([args.godot, "--headless", "--path", str(ROOT), "--export-release", "Linux Bundle QA", str(executable)],
                env=export_environment, required_marker=export_marker)
            shutil.copyfile(data_pack, qa / "anatomy.pck")
            executable.chmod(0o755)
            # Run outside the source project; every anatomy read must come from the bundle.
            run([str(executable), "--headless", "--audio-driver", "Dummy", "--", "--verify-bundle"], cwd=qa, env=qa_environment,
                required_marker="PASS offline native bundle", expected_identity=report['build_identity'])
            report['linux_loading_shutdown_qa'] = check_loading_shutdown(
                [str(executable), '--headless', '--audio-driver', 'Dummy'], qa, qa_environment)
            (qa / "anatomy.pck").rename(qa / "anatomy.unavailable")
            missing = subprocess.run([str(executable), "--headless", "--", "--verify-bundle"],
                                     cwd=qa, env=qa_environment, text=True, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT, timeout=30)
            if missing.returncode != 1 or "Anatomy is missing" not in missing.stdout:
                raise ValueError("Missing anatomy bundle must produce a clear failure")
            report["linux_qa"] = "passed exported-runtime checks for every bundled reference and missing-content handling"
        for platform in args.platform:
            modes = {}
            folder = temporary / "PraxisCorporis"
            folder.mkdir()
            print(f"Exporting {platform}…", flush=True)
            if platform == "windows":
                executable = folder / "PraxisCorporis.exe"
                run([args.godot, "--headless", "--path", str(ROOT), "--export-release", "Windows Private", str(executable)],
                    env=export_environment, required_marker=export_marker)
                architectures = binary_architectures(executable)
            else:
                app_archive = temporary / "macos-app.zip"
                run([args.godot, "--headless", "--path", str(ROOT), "--export-release", "macOS Private", str(app_archive)],
                    timeout=300, env=export_environment, required_marker=export_marker)
                modes = unpack_zip(app_archive, folder)
                applications = list(folder.glob("*.app"))
                if len(applications) != 1:
                    raise ValueError("Expected one Mac application bundle")
                previous_name = applications[0].name
                if previous_name != "PraxisCorporis.app":
                    applications[0].rename(folder / "PraxisCorporis.app")
                    modes = {("PraxisCorporis.app/" + name[len(previous_name) + 1:]
                              if name.startswith(previous_name + "/") else name): mode
                             for name, mode in modes.items()}
                executables = list(folder.glob("*.app/Contents/MacOS/*"))
                if len(executables) != 1 or not modes.get(executables[0].relative_to(folder).as_posix(), 0) & 0o111:
                    raise ValueError("Mac bundle must have one executable with execute permissions")
                architectures = binary_architectures(executables[0])
                core_packs = list(folder.glob("*.app/Contents/Resources/*.pck"))
                if len(core_packs) != 1 or core_packs[0].stat().st_size < data_pack.stat().st_size:
                    raise ValueError("Mac application must contain its anatomy inside the core resource pack")
                if not list(folder.glob("*.app/Contents/_CodeSignature/CodeResources")):
                    raise ValueError("Mac application must retain its ad-hoc resource seal")
                if args.qa_linux or args.qa_mac_content:
                    print("Checking the embedded Mac content using the development engine…", flush=True)
                    # Engine-consumed --main-pack is absent from OS.get_cmdline_args().
                    # An external script checks the actual virtual pack without relying on template features.
                    run([args.godot, "--headless", "--audio-driver", "Dummy", "--main-pack", str(core_packs[0]),
                         "--script", str(ROOT / "tests/packed_resource_boundary.gd")], cwd=folder, env=qa_environment,
                        required_marker="PASS standalone packed resource boundary")
                    run([args.godot, "--headless", "--audio-driver", "Dummy", "--main-pack", str(core_packs[0]),
                         "--", "--verify-bundle", "--verify-export-boundary"], cwd=folder, env=qa_environment,
                        required_marker="PASS offline native bundle", timeout=300, expected_identity=report['build_identity'])
                    report["mac_content_qa"] = "passed every bundled reference in embedded content on the development engine; Mac device testing pending"
                    report['mac_loading_shutdown_content_qa'] = check_loading_shutdown(
                        [args.godot, '--headless', '--audio-driver', 'Dummy', '--main-pack', str(core_packs[0])],
                        folder, qa_environment)
            if platform == "windows":
                shutil.copyfile(data_pack, folder / "anatomy.pck")
            add_notices(folder, platform, report['build_identity'])
            name = "PraxisCorporis-Windows-x64-private.zip" if platform == "windows" else "PraxisCorporis-macOS-universal-private.zip"
            archive = temporary / name
            make_zip(folder, archive, modes)
            shutil.rmtree(folder)
            destination = args.output / name
            os.replace(archive, destination)
            report["artifacts"].append({"file": name, "bytes": destination.stat().st_size,
                                        "sha256": sha256(destination), "architectures": architectures})
            print("Built", destination, flush=True)
        ensure_unchanged_sources(report["source_hashes"])
        report["runtime_sources_unchanged"] = True
        (args.output / "build-report.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True, help="Path to the Godot 4.7.2 Standard executable")
    parser.add_argument("--output", type=pathlib.Path, default=ROOT / "dist")
    parser.add_argument("--platform", nargs="+", choices=["windows", "macos"], default=["windows", "macos"])
    parser.add_argument("--qa-linux", action="store_true", help="Test an exported Linux runtime; Linux is not a release target")
    parser.add_argument("--qa-mac-content", action="store_true", help="Check embedded Mac content on the development engine, independently of Linux template QA; Mac hardware testing remains pending")
    options = parser.parse_args()
    options.godot = str(pathlib.Path(shutil.which(options.godot) or options.godot).resolve())
    options.output = options.output.resolve()
    build(options)
