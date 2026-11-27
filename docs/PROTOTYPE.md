# Run the private anatomy prototype

The viewer uses real, separate HRA male and female reference samples inside
one continuous scene. It is a partial atlas with medical review pending. Draft
study cards (247) and 173 condition summaries ([body study content](BODY_STUDY_CONTENT.md))
provide reference locations; pathological geometry is unavailable. Detailed source findings are in [the sample audit](audit/HRA_SAMPLE_FINDINGS.md).

The female and male bodies also carry later HRA organs (breasts, palatine tonsils,
spinal cord and vertebrae) and parts traced from the same donors' Visible Human CT:
parotid glands, stomach, oesophagus, thyroid, adrenal glands, ribs and costal
cartilages, sternum, gluteal, iliopsoas and deep back muscles, and in a second round
the tongue, mandible, jaw, neck, chest, back and abdominal wall muscles, diaphragm,
shoulder bones and (female) humeri, submandibular glands and hyoid
([parotid audit](audit/VHP_PAROTID.md), [CT parts audit](audit/VHP_CT_PARTS.md)).
Structures no body models (scrotum, vulva, adenoids, lingual tonsils) have text-only
cards that search lists as "No 3D model".

A separate **complete male body** (BodyParts3D v4.0, every source mesh) adds the
organs, skeleton, muscles and vessels the HRA bodies lack, such as the stomach,
esophagus, diaphragm, spinal cord and glands. It is not aligned to the HRA bodies;
choose it from the reference menu. See [revision 7](BODY_STUDY_CONTENT.md#revision-7-the-complete-male-body).

The [study workspace guide](STUDY_WORKSPACE.md) covers portable saved views/notes,
the six-step guided chest exploration, the draft study cards, text sizing and
remembered preferences, and four separate spinal source studies.

The selected-part Actions menu shares the workspace inspection, label, visibility,
Move, restore and undo/redo controls. Visibility and history use smaller submenus;
visibility changes are unavailable while inspecting alone. Opening or dismissing
the menu preserves selection and camera. The menu closes when reference loading,
selection or display layout changes. Right-drag continues to pan. Pathological geometry and physiological simulation remain pending.
The guided chest teaching layout is available through its separate guide controls.

## Requirements and setup

For the generated Windows/Mac packages, use [NATIVE_BUILDS.md](NATIVE_BUILDS.md).
They include the runtime and anatomy and require no development tools.
The instructions below are for running/editing the source project.

Use Python 3.10 or newer and
[Godot 4.7.2 Standard](https://godotengine.org/download/archive/4.7.2-stable/).
The .NET edition is unnecessary for this GDScript project. Windows and macOS are
the target platforms; the current development checks run on Linux.

From the repository folder, run:

```sh
python3 tools/fetch_assets.py
godot --headless --path . --script tools/prepare_assets.gd
godot --path .
```

On Windows, use `python` if that is your Python executable. Substitute the full path
to the downloaded Godot executable for `godot` if it is not on PATH. Alternatively,
open project.godot in the Godot editor and press F5 after preparation.

The downloader obtains approximately 155 MB of pinned anatomy GLBs and verifies
their exact byte counts and SHA-256 hashes. Existing verified files are reused.
Sources, hashes and licence records are in
[source_manifest.json](../content/source_manifest.json). It sends no project files
or user data to the source repository.

Preparation imports both sources, excludes sampling-site roots, and writes local
compiled geometry scenes in assets/prepared/. Version-2 caches retain the source
mesh data and omit picking colliders; the viewer builds exact triangle picking
nodes from precomputed shapes loaded in small groups. Offline preparation stores
these shapes separately with an 80,000-triangle/32-mesh budget per group. Loading
yields between groups, and node/material setup yields after about 8 ms or 40 meshes.
One mesh is an indivisible operation, so this budget is not a maximum-pause guarantee.
The preparation tool can migrate the previous pinned cache without a fresh GLB import.
The first raw import is expensive; preparation can take several minutes. Subsequent
launches reuse the scenes. A source-hash or engine-version change invalidates the
cache. Cache filenames include the geometry format version. The project folder must
be writable during this development preparation.
Private packages bundle the prepared scenes read-only; they never import or write
geometry into the installation folder. Full installer/update handling remains work.

Reference loading checks the pinned source in a file-reading worker and reads prepared
scenes through Godot's threaded resource loader. The loading row names the current
step; its bar measures that step only. Selection preparation yields between mesh
batches. The previous anatomy stays visible while a replacement is checked, with
anatomy/camera controls paused to preserve the current exploration. A failed read or
invalid source mapping restores the controls and keeps the existing scene, camera,
labels, isolation, movement settings, edits and both histories.

Once a reference is open, **Cancel opening** keeps that exploration when a
replacement is pending. It appears in both workspace sizes. A pending read is
allowed to finish before its result is collected and released; cancellation can
therefore take a moment. Canceled staging never replaces the current scene, and
keyboard focus returns to anatomy. Chest/route progress also resumes at the same
step after cancellation or a failed switch. A completed switch ends the study and
restores its original viewing controls.

Scene instantiation and the final replacement still run on the main thread and can
cause a short pause. Keeping both references temporarily uses more memory. The first
raw development import remains expensive and should be run as preparation before
opening the app; desktop packages include prepared scenes.
[Godot background loading](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html).

The GLBs, compiled scenes and .godot/ directory are excluded from Git. After fetching
and preparing, exploration and saves work offline. No login or network connection
is used by the viewer.

The [fresh-source verification](audit/SOURCE_CHECKOUT_VERIFICATION.md) checks this
workflow without existing engine or geometry caches on the development host,
including the optional studies. Mac execution is deferred.

### Mac source checkout

Mac testing is deferred until the user's future checkout. After cloning, open
Terminal in the repository folder. Install Python 3.10 or newer and Godot 4.7.2
Standard as above. If Godot is in Applications, run the following; adjust
`praxis_godot` if you unpacked it elsewhere:

```sh
praxis_godot="/Applications/Godot.app/Contents/MacOS/Godot"
git rev-parse HEAD
"$praxis_godot" --version
python3 tools/fetch_assets.py
"$praxis_godot" --headless --path . --script tools/prepare_assets.gd
"$praxis_godot" --path .
```

Keep the printed Git revision and engine version with any later observations.
The source project shows a development-checkout identity, rather than the build
ID of a previously exported archive. Export templates are needed only to create
desktop packages, not to run this source project. The first fetch needs network
access and the first preparation can take several minutes.

The commands above prepare the two HRA body references. To also reproduce the
separate bone study and four spinal studies available in the private packages,
close the viewer, then run:

```sh
python3 tools/fetch_assets.py --manifest content/bodyparts3d_source_manifest.json
python3 tools/build_bone_study.py assets/bodyparts3d/raw
python3 tools/fetch_assets.py --manifest content/spinal_source_manifest.json
"$praxis_godot" --headless --path . --script tools/prepare_assets.gd
"$praxis_godot" --path .
```

The study catalogues are already versioned. Preparation discovers studies whose
geometry is present; leaving these optional downloads out keeps the two HRA body
references usable. These studies remain separate and unregistered to either body.
Use the [Mac acceptance guide](MAC_ACCEPTANCE.md) when ready; report the actual
checkout revision and only the references prepared in that checkout.

## Controls

| Action | Control |
|---|---|
| Orbit | Primary-button drag in the 3D view. A quick flick keeps the view turning briefly after release; pressing again stops it. |
| Pan | Shift + primary drag, right/middle drag, or supported trackpad pan gesture. |
| Zoom | Scroll wheel or supported pinch gesture. The wheel zooms towards the point under the pointer. |
| Focus a part | Double-click it in the 3D view to select it and bring it into focus. |
| See a selected part | Selecting an internal part draws the layers in front of it faded: the skin for any internal part, and also muscle, bone, ligament and cartilage for an organ, vessel or nerve. Faded layers are click-through. This is display only; selecting the skin, or clearing the selection, shows every layer again, and saved views and undo are unaffected. |
| Camera motion | Camera moves ease into place. View > Preferences > Smooth camera motion turns easing, gliding and pointer zoom off for instant movement. |
| Keyboard camera | Tab/click to focus the 3D view (teal border). Arrows orbit; Shift-arrows pan; +/- zoom; F fits selection; Home shows the body. |
| Orient the camera | Camera views offers Front, Back, From body left/right and angled Above/Below around the current focus. The direction cue rotates with the camera; L/R refer to the body's sides. |
| Find a source record | Ctrl/Cmd+F or View/Explore > Find anatomy opens search. Search names, source names, ontology IDs or catalogue IDs; Enter selects the first ranked result. Escape clears the query, then returns focus to 3D. |
| Find a condition | Type a condition's name in the same search; matching conditions offered on this body follow the anatomy results and open their draft text. |
| Browse all source records | Turn on List view. Previous/Next pages through every catalogue record, 100 at a time. Select a row to focus it; turn List view off to return to the hierarchy. |
| Read study text | Read study card opens selectable draft text and source addresses. Explore offers the same action in expanded anatomy when a card exists. Close/Escape preserves the view. |
| Trace source identity | Copy source record in the details panel copies the selected record and reference fingerprint. |
| Select and focus | Click visible geometry or a surface label, choose a tree item, or select a search result. |
| Actions beside anatomy | Select a part, then choose Actions beside its label. Shift+F10 or the Menu key opens it from the focused 3D view. Hidden/faded/off-screen selections keep a corner button. |
| Browse systems and parts | Expand the anatomy tree; parent groups select their descendant meshes. |
| Browse local components | The Supplied parts list follows the current organ/group and uses the same selection as the main tree. |
| Inspect a covered part | Select it, then Inspect alone. Further selections follow this temporary view. |
| Return to surroundings | Return to context restores the selection/camera from before inspection and preserves current body edits. |
| Reveal deeper anatomy | Peel away skin; Hide/Fade/Show apply to the current selection. Choosing a structure that other anatomy covers from the current view turns the camera to the nearest of 26 directions around the body, within a quarter turn, that shows it. When it is enclosed from every direction, the camera takes the most open one and draws the parts in front of it faded while it stays selected (from the current direction unless another within a quarter turn has at most half as many in front); the status line names them. Selection takes well under 0.1 s. The fading is display only (stored visibility, saved views and undo are unchanged), and Back restores it with the view. A prepared cut-away, Inspect alone or a cut-away view leaves the camera put and the status line names what covers the structure. |
| First chest view | Show chest hides skin and fades lungs around the selected heart. |
| Labels | Selection label is on by default. Enable Local part labels; Maximum labels controls density from 1 to 12. |
| Cut-away view | In the details panel, turn on Cut-away view and drag its depth slider: anatomy nearer than a plane facing you, from 15 cm in front of the focus point to 15 cm beyond it, is not drawn. Clicks and labels reach what the cut exposes. |
| Prepared cut-aways | Under Show chest, Prepared cut-aways opens the heart chambers from the front, the brain at the midline from the left or in a side-to-side section from the front, the left eye from the side, or the right kidney from behind. It selects the structure, turns the camera and sets the cut. Back returns the previous view; turn off Cut-away view to remove the cut. |
| Previous/next view | Back/Forward or Alt + Left/Right outside text entry. |
| Move anatomy | Enable Move selected, then primary-drag in the viewer's camera plane. Shift-drag still pans. |
| Restore | Restore selected or Restore all recovers original transforms and visibility. |
| Undo | Undo button or Ctrl/Cmd + Z outside text entry. |
| Redo | Redo button or Ctrl/Cmd + Shift + Z outside text entry. |
| Original position | Show original positions toggles faint blue, non-selectable copies of moved anatomy at its baseline location. |
| Leave Move mode | Escape or Whole body returns to navigation and preserves inspection changes. |
| Body reference | Select Female reference or Male reference; shared canonical selections are retained where mapped. |
| Save/load | Saved views opens named local exploration setups with Save current view, Restore, Rename and Delete. A successful Restore or previous quick save returns keyboard focus to anatomy. |
| Find a saved view | Search its name, notes, reference or selected anatomy name/source ID. This reference narrows the library; the heading shows matches out of all views. |
| Study notes | Select a saved view, type your observations/questions, then Save notes. |
| Coverage | Coverage opens the technical inventory and known gaps. Arrows choose groups; Tab reaches selectable text and Explore; Page Up/Down scroll; Escape closes it. Explore returns focus to anatomy for camera keys. |
| Workspace panels | View toggles the anatomy explorer and structure details independently; Keyboard controls opens the shortcut reference. |
| Expanded anatomy | View > Expand anatomy or F11 fills the window with the live anatomy view. Escape or Return to workspace brings the panels back. |
| Expanded controls | Explore keeps labels, focus/whole body, Inspect alone/Return to context, Move, Undo/Redo, Saved views, Screenshot and keyboard help available. Selection, Move mode and action feedback remain visible. |
| Rendering resolution | View chooses Native, 75% or 50% screen-pixel resolution. Lower settings reduce graphics load while keeping all geometry and sharp UI labels. This is a remembered device preference, separate from saved anatomy views. |
| Screenshot | Screenshot captures the current workspace and opens a PNG save dialog; source credits and prototype status are added below the image. |

Keyboard camera controls work only while the 3D view has focus. Search/list arrows
and text editing keep their ordinary behaviour. Camera keys leave explicit Move mode
and preserve inspection changes. The focused scene has a teal border and a keyboard
hint below it. Alt-history and inspection undo/redo remain available. This supplies a
keyboard camera route. Precise keyboard movement is also available: M toggles Move;
I/J/K/L move up/left/down/right in camera coordinates; U/O move toward/away. A press
moves 5 mm, or 1 mm with Shift. Held repeats are ignored and each step supports Undo.
A movement key ends any held pointer drag; start a fresh drag to continue. Each
completed drag and keyboard step remains independently reversible.
Tab reaches study, related-anatomy/condition and route-source links. Enter opens
source links in the browser. If the system reports a launch failure, a selectable
address remains available in the app; closing it returns focus to the link.
Assistive-technology and human accessibility acceptance remain open.

Wheel zoom uses the amount reported by the input device, so fine scrolling makes
smaller changes. Equal opposite wheel amounts or keyboard zoom steps return to
the same framing before reaching the near/far limits. Pinch uses its reported
positive scale factor; invalid factors leave the view unchanged. Keyboard and
pinch zoom preserve the focus point; wheel zoom with smooth motion on moves the
focus point towards the pointer, and with smooth motion off preserves it. Zoom
keeps anatomy edits and inspection history.

Smooth motion only changes how the camera is drawn. The stored view (focus point,
distance and angles) changes immediately, so saved views, Back/Forward and
picking use exact values. Scripted checks and the native verification modes
always use instant movement.

**Appearance.** Parts are drawn in illustrative tissue colours and finishes chosen
from their names: for example dark red-brown liver, ivory bone, pearly cartilage,
red arteries and blue veins. These are display choices, not medical data, and
the source geometry, labels and IDs are unchanged. A part the rules do not
recognise keeps a softened version of its source colour. The selected part is
tinted amber with a bright rim, so it keeps its shading. A warm key light, a
cool fill light and a back light give depth, over a vignetted backdrop. There are
no cast shadows: they added about 70% to frame time in testing.

Switching to another app/window or focusing another control stops the current
pointer drag. A lost mouse release or canceled click also stops it. Your existing
camera position, selection and anatomy edits remain; Undo still reverses a Move
gesture. Press again to begin a new drag. The Move toggle keeps its chosen setting.

Named camera views retain the focus point, distance, selection, labels, isolation
and anatomy edits. They leave explicit Move mode and participate in Back/Forward
history. Above/Below stay slightly angled. The source-direction cue is fixed to the
reference frame, so moving anatomy aside does not change it. Labels avoid this
control's rectangle. Direction metadata must match the actual reference fingerprint;
otherwise the cue explains that orientation is unavailable and named views are disabled.
[Source checks and limits](audit/REFERENCE_ORIENTATION.md) document the geometry evidence;
this does not establish qualified anatomical review or alignment between bodies.

Hiding panels gives more width to the same scene without changing selection, camera,
labels, isolation or body edits. The top View menu remains available to reopen them.
Both View and expanded Explore can receive Tab focus and open with Enter. Escape
dismisses an open menu first. The expanded feedback panel has a teal border while
the anatomy view has keyboard focus. Explore and workspace controls share the same
label and resolution settings; inspection actions pause while another reference loads.

The 3D buffer follows the display's actual pixel area, including window scaling,
while labels and controls remain in UI coordinates. Camera picking and drag input
convert between those coordinate systems. Expanded Native view covers the full
client window; a 1920 × 1080 window produces a 1920 × 1080 3D buffer. Very large
buffers are limited to 8192 pixels per dimension, with their aspect ratio retained.
Anatomy, camera state, inspection history and the live 3D world survive display-mode
changes. Window aspect expansion uses available space without letterbox borders.
Panel visibility stays as set while switching references/restoring views and is remembered
across launches. Panel layout is separate from saved anatomy snapshots.

Screenshot export includes the current window, visible labels and panels, with a
source/status footer rendered inside the PNG. Hidden side panels remain hidden, while
the footer still identifies the source, licence links, display modifications and review
status. The separate bone study retains its exact creator credit and alignment limits.
The save dialog prefers the native OS picker, allows PNG only and asks before replacing
an existing file. Capturing or cancelling does not change anatomy or saved views. If
the body/camera changes during capture, the app asks you to try again instead of
attaching the wrong source context. Images remain local.

Faded structures are click-through; hidden structures have no active pick collision.
Choose either in the tree and use Show to make it directly selectable again.
Viewer undo/redo restores visibility and inspection displacements, not camera navigation.
Visibility and Restore add an anatomy undo step only when a mesh state changes.
Applying the same saved anatomy also preserves existing undo/redo. A real change
still creates a step and clears redo from the old branch. Restore all retains its
return-to-context behavior and the separate navigation history.
Movement records history only when an offset changes. An ineffective movement at
the displacement limit keeps Undo/Redo; a drag that first reaches a limit can
reverse into available space with one undo step. Undo/Redo ends the active pointer
gesture and keeps Move selected, so a fresh drag continues deliberately.
Switching Move on or off ends a held gesture as well. The old held button cannot
turn an orbit into a move, or a move into an orbit; press again to continue in the
chosen mode.
New inspection edits discard redo history. Original-position overlays are separate
from anatomy and do not intercept clicks; restoring a part hides its overlay.
Ordinary selection of a hidden structure focuses its position without revealing it.
Inspect alone explicitly reveals supplied geometry temporarily, as described below.

Back/Forward restores selection, camera position, the relevant local label set and
temporary inspection mode, including its return action. It exits Move mode.
It preserves current visibility, displacements and inspection undo/redo. Manual orbit
and pan are captured when leaving a view. Choosing another structure after going
back discards the old forward branch. History holds up to 40 previous views per body
and is not saved across launches. Whole body records a return point while preserving
inspection changes.

Local sets use the current source hierarchy, retaining an organ's context when you
select one of its components. Both hearts have 14 supplied component meshes. Labels
are clickable, use leader lines and avoid overlapping each other or leaving the
viewport. Leaders end at actual first-hit opaque surfaces belonging to the named
structure. In the ordinary body view, covered, hidden and faded components are omitted; the tree remains the
parallel route to select them. Faded layers are transparent to label ray queries as
well as clicks. Whole body clears the local context; changing organs replaces it.
Thin parts may remain unlabelled if the bounded surface search cannot find a hit.
Broad system label sets are not implemented.

Surface searches run at most ten times per second, with a 160-ray budget per update
and at most 64 supplied parts in a local set. These limits bound work but do not
establish a target-device performance result. Long names are shortened in pills and
available in their tooltips and the details panel. The details panel scrolls when
needed so the viewport and bottom controls remain available. Keyboard focus follows
the scrollable panel's controls using
[Godot's ScrollContainer](https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html).

**Cut-away view.** The cut is the camera's near clipping plane moved to a set
depth from the focus point, so it always faces you and follows orbit and zoom at
that depth. It is a display setting, like the rendering resolution: it changes no
selection, visibility, positions or histories, saved views do not record it, and
it stays as set while switching references. The cut faces are open. No caps,
cut-surface tissue or interior anatomy are created, so hollow organs show their
inner walls and solid parts show their far inside surface. A depth nearer than the
camera leaves the view uncut. The expanded view's Explore menu does not offer it;
return to the workspace to change it.

**Prepared cut-aways.** Each prepared cut is a structure, one of the six
body-direction camera views and a cut depth (`scripts/prepared_cuts.gd`). Opening one
ends any inspection, selects the structure, turns the camera and sets the cut-away
view; the selection and camera change go into Back/Forward history, and anatomy
visibility and positions are not changed. A reference lacking the structure or
checked body directions shows the item disabled. They are the same uncapped cut at
a chosen place, not validated sections: what shows is the supplied surfaces the cut
exposes, and their descriptions are draft text pending review.

## Find structures and source records

Search applies to the current reference. It checks display names, original source
names, ontology IDs and catalogue IDs. Name searches accept multiple words in any
order. Exact names/identifiers rank ahead of prefixes and other text matches. For
example, `UBERON:0002135` or `UBERON0002135` finds the supplied mitral valve in either
HRA body; `FMA24474` or `FJ3365` finds Right femur in the separate bone study. Case,
whitespace and common identifier separators are normalized for lookup. Search uses
only names and identifiers present in the catalogue.
Unicode spaces, including nonbreaking and narrow nonbreaking spaces copied from
other text, work like ordinary spaces. A query containing only spaces shows the
chosen browsing mode: hierarchy by default, or the paged list.

**Conditions by name.** Search also lists the draft conditions offered on the current
body whose title contains every word of the query, after the supplied records and
any text-only study cards: for example `aortic stenosis`, `asthma` or
`ovarian cyst`. Each row reads *Condition* and names its reference anatomy.
Choosing one opens the condition's draft text and sources without changing the
view; **Inspect reference anatomy** then isolates its supplied reference location.
Conditions whose anatomy the current body lacks are not listed, so `prostate` finds
prostate conditions on the male body only. Condition titles are not aliases for
anatomy, and the result count includes them.

Results show the display label and source name on separate lines. Repeated labels
remain distinct records; their original left/right names or file IDs stay visible.
Long source names retain their suffix when shortened, and the tooltip contains the
complete name, ontology, catalogue ID and recorded hierarchy. The details panel also
shows the complete source identity. This hierarchy is the source's grouping information.

Click a result to select/focus the actual geometry, or press Enter in the search field
to select the first result and move keyboard focus to the list. Filtering leaves
camera, selection and inspection history unchanged until you select a result. Search
selection uses the same isolation, labels and Back/Forward behaviour as the tree.
Clearing the query restores the chosen browsing mode and current selection. Search caps at
100 results and reports the full match count; the empty state identifies the reference
and suggests another name/source ID. Switching references searches that body's records.
A failed body load retains the prior index/results.
See [Unicode search verification](audit/SEARCH_SPACING_VERIFICATION.md) for the
copied-space reproduction and checks across all seven references.

**List view** offers every catalogue record, including source grouping records,
in alphabetically ordered pages of 100. Previous/Next changes the page without
selecting or moving anatomy. Search still uses its ordinary ranking; clear it to
return to the chosen page. Changing references starts at the first page. The mode
is temporary for this window and is separate from saved anatomy snapshots.
The native list also provides an alternative to hierarchy rows that the pinned
Windows accessibility backend does not expose. Search, saved-view fields and core
controls have explicit accessible names/descriptions. Native API checks do not
establish screen-reader usability or conformance.

**Copy source record** copies the selected label, original source name, ontology,
catalogue ID, reference identity/hash, supplied mesh count, coverage notice and draft
review status as plain text. Copying happens only when you press the button. It
includes no study notes or anatomy changes and does not contact a service. Native
clipboard acceptance remains part of the private device trial.

## Inspect supplied parts

Select Heart in the tree or use Show chest. The Supplied parts panel lists the
source's grouped chambers, papillary muscles and valves. Select a component in
either list, then choose Inspect alone. You can also inspect the whole heart first
and select individual parts while that view is active.

Inspect alone hides surroundings and temporarily renders the selected supplied
meshes opaque, including meshes currently hidden/faded in your ordinary view. They
remain in the same scene at their current body coordinates. It does not create
new interior surfaces, tissue, caps, a cutaway or a separation layout. Source labels
and geometry remain draft imports pending review.

The temporary mask is separate from the stored visibility and displacement state.
Labels, picking and original-position overlays follow the mask. The organ's local
part list stays available when selecting its components. Show/Hide/Fade and skin
reveal are disabled while inspecting alone; Return to context exposes those ordinary
controls again. Movement, undo/redo and Restore selected still work during inspection.

Return to context is above the viewport and remains accessible while the details
panel scrolls. It restores the prior selection, camera and label context, preserves
edits made during inspection, and leaves Move mode. Whole body and Show chest remove
the mask; Restore all removes it and resets visibility/displacements. Selecting
another structure during inspection makes the mask follow that selection, retaining
the initial return view. Body switching clears temporary inspection.

Save/load retains the mask and a validated return view, so reopening an isolated
part keeps a working Return to context action. Missing parts, a mismatched isolated
selection or malformed return camera/context are rejected before switching bodies
or changing the session. Older saves without these optional fields load in the
ordinary body view.

## Saved views

Import/export and compatibility-preview controls are described in the
[study workspace guide](STUDY_WORKSPACE.md#portable-saved-views).
In the import preview, Page Up/Down scroll the selectable text, Ctrl/Cmd+A selects
it, Tab reaches the actions, and Escape cancels without changing the library.

Open **Saved views**, enter a name, and choose **Save current view**. The library
keeps up to 200 named setups on this computer. Select a view to see its reference
and structure, then **Restore**. Change its name in the field and choose **Rename**;
deletion requires a second click on **Confirm delete**. Names must be distinct,
including when only letter case differs. Saving creates a new view rather than
overwriting an existing one. Restore validates the complete snapshot before changing
the body. Missing content or a different geometry hash leaves the session untouched.

Each saved view can hold your own multiline study notes. Save the view first, select
it in the library, type observations or questions under **Your study notes**, then
choose **Save notes**. Notes are plain local text, up to 10,000 characters per view;
they do not modify the body snapshot or provide authored disease information.
Creating another view starts with empty notes. Selecting a different view preserves
any unsaved drafts until you return to them.
The note editor's Undo/Redo applies to the selected saved view. Switching views
starts fresh editor history with one cursor at the beginning and no selection,
including when both notes have identical text. Filtering, renaming or saving the
same selected note keeps its cursor positions and Undo/Redo history.

Search the library by view name or note text, including drafts. **Ctrl+F** focuses
search, **Enter** selects a matching row, and **Escape** clears a nonempty focused
search. Unicode spaces work like ordinary spaces; stored names and notes retain
their original text. Filtering preserves drafts and does not restore anatomy. The
result count includes the full library; clear search to return to every view. The
dialog's action buttons stay visible while its content can scroll at compact sizes.

Closing Saved views, restoring a view/older quick save, or normally closing the app
protects unsaved drafts with **Save notes**, **Discard notes**, or **Keep editing**.
Save writes every pending draft in one library update before continuing. A failed
write leaves the dialog and typed text open. Drafts live in memory until saved; a
forced process stop or crash loses work that has not been saved or exported. **Export all views** includes
unfinished notes in a separate JSON copy and leaves them open, including drafts
hidden by filtering. It requires no Save/Discard decision, so work can be backed
up when a newer library blocks Save. The active library and its backup stay intact. Deleting a view also deletes its
notes after the existing explicit confirmation. Older libraries without notes
remain readable without being rewritten just by opening them.

The optional [BodyParts3D bone study](audit/BODYPARTS3D_FINDINGS.md) provides a separate
male source reference with 203 mesh files. It is available in the reference selector
when prepared/bundled. It retains its own coordinates, source coverage and notices;
it is unregistered to either HRA body and does not fill female skeletal gaps. Skin and
chest controls are disabled for this source. Existing HRA references remain intact.
Its saved views include a geometry hash, and incompatible/missing study sources are
rejected before changing the current view. Older HRA schema-1 saves remain compatible.

Body switching restores that body's original inspection state and clears undo/redo
and navigation history.
Each view records body, selected ID, camera, labels, original-position display,
local label context/density, temporary inspection/return view, visibility and
displacements. Earlier schema-1 saves remain compatible through defaults for optional
fields. General Back/Forward history is not saved across launches.
The local library is `user://saved_views.json`, outside the installation/project.
Numbers use full precision, and writes use a temporary file plus one previous-library
backup (`.bak`). Invalid formats or failed writes preserve the known library. If the
main file is damaged/missing and the backup is valid, **Recover previous library**
restores it; a damaged original is retained as `.damaged`, or `.damaged-<unique ID>`
when an earlier copy already exists. The result message names the preserved file.
If the main file changes after the recovery offer, recovery stops and asks you to
close and reopen Saved views. A healthy loaded library cannot be rolled back through
this action. Malformed JSON in libraries, imports or backups produces the app's
readable error message without an engine parser error. Malformed UTF-8 and raw NUL
bytes are also rejected before decoding; known notes and damaged-file bytes remain
intact, while valid Unicode and BOM files remain supported. Recovery returns the
previous version, which may omit the most recent edit. A stale open library detects
external file changes and asks you to close/reopen before editing. This is local
storage, without cloud sync or a cross-process transaction service.

The older `user://saved_view.json` quick-save slot is kept intact. When present,
**Restore previous quick save** appears in the window. Older HRA schema-1 views retain
their compatible defaults. Portable JSON import/export is available through Saved
views; general schema migration remains future work. Saved notes use the same
backup and stale-file protections as the views. Text editing undo belongs to the
note field and leaves anatomy edits untouched.

## Actual scope and limitations

Coverage in the top bar lists supplied system groups for both bodies, compares their
source mesh/group counts and keeps known gaps at the start of each entry. Other /
unestablished coverage has no exploration shortcut. The inventory does not assign
completeness percentages or promote draft labels to medical review. Its notes are
bound to the pinned catalogue/source commit in
[coverage_notes.json](../content/coverage_notes.json).
The group list receives focus when Coverage opens. Use arrows to choose a group,
Tab to reach its inventory text, Page Up/Down to scroll, and Ctrl/Cmd+A to select
the text. Tab also reaches Explore and Close. Escape closes the window even while
text is selected, preserving the current anatomy view.

- Both samples provide surrounding body context and separately named organ geometry.
- The HRA bodies have no skull, limb bones above the femur, or full muscle and peripheral-nerve
  sets; the complete male body supplies those for one separate, unaligned person.
- Source labels, grouping and ontology fields remain draft import metadata.
- Heart parts exist, but caps, validated sections, reviewed interiors and tissue
  explanations are not implemented. The cut-away view, prepared cuts included, is an uncapped,
  camera-facing near-plane cut, not a prepared section.
- Draft condition summaries for 173 conditions and an unreviewed conceptual
  heart–lung route are available. Pathological geometry, disease comparisons, injury simulation and
  physiological animation are not implemented.
- Source labels remain unreviewed. Broader system sets, authored label anchors,
  comprehensive visibility sampling and fully stable layout during motion remain work.
- Movement is an inspection displacement with optional original-position overlays.
  Guided chest adds a temporary chamber teaching layout; transformation handles
  remain future work.
- No signed Windows or Mac installer, minimum-hardware claim, qualified medical
  review, accessibility acceptance or public-release readiness is established.

## Build identification

Open **Sources** to read the private version/build ID, source revision, source-input
fingerprint, engine, runtime platform and content-pack ID. `START_HERE.txt` carries
the same identity for launch failures. Include the build ID with trial observations.
A development checkout identifies itself without claiming an exported build ID.
These fields identify the candidate; medical review and release acceptance remain
separate. [Private build identity](audit/BUILD_IDENTITY_VERIFICATION.md).

## Verification

Static anatomy reuses its last rendered frame until the camera, model appearance
or display changes. Keep those invalidation paths complete when adding controls;
animated materials or geometry would require a corresponding rendering policy.
The redraw check compares cached images with continuous rendering on the native
Windows build and checks the event paths headlessly across all seven references.
Label placement also reuses unchanged results. Keep its camera/display/settings
and overlay inputs complete; model appearance and theme changes invalidate it.
Explicit `update_labels()` still solves immediately and leaves a periodic check
after physics/layout settles. The label-reuse check compares periodic placement
with a fresh solve and validates real source-mesh hits.

```sh
python3 tools/fetch_assets.py --verify-only
python3 -m unittest discover -s tests -v
godot --headless --path . --script tests/build_identity_smoke.gd
godot --headless --path . --script tests/accessibility_input_smoke.gd
godot --headless --path . --script tests/anatomy_list_smoke.gd
godot --headless --path . --script tests/search_spacing_smoke.gd
godot --headless --path . --script tests/scene_render_smoke.gd
godot --headless --path . --script tests/label_reuse_smoke.gd
godot --headless --path . --script tests/viewer_smoke.gd
godot --headless --path . --script tests/exploration_smoke.gd
godot --headless --path . --script tests/part_inspection_smoke.gd
godot --headless --path . --script tests/coverage_smoke.gd
godot --headless --path . --script tests/study_reference_smoke.gd
godot --headless --path . --script tests/keyboard_workspace_smoke.gd
godot --headless --path . --script tests/scene_display_smoke.gd
godot --headless --path . --script tests/orientation_smoke.gd
godot --headless --path . --script tests/part_actions_smoke.gd
godot --headless --path . --script tests/loading_smoke.gd
godot --headless --path . --script tests/search_smoke.gd
godot --headless --path . --script tests/render_profile_smoke.gd
godot --headless --path . --script tests/export_boundary_smoke.gd
```

On Windows, after placing Godot 4.7.2 at
`build\toolchain\engine\Godot_v4.7.2-stable_win64_console.exe` (or passing `-Godot`),
run every headless `tests\*_smoke.gd` check in its own engine process with:

```powershell
python -m unittest discover -s tests
powershell -ExecutionPolicy Bypass -File tools\run_suite.ps1
```

The runner writes one log per check and `summary.txt` under `build\suite`; `-Only
name,name` runs a subset. It points the engine's APPDATA at `build\dev-environment` so
real saved views and preferences are untouched.

The Python checks cover corrupt inputs, path containment, asset modification,
catalogue references, both bodies and exclusion of sampling sites. The engine
integration uses actual geometry to check multi-mesh movement, exact restoration,
undo/redo, branching history, original-position overlays, saved-state validation and
hidden/faded picking behaviour. Loading checks use real prepared geometry and verify UI frame processing, source-read
shutdown, concurrent-request rejection and failure preservation after missing files,
changed hashes, missing roots and invalid mesh mappings. Input while loading cannot
undo edits or alter the camera/Move mode. Native archive tests check target architectures,
Mac executable metadata and extraction containment.
Exploration checks cover both-body navigation/inspection separation, local label
context, density, surface ownership, occlusion, layout containment and compatible
saved-view settings. The rendered capture also clicks a real label through the
desktop UI and checks toolbar containment at a 1100 × 720 window size.
Part inspection checks cover both bodies, covered-part selection, temporary reveal,
mask/label/picking agreement, exact return framing, edits made while inspecting,
undo/redo, body switching, compatible saves and atomic rejection of invalid returns.
Rendered checks click Inspect alone, a supplied part and Return to context through
native input, and move the part while inspecting it.

Named-view storage and restore checks:

```sh
godot --headless --path . --script tests/saved_views_smoke.gd
godot --headless --path . --script tests/study_notes_smoke.gd
godot --path . --script tests/capture_saved_views.gd
```

These use separate test filenames. They cover all three prepared references,
inspection return after reopening, full geometry displacement precision, rename/delete,
invalid/missing sources, duplicate names, stale edits, damaged-file recovery and write
failures. The rendered check clicks Save/Restore through native input at the compact
window size. It writes a developer capture under /tmp/medicine-viewer-feasibility/.

Optional rendered capture on a Linux development display:

```sh
godot --path . --script tests/capture_viewer.gd
godot --path . --script tests/capture_keyboard_workspace.gd
godot --path . --script tests/capture_loading.gd
godot --path . --script tests/capture_search.gd
godot --path . --script tests/capture_screenshot_export.gd
godot --path . --script tests/capture_profile_rejection.gd
```

This developer capture writes images under /tmp/medicine-viewer-feasibility/; create
that directory first. It is separate from the normal application.

Record measured results and hardware in [FEASIBILITY_RESULTS.md](FEASIBILITY_RESULTS.md).
Headless success does not establish visual quality, frame rate, input usability,
or Windows/macOS device compatibility.
