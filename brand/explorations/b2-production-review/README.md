# B2 Lunar Droplet — production review

An editable vector redraw of the ImageGen concept selected by the user, preserving the graphite crescent lobe, flowing violet capsule, and two transparent cutouts. The paths are an optical approximation, not a pixel-identical trace. No application icon has been changed.

- [Comparison board](review-board.png) — existing Lunotch icon, proposed light/dark Dock previews, and actual-pixel menu-bar samples.
- [Editable color master](lunotch-b2-master.svg) and [1024px transparent PNG](lunotch-b2-master-1024.png).
- [Light-surface mark](lunotch-b2-light.svg) and [dark-surface mark](lunotch-b2-dark.svg).
- [Light Dock preview](dock-light-1024.png) / [dark Dock preview](dock-dark-1024.png) and editable `dock-light.svg` / `dock-dark.svg`. These are rounded-square review mockups, not macOS-rendered icons or native packages.
- Menu symbol: [dark SVG](menu-dark.svg) / [light SVG](menu-light.svg), plus `menu-{dark,light}-{16,32,128}.png`. It has enlarged cutouts relative to the full-color master to improve legibility; each PNG is rendered from its corresponding SVG.

The comparison board positions the actual 16, 32 and 128-pixel PNGs at native pixel dimensions, but a viewer may scale the board. Open the individual PNGs at 100% for inspection. The 16px symbol is still tiny and has not been tested in an actual macOS menu bar; a larger menu-bar canvas or further simplification may be necessary. Dark and light Dock treatments are design variants, not automatic OS appearances.

Validation: `@resvg/resvg-js` rendered all PNGs directly from the vector definitions. RGBA pixel samples in the 1024px master confirmed transparent background, crescent and pill, with opaque body; menu PNG dimensions were checked. This is a design review, not an installed or platform-certified icon. No independent name or trademark clearance was performed.

`build.cjs` is the source for the vector definitions and preview compositions; it uses the locally installed resvg dependency at the absolute path shown in the script. Edit the definitions and rebuild to synchronize exports.
