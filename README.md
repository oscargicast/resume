Resume
======

Single-column, ATS-proof LaTeX resume built on the `article` class.
See [`.claude/skills/ats-resume/SKILL.md`](.claude/skills/ats-resume/SKILL.md) for the authoritative editing guide.

- Main file: [resume.tex](resume.tex)
- Sections: [sections/](sections/)
- Output: [resume.pdf](resume.pdf?raw=true)

## Build

```sh
make               # compile resume.pdf (incremental — skipped if up-to-date)
make view          # compile and open the PDF
make watch         # rebuild continuously on save (latexmk -pvc)
make cover-letters # compile every cover-letters/*/cover-letter.tex
make docs          # compile the resume and every cover letter
make clean         # remove build/ artifacts (keeps committed PDFs)
make distclean     # also remove resume.pdf and cover-letter PDFs
make help          # list targets
```

`make` is incremental: if `resume.pdf` is newer than all sources, Make prints `Nothing to be done for 'all'` and exits. That is correct — there is nothing to rebuild. To force a full rebuild, run `make clean && make` (or `make distclean && make`).

Requires a TeX Live distribution with `latexmk` and `pdflatex`. Uses standard packages only (`lmodern`, `microtype`, `geometry`, `enumitem`, `titlesec`, `tabularx`, `hyperref`, `glyphtounicode`) — no `moderncv`, no `fontspec`.

## Cover letters

Per-company LaTeX cover letters live under [`cover-letters/`](cover-letters/) and share an ATS-proof preamble with the resume. See [`.claude/skills/ats-cover-letter/SKILL.md`](.claude/skills/ats-cover-letter/SKILL.md) for the authoritative editing guide (one-page cap, ragged-right body, posting-anchored opener, no em-dashes).

```
cover-letters/
├── _common/cover-letter-preamble.tex    # shared preamble + \coverHeader
└── <company-slug>/
    ├── cover-letter.tex                  # per-company source
    ├── cover-letter.pdf                  # committed build output
    └── job-posting.md                    # captured job description
```

Build every letter with `make cover-letters`. Internally, the Makefile pattern rule compiles each `cover-letters/<slug>/cover-letter.tex` via `latexmk` into `build/cover-letters/<slug>/` and copies the resulting `cover-letter.pdf` next to its source. `make distclean` also removes the generated letter PDFs.

To add a new cover letter, duplicate an existing `<company-slug>/` folder, swap `job-posting.md`, and rewrite `cover-letter.tex` following the skill's structure.

## ATS verification

```sh
pdffonts resume.pdf                                          # every row should show emb yes / uni yes
pdftotext -layout resume.pdf -                               # reading order must be linear, ligatures intact
pdffonts cover-letters/<slug>/cover-letter.pdf               # same check for any cover letter
pdftotext -layout cover-letters/<slug>/cover-letter.pdf -    # confirm 1 page, no em-dashes
```
