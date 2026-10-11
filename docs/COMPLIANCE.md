# Release Requirements: Accuracy, Rights, Access, and Distribution

Status: product requirements and unresolved dependencies, not a legal or medical
certification. Detailed jurisdiction-specific obligations are not determined here.

## Medical accuracy

The app provides general educational anatomy and authored conditions. It does not
accept patient records or provide patient-specific diagnosis/treatment.

Private drafts identify incomplete or unreviewed content. Public material must
carry source and review evidence for the published version, including appropriate
review of visual anatomy, pathway relationships, and condition/injury explanations.

No qualified reviewer is currently available. Recruiting review is an unresolved
public-release dependency, not a reason to stop planning or private development.
A disclaimer or successful usability test is not accuracy validation.

Use a concise educational-purpose statement in onboarding/About and contextual
source/review information in details. Avoid filling ordinary exploration with
development metadata; expose information that helps learners judge content.

## Content rights

Every imported asset has source, creator, version, licence, modifications, and
required attribution. Assess permissions for distribution, changes, future paid
features, exported views, and content updates.

The proposed policy prefers commercially reusable sources and excludes
noncommercial assets from the core. Do not infer that a licence on one original
dataset clears all contributions in a derivative atlas.

CC BY requires credit and change notices under its terms. CC BY-SA adds obligations
for distributed adaptations; neither licence is inherently a prohibition on charging.
[CC BY](https://creativecommons.org/licenses/by/4.0/),
[CC BY-SA](https://creativecommons.org/licenses/by-sa/4.0/).

Keep application and content licence decisions explicit. Separation of files alone
does not answer every licensing question. Application licensing is unresolved and
must be chosen before distributing code.

Maintain [ATTRIBUTIONS.md](../ATTRIBUTIONS.md) and a per-asset record; carry applicable
credits with screenshots and other exported material.

## Privacy

Proposed first release stores preferences, bookmarks, notes, and saved views locally.
No account or telemetry is required. Explain what is saved and provide backup,
export, and deletion controls. Logs should avoid recording note contents by default.

Feedback from private testers is shared intentionally. Cloud sync or analytics
would require a separate data-handling design; neither is assumed here.

## Accessibility and usable controls

- Keyboard-operable browsing, search, panels, labels, and core viewer actions.
- Trackpad alternatives to secondary-button and precision-drag gestures.
- Visible focus, readable typography, adjustable label density, and scalable UI.
- Non-colour cues for selection and condition highlights.
- Reduced-motion camera transitions.
- A text structure/relationship list as a parallel way to explore.
- Testing with actual assistive technology before claiming a level of conformance.

Native UI does not automatically establish screen-reader accessibility. Treat it
as a feasibility and testing item. No accessibility certification is claimed.

## Desktop distribution

Initial proposal: direct downloads for Windows x64 and universal macOS builds,
with clearly stated tested OS/hardware support.

Godot documents Windows signing and macOS signing/notarization. Mac public
distribution should use the normal signed/notarized path rather than expecting
learners to bypass platform protections.
[Windows export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html),
[macOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html).

Certificates, developer accounts, hardware access, and any associated distribution
costs remain to be arranged. Free anatomy assets do not establish a zero-cost public
distribution process. No purchases or account registrations are authorised by this plan.

Version app and content separately, validate acquired packs, preserve local saves,
and recover from interrupted updates. Choose an update mechanism after packaging
evaluation; a hosted service is not assumed.

## Public-release checklist

Detailed gates are in [RELEASE_CRITERIA.md](RELEASE_CRITERIA.md): declared content
coverage, reviewed medical material, compatible asset licences, working core journey
on both bodies, measured performance, accessible controls, recoverable saves, and
tested platform distribution.
