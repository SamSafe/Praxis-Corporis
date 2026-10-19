"""Test private Windows upgrade/rollback through real app controls and isolated data.

Uses unchanged recorded archives. Only the generated child's APPDATA and LOCALAPPDATA
are shared between versions. No external scripts, clipboard, global keyboard input,
user libraries, file pickers, installers or OS accessibility settings are used.
"""
from __future__ import annotations

import argparse
import datetime
import json
import math
import pathlib
import re
import shutil

from audit_native import git_bytes, source_snapshot
from build_native import sha256, unpack_zip
from verify_windows import (artifact_record, cleanup_successful_session, native_session,
                            powershell, ps_literal, write_report)

ROOT = pathlib.Path(__file__).resolve().parents[1]
PROFILE_FILES = ('saved_views.json', 'saved_views.json.bak', 'preferences.json',
                 'reference-state.json', 'window-state.json')
PREFERENCES = dict(text_scale=1.15, resolution=0.75, explorer=True, details=True,
                   selection_labels=False, local_labels=True, label_density=5)
STATE_NUMBER_TOLERANCE = 1e-12


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def catalogue(report: dict) -> list[dict]:
    revision = report['source_revision']
    bodies = json.loads(git_bytes(ROOT, revision, 'content/sample_pack.json'))['bodies']
    bones = json.loads(git_bytes(ROOT, revision, 'content/bodyparts3d_bone_study.json'))
    bodies.append(bones)
    bodies.extend(json.loads(git_bytes(ROOT, revision, 'content/spinal_studies.json'))['bodies'])
    return bodies


def entries_by_id(profile: pathlib.Path) -> dict[str, dict]:
    data = json.loads((profile / 'saved_views.json').read_text(encoding='utf-8-sig'))
    require(data.get('schema_version') == 1 and isinstance(data.get('views'), list), 'Unsupported library schema')
    entries = data['views']
    require(all(isinstance(entry, dict) and isinstance(entry.get('id'), str) for entry in entries), 'Invalid library entries')
    indexed = {entry['id']: entry for entry in entries}
    require(len(indexed) == len(entries) and len({e['name'] for e in entries}) == len(entries), 'Duplicate library identities or names')
    return indexed


def same_state(left, right) -> bool:
    """Allow decimal reserialization noise, retaining every key and discrete value."""
    if isinstance(left, bool) or isinstance(right, bool):
        return type(left) is type(right) and left == right
    if isinstance(left, (int, float)) and isinstance(right, (int, float)):
        return math.isfinite(left) and math.isfinite(right) and math.isclose(
            left, right, rel_tol=STATE_NUMBER_TOLERANCE, abs_tol=STATE_NUMBER_TOLERANCE)
    if isinstance(left, dict) and isinstance(right, dict):
        return left.keys() == right.keys() and all(same_state(value, right[key]) for key, value in left.items())
    if isinstance(left, list) and isinstance(right, list):
        return len(left) == len(right) and all(same_state(a, b) for a, b in zip(left, right))
    return type(left) is type(right) and left == right


def verify_entries(before: dict, after: dict, cases: list[dict], restored: dict[str, dict] | None = None) -> dict[str, dict]:
    for key, entry in before.items():
        current = after.get(key, {})
        require({k: v for k, v in current.items() if k != 'state'} == {k: v for k, v in entry.items() if k != 'state'}
                and same_state(current.get('state'), entry.get('state')), 'An existing view, note or identity changed')
    added = {key: entry for key, entry in after.items() if key not in before}
    require(len(added) == len(cases), 'Unexpected number of newly captured views')
    by_name = {entry['name']: entry for entry in added.values()}
    for case in cases:
        entry = by_name.get(case['name'], {})
        require(entry.get('notes') == case['note'], 'Multiline Unicode note differs: ' + case['id'])
        state = entry.get('state', {})
        require(state.get('body') == case['id'] and state.get('reference_hash') == case['sha256'], 'Captured source differs: ' + case['id'])
        require(state.get('selection') == case['leaf'] and state.get('isolation') == case['leaf']
                and bool(state.get('inspection_return')), 'Selection/isolation/return state was lost: ' + case['id'])
        require(state.get('labels') is False and state.get('local_labels') is True and state.get('label_density') == 5,
                'Saved label preferences differ: ' + case['id'])
        changes = state.get('changes', {})
        require(any(any(float(axis) != 0 for axis in change.get('offset', [])) for change in changes.values()), 'No real movement was captured: ' + case['id'])
        require(any(change.get('visibility') == 'faded' for change in changes.values()), 'Faded visibility was not captured: ' + case['id'])
        if restored is not None:
            require(same_state(state, restored[case['restore_name']]['state']), 'Restored camera/anatomy/labels differ: ' + case['id'])
    return by_name


def inspect_run(output: pathlib.Path, count: int, engine: str, expected_title: str) -> dict:
    closed = json.loads((output / 'exit.json').read_text(encoding='utf-8-sig'))
    require(closed['closed'] and closed['exit_code'] == 0 and not closed.get('forced', False) and closed['completed'] == count, 'Native compatibility step did not complete normally')
    ready = json.loads((output / 'ready.json').read_text(encoding='utf-8-sig'))
    require(ready['title'] == expected_title and ready['client_size'] == [1300, 800], 'Startup reference/window layout was not restored')
    progress = json.loads((output / 'progress.json').read_text(encoding='utf-8-sig'))
    require(len(progress['completed']) == count, 'Native compatibility progress is incomplete')
    log = (output / 'engine.log').read_text(encoding='utf-8-sig')
    require('Godot Engine v' + engine in log, 'Unexpected native engine')
    require(not re.search(r'ERROR:|Unicode parsing error|ObjectDB instance.*leaked|^Leaked instance:', log, re.M), 'Native step reported an error or leak')
    return dict(exit=closed, ready=ready, completed=progress['completed'], engine_log_sha256=sha256(output / 'engine.log'))


def verify(args: argparse.Namespace) -> dict:
    builds = {name: json.loads(path.read_text(encoding='utf-8')) for name, path in
              [('baseline', args.baseline_build_report), ('candidate', args.candidate_build_report)]}
    archives = dict(baseline=args.baseline_archive, candidate=args.candidate_archive)
    artifacts = {}
    for name in builds:
        source_snapshot(builds[name])
        artifacts[name] = artifact_record(archives[name], builds[name])
    old, new = catalogue(builds['baseline']), catalogue(builds['candidate'])
    require({b['id']: b['sha256'] for b in old} == {b['id']: b['sha256'] for b in new},
            'This cycle requires the same reference geometry; changed-content acceptance is separate')
    require(not args.output.exists(), 'Use a fresh compatibility output folder')
    args.output.mkdir(parents=True)
    session, windows = native_session(args)
    write_report(args.output / 'session.json', dict(path=str(session), windows=windows))
    controller = pathlib.Path(__file__).with_suffix('.ps1')
    profile = session / 'shared-data/PraxisCorporisPrototype'
    runs = []
    try:
        for name in builds:
            (session / name).mkdir()
            unpack_zip(archives[name], session / name)
        (session / 'jobs').mkdir()
        profile.mkdir(parents=True)
        (profile / 'preferences.json').write_text(json.dumps(dict(schema_version=1, values=PREFERENCES)), encoding='utf-8')
        preferences_hash = sha256(profile / 'preferences.json')
        (profile / 'window-state.json').write_text(json.dumps(dict(schema_version=1, size=[1300, 800], maximized=False)), encoding='utf-8')
        cases = [dict(id=body['id'], token=f'qa_ref_{index:02d}', sha256=body['sha256'], leaf=body.get('qa_leaf_id',
                      'source.bodyparts3d-v4-male.FJ3365' if body['id'] == 'bodyparts-male-bones-study' else 'anatomy.heart.valve.mitral'),
                      title='Praxis Corporis · ' + body.get('short_label', body['label'])) for index, body in enumerate(old)]
        script = controller.read_text(encoding='utf-8')

        def launch(job: dict) -> None:
            tag = job['tag']
            local_job = session / 'jobs' / (tag + '.json')
            local_job.write_text(json.dumps(job, ensure_ascii=False), encoding='utf-8')
            command = '& {\n' + script + '\n} -QaFolder ' + ps_literal(windows) + ' -JobFile ' + ps_literal(windows + '\\jobs\\' + tag + '.json')
            destination = args.output / 'runs' / tag
            destination.mkdir(parents=True, exist_ok=False)
            result = powershell(args, command, timeout=360)
            if (session / 'runs' / tag).exists():
                shutil.copytree(session / 'runs' / tag, destination, dirs_exist_ok=True)
            (destination / 'controller-stderr.log').write_text(result.stderr, encoding='utf-8')
            (destination / 'controller-stdout.log').write_text(result.stdout, encoding='utf-8')
            require(result.returncode == 0, 'Owned compatibility controller failed: ' + result.stderr.strip())
            observation = inspect_run(destination, len(job['cases']), builds[job['version']]['engine'], job['ready_title'])
            runs.append(dict(tag=tag, version=job['version'], **observation))
            require(sha256(profile / 'preferences.json') == preferences_hash, 'Reading/restoring views changed the device preferences file')
            settings = json.loads((profile / 'window-state.json').read_text())
            require(settings == dict(schema_version=1, size=[1300, 800], maximized=False), 'Normal close changed the remembered window layout')
            snapshot = args.output / 'profiles' / tag
            snapshot.mkdir(parents=True)
            for name in PROFILE_FILES:
                if (profile / name).is_file():
                    shutil.copyfile(profile / name, snapshot / name)
            print('PASS native compatibility step:', tag, flush=True)

        before = {}
        baseline = {}
        for index, case in enumerate(cases):
            (profile / 'reference-state.json').write_text(json.dumps(dict(schema_version=1, body_id=case['id'], source_sha256=case['sha256'])), encoding='utf-8')
            capture = dict(case, name='QA baseline ' + case['id'] + ' ' + case['token'], restore_name='', note='Baseline QA only · ' + case['id'] + '\nCafé λ 🫀')
            launch(dict(tag=f'baseline-{index:02d}', version='baseline', action='baseline', ready_title=case['title'], cases=[capture]))
            after = entries_by_id(profile)
            baseline.update(verify_entries(before, after, [capture]))
            before = after
        previous = baseline
        for stage, version, prefix in [('forward', 'candidate', 'current'), ('rollback', 'baseline', 'rollback'), ('reopen', 'candidate', 'reopened')]:
            captures = [dict(case, name='QA ' + prefix + ' ' + case['id'] + ' ' + case['token'],
                             restore_name=next(e['name'] for e in previous.values() if e['state']['body'] == case['id']),
                             note=prefix.capitalize() + ' QA only · ' + case['id'] + '\nCafé λ 🫀') for case in cases]
            launch(dict(tag=stage, version=version, action='restore', ready_title=cases[-1]['title'], cases=captures))
            after = entries_by_id(profile)
            previous = verify_entries(before, after, captures, previous)
            before = after
        require(len(before) == len(cases) * 4, 'Final saved-view count differs from the full cycle')
        result = dict(result='passed', checked_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      artifacts=artifacts, source_revisions={key: b['source_revision'] for key, b in builds.items()},
                      build_identities={key: b.get('build_identity') for key, b in builds.items()},
                      verifier_sha256=sha256(pathlib.Path(__file__)), controller_sha256=sha256(controller),
                      references=[case['id'] for case in cases], normal_launches=len(runs), runs=runs,
                      saved_views=len(before), snapshot_comparisons=len(cases) * 3, original_ids_and_entries_preserved=True,
                      exact_multiline_unicode_notes=True, preferences_file_unchanged=True, window_client_size=[1300, 800],
                      state_number_tolerance=dict(absolute=STATE_NUMBER_TOLERANCE, relative=STATE_NUMBER_TOLERANCE,
                                                  scope='Scene numbers only; JSON decimal reserialization. Entry IDs, notes and timestamps compare exactly.'),
                      scope='Native Windows controls and owned-window input, same geometry and save schema. Mac, changed schemas/content, installers and human device acceptance remain separate.',
                      evidence={str(p.relative_to(args.output)): sha256(p) for p in args.output.rglob('*') if p.is_file()})
        write_report(args.output / 'report.json', result)
        result['cleanup'] = cleanup_successful_session(session)
        result['cleanup']['independently_absent'] = not session.exists()
        write_report(args.output / 'report.json', result)
        require(result['cleanup']['status'] == 'removed' and result['cleanup']['independently_absent'], 'Owned compatibility session cleanup did not finish')
        return result
    except BaseException:
        print('Retained owned compatibility session:', session, flush=True)
        raise


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['baseline-archive', 'baseline-build-report', 'candidate-archive', 'candidate-build-report', 'output']:
        parser.add_argument('--' + name, type=pathlib.Path, required=True)
    parser.add_argument('--powershell', default='powershell.exe')
    args = parser.parse_args()
    result = verify(args)
    print('PASS native upgrade/rollback:', result['normal_launches'], 'launches;', result['snapshot_comparisons'], 'snapshot comparisons')


if __name__ == '__main__':
    main()
