# Study workspace improvements

Implemented on 2026-10-15 for the private prototype. The original HRA United
female/male references and existing saved libraries retain their identities.

## Study information

Fifteen authored cards cover the heart, its chambers/septum/valves, and the lungs.
Select a covered structure to read a short overview and function, follow related
structures in the current body, or open its primary sources in a browser.
**Source and mesh details** expands the complete technical source record.
Structures without an authored card say so explicitly.

Text and relationships are stored separately from geometry in
[study_content.json](../content/study_content.json). These are private drafts. Assistant source cross-checks are preliminary; human
source review and qualified medical review remain pending. General anatomical explanations do
not establish the completeness of source meshes or supply a validated cutaway.
The source pages are NHLBI / NIH's [heart anatomy](https://www.nhlbi.nih.gov/health/heart/anatomy),
[heart blood flow](https://www.nhlbi.nih.gov/health/heart/blood-flow),
[respiratory system](https://www.nhlbi.nih.gov/health/lungs/respiratory-system) and
[gas exchange](https://www.nhlbi.nih.gov/health/lungs/breathing-benefits).
No source illustrations, videos or substantial text passages are reused.

The earlier packages used `source_checked` labels without the recorded human
check required by [the review model](DATA_MODEL.md#review-evidence). That was an
overstatement. Current records use `draft`, keep both human review stages pending,
and store assistant cross-check metadata separately. Unsupported review promotions
are rejected by the loader. Earlier engineering reports do not establish human review.

## Related conditions

Heart and valve cards now link two initial examples: **Aortic stenosis** and
**Mitral regurgitation**. These are short draft summaries based on
[NHLBI's valve-disease types](https://www.nhlbi.nih.gov/health/heart-valve-diseases/types)
and the heart blood-flow page above. Qualified medical review remains pending.
The associations and reference targets are explicit records in the content file.

Open a condition to read its summary, anatomical location, depiction limits and
sources. Reading or closing the text preserves the current exploration.
**Inspect reference anatomy** reveals the supplied valve using the existing
inspection tools. **Return to context** restores body context; **Back** can also
recover an earlier isolated view. Source visibility/displacement edits remain intact.

The supplied meshes are unreviewed reference anatomy. These examples provide no
pathological mesh, narrowing, leakage, leaflet motion or flow simulation. Saved views
retain the ordinary reference-anatomy setup. The loader accepts the implemented
`reference_location_only` capability and rejects unsupported geometry claims.
The separate bone/spinal studies have no inferred condition associations.

## Guided chest exploration

Choose **Guided chest** in either HRA body, or **Explore > Guided chest** in expanded
anatomy. Six steps show chest context, supplied heart parts, separated chamber meshes,
a supplied valve, both lungs, and chest context again. Use Previous/Next while freely
orbiting, selecting and inspecting the supplied geometry.

The chamber layout is a teaching displacement, with blue original-position ghosts.
It is not a pathological model or a validated anatomical cutaway. Each step resets
the temporary teaching edits. **Finish and restore** restores the starting camera,
selection, labels, visibility, displacement, isolation/return context and undo/redo
and navigation histories. A reference switch or saved-view restoration finishes the
guide first. Save a named view before finishing to retain a teaching setup; the
snapshot uses the ordinary inspection format and does not retain guide progress.

The guide remains available when anatomy is expanded. It is disabled for the separate
bone/spinal source studies, which do not supply the required chest geometry.

## Heart-to-lung route

Choose **Heart ↔ lungs**, or **Explore > Heart ↔ lungs route** in expanded anatomy.
The authored sequence visits the vena cava, right heart, pulmonary vessels, lungs,
left heart and aorta before a conceptual return through the body. At the pulmonary
trunk, choose either lung branch. **Previous** retraces the branch you took; at the
branch choice you can try the other lung. Every step links its supporting source.

Source selections are mapped separately to the exact female and male records,
including source names and ontology IDs. A mismatched record disables the route.
Lung surfaces provide context for gas exchange: individual alveoli and their
capillary networks are absent. The complete systemic vessel/tissue route is also
an explicit gap. Mesh interiors and physical continuity remain unverified; this
conceptual sequence draws no simulated flow or anatomical channels.

The route uses NHLBI's blood-flow and gas-exchange pages above, plus Tucker,
Weber and Burns, [*Anatomy, Thorax, Heart Pulmonary Arteries*](https://www.ncbi.nlm.nih.gov/books/NBK534812/)
(StatPearls, updated 2023-07-24) for the two pulmonary arterial branches. All text
and relationships remain drafts with human source and medical review pending.
The loader validates review stages, citations, HTTPS links, graph reachability,
return paths and mapping fields before making the content available.

Like the chest guide, **Finish and restore** recovers the exact starting exploration
and histories. Switching between guide and route restores the previous workspace
before starting the next. Changing reference or restoring a saved view finishes
the route. A saved snapshot retains its anatomy setup, without route progress.

## Precise keyboard movement

Focus the 3D view and press **M** to enter Move mode. Press **I/J/K/L** to move
up/left/down/right in the camera plane, or **U/O** toward/away from the camera.
Each deliberate press moves 5 mm; hold **Shift** for 1 mm. Held-key repeat is ignored
so it cannot create an accidental long displacement. **Ctrl/Cmd+Z** reverses one
step; add Shift to redo. Original-position ghosts use the existing visibility control.

**M** or **Escape** leaves Move mode. Camera keys still leave Move mode and preserve
inspection edits. The keys apply only while the 3D view has focus; search and text
fields retain normal input. Movement works in both workspace sizes and every source
reference. These are camera coordinates, separate from body-direction presets.

## Portable saved views

In **Saved views**, the search field finds view names, saved notes and unsaved note
drafts. Words can appear in any order; matching ignores letter case. The count
shows matching views against the whole library. **Ctrl+F** focuses search;
**Enter** selects a match without restoring it. **Escape** clears a nonempty
focused search. The clear button restores the full list.

Filtering keeps note drafts and the current anatomy unchanged. A hidden selection
is cleared rather than replaced by another view. Saving or renaming a view clears
the search when needed to reveal that view. Saving notes refreshes their matches.
The dialog keeps its action buttons visible and scrolls content at smaller sizes
or larger text settings.

**Save notes** retains the selected view's draft. **Save all notes** or **Ctrl/Cmd+S**
retains every pending note, including drafts hidden by the search, and keeps the
library open. The note status counts drafts on other views. All notes are saved
together: an invalid note or failed write leaves every draft open. Selection and
the editor cursor stay in place if the selected view still matches the search.
Saving notes preserves a view name you are still typing. Use **Save current view**
or **Rename** to apply that name.
Saving or discarding notes before another action also refreshes search results.

After confirming a deletion, **Undo delete** restores the most recently deleted
view at its previous list position where possible. Its identity, date, snapshot
and saved notes remain intact. Unfinished notes return as an unsaved draft; use
**Save notes** to retain them. Other drafts and the open anatomy stay unchanged.
Undo reveals and selects the restored view, clearing the search if needed.

Only the last confirmed deletion is available, and only while this library window
stays open. A failed delete leaves the previous undo available. A failed undo
keeps its recovery record for retry; name/identity conflicts, a full library and
external file changes cannot overwrite existing views. Closing the window drops
this temporary undo record.

In **Saved views**, **Export all views** writes a local JSON file containing named
snapshots and their saved notes. There are no anatomy meshes, accounts or uploads
in this export. Unsaved notes use the existing save/discard/keep-editing choices.

**Import views** first previews compatible views, skipped duplicates and incompatible
reference/version data. Name collisions receive a numbered suffix; changed snapshots
with a colliding identity receive a new identity. Reimporting an unchanged view keeps
the local name and avoids another copy. Only compatible views are added, and the
existing library is retained. Damaged files and stale previews cannot partly replace
the library. The format retains the existing 200-view, 32-MiB and 10,000-character
note limits. A failed write preserves the existing library and reports the error.

Damaged or missing libraries can recover from a valid previous library. Recovery
refuses a stale offer if the main file has changed, and preserves each damaged
original under its own filename. The result names that copy. Older damaged copies
and the valid backup remain available. A healthy loaded library does not offer
recovery. Invalid JSON reports a readable error while keeping the input unchanged.

## Opening and switching references

After a reference is open, **Cancel opening** is available during a replacement
in both workspace sizes. It keeps the current anatomy, camera, labels, inspection
edits and histories. Guide/route controls pause while loading and resume at the
same step if opening is canceled or fails. A completed switch finishes the study
and restores its original viewing controls. Canceling a different-reference saved
view also retains the current study.

Canceling may wait for the current reading step to finish before controls resume.
The button then disappears and keyboard focus returns to the anatomy view. The
last completed reference remains the startup choice. Completing a later reference
switch still works normally.

## Viewing preferences

**View > Preferences** offers 100%, 115% and 130% text, plus a reset action. The
header wraps at smaller window sizes. Panel visibility, 3D resolution, selection/local
labels and label density are saved locally in `user://preferences.json`.
Anatomy snapshots keep their own label settings; restoring a view does not replace
the stored device defaults. Damaged preferences fall back to defaults. QA uses
disposable preference paths and does not read or alter the user's preferences.

Normal desktop launches also remember the windowed client size and maximized state
on a clean close, in `user://window-state.json`. Reopening centers the window on the
current display and bounds the saved size to its usable area while retaining the
app's minimum size. Returning from maximized mode keeps the preceding windowed
dimensions. Window layout is independent of anatomy snapshots and portable views.
Scripted QA and headless runs ignore this desktop file. Invalid layout settings
fall back to the current default layout; malformed viewing-preference JSON also
recovers without a parser error.

A normal close also saves the last successfully loaded reference in
`user://reference-state.json`. Reopening starts that reference at its default
anatomy view. Camera, inspection edits and notes remain in named saved views.
The window title identifies the loaded reference. Failed switches do not replace
the remembered choice, and canceling an unsaved-note close saves neither startup
reference nor window layout.

Startup matches both the installed reference ID and source fingerprint. A removed,
changed or unreadable choice falls back to the female reference with a status
message. If its asset cannot load, startup also tries the female reference. Loading
alone does not rewrite the startup file; an accepted normal close saves the last
completed load. Scripted QA and headless runs ignore this file.

Text sizing and keyboard manipulation improve access; assistive-technology and
human accessibility acceptance remain open.

Text fields, lists and selectable information use teal focus outlines. Text
selection has a dark teal highlight, and unavailable buttons/links retain muted,
readable labels. Focusing an anatomy list reveals its selected structure after
layout or text-size changes without changing the selection, camera or edits.
The note editor follows the same dark palette as the other text fields.

Keyboard help and **Sources** use bounded, scrollable windows. Their text follows
the selected size and can be selected for copying. Tab changes focus; Page Up/Down
scrolls focused text, and Escape closes the window. Sources also lists the authored
study-text references and remains available while the first body is loading.

## Added anatomy studies

The reference selector adds four independent HRA v1.2 source studies:

| Study | Source meshes | Source triangles |
|---|---:|---:|
| Female spinal cord | 29 | 288,912 |
| Female vertebrae | 25 | 426,468 |
| Male spinal cord | 30 | 16,358 |
| Male vertebrae | 24 | 320,442 |

All 108 source meshes retain their geometry, source indices and coordinates, with
exact picking, isolation/return, movement/restoration, saved views and source credits.
They are not registered to the United bodies or to one another. Each study has its
own coverage record. Body-direction presets are disabled until their reference frames
have independent evidence. Picking resources use a documented 100× numeric scale
with an inverse collision transform, avoiding small-triangle ray tolerances while
leaving display geometry in its original metre frame. Every source triangle is
retained; sampled reconstructed vertices differ by at most about 0.061 micrometre.
Very thin or covered silhouettes retain the ordinary corner Actions fallback when
the bounded label search cannot establish a surface hit.

`VH_F_lumbar_vertebra_6` remains an explicitly unlabelled source record with its
original name and missing ontology. No variant/error interpretation is assigned.
Full rib-cage/skull/muscle coverage and medical review remain open.

To reproduce the optional studies before preparing geometry:

```sh
python3 tools/fetch_assets.py --manifest content/spinal_source_manifest.json
python3 tools/build_spinal_studies.py
godot --headless --path . --script tools/prepare_assets.gd
```

Original URLs, byte counts and SHA-256 hashes are pinned in the manifest. The builder
rejects changed sources and unestablished node transforms. The original candidate
inspection remains in [HRA_SPINAL_CANDIDATES.md](audit/HRA_SPINAL_CANDIDATES.md).

## Verification

Run the existing checks in [PROTOTYPE.md](PROTOTYPE.md), plus:

```sh
python3 -m unittest discover -s tests -v
godot --headless --path . --script tests/portable_views_smoke.gd
godot --headless --path . --script tests/study_workspace_smoke.gd
godot --headless --path . --script tests/spinal_picking_smoke.gd
godot --headless --path . --script tests/study_content_smoke.gd
godot --headless --path . --script tests/circulation_route_smoke.gd
godot --headless --path . --script tests/keyboard_movement_smoke.gd
godot --headless --path . --script tests/information_dialog_smoke.gd
godot --headless --path . --script tests/window_state_smoke.gd
godot --headless --path . --script tests/saved_views_filter_smoke.gd
godot --headless --path . --script tests/saved_views_recovery_smoke.gd
godot --headless --path . --script tests/saved_views_undo_smoke.gd
godot --headless --path . --script tests/reference_state_smoke.gd
godot --headless --path . --script tests/reference_startup_smoke.gd
godot --headless --path . --script tests/loading_cancel_smoke.gd
```

The workspace check exercises real geometry in both bodies and all four spinal studies,
guide restoration, card mappings, text sizing, preference wiring, coverage and import
preview. Running it with a desktop display also captures the new screens under
`/tmp/medicine-improvements/` (create that directory first). The precision check exercises actual physics rays and first-hit labels, comparing
reconstructed collision vertices with source mesh faces. The exported runtime checks
portable views/notes, preferences and reversible guide state in disposable files.
Device trials and qualified medical review remain separate from scripted verification.
[Verification and current private packages](audit/ALL_NOTES_VERIFICATION.md)
retain exact build identities, native Windows evidence, saved-view recovery/search/draft
and deletion-undo checks, study-preserving cancellation and normal-launch reference/window restoration observations. [Draft content verification](audit/DRAFT_CONTENT_VERIFICATION.md)
records the learning-content review-stage correction and valve-reference checks.
