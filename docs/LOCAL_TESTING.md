# Lunotch: local launch and interaction checks

This is a personal macOS fork of Boring Notch. Development runs use a local Debug build; v0.1.0-preview.2 is an ad-hoc signed Release build without Apple Developer ID notarization. A B2-branded Debug app previously launched with one main process plus its helper and media adapter, but the new focused-layout polish has **not** been observed on-screen. Screen-level behavior still needs hands-on verification.

## Open the build

```sh
open -n "$HOME/Library/Developer/Xcode/DerivedData/boringNotch-bpaeuyfwookhpndolrkdckqtproc/Build/Products/Debug/Lunotch.app"
```

It runs in the menu bar/notch rather than as a normal Dock app. Quit the currently running **Lunotch** instance via its menu bar Quit command before launching the newly compiled build, to avoid two notch overlays. Grant permissions again if macOS prompts because the bundle identifier changed. Only enable camera, calendar, Reminders, or Accessibility permissions if you want the corresponding features.

## Manual QA to complete

1. Hover over and click the notch to expand/collapse. Repeat quickly, move the cursor away while animating, and check that the notch closes correctly without flicker or blocking the camera/menu bar.
2. Swipe/drag the notch and interrupt a gesture halfway. Verify it returns to a stable size. Repeat with a file dragged across the shelf and remove the test file afterward.
3. Play music, pause, skip, and test volume/brightness HUD updates. Confirm shelf, calendar, settings and other existing features still respond as expected.
4. Turn on **System Settings → Accessibility → Display → Reduce motion**, then repeat open/close, hover and HUD interactions. The changed transitions should use short fades rather than bouncing/moving. Restore your personal preference afterward.
5. If using an external monitor or a notchless display, test target positioning, mouse entry, and sleep/wake. Watch for stalls or multiple overlays when changing displays.
6. With gestures enabled, start a down/up swipe but release **before** the activation threshold: the shell should settle, with no open/close or haptic. Repeat using the trackpad, mouse wheel, and by reversing direction midway. Cross the threshold and check for exactly one transition and haptic. Verify a slow scroll on controls outside the notch does not toggle it; inertial/momentum scroll should not trigger a second action.
7. Drag in and out of the notch repeatedly while hovering, then move a file toward the shelf. It should stay open during active file-drop targeting, even when hover ends. After the drop ends it may close normally.
8. Drag the music scrubber slowly and rapidly. The fill should follow the pointer without a spring delay; only the track thickness should animate. Check normal play/pause and skip controls still respond.
9. Start a track, then expand the notch: compare its **450 × 180-point compact shell** and internal spacing against the supplied Alcove screenshot. Check artwork, title/artist (including very long titles), gently animated four bars, blue inline progress timeline with negative remaining time, and five evenly spaced actions. Look for clipping and excess blank space. Test **Shuffle / Previous / Play-Pause / Next / Sound Output**, seeking and track changes; confirm bars stop when paused and under Reduce Motion. The output-device icon opens macOS Sound settings for device selection (it does not show an in-notch device picker). Favorite and Volume remain available in the editable control palette. Check that existing users with the previous unmodified five-slot default are migrated to the new row; customized layouts should remain intact.
10. In Settings → Media turn **Use compact music player on Home** off and on; verify the regular calendar layout returns at the normal width when off, and focused mode returns at compact width when on. Pause media and wait beyond the media idle timeout: Home should remain at **450 × 180 points**, showing a placeholder if no player remains available, without reverting to the 640 × 190 legacy player. Switch between music and shelf/calendar/camera while expanded, watching for resizing hitches or stale width, and verify no overlapping controls. The previous 0.1-second hover-opening preference should remain intact.

11. Visually inspect the B2 Lunar Droplet mark in Finder, onboarding and Settings → About. Check the monochrome menu-bar symbol on light and dark surfaces for contrast and clear inner cutouts. The `LunotchMenuIcon` asset is integrated, but `screencapture` failed (`could not create image from display`), so visual QA remains open.

12. Check the **100%** battery label beside the physical notch: it should remain horizontal without wrapping or clipping. Check that the focused 68 × 68-point album art is square, previous/next controls use the double-triangle transport glyphs (`backward.fill` / `forward.fill`), the central play/pause icon is larger, and the Sound Output icon appears muted. Open and close the player rapidly, then switch between shelf, calendar and media to check size-change smoothness. If the old layout returns after restart, check that an old installed app was not selected by the restart helper and that no duplicate Lunotch processes are running.

When rebuilding, close any existing Lunotch process before opening the new app. The November 7 restart found that SIGTERM alone did not end an older main process, leaving two instances and potentially two competing notch overlays. Confirm one `Lunotch.app/Contents/MacOS/Lunotch` process after relaunch. Do not terminate unrelated system `mediaremote` processes.

## If motion still hitches

Profile the running app from Xcode with **Product → Profile → SwiftUI** in Instruments, then record a rapid open/close and gesture interaction. Inspect **Long View Body Updates**, **Long Platform View Updates**, and **Hitches**. The code still contains expensive blurred album-art layers and live media updates; optimize only after a trace identifies a hot path. Apple's instructions: https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance and https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency.

Record pass/fail results (and specific reproduction steps for failures) in `docs/GOAL.md` before marking the remaining acceptance criteria complete. The latest branding build log is at `/tmp/lunotch-b2-complete-build.log`; that log may be cleared by the operating system.
