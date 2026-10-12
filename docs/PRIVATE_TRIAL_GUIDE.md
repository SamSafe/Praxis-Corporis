# Personal and private viewer trial

Use this guide for the user's own trial first. A later small group can use the same
tasks when the user chooses to invite them. No testers have been contacted. These
tasks assess controls and coverage understanding; they do not provide medical review.

## Record the tested version

Record the archive name and SHA-256 from [the build report](audit/native-build-report.json),
OS version, graphics device, screen resolution/scaling, and whether input uses a mouse
or trackpad. Use the actual ZIP that matches that record. Later source commits do not
retroactively validate earlier packages. Extract the complete archive before opening it.
See [native setup](NATIVE_BUILDS.md).

Record whether the app started, the first visible body/loading time, and any failure
message. Screenshot the relevant state for a reproducible bug. Screenshots and saved
views stay local; no reporting/upload service is installed.

## Core tasks

Try each task before reading the [controls guide](PROTOTYPE.md), then note whether the
guide resolves any confusion. Preserve useful failed attempts rather than silently
restarting. Repeat the HRA tasks for both female and male references.

| Task | Success to observe | Notes to record |
|---|---|---|
| Identify the current reference | Recognise its body/source and that coverage is partial. | What did you assume was included? |
| Explore the body | Orbit, pan and zoom using the available input device. | Any jump, accidental selection or lost orientation? |
| Reveal and select the heart | Peel skin or use Show chest; selection focuses on its actual body position. | Is surrounding context useful? |
| Identify a supplied part | Enable local labels or choose a component in the list. | Can you reach a small/covered part without a direct click? |
| Inspect and return | Inspect alone, choose a component, then Return to context. | Does the temporary view and return action make sense? |
| Move and recover | Enable Move, displace a part, use Undo/Redo and Restore selected. | Is original placement clear? Did navigation ever move anatomy? |
| Revisit anatomy | Select the heart/lung and use Back/Forward. | Were camera and inspection changes retained as expected? |
| Save two views | Give two different setups distinct names in Saved views. | Are reference and structure easy to distinguish? |
| Reopen and restore | Close/reopen the app and restore a named isolated part. | Does Return to context still work? |
| Check a coverage gap | Open Coverage and inspect skeletal coverage for both HRA bodies. | Do counts look like a completeness claim? |
| Explore the bone study | Choose the separate male study, find Right femur, inspect and restore it. | Is its lack of HRA/female alignment clear? |
| Use a smaller window | Repeat selection, Save/Restore and inspection return. | Any unreadable text, clipped actions or blocked anatomy? |
| Use keyboard alternatives | Tab through actions and operate the tree/search without clicking. | Which core action still requires a pointer? |

The app currently has no disease visuals, reviewed routes, authored cutaways or
registered whole female skeleton. Record expectations for these as missing coverage;
do not score source geometry as a verified disease or pathway demonstration.

## Capture findings

For each failure, record the starting reference/selection, steps, expected outcome,
actual outcome, frequency, and screenshot/saved-view name if useful. Distinguish
“cannot complete”, “completed after help”, and “completed independently”. Explain
confusion in the user's own words. Do not include personal health information.

Keep unresolved issues in a versioned local trial record. A useful template is:

```text
Archive/hash:
OS/device/graphics:
Screen/scaling/input:
Task and completion level:
Starting reference/selection:
Steps:
Expected / observed:
Repeatable?:
Capture or saved-view name:
```

## Limits of a passing trial

Human mouse/trackpad, keyboard and comprehension evidence is separate from the
scripted native Windows checks. Mac execution needs a real Mac; the development-engine
embedded-pack check cannot substitute for it. Representative laptop performance,
accessibility acceptance, qualified anatomy/content review and public distribution
remain gates in [RELEASE_CRITERIA.md](RELEASE_CRITERIA.md).
