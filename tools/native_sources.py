"""Versioned inputs for native exports and independent committed-source audits."""

from __future__ import annotations

import pathlib
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
