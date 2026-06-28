# Glossary

Shared vocabulary so docs and code mean the same thing.

| Term | Meaning |
|---|---|
| **Praxis Corporis** | The project name (Latin, "practice of the body"); shortened to **Praxis**. |
| **Wedge** | The single body region built end-to-end first (see [SCOPE.md](SCOPE.md)). |
| **Structure** | Any anatomical entity (bone, muscle, nerve, vessel, organ, region) — a content record. |
| **Shared-id contract** | The rule that one `id` identifies a structure across the 3D model, content, and quizzes (see [DATA_MODEL.md](DATA_MODEL.md)). |
| **Pathology / Condition** | A disease or abnormality and its effect on one or more structures. |
| **Overlay** | A visual change applied to the model to show a pathology (color, region, deform, mesh-swap). |
| **Review status** | `draft` / `reviewed` / `verified` — how trustworthy a content entry's medical accuracy is. |
| **SRS** | Spaced Repetition System — schedules review of items by recall difficulty. |
| **FSRS / SM-2** | Specific SRS scheduling algorithms. FSRS is the modern one. |
| **glTF / GLB** | Web-native 3D model formats; nodes within them map to structures. |
| **Node** | A named element inside a glTF model; its name equals a structure `id`. |
| **r3f** | react-three-fiber, the React renderer for Three.js. |
| **Local-first** | Architecture where data lives on the user's device; no server required. |
| **ADR** | Architecture Decision Record (see [decisions/](decisions/)). |
| **Systemic disease tracing** | Following one condition's effects across multiple organ systems (a North Star feature). |
| **Atlas** | The navigable 3D anatomical model the user explores; the visual front end of the structure data. |
| **MCAT** | Medical College Admission Test — the entry exam the early study/quiz features target. |
| **USMLE** | United States Medical Licensing Examination — the later-stage exams Praxis aims to stay useful for. |
| **Three.js** | The underlying WebGL 3D library that **r3f** wraps; renders the glTF model in the browser. |
| **Walled garden** | A closed, expensive study platform that locks content behind paywalls — the kind of tool Praxis is positioned against (see [VISION.md](VISION.md)). |
| **North Star feature** | A high-ambition capability that guides design direction even before it ships (e.g. systemic disease tracing). |
