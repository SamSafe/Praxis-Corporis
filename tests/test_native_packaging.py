"""Check archive containment, executable metadata and target architecture inspection."""

import os
import pathlib
import stat
import struct
import sys
import tempfile
import unittest
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from build_native import binary_architectures, make_zip, unpack_zip


class NativePackagingTests(unittest.TestCase):
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
