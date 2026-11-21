"""Audit private archives, notices and source snapshots without executing applications."""
from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import pathlib
import re
import subprocess
import tempfile
import zipfile

from build_native import ROOT, binary_architectures, sha256, unpack_zip
from native_sources import SNAPSHOT_VERSION, source_paths, verify_identity_record

FIXED_SOURCES = {
    'project.godot', 'export_presets.cfg', 'content/sample_pack.json', 'content/source_manifest.json',
    'content/toolchain_manifest.json', 'content/coverage_notes.json', 'content/bodyparts3d_bone_study.json',
    'content/bodyparts3d_complete_body.json',
    'content/bodyparts3d_source_manifest.json', 'addons/private_native_export/plugin.gd',
}
NOTICES = {name: 'third_party/' + name for name in [
    'HRA-LICENSE.txt', 'HRA-README.md', 'Godot-LICENSE.txt', 'Godot-COPYRIGHT.txt',
    'BodyParts3D-README.html', 'BodyParts3D-CURRENT-LICENSE.html', 'BodyParts3D-LEGACY-OBJ-NOTICE.txt',
]}
NOTICES['ATTRIBUTIONS.md'] = 'ATTRIBUTIONS.md'
TARGETS = {'PraxisCorporis-Windows-x64-private.zip': ['x86_64'],
           'PraxisCorporis-macOS-universal-private.zip': ['x86_64', 'arm64']}


def git_bytes(repository: pathlib.Path, revision: str, relative: str) -> bytes:
    return subprocess.check_output(['git', 'show', revision + ':' + relative], cwd=repository,
                                   stderr=subprocess.PIPE, timeout=15)


def source_snapshot(report: dict, repository: pathlib.Path = ROOT) -> str:
    revision = report['source_revision']
    if not isinstance(revision, str) or not re.fullmatch('[0-9a-f]{40}', revision):
        raise ValueError('Build report must record a full committed source revision')
    tracked = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', revision], cwd=repository,
                                      text=True, stderr=subprocess.PIPE, timeout=15).splitlines()
    scripts = {p for p in tracked if re.fullmatch(r'scripts/[^/]+\.gd', p)}
    # Earlier recorded snapshots predate orientation metadata; require it when
    # present in that commit without silently redefining historical packages.
    additional = {'content/reference_frames.json', 'content/study_content.json',
                  'content/spinal_studies.json', 'content/spinal_source_manifest.json'} & set(tracked)
    required = FIXED_SOURCES | scripts | additional
    if 'tools/native_sources.py' in tracked:
        if report.get('source_snapshot_version') != SNAPSHOT_VERSION:
            raise ValueError('This source revision requires native source snapshot version 2')
        required = source_paths(tracked)
    elif report.get('source_snapshot_version', 1) != 1:
        raise ValueError('Historical source revisions require their original snapshot version')
    if not scripts or set(report['source_hashes']) != required:
        raise ValueError('Source snapshot omits or changes the set of required runtime files')
    for relative, expected in report['source_hashes'].items():
        if hashlib.sha256(git_bytes(repository, revision, relative)).hexdigest() != expected:
            raise ValueError('Recorded source hash differs from its commit: ' + relative)
    if 'scripts/build_identity.gd' in tracked:
        verify_identity_record(report, git_bytes(repository, revision, 'export_presets.cfg').decode('utf-8'))
    elif 'build_identity' in report:
        raise ValueError('Build identity is not supported by this historical source revision')
    return revision


def audit(report: dict, directory: pathlib.Path, repository: pathlib.Path = ROOT) -> dict:
    revision = source_snapshot(report, repository)
    expected_notices = {name: hashlib.sha256(git_bytes(repository, revision, relative)).hexdigest()
                        for name, relative in NOTICES.items()}
    artifacts, seen = [], set()
    if not report['artifacts']:
        raise ValueError('Build report has no native artifacts')
    for item in report['artifacts']:
        name = item['file']
        if name not in TARGETS or name in seen or item['architectures'] != TARGETS[name]:
            raise ValueError('Build report has an unsupported, repeated or misidentified artifact')
        seen.add(name)
        archive = directory / name
        if archive.stat().st_size != item['bytes'] or sha256(archive) != item['sha256']:
            raise ValueError('Archive differs from its recorded build artifact: ' + name)
        with zipfile.ZipFile(archive) as package:
            names = package.namelist()
            if len(names) != len(set(names)) or any(not p.startswith('PraxisCorporis/') or '\\' in p or '..' in pathlib.PurePosixPath(p).parts for p in names):
                raise ValueError('Archive paths are duplicated or outside the private package')
        with tempfile.TemporaryDirectory(prefix='praxis-archive-audit-') as temporary:
            root = pathlib.Path(temporary)
            modes = unpack_zip(archive, root) # Reads every entry, validating its CRC.
            folder = root / 'PraxisCorporis'
            for notice, expected in expected_notices.items():
                if sha256(folder / 'NOTICES' / notice) != expected:
                    raise ValueError('Native notice differs from the committed source: ' + notice)
            if not (folder / 'START_HERE.txt').stat().st_size:
                raise ValueError('Private startup instructions are missing')
            if report.get('build_identity'):
                instructions = (folder / 'START_HERE.txt').read_text(encoding='utf-8').splitlines()
                for label, key in [('Version', 'application_version'), ('Build ID', 'build_id'),
                                   ('Source revision', 'source_revision'), ('Source inputs SHA-256', 'source_snapshot_sha256')]:
                    if label + ': ' + report['build_identity'][key] not in instructions:
                        raise ValueError('Startup instructions do not identify the recorded private build')
            if 'Windows' in name:
                executable = folder / 'PraxisCorporis.exe'
                anatomy = folder / 'anatomy.pck'
                if anatomy.stat().st_size != report['anatomy_package']['bytes'] or sha256(anatomy) != report['anatomy_package']['sha256']:
                    raise ValueError('Windows anatomy package differs from its build record')
                content_check = 'Companion anatomy package bytes/SHA-256 match the build record.'
            else:
                app = folder / 'PraxisCorporis.app'
                executables = list((app / 'Contents/MacOS').glob('*'))
                packs = list((app / 'Contents/Resources').glob('*.pck'))
                if len(executables) != 1 or not executables[0].is_file() or not modes.get(executables[0].relative_to(root).as_posix(), 0) & 0o111:
                    raise ValueError('Mac application must retain one executable with execute permissions')
                if len(packs) != 1 or packs[0].stat().st_size < report['anatomy_package']['bytes']:
                    raise ValueError('Mac embedded content is missing or smaller than its anatomy package')
                if not (app / 'Contents/_CodeSignature/CodeResources').is_file():
                    raise ValueError('Mac ad-hoc resource seal is missing')
                executable = executables[0]
                content_check = 'Embedded content size, executable modes and resource-seal presence checked; no signature or content execution claim.'
            if binary_architectures(executable) != item['architectures']:
                raise ValueError('Actual executable architecture differs from its build record')
        artifacts.append(dict(item, crc='passed every extracted entry', notices='all match committed source', content=content_check))
    return {'schema_version': 1, 'recorded_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'source_snapshot_verified_against_revision': revision, 'runtime_source_files': len(report['source_hashes']),
            'source_snapshot_version': report.get('source_snapshot_version', 1),
            'source_snapshot_scope': ('Project/export configuration, resource directories, UIDs and native build inputs.'
                                      if report.get('source_snapshot_version') == SNAPSHOT_VERSION else
                                      'Legacy recorded scripts/configuration/content; startup scene and UIDs were not recorded.'),
            'auditor_sha256': sha256(pathlib.Path(__file__)), 'artifacts': artifacts,
            'build_identity': report.get('build_identity'),
            'scope': 'Archive/source audit only; native execution, resource-boundary checks, content fidelity and device performance have separate evidence.'}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-report', type=pathlib.Path, default=ROOT / 'dist/build-report.json')
    parser.add_argument('--artifact-dir', type=pathlib.Path, help='Defaults to the build report directory')
    parser.add_argument('--output', type=pathlib.Path, help='New evidence file; existing files are retained')
    args = parser.parse_args()
    try:
        report = json.loads(args.build_report.read_text(encoding='utf-8'))
        result = audit(report, args.artifact_dir or args.build_report.parent)
        if args.output:
            with args.output.open('x', encoding='utf-8') as stream:
                stream.write(json.dumps(result, indent=2) + '\n')
    except (OSError, ValueError, KeyError, TypeError, zipfile.BadZipFile, subprocess.SubprocessError) as error:
        parser.exit(1, str(error) + '\n')
    print('PASS archive CRCs, architectures, committed notices and source snapshot:', result['source_snapshot_verified_against_revision'])
    for item in result['artifacts']:
        print(item['file'], '·', item['sha256'])
    if args.output:
        print('Retained evidence:', args.output)


if __name__ == '__main__':
    main()
