# Lunotch v0.1.0-preview.2 — B2 branding and focused-player polish

This is an experimental **Apple Silicon (arm64)** macOS preview, version **0.1.0 (build 2)**.

### What's changed

- Applied the **B2 Lunar Droplet** design to the Finder app icon, light/dark menu-bar template symbol, in-app marks and wordmarks.
- Kept the **450 × 180-point compact Home music view** selected when playback pauses or metadata goes idle; show a no-media placeholder when appropriate. The full shelf/camera layout remains larger.
- Constrained focused album artwork to a crisp **68 × 68-point** rounded square; refined track-skip glyphs and handled non-finite playback-time text.
- Tightened compact header spacing and fixed the battery percentage label's horizontal layout to address wrapping at **100%**.
- Added explicit native animation for notch-size and view changes. Motion still respects the Reduce Motion preference.

### Install

1. Download **Lunotch-v0.1.0-preview.2-arm64.dmg** from the release assets.
2. Open the disk image and drag **Lunotch.app** to **Applications**.
3. Quit other running copies of Lunotch and Boring Notch before opening the installed app; the app normally lives in the menu bar/notch, not the Dock.
4. The build is **ad-hoc signed, not Apple Developer ID signed or notarized**. macOS may require **System Settings → Privacy & Security → Open Anyway** after an attempted launch. Only use that option when you trust the download.

**SHA-256:** `91d012b49758a886dc685be672283e40eefef7271114d996db8bf4feec82bf84`

### Verification and known limits

The Release build succeeded on Apple Silicon with Xcode 26; deep code-signature verification passed, the compiled B2 menu-bar image assets were present at 1×/2× as templates, and the DMG passed checksum verification and read-only mount inspection. The DMG contains the expected app and Applications shortcut.

**Manual visual and interaction testing is still open.** Screen capture was unavailable on the development Mac during this session. Hover responsiveness, player controls and seeking, music idle behavior, battery alignment, real animation smoothness, shelf, camera, HUD, external displays, accessibility and sleep/wake have not been validated on screen for this build. Some restarts may open an older installed copy when multiple apps share the same bundle identifier; confirm the exact app being launched. Existing Swift concurrency warnings and a media-adapter macOS minimum-version mismatch remain. The Xcode project targets macOS 14, but the media adapter targets macOS 15; macOS 15+ is the practical starting point, without broad compatibility verification. There is no automatic updater.

### Credits and licensing

Lunotch is an independently branded derivative of [Boring Notch](https://github.com/TheBoredTeam/boring.notch), licensed under **GPL-3.0** with upstream source history and notices retained. Its UI motion is inspired by public previews of [Alcove](https://tryalcove.com/). There is no affiliation with or endorsement by either project. Sources and licenses are available in [SemiAutomat1c/Lunotch](https://github.com/SemiAutomat1c/Lunotch).
