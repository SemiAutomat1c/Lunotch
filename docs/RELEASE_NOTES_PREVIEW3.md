# Lunotch v0.1.0-preview.3 — Screenshot Studio, Work Mode and refreshed branding

This is an experimental **Apple Silicon (arm64)** macOS preview, version **0.1.0 (build 3)**. It includes changes pushed through November 9, 2026.

### What’s new

- **Screenshot Studio:** click the camera shortcut in the notch or use the menu to select part of a screen through ScreenCaptureKit; import an image from the clipboard or a file; opt into screenshot-folder previews. Edit with crop, text, arrows, pen, highlights, shapes, opaque redaction, undo/redo, zoom and PNG export.
- **Work Mode:** separate utility window with 15/25/45/60-minute focus sessions, approximate RAM view, explicitly confirmed browser-close action, and local Markdown research notes with URL import and source copy.
- **Smaller music Home:** focused panel reduced from **450 × 180** to **400 × 166 points** with **58-point** artwork, tightened header/battery layout, and five configurable media controls.
- **Lunotch identity cleanup:** removed unused upstream icon/logo files and obsolete localization keys; updated onboarding, About and Appearance wording while preserving Boring Notch GPL-3.0 credit.

### Installation

1. Download **Lunotch-v0.1.0-preview.3-arm64.dmg** from this release's assets.
2. Open the DMG and drag **Lunotch.app** into **Applications**, replacing the previous version if desired.
3. Quit any previous running Lunotch or Boring Notch copy before launching the installed app. Lunotch runs primarily in the menu bar/notch rather than the Dock.
4. This DMG is **ad-hoc signed and not Developer ID signed or notarized**. macOS may block first launch; if you trust the asset after verifying its checksum, use **System Settings → Privacy & Security → Open Anyway** when offered. There is no automatic updater.
5. Screen capture requires macOS **Screen & System Audio Recording** permission. Switching between differently signed builds with the same bundle identifier may require a fresh grant. Restart Lunotch after granting permissions if macOS requests it.

**SHA-256:** `c840dbb4596148d322a86a41a05f8e159567be39f0c8522c04d1f118cea2b10f`

### Verification and known limits

The Apple Silicon Release build **succeeded**. The arm64 app and embedded helper passed strict code-signature verification; the app reports version **0.1.0 (build 3)**, and the compiled assets include the current Lunotch identity. The packaged DMG passed integrity verification and a read-only mount check, including its Applications shortcut and packaged app signature. Work Mode's 15-minute timer Start/Pause/Reset, RAM display, browser close **Cancel**, and Markdown note Save/Append passed earlier live QA. Other Work Mode presets, browser close confirmation behavior, ScreenCaptureKit authorization, selection/crosshair, editor interactions, compact-player alignment, external-monitor behavior and broader macOS support **have not been fully verified on-device**. Use the experimental preview accordingly.

The project targets macOS 14, but its media adapter currently targets macOS 15; **macOS 15+** is the practical starting point, without a broad compatibility guarantee. Existing Swift concurrency and MediaRemoteAdapter deployment-target warnings may remain.

### Credits

Lunotch is an independently branded [Boring Notch](https://github.com/TheBoredTeam/boring.notch) derivative distributed under **GPL-3.0**, with upstream source history and notices retained. Motion and music-layout ideas draw on public [Alcove](https://tryalcove.com/) previews; neither project endorses or is affiliated with Lunotch. Source and license files are in [SemiAutomat1c/Lunotch](https://github.com/SemiAutomat1c/Lunotch).
