# Lunotch — ImageGen exploration

Nine individually generated bitmap concepts, separate from the earlier SVG exploration. ImageGen was the primary creative tool; the presentation script only places the generated PNG artwork on backgrounds and rounded-square tiles. No logo shapes were drawn by the script. Concepts are illustrative design proposals, not production-ready icons.

- [Nine-concept board](comparison-board.png) — each symbol on a light panel with light and dark surface tests.
- [macOS icon board](app-icons-board.png) — nine rounded-square presentation mockups.
- Each `A1`–`C3` folder includes the original 1254 × 1254 generated PNG with an alpha channel, light/dark surface tests, a 1024 × 1024 icon mockup, and 16, 32 and 128 px reductions. `C1/alternate-opaque.png` is a separately generated cleaner opaque alternative; the boards show the original C1 to preserve their consistent source.

**Quality limits:** The original generated transparencies include unwanted pale/color speckling and ragged edge residue, especially A1, A2, B2, C1 and C3. C1's separately generated opaque alternative has cleaner edges but is not a transparent version of the same design. Several dark designs lose contrast on dark surfaces; the tests preserve the original colors to make that visible. The files are useful for selecting a visual direction but need cleanup and carefully redrawn, optically adjusted light/dark and monochrome variants before use. The 16/32 px reductions are actual exported pixel sizes, not a claim of tested legibility. No device, recognition, trademark, or originality search was performed.

## Evaluation

| Concept | Design assessment | Small size / animation |
| --- | --- | --- |
| A1 — Crescent cradle | Strongest continuity with the current lunar orbit and floating pill. The crescent joins the capsule more clearly than the other A variants, although the pale silver has low contrast on white and edge residue reduces polish. | The thin tip and dark capsule can disappear on some surfaces; the capsule could expand while the moon anchors it. |
| A2 — Lunar horizon | Symmetric, calm, and clearly moon plus notch; the blue dot adds familiarity but could become decorative. Its upward crescent can read as a smile. | Thick forms help scaling, but the dot and tips may vanish. The notch can expand above a stable crescent. |
| A3 — Carved disc | The most compact lunar silhouette, with an architectural profile. The inset pill reads partially hidden, weakening the notch story. | Broad mass scales well, but the small inset needs work. The inner cutout could slide to suggest an eclipse. |
| B1 — Fluid waist | Broad, confident fluid silhouette with a clear violet moon; less explicit as a notch and very dark on dark surfaces. | Strong overall mass; internal moon and pinched waist need review at 16 px. Expanding the waist gives a natural animation. |
| B2 — Lunar droplet | Most expressive asymmetry, combining moon, flowing form and aperture; visually busy and less restrained. | Small aperture and crescent risk closing at small sizes; a morphing droplet suggests useful transition behavior. |
| B3 — Expanding belly | A recognizable top notch and curved violet underside suggest expansion in a single compact form. The saturated violet is stronger than the requested restraint. | A large notch helps recognition, but black disappears on dark backgrounds. The belly is a direct cue for expansion animation. |
| C1 — Offset eclipse | Intersecting discs and the horizon suggest a technical eclipse. The original has severe transparent-background residue; the opaque alternate is cleaner but uses a different geometry. | The thin horizontal break may close at 16 px. Discs can shift against each other. |
| C2 — Eclipse aperture | Extremely simple and balanced; the central bar and disc are easy to parse but relatively generic and can read as a minus sign. | Large elements survive scaling; a sliding pill is straightforward to animate. |
| C3 — Tangent eclipse | Distinctive overlapping masses and a single shared aperture. Balanced and architectural, though less specifically lunar and the aperture contains artifacts. | Big shapes provide a strong starting point; tonal contrast collapses on dark surfaces. The circles could move in opposing directions. |

## Recommendation

1. **A1 — Crescent cradle:** primary identity candidate. It joins the product's existing moon and notch story in an elegant, unified silhouette. Redraw cleanly, increase contrast, and tune the crescent at 16–32 px.
2. **B3 — Expanding belly:** motion reference and alternative identity. Its notch-shaped top and swelling lower edge connect directly to the product behavior; reduce violet saturation and provide a light mark for dark environments.
3. **C3 — Tangent eclipse:** geometric alternative with a memorable shared aperture. Refine its overlapping edges and color contrast, and test whether the lunar idea still reads without color.

A1's stable crescent paired with B3's restrained expansion is a promising future animation direction. Respect Reduce Motion and avoid idle loops, in line with the existing brand guide.

## Prompt set

Built-in ImageGen was invoked once for each concept with this shared instruction: “Create exactly ONE standalone original symbol for Lunotch, a premium native macOS notch companion. Transparent background, centered fully inside square with ample clear space. No tile, no text, no words, no letters, no mockups. Precise geometry, restrained premium industrial graphic design, clean flat high contrast edges. Recognizable as a static mark at small size. Avoid shadows, glow, 3D, texture, gradients, decorative details, and existing company logos.” Each used an additional direction:

- A1: unified icy-silver crescent flowing seamlessly into a horizontal capsule, with open center.
- A2: horizontal capsule interrupting a broad upward crescent, silver/graphite and small icy-blue accent.
- A3: compact lunar disc with crescent cutout and a horizontal notch integrated into its silhouette.
- B1: organic capsule with pinched waist and bold crescent cutout, graphite and muted violet.
- B2: asymmetrical droplet flowing into a capsule, lunar negative space and inset pill, titanium/lavender.
- B3: rounded capsule with a swelling crescent underside and crisp top notch, graphite/violet.
- C1: offset circular discs and crescent light region intersected by a notch, titanium/graphite.
- C2: disc partly obscured by a horizontal pill aperture, black and silver.
- C3: overlapping circles around a central rounded notch with crescent negative space.

A tenth built-in ImageGen call produced the supplementary opaque C1 variation: overlapping eclipse discs and a horizontal notch on a clean warm-white background.
