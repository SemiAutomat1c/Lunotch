# Alcove-inspired notch UX research

Research captured on 2026-11-06 with Firecrawl CLI. Product descriptions are vendor claims; indexed community comments are anecdotes, and the Seam comparison is written by a competing vendor. The research is design guidance, not a measured feature, performance, or stability benchmark.

## What makes Alcove appealing

Alcove leads with **fluid transitions** and a cohesive Dynamic Island-like surface. Its site highlights instant notifications, Live Activities, swipe gestures, configurable HUDs, lock-screen widgets, and a native-feeling presentation. Its changelog gives more concrete motion cues:

- v1.6: HUD overshoot, progressive blur, and wider display/device support.
- v1.7: simultaneous activities (Duo mode), a compact pill for notchless displays, waveform, outlines, and richer music handling.
- v1.5: Tahoe visual refresh and multiple activities; earlier versions added calendar/lock-screen widgets and media controls.

Indexed community discussions describe Alcove as smooth, seamless, polished and stable. These are impressions from selected comments; no controlled side-by-side timing, crash, CPU or battery measurements were obtained. Seam's September 2026 comparison (updated November 2) similarly praises Alcove's visual feel while noting Boring Notch's broader utility and file shelf. Seam sells its own competing notch app, so its conclusions may be biased. Its claim that Boring Notch lacks swipe gestures is contradicted by the checked source code: `ContentView.swift` already registers up/down pan gestures.

## Preserve Boring Notch's useful baseline

The checked starter provides a music activity/visualizer, file shelf with drop interactions, HUD presentation, calendar and other integrations, hover/tap and swipe controls, and several customization flags. Keep these working. An Alcove-style upgrade should focus first on continuity between closed, expanded, and HUD states, without introducing a duplicate activity system.

## Prioritized personal build

| Priority | Desired behavior | Evaluation |
| --- | --- | --- |
| P0 | Unified, interruptible expand/collapse, gentle hover response, and content reveal | Quick repeated open/close/hover does not flicker or leave a stuck state; reduced-motion setting stays subtle. |
| P0 | Smooth closed-to-open shape and width/height changes | Corner radii and content track the same state; no clipping or sudden snap. |
| P1 | Consistent HUD entrance/exit, proportionate sizes and padding | Volume, brightness, battery and music remain legible and do not collide with the camera/notch. |
| P1 | Reliable shelf, gestures, hover and wake behavior | File drops and up/down gestures still work; sleep/wake manually tested where possible. |
| P1 | Responsive, non-distracting animation | Transitions feel quick, can be interrupted, and do not loop continuously while idle. |
| P2 | Simultaneous activities, progressive blur, optional pill mode and waveform polish | Explore individually only after a built, working baseline. |

## Sources and confidence

- Alcove product: https://tryalcove.com/ (first-party product claims)
- Alcove release notes: https://tryalcove.com/changelog (first-party release summaries)
- Alcove FAQs: https://tryalcove.com/faqs (first-party)
- Competitor comparison: https://getseam.app/blog/alcove-vs-boring-notch (Seam marketing; cross-check claims)
- Indexed discussion: https://www.reddit.com/r/macapps/comments/1hxs1s3/should_i_switch_to_alcove_notch_app/
- Indexed launch discussion: https://www.reddit.com/r/macapps/comments/1gltlih/alcove_a_new_dynamic_islandnotch_app/
- Local upstream baseline: `boringNotch/ContentView.swift`, `boringNotch/components/Notch/NotchShape.swift`, `boringNotch/components/Live activities/`

Firecrawl does not support scraping Reddit directly in this environment; community impressions come from search snippets, not a complete comment review. The raw research remains in ignored `.firecrawl/` files. No claim is made that Alcove proprietary code or assets were examined or copied.
