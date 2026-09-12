# Source library

Canonical regulation and checklist sources live here. The Downloads page only includes entries enabled in `../downloads-manifest.json`.

## Layout

```
sources/
├── regulation/              # Exposed regulation PDFs; other sources in regulation/MD/
├── checklists/              # Exposed checklist PDF; other sources in checklists/MD/
└── project/                 # Project handoff and maintenance notes
```

## Adding files

1. Put the source file in the appropriate `sources/` subfolder.
2. Add an entry to `downloads-manifest.json`, or change its `enabled` value.
3. Run `bash build-downloads.sh` from the project root.
4. Deploy the regenerated `downloads.html` with the rest of the static site.

The build script:
- Encodes each enabled file as base64.
- Uses the section, title, description and download filename from the manifest.
- Embedding large downloads increases `downloads.html`; keep the enabled set reasonably small.
