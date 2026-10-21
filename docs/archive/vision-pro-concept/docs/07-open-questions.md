# 07 — Open Questions

Ordered roughly by how much they block progress. Each includes a recommendation, so
none of them is a blank page — the recommendation is a starting position to argue
with, not a decision already made.

---

## Q1 — Is the headset the point, or one target among several? *(blocking)*

The project is named for Vision Pro, but the answer changes the stack, the roadmap,
and how much of the UI gets built twice.

- If **the headset is the point** — the value is specifically stereoscopic depth and
  body-scale presence — then a native visionOS stack is justified, and the practical
  consequence is needing a Mac with Xcode, since none of it can be built on the
  current Linux machine.
- If **the headset is one target** and the real goal is the layered anatomy/pathology
  system, then a WebXR-capable web stack reaches Vision Pro, other headsets, phones,
  and desktop from one codebase, and can be built here today.

**Recommendation:** the second, unless there is a reason to want the native path. The
architecture in [02-architecture.md](02-architecture.md) keeps everything below the
Resolver portable regardless, so this is a reversible decision — but reversing it
still costs the whole presentation layer, so it is worth answering honestly rather
than defaulting.

---

## Q2 — Serialization format for content *(blocking)*

Thousands of records, hand-authored, version-controlled, read constantly.

- **JSON** — universal, trivially parsed, schema-validatable; verbose and comment-free.
- **YAML/TOML** — pleasant to hand-write, comments allowed; whitespace and type
  coercion surprises at scale.
- **Markdown + frontmatter** — best for the prose-heavy parts (a condition's
  `explanation` wants to be real prose, not a quoted string).
- **SQLite** — best for querying the relation graph; worst for diffs and hand-editing.

**Recommendation:** structured data in one text format, prose in Markdown, and build
an index at load time rather than storing one. The relation graph is small enough to
hold in memory; a database is a premature answer to a query problem you do not have
yet. Revisit if the graph passes ~50k edges.

---

## Q3 — Coordinate frame and units *(blocking, cheap)*

Trivial to decide now, extremely annoying to change later, since it invalidates every
`transform` in the content.

**Recommendation:** metres, real human scale (~1.75 m standing), origin at the floor
between the feet, +Y up, +Z anterior, +X to the *subject's* left. Standard anatomical
position. Being explicit about "subject's left" rather than "viewer's left" prevents a
class of laterality bug that is genuinely hard to notice.

---

## Q4 — How far below gross anatomy does the model go?

Histology? Cell types? Molecular pathways? Real diseases live at every level —
"demyelination" is a molecular event with a gross-anatomical consequence.

**Recommendation:** design the id space so it *can* extend below gross anatomy
(`nerve.median.tissue.myelin`), populate only gross anatomy for now, and let actual
content demand pull it deeper. Do not build a histology layer speculatively.

---

## Q5 — Where does non-visual content live?

Conditions want prose: mechanism, presentation, management. Much of that has no
visual representation at all.

**Recommendation:** keep it in the Condition record but clearly separated from the
`involves[]` block — visual content drives the renderer, prose drives the panel. The
risk to watch is the project quietly becoming a text database with a 3D decoration;
if a condition's record is 90% prose, ask whether it belongs here at all.

---

## Q6 — Authoring workflow

Hand-writing records in a text editor is fine for 50 and painful at 500. A dedicated
authoring tool is a whole second product.

**Recommendation:** text files plus a validator and good error messages until it
genuinely hurts. The one thing worth building early is a **placement tool** — clicking
positions in 3D and having coordinates written back — because eyeballing numeric
transforms is the specific part that is miserable rather than merely tedious.

---

## Q7 — Solo project, or eventually shared?

Affects licensing (share-alike geometry propagates), hosting, content review, and
whether medical accuracy needs a process rather than good intentions.

**Recommendation:** build as if solo, but keep the content licence-clean and the
accuracy discipline from [03-anatomy-sources.md](03-anatomy-sources.md) in place from
the start. Both are cheap now and expensive to retrofit. Decide about sharing when
there is something worth sharing.

---

## Q8 — What is the first condition, really?

Phase 2 suggests myocardial infarction. The first condition sets the pattern every
later record copies, so it is worth choosing on merit.

Good candidates test different things: **MI** (multi-structure, staged causal reveal,
territory mapping onto vascular supply), **aortic stenosis** (deformation, downstream
compensatory change), **disc herniation** (mechanical displacement, mapping a lesion
onto a dermatome/myotome distribution).

**Recommendation:** pick whichever you are studying when Phase 2 starts. The tool
being immediately useful to you matters more than the elegance of the example.
