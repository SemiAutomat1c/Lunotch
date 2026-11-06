# Goal: personal Alcove-inspired macOS notch app

## Mission for the coding agent

Deliver a locally usable personal macOS notch app from the Boring Notch starter that feels fluid and intentional in the way Alcove's marketing demonstrates, while preserving Boring Notch's music, shelf, HUDs, calendar, gestures, and settings. Work autonomously from discovery through verification and documentation. Use original SwiftUI animations and available open-source code; do not copy proprietary Alcove binaries, graphics, or source. Do not publish, push, deploy, purchase software, or redistribute the derivative without a separate user request. Keep GPL-3.0 and upstream attribution intact.

### Workspace and constraints

- Repo: `/Users/ryandeniega/repos/Repo/alcove-personal` (Boring Notch shallow clone, `main` at `b7611bb`).
- Xcode: `boringNotch.xcodeproj`; source: `boringNotch/`.
- User machine: Apple Silicon, macOS 26.5.1, Xcode 26.4.1 (observed 2026-11-06).
- Memory workflow: read `/Users/ryandeniega/Obsidian/AGENTS.md`, its four startup files, and `Projects/Alcove-inspired macOS notch app.md`; write project and daily notes after substantial work.
- Research: `docs/ALCOVE_UX_RESEARCH.md`; raw Firecrawl results in ignored `.firecrawl/`.
- User preference: the app is **only for personal use**; Boring Notch is the starter; motion and UI/UX quality are the primary reason for taking inspiration from Alcove.

### Execute, in order

1. **Inspect and baseline.** Check worktree and all existing local changes, dependencies, Xcode targets/schemes and app requirements. Preserve uncommitted work. Attempt a clean local build before assuming code compiles; investigate Xcode/SwiftPM problems using evidence. Record tool versions and specific failures.
2. **Understand behavior and references.** Read `docs/ALCOVE_UX_RESEARCH.md`, the official Alcove site/changelog and relevant SwiftUI code. Distinguish first-party claims, biased competitor claims and community anecdotes. Focus on feeling and interaction grammar rather than pixel-copying a commercial app.
3. **Motion architecture.** Centralize open, close, hover, drag and content-transition timing. Prefer state-driven, interruptible springs; avoid conflicting implicit animations. Implement reduced-motion support, with opacity and short non-spring transitions.
4. **Notch shell and reveal.** Refine interpolation of width, height, corner shape, shadow and content. Keep a stable collapsed camera-safe geometry and a readable expanded layout. Handle rapid enter/leave, tap, open/close, and drag cancellation.
5. **HUD and activity polish.** Inspect volume, brightness, charging/battery and media HUDs. Adjust transitions, rhythm and spacing where a real issue is found. Keep live media and file shelf usable; avoid blocking interactions or adding continuous idle animation.
6. **Reliability and UX.** Review animations during dragging, hover timing, gesture thresholds, opening while a notification is active, file-drop targeting, notchless displays, and sleep/wake assumptions. Do not remove Boring Notch features or settings to achieve polish.
7. **Build and validate.** Run `git diff --check`, Swift syntax parsing, and `xcodebuild` for the app scheme with signing disabled. Run or manually inspect on the Mac if feasible. Check expand/collapse, hover exit, gestures, shelf, music/HUD, reduced motion and rapid repeated interactions. If runtime testing is unavailable, explicitly label those behaviors **unverified**.
8. **Close out.** Update this document with actual verification and remaining limitations; update Obsy project and the daily note; report the changed files, test results and next realistic step. Do not silently mark blocked or untested work as complete.

### Acceptance criteria

- [x] App builds on the local Xcode toolchain, with an actual successful build log.
- [ ] Expand and collapse feel balanced; hover and content transitions are coordinated and interruptible.
- [x] Accessibility Reduce Motion selects short non-spring, opacity-oriented transitions in the modified views (source checked; visual behavior still needs QA).
- [ ] Existing shelf, music, HUD, settings and swipe/hover actions are not regressed.
- [x] Personal build launches on the Mac and starts the XPC helper; interaction testing gaps are documented below.
- [x] Changes and documentation are reviewable in this local repo; project/daily memory updated.

### Initial known progress (2026-11-06)

Source inspection, Firecrawl research, a central `NotchMotion` timing enum and first `ContentView` animation refinements were completed before this goal document. `swiftc -frontend -parse` and `git diff --check` passed at that point. A prior `xcodebuild -list` has been stuck during package resolution for over 30 minutes and is **not** a successful build. Continue diagnosis and implementation from this worktree; avoid recreating the repo.

### Execution results — November 6, 2026

- **Build:** Xcode 26.4.1 on Apple Silicon macOS 26.5.1 produced `** BUILD SUCCEEDED **` at 14:49 Manila time. Log: `/tmp/alcove-personal-rebrand-build.log`. Command:
  ```sh
  xcodebuild -project boringNotch.xcodeproj -scheme boringNotch -configuration Debug -sdk macosx -destination 'platform=macOS,arch=arm64' -derivedDataPath /Users/ryandeniega/Library/Developer/Xcode/DerivedData/boringNotch-bpaeuyfwookhpndolrkdckqtproc CODE_SIGNING_ALLOWED=NO build
  ```
- **Output:** `~/Library/Developer/Xcode/DerivedData/boringNotch-bpaeuyfwookhpndolrkdckqtproc/Build/Products/Debug/Alcove Personal.app`. App ID: `dev.ryandeniega.alcovepersonal`. XPC helper ID: `dev.ryandeniega.alcovepersonal.BoringNotchXPCHelper`. Debug build, no distribution signing or packaging.
- **Runtime smoke test:** `open -n` launched the local app. The `Alcove Personal` executable remained running after launch; its embedded `BoringNotchXPCHelper` XPC executable and media-adapter subprocess also ran. This validates startup and process linkage only, not correctness of visible interactions.
- **Static checks:** `xcrun swiftc -frontend -parse` across modified Swift sources, `git diff --check`, `plutil -lint` for Xcode project and app plist all passed. Embedded helper plist has the expected personal bundle ID.
- **Motion implementation:** Added centralized `NotchMotion` spring timings for expand/collapse, hover, gesture, content and HUD, with reduced-motion transitions. Refined notch stroke/shadow, HUD/header/content reveal, drag thumb response, cancellation of pending hover/drop tasks and safe sneak-peek notification decoding. Preserved existing shelf/music/calendar/settings implementation.
- **Personal branding:** Changed Finder app product name, visible onboarding/menu/settings labels and bundle IDs. Removed automatic Sparkle update dependency, update feed and public release/update UI for the local fork. Retained original Boring Notch source attribution and GPL-3.0 license.
- **Dependency resolution:** The `lottie-spm` binary artifact was blocked during SwiftPM resolution; using upstream source package `airbnb/lottie-ios` at compatible version fixed the local build. `Package.resolved` records the replacement.
- **Warnings/limitations:** The successful build still reports upstream concurrency warnings, unused variables, and a MediaRemoteAdapter minimum-target warning (framework built for macOS 15, project configured for 14). No crash was observed during the brief launch smoke test. Attempting to capture a cropped notch screenshot returned `could not create image from rect`; visual inspection was therefore unavailable. Expand/collapse animation quality, hover exit/races, drag cancellation, file shelf, actual media/HUD behavior, permissions, notchless screen, multi-display, sleep/wake and Reduce Motion behavior are **unverified at runtime**.
- **Next step:** Follow `docs/LOCAL_TESTING.md` on the Mac; record results and address any issues observed. Changes remain local and uncommitted; no push, install to Applications, or distribution.

### Identity update — November 6, 2026

The working name is **Lunotch**, with an original crescent/island icon, SVG mark and light/dark logo lockups; see `docs/BRAND_IDENTITY.md`. Finder/menu/onboarding/About labels, app/XPC bundle identifiers, macOS icon catalogs, and the appearance-aware accent color now use this identity. The earlier `Alcove Personal.app` build above remains historical evidence; new build evidence appears below once verified. The app is still personal and uncommitted; existing GPL/source attribution remains intact.

### Lunotch branding verification — November 6, 2026 (18:04 PHT)

- **Build:** `** BUILD SUCCEEDED **`, Xcode Debug Apple Silicon/macOS with signing disabled. Log: `/tmp/lunotch-brand-build.log`. Output: `~/Library/Developer/Xcode/DerivedData/boringNotch-bpaeuyfwookhpndolrkdckqtproc/Build/Products/Debug/Lunotch.app`.
- **Bundle metadata:** `CFBundleDisplayName = Lunotch`, main ID `dev.ryandeniega.lunotch`, embedded XPC ID `dev.ryandeniega.lunotch.BoringNotchXPCHelper`. Compiled `Contents/Resources/AppIcon.icns` exists (101 KB).
- **Visual assets:** Generated original PNG app icons for all ten macOS slots, plus both original in-app icon references, standalone 1024 PNG and SVG mark/wordmarks. All PNG dimensions and asset JSON entries match; SVGs passed `xmllint`. Appearance-aware accent tokens are documented; light/dark brand accent contrast against the specified backgrounds is 5.87:1 and 9.39:1 respectively.
- **Code/static checks:** `git diff --check`, `plutil -lint` (project and both source plists), asset PNG validation and successful Swift compilation in the Xcode build. Existing upstream Swift concurrency and macOS target warnings remain.
- **Runtime limitation:** The earlier `Alcove Personal` app was still running during this build; it was deliberately left open to avoid interrupting its user's session. **Lunotch's new build has not been launched or visually QA-tested.** Quit the old app, open `Lunotch.app`, and follow `docs/LOCAL_TESTING.md`. Re-grant macOS permissions if prompted by the new bundle ID.
- **Scope:** All changes local and uncommitted, no push, distribution, domain purchase or registration. GPL-3.0 and Boring Notch attribution retained.

### Lunotch launch smoke test — November 6, 2026 (following the brand build)

- User quit the earlier `Alcove Personal` instance. `open -n` started the branded `Lunotch.app` successfully. A follow-up `ps` showed the main Lunotch executable (PID 76189), embedded `BoringNotchXPCHelper` (PID 76207) and media adapter (PID 76208) running, with no old Alcove Personal app process.
- Observed running processes and main `CFBundleIdentifier = dev.ryandeniega.lunotch`; this confirms startup and helper activation only. Manual interaction/animation quality, shelf, music/HUD controls, permission prompts, camera and reduced motion remain unverified.

### Native motion and gesture refinement — November 6, 2026 (18:30 PHT)

- **Source diagnosis:** `ContentView` animated *every* gesture progress event with an implicit interactive spring, so the response could lag the pointer; it also scaled the whole notch by up to 20% at the activation threshold. The `ScrollMonitor` was installed on the whole window without checking pointer bounds, allowing unrelated scrolling to affect notch state. The music scrubber redundantly animated its `dragging` state during every pointer update.
- **Source changes:** The notch now tracks continuous gesture progress without tweening; whole-surface scale is limited to ±2.5% and springs to rest on release. Upward dismissal and visual reset share a collapse transaction. Scroll gestures are accepted only inside the notch's view bounds, skip inertial momentum and cancel cleanly on pointer exit. Drags require movement beyond the existing small threshold, and the music scrubber tracks values directly. A hover-exit close does not fire while a file-drop zone is active.
- **Verification:** `xcrun swiftc -frontend -parse` on the changed Swift files and `git diff --check` passed. Xcode Debug arm64 macOS build **SUCCEEDED** at 18:30 PHT with `CODE_SIGNING_ALLOWED=NO`; log `/tmp/lunotch-motion-build.log`, output `~/Library/Developer/Xcode/DerivedData/boringNotch-bpaeuyfwookhpndolrkdckqtproc/Build/Products/Debug/Lunotch.app`. Current warnings: existing `MediaRemoteAdapter.framework` targets macOS 15 while app targets macOS 14, and no App Intents dependency for metadata extraction.
- **Runtime scope:** The old Lunotch process (PID 76189) and helper (PID 76207) were still running after the rebuild. The rebuilt code is not verified in a fresh running instance. Follow `docs/LOCAL_TESTING.md` to test quick hovering, swipe threshold/reversal, scroll outside the notch, file drop, music scrubbing, HUDs, reduced motion and multi-display. No commit, push, installation or distribution.
- **Research basis:** Apple's WWDC24 *Enhance your UI animations and transitions* describes continuous gesture retargeting and spring release (https://developer.apple.com/videos/play/wwdc2024/10145/). Apple's SwiftUI `Animation` and `Transaction` documentation describes spring replacement/velocity and continuous state changes (https://developer.apple.com/documentation/swiftui/animation, https://developer.apple.com/documentation/swiftui/transaction). Profile SwiftUI body updates/hitches before further performance tuning (https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance). Firecrawl search archived in ignored `.firecrawl/swiftui-motion-search.json`.

### Alcove-reference focused music player — November 6, 2026 (~22:16 PHT)

- **Reference:** User-provided Alcove music player screenshot. Recreated the composition using native SwiftUI: rounded artwork at the upper left, title/artist next to it, a four-bar animated playback indicator, elapsed/progress/negative remaining time on one row, and five large evenly spaced media controls. Muted blue scrubber fill and subdued secondary text follow the reference. Animation pauses with playback and respects Reduce Motion.
- **Behavior:** Added `focusedMusicPlayer` setting (default enabled) under Media. It shows a full-width player when music is active and the camera preview is closed; existing calendar/camera layout remains when focused mode is off. Five controls are configurable through the existing slot setting, now defaulting to favorite, previous, play/pause, next and **volume** (the reference's final output-device control is approximated by the existing functional volume control). Kept track seek, playback and favorite actions. The mode toggle uses reactive Defaults binding.
- **Verification:** `git diff --check`, Swift frontend parsing of four changed source files, and macOS arm64 Debug `xcodebuild` with signing disabled passed; `** BUILD SUCCEEDED **` in `/tmp/lunotch-focused-player-build.log`. Relaunched the latest executable; observed one Lunotch main process (PID 56377), XPC helper (PID 56395) and media adapter (PID 56396). `minimumHoverDuration` preference remains `0.1` seconds. No commit/push.
- **Remaining:** A display capture attempt failed with `could not create image from display`; screenshot-level alignment, animation smoothness, scrubbing, favorite, volume, playback controls and keyboard/accessibility interactions need human visual/interaction testing. Existing Swift concurrency and minimum macOS version warnings remain. The user can test with an active media track and expand Lunotch at the notch.

### Compact focused music proportions — November 6, 2026 (~22:45 PHT)

- **User feedback:** Compared with the Alcove reference screenshot, the running Lunotch music panel was too wide and too tall.
- **Changes:** Added a focused-music notch size of **450 × 180 points** (formerly the regular **640 × 190** open size), kept the full-size window and regular layout for shelf/calendar/camera, and constrained the focused content to the new compact width. The open shell recomputes its size when the focus, active media or camera state changes. Tightened artwork/title-row spacing, title size and media-control dimensions while keeping the 68-point artwork.
- **Verification:** Swift frontend parse on the four edited Swift files, `git diff --check`, and unsigned arm64 macOS Debug `xcodebuild` passed (`** BUILD SUCCEEDED **`; log `/tmp/lunotch-compact-player-build.log`). Relaunched the rebuilt `Lunotch.app`; observed its main executable PID **63690**, XPC helper PID **63713**, and media adapter PID **63716** running at the time of the check. Saved `minimumHoverDuration` still reads **0.1 seconds**. No commit or push.
- **Still unverified:** The running process alone does not prove the panel matches the screenshot. On-screen spacing/size, long-title truncation, reactive resizing when switching to shelf/calendar/camera, clipping, hover responsiveness, animation continuity, player controls and Reduce Motion need manual visual/interaction QA; screen capture was previously unavailable.

### Prevent intermittent legacy music layout — November 7, 2026 (~01:55 PHT)

- **Root cause:** The new compact `NotchHomeView` and its 450 × 180 shell were gated on `musicManager.isPlaying || !musicManager.isPlayerIdle`. When media became idle after the configured wait, the view and shell returned to the older music/calendar arrangement at 640 × 190. A prior Lunotch instance also survived a normal SIGTERM during relaunch, allowing competing app instances.
- **Source fix:** In `NotchHomeView`, `ContentView` and `BoringViewModel`, compact mode now remains selected on Home whenever the Media setting is enabled and camera preview is closed, independent of playback/idle state. Added a **Nothing Playing** placeholder for no active player and updated the toggle copy to **Use compact music player on Home**. Existing full-size shelf and camera behavior remains intentional; turning the compact setting off restores the previous Home layout.
- **Verification:** `git diff --check`, Swift frontend parse of the four edited Swift files and unsigned arm64 macOS Debug build passed (`** BUILD SUCCEEDED **` in `/tmp/lunotch-stable-compact-build.log`). Terminated the old instance (PID 69028; it did not exit on SIGTERM), then opened the newly built Debug app. Checked that only the new main process (PID 33134) and its media adapter (PID 33149) remained. Source/build/launch checks passed; idle-timeout switching and the on-screen appearance still require interactive confirmation.
- **Scope:** Local source and Debug build only. The previously published `v0.1.0-preview.1` DMG is unchanged. Concurrent icon/brand edits in the worktree were preserved; no commit/push/release as part of this fix.


### First GitHub preview packaging — November 6, 2026

- **Distribution intent:** User explicitly requested the new `SemiAutomat1c/Lunotch` repository and an installable DMG. Maintained the complete upstream Boring Notch Git history, original GPL-3.0 text and third-party notices; added unmistakable derivative credit in the Lunotch README and concise Contributing/Security docs. Removed inherited upstream release/CI/Crowdin workflows and appcast files and replaced obsolete upstream `Configuration/dmg` packaging with `scripts/package-dmg.sh`. This prevents the personal fork from running upstream release automations or advertising Boring Notch downloads as Lunotch installers.
- **Version:** Renamed the app/helper marketing version to `0.1.0` (build `1`). Signed local Release build for Apple Silicon succeeded at `/tmp/lunotch-release-final-build.log` using `CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-`. `codesign --verify --deep --strict` passed for the Release app and embedded helper; app bundle identifier confirmed as `dev.ryandeniega.lunotch`.
- **DMG:** Built `dist/Lunotch-v0.1.0-preview.1-arm64.dmg` using a staging folder with `Lunotch.app` plus `/Applications` link; `hdiutil verify` passed, and a readonly mounted inspection confirmed executable, symlink, arm64 Mach-O, bundle version `0.1.0` and code signature. SHA-256: `b3610d1ed9072d1559e2bcb532c99e49f2e5c53c907b2c88cc7ba9990e6c64d5`; size about 7.9 MiB. The artifact is intended for the GitHub release asset, not the Git source tree.
- **Limitations:** Ad-hoc signing is not Developer ID distribution or notarization. Full on-device interaction QA, multiple macOS versions, notchless/external displays, camera and accessibility remain open. GitHub release publish/verification should be recorded separately after completion.

### Published preview verification — November 6, 2026

- Public GitHub repository `https://github.com/SemiAutomat1c/Lunotch`, `main` commit `40845848546226de11c7d126addb6689cda9581c`, preserving 1,329 upstream commits from Boring Notch. The former `origin` is preserved as `upstream`; new `origin` is the user's Lunotch repository.
- Published GitHub **pre-release** tag `v0.1.0-preview.1` pointing to the same commit and uploaded `Lunotch-v0.1.0-preview.1-arm64.dmg` (8,276,177 bytes) to `https://github.com/SemiAutomat1c/Lunotch/releases/tag/v0.1.0-preview.1`. A downloaded copy from GitHub matched the local SHA-256 `b3610d1ed9072d1559e2bcb532c99e49f2e5c53c907b2c88cc7ba9990e6c64d5`. Release is public and non-draft.
- GitHub description and topics updated. No CI or automatic releases are active after removing the old project's workflows. Important unfinished task: manual visual/interaction QA plus Developer ID signing and notarization if wider distribution is planned.

### B2 complete brand integration — November 7, 2026 (~02:24 PHT)

- Applied the selected B2 Lunar Droplet identity to the `LunotchMenuIcon` adaptive macOS menu-bar template (28×18 at 1x; 56×36 at 2x), `logo` and `logo2` images used in onboarding/Settings, and light/dark wordmark SVGs. The app-icon catalog already contained B2. `swift brand/render-b2-icon.swift` regenerates all PNG derivatives from editable SVG masters.
- **Verification:** Swift parsing, asset sizes/JSON, `git diff --check`, and compiled asset catalog check (`LunotchMenuIcon` Template Mode = `template`) passed. Unsigned macOS arm64 Debug Xcode build **SUCCEEDED**, log `/tmp/lunotch-b2-complete-build.log`.
- **Runtime:** Quit older main PID 33134, which survived SIGTERM and required targeted SIGKILL, then launched rebuilt app and observed one main PID 43212 plus helper 43238 and media adapter 43241. `screencapture` failed (`could not create image from display`), so menu-bar / Finder / in-app visual accuracy and interaction flows require manual on-device testing. The public v0.1.0-preview.1 DMG is unchanged. No commit, push or publication.

### Preview.2 polish and packaging — November 7, 2026 (~02:47 PHT)

- Revised focused album art to an explicit 68×68 clipped button, refined track-skip icons, constrained battery percentage to one horizontal line, compacted header controls, guarded invalid playback-time labels, and added explicit notch/view sizing animations. The earlier idle-stable 450×180 focused Home behavior is retained. The B2 app, menu-bar and in-app identities are included.
- Internal build number increased from 1 to **2**, marketing version remains 0.1.0. Full arm64 Release Xcode build passed (`/tmp/lunotch-preview2-release-final-build.log`), code signing verified, compiled menu-bar B2 template assets confirmed, project plist lint and `git diff --check` passed. Preexisting Swift concurrency and macOS 14/15 media-adapter linkage warnings remain.
- Created **`dist/Lunotch-v0.1.0-preview.2-arm64.dmg`**, SHA-256 `91d012b49758a886dc685be672283e40eefef7271114d996db8bf4feec82bf84`. `hdiutil verify` succeeded. Read-only mounting confirmed `Lunotch.app` (build 2), `/Applications` symlink and valid app signature. Disk image is gitignored.
- On-screen inspection and manual flows remain unverified because display capture failed earlier, and the attempted local app restart/launcher patch was blocked by current tool safety checks. The old-layout restart ambiguity is documented for later investigation; no runtime visual assertions are made here. See `docs/RELEASE_NOTES_PREVIEW2.md` and `docs/LOCAL_TESTING.md`.
