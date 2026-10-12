# Run the private anatomy prototype

The first viewer uses real, separate HRA male and female reference samples inside
one continuous scene. It is a partial atlas and has no disease content or medical
review. Detailed findings are in [the sample audit](audit/HRA_SAMPLE_FINDINGS.md).

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

Preparation imports both sources, excludes sampling-site roots, creates accurate
mesh collision shapes, and writes local compiled scenes in assets/prepared/.
The first raw import is expensive; preparation can take several minutes. Subsequent
launches reuse the scenes. A source-hash or engine-version change invalidates the
cache. The project folder must be writable during this development preparation.
Private packages bundle the prepared scenes read-only; they never import or write
geometry into the installation folder. Full installer/update handling remains work.

The GLBs, compiled scenes and .godot/ directory are excluded from Git. After fetching
and preparing, exploration and saves work offline. No login or network connection
is used by the viewer.

## Controls

| Action | Control |
|---|---|
| Orbit | Primary-button drag in the 3D view. |
| Pan | Shift + primary drag, right/middle drag, or supported trackpad pan gesture. |
| Zoom | Scroll wheel or supported pinch gesture. |
| Select and focus | Click visible geometry or a surface label, choose a tree item, or select a search result. |
| Browse systems and parts | Expand the anatomy tree; parent groups select their descendant meshes. |
| Browse local components | The Supplied parts list follows the current organ/group and uses the same selection as the main tree. |
| Inspect a covered part | Select it, then Inspect alone. Further selections follow this temporary view. |
| Return to surroundings | Return to context restores the selection/camera from before inspection and preserves current body edits. |
| Reveal deeper anatomy | Peel away skin; Hide/Fade/Show apply to the current selection. |
| First chest view | Show chest hides skin and fades lungs around the selected heart. |
| Labels | Selection label is on by default. Enable Local part labels; Maximum labels controls density from 1 to 12. |
| Previous/next view | Back/Forward or Alt + Left/Right outside text entry. |
| Move anatomy | Enable Move selected, then primary-drag in the viewer's camera plane. Shift-drag still pans. |
| Restore | Restore selected or Restore all recovers original transforms and visibility. |
| Undo | Undo button or Ctrl/Cmd + Z outside text entry. |
| Redo | Redo button or Ctrl/Cmd + Shift + Z outside text entry. |
| Original position | Show original positions toggles faint blue, non-selectable copies of moved anatomy at its baseline location. |
| Leave Move mode | Escape or Whole body returns to navigation and preserves inspection changes. |
| Body reference | Select Female reference or Male reference; shared canonical selections are retained where mapped. |
| Save/load | Saved views opens named local exploration setups with Save current view, Restore, Rename and Delete. |
| Coverage | Coverage opens the technical inventory for both reference bodies, known gaps and a shortcut to select a supplied group. |

Faded structures are click-through; hidden structures have no active pick collision.
Choose either in the tree and use Show to make it directly selectable again.
Viewer undo/redo restores visibility and inspection displacements, not camera navigation.
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

Open **Saved views**, enter a name, and choose **Save current view**. The library
keeps up to 200 named setups on this computer. Select a view to see its reference
and structure, then **Restore**. Change its name in the field and choose **Rename**;
deletion requires a second click on **Confirm delete**. Names must be distinct,
including when only letter case differs. Saving creates a new view rather than
overwriting an existing one. Restore validates the complete snapshot before changing
the body. Missing content or a different geometry hash leaves the session untouched.

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
restores it; a damaged original is retained as `.damaged`. Recovery returns the
previous version, which may omit the most recent edit. A stale open library detects
external file changes and asks you to close/reopen before editing. This is local
storage, without cloud sync or a cross-process transaction service.

The older `user://saved_view.json` quick-save slot is kept intact. When present,
**Restore previous quick save** appears in the window. Older HRA schema-1 views retain
their compatible defaults. General schema migration/import/export remain future work.

## Actual scope and limitations

Coverage in the top bar lists supplied system groups for both bodies, compares their
source mesh/group counts and keeps known gaps at the start of each entry. Other /
unestablished coverage has no exploration shortcut. The inventory does not assign
completeness percentages or promote draft labels to medical review. Its notes are
bound to the pinned catalogue/source commit in
[coverage_notes.json](../content/coverage_notes.json).

- Both samples provide surrounding body context and separately named organ geometry.
- Full skeleton/muscle/peripheral-nerve coverage is absent from these samples.
- Source labels, grouping and ontology fields remain draft import metadata.
- Heart parts exist, but prepared cutaways, caps, reviewed interiors and tissue
  explanations are not implemented.
- There is no authored disease list, comparison, injury simulation, animation or
  reviewed heart–lung pathway. Vessel geometry alone is not a route graph.
- Source labels remain unreviewed. Broader system sets, authored label anchors,
  comprehensive visibility sampling and fully stable layout during motion remain work.
- Movement is a camera-plane inspection displacement with optional original-position
  overlays. Handles and guided exploded views remain future work.
- No signed Windows or Mac installer, minimum-hardware claim, qualified medical
  review, accessibility acceptance or public-release readiness is established.

## Verification

```sh
python3 tools/fetch_assets.py --verify-only
python3 -m unittest discover -s tests -v
godot --headless --path . --script tests/viewer_smoke.gd
godot --headless --path . --script tests/exploration_smoke.gd
godot --headless --path . --script tests/part_inspection_smoke.gd
godot --headless --path . --script tests/coverage_smoke.gd
godot --headless --path . --script tests/study_reference_smoke.gd
```

The Python checks cover corrupt inputs, path containment, asset modification,
catalogue references, both bodies and exclusion of sampling sites. The engine
integration uses actual geometry to check multi-mesh movement, exact restoration,
undo/redo, branching history, original-position overlays, saved-state validation and
hidden/faded picking behaviour. Native archive tests check target architectures,
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
```

This developer capture writes images under /tmp/medicine-viewer-feasibility/; create
that directory first. It is separate from the normal application.

Record measured results and hardware in [FEASIBILITY_RESULTS.md](FEASIBILITY_RESULTS.md).
Headless success does not establish visual quality, frame rate, input usability,
or Windows/macOS device compatibility.
