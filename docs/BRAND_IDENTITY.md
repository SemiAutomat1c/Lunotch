# Lunotch — personal macOS notch app brand (v1)

- **Name:** Lunotch
- **Pronunciation:** *loo-notch*
- **One-line positioning:** A lively little space around your Mac's notch.
**Tagline:** **Your Mac, a little more alive.**

Lunotch combines *luna* (moon) with *notch* (the camera cutout). It is an original identity for the personal SwiftUI app built on Boring Notch, with fluid transitions inspired by Alcove's public-facing UX. The distinctive mark combines a crescent/orbit with a floating island; it intentionally does not reproduce the Alcove name or logo.

## Name screening, November 6, 2026

| Candidate | Checks | Decision |
| --- | --- | --- |
| **Lunotch** | GitHub Search API (`lunotch in:name`): **0** matching repositories; Apple iTunes Search API for `macSoftware`, US: **0**, PH: **0**; Verisign RDAP `lunotch.com`: HTTP **404** (no domain record returned). Broad web queries for `"Lunotch" app macOS notch` and `"Lunotch" software` returned no exact named app results. | **Selected as a working personal-use name.** |
| Islune | GitHub exact-name and Mac App Store searches returned no results; `islune.com` was registered in RDAP. | Avoided because the domain is occupied. |
| Pillune | GitHub exact-name query returned one similar repository, and `pillune.com` returned RDAP 404. | Backup option; less clear connection to the notch. |
| Notchlet / Nimlet | Earlier online searches surfaced existing uses. | Avoided because of name overlap. |

Name-check URLs: [GitHub API](https://api.github.com/search/repositories?q=lunotch+in%3Aname), [Apple US](https://itunes.apple.com/search?term=lunotch&media=software&entity=macSoftware&country=us), [Apple PH](https://itunes.apple.com/search?term=lunotch&media=software&entity=macSoftware&country=ph), [Verisign RDAP](https://rdap.verisign.com/com/v1/domain/lunotch.com).

**Scope:** These are point-in-time discovery results, not guarantees that the name is unique, that a domain can be registered, or that no confusingly similar trademark exists. WIPO's Global Brand Database and the applicable official trademark registries were identified for future clearance but not exhaustively searched. No domain/trademark purchase or registration was made. Re-run checks before any public launch. See [WIPO availability guidance](https://www.wipo.int/en/web/madrid-system/check-availability) and [IPOPHL trademark search](https://www.ipophil.gov.ph/trademark/trademark-online-tools/).

## Logo system

- **App icon / compact mark:** `brand/lunotch-mark.svg`, `brand/lunotch-icon-1024.png`. Moon-like incomplete orbit surrounds a minimal floating island. It reads as motion and a macOS notch at Dock and menu sizes.
- **Horizontal wordmark:** `brand/lunotch-lockup-dark.svg` and `brand/lunotch-lockup-light.svg`, both editable SVG. Lowercase *lunotch* communicates a quiet, friendly utility.
- **Xcode asset sizes:** `boringNotch/Assets.xcassets/AppIcon.appiconset` includes macOS 16/32/128/256/512 point assets and their @2x variants. `logo` and `logo2` assets reuse the compact symbol for existing in-app references.
- **Reproducibility:** From repo root, run `swift brand/render-icons.swift` to regenerate native PNGs and asset manifests. The SVG describes the same original geometry; the native renderer adds subtle tile shading and a floating-island shadow.

**Clear space:** For the lockup, leave at least half the icon tile's rendered height on every side when space allows. Do not distort, rotate, recolor individual pieces, or place the light lettering over a bright photograph. Use the compact icon at small sizes; use wordmark lockups where legibility permits.

## Color palette

| Token | Hex | Use |
| --- | --- | --- |
| Midnight | `#0B1022` | Icon base, dark brand surface |
| Deep indigo | `#252044` | Low-contrast depth, dark gradient |
| Moon white | `#F3F1FF` | Brand text on midnight |
| Soft lunar | `#D6D1FF` | Crescent / island border |
| Lavender | `#B9B5FF` | Primary orbit highlight |
| Periwinkle | `#7889FF` | Motion / orbit finish |
| Light surface | `#F6F5FF` | Light brand surface |
| Ink | `#151A32` | Text on light surface |
| Light-mode accent | `#5A55A9` | Interactive emphasis on light surfaces; 5.87:1 against Light surface |
| Dark-mode accent | `#B4AEFF` | Controls and emphasis on Midnight; 9.39:1 contrast |

The `AccentColor` asset has separate light/dark appearances. Keep native macOS system colors for normal form controls, statuses and error feedback, and let the user's existing settings take priority where applicable.

## Type and motion

Use **SF Pro Display** for wordmark and large headers, **SF Pro Text** or system SwiftUI type for body copy. Prefer native Dynamic Type sizes and weight differences over decorative effects. The icon uses a soft, purposeful orbit; product transitions should stay smooth and interruptible. Respect **Reduce Motion**, avoid permanent idle loops, and preserve Boring Notch's existing feature interactions.

## Voice and sample copy

Lunotch speaks like a quiet, useful personal Mac companion: short, warm, and concrete. Avoid hype and promises about performance. Example microcopy: “Your Mac, a little more alive.” / “Drop to keep it nearby.” / “All set.” / “Allow access to show your calendar here.”

## In-app implementation and attribution

- Finder product name, menu bar title, onboarding, settings title and About view use **Lunotch**.
- Main bundle ID: `dev.ryandeniega.lunotch`; embedded XPC helper bundle ID: `dev.ryandeniega.lunotch.BoringNotchXPCHelper`. The helper target keeps its upstream internal technical name.
- Because the bundle ID changed, macOS may ask for camera, calendar, Reminders or Accessibility permission again. Quit the old `Alcove Personal` build before launching the new one to avoid duplicate notch overlays.
- Keep upstream Boring Notch attribution, copyright notices and `LICENSE` (GPL-3.0). The source is published as a personal GPL-3.0 preview fork at https://github.com/SemiAutomat1c/Lunotch; its first installable DMG is ad-hoc signed, unnotarized, and offered without broad QA claims. Lunotch is not affiliated with Alcove or the Boring Notch team.
