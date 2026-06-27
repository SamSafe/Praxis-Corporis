# Content Pipeline — The Actually Hard Part

The code is the easy 20%. This document covers the 80%: **where do the 3D models and the
medical facts come from, and how do you keep them correct and legal?** Most projects
like this die here, not in the codebase.

## Two separate supply problems

1. **3D anatomical assets** (the meshes).
2. **Medical knowledge** (text: function, relationships, pathology, questions).

Treat them independently — different sources, different licensing, different risks.

## 1. Sourcing 3D models

Options, roughly cheapest-effort to most-control:

| Approach | Pros | Cons / risk |
|---|---|---|
| **Build on a hosted platform's API** (e.g. BioDigital Human) | Instant high-quality, medically vetted models + viewer | Cost, vendor lock-in, ToS limits, less control |
| **License a 3D anatomy asset pack** | Good quality, you own the integration | Upfront cost; license terms (can you redistribute? commercial?) |
| **Open / free model sources** — NIH 3D Print Exchange, BodyParts3D/Anatomography (CC-licensed whole-body), Z-Anatomy (open Blender project), Sketchfab CC models | Free, openable | Variable quality & accuracy; **must verify license** per asset; node naming needs cleanup |
| **Reconstruct from open imaging** — Visible Human Project, open CT/MRI datasets, segment with 3D Slicer | Full control, real data | Large effort; segmentation is skilled work |
| **Commission / model in Blender yourself** | Total control & ownership | Slow; needs anatomy + 3D skill |

**Recommended v1 path:** start from an **open, CC-licensed set** (BodyParts3D /
Z-Anatomy are the usual starting points) for your one wedge region, clean up and rename
nodes to match your [DATA_MODEL.md](DATA_MODEL.md) ids. Record the exact license of
every asset in `content/_references/`.

> ⚠️ Every model file needs a documented license and attribution. "Found it online" is
> not a license. See [COMPLIANCE.md](COMPLIANCE.md).

## 2. Sourcing medical knowledge

This is a **medical-writing and review** problem, not a coding one.

### Where facts come from
- Authoritative textbooks (Gray's Anatomy, Moore, Netter for anatomy; Robbins for
  pathology; Guyton for physiology). You **cannot copy their text** — you write your own
  summaries and **cite** the source.
- Open/public references: NIH/MedlinePlus, peer-reviewed open-access journals,
  reputable society guidelines.

### The accuracy process (non-negotiable once it teaches medicine)
Every structure/pathology entry has a `reviewStatus`:
- `draft` — written, unverified.
- `reviewed` — checked against ≥1 cited authoritative source.
- `verified` — checked by someone with relevant medical training.

Until you have medical reviewers, **everything is `draft` and the UI must say so**
(disclaimer banner — see [COMPLIANCE.md](COMPLIANCE.md)).

### Citations
Maintain a citation registry (`content/_references/`). Every non-trivial claim links to
a reference id. This is what separates a credible study tool from a wiki of guesses, and
it's your defense if a fact is challenged.

### On using AI to draft content
Fine for **first drafts and structure**, dangerous as a **source of truth** — LLMs
hallucinate plausible-sounding medical facts. Rule: AI may draft, a cited human-checked
source must back every fact before it leaves `draft`. Never ship AI-generated medical
claims as `verified`.

## Pathology *simulation* assets

Showing a disease's effect (overlay, deformation, mesh swap) often needs **per-condition
art or animation**. Start with the cheapest visual that teaches:
1. **Color/region overlay** on the existing mesh (cheap, often enough).
2. **Opacity/highlight** of affected structures.
3. **Mesh swap / morph** (expensive — only for high-value conditions later).

Define the `visual.type` per pathology in the data model so the app knows how to render
each one.

## Pipeline summary

```
 source asset ──► clean + rename nodes ──► record license ──► commit to content/
 source facts ──► write summary + cite ──► reviewStatus ──► commit to content/
                          │
                          ▼
                 schema validation (CI) ──► build ──► static deploy
```
