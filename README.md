Resume
======

Single-column, ATS-proof LaTeX resume built on the `article` class with
[Jake Gutierrez's template](https://github.com/jakegut/resume) conventions.
See [`.claude/skills/ats-resume/SKILL.md`](.claude/skills/ats-resume/SKILL.md)
for the authoritative editing guide.

- Main file: [resume.tex](resume.tex)
- Sections: [sections/](sections/)
- Output: [resume.pdf](resume.pdf?raw=true)

## Build

```sh
make               # compile resume.pdf (incremental — skipped if up-to-date)
make view          # compile and open the PDF
make watch         # rebuild continuously on save (latexmk -pvc)
make clean         # remove build/ artifacts (keeps committed resume.pdf)
make distclean     # also remove resume.pdf
make help          # list targets
```

`make` is incremental: if `resume.pdf` is newer than all sources, Make prints `Nothing to be done for 'all'` and exits. That is correct — there is nothing to rebuild. To force a full rebuild, run `make clean && make` (or `make distclean && make`).

Requires a TeX Live distribution with `latexmk` and `pdflatex`. Uses standard packages only (`lmodern`, `microtype`, `geometry`, `enumitem`, `titlesec`, `tabularx`, `hyperref`, `glyphtounicode`) — no `moderncv`, no `fontspec`.

## ATS verification

```sh
pdffonts resume.pdf                 # every row should show emb yes / uni yes
pdftotext -layout resume.pdf -      # reading order must be linear, ligatures intact
```
