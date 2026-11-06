# Lunotch — identity explorations

Nine independent concepts for review, grounded in the existing crescent-and-island identity in `docs/BRAND_IDENTITY.md`. These are exploratory proposals; none replaces the current app icon. The vector concepts were drawn in SVG, and each raster preview was rendered from the same vector geometry. The separate image-generated boards are visual ideation references, not the source of the SVG assets.

## Boards

- [Nine concepts](comparison-board.png) · [editable SVG](comparison-board.svg)
- [App-icon shortlist](shortlist-board.png) · [editable SVG](shortlist-board.svg)

## Concepts and evaluation

Judgments are comparative design assessments, not trademark searches or user recognition tests. Small-size comments describe the exported previews; no menu-bar integration or device testing was performed.

| ID | Concept | Distinctiveness & balance | Small-size / premium appearance | Animation opportunity |
| --- | --- | --- | --- | --- |
| A1 | Crescent cradle | Clear moon and island relationship, closest to Lunotch's existing visual idea; quiet, balanced and memorable. | Simple silhouette; tapered tips can soften at 16 px. | Island can expand while crescent remains a stable anchor. |
| A2 | Low orbit | Warm upward cradle, but can read as a smile. | Broad lower crescent survives scaling; minimal and friendly. | Crescent can rise in response to the expanding island. |
| A3 | Tidal crescent | Reversed crescent gives an active offset; overlap adds tension. | Thin horns and overlap merge at 16 px. | The island can pass through the arc as it changes state. |
| B1 | Tidal expansion | Friendly, symmetrical, fluid outline; the monochrome capsule loses its internal color distinction. | Compact but the crescent counter gets small; lively rather than austere. | Natural expansion and contraction along the horizontal axis. |
| B2 | Flow aperture | Most distinctive liquid silhouette; the notch and lunar counter add a purposeful rhythm. | Aperture is stronger than B1 in monochrome; tiny lunar counter needs 16 px review. | Aperture, shoulders and pill can respond to content and gestures. |
| B3 | Wake | The waist suggests a wake and motion; more pointed and expressive. | The monochrome interior pill merges into the silhouette and the crescent becomes small. | Shape naturally morphs from a capsule into a stretched state. |
| C1 | Split halo | Very balanced and simple, though the ring and dash can feel generic. | Clear and crisp; the thin ring could need weight adjustment at 16 px. | Ring can rotate or open, but the static identity is less lunar. |
| C2 | Offset occultation | Asymmetric eclipse feels purposeful and recognizable; overlaps are clear in color. | Strong silhouette and notch, but overlap distinction compresses in monochrome. | Two discs can slide to reveal and conceal the notch. |
| C3 | Horizon cut | Calm and geometrically stable; concentric construction is less distinctive. | Solid, high-contrast shape; can resemble a minus sign at small sizes. | Inner disc can translate through the outer frame. |

## Recommendation

1. **A1 — Crescent cradle:** strongest primary identity. It carries forward the existing moon-and-island story with a quieter, more geometric silhouette. Its thin crescent tips and generous canvas margins should be optically adjusted after viewing actual menu-bar renders.
2. **B2 — Flow aperture:** best motion vocabulary. Its soft shoulders and aperture suggest expansion and contraction; the small lunar counter can disappear at tiny sizes. Use its motion principles to animate A1's island rather than treating the symbols as a single fixed shape.
3. **C2 — Offset occultation:** strongest geometric alternative. Offset circles give a confident eclipse and clean notch, though the overlap loses a tonal distinction in monochrome and the shape may need careful small-size refinement.

For all three, test optical weight at actual menu-bar size and against real system backgrounds. Avoid idle loops and respect Reduce Motion, consistent with the existing brand guidance. Originality here means newly drawn for this exploration; no independent similarity or trademark clearance was performed.

## File guide

Each `A1`–`C3` folder contains:

- `master.svg` — editable 1024-square transparent color geometry, designed for dark backgrounds.
- `transparent-1024.png` — direct render of that master.
- `app-icon-preview.svg` / `.png` — rounded-square presentation mock, not a production `.icon` package or system-rendered macOS icon.
- `preview-light.png` / `preview-dark.png` — same geometry with light- and dark-surface color treatments.
- `monochrome.svg` / `monochrome-1024.png` — dark mark on transparency; inverse files contain a white mark.
- `small-16.png`, `small-32.png`, `small-128.png` — actual pixel dimensions, rendered directly from the monochrome SVG at the same 1024-unit canvas bounds.

The pale transparent color master is for dark surfaces; use the dark monochrome asset or the darker treatment shown in `preview-light.png` on light surfaces. The previews are not guaranteed to remain legible in all real contexts. `generate.cjs` contains the editable concept definitions and rebuilds all vector-based assets using the locally installed `@resvg/resvg-js`; its absolute dependency path is specific to this machine. Editing only an exported SVG will not update the generator: edit the concept definition and regenerate to keep variants synchronized.

## Image-generated visual studies

Three supplemental bitmap boards were generated with the built-in image-generation tool after the vector exploration. They are alternative ideation, not renders of A1–C3 and not editable masters. Their thin details and variable geometries are untested at small sizes; the liquid images in particular do not consistently depict a distinct notch.

- [Lunar Island study](imagegen/lunar-island.png)
- [Liquid Notch study](imagegen/liquid-notch.png)
- [Eclipse study](imagegen/eclipse.png)

Prompts: create a refined, original, vector-like three-symbol board for each direction, on warm white without typography or effects. Lunar: a crescent partially wrapping a horizontal pill in silver, graphite and icy blue. Liquid: organic expanding capsules with lunar negative space in graphite, electric blue and violet. Eclipse: overlapping geometric circular forms with a horizontal notch in black, warm white and titanium.

## Individual ImageGen exploration

A subsequent set of nine individually generated bitmap concepts, separate from the earlier vector work, is available in [imagegen-2026-11-06](imagegen-2026-11-06/README.md). That folder documents the generated originals, comparison boards, surface tests, small-size reductions and known alpha/contrast limitations.
