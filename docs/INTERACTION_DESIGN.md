# Interaction Design

Status: proposed desktop experience for review before implementation.

See [Interface specification](INTERFACE_SPEC.md) for static screen studies and
the exact selection, restore, pathway, and loading behaviours proposed for review.

## Workspace

| Area | Purpose |
|---|---|
| Top | Reference body, search, current region, previous view, full-body view. |
| Left | Region/system explorer, visibility, layer controls, saved views. |
| Centre | Continuous body scene, selection, local labels, anchored menu. |
| Right | Anatomy details, composition, connections, conditions, sources. |
| Bottom | Navigate/move modes, labels, fade, cutaway, separate, undo, restore. |

Panels collapse without losing state. Use neutral adjustable background, clear
anatomical orientation, restrained highlights, and names/outlines as alternatives
to colour alone. Keep technical preparation details out of ordinary learning flows.

## Primary journey

1. Open a whole-body reference; choose male or female anatomy.
2. Orbit and reveal deeper anatomy through visibility and transparency controls.
3. Select the heart. A short transition focuses on its actual position without
   opening a disconnected scene.
4. Enable local part labels. Select parts directly or through a searchable list.
5. Open Related conditions; select covered content and display affected anatomy.
6. Orbit/pan the heart while useful surrounding anatomy remains available.
7. Show connections; choose a supported route toward the lungs, inspect its
   structures, and choose branches where present.
8. Continue to nearby anatomy with useful visibility settings preserved.
9. Return through history, restore inspection disassembly, or reset the condition.

Revealing anatomy uses actual source groups; the body is not assumed to be a
uniform stack of layers. Reveal-target changes must be reversible.

## Proposed controls

| Input in Navigate mode | Action |
|---|---|
| Click a structure | Select and focus; never drag it accidentally. |
| Primary drag | Orbit the current focus. |
| Scroll / supported trackpad zoom | Scale-sensitive approach/retreat. |
| Secondary drag or Shift + primary drag | Pan, including a trackpad alternative. |
| Search/list activation | Same selection and focus as direct clicking. |
| Previous view | Return to a prior focus and useful camera/visibility state. |
| Escape | Close active menu/tool before clearing selection. |

Visible actions, configurable shortcuts, and keyboard-operable lists provide
gesture alternatives. Trackpad mappings require platform testing. Reduced-motion
settings shorten or remove camera travel.

Small structures remain accessible through the anatomy list. Overlapping targets
offer a chooser. Hidden geometry does not intercept clicks; faded geometry has a
clear selection policy.

## Selection and camera

Selection opens a small anchored menu with a connector to the structure:
Inspect anatomy, Show labels, Show connections, Related conditions, Explore changes,
and supported hide/fade/move/separate/restore actions.

Long lists and explanations open in the right panel. Keep the menu in the window
and away from the selected anatomy. Preserve selection when closing it.

Camera focus uses safe framing and scale-sensitive movement. Reveal target can fade
obstructing anatomy while keeping context. History and frame-selection/full-body
actions prevent getting lost. Internal travel requires supplied interior geometry;
camera motion cannot establish absent detail.

## Disassembly

Move mode is explicit. Handles or an inspection plane move supported structures.
Optional outlines mark their baseline locations. Guided separation uses authored
groups and offsets in the same scene.

Restore selected, restore group, and restore all recover exact baseline transforms.
Undo covers moves and visibility. Inspection displacement does not apply damage or
alter the stored connection graph.

Connected parts without suitable deformation assets can move together or show
conceptual connections explicitly; never invent stretched anatomy.

## Labels and interior inspection

Offer selected-only, local parts, and system label sets. Prioritize selection and
control density by screen space and distance. Leaders identify real structures;
occlusion handling avoids implying that a visible label names a different surface.
A text list provides a parallel inspection route.

Inspect actual internal components and source-backed composition information.
Composition text does not imply microscopic geometry exists. Start with validated
cutaways. General cross-sections need prepared surfaces and appropriate caps;
surface clipping does not create missing interiors.

## Pathways

Use reviewed routes with structures, named relationship types, waypoints, sources,
branches, and body-specific representation mappings. Adjacency, containment, blood
flow, nerve course, and disease consequences are different relationships.

Users can orbit, pause, choose a branch, stop following, and return to the start.
Missing segments are explicit; do not draw invented continuity through a gap.

## Conditions and injury

Related conditions exposes supported entries and available visual capabilities.
Highlights locate documented affected anatomy without pretending to be full
disease morphology.

Explore changes uses predefined scenarios. Expose location/pattern parameters only
when corresponding visuals and explanations have support. Causes, changes, and
effects stay linked to the authored scenario.

Normal and condition state are clearly named. Comparison uses an in-place toggle
or optional synchronized second viewport. Restore normal removes scenario changes
while retaining ordinary viewing preferences where possible.

## Saved views and body switching

Saved views include body/content versions, camera, selection, visibility, labels,
disassembly, and active scenario. Missing or changed content triggers a recoverable
restore path rather than silently displaying an incompatible state.

Switching bodies maps corresponding structures where available and reframes the
analogous region. If unsupported, return to that region or the whole body and explain
the coverage gap. Do not map sex-specific structures to unrelated anatomy.
