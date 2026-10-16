"""Check archive containment, executable metadata and target architecture inspection."""

import os
import pathlib
import stat
import struct
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_native import binary_architectures, ensure_unchanged_sources, make_zip, run, sha256, unpack_zip


class NativePackagingTests(unittest.TestCase):
    def test_shutdown_build_checks_cannot_accept_missing_checks_or_late_leaks(self):
        marker = 'PASS loading shutdown: initial/anatomy · resource true · worker false · staged false'
        for output in ['', marker + '\n' + marker, marker + '\nERROR: Resource failed',
                       marker + '\nWARNING: 1 ObjectDB instance was leaked at exit',
                       marker + '\nSCRIPT ERROR: invalid call']:
            with self.subTest(output=output), patch('build_native.subprocess.run', return_value=SimpleNamespace(returncode=0, stdout=output)):
                with self.assertRaises(RuntimeError):
                    run(['fixture-engine'], required_marker=marker)

    def test_changed_or_deleted_runtime_inputs_cannot_finish_a_build(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            (root / "scripts").mkdir()
            project = root / "project.godot"
            script = root / "scripts/viewer.gd"
            project.write_text("original project")
            script.write_text("original script")
            recorded = {"project.godot": sha256(project), "scripts/viewer.gd": sha256(script)}
            ensure_unchanged_sources(recorded, root)
            script.write_text("edited during export")
            with self.assertRaisesRegex(ValueError, "viewer.gd"):
                ensure_unchanged_sources(recorded, root)
            script.write_text("original script")
            project.unlink()
            with self.assertRaisesRegex(ValueError, "project.godot"):
                ensure_unchanged_sources(recorded, root)

    def test_added_runtime_script_invalidates_the_recorded_build_snapshot(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            (root / "scripts").mkdir()
            script = root / "scripts/viewer.gd"
            script.write_text("original script")
            recorded = {"scripts/viewer.gd": sha256(script)}
            (root / "scripts/added.gd").write_text("new runtime resource")
            with self.assertRaisesRegex(ValueError, "Runtime scripts changed"):
                ensure_unchanged_sources(recorded, root)

    def test_mac_executable_permissions_survive_archive_round_trip(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            source = root / "PraxisCorporis"
            executable = source / "PraxisCorporis.app/Contents/MacOS/PraxisCorporis"
            executable.parent.mkdir(parents=True)
            executable.write_bytes(b"test executable metadata")
            executable.chmod(0o644)
            archive = root / "native.zip"
            # Preserve Mac export metadata even on a host without Unix execute bits.
            make_zip(source, archive, {"PraxisCorporis.app/Contents/MacOS/PraxisCorporis": 0o755})
            with zipfile.ZipFile(archive) as package:
                info = package.getinfo("PraxisCorporis/PraxisCorporis.app/Contents/MacOS/PraxisCorporis")
                self.assertEqual(info.create_system, 3)
                self.assertTrue((info.external_attr >> 16) & 0o111)
            destination = root / "extracted"
            unpack_zip(archive, destination)
            result = destination / "PraxisCorporis/PraxisCorporis.app/Contents/MacOS/PraxisCorporis"
            if os.name == "posix":
                self.assertTrue(result.stat().st_mode & 0o111)
            self.assertEqual(result.read_bytes(), executable.read_bytes())

    def test_path_escape_and_symlink_entries_are_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            for name, mode in [("../outside", stat.S_IFREG | 0o644), ("link", stat.S_IFLNK | 0o777)]:
                archive = root / "invalid.zip"
                info = zipfile.ZipInfo(name)
                info.external_attr = mode << 16
                with zipfile.ZipFile(archive, "w") as package:
                    package.writestr(info, b"outside")
                with self.assertRaises(ValueError):
                    unpack_zip(archive, root / "unpacked")
                self.assertFalse((root / "outside").exists())

    def test_windows_and_universal_mac_headers_are_distinguished(self):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            windows = bytearray(70)
            windows[:2] = b"MZ"
            struct.pack_into("<I", windows, 60, 64)
            struct.pack_into("<4sH", windows, 64, b"PE\0\0", 0x8664)
            executable = root / "windows.exe"
            executable.write_bytes(windows)
            self.assertEqual(binary_architectures(executable), ["x86_64"])
            struct.pack_into("<H", windows, 68, 0x014C)
            executable.write_bytes(windows)
            with self.assertRaises(ValueError):
                binary_architectures(executable)
            universal = root / "macos"
            universal.write_bytes(struct.pack(">II", 0xCAFEBABE, 2)
                                  + struct.pack(">IIIII", 0x01000007, 3, 4096, 100, 12)
                                  + struct.pack(">IIIII", 0x0100000C, 0, 8192, 100, 12))
            self.assertEqual(set(binary_architectures(universal)), {"x86_64", "arm64"})


if __name__ == "__main__":
    unittest.main()
