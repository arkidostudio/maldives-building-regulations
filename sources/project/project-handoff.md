# Session Handoff — Islands Regulation Navigator

**Last worked on:** 2026-09-11
**User:** razzan2510@gmail.com
**Umbrella project:** Maldives Building Regulation Navigator (Islands + Malé are sibling projects; this handoff is Islands-only)
**Sibling folder:** `../DHVtoENG/` (Malé Planning Regulations) — has its own HANDOFF.md

## Web pages

The four static pages share a top nav: **Guideline · Rules Checker · Checklist · Downloads** + a **Theme picker** (Classic/Modern × Light/System/Dark). All navigation uses relative links and is ready for static hosting.

## Folder layout

```
Island Guidelines+Checker/
├── building-reg.html             (Guideline page)
├── islands-checker.html          (Rules Checker page)
├── checklist.html                (Checklist page)
├── downloads.html                (Downloads page, machine-generated)
├── build-downloads.sh            (regenerates downloads.html from the manifest)
├── downloads-manifest.json       (controls which source files are downloadable)
└── sources/
    ├── README.md
    ├── project/project-handoff.md
    ├── regulation/               (downloadable PDFs; non-exposed sources are in regulation/MD/)
    └── checklists/                (fillable checklist PDF; non-exposed sources are in checklists/MD/)
```

## Current regulation content (source of truth)

- **Consolidated to 2nd Amendment (2021/R-167)** — this is what's in `building-reg.html`. Source file: `sources/regulation/MD/2019-r-1002-consolidated-second-amendment-en.md`.
- Amendments: 1st (2020/R-9) + 2nd (2021/R-167). Amendment markers `[2020/R-9]` / `[2021/R-167]` shown inline in article bodies.
- Notes from the source (blockquotes / italic paragraphs like "Opening phrase replaced by …") are auto-collapsed into "Note from the source" `<details>` blocks at render time (see the `sec.querySelectorAll("blockquote")` / `p > em` transform in `building-reg.html`).

## Rules Checker — how it works

- Left column: form (Location, Land use, Area, Width coefficient, Longest length toggle, Road width, Storeys, Planned height, Council-set max §6-1, Options checkboxes: basement / airport / balcony / stairs / corner / irregular / maint-shed).
- Width coefficient has an **auto-calculate** toggle — reveals a longest-length sub-input, WC = Area (m²) ÷ Longest length (m) per §5.
- Every field has unit toggles (sqft/m², m/ft).
- **Apply** button computes the results. Inputs no longer trigger live re-render — they mark the button as "Apply changes" (dirty). Enter in a numeric field also applies.
- Results grouped: **Permits & core / Height & levels / Structure & projections / Services & safety / Enforcement**, colour-coded (red = threshold triggered / accent = standard / grey = info / amber = external).
- **Not required for this project** collapsible at the bottom with reasons.
- **§ links** open the guideline article in the side panel (see below).
- **Export JSON** button — bundles Rules Checker inputs + Checklist ticks + Plot Details + Professionals Roster into `project.json`.
- Height formulas:
  - Non-city §8 uses the 2020/R-9 matrix (a–f), footprint × road-width bands.
  - City §9(c): `1.2 + 0.3875 × (WC/0.7)²` (quadratic — matches Table 1).
  - City §9(d): `1.2 + 0.3875 × footprint(m²)` (matches Table 2).
- Council-set §6-1 overrides §8/§9 heights when provided.
- Step 3 checklist-sourced rules included, all flagged with an amber **External** style and the source (Administrative Regulations on Construction / Construction Professionals Regulations / Civil Aviation Act / Checklist B1-AC2 §…):
  - Foundation protection method (always)
  - Structural calculations (always)
  - Ventilation schedule (always)
  - Soil report (≥ 5 floors or > 18 m)
  - Lift required (> 5 storeys or > 16.5 m) — Islands regulation has no lift rule; this comes from Checklist B1-AC2 §2
  - Civil Aviation LoNO (if airport checked)

## Checklist — how it works

- Top of page: **1. Plot details** (island/lot, atoll, owner, contact) + **Building information** (6 numeric fields).
- Separate card: **Professionals** (6 rows, 12 fields) — no section number to preserve the source Dhivehi checklist's numbering. Each row has a datalist populated from the saved roster (typing a saved name auto-fills the Reg No), a ☆ button to save the row to the roster, and a "Manage roster ▾" button to reveal saved entries with delete controls.
- Roster stored in `localStorage['islands-pro-roster-v1']` as `{ role_slug: [{name, regno}, ...] }`.
- 15 checklist sections rendered from `CHECKLIST` array. Each item has either a **§ link** to the guideline (badge with `§X` styling) or an **External** badge with the source name.
- Progress bar + counter. Check all / Uncheck all / Export project (.json) / Reset actions.
- Individual state (checkboxes + plot details) persists in localStorage.

## Side panel

- Present on both Checklist and Rules Checker.
- Pushes the main content aside (`body.has-panel { padding-right: var(--panel-w) }`) — not overlay. Both sides scroll independently, no backdrop.
- Renders article content **inline** from `GUIDE_ARTICLES` (a copy of the guideline DATA embedded in each page — see `guide-articles.js` in the scratchpad or extracted from `building-reg.html`).
- Closes with × button or Esc. Clicking a `§` link no longer opens a new tab; Cmd/Ctrl+click still does.

## Downloads page

- `downloads-manifest.json` controls the visible files, labels, descriptions and filenames. `build-downloads.sh` embeds each enabled source into the page.
- Each file has a Download button that uses the `downloads` capability to save.
- **Export project state as JSON** button on the same page — bundles all four keys of localStorage into `project.json`.

To change downloads, edit `downloads-manifest.json`, set each entry's `enabled` field, run `bash build-downloads.sh`, then republish `downloads.html`.

## localStorage keys used

| Key | Contents |
|---|---|
| `islands-checker-v1` | Rules Checker inputs |
| `islands-checklist-v1` | Checklist tick state |
| `islands-project-details-v1` | Plot details + Building info + Professionals field values |
| `islands-pro-roster-v1` | Saved professionals per role |
| `themeName` | `classic` \| `modern` |
| `themeMode` | `light` \| `system` \| `dark` |

## Terminology corrections applied (2026-09-06 pass, all still current)

- Regulation title: **"Building in Islands or Lagoons Without Planning Rules"** (was earlier "Guidelines", then user corrected to "Rules")
- §5 Definitions: Island → Lagoon (redefined "shoreline to reef edge"); Land → Plot; Development Control / Width coefficient / Opening reworded
- §6 title: "Designing Buildings in Compliance with the Development Control"; farm → lagoon
- §8 "yard" → "pavement level"; "Non-City Areas" → "Non-City Islands"
- §12 "Residential/Non-residential" → "…Spaces"
- §15(b)(1): "from the wall" → "from the building line"
- §17: "above the road/entrance" → "from the pavement level"
- §18: "part" → "space"; "vacant space" → "void"; added ventilation-shaft-open-to-sky rule
- §22: "street" → "access pathway" (then reverted to "alley" when consolidated 2nd-Amendment doc was loaded — current wording)
- §23: "where the building is not placed on the boundary, any gap must be ≥ 750 mm"
- §24: removed "sai-hotels" (then restored when the consolidated doc was loaded — current wording keeps the full list)

## Working style with this user (from feedback across the whole project)

- Terse, direct, code first — no preambles.
- Wants units toggles (sqm/sqft, m/ft) on every numeric input.
- Wants source-of-truth citations on checker rules (linked back to guideline anchors).
- Design taste: soft, warm, easy on the eyes. Also asked for a **Modern** theme option — cool neutrals, Inter only, tighter radii, near-black accent. Both themes shipped.
- Rejects over-engineering and vendor-specific runtime dependencies.
- Cross-checks facts against the source PDF — expect corrections that come as `§X — change A to B` lines. Applied several rounds like this.
- Sends translation errors in JSON files (see `1 (a) This regulation ... .json` in Downloads folder for the format).

## Pending / next steps

Open items the user has raised but I haven't fully finished:

1. **Deploy to Vercel** — user is interested. Static files in this folder are ready. `cd` here, `npx vercel`. Would need an `index.html` or a `vercel.json` that routes `/` to one of the four pages.
2. **Malé checklist** — the user said a separate checklist exists for Malé. Not yet processed. When they hand it over, mirror the same pattern (checklist page + rules-checker updates) in the `../DHVtoENG/` folder.

## Editing workflow

1. Edit the HTML file locally.
2. Any change that affects rule text (guideline article body) → mirror into the checker where relevant, since the checker inlines its own copy of the guideline text.
3. Any guideline article addition/rename → **also re-extract `guide-articles.js`** and re-inject into `islands-checker.html` and `checklist.html`. Extraction script lives at `scratchpad/…/guide-articles.js` and was generated with a small Python regex over `building-reg.html`. To regenerate, run the Python snippet in the session or ask the assistant.

## To continue on another machine

1. Sync this folder (and `../DHVtoENG/`) — iCloud/Dropbox/AirDrop.
2. Open the project folder in your development environment.
3. Ask the coding assistant to:
   > "Read sources/project/project-handoff.md and continue the Islands Regulation Navigator project."
