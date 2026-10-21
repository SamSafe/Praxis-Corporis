# 04 — Interaction Model

How a user actually navigates a body. Written against capabilities rather than a
specific input API, so it holds for a mouse, a touchscreen, or hand tracking in a
headset.

---

## The five core interactions

Everything else is a variation on these.

### 1. Reveal — control what is visible
The single most-used interaction, and the one worth making excellent.

Three independent axes, which should compose rather than conflict:

- **By system** — skeletal, muscular, cardiovascular, nervous, … Multi-select, since
  the interesting views are combinations (nerves *and* the muscles they supply).
- **By region** — thorax, left forearm, posterior triangle of the neck. Follows the
  `parent` containment tree.
- **By depth** — peel from skin inward. Effectively a system-ordering, and the mental
  model closest to dissection.

Each layer needs three states, not two: **visible**, **ghosted**, **hidden**. Ghosting
is what makes the display legible — semi-transparent skin giving spatial context to
the organs beneath is the default view of most good anatomy software, not a special
case. Design the transparency handling for it up front (see the compositing note in
[02-architecture.md](02-architecture.md)).

### 2. Select — point at something and learn what it is
Pick → highlight → info panel. The panel is a browser over the relation graph, and
this is where the graph from [01-data-model.md](01-data-model.md) becomes the product:

```
Biceps brachii
Musculus biceps brachii · FMA:37670

Origin      supraglenoid tubercle · coracoid process   →
Insertion   radial tuberosity · bicipital aponeurosis  →
Innervation musculocutaneous nerve (C5–C6)             →
Supply      brachial artery                            →
Action      elbow flexion · forearm supination

Involved in   biceps tendinopathy · musculocutaneous
              nerve injury                             →
```

Every `→` is a jump to another structure, which reveals it and re-centres on it.
Navigation *through anatomy along real anatomical relationships* is the thing that
distinguishes this from an illustrated list, and it costs almost nothing to build
once the graph exists.

### 3. Isolate — reduce to one thing
Hide everything except a selection and its immediate relations. The natural companion
to selection: point at a nerve, isolate, and see exactly its territory.

### 4. Cut — see inside
Cutaway planes along the anatomical axes (sagittal, coronal, transverse), draggable.
Deserves specific attention because sectional views are how cross-sectional anatomy
is actually taught and how imaging is read — the mapping between a 3D model and a CT
slice is one of the genuinely hard things for learners, and a tool that shows both at
once addresses it directly.

Requires capping the cut surface, or organs render as hollow shells and the effect is
ruined. Worth verifying early that the chosen stack can do this.

### 5. Compare — normal vs. affected
Toggle a condition on and off over the same anatomy, or show both side by side. The
comparison is where the pathology actually lands: a thickened ventricular wall means
little in isolation and is obvious against the normal one.

---

## Pathology and process overlays

**Applying a condition** highlights involved structures by `severity`, applies each
`effect`'s visual treatment, and reveals whatever is hidden but involved. A staged
reveal following `primary → secondary → consequence` shows the disease as a *causal
sequence* — the thing static images cannot do and the clearest argument for the whole
project.

**Playing a process** needs transport controls: play, pause, scrub, speed, loop, and
step-by-step with the current step's label shown. Scrubbing matters more than
playback — the value is in stopping at the moment something happens and looking at
where it is.

---

## Screen vs. immersive

The interaction *core* is shared; the presentation differs. This is the reason
Interaction and Presentation are separate subsystems in
[02-architecture.md](02-architecture.md).

| | Flat screen | Immersive headset |
| --- | --- | --- |
| Navigate | orbit / pan / zoom | walk around a body-scale model, or manipulate a held one |
| Select | cursor | gaze + pinch, or ray from hand |
| Reveal | side panel with layer tree | a panel placed in space, or gesture-based peeling |
| Cut | drag a plane handle | grab and move the plane directly |
| Read | panel beside the model | panel anchored near the structure, billboarded to face the viewer |

Two things immersive display genuinely adds, worth naming because they justify the
extra cost: **true stereoscopic depth**, which is the thing flat anatomy images cannot
convey and the thing spatial relationships actually consist of; and **scale
manipulation** — inspecting a heart held at arm's length, then standing inside a
scaled-up one. Neither has a flat-screen equivalent.

Things that hurt in a headset and should be designed around: dense text (keep panels
short, big, and near), small targets (generous hit volumes), rapid camera motion
(move the model, not the user), and long sessions (build for ten-minute uses, not
ninety).

---

## Accessibility and honesty

- **Never encode meaning in colour alone.** Pathology overlays should differ in
  pattern, outline, or label too — around 1 in 12 men has some form of colour vision
  deficiency, and red-highlighted-on-pink-tissue is exactly the failing case.
- **Everything reachable without a headset.** The immersive mode is an enhancement,
  never the only path to content.
- **Everything reachable by keyboard and by search.** Search by name — including
  synonyms and Latin — is often faster than navigating a tree, and it is the primary
  route for anyone who cannot use a pointer precisely.
- **Show uncertainty.** Where geometry is a placeholder or a record is a draft, say
  so in the UI. An anatomy tool that looks authoritative while being approximate is
  worse than one that is honest about what it is.
