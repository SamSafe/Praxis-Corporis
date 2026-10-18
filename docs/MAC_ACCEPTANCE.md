# Mac acceptance run

Use the current private candidate. This is an actual-device test of the app and
controls; it does not establish medical accuracy or complete anatomy coverage.

- Archive: `dist/build-identity-improvements/PraxisCorporis-macOS-universal-private.zip`
- Bytes: `350671781`
- SHA-256: `7d900e32b30ffd4a46639bfc6f5b082799260c3b3d0de4994dec3fea98f57bd4`
- Build ID: `f962ce195f324c89a400cf07d8767c9d`
- Version: `0.1.0` (private)
- Runtime source: `c86cfba1e544b20917b66c14ea405f0b74abfd47`
- Build/audit: [verification](audit/BUILD_IDENTITY_VERIFICATION.md)

This packet identifies the newly stamped candidate. If testing an earlier package
has begun, keep its [9e864a0 template](trials/MAC_9E864A0_TEMPLATE.md) or
[6a878b7 template](trials/MAC_6A878B7_TEMPLATE.md), and include that source/hash with
observations. Earlier observations remain attached to their tested version.
No Mac results have yet been recorded.

Copy the complete ZIP to the Mac, extract it and open `PraxisCorporis.app` inside
`PraxisCorporis`. Anatomy is inside the app bundle. Follow the existing
[Mac launch guidance](NATIVE_BUILDS.md#run-a-build) if macOS asks about the private
ad-hoc-signed application. Record the exact message if it will not open.

Use throwaway saved views and fictional notes for these checks. Keep a copy of the
[results template](trials/MAC_C86CFBA_TEMPLATE.md). Mark each task Pass, Fail or
Blocked and describe any unexpected behavior. A failed task is useful evidence.

| Task | Expected result |
| --- | --- |
| Launch without network access | The app opens a reference from its bundled content. Coverage and private-draft status are visible. Sources shows the build ID above; it also appears in START_HERE.txt. |
| Female and male exploration | Both HRA references open. Orbit, pan and zoom work with the actual mouse/trackpad. Select, focus and Back return to useful anatomy views. |
| Search and keyboard | Cmd+F opens anatomy search; Enter selects a source result; Escape clears search then returns to anatomy. Try `left atrium` and `UBERON0002135` in either HRA body. |
| Paged records | Turn on List view; browse Previous/Next and select a real source record. Search still finds it; clearing search returns to the chosen mode. Turn List view off to return to the hierarchy. |
| Inspect and restore | Inspect a supplied part alone, then Return to context. Turn Move on, move a part, Undo, then restore it. Ordinary orbit does not move anatomy. |
| Separate studies | Open the bone study and all four spinal studies. Each loads, can select/focus a supplied part and clearly identifies its separate, unregistered source status. |
| Compact/expanded layouts | Resize the window; try expanded anatomy and 130% text. Reach study text, actions, labels and a clear return path without clipped controls. |
| Study reading and sources | Open Read study card and a condition summary. Scroll/read sources, close with Escape and continue navigating. A source link opens the browser or leaves a usable address on failure. |
| Notes, backup and import | Save a test view with multiline notes such as `Café 🫀`. Cmd+S saves notes. Export through the native picker, then import through its compatibility preview. The notes and source reference stay intact. |
| Unfinished-note protection | Change a test note, then try closing the library and quitting the app. Keep editing preserves the draft. Save notes persists it. Test the actual Cmd+Q route too. |
| Screenshot | Use Screenshot and the native save picker. Reopen the PNG: anatomy, source credits and draft/review status are present. |
| Restart | Close normally and reopen. The last successful reference/window layout returns; named saved views and notes can be reopened. |
| Accessibility observation | If available, try VoiceOver on named core controls, List view records/paging, anatomy search, the saved-view filter and the note editor. Record missing names, unusable focus or actions. This observation does not by itself establish conformance. |

Record stalls, loading problems, heat/noise or responsiveness issues as observations.
This short run does not measure sustained FPS or pass the separate
[performance protocol](PERFORMANCE_PROTOCOL.md).

Send the completed observations in the conversation. Model/macOS version, which
tasks failed and exact messages are the most useful first details. No automatic
upload or contact with other people is involved.
