"""Versioned inputs for native exports and independent committed-source audits."""

from __future__ import annotations

import pathlib
import configparser
import hashlib
import json
import re
from collections.abc import Iterable

SNAPSHOT_VERSION = 2
SOURCE_ROOTS = ('scripts', 'scenes', 'content', 'addons/private_native_export')
BUILD_INPUTS = frozenset({'project.godot', 'export_presets.cfg', 'tools/native_sources.py',
                          'tools/build_native.py', 'tools/pack_anatomy.gd'})


def source_paths(paths: Iterable[str]) -> set[str]:
    """Use the same scope for working files and a recorded Git tree.

    Include every file under the resource directories, including nested scenes,
    resource UIDs and plugin configuration. Documentation and QA outputs remain
    outside the export inputs.
    """
    return {path for path in paths if path in BUILD_INPUTS
            or any(path.startswith(folder + '/') for folder in SOURCE_ROOTS)}


def discover_sources(root: pathlib.Path) -> set[str]:
    paths = {name for name in BUILD_INPUTS if (root / name).is_file()}
    for folder in SOURCE_ROOTS:
        paths.update(path.relative_to(root).as_posix()
                     for path in (root / folder).rglob('*') if path.is_file())
    return paths


def private_application_version(presets: str) -> str:
    config = configparser.ConfigParser(interpolation=None)
    config.read_string(presets)
    versions = [json.loads(config[section][key]) for section, key in [
        ('preset.0.options', 'application/file_version'),
        ('preset.0.options', 'application/product_version'),
        ('preset.1.options', 'application/short_version'),
        ('preset.1.options', 'application/version')]]
    if not all(isinstance(value, str) for value in versions) or len(set(versions)) != 1 or not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+', versions[0]):
        raise ValueError('Private platform versions must agree on one three-part application version')
    return versions[0]


def identity_record(report: dict, presets: str, build_id: str) -> dict:
    if not isinstance(build_id, str) or not re.fullmatch('[0-9a-f]{32}', build_id):
        raise ValueError('Private build identity needs a 32-character build ID')
    fingerprint = hashlib.sha256(json.dumps(report['source_hashes'], sort_keys=True,
                                           separators=(',', ':')).encode('utf-8')).hexdigest()
    return dict(schema_version=1, channel='private', build_id=build_id,
                application_version=private_application_version(presets),
                source_revision=report['source_revision'], source_snapshot_sha256=fingerprint,
                engine=report['engine'], content_pack=report['content_pack'])


def verify_identity_record(report: dict, presets: str) -> dict:
    identity = report.get('build_identity')
    if not isinstance(identity, dict) or identity != identity_record(report, presets, identity.get('build_id')):
        raise ValueError('Private build identity differs from its recorded source, version, engine or content')
    return identity
