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
| Save/load | Save view and Load view use one local saved-view slot. |

Faded structures are click-through; hidden structures have no active pick collision.
Choose either in the tree and use Show to make it directly selectable again.
Viewer undo/redo restores visibility and inspection displacements, not camera navigation.
New inspection edits discard redo history. Original-position overlays are separate
from anatomy and do not intercept clicks; restoring a part hides its overlay.
Selecting a hidden structure focuses its position without silently revealing it.

Back/Forward restores selection, camera position and the relevant local label set.
It preserves current visibility, displacements and inspection undo/redo. Manual orbit
and pan are captured when leaving a view. Choosing another structure after going
back discards the old forward branch. History holds up to 40 previous views per body
and is not saved across launches. Whole body records a return point while preserving
inspection changes.

Local sets use the current source hierarchy, retaining an organ's context when you
select one of its components. Both hearts have 14 supplied component meshes. Labels
are clickable, use leader lines and avoid overlapping each other or leaving the
viewport. Leaders end at actual first-hit opaque surfaces belonging to the named
structure. Covered, hidden and faded components are omitted; the tree remains the
parallel route to select them. Faded layers are transparent to label ray queries as
well as clicks. Whole body clears the local context; changing organs replaces it.
Thin parts may remain unlabelled if the bounded surface search cannot find a hit.
Broad system label sets are not implemented.

Surface searches run at most ten times per second, with a 160-ray budget per update
and at most 64 supplied parts in a local set. These limits bound work but do not
establish a target-device performance result. Long names are shortened in pills and
available in their tooltips and the details panel. The details panel scrolls when
needed so the viewport and bottom controls remain available.

Body switching restores that body's original inspection state and clears undo/redo
and navigation history.
The saved slot records body, selected ID, camera, labels, original-position display,
local label context/density, visibility and displacements. Earlier schema-1 saves
remain compatible through defaults for the optional new label fields.
Saves use Godot's user:// location, outside the project, with a temporary-file rename.
Invalid schemas, content versions, missing structures and malformed transforms are
rejected. Multiple bookmarks, backups and migration recovery remain future work.

## Actual scope and limitations

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

Optional rendered capture on a Linux development display:

```sh
godot --path . --script tests/capture_viewer.gd
```

This developer capture writes images under /tmp/medicine-viewer-feasibility/; create
that directory first. It is separate from the normal application.

Record measured results and hardware in [FEASIBILITY_RESULTS.md](FEASIBILITY_RESULTS.md).
Headless success does not establish visual quality, frame rate, input usability,
or Windows/macOS device compatibility.
