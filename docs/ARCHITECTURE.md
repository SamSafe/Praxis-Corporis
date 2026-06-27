# Architecture (Proposed)

> This is a *proposed* starting design for the v1 wedge, not a finished spec. Record
> significant choices as ADRs in [decisions/](decisions/).

## Guiding principles

- **Local-first.** v1 needs no backend. The app + content are static assets; user
  progress lives in the browser. This keeps it free to host, private, and simple.
- **Content separate from code.** Anatomy/pathology/quiz data are data files, not
  hardcoded — so medical content can be authored, reviewed, and corrected without
  redeploying logic. See [DATA_MODEL.md](DATA_MODEL.md).
- **Buy/borrow the 3D, build the learning.** The viewer is commodity; the structured
  content + testing loop is the value. Don't build a renderer from scratch.

## Recommended stack (v1)

| Concern | Recommendation | Why |
|---|---|---|
| Language | **TypeScript** | Type safety pays off as content schemas grow |
| 3D engine | **Three.js**, ideally via **React-three-fiber** | De-facto standard for web 3D; huge ecosystem; glTF support |
| UI framework | **React** (+ Vite) | Matches react-three-fiber; fast dev loop |
| Model format | **glTF/GLB** with named nodes per structure | Web-native, compact, nodes map to selectable structures |
| State | Lightweight store (**Zustand**) | Simple; avoids Redux overhead |
| Content | **Markdown + JSON/YAML** files, validated by schema (**Zod**) | Human-editable, diffable, reviewable in PRs |
| Spaced repetition | **FSRS** (or SM-2) library | Modern, well-studied scheduling |
| Persistence (v1) | **IndexedDB** (e.g. via Dexie) | Stores progress/notes locally, larger quota than localStorage |
| Hosting | Static host (**GitHub Pages / Netlify / Cloudflare Pages**) | Free, no server |

> If you'd rather not assemble the 3D yourself, the alternative is building on the
> **BioDigital Human API** (hosted models + viewer) and layering your testing/content
> on top. Trade-off: faster start and great assets, but vendor lock-in, cost at scale,
> and less control. Capture this as an ADR before committing.

## Component sketch (v1)

```
┌─────────────────────────────────────────────────────────┐
│                        Web App (SPA)                      │
│                                                           │
│  ┌──────────────┐   ┌───────────────┐  ┌──────────────┐  │
│  │  3D Viewer    │   │  Info / Label  │  │  Study/Quiz  │  │
│  │ (r3f/Three)   │◄─►│     Panel      │  │    Engine    │  │
│  │  - camera     │   │  - structure   │  │  - FSRS      │  │
│  │  - selection  │   │  - pathology   │  │  - queues    │  │
│  │  - clip plane │   │    toggle      │  │  - sessions  │  │
│  └──────┬────────┘   └───────┬───────┘  └──────┬───────┘  │
│         │                    │                  │          │
│         └──────────┬─────────┴──────────────────┘          │
│                    ▼                                        │
│         ┌────────────────────┐     ┌──────────────────┐    │
│         │  Content Store      │     │  Progress Store  │    │
│         │  (loaded data:      │     │   (IndexedDB:    │    │
│         │  structures,        │     │   mastery,       │    │
│         │  pathologies, decks)│     │   notes)         │    │
│         └─────────┬──────────┘     └──────────────────┘    │
└───────────────────┼────────────────────────────────────────┘
                    ▼
        Static content bundle (glTF models + JSON/MD + schemas)
```

## The selection mechanism (the key technical idea)

Each anatomical structure is a **named node** in the glTF model. The same `id` is the
key used by the content files and the quiz items. So:

- Click in 3D → engine returns node `id` → look up content by `id` → render info panel.
- Quiz "highlight this structure" → set selection by `id` → highlight node in 3D.

This shared-id contract between **model**, **content**, and **quiz** is what makes the
whole thing one connected system instead of three. Define it carefully — see
[DATA_MODEL.md](DATA_MODEL.md).

## What to defer (don't over-engineer v1)

- No backend, auth, or database server.
- No microservices, no GraphQL.
- No native/mobile/VR builds.
- No CMS — content is files in the repo.

Add these only when a concrete need (sync, sharing, scale) actually appears.
