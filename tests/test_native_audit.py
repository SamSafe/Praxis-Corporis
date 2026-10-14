"""Bind archive reviews to committed sources and actual packaged content."""
import copy
import hashlib
import pathlib
import struct
import subprocess
import sys
import tempfile
import unittest
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from audit_native import FIXED_SOURCES, NOTICES, TARGETS, audit, source_snapshot
from build_native import make_zip, sha256


def fixture(root, mac=False):
    repository = root / 'repository'
    repository.mkdir()
    sources = FIXED_SOURCES | {'scripts/viewer.gd'}
    for relative in sources | set(NOTICES.values()):
        path = repository / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('Fixture content for ' + relative, encoding='utf-8')
    subprocess.run(['git', 'init', '-q'], cwd=repository, check=True)
    subprocess.run(['git', 'add', '.'], cwd=repository, check=True)
    subprocess.run(['git', '-c', 'user.name=Archive Fixture', '-c', 'user.email=fixture@invalid', 'commit', '-qm', 'Fixture'], cwd=repository, check=True)
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repository, text=True).strip()
    folder = root / 'PraxisCorporis'
    notices = folder / 'NOTICES'
    notices.mkdir(parents=True)
    for name, relative in NOTICES.items():
        (notices / name).write_bytes((repository / relative).read_bytes())
    (folder / 'START_HERE.txt').write_text('Private fixture instructions')
    anatomy = b'Fixture anatomy bytes'
    modes = {}
    if mac:
        app = folder / 'PraxisCorporis.app'
        executable = app / 'Contents/MacOS/PraxisCorporis'
        executable.parent.mkdir(parents=True)
        executable.write_bytes(struct.pack('>II', 0xCAFEBABE, 2)
                               + struct.pack('>IIIII', 0x01000007, 3, 4096, 100, 12)
                               + struct.pack('>IIIII', 0x0100000C, 0, 8192, 100, 12))
        embedded = app / 'Contents/Resources/PraxisCorporis.pck'
        embedded.parent.mkdir(parents=True)
        embedded.write_bytes(anatomy + b'Fixture core')
        seal = app / 'Contents/_CodeSignature/CodeResources'
        seal.parent.mkdir(parents=True)
        seal.write_text('Fixture seal presence only')
        modes[executable.relative_to(folder).as_posix()] = 0o755
        name = 'PraxisCorporis-macOS-universal-private.zip'
    else:
        header = bytearray(70)
        header[:2] = b'MZ'
        struct.pack_into('<I', header, 60, 64)
        struct.pack_into('<4sH', header, 64, b'PE\0\0', 0x8664)
        (folder / 'PraxisCorporis.exe').write_bytes(header)
        (folder / 'anatomy.pck').write_bytes(anatomy)
        name = 'PraxisCorporis-Windows-x64-private.zip'
    archive = root / name
    make_zip(folder, archive, modes)
    item = {'file': name, 'architectures': TARGETS[name], 'bytes': archive.stat().st_size, 'sha256': sha256(archive)}
    report = {'source_revision': revision, 'source_hashes': {p: sha256(repository / p) for p in sources},
              'artifacts': [item], 'anatomy_package': {'bytes': len(anatomy), 'sha256': hashlib.sha256(anatomy).hexdigest()}}
    return repository, folder, archive, report, modes


def refresh(archive, report):
    report['artifacts'][0].update(bytes=archive.stat().st_size, sha256=sha256(archive))


class NativeAuditTests(unittest.TestCase):
    def test_source_record_requires_every_runtime_file_and_the_committed_bytes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            repository, _, _, report, _ = fixture(root)
            self.assertEqual(source_snapshot(report, repository), report['source_revision'])
            for mutate in [lambda r: r['source_hashes'].pop('scripts/viewer.gd'),
                           lambda r: r['source_hashes'].update({'project.godot': '0' * 64}),
                           lambda r: r.update(source_revision='HEAD')]:
                broken = copy.deepcopy(report)
                mutate(broken)
                with self.subTest(broken=broken), self.assertRaises(ValueError):
                    source_snapshot(broken, repository)
            # Working-copy changes cannot silently replace the recorded committed snapshot.
            (repository / 'project.godot').write_text('Later uncommitted edit')
            self.assertEqual(source_snapshot(report, repository), report['source_revision'])

    def test_orientation_metadata_is_required_for_snapshots_that_contain_it(self):
        with tempfile.TemporaryDirectory() as temporary:
            repository, _, _, report, _ = fixture(pathlib.Path(temporary))
            path = repository / 'content/reference_frames.json'
            path.write_text('Fixture orientation metadata')
            subprocess.run(['git', 'add', str(path)], cwd=repository, check=True)
            subprocess.run(['git', '-c', 'user.name=Archive Fixture', '-c', 'user.email=fixture@invalid', 'commit', '-qm', 'Orientation fixture'], cwd=repository, check=True)
            report['source_revision'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repository, text=True).strip()
            with self.assertRaisesRegex(ValueError, 'required runtime files'):
                source_snapshot(report, repository)
            report['source_hashes']['content/reference_frames.json'] = sha256(path)
            self.assertEqual(source_snapshot(report, repository), report['source_revision'])

    def test_matching_hashes_do_not_hide_changed_notices_or_anatomy(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            repository, folder, archive, report, modes = fixture(root)
            self.assertEqual(audit(report, root, repository)['artifacts'][0]['crc'], 'passed every extracted entry')
            notice = folder / 'NOTICES/HRA-LICENSE.txt'
            original = notice.read_bytes()
            notice.write_bytes(b'Changed notice')
            make_zip(folder, archive, modes)
            refresh(archive, report)
            with self.assertRaisesRegex(ValueError, 'notice'):
                audit(report, root, repository)
            notice.write_bytes(original)
            (folder / 'anatomy.pck').write_bytes(b'Changed anatomy')
            make_zip(folder, archive, modes)
            refresh(archive, report)
            with self.assertRaisesRegex(ValueError, 'anatomy package'):
                audit(report, root, repository)

    def test_mac_modes_and_resource_seal_are_separate_from_native_execution(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            repository, folder, archive, report, modes = fixture(root, mac=True)
            result = audit(report, root, repository)
            self.assertIn('no signature or content execution claim', result['artifacts'][0]['content'])
            modes[next(iter(modes))] = 0o644
            make_zip(folder, archive, modes)
            refresh(archive, report)
            with self.assertRaisesRegex(ValueError, 'execute permissions'):
                audit(report, root, repository)
            modes[next(iter(modes))] = 0o755
            (folder / 'PraxisCorporis.app/Contents/_CodeSignature/CodeResources').unlink()
            make_zip(folder, archive, modes)
            refresh(archive, report)
            with self.assertRaisesRegex(ValueError, 'resource seal'):
                audit(report, root, repository)

    def test_misidentified_modified_or_escaping_archives_fail(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = pathlib.Path(temporary)
            repository, _, archive, report, _ = fixture(root)
            for mutate in [lambda r: r['artifacts'][0].update(architectures=['arm64']),
                           lambda r: r['artifacts'][0].update(sha256='0' * 64),
                           lambda r: r['artifacts'].append(copy.deepcopy(r['artifacts'][0]))]:
                broken = copy.deepcopy(report)
                mutate(broken)
                with self.subTest(broken=broken), self.assertRaises(ValueError):
                    audit(broken, root, repository)
            with zipfile.ZipFile(archive, 'a') as package:
                package.writestr('PraxisCorporis/../escape.txt', 'must remain inside the package')
            refresh(archive, report)
            with self.assertRaisesRegex(ValueError, 'paths'):
                audit(report, root, repository)


if __name__ == '__main__':
    unittest.main()
