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
import tempfile

from build_native import binary_architectures, sha256, unpack_zip
from audit_native import git_bytes, source_snapshot

ROOT = pathlib.Path(__file__).resolve().parents[1]
MARKERS = ["bundled local saved view and study notes", "failed replacement preserves exploration",
           "bundled keyboard workspace", "bundled source search", "bundled scene display", "bundled expanded controls", "bundled orientation", "bundled part actions"]
RENDERED_MARKERS = ["native rendered study notes", "native credited screenshot", "native rendered reference", "native expanded anatomy", "native expanded screenshot", "native orientation", "native part actions"]


def ps_literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def parse_result(log: str, rendered: bool, circulation: bool = False) -> dict:
    if "SCRIPT ERROR:" in log or re.search(r"^ERROR:", log, re.M):
        raise ValueError("The native runtime reported an error")
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
        for marker in MARKERS + (RENDERED_MARKERS if rendered else []):
            if not re.search(r"^PASS " + re.escape(marker) + ": " + re.escape(reference) + r"(?: · .*|)$", log, re.M):
                raise ValueError("Native check missing: " + marker + " / " + reference)
        if any(key.startswith('hra-v1-2-') for key in references) and not re.search(
                r'^PASS bundled study workspace: ' + re.escape(reference) + r'$', log, re.M):
            raise ValueError('Native study workspace check missing: ' + reference)
    result = process_observations(log, rendered)
    if circulation:
        for reference in references:
            if f'PASS bundled keyboard movement: {reference}' not in log.splitlines():
                raise ValueError('Native keyboard movement check missing: ' + reference)
        for reference in ['female', 'male']:
            if f'PASS bundled circulation route: {reference}' not in log.splitlines():
                raise ValueError('Native circulation route check missing: ' + reference)
    result.update(references=references, ui_process_frames_during_successful_load=frames)
    return result


def process_observations(log: str, rendered: bool = True) -> dict:
    if 'SCRIPT ERROR:' in log or re.search(r'^ERROR:', log, re.M) or 'Windows native exit code: 0' not in log:
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
    (local_path / ".praxis-qa-owned").write_text("Generated private verification session\n", encoding="utf-8")
    return local_path, windows_path


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


def captures(folder: pathlib.Path, output: pathlib.Path, references: dict, circulation: bool = False) -> dict:
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
    return images


def verify(args: argparse.Namespace) -> dict:
    build_report = json.loads(args.build_report.read_text(encoding="utf-8"))
    item = artifact_record(args.archive, build_report)
    source_snapshot(build_report)
    content_path = 'content/study_content.json'
    content = (json.loads(git_bytes(ROOT, build_report['source_revision'], content_path))
               if content_path in build_report['source_hashes'] else {})
    circulation = 'heart-lung' in content.get('routes', {})
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
        log = run_native(args, windows_session, windows_session + "\\" + executable_relative)
        result = parse_result(log, args.mode == "rendered", circulation)
        if result["engine_actual"] != build_report["engine"]:
            raise ValueError("The native runtime differs from the pinned build engine")
        result.update(schema_version=1, recorded_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      mode=args.mode, result="passed; native exit code 0", source_revision=build_report["source_revision"],
                      artifact=item, engine_expected=build_report["engine"], verifier_sha256=sha256(pathlib.Path(__file__)),
                      archive_crc="passed during extraction", user_data="APPDATA and LOCALAPPDATA isolated in a generated QA session; user libraries untouched.",
                      limits=["Scripted actions; human input, clipboard and native OS picker acceptance remain open.",
                              "No sustained-performance or maximum-loading-pause claim.", "This checks actual Windows execution; Mac device validation is separate."])
        if args.mode == "rendered":
            result["captures"] = captures(session, args.output, result["references"], circulation)
        if (session / "engine.log").exists():
            shutil.copyfile(session / "engine.log", args.output / "engine.log")
        (args.output / "report.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    except BaseException:
        print("Verification failed. Its isolated native session is retained:", windows_session)
        raise
    else:
        if (session / ".praxis-qa-owned").is_file():
            shutil.rmtree(session)
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=pathlib.Path, default=ROOT / "dist/PraxisCorporis-Windows-x64-private.zip")
    parser.add_argument("--build-report", type=pathlib.Path, default=ROOT / "dist/build-report.json")
    parser.add_argument("--output", type=pathlib.Path, help="New folder for retained logs, captures and report")
    parser.add_argument("--mode", choices=["rendered", "headless"], default="rendered")
    parser.add_argument("--powershell", help="Windows PowerShell executable; required on WSL")
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


if __name__ == "__main__":
    main()
