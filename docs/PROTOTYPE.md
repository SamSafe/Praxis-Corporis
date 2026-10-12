# Run the private anatomy prototype

The first viewer uses real, separate HRA male and female reference samples inside
one continuous scene. It is a partial atlas and has no disease content or medical
review. Detailed findings are in [the sample audit](audit/HRA_SAMPLE_FINDINGS.md).

## Requirements and setup

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
Bundled content and installed-application cache handling remain packaging work.

The GLBs, compiled scenes and .godot/ directory are excluded from Git. After fetching
and preparing, exploration and saves work offline. No login or network connection
is used by the viewer.

## Controls

| Action | Control |
|---|---|
| Orbit | Primary-button drag in the 3D view. |
| Pan | Shift + primary drag, right/middle drag, or supported trackpad pan gesture. |
| Zoom | Scroll wheel or supported pinch gesture. |
| Select and focus | Click visible geometry, choose a tree item, or select a search result. |
| Browse systems and parts | Expand the anatomy tree; parent groups select their descendant meshes. |
| Reveal deeper anatomy | Peel away skin; Hide/Fade/Show apply to the current selection. |
| First chest view | Show chest hides skin and fades lungs around the selected heart. |
| Labels | Toggle the current selection label; the tree lists supplied components. |
| Move anatomy | Enable Move selected, then primary-drag in the viewer's camera plane. Shift-drag still pans. |
| Restore | Restore selected or Restore all recovers original transforms and visibility. |
| Undo | Undo button or Ctrl/Cmd + Z outside text entry. |
| Body reference | Select Female reference or Male reference; shared canonical selections are retained where mapped. |
| Save/load | Save view and Load view use one local saved-view slot. |

Faded structures are click-through; hidden structures have no active pick collision.
Choose either in the tree and use Show to make it directly selectable again.
Viewer undo restores visibility and inspection displacements, not camera navigation.
Selecting a hidden structure focuses its position without silently revealing it.

Body switching restores that body's original inspection state and clears undo.
The saved slot records body, selected ID, camera, labels, visibility and displacements.
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
- Labels currently follow the selected structure's bounds; local-part label sets,
  leader lines, overlap resolution and occlusion handling are later work.
- Movement is a camera-plane inspection displacement. Handles, original-position
  ghosts, guided exploded views, redo and navigation history remain future work.
- No signed Windows or Mac installer, minimum-hardware claim, qualified medical
  review, accessibility acceptance or public-release readiness is established.

## Verification

```sh
python3 tools/fetch_assets.py --verify-only
python3 -m unittest discover -s tests -v
godot --headless --path . --script tests/viewer_smoke.gd
```

The Python checks cover corrupt inputs, path containment, asset modification,
catalogue references, both bodies and exclusion of sampling sites. The engine
integration uses actual geometry to check multi-mesh movement, exact restoration,
undo, saved-state validation and hidden/faded picking behaviour.

Optional rendered capture on a Linux development display:

```sh
godot --path . --script tests/capture_viewer.gd
```

This developer capture writes images under /tmp/medicine-viewer-feasibility/; create
that directory first. It is separate from the normal application.

Record measured results and hardware in [FEASIBILITY_RESULTS.md](FEASIBILITY_RESULTS.md).
Headless success does not establish visual quality, frame rate, input usability,
or Windows/macOS device compatibility.
