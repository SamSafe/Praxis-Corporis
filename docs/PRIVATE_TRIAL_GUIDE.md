# Personal and private viewer trial

Use this guide for the user's own trial first. A later small group can use the same
tasks when the user chooses to invite them. No testers have been contacted. These
tasks assess controls and coverage understanding; they do not provide medical review.

## Record the tested version

Record the archive name and SHA-256 from [the build report](audit/native-build-report.json),
OS version, graphics device, screen resolution/scaling, and whether input uses a mouse
or trackpad. Use the actual ZIP that matches that record. Later source commits do not
retroactively validate earlier packages. Extract the complete archive before opening it.
See [native setup](NATIVE_BUILDS.md).

Record whether the app started, the first visible body/loading time, and any failure
message. Screenshot the relevant state for a reproducible bug. Screenshots and saved
views stay local; no reporting/upload service is installed.

## Core tasks

Try each task before reading the [controls guide](PROTOTYPE.md), then note whether the
guide resolves any confusion. Preserve useful failed attempts rather than silently
restarting. Repeat the HRA tasks for both female and male references.

| Task | Success to observe | Notes to record |
|---|---|---|
| Switch references | Watch the loading steps; wait for the new body before manipulating it. | Did the progress update, and was there a noticeable pause? |
| Identify the current reference | Recognise its body/source and that coverage is partial. | What did you assume was included? |
| Explore the body | Orbit, pan and zoom using the available input device. | Any jump, accidental selection or lost orientation? |
| Recover orientation | Choose Camera views > Front, Back and From body left/right. Read the direction cue, then use Back. Try this with an isolated or moved part. | Is it clear that left/right belong to the body? Did camera rotation preserve your focus and anatomy edits? |
| Reveal and select the heart | Peel skin or use Show chest; selection focuses on its actual body position. | Is surrounding context useful? |
| Find a source ID | Search UBERON0002135 in HRA or FMA24474 in the bone study; press Enter. Check repeated names such as Dura mater. | Are source names readable and distinct? |
| Copy a source record | Copy the selected source record and paste it into a local text editor. | Are the reference, ID, coverage and review status clear? |
| Use actions beside anatomy | Open Actions beside a selected part, inspect/return, hide it and use the corner Actions button to show or restore it. Try Shift+F10, submenus and Escape in expanded anatomy. | Is the selected part clear? Any clipped menus, accidental camera motion or inaccessible hidden selections? |
| Identify a supplied part | Enable local labels or choose a component in the list. | Can you reach a small/covered part without a direct click? |
| Inspect and return | Inspect alone, choose a component, then Return to context. | Does the temporary view and return action make sense? |
| Move and recover | Enable Move, displace a part, use Undo/Redo and Restore selected. | Is original placement clear? Did navigation ever move anatomy? |
| Revisit anatomy | Select the heart/lung and use Back/Forward. | Were camera and inspection changes retained as expected? |
| Save two views | Give two different setups distinct names in Saved views. | Are reference and structure easy to distinguish? |
| Add study notes | Select each saved view, save different notes, and reopen them. Try Keep editing after closing an unsaved draft. | Did text stay attached to the right view? Were the choices clear? |
| Reopen and restore | Close/reopen the app and restore a named isolated part. | Does Return to context still work? |
| Export a screenshot | Save a PNG through the native picker, reopen it and check the source/status footer. Cancel another export. | Any missing label, clipped credit, unclear overwrite or changed session? |
| Check a coverage gap | Open Coverage and inspect skeletal coverage for both HRA bodies. | Do counts look like a completeness claim? |
| Explore the bone study | Choose the separate male study, find Right femur, inspect and restore it. | Is its lack of HRA/female alignment clear? |
| Use a smaller window | Repeat selection, Save/Restore and inspection return. | Any unreadable text, clipped actions or blocked anatomy? |
| Explore with the panels away | Expand anatomy with View or F11. Use Explore to toggle labels, inspect/return, save/restore a view and export a credited PNG. Escape dismisses an open menu before returning to the workspace. | Are selection, Move mode and action feedback clear? Can you keep exploring without reopening panels? |
| Choose rendering quality | In workspace View or expanded Explore, try Native, 75% and 50%, then return to Native. | Does navigation stay consistent? Are UI labels readable, and which setting is comfortable on this device? |
| Use keyboard alternatives | Tab through actions; focus the teal-bordered 3D view and orbit/pan/zoom with keys; operate tree/search. | Is focus clear? Which action still requires a pointer? |

Also try the new [study workspace](STUDY_WORKSPACE.md) tasks:

- Follow all six Guided chest steps in both HRA bodies. Finish and check that your
  original edits/camera return; try the guide in expanded anatomy.
- Read a heart/valve/lung card, follow a related-structure link, and open a source.
- Follow Heart ↔ lungs through each branch. Use Previous to change branches, read
  the lung/systemic coverage gaps, and finish to recover your starting view.
- With the 3D view focused, press M and try I/J/K/L/U/O, then Shift for fine steps.
  Undo/redo a step and check that typing in search never moves anatomy.
- Export named views/notes, import into a second local installation, inspect the
  compatibility preview and repeat the import to check duplicate handling.
- Choose 130% text, hide a panel and change rendering quality; restart the app and
  check the remembered defaults.
- Open each spinal source study, inspect/return from a source mesh, and check that
  separate coordinates and the unresolved female metadata record are understandable.

The app currently has no disease visuals, reviewed routes, authored cutaways or
registered whole female skeleton. Record expectations for these as missing coverage;
do not score source geometry as a verified disease or pathway demonstration.

## Capture findings

For each failure, record the starting reference/selection, steps, expected outcome,
actual outcome, frequency, and screenshot/saved-view name if useful. Distinguish
“cannot complete”, “completed after help”, and “completed independently”. Explain
confusion in the user's own words. Do not include personal health information.

Keep unresolved issues in a versioned local trial record. A useful template is:

```text
Archive/hash:
OS/device/graphics:
Screen/scaling/input:
Task and completion level:
Starting reference/selection:
Steps:
Expected / observed:
Repeatable?:
Capture or saved-view name:
```

## Limits of a passing trial

Human mouse/trackpad, keyboard and comprehension evidence is separate from the
scripted native Windows checks. Mac execution needs a real Mac; the development-engine
embedded-pack check cannot substitute for it. Representative laptop performance,
accessibility acceptance, qualified anatomy/content review and public distribution
remain gates in [RELEASE_CRITERIA.md](RELEASE_CRITERIA.md).
