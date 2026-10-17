"""Verify a private Windows archive on Windows or through explicit WSL interop."""
from __future__ import annotations

import argparse
import datetime
import json
import os
import pathlib
import re
import shutil
import struct
import subprocess

from build_native import binary_architectures, sha256, unpack_zip
from audit_native import git_bytes, source_snapshot
from window_lifecycle_windows import reference_cases, verify_lifecycle

ROOT = pathlib.Path(__file__).resolve().parents[1]
OWNED_SESSION_MARKER = "Generated private verification session\n"
MARKERS = ["bundled local saved view and study notes", "failed replacement preserves exploration",
           "bundled keyboard workspace", "bundled source search", "bundled scene display", "bundled expanded controls", "bundled orientation", "bundled part actions"]
RENDERED_MARKERS = ["native rendered study notes", "native credited screenshot", "native rendered reference", "native expanded anatomy", "native expanded screenshot", "native orientation", "native part actions"]


def ps_literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def parse_result(log: str, rendered: bool, circulation: bool = False, information: bool = False,
                 conditions: bool = False, find_anatomy: bool = False,
                 pointer_interruption: bool = False, saved_view_context: bool = False,
                 camera_zoom: bool = False, coverage_keyboard: bool = False,
                 study_navigation: bool = False, import_preview: bool = False,
                 unchanged_edits: bool = False, movement_history: bool = False,
                 move_mode_boundary: bool = False, nudge_gesture: bool = False,
                 source_fallback: bool = False, study_reader: bool = False) -> dict:
    if "ERROR:" in log:
        raise ValueError("The native runtime reported an error")
    if re.search(r'ObjectDB instance.*leaked|^Leaked instance:', log, re.M):
        raise ValueError('The native runtime leaked an object at exit')
    if "PASS offline native bundle" not in log or "Windows native exit code: 0" not in log:
        raise ValueError("Native verification did not finish successfully")
    if 'PASS private export resource boundary' not in log:
        raise ValueError('Native verification did not check its exported resource boundary')
    references = {key: int(count) for key, count in re.findall(r"^PASS bundled reference: (\S+) · (\d+) meshes$", log, re.M)}
    if not {"female", "male"}.issubset(references):
        raise ValueError("Native verification omitted a required HRA reference")
    frames = {key: int(count) for key, count in re.findall(r"^PASS interface frames while loading: (\S+) · (\d+)$", log, re.M)}
    for reference, count in references.items():
        if count <= 0 or frames.get(reference, 0) < 2:
            raise ValueError("Reference geometry/loading evidence is incomplete: " + reference)
        for marker in MARKERS + (RENDERED_MARKERS if rendered else []) + (['native coverage reader'] if rendered and coverage_keyboard else []):
            if not re.search(r"^PASS " + re.escape(marker) + ": " + re.escape(reference) + r"(?: · .*|)$", log, re.M):
                raise ValueError("Native check missing: " + marker + " / " + reference)
        if any(key.startswith('hra-v1-2-') for key in references) and not re.search(
                r'^PASS bundled study workspace: ' + re.escape(reference) + r'$', log, re.M):
            raise ValueError('Native study workspace check missing: ' + reference)
        if find_anatomy and f'PASS bundled find anatomy: {reference}' not in log.splitlines():
            raise ValueError('Native Find anatomy check missing: ' + reference)
        if pointer_interruption and f'PASS bundled pointer interruption: {reference}' not in log.splitlines():
            raise ValueError('Native pointer interruption check missing: ' + reference)
        if saved_view_context and f'PASS bundled saved-view anatomy search: {reference}' not in log.splitlines():
            raise ValueError('Native saved-view anatomy search check missing: ' + reference)
        if camera_zoom and f'PASS bundled camera zoom: {reference}' not in log.splitlines():
            raise ValueError('Native camera zoom check missing: ' + reference)
        if coverage_keyboard and f'PASS bundled coverage keyboard: {reference}' not in log.splitlines():
            raise ValueError('Native coverage keyboard check missing: ' + reference)
        if study_navigation and reference in ['female', 'male'] and f'PASS bundled study navigation: {reference}' not in log.splitlines():
            raise ValueError('Native study navigation check missing: ' + reference)
        if import_preview and f'PASS bundled import preview: {reference}' not in log.splitlines():
            raise ValueError('Native import preview check missing: ' + reference)
        if unchanged_edits and f'PASS bundled unchanged edits: {reference}' not in log.splitlines():
            raise ValueError('Native unchanged-edit history check missing: ' + reference)
        if movement_history and f'PASS bundled movement history: {reference}' not in log.splitlines():
            raise ValueError('Native movement history check missing: ' + reference)
        if move_mode_boundary and f'PASS bundled move mode boundary: {reference}' not in log.splitlines():
            raise ValueError('Native Move mode gesture check missing: ' + reference)
        if nudge_gesture and f'PASS bundled nudge gesture: {reference}' not in log.splitlines():
            raise ValueError('Native keyboard/pointer gesture check missing: ' + reference)
        if source_fallback and reference in ['female', 'male'] and f'PASS bundled source fallback: {reference}' not in log.splitlines():
            raise ValueError('Native source launch fallback check missing: ' + reference)
        if study_reader and f'PASS bundled study reader: {reference}' not in log.splitlines():
            raise ValueError('Native study reader check missing: ' + reference)
    result = process_observations(log, rendered)
    if information and 'PASS bundled information dialogs: female' not in log.splitlines():
        raise ValueError('Native information dialog check missing')
    if import_preview and rendered and 'PASS native import preview: female' not in log.splitlines():
        raise ValueError('Native import preview capture check missing')
    if source_fallback and rendered and 'PASS native source fallback: female' not in log.splitlines():
        raise ValueError('Native source launch fallback capture check missing')
    if study_reader and rendered and 'PASS native study reader: female' not in log.splitlines():
        raise ValueError('Native study reader capture check missing')
    if conditions:
        for reference in ['female', 'male']:
            if f'PASS bundled condition study: {reference}' not in log.splitlines():
                raise ValueError('Native condition study check missing: ' + reference)
    if circulation:
        for reference in references:
            if f'PASS bundled keyboard movement: {reference}' not in log.splitlines():
                raise ValueError('Native keyboard movement check missing: ' + reference)
        for reference in ['female', 'male']:
            if f'PASS bundled circulation route: {reference}' not in log.splitlines():
                raise ValueError('Native circulation route check missing: ' + reference)
    result.update(references=references, ui_process_frames_during_successful_load=frames)
    if pointer_interruption:
        result['pointer_interruption_references'] = list(references)
    if saved_view_context:
        result['saved_view_anatomy_search_references'] = list(references)
    if camera_zoom:
        result['camera_zoom_references'] = list(references)
    if coverage_keyboard:
        result['coverage_keyboard_references'] = list(references)
    if study_navigation:
        result['study_navigation_references'] = [reference for reference in references if reference in ['female', 'male']]
    if import_preview:
        result['import_preview_references'] = list(references)
    if unchanged_edits:
        result['unchanged_edit_references'] = list(references)
    if movement_history:
        result['movement_history_references'] = list(references)
    if move_mode_boundary:
        result['move_mode_boundary_references'] = list(references)
    if nudge_gesture:
        result['nudge_gesture_references'] = list(references)
    if source_fallback:
        result['source_fallback_references'] = [reference for reference in references if reference in ['female', 'male']]
    if study_reader:
        result['study_reader_references'] = list(references)
    return result


def parse_loading_shutdown(log: str, case: str) -> dict:
    fields = case.split('/')
    expected = {'source': (False, True, False), 'anatomy': (True, False, False),
                'selection': (True, False, True), 'preparing': (False, False, True)}
    if len(fields) != 2 or fields[0] not in {'initial', 'replacement'} or fields[1] not in expected:
        raise ValueError('Unknown loading shutdown case')
    if 'ERROR:' in log:
        raise ValueError('Loading shutdown reported an error')
    if re.search(r'ObjectDB instance.*leaked|^Leaked instance:', log, re.M):
        raise ValueError('Loading shutdown leaked an object at exit')
    resource, worker, staged = expected[fields[1]]
    marker = (f'PASS loading shutdown: {case} · resource {str(resource).lower()} '
              f'· worker {str(worker).lower()} · staged {str(staged).lower()}')
    observed = re.findall(r'^PASS loading shutdown: .*$', log, re.M)
    if observed != [marker]:
        raise ValueError('Loading shutdown ownership/cleanup evidence is missing or mismatched')
    return {'case': case, 'owned_resource_at_close': resource, 'hash_worker_at_close': worker,
            'staged_scene_at_close': staged, 'ownership_cleanup_verified': True}


def process_observations(log: str, rendered: bool = True) -> dict:
    if 'ERROR:' in log or 'Windows native exit code: 0' not in log:
        raise ValueError('Native process did not finish without errors')
    memory = {}
    for field, label in [("peak_working_set_bytes_observed", "QA observed peak working set bytes"),
                         ("maximum_private_bytes_sampled", "QA sampled maximum private bytes")]:
        match = re.search(re.escape(label) + r": (\d+)", log)
        if not match:
            raise ValueError("Native process memory observations are missing")
        memory[field] = int(match[1])
    memory.update(sampling_interval_ms=500, scope="Entire native process; not per-scene or GPU memory.")
    renderer = next((line for line in log.splitlines() if line.startswith("OpenGL API ")), None)
    if rendered and not renderer:
        raise ValueError("Native rendering identity is missing")
    version = re.search(r"^Godot Engine v([^\s]+)", log, re.M)
    if not version:
        raise ValueError("The native engine version is missing")
    return {"engine_actual": version[1], "renderer": renderer, "process_memory_observations": memory}


def artifact_record(archive: pathlib.Path, build_report: dict) -> dict:
    item = next((a for a in build_report.get("artifacts", []) if a.get("file") == archive.name), None)
    if not item or item.get("architectures") != ["x86_64"] or "Windows" not in archive.name:
        raise ValueError("Choose the Windows archive recorded in the build report")
    if archive.stat().st_size != item["bytes"] or sha256(archive) != item["sha256"]:
        raise ValueError("The archive differs from its recorded build artifact")
    return item


def powershell(args: argparse.Namespace, command: str, timeout: int = 30) -> subprocess.CompletedProcess:
    command = "[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)\n" + command
    return subprocess.run([args.powershell, "-NoProfile", "-Command", command],
                          capture_output=True, encoding="utf-8", errors="replace", timeout=timeout)


def native_session(args: argparse.Namespace) -> tuple[pathlib.Path, str]:
    result = powershell(args, "$ErrorActionPreference = 'Stop'\n"
        "$folder = [IO.Path]::Combine([IO.Path]::GetTempPath(), 'PraxisCorporis-QA-' + [Guid]::NewGuid().ToString('N'))\n"
        "[void][IO.Directory]::CreateDirectory($folder)\nWrite-Output $folder")
    if result.returncode:
        raise RuntimeError("Could not create an isolated native session: " + result.stderr.strip())
    windows_path = result.stdout.strip()
    if not re.fullmatch(r"[A-Za-z]:\\[^\r\n]+\\PraxisCorporis-QA-[0-9a-f]{32}", windows_path):
        raise ValueError("Unexpected native session path")
    if os.name == "nt":
        local_path = pathlib.Path(windows_path)
    else:
        mapped = subprocess.check_output(["wslpath", "-u", windows_path], text=True, timeout=10).strip()
        local_path = pathlib.Path(mapped)
    (local_path / ".praxis-qa-owned").write_text(OWNED_SESSION_MARKER, encoding="utf-8")
    return local_path, windows_path


def write_report(path: pathlib.Path, report: dict) -> None:
    """Keep the last complete report if a later metadata update cannot finish."""
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    temporary.replace(path)


def cleanup_successful_session(session: pathlib.Path, keep: bool = False) -> dict:
    """Only remove this run's marked scratch folder after its evidence is retained."""
    outcome = {'status': 'retained', 'path': str(session)}
    if keep:
        return dict(outcome, reason='Requested with --keep-session')
    try:
        if not session.is_absolute() or not re.fullmatch(r'PraxisCorporis-QA-[0-9a-f]{32}', session.name):
            return dict(outcome, reason='Unexpected generated-session path; left unchanged')
        if session.is_symlink():
            return dict(outcome, reason='Generated-session path is a symlink; left unchanged')
        if not session.exists():
            return dict(outcome, status='already_missing')
        marker = session / '.praxis-qa-owned'
        if not session.is_dir() or marker.is_symlink() or not marker.is_file():
            return dict(outcome, reason='Generated-session ownership could not be verified')
        if marker.stat().st_size > 128 or marker.read_text(encoding='utf-8') != OWNED_SESSION_MARKER:
            return dict(outcome, reason='Generated-session marker differs; left unchanged')
        shutil.rmtree(session)
    except (OSError, UnicodeError) as error:
        return dict(outcome, reason='Temporary-file cleanup could not finish: ' + str(error))
    return dict(outcome, status='removed')


def run_native(args: argparse.Namespace, folder: str, executable: str,
               user_arguments: list[str] | None = None, process_timeout: int = 180) -> str:
    mode = "--verify-rendered-bundle" if args.mode == "rendered" else "--verify-bundle"
    engine_args = ("" if args.mode == "rendered" else "--headless ") + "--audio-driver Dummy --log-file "
    command = """$ErrorActionPreference = 'Stop'
$folder = FOLDER
$p = New-Object System.Diagnostics.Process
$p.StartInfo.FileName = EXECUTABLE
$p.StartInfo.WorkingDirectory = $folder
$p.StartInfo.UseShellExecute = $false
$p.StartInfo.RedirectStandardOutput = $true
$p.StartInfo.RedirectStandardError = $true
$p.StartInfo.EnvironmentVariables['APPDATA'] = Join-Path $folder 'user-data'
$p.StartInfo.EnvironmentVariables['LOCALAPPDATA'] = Join-Path $folder 'cache'
$p.StartInfo.Arguments = ENGINE_ARGS + '"' + (Join-Path $folder 'engine.log') + '" -- ' + USER_ARGS
$started = $false
try {
    $started = $p.Start()
    $stdout = $p.StandardOutput.ReadToEndAsync()
    $stderr = $p.StandardError.ReadToEndAsync()
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $peakWorking = 0L
    $peakPrivate = 0L
    while (-not $p.WaitForExit(500)) {
        if ($watch.ElapsedMilliseconds -gt TIMEOUT_MS) { throw 'Own Windows QA process timed out' }
        $p.Refresh()
        $peakWorking = [Math]::Max($peakWorking, $p.PeakWorkingSet64)
        $peakPrivate = [Math]::Max($peakPrivate, $p.PrivateMemorySize64)
    }
    Write-Output $stdout.Result
    Write-Output $stderr.Result
    Write-Output ('QA observed peak working set bytes: ' + $peakWorking)
    Write-Output ('QA sampled maximum private bytes: ' + $peakPrivate)
    Write-Output ('Windows native exit code: ' + $p.ExitCode)
    exit $p.ExitCode
} finally {
    if ($started -and -not $p.HasExited) { $p.Kill(); [void]$p.WaitForExit(10000) }
}
""".replace("FOLDER", ps_literal(folder)).replace("EXECUTABLE", ps_literal(executable)).replace("ENGINE_ARGS", ps_literal(engine_args)).replace("USER_ARGS", ps_literal(' '.join(user_arguments or [mode]))).replace("TIMEOUT_MS", str(process_timeout * 1000))
    result = powershell(args, command, timeout=process_timeout + 35)
    log = result.stdout + result.stderr
    (args.output / "native-runtime.log").write_text(log, encoding="utf-8")
    if result.returncode:
        raise RuntimeError("Native verification failed; see native-runtime.log")
    return log


def captures(folder: pathlib.Path, output: pathlib.Path, references: dict, circulation: bool = False,
             information: bool = False, conditions: bool = False, coverage_keyboard: bool = False,
             import_preview: bool = False, source_fallback: bool = False,
             study_reader: bool = False) -> dict:
    images = {}
    destination = output / "captures"
    destination.mkdir()
    source = folder / "user-data/PraxisCorporisPrototype"
    for reference in references:
        prefixes = ["native-search", "native-study-notes", "native-loading", "native-export", "native-expanded",
                       "native-expanded-export", "native-expanded-menu",
                       "native-orientation",
                       "native-part-actions-compact", "native-part-actions-expanded", "native-part-visibility",
                       "native-chest" if reference in ["female", "male"] else "native-bones"]
        if reference in ['female', 'male'] and any(key.startswith('hra-v1-2-') for key in references):
            prefixes.append('native-guided')
        if reference in ['female', 'male'] and circulation:
            prefixes.extend(['native-route', 'native-route-compact'])
        if reference in ['female', 'male'] and conditions:
            prefixes.append('native-condition')
        if coverage_keyboard:
            prefixes.append('native-coverage')
        for prefix in prefixes:
            name = f"{prefix}-{reference}.png"
            path = source / name
            with path.open("rb") as stream:
                header = stream.read(24)
            if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
                raise ValueError("Native capture is unavailable or invalid: " + name)
            pixels = list(struct.unpack(">II", header[16:24]))
            if not all(v > 0 for v in pixels):
                raise ValueError("Native capture has invalid dimensions: " + name)
            shutil.copyfile(path, destination / name)
            images[name] = {"file": "captures/" + name, "pixels": pixels, "sha256": sha256(path)}
    dialog_captures = ([f'native-information-{kind}.png' for kind in ['help', 'sources']] if information else [])
    if import_preview:
        dialog_captures.extend(f'native-import-preview-{kind}.png' for kind in ['long', 'duplicates'])
    if source_fallback:
        dialog_captures.append('native-source-fallback.png')
    if study_reader:
        dialog_captures.extend(f'native-study-reader-{kind}.png' for kind in ['workspace', 'expanded'])
    if dialog_captures:
        for name in dialog_captures:
            path = source / name
            with path.open('rb') as stream:
                header = stream.read(24)
            if len(header) != 24 or header[:8] != b'\x89PNG\r\n\x1a\n':
                raise ValueError('Native dialog capture is invalid: ' + name)
            pixels = list(struct.unpack('>II', header[16:24]))
            if not all(v > 0 for v in pixels):
                raise ValueError('Native dialog capture dimensions are invalid')
            shutil.copyfile(path, destination / name)
            images[name] = {'file': 'captures/' + name, 'pixels': pixels, 'sha256': sha256(path)}
    return images


def verify(args: argparse.Namespace) -> dict:
    build_report = json.loads(args.build_report.read_text(encoding="utf-8"))
    item = artifact_record(args.archive, build_report)
    source_snapshot(build_report)
    content_path = 'content/study_content.json'
    content = (json.loads(git_bytes(ROOT, build_report['source_revision'], content_path))
               if content_path in build_report['source_hashes'] else {})
    circulation = 'heart-lung' in content.get('routes', {})
    information = 'scripts/information_dialog.gd' in build_report['source_hashes']
    conditions = bool(content.get('conditions'))
    window_state = 'scripts/window_state.gd' in build_report['source_hashes']
    reference_state = 'scripts/reference_state.gd' in build_report['source_hashes']
    loading_shutdown = ('scripts/viewer.gd' in build_report['source_hashes']
                        and b'--verify-loading-shutdown' in git_bytes(ROOT, build_report['source_revision'], 'scripts/viewer.gd'))
    find_anatomy = ('scripts/viewer.gd' in build_report['source_hashes']
                    and b'PASS bundled find anatomy:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/viewer.gd'))
    pointer_interruption = ('scripts/study_verification.gd' in build_report['source_hashes']
                           and b'PASS bundled pointer interruption:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    saved_view_context = ('scripts/viewer.gd' in build_report['source_hashes']
                          and b'PASS bundled saved-view anatomy search:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/viewer.gd'))
    camera_zoom = ('scripts/study_verification.gd' in build_report['source_hashes']
                   and b'PASS bundled camera zoom:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    coverage_keyboard = ('scripts/study_verification.gd' in build_report['source_hashes']
                         and b'PASS bundled coverage keyboard:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    study_navigation = ('scripts/study_verification.gd' in build_report['source_hashes']
                        and b'PASS bundled study navigation:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    import_preview = ('scripts/study_verification.gd' in build_report['source_hashes']
                      and b'PASS bundled import preview:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    unchanged_edits = ('scripts/study_verification.gd' in build_report['source_hashes']
                       and b'PASS bundled unchanged edits:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    movement_history = ('scripts/study_verification.gd' in build_report['source_hashes']
                        and b'PASS bundled movement history:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    move_mode_boundary = ('scripts/study_verification.gd' in build_report['source_hashes']
                          and b'PASS bundled move mode boundary:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    nudge_gesture = ('scripts/study_verification.gd' in build_report['source_hashes']
                     and b'PASS bundled nudge gesture:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    source_fallback = ('scripts/study_verification.gd' in build_report['source_hashes']
                       and b'PASS bundled source fallback:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    study_reader = ('scripts/study_verification.gd' in build_report['source_hashes']
                    and b'PASS bundled study reader:' in git_bytes(ROOT, build_report['source_revision'], 'scripts/study_verification.gd'))
    startup_cases = None
    if reference_state:
        bodies = json.loads(git_bytes(ROOT, build_report['source_revision'], 'content/sample_pack.json'))['bodies']
        bodies += json.loads(git_bytes(ROOT, build_report['source_revision'], 'content/spinal_studies.json'))['bodies']
        startup_cases = reference_cases(bodies)
    if args.output.exists():
        raise ValueError("Use a new output folder; prior reports are kept unchanged")
    args.output.mkdir(parents=True)
    session, windows_session = native_session(args)
    try:
        unpack_zip(args.archive, session)
        executable = session / "PraxisCorporis/PraxisCorporis.exe"
        if binary_architectures(executable) != ["x86_64"] or not (executable.parent / "anatomy.pck").is_file():
            raise ValueError("Extracted Windows executable/anatomy is incomplete")
        executable_relative = executable.relative_to(session).as_posix().replace("/", "\\")
        window_fixture = session / 'user-data/PraxisCorporisPrototype/window-state.json'
        fixture_text = '{"schema_version":1,"size":[4320,2440],"maximized":true}'
        if window_state:
            window_fixture.parent.mkdir(parents=True, exist_ok=True)
            window_fixture.write_text(fixture_text, encoding='utf-8')
        reference_fixture = session / 'user-data/PraxisCorporisPrototype/reference-state.json'
        reference_fixture_text = json.dumps(startup_cases['male']['record']) if startup_cases else ''
        if reference_state:
            reference_fixture.parent.mkdir(parents=True, exist_ok=True)
            reference_fixture.write_text(reference_fixture_text, encoding='utf-8')
        log = run_native(args, windows_session, windows_session + "\\" + executable_relative)
        result = parse_result(log, args.mode == "rendered", circulation, information, conditions,
                              find_anatomy, pointer_interruption, saved_view_context, camera_zoom, coverage_keyboard, study_navigation, import_preview, unchanged_edits, movement_history, move_mode_boundary, nudge_gesture, source_fallback, study_reader)
        if result["engine_actual"] != build_report["engine"]:
            raise ValueError("The native runtime differs from the pinned build engine")
        result.update(schema_version=1, recorded_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      mode=args.mode, result="passed; native exit code 0", source_revision=build_report["source_revision"],
                      artifact=item, engine_expected=build_report["engine"], verifier_sha256=sha256(pathlib.Path(__file__)),
                      archive_crc="passed during extraction", user_data="APPDATA and LOCALAPPDATA isolated in a generated QA session; user libraries untouched.",
                      limits=["Scripted actions; human input, clipboard and native OS picker acceptance remain open.",
                              "No sustained-performance or maximum-loading-pause claim.", "This checks actual Windows execution; Mac device validation is separate."])
        if args.mode == "rendered":
            result["captures"] = captures(session, args.output, result["references"], circulation, information, conditions, coverage_keyboard, import_preview, source_fallback, study_reader)
        if (session / "engine.log").exists():
            shutil.copyfile(session / "engine.log", args.output / "engine.log")
        if reference_state:
            if reference_fixture.read_text(encoding='utf-8') != reference_fixture_text:
                raise ValueError('Scripted QA changed the isolated startup-reference fixture')
            reference_fixture.unlink()
            result['reference_settings_ignored_during_scripted_qa'] = True
        if window_state:
            if window_fixture.read_text(encoding='utf-8') != fixture_text:
                raise ValueError('Scripted QA changed the isolated window-settings fixture')
            window_fixture.unlink()
            result['window_settings_ignored_during_scripted_qa'] = True
            if args.mode == 'rendered':
                result['window_state_lifecycle'] = verify_lifecycle(args, session, windows_session, windows_session + '\\' + executable_relative, startup_cases)
        if loading_shutdown:
            result['loading_shutdown'] = verify_loading_shutdown(
                args, session, windows_session, str(pathlib.PureWindowsPath(windows_session) / executable_relative),
                build_report['engine'])
        result['session_cleanup'] = {'status': 'pending', 'path': str(session)}
        write_report(args.output / 'report.json', result)
    except BaseException:
        print("Verification failed. Its isolated native session is retained:", windows_session)
        raise
    else:
        result['session_cleanup'] = cleanup_successful_session(session, getattr(args, 'keep_session', False))
        write_report(args.output / 'report.json', result)
    return result


def verify_loading_shutdown(args: argparse.Namespace, session: pathlib.Path, windows_session: str,
                            executable: str, engine: str) -> list[dict]:
    data = session / 'user-data/PraxisCorporisPrototype'
    names = ['saved_views.json', 'preferences.json', 'reference-state.json', 'window-state.json']
    def settings_snapshot() -> dict:
        snapshot = {}
        for name in names:
            path = data / name
            if path.exists():
                metadata = path.stat()
                snapshot[name] = (path.read_bytes(), metadata.st_mtime_ns, metadata.st_ino)
            else:
                snapshot[name] = None
        return snapshot
    before = settings_snapshot()
    results = []
    for case in ['initial/anatomy', 'replacement/selection']:
        folder = args.output / 'loading-shutdown' / case.replace('/', '-')
        folder.mkdir(parents=True)
        child_args = argparse.Namespace(**vars(args))
        child_args.output = folder
        user_args = ['--verify-loading-shutdown', '--shutdown-stage=' + case.split('/')[1]]
        if case.startswith('replacement/'):
            user_args.append('--shutdown-replacement')
        log = run_native(child_args, windows_session, executable, user_args)
        record = parse_loading_shutdown(log, case)
        record.update(process_observations(log, args.mode == 'rendered'))
        if record['engine_actual'] != engine:
            raise ValueError('Loading shutdown used a different engine')
        after = settings_snapshot()
        if before != after:
            raise ValueError('Scripted loading shutdown changed persistent settings or saved views')
        record.update(log=(folder / 'native-runtime.log').relative_to(args.output).as_posix(),
                      log_sha256=sha256(folder / 'native-runtime.log'), settings_unchanged=True)
        results.append(record)
    return results


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=pathlib.Path, default=ROOT / "dist/PraxisCorporis-Windows-x64-private.zip")
    parser.add_argument("--build-report", type=pathlib.Path, default=ROOT / "dist/build-report.json")
    parser.add_argument("--output", type=pathlib.Path, help="New folder for retained logs, captures and report")
    parser.add_argument("--mode", choices=["rendered", "headless"], default="rendered")
    parser.add_argument("--powershell", help="Windows PowerShell executable; required on WSL")
    parser.add_argument('--keep-session', action='store_true', help='Keep the generated successful session for manual inspection')
    args = parser.parse_args()
    if not args.powershell:
        if os.name != "nt":
            parser.error("Run on Windows, or provide --powershell pointing to native Windows PowerShell through WSL")
        args.powershell = str(pathlib.Path(os.environ.get("SystemRoot", r"C:\Windows")) / "System32/WindowsPowerShell/v1.0/powershell.exe")
    if args.output is None:
        args.output = ROOT / "dist" / ("windows-qa-" + datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f"))
    try:
        result = verify(args)
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        parser.exit(1, str(error) + "\n")
    print("PASS native Windows archive:", result["source_revision"])
    print("Retained report:", args.output / "report.json")
    if result['session_cleanup']['status'] == 'retained':
        print('Generated QA session retained:', result['session_cleanup']['path'])
        print(result['session_cleanup']['reason'])


if __name__ == "__main__":
    main()
