"""Check eight real shutdown boundaries in isolated source-runtime processes."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import time

from audit_native import git_bytes
from build_native import ensure_unchanged_sources, sha256
from verify_windows import parse_loading_shutdown

ROOT = pathlib.Path(__file__).resolve().parents[1]


def check(godot: str, output: pathlib.Path) -> dict:
    if output.exists():
        raise ValueError('Use a new output directory; existing evidence is retained')
    version = subprocess.check_output([godot, '--version'], text=True, timeout=10).strip()
    if not version.startswith('4.7.2.'):
        raise ValueError('Use the pinned Godot 4.7.2 engine')
    output.mkdir(parents=True)
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    paths = [ROOT / 'project.godot', ROOT / 'scenes/main.tscn', pathlib.Path(__file__),
             ROOT / 'tools/verify_windows.py', *sorted((ROOT / 'scripts').glob('*.gd')),
             *sorted((ROOT / 'content').glob('*.json'))]
    hashes = {p.relative_to(ROOT).as_posix(): sha256(p) for p in paths}
    try:
        matches_revision = all(hashlib.sha256(git_bytes(ROOT, revision, p)).hexdigest() == digest
                               for p, digest in hashes.items())
    except subprocess.CalledProcessError:
        matches_revision = False # Untracked development files still have recorded byte hashes.
    report = {'schema_version': 1, 'engine': version, 'source_revision': revision, 'source_hashes': hashes,
              'recorded_sources_match_revision': matches_revision, 'checks': []}
    with tempfile.TemporaryDirectory(prefix='shutdown-user-data-', dir=output) as session:
        for phase in ['initial', 'replacement']:
            for boundary in ['source', 'anatomy', 'selection', 'preparing']:
                case = phase + '/' + boundary
                env = os.environ.copy()
                private = pathlib.Path(session) / case.replace('/', '-')
                env.update(XDG_DATA_HOME=str(private / 'data'), XDG_CONFIG_HOME=str(private / 'config'),
                           XDG_CACHE_HOME=str(private / 'cache'))
                command = [godot, '--headless', '--audio-driver', 'Dummy', '--path', str(ROOT), '--',
                           '--verify-loading-shutdown', '--shutdown-stage=' + boundary]
                if phase == 'replacement':
                    command.append('--shutdown-replacement')
                started = time.monotonic()
                log = output / (case.replace('/', '-') + '.log.txt')
                try:
                    result = subprocess.run(command, cwd=ROOT, env=env, text=True,
                                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=40)
                except subprocess.TimeoutExpired as error:
                    partial = error.stdout.decode(errors='replace') if isinstance(error.stdout, bytes) else (error.stdout or '')
                    log.write_text(partial, encoding='utf-8')
                    raise ValueError('Shutdown process timed out; partial output retained: ' + case) from error
                log.write_text(result.stdout, encoding='utf-8')
                if result.returncode:
                    raise ValueError('Shutdown process failed: ' + case)
                observed = parse_loading_shutdown(result.stdout, case)
                observed.update(exit_code=result.returncode, log=log.name, log_sha256=sha256(log),
                                seconds=round(time.monotonic() - started, 3))
                report['checks'].append(observed)
                print('PASS source loading shutdown:', case, flush=True)
    ensure_unchanged_sources(hashes)
    report.update(recorded_sources_unchanged=True, isolated_user_data_removed=True)
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', required=True, type=pathlib.Path)
    args = parser.parse_args()
    engine = shutil.which(args.godot) or str(pathlib.Path(args.godot).resolve())
    try:
        check(engine, args.output.resolve())
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, str(error) + '\n')
