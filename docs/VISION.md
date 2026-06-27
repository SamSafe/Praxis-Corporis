# Vision

> **Project name:** Praxis Corporis (Latin, "practice of the body") — often shortened to
> **Praxis**. The name captures the two halves of the project: a *corpus* (the body / a
> body of knowledge) you can navigate, and *praxis* (applied practice) — the testing and
> study loop that is the core differentiator.

## One-sentence pitch

A navigable 3D human body where every structure is labeled, testable, and connected to
the physiology and diseases that affect it — a single tool that teaches *and* examines,
useful from MCAT through clinical practice.

## The problem

Learning medicine forces you to hold three things in your head at once and constantly
switch tools to do it:

1. **Spatial structure** — what is where, and what it looks like from different angles
   (2D atlases and cadaver lab).
2. **Function** — what each structure does (textbooks).
3. **Pathology** — what goes wrong, why, and the downstream effects (more textbooks,
   case banks, flashcards).

These live in separate products. You memorize the brachial plexus in one app, learn
about Erb's palsy in another, and get quizzed in a third. Nothing shows you the *same*
nerve, then breaks it, then asks you what happens.

## The vision

One environment where you can:

- **Navigate** the body in 3D — rotate, slice, isolate systems (skeletal, muscular,
  nervous, vascular, lymphatic, organ systems), peel layers, and view cross-sections.
- **Label & annotate** — toggle labels, add your own notes/pins, draw, save views.
- **Learn structure → function** — click any structure for its name, relationships
  (origin/insertion, innervation, blood supply, drainage), and physiology.
- **Overlay pathology** — apply a disease/condition and *see* its effect on the model
  (e.g. an MI region on the heart, a herniated disc compressing a nerve root, the
  vascular territory of a stroke), with the clinical presentation explained.
- **Be tested** — built-in quizzes and spaced repetition driven by the same data:
  identify structures, match condition→effect, clinical vignettes tied to the 3D view.
- **Trace consequences** — pick a condition and follow its systemic impact across organ
  systems ("what does uncontrolled diabetes do, organ by organ?").

## Who it's for (in order)

1. **You / pre-med & MCAT students** — anatomy, physiology, intro pathology.
2. **Medical & nursing/PA/allied-health students** — deeper anatomy + pathology + boards prep.
3. (Later) **Educators** — assign content, build quizzes, track classes.
4. (Much later) **Patient education / clinicians** — explain conditions visually.

## The honest reality (read this before writing any code)

This vision, taken whole, is **the work of a well-funded company over many years**, not
a solo or small project. The hard part is *not* the 3D viewer — that's a solved problem
with off-the-shelf engines. The hard parts are:

- **Medically accurate 3D assets** for the whole body (expensive to license, very
  expensive to make).
- **Curated, correct, referenced medical content** for thousands of structures and
  hundreds of diseases — this is a medical-writing and review effort, not a coding one.
- **Pathology *simulation*** (showing a disease's effect on the model) requires both
  custom assets/animations per condition *and* domain expertise per condition.
- **Liability and accuracy** — once it teaches medicine, wrong content has real stakes.

The strategic answer is not "build less ambition" — keep the big vision here as the
North Star. The answer is to **pick one narrow, finishable wedge** and build it
end-to-end so it's genuinely good, then expand. See [SCOPE.md](SCOPE.md).

## Success criteria for v1 (proof the idea works)

A med/pre-med student uses it for one body region (proposed: the heart, or the upper
limb) and says *"I'd use this instead of my current tool for this topic."* If you can't
beat existing tools on **one** region, breadth won't save you.

## Non-goals (at least early)

- Not a diagnostic or clinical-decision tool (regulatory minefield — see [COMPLIANCE.md](COMPLIANCE.md)).
- Not surgical simulation / VR (huge separate effort).
- Not patient-specific imaging (DICOM/CT/MRI reconstruction) in v1.
- Not a content marketplace or social platform in v1.
