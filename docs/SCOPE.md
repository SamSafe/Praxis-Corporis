# Scope — Picking a Finishable Wedge

The full vision is too big to build in one go (see [VISION.md](VISION.md) "honest
reality"). This doc exists to force a decision: **what is the smallest version that is
actually good and actually shippable?**

## The wedge principle

Build **one body region**, end-to-end, better than the incumbents *for that region*,
then expand region by region. Breadth is the reward for depth, not a starting point.

A region is "done" when it has all four layers working together:

1. **3D model** of the region, navigable + labeled.
2. **Structured content** for each structure (function, relationships).
3. **At least one pathology overlay** (normal ↔ diseased toggle + explanation).
4. **Testing loop** (spaced repetition over that region's structures & conditions).

## Candidate wedges (pick one)

| Wedge | Why it's good | Why it's hard |
|---|---|---|
| **The heart** | Self-contained, huge exam relevance, classic pathologies (MI, valve disease, conduction), clear normal↔disease story | Needs motion/physiology to be compelling; conduction is dynamic |
| **Upper limb (shoulder→hand)** | Pure anatomy showcase: bones, muscles (origin/insertion), brachial plexus, classic nerve palsies (Erb's, wrist drop, claw hand) — maps perfectly to "structure→lesion→deficit" | Lots of structures to model & label |
| **The kidney/nephron** | Where structure↔function↔pathology is tightest; great for systemic-disease tracing (diabetes, hypertension) | More physiology than gross anatomy; harder to make "navigable" feel rich |

**Recommendation:** start with **the heart** *or* the **upper limb**. The heart wins on
relevance and the satisfying normal↔disease toggle; the upper limb wins on showing off
3D navigation and the clean lesion→deficit testing loop. Decide based on which one *you*
most want to study first — your own motivation is the project's fuel.

## In scope for v1 (one wedge)

- Web app, desktop browser first.
- One region's 3D model, rotate/zoom/isolate/slice.
- Click-to-identify with labels and a structure info panel.
- 3–5 pathologies for that region with normal↔disease toggle + explanation.
- Spaced-repetition quiz mode over that region.
- Local save of user notes/progress.

## Explicitly out of scope for v1

- Whole-body coverage.
- Account system / cloud sync / multiplayer (local-first first).
- Mobile/native apps, VR.
- AI tutor / chat (tempting, but add it once content exists, not before).
- Educator dashboards, classes, assignments.
- Patient-specific imaging (DICOM).

## How to know the wedge worked

You (and ideally 3–5 other students) reach for it instead of your current tool when
studying that region. If not, fix the wedge before adding a second region.
