# Software Engineering Fundamentals

This repository builds a single-file HTML handbook and an A4 PDF from the same
chapter-level Markdown sources. Mermaid diagrams remain embedded in the Markdown
and are rendered as vector SVG for both outputs.

## Build

From Git Bash:

```bash
bash build.sh
```

From PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

Outputs:

- `book/output/book.html`
- `book/output/book.pdf`

The repository carries a portable Pandoc binary and local JavaScript assets, so
the build does not fetch anything. PDF generation uses an installed Chromium
browser (Google Chrome or Microsoft Edge).

## Source layout

- `book/front-matter/`: title, notation legend, glossary, and revision sheets
- `book/chapters/part-NN/`: one Markdown source per chapter plus a part divider
- `book/manifest.txt`: exact assembly order
- `book/assets/`: CSS, Lua filter, templates, diagram rules, and local runtimes
- `book/output/`: final deliverables

## Authoring rules

1. Keep chapter sources valid, portable Markdown.
2. Use the visual notation defined in `book/front-matter/visual-notation.md`.
3. Use Mermaid only when a relationship is clearer visually than in prose.
4. Add a short standalone key below every diagram.
5. Keep diagrams grayscale, compact enough for one A4 page, and free of
   crossed or ambiguous edges. Split dense diagrams.
6. Use callout classes consistently: `interview-tip`, `scenario`, `gotcha`,
   and `key-terms`.
7. Mark vendor- or version-specific behavior explicitly.

## Build validation

The build fails when a manifest source is missing, a Mermaid block cannot be
rendered, a diagram remains unrendered in the print DOM, or an output is missing.

