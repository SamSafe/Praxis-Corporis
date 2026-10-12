"""Profile an exact private Windows archive in an isolated native session."""
from __future__ import annotations

import argparse
import datetime
import json
import math
import os
import pathlib
import re
import shutil
import subprocess

from build_native import binary_architectures, sha256, unpack_zip
from summarize_profile import validate_configuration, validate_report
from verify_windows import ROOT, artifact_record, native_session, powershell, process_observations, run_native


def profile_options(args: argparse.Namespace) -> tuple[dict, list[str], int]:
    if not re.fullmatch(r'[0-9]+x[0-9]+', args.window):
        raise ValueError('Window must be WIDTHxHEIGHT in pixels')
    config = {'seconds': args.seconds, 'warmup_seconds': args.warmup,
              'repetitions': args.repetitions, 'window_pixels': [int(v) for v in args.window.split('x')]}
    validate_configuration(config)
    arguments = ['--profile-rendered-bundle', f'--profile-seconds={args.seconds}',
                 f'--profile-warmup={args.warmup}', f'--profile-repetitions={args.repetitions}',
                 f'--profile-window={args.window}']
    # Eight current scenes; allow loading/setup time for every repetition.
    timeout = math.ceil(8 * (args.seconds + args.warmup) * args.repetitions) + 180 * args.repetitions + 60
    return config, arguments, timeout


def validate_native_profile(report: dict, log: str, build: dict, config: dict) -> tuple[dict, list[dict]]:
    observations = process_observations(log)
    if 'PASS rendering profile recorded: user://render-profile.json' not in log:
        raise ValueError('The native process did not finish writing a profile')
    if observations['engine_actual'] != build['engine'] or report.get('platform') != 'Windows':
        raise ValueError('Profile platform/engine differs from the native artifact')
    if report.get('schema_version') != 2 or report.get('configuration') != config or report.get('pack_id') != build['content_pack']:
        raise ValueError('Profile did not use the requested measurement configuration/content pack')
    if not report.get('engine_commit') or report['engine_commit'][:9] not in build['engine']:
        raise ValueError('Profile engine commit differs from the native artifact')
    rows = validate_report(report)
    if {p['reference'] for p in report['measurement_plan']} != {'female', 'male', 'bodyparts-male-bones-study'}:
        raise ValueError('Profile omitted a current bundled reference')
    if len(rows) != 8 * config['repetitions']:
        raise ValueError('Profile omitted a current bundled workload')
    return observations, rows


def host_identity(args: argparse.Namespace) -> dict:
    result = powershell(args, """$ErrorActionPreference = 'Stop'
$system = Get-CimInstance Win32_ComputerSystem
$osInfo = Get-CimInstance Win32_OperatingSystem
$cpus = @(Get-CimInstance Win32_Processor | Select-Object Name, NumberOfLogicalProcessors)
$gpus = @(Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion)
$scheme = (& powercfg /getactivescheme | Out-String).Trim()
@{os_caption=$osInfo.Caption; os_version=$osInfo.Version; os_build=$osInfo.BuildNumber;
total_physical_ram_bytes=$system.TotalPhysicalMemory; cpus=$cpus; reported_graphics_adapters=$gpus;
active_power_scheme=$scheme} | ConvertTo-Json -Depth 5 -Compress""")
    if result.returncode:
        raise RuntimeError('Could not record native host identity: ' + result.stderr.strip())
    return json.loads(result.stdout)


def profile(args: argparse.Namespace) -> dict:
    config, arguments, timeout = profile_options(args)
    build = json.loads(args.build_report.read_text(encoding='utf-8'))
    item = artifact_record(args.archive, build)
    if args.output.exists():
        raise ValueError('Use a new output folder; prior reports are kept unchanged')
    args.output.mkdir(parents=True)
    host = host_identity(args)
    session, windows_session = native_session(args)
    print('Native staging:', windows_session, flush=True)
    try:
        unpack_zip(args.archive, session)
        executable = session / 'PraxisCorporis/PraxisCorporis.exe'
        if binary_architectures(executable) != ['x86_64'] or not (executable.parent / 'anatomy.pck').is_file():
            raise ValueError('Extracted native executable/anatomy is incomplete')
        relative = executable.relative_to(session).as_posix().replace('/', '\\')
        args.mode = 'rendered'
        print(f"Running {config['repetitions']} repetition(s), {config['seconds']:g}s per scene at {args.window}; isolated native data.", flush=True)
        log = run_native(args, windows_session, windows_session + '\\' + relative, arguments, timeout)
        raw_path = session / 'user-data/PraxisCorporisPrototype/render-profile.json'
        report = json.loads(raw_path.read_text(encoding='utf-8'))
        observations, rows = validate_native_profile(report, log, build, config)
        shutil.copyfile(raw_path, args.output / 'render-profile.json')
        if (session / 'engine.log').exists():
            shutil.copyfile(session / 'engine.log', args.output / 'engine.log')
        result = dict(observations, schema_version=1, result='passed raw measurement/complete workload validation; native exit code 0',
            recorded_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            source_revision=build['source_revision'], artifact=item, host=host, configuration=config,
            profiler_sha256=sha256(pathlib.Path(__file__)), verifier_sha256=sha256(ROOT / 'tools/verify_windows.py'),
            validator_sha256=sha256(ROOT / 'tools/summarize_profile.py'), raw_profile={'file': 'render-profile.json', 'sha256': sha256(raw_path)},
            scene_summary=rows, load_summary=[{k: load[k] for k in ['reference', 'repetition', 'wall_seconds', 'maximum_process_gap_ms', 'intervals_over_100_ms']} for load in report['loads']],
            context=args.context or 'No operator context supplied; background work, power source and thermal state uncontrolled.',
            limits=['Repeated runs in one process; later references/repetitions can reuse resources and OS file caches.',
                    'Process memory sampled every 500ms across the full run; not GPU or per-scene memory.',
                    '1080p window includes side panels; the actual 3D viewport is recorded separately.',
                    'Frame-callback cadence and load gaps are observations, not GPU timestamps or presentation latency.',
                    'One Windows host does not close Mac, representative-hardware, human-input or anatomy-review gates.'])
        (args.output / 'report.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    except BaseException:
        print('Native staging retained for diagnosis:', windows_session, flush=True)
        raise
    if (session / '.praxis-qa-owned').is_file():
        shutil.rmtree(session)
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=pathlib.Path, default=ROOT / 'dist/PraxisCorporis-Windows-x64-private.zip')
    parser.add_argument('--build-report', type=pathlib.Path, default=ROOT / 'dist/build-report.json')
    parser.add_argument('--output', type=pathlib.Path, help='New folder for retained logs and exact-artifact reports')
    parser.add_argument('--seconds', type=float, default=5)
    parser.add_argument('--warmup', type=float, default=1)
    parser.add_argument('--repetitions', type=int, default=1)
    parser.add_argument('--window', default='1440x900')
    parser.add_argument('--context', help='Operator observations about power source, foreground use and background work')
    parser.add_argument('--powershell', help='Native Windows PowerShell executable; required on WSL')
    args = parser.parse_args()
    if not args.powershell:
        if os.name != 'nt':
            parser.error('Run on Windows or provide --powershell pointing to native Windows PowerShell through WSL')
        args.powershell = str(pathlib.Path(os.environ.get('SystemRoot', r'C:\Windows')) / 'System32/WindowsPowerShell/v1.0/powershell.exe')
    if args.output is None:
        args.output = ROOT / 'dist' / ('windows-profile-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    try:
        result = profile(args)
    except (OSError, ValueError, KeyError, TypeError, RuntimeError, subprocess.SubprocessError) as error:
        parser.exit(1, str(error) + '\n')
    print('PASS native Windows rendering profile:', result['source_revision'])
    print('Retained report:', args.output / 'report.json')


if __name__ == '__main__':
    main()
