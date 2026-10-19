# Private update and rollback trial

Use this procedure with throwaway data to check the selected private build pair. The
current private candidate is identified in [native builds](NATIVE_BUILDS.md).
The recorded Windows cycle passes source `9e864a0` → `c86cfba` → `9e864a0` →
`c86cfba`: 10 normal launches, 28 views and 21 complete scene comparisons, with
unchanged geometry and save schema. See the [exact pair and evidence](audit/PRIVATE_UPGRADE_VERIFICATION.md).
Actual Mac, future migrations and installer acceptance are separate.

## Keep the data and app versions identifiable

Sources and `START_HERE.txt` identify stamped candidates. Retain the complete old
ZIP, its source/hash or build record, and the new ZIP. Earlier unstamped candidates
can be identified by their recorded archive SHA-256 and source revision.

These private versions share one user-data directory, separate from the app folder:

| Platform | Directory |
| --- | --- |
| Windows | `%APPDATA%\PraxisCorporisPrototype` |
| macOS | `~/Library/Application Support/PraxisCorporisPrototype` |

The project selects Godot's custom user-data directory and this exact name.
[Godot data-path documentation](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
describes the platform locations. On Windows, paste the path into File Explorer's
address bar. On Mac, use Finder → Go → Go to Folder.

The main files are `saved_views.json` (named views and notes), `saved_view.json`
(previous quick save), `preferences.json`, `window-state.json` and
`reference-state.json`. Keep available `.bak` and recovery copies too.

## Before switching versions

1. In Saved views, save unfinished notes. Export all views to a separate backup
   location. Export includes unfinished drafts when saving is unavailable; keep
   that copy distinct from the active library.
2. Close every running copy normally, including an older app version.
3. Copy the complete user-data directory to a dated backup folder. Keep this
   snapshot and the exported JSON unchanged throughout the trial.
4. Extract the new ZIP into a separate app folder. Keep the previous app folder
   available. Windows needs its companion `anatomy.pck`; the Mac app carries anatomy
   inside its bundle. Follow the existing private launch guidance.
5. Open only the new version. Confirm its build ID/source against the selected
   candidate. Check the remembered window/reference and preferences.
6. Restore a named view. Check the reference, selection, camera, hidden/faded parts,
   movement offsets, isolation/Return to context and labels. Read multiline notes
   containing characters such as `Café λ 🫀`. Check several references.
7. Save a new throwaway view/note, close normally, reopen and check it again.
   Record the tested build IDs, failed steps and exact messages.

## Rollback and recovery

Close all app versions and make a second dated copy of the current user-data
folder before attempting rollback. Preserve newly written notes and the earlier
backup as separate copies.

For a qualified compatible pair, reopen the older app with the working test data
and repeat restoration/note checks, then reopen the newer app. The recorded native
cycle verifies seven representative views for the specified Windows pair. It does
not establish compatibility with future changed schemas or reference geometry.

If the older app rejects the data or the trial fails, close it. Keep the failed
working folder for diagnosis. Restore a copy of the pre-update backup as the active
user-data directory, then reopen the matching prior app. This returns to the saved
point; notes written later remain in the separately retained folder/export.

No automatic updater, data migration, public distribution or upload is supplied by
this procedure. A release still needs actual device acceptance and a defined
version/signing/support policy.
