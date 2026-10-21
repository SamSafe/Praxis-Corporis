# 00 — Vision and Scope

## The motivation

Medicine is taught as a stack of separate subjects — anatomy, physiology, pathology,
pharmacology — that describe the same body. Learners hold them as separate mental
models and pay a tax every time they have to reconcile them. A patient with heart
failure is simultaneously an anatomical object, a pump with altered pressure-volume
behaviour, a set of neurohormonal feedback loops, and a target for four drug classes.

The point of this project is to make **one substrate** — a navigable body — that all
of those views can be attached to, so that the connections are the default state of
the display rather than something the learner has to reconstruct.

## What it should let a user do

In rough order of ambition:

1. **See** a human body in 3D and move around it.
2. **Isolate** — show only the skeleton, only the muscles of the anterior thigh, only
   the branches of the coeliac trunk.
3. **Identify** — point at something and be told what it is, with correct terminology
   and a stable identifier.
4. **Relate** — from any structure, see what it attaches to, what it is supplied by,
   what it drains into, what innervates it, what it is contained by.
5. **Overlay pathology** — select a condition and see which structures it involves,
   how they change, and in what sequence.
6. **Trace process** — follow a pathway (electrical conduction, blood flow, a reflex
   arc, a metabolic cascade) as something animated through the anatomy it occupies.
7. **Compare** — normal vs. affected, side by side or as a toggle.

Items 1–4 are an anatomy atlas. Items 5–7 are the actual thesis: that pathology and
physiology become dramatically easier to hold when they are rendered *in situ*.

## Audience

Primary: the author, as a learner and as a builder. This is a tool that gets built
by someone who needs it, which is the right condition for it to be good.

Secondary, if it goes well: medical and allied-health students; patient explanation
(a clinician turning a screen around to show someone what is happening in their body).

Explicitly **not** a target: clinical decision support, diagnosis, or anything that
influences the care of a specific patient. See "Not in scope" below — this boundary
is load-bearing and should be restated in the UI itself.

## Non-goals

Being clear about these early prevents a lot of wasted work.

**Not patient-specific.** This visualizes canonical anatomy and textbook disease
processes. It does not ingest a patient's imaging, does not render *their* anatomy,
and does not comment on *their* case. If DICOM import is ever added, it is for
education on de-identified data, not for reading studies.

**Not a diagnostic or clinical tool.** No differential generation, no risk scoring,
no dosing. The moment a tool suggests what might be wrong with someone, it acquires
a regulatory character (software as a medical device) and an ethical weight that a
learning visualizer should not carry. Keep the tool descriptive, not prescriptive.

**Not a surgical simulator.** No soft-body deformation, cutting mechanics, or haptics.
Those are a different and much harder engineering problem.

**Not a replacement for cadaveric or clinical learning.** It is a supplement, and
should be honest that idealized geometry hides the variation that real bodies have.

**Not exhaustive on day one.** The Foundational Model of Anatomy has ~104,000 classes.
Any attempt to be complete before being useful will kill the project. Depth comes
region by region, driven by whatever the author is actually studying.

## The design constraint that matters most

The content will outlive and outgrow the code. There will eventually be far more
hours in *writing anatomy and disease records* than in writing rendering logic.

Therefore: the data format is the real product surface. It should be pleasant to
author by hand, diff-able in version control, validatable, and stable enough that
records written in year one still load in year three. Everything in
[01-data-model.md](01-data-model.md) follows from taking this seriously.
