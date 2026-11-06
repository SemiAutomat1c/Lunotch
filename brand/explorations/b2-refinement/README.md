# B2 Lunar Droplet refinement

The user selected B2 from the ImageGen exploration. This pass uses the built-in ImageGen editor to preserve its graphite crescent lobe, flowing lavender capsule, and horizontal aperture while removing visible artifacts. The opaque white edit is the cleanest result. It is an image-generated approximation of the chosen original, not a pixel-identical redraw or editable vector.

- [Review board](review-board.png) — light, experimental dark and actual-size reductions.
- [Refined artwork on white](refined-white.png) — 1254 × 1254, generated with a white background and white interior shapes.
- [Experimental transparent artwork](transparent-experimental.png) — generated from the white version; it retains magenta edge contamination around the pill and a few outer edges, so it is not production-ready.
- [Experimental dark surface](dark-surface-experimental.png) — shows the transparent image on a dark background; graphite contrast needs improvement.
- [Rounded-square preview](app-icon-preview.png) — white presentation mockup, not a system-rendered or installed icon.
- [16px](white-16px.png), [32px](white-32px.png), [128px](white-128px.png) — resizes of the white artwork. At 16 px the crescent and aperture are very small; a simplified, optically adjusted menu-bar version is needed.

The white version closely retains the selected asymmetrical silhouette, colors, and two interior details; there are small geometric differences from the original. The dark test uses the experimental transparent output, not a verified dark-mode variant. Actual-device testing, clean alpha, a tuned small-size symbol, and a dark-mode treatment remain open. No app icon was replaced.

ImageGen prompts: first asked to clean the original while preserving silhouette and transparent cutouts; that result lost the cutouts and was rejected. The second asked for the exact crescent and capsule holes on opaque white with clean flat edges. A third asked to remove only the white background and preserve both cutouts; visible magenta residue remains. `present.cjs` creates previews by placing the generated artwork on backgrounds and reducing it; it does not redraw the logo.
