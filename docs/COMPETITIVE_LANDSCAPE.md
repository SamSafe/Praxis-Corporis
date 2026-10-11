# Research Notes and Competitive Landscape

Status: competitor evaluation is deferred; no market-ranking claims are established.

The earlier proposal described quizzes as the main differentiator and made broad
claims about the absence of useful free alternatives. Those claims are not used
as evidence for the current exploration-first design.

## What would help this plan

Evaluate comparable tools against the user's actual journey:

- Reveal anatomy from a whole-body reference.
- Focus on the heart without losing surrounding spatial relationships.
- Label/select individual parts and inspect supported internals.
- Move parts manually and use guided separation.
- Discover conditions through anatomy.
- Follow connections toward the lungs.
- Offer clear male/female coverage and work on student laptops.

Compare actual workflows, content scope, offline use, access, provenance, and
device requirements. Avoid using promotional object counts as proof of completeness.

## Source research already performed

BodyParts3D, Z-Anatomy, Human Reference Atlas, and Visible Human are asset/reference
candidates described in [CONTENT_PIPELINE.md](CONTENT_PIPELINE.md). The reviewed
documentation establishes candidate availability, not model quality or viewer performance.

## Technology evidence

Native distribution is the selected product direction. Browser technology remains
capable of 3D rendering; installation alone does not guarantee performance.

Unity documents hardware-accelerated web rendering and web-specific restrictions.
Electron documents a Chromium-based renderer. These sources informed the distinction
between a native engine and a packaged browser application; no comparative anatomy
benchmark was performed.

- [Unity web performance](https://docs.unity3d.com/6000.0/Documentation/Manual/webgl-performance.html).
- [Unity web limitations](https://docs.unity3d.com/6000.0/Documentation/Manual/webgl-technical-overview.html).
- [Electron architecture](https://www.electronjs.org/docs/latest/tutorial/process-model).

Engine selection remains provisional until the planned feasibility trial.
