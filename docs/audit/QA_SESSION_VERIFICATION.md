# Native QA evidence retention and cleanup

Tool checkpoint `eed5f20`, checked against the existing private runtime
`82120935bacc41a182a7d0b48c83bfceff4d6b8d` on 2026-10-15. The app archives retain
the identities in [draft-content verification](DRAFT_CONTENT_VERIFICATION.md).

The Windows verifier and profiler already removed successful staging. Cleanup now
checks the generated absolute path and ownership marker, preserves foreign folders
and symlinks, and records its outcome separately from runtime/measurement results.
A locked generated file can leave staging behind without converting a verified app
run into a runtime failure. `--keep-session` supports deliberate manual inspection.
Failed runtimes or failed evidence retention keep their staging for diagnosis.

Reports use atomic replacement. A failed later update preserves the previous
complete report. Logs, captures and raw measurements are retained before cleanup.

| Check | Evidence |
|---|---|
| Python | All 54 checks pass. New cases cover owned/foreign folders, marker changes and symlinks, Windows line endings, explicit retention, locked cleanup, atomic-update failure and failed-runtime/evidence retention. [Log](qa-session-python.log.txt). |
| Real Windows verifier | The exact current archive passes all seven references and retains 94 capture identities plus logs. Cleanup reports `removed`; the recorded staging path was independently checked absent. [Report](qa-session-windows-qa.json), [runtime log](qa-session-windows-runtime.log.txt). |
| Real Windows profiler | Sixteen one-second scenes and seven loads pass raw-data/workload validation at an actual 1920 × 1080 expanded/native buffer. Cleanup reports `removed`, its staging path was checked absent, and raw measurements/logs remain available. [Report](qa-session-profile-report.json), [raw data](qa-session-profile-raw.json), [log](qa-session-profile-runtime.log.txt), [startup binding](qa-session-profile-attempt.json). |
| Independent summary | The retained raw profile and evidence fingerprints pass the separate summary validator. [Diagnostic summary](QA_SESSION_PROFILE_SMOKE.md). This is lifecycle verification, not sustained-performance acceptance. |

Rendered captures remain under `dist/draft-study-improvements/windows-cleanup-qa/`;
raw profiling output remains under `dist/draft-study-improvements/profile-cleanup-smoke/`.
No application-content, medical-review, Mac-execution or public-release gate is
established by these tool checks.
