# Personal and private viewer trial

Use this guide for the user's own trial first. A later small group can use the same
tasks when the user chooses to invite them. No testers have been contacted. These
tasks assess controls and coverage understanding; they do not provide medical review.

## Record the tested version

Record the archive name and SHA-256 from the matching build report linked in
[private builds](NATIVE_BUILDS.md),
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
| Cancel a reference switch | With a reference already open, choose another and use Cancel opening. Repeat during a chest guide or route and in expanded anatomy, then retry the switch. | Were the original view, edits, study step and keyboard focus retained? Did the cancellation feedback make sense? |
| Identify the current reference | Recognise its body/source and that coverage is partial. | What did you assume was included? |
| Explore the body | Orbit, pan and zoom using the available input device. | Any jump, accidental selection or lost orientation? |
| Try fine zoom | Use a high-resolution wheel/trackpad if available. Compare small and large scrolls, reverse equal amounts, then compare keyboard +/- and pinch. | Is the amount comfortable, does reversal retain framing away from the limits, and do anatomy edits stay intact? |
| Recover orientation | Choose Camera views > Front, Back and From body left/right. Read the direction cue, then use Back. Try this with an isolated or moved part. | Is it clear that left/right belong to the body? Did camera rotation preserve your focus and anatomy edits? |
| Reveal and select the heart | Peel skin or use Show chest; selection focuses on its actual body position. | Is surrounding context useful? |
| Find a source ID | Search UBERON0002135 in HRA or FMA24474 in the bone study; press Enter. Check repeated names such as Dura mater. | Are source names readable and distinct? |
| Copy a source record | Copy the selected source record and paste it into a local text editor. | Are the reference, ID, coverage and review status clear? |
| Use actions beside anatomy | Open Actions beside a selected part, inspect/return, hide it and use the corner Actions button to show or restore it. Try Shift+F10, submenus and Escape in expanded anatomy. | Is the selected part clear? Any clipped menus, accidental camera motion or inaccessible hidden selections? |
| Identify a supplied part | Enable local labels or choose a component in the list. | Can you reach a small/covered part without a direct click? |
| Inspect and return | Inspect alone, choose a component, then Return to context. | Does the temporary view and return action make sense? |
| Move and recover | Enable Move, displace a part, use Undo/Redo and Restore selected. | Is original placement clear? Did navigation ever move anatomy? |
| Keep redo through an unchanged command | Move a supplied part and Undo it. Choose Show or Restore while it is already in that state, then Redo. Also try restoring a saved view with the same anatomy. | Is the undone movement still recoverable? Do real new edits correctly start another undo branch? |
| Undo during a held Move drag | While holding a Move drag, press Ctrl/Cmd+Z, then move the pointer without releasing. Release and start a fresh drag; repeat with Redo. | Did restoration stay in place until a fresh gesture, with Move still selected and one undo step for each real drag? |
| Mix mouse and keyboard movement | While holding a Move drag, press L (then Shift+L), continue moving without releasing, then release and start a new drag. Undo and Redo each action. Repeat a blocked step at the movement limit. | Did held motion stop at the key step, with each real drag/step independently reversible and blocked steps preserving Redo? |
| Switch mode during a held drag | While orbiting with the left button held, press M and keep moving without releasing. Release and start a Move drag; press M again while holding. | Did anatomy and camera stay at their switch-time positions until a fresh press, with the chosen mode clear? |
| Interrupt a pointer drag | During orbit/pan and Move, switch away from the app, release the mouse, return and move the pointer without pressing. Also focus anatomy search during a drag. Start a fresh drag and use Undo. | Did motion stop, selection stay put, and each deliberate Move gesture keep its own undo step? |
| Resume camera keys after a dialog action | Use Coverage > Explore supplied group, then press an arrow key. Restore a named view or previous quick save and repeat; try Restore after saving/discarding draft notes. Cancel a dialog as well. | Do successful actions focus anatomy without another click, preserving edits and notes? Does cancel return to the opening control? |
| Revisit anatomy | Select the heart/lung and use Back/Forward. | Were camera and inspection changes retained as expected? |
| Save two views | Give two different setups distinct names in Saved views. | Are reference and structure easy to distinguish? |
| Add study notes | Select each saved view, save different notes, and reopen them. Try Keep editing after closing an unsaved draft. | Did text stay attached to the right view? Were the choices clear? |
| Find a saved view | Search a name, note word, selected anatomy name or source ID. Toggle This reference in a mixed-reference library. Filter away a draft, clear search and return to it. Try Ctrl/Cmd+F, Enter and Escape at 130% text. | Were context/counts clear, drafts retained and actions reachable in a small dialog? |
| Reopen and restore | Close/reopen the app and restore a named isolated part. | Does Return to context still work? |
| Export a screenshot | Save a PNG through the native picker, reopen it and check the source/status footer. Cancel another export. | Any missing label, clipped credit, unclear overwrite or changed session? |
| Check a coverage gap | Open Coverage and inspect skeletal coverage for both HRA bodies. | Do counts look like a completeness claim? |
| Read Coverage with keys | At 130% text in a small window, use arrows to choose a group, Tab to reach the inventory, Page Up/Down to read it and Ctrl/Cmd+A to select its text. Close with Escape; reopen and Tab to Explore. If useful, copy selected text into your own editor. | Is all text reachable, focus clear and the original view preserved on close? Is the copied inventory understandable? |
| Explore the bone study | Choose the separate male study, find Right femur, inspect and restore it. | Is its lack of HRA/female alignment clear? |
| Use a smaller window | Repeat selection, Save/Restore and inspection return. | Any unreadable text, clipped actions or blocked anatomy? |
| Explore with the panels away | Expand anatomy with View or F11. Use Explore to toggle labels, inspect/return, save/restore a view and export a credited PNG. Escape dismisses an open menu before returning to the workspace. | Are selection, Move mode and action feedback clear? Can you keep exploring without reopening panels? |
| Choose rendering quality | In workspace View or expanded Explore, try Native, 75% and 50%, then return to Native. | Does navigation stay consistent? Are UI labels readable, and which setting is comfortable on this device? |
| Back up unfinished notes | Edit notes on two views, hide one with search, then Export all views without saving. Re-import the copy through preview. If another window has changed the library, try Save and then Export. | Does the copy include both drafts without changing the library or clearing the editor? Are the picker label and later separate note versions clear? |
| Read a study card | Select the heart, a valve and a lung. Open Read study card in workspace and expanded anatomy, try 130% text, select/scroll the text and close it. Follow a related-anatomy link, then press Enter. Repeat during a guide or route. | Are the text, reference, draft status and sources clear? Does focus stay useful and the original study/view remain intact? |
| Follow study links | Tab to a related structure, condition summary and source citation; activate with Enter. Read a citation in your browser and return to the app. If a launch failure occurs, read/select the fallback address and close it. | Are the links reachable and focus clear? Does returning preserve the study step? Is any fallback readable at 130% text size? |
| Use keyboard alternatives | Tab through actions; focus the teal-bordered 3D view and orbit/pan/zoom with keys; operate tree/search. | Is focus clear? Which action still requires a pointer? |

Also try the new [study workspace](STUDY_WORKSPACE.md) tasks:

- Follow all six Guided chest steps in both HRA bodies. Finish and check that your
  original edits/camera return; try the guide in expanded anatomy.
- Focus Next and press Enter through the chest steps. Check that focus reaches
  Finish at the end and returns to 3D after restoring. In Heart ↔ lungs, use Tab at
  the lung choices and Enter to follow either branch; retrace it with Previous.
- Read a heart/valve/lung card, follow a related-structure link, and open a source.
- Follow Heart ↔ lungs through each branch. Use Previous to change branches, read
  the lung/systemic coverage gaps, and finish to recover your starting view.
- With the 3D view focused, press M and try I/J/K/L/U/O, then Shift for fine steps.
  Undo/redo a step and check that typing in search never moves anatomy.
- Resize the window, close normally and reopen. Repeat while maximized, then restore
  the windowed frame. Check the result on another available display and record any
  misplaced controls or unexpected dimensions.
- Choose another reference, close normally and reopen. Check its window title and
  default anatomy view. Restore a named view when you want its exact inspection
  setup and notes. Check that canceling an unsaved-note close keeps the app open.
- Export named views/notes, import into a second local installation, inspect the
  compatibility preview and repeat the import to check duplicate handling. Try
  Page Up/Down, Ctrl/Cmd+A, Escape and Tab to the import actions at 130% text;
  check that reading or canceling leaves the library unchanged.
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
