# Lunotch release procedure

This personal project distributes a **preview** as a GitHub Release asset; DMGs are *not* committed into Git. The original Boring Notch GitHub Actions, Sparkle/appcast publishing workflows and donation links were removed for this fork. No automatic update channel exists. Keep `LICENSE` and third-party notices in the source distribution.

1. Confirm the app's marketing version/build in `boringNotch.xcodeproj/project.pbxproj`; record release changes and known QA gaps in the README and `docs/GOAL.md`.
2. On an Apple Silicon Mac with Xcode, build:
   ```bash
   xcodebuild -project boringNotch.xcodeproj -scheme boringNotch \
     -configuration Release -sdk macosx \
     -destination 'platform=macOS,arch=arm64' \
     CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- build
   ```
3. Verify the resulting `Lunotch.app` with `codesign --verify --deep --strict --verbose=2 /path/to/Lunotch.app`. Inspect its `Info.plist`, helper bundle ID, and architecture.
4. Package using `scripts/package-dmg.sh /path/to/Lunotch.app`; the current default label creates `dist/Lunotch-v0.1.0-preview.2-arm64.dmg` with an `/Applications` shortcut, verifies the disk image and prints its SHA-256. Pass a third argument to use a different label.
5. Mount the DMG read-only and verify it contains the intended app and Applications link. Smoke test the installed copy on a suitable Mac where possible. An ad-hoc signature is not Developer ID signing and is **not notarization**.
6. Push reviewed source. Publish a clearly marked **pre-release** tagged `v0.1.0-preview.2`, attach the DMG, and put its SHA-256 in release notes along with installation steps, limitations and upstream attribution. Explicitly use `--repo SemiAutomat1c/Lunotch` in `gh` commands: the configured default may resolve to the upstream Boring Notch repo.
7. Confirm the GitHub release's asset is downloadable and the expected remote commit and tag exist.

Do not describe this build as notarized, broadly compatible, or visually QA complete until those checks are performed. For a future version, update the label and associated links/metadata.
