"""Keep generated-session cleanup separate from retained runtime verification."""
import argparse
import contextlib
import io
import json
import pathlib
import struct
import sys
import tempfile
import unittest
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from verify_windows import OWNED_SESSION_MARKER, cleanup_successful_session, verify, write_report
from test_windows_verification import complete_log


def owned_session(parent):
    folder = parent / ('PraxisCorporis-QA-' + 'a' * 32)
    folder.mkdir()
    (folder / '.praxis-qa-owned').write_text(OWNED_SESSION_MARKER, encoding='utf-8')
    (folder / 'anatomy.pck').write_bytes(b'Reproducible generated fixture')
    return folder


class NativeSessionCleanupTests(unittest.TestCase):
    def test_only_owned_scratch_is_removed_and_retained_evidence_survives(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = pathlib.Path(directory)
            folder = owned_session(parent)
            evidence = parent / 'report.json'
            evidence.write_text('Retained evidence')
            self.assertEqual(cleanup_successful_session(folder)['status'], 'removed')
            self.assertFalse(folder.exists())
            self.assertEqual(evidence.read_text(), 'Retained evidence')
            self.assertEqual(cleanup_successful_session(folder)['status'], 'already_missing')

    def test_foreign_or_changed_markers_and_symlinks_are_retained(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = pathlib.Path(directory)
            foreign = parent / 'user-library'
            foreign.mkdir()
            (foreign / '.praxis-qa-owned').write_text(OWNED_SESSION_MARKER)
            self.assertEqual(cleanup_successful_session(foreign)['status'], 'retained')
            folder = owned_session(parent)
            marker = folder / '.praxis-qa-owned'
            marker.unlink()
            self.assertEqual(cleanup_successful_session(folder)['status'], 'retained')
            marker.write_text('Different ownership')
            self.assertEqual(cleanup_successful_session(folder)['status'], 'retained')
            marker.unlink()
            try:
                marker.symlink_to(foreign / '.praxis-qa-owned')
            except (OSError, NotImplementedError):
                pass
            else:
                self.assertEqual(cleanup_successful_session(folder)['status'], 'retained')
                self.assertTrue(foreign.exists())
                link = parent / ('PraxisCorporis-QA-' + 'b' * 32)
                link.symlink_to(foreign, target_is_directory=True)
                self.assertEqual(cleanup_successful_session(link)['status'], 'retained')
                self.assertTrue(foreign.exists())

    def test_windows_marker_line_endings_and_explicit_retention(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = owned_session(pathlib.Path(directory))
            (folder / '.praxis-qa-owned').write_bytes(OWNED_SESSION_MARKER.replace('\n', '\r\n').encode())
            self.assertEqual(cleanup_successful_session(folder, keep=True)['status'], 'retained')
            self.assertTrue(folder.exists())
            self.assertEqual(cleanup_successful_session(folder)['status'], 'removed')

    def test_atomic_report_update_keeps_previous_complete_evidence_on_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'report.json'
            write_report(path, {'result': 'passed', 'session_cleanup': {'status': 'pending'}})
            original = path.read_bytes()
            with mock.patch.object(pathlib.Path, 'replace', side_effect=PermissionError('locked report')):
                with self.assertRaises(PermissionError):
                    write_report(path, {'result': 'passed', 'session_cleanup': {'status': 'removed'}})
            self.assertEqual(path.read_bytes(), original)
            self.assertEqual(json.loads(path.read_text())['result'], 'passed')

    def test_cleanup_failure_preserves_a_successful_runtime_result(self):
        self.run_verifier_fixture(cleanup_fails=True)

    def test_failed_runtime_keeps_its_session_for_diagnosis(self):
        self.run_verifier_fixture(runtime_fails=True)

    def test_failed_evidence_write_keeps_the_complete_native_session(self):
        self.run_verifier_fixture(report_fails=True)

    def run_verifier_fixture(self, cleanup_fails=False, runtime_fails=False, report_fails=False):
        with tempfile.TemporaryDirectory() as directory:
            parent = pathlib.Path(directory)
            session = owned_session(parent)
            app = session / 'PraxisCorporis'
            app.mkdir()
            executable = bytearray(70)
            executable[:2] = b'MZ'
            struct.pack_into('<I', executable, 60, 64)
            struct.pack_into('<4sH', executable, 64, b'PE\0\0', 0x8664)
            (app / 'PraxisCorporis.exe').write_bytes(executable)
            (app / 'anatomy.pck').write_bytes(b'Anatomy fixture')
            (session / 'engine.log').write_text('Engine fixture')
            archive = parent / 'PraxisCorporis-Windows-x64-private.zip'
            archive.write_bytes(b'Artifact fixture')
            report = parent / 'build-report.json'
            report.write_text(json.dumps({'source_revision': '1' * 40, 'source_hashes': {},
                'engine': '4.7.2.stable.official.ed1daf0bf'}))
            args = argparse.Namespace(build_report=report, archive=archive, output=parent / 'retained', mode='headless', keep_session=False)
            item = {'file': archive.name, 'architectures': ['x86_64']}
            with mock.patch('verify_windows.artifact_record', return_value=item), \
                 mock.patch('verify_windows.source_snapshot'), \
                 mock.patch('verify_windows.native_session', return_value=(session, str(session))), \
                 mock.patch('verify_windows.unpack_zip'), \
                 mock.patch('verify_windows.run_native', side_effect=RuntimeError('runtime failed') if runtime_fails else None, return_value=complete_log(False)), \
                 mock.patch('verify_windows.write_report', side_effect=PermissionError('evidence unavailable') if report_fails else write_report), \
                 mock.patch('verify_windows.shutil.rmtree', side_effect=PermissionError('locked temporary executable') if cleanup_fails else None) as remove:
                if runtime_fails or report_fails:
                    with contextlib.redirect_stdout(io.StringIO()), self.assertRaises(RuntimeError if runtime_fails else PermissionError):
                        verify(args)
                    remove.assert_not_called()
                    self.assertTrue((session / 'anatomy.pck').exists())
                else:
                    result = verify(args)
                    self.assertEqual(result['result'], 'passed; native exit code 0')
                    self.assertEqual(result['session_cleanup']['status'], 'retained')
                    self.assertIn('locked temporary executable', result['session_cleanup']['reason'])
                    saved = json.loads((args.output / 'report.json').read_text())
                    self.assertEqual(saved, result)
                    self.assertEqual((args.output / 'engine.log').read_text(), 'Engine fixture')
                    self.assertTrue((session / 'anatomy.pck').exists())


if __name__ == '__main__':
    unittest.main()
