"""Check real Windows UI Automation against an exact private archive.

Runs in a marked, isolated QA copy. Does not access the clipboard, desktop tree,
user library, file pickers or OS accessibility settings. This verifies native API
exposure and selected actions, not screen-reader usability or conformance.
"""
from __future__ import annotations

import argparse
import datetime
import json
import pathlib
import re
import shutil

from audit_native import git_bytes, source_snapshot
from build_native import sha256, unpack_zip
from verify_windows import (artifact_record, cleanup_successful_session, native_session,
                            powershell, ps_literal, write_report)

ROOT = pathlib.Path(__file__).resolve().parents[1]
SNAPSHOTS = ('baseline', 'search', 'page-one', 'page-two', 'page-return', 'hierarchy-return',
             'library', 'library-filter')


def rows(snapshot: dict, role: str) -> list[dict]:
    return [row for row in snapshot['elements'] if row['role'] == 'ControlType.' + role]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def inspect(snapshots: dict[str, dict]) -> dict:
    baseline = snapshots['baseline']['elements']
    for name in ('Find anatomy', 'List view', 'Anatomy hierarchy', '3D anatomy view'):
        require(any(row['name'] == name for row in baseline),
                'Missing accessible name: ' + name)
    require(any(row['name'] == 'Local label density' for row in baseline),
            'Missing named label-density control')
    require(len(rows(snapshots['search'], 'ListItem')) == 1,
            'Accessible search did not produce its unique source record')
    pages = [[row['name'] for row in rows(snapshots[name], 'ListItem')]
             for name in ('page-one', 'page-two', 'page-return')]
    require(all(0 < len(page) <= 100 for page in pages), 'Expected visible native rows on each page')
    for name, expected in [('page-one', 'Records 1–100 of 970'), ('page-two', 'Records 101–200 of 970'), ('page-return', 'Records 1–100 of 970')]:
        require(any(row['name'].startswith(expected) for row in rows(snapshots[name], 'Text')),
                'Native page summary differs from the expected range')
    require(pages[0] != pages[1] and pages[0] == pages[2], 'Native paging did not advance and return')
    hierarchy = snapshots['hierarchy-return']['elements']
    require(any(row['name'] == 'Anatomy hierarchy' for row in hierarchy)
            and not any(row['name'] == 'Anatomy records' for row in hierarchy),
            'Native mode toggle did not restore the hierarchy')
    library = snapshots['library']['elements']
    for name in ('Saved view name', 'Find saved views', 'Study notes'):
        require(any(row['name'] == name for row in library),
                'Missing accessible saved-view field: ' + name)
    require(len(rows(snapshots['library'], 'ListItem')) == 2, 'Isolated library seed was not exposed')
    matches = rows(snapshots['library-filter'], 'ListItem')
    require(len(matches) == 1 and 'Accessibility second' in matches[0]['name'],
            'Accessible library input did not filter to the expected saved view')
    return dict(search_results=1, page_size=100, native_pages_compared=3,
                library_before=2, library_after=1,
                scope='Windows UI Automation names, search and page actions; list scrolling, row activation, human screen-reader and Mac checks remain pending')


def verify(args: argparse.Namespace) -> dict:
    build = json.loads(args.build_report.read_text(encoding='utf-8'))
    artifact = artifact_record(args.archive, build)
    source_snapshot(build)
    args.output.mkdir(parents=True, exist_ok=False)
    session, windows = native_session(args)
    write_report(args.output / 'session.json', dict(path=str(session), windows=windows))
    controller = pathlib.Path(__file__).with_suffix('.ps1')
    snapshots = {}
    try:
        unpack_zip(args.archive, session)
        # Fake views exist only inside this generated child process's APPDATA.
        pack = json.loads(git_bytes(ROOT, build['source_revision'], 'content/sample_pack.json'))
        reference = next(body for body in pack['bodies'] if body['id'] == 'female')
        state = dict(schema_version=1, pack_id=pack['id'], body='female', selection='anatomy.heart',
                     camera=dict(target=[0, 0, 0], distance=2.8, yaw=0, pitch=0), labels=True,
                     reference_hash=reference['sha256'], changes={})
        seed = dict(schema_version=1, views=[dict(id=letter * 32, name='Accessibility ' + name,
                    state=state, created_unix=1, notes='Generated QA note')
                    for letter, name in [('a', 'first'), ('b', 'second')]])
        library = session / 'uia-data/PraxisCorporisPrototype/saved_views.json'
        library.parent.mkdir(parents=True)
        library.write_text(json.dumps(seed), encoding='utf-8')
        before = sha256(library)
        script = controller.read_text(encoding='utf-8')
        # Embed the script, with a properly quoted parameter; never a shell command.
        command = '& {\n' + script + '\n} -QaFolder ' + ps_literal(windows)
        result = powershell(args, command, timeout=120)
        (args.output / 'controller-stdout.log').write_text(result.stdout, encoding='utf-8')
        (args.output / 'controller-stderr.log').write_text(result.stderr, encoding='utf-8')
        for name in [*(name + '.json' for name in SNAPSHOTS), 'engine.log', 'stdout.log',
                     'stderr.log', 'exit.json', 'launched.json']:
            if (session / name).is_file():
                shutil.copyfile(session / name, args.output / name)
        require(result.returncode == 0, 'Native UI Automation failed: ' + result.stderr.strip())
        closed = json.loads((args.output / 'exit.json').read_text(encoding='utf-8-sig'))
        require(closed['closed'] and closed['exit_code'] == 0, 'Owned native viewer did not close cleanly')
        log = (args.output / 'engine.log').read_text(encoding='utf-8-sig')
        require('Godot Engine v' + build['engine'] in log, 'Unexpected native engine version')
        require(not re.search(r'ERROR:|Unicode parsing error|ObjectDB instance.*leaked|^Leaked instance:', log, re.M),
                'Native accessibility run reported a runtime error or leak')
        for name in SNAPSHOTS:
            snapshots[name] = json.loads((args.output / (name + '.json')).read_text(encoding='utf-8-sig'))
        checks = inspect(snapshots)
        require(sha256(library) == before, 'Read-only accessibility actions changed the isolated library')
        report = dict(result='passed', checked_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      artifact=artifact, source_revision=build['source_revision'],
                      verifier_sha256=sha256(pathlib.Path(__file__)), controller_sha256=sha256(controller),
                      build_report_sha256=sha256(args.build_report), checks=checks,
                      isolated_library_unchanged=True, exit=closed,
                      evidence={p.name: sha256(p) for p in args.output.iterdir() if p.is_file()})
        write_report(args.output / 'report.json', report)
        report['cleanup'] = cleanup_successful_session(session)
        report['cleanup']['independently_absent'] = not session.exists()
        write_report(args.output / 'report.json', report)
        require(report['cleanup']['status'] == 'removed' and report['cleanup']['independently_absent'],
                'Owned QA folder cleanup did not finish')
        return report
    except BaseException:
        # Retain the marked session and closed progress files for diagnosis.
        print('Retained owned accessibility session:', session, flush=True)
        raise


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=pathlib.Path, required=True)
    parser.add_argument('--build-report', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    parser.add_argument('--powershell', default='powershell.exe')
    args = parser.parse_args()
    report = verify(args)
    print('PASS native Windows accessibility:', report['source_revision'])
    print(json.dumps(report['checks'], indent=2))


if __name__ == '__main__':
    main()
