# Compliance, Licensing & Liability

Read this before publishing anything. None of this is legal advice — when money or
public release is involved, consult a real lawyer. But these are the issues you must not
ignore.

## 1. Medical disclaimer (do this from day one)

The moment the app states medical facts, add a persistent, unmissable disclaimer:

> **For educational and study purposes only. Not medical advice. Not a diagnostic tool.
> Do not use for clinical decision-making. Content may be incomplete or inaccurate;
> verify against authoritative sources.**

While content is unverified, also surface per-item review status (e.g. a "draft —
unverified" badge), per [CONTENT_PIPELINE.md](CONTENT_PIPELINE.md).

## 2. Regulatory line: education vs. medical device

- An **educational/study tool** is low-risk.
- A tool that **diagnoses, recommends treatment, or guides clinical decisions** can be
  regulated as a medical device (FDA in the US, CE/MDR in the EU). This is a different
  universe of cost and liability.
- **Stay firmly on the education side** (it's a non-goal to cross it — see
  [VISION.md](VISION.md)). Avoid any feature that outputs patient-specific guidance.

## 3. Content licensing (the part that sinks projects)

Two separate licenses:

### Code license
Pick one for *your* code (MIT/Apache-2.0 if you want it open and reusable; AGPL if you
want derivatives kept open). Decide and record as an ADR.

### Content license — handle each asset and text source individually
- **3D models:** every model needs a documented license permitting your use
  (and redistribution, if you ship the file). CC-BY requires attribution; CC-BY-SA
  requires share-alike; CC-NC blocks commercial use; "free to download" ≠ "free to
  redistribute." Track license + attribution per asset in `content/_references/`.
- **Text:** you may **not** copy textbook/atlas text. Write original summaries and cite.
  Facts aren't copyrightable; *expression* is. Netter-style illustrations are
  copyrighted — don't trace or reproduce them.
- **Trademarks/eponyms:** fine to *name* conditions; don't imply endorsement.

### Attribution file
Keep a top-level `ATTRIBUTIONS.md` / `NOTICE` listing every third-party asset, its
source, license, and author. Required by most open licenses and good hygiene regardless.

## 4. Privacy & data

- v1 is **local-first** (progress stays on device) — minimal privacy exposure.
- The moment you add accounts/sync/analytics: add a privacy policy; minimize data;
  remember **GDPR** (EU) and that any *real* patient data would trigger **HIPAA**-type
  obligations (another reason to never accept patient data).
- Don't add third-party analytics/trackers silently.

## 5. Accessibility

If students with disabilities will use it (and for any institutional adoption), aim for
**WCAG 2.1 AA**: keyboard navigation, color-contrast, screen-reader labels, non-color
cues. Hard with pure 3D — plan text-equivalent interactions early.

## 6. If you ever monetize or seek institutional adoption

- Terms of Service + Privacy Policy become mandatory.
- Institutions will ask about accessibility, data handling, and content provenance —
  the citation registry and attributions file are exactly what they'll want to see.

## Checklist before any public release

- [ ] Disclaimer banner present and unmissable
- [ ] Every 3D asset has a recorded, compatible license + attribution
- [ ] No copied textbook text or traced copyrighted figures
- [ ] `ATTRIBUTIONS.md` complete
- [ ] Code license chosen (ADR recorded)
- [ ] Review-status badges shown for unverified content
- [ ] Privacy policy if any data leaves the device
