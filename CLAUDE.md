# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Authoritative skills

Before editing anything, read the skill that matches what you're
touching:

- [`.claude/skills/ats-resume/SKILL.md`](.claude/skills/ats-resume/SKILL.md)
  — authoritative for `resume.tex` and `sections/*.tex` (preamble, macros,
  section order, canonical contact info, density tuning, testing).
- [`.claude/skills/ats-cover-letter/SKILL.md`](.claude/skills/ats-cover-letter/SKILL.md)
  — authoritative for `cover-letters/**` (shared preamble, one-page
  structure, writing rules, per-company folder layout, build).

This CLAUDE.md is a short pointer; each skill is the full spec.

## Project

Single-column, ATS-proof LaTeX resume built on the `article` class with
[Jake Gutierrez's template](https://github.com/jakegut/resume) conventions.
Owner/subject: Oscar Giraldo Castillo.

## Build

Use the `Makefile`. `pdflatex` and `latexmk` are at
`/Library/TeX/texbin/`.

```sh
make           # incremental; 'Nothing to be done for all' means up-to-date
make view      # compile and open the PDF
make watch     # latexmk -pvc; rebuild on every save
make clean     # remove build/ (keeps committed resume.pdf)
make distclean # also remove resume.pdf
make help      # list targets
```

`latexmk` writes intermediates to `build/` (gitignored) via
`-output-directory`; the Makefile then copies `build/resume.pdf` to the
repo root so the committed `resume.pdf` (linked from the README) stays in
sync. To force a full rebuild after edits, run `make clean && make`.

## Layout

```
resume.tex                               # preamble, macros, header, \input list
sections/*.tex                           # section fragments (no preamble)
assets/picture.jpg                       # unreferenced; no \photo is used anymore
resume.pdf                               # committed build output (README links it)
cover-letters/                           # per-company LaTeX cover letters
  _common/cover-letter-preamble.tex      # shared preamble + \coverHeader
  <company-slug>/cover-letter.tex        # per-company source
  <company-slug>/cover-letter.pdf        # committed build output
  <company-slug>/job-posting.md          # captured job description
Makefile                                 # build targets (resume + cover-letters)
.claude/skills/ats-resume/SKILL.md       # authoritative guide for resume edits
.claude/skills/ats-cover-letter/SKILL.md # authoritative guide for cover letters
```

`resume.tex` sets the `article` class + ATS-proof preamble
(`\input{glyphtounicode}` + `\pdfgentounicode=1` + `\DisableLigatures`),
defines three custom macros (`\cvEntry`, `\cvProject`, `\cvSkill`), emits
the header inside a `\begin{center}` block (body text, not `\fancyhdr`),
and `\input`s sections in this order:

1. `sections/summary.tex`
2. `sections/experience.tex`
3. `sections/projects.tex`
4. `sections/skills.tex`
5. `sections/education.tex`
6. `sections/certifications.tex`
7. `sections/honors-awards.tex`
8. `sections/languages.tex`

## Editing conventions

- Personal/contact data lives in `resume.tex` only. Update it there (header
  `\begin{center}` block and `\hypersetup{}`), never in section files.
- Content edits (new job, new skill, etc.) go in the matching
  `sections/*.tex` file and must use the `\cvEntry` / `\cvProject` /
  `\cvSkill` macros — never `\cventry` (moderncv) or raw `tabular`.
- Preserve UTF-8 (the preamble declares `\usepackage[utf8]{inputenc}`).
- Do **not** re-introduce: `moderncv`, `\fancyhdr`, `\photo{}`,
  `\quote{}`, multi-column layouts, or FontAwesome icons without visible
  text. The skill lists the full rejection set.
- Target: **2 pages max** for this senior profile. Tune bullets first,
  spacing second — see the density-tuning section of the skill.
- After any edit run `make clean && make` plus the
  `pdffonts` / `pdftotext -layout` ATS checks described in the skill.
