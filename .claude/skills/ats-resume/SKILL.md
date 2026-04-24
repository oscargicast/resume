---
name: ats-resume
description: >
  Use when editing Oscar Giraldo Castillo's LaTeX resume in this repo.
  Enforces ATS-proof rules (single-column article, ligature fix, visible
  URLs, no photo/fancyhdr/moderncv) AND the repo's build conventions
  (Makefile, macros, section order, canonical contact info). Triggers on:
  "resume", "CV", "currículum", "hoja de vida", "ATS", "resume.tex",
  "moderncv", "Jake Gutierrez".
---

# ats-resume

Authoritative guide for editing the resume in **this** repo
(`/Users/oscar/Projects/resume`) without breaking ATS compatibility. Combines
generic ATS-proof LaTeX rules with the repo's build system and canonical
data. When this skill and `CLAUDE.md` disagree, this skill wins.

Reference source for the ATS research is
[`ast-best-practices-resume.md`](../../../ast-best-practices-resume.md).

## The one-line ATS fix nobody explains

Every pdfLaTeX resume **must** include these two lines in its preamble:

```latex
\input{glyphtounicode}
\pdfgentounicode=1
```

Without them, pdfTeX's Computer Modern fonts encode `fi` and `fl` as single
glyphs with no `/ToUnicode` CMap. Workday, Greenhouse, Taleo, Textkernel's
2024 LLM Parser and Ashby's AI-Assisted Review all extract "artificial" as
`arti cial` — silently corrupting keywords. XeLaTeX and LuaLaTeX handle
this natively; pdfLaTeX does not. Pair with
`\DisableLigatures[f]{encoding = *, family = *}` from `microtype` as
belt-and-suspenders.

## Canonical preamble (as used by `resume.tex` today)

This is the preamble the repo actually ships — margins and spacing already
tuned for a 2-page senior resume. Do not revert to the 0.65in / 10pt/4pt
defaults from the reference doc without re-verifying page count.

```latex
\documentclass[11pt,letterpaper]{article}

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[english]{babel}

\usepackage{lmodern}
\usepackage{microtype}
\DisableLigatures[f]{encoding = *, family = *}
\input{glyphtounicode}
\pdfgentounicode=1

%% Color palette. Zero ATS impact — pdftotext strips color.
%% Keep it two-tone. Heading-only. Don't define unused colors (dead code);
%% add a new tone only when you have a concrete use for it.
\usepackage{xcolor}
\definecolor{titleStrong}{HTML}{3D5A80}  % hero, sections, rule — ~7.6:1 on white
\definecolor{titleMid}{HTML}{556E8D}     % role/project/skill/honor titles — ~5.6:1

\usepackage[margin=0.45in]{geometry}
\usepackage{enumitem}
\setlist[itemize]{leftmargin=*, topsep=0pt, itemsep=0pt,
                  parsep=0pt, label=\textbullet}
\setlength{\parindent}{0pt}
\pagestyle{empty}

\usepackage{titlesec}
\titleformat{\section}
  {\large\bfseries\raggedright\color{titleStrong}}{}{0em}{}[{\color{titleStrong}\titlerule}]
\titlespacing*{\section}{0pt}{12pt}{5pt}
\setcounter{secnumdepth}{0}

\usepackage{tabularx}

\usepackage[hidelinks]{hyperref}
\hypersetup{
  pdftitle={Oscar Giraldo Castillo - Senior Full-Stack Engineer Resume},
  pdfauthor={Oscar Giraldo Castillo},
  pdfsubject={Senior Backend Software Engineer},
  pdfkeywords={Python, Django, FastAPI, PostgreSQL, Redis, AWS, Kubernetes,
               Docker, distributed systems, microservices, MCP,
               Model Context Protocol, LLM tooling, backend, event-driven,
               Go, TypeScript, data engineering},
  colorlinks=false, pdfborder={0 0 0}
}
\urlstyle{same}
\pdfminorversion=7
```

Note: `bookmarks=true` is **not** in `\hypersetup` — `hidelinks` already
implies it. Adding it triggers the harmless `Option 'bookmarks' has already
been used` warning.

## Six macros cover every content pattern

Defined inline at the top of `resume.tex`. Always use these — never raw
`\textbf{...}` for headings, never `\cventry` (moderncv), never
`tabular`-based alternatives.

**Presentation components** (3) — reused by the content macros and by
section files directly:

```latex
% Bold + accent color. Use for any sub-title.
\newcommand{\cvHeading}[1]{\textbf{\textcolor{titleMid}{#1}}}

% Free-text line under a \cvEntry (activities, coursework, narrative).
\newcommand{\cvNote}[1]{\noindent #1\par\vspace{2pt}}

% Honor / certification line: colored title + detail.
\newcommand{\cvHonor}[2]{\cvHeading{#1} -- #2}
```

**Content macros** (3) — each consumes `\cvHeading` internally for its
title, so the whole hierarchy shares one color source:

```latex
% \cvEntry{Title}{Dates}{Org}{Location}
\newcommand{\cvEntry}[4]{%
  \noindent\cvHeading{#1}\hfill #2 \\
  \textit{#3}\hfill \textit{#4}\par\vspace{2pt}%
}

% \cvProject{Name}{Stack}{URL}
\newcommand{\cvProject}[3]{%
  \noindent\cvHeading{#1} \textbar\ \textit{#2}%
  \ifx&#3&\else\hfill\href{#3}{#3}\fi
  \par\vspace{2pt}%
}

% \cvSkill{Category}{Comma-separated list}
\newcommand{\cvSkill}[2]{%
  \noindent\cvHeading{#1:} #2\par\vspace{1pt}%
}
```

Usage cheatsheet for section files:

| Content kind                         | Use               |
|--------------------------------------|-------------------|
| Job / education entry with bullets   | `\cvEntry` + `itemize` |
| Entry with a single prose line       | `\cvEntry` + `\cvNote` |
| Side project / portfolio item        | `\cvProject` + `itemize` |
| Skills category line                 | `\cvSkill` |
| Honor / award / certification item   | `\item \cvHonor{title}{detail}` |
| Cert without trailing detail         | `\item \cvHeading{title}` |
| Inline label:value (e.g. Languages)  | `\cvHeading{Label:} value` |

Real usage from the repo:

```latex
\cvEntry{Python Backend Engineer}{Oct 2021 -- Jan 2023}{SpaceAG Global}{Lima, Perú}
\begin{itemize}
  \item Implemented a multi-tenant reporting module syncing AWS RDS with AWS
        Athena via EventBridge, Celery, and Pandas, producing Parquet files
        on AWS S3.
\end{itemize}

\cvProject{MCP Servers for Cometa}{Python, Model Context Protocol, Claude, OpenAI}{https://github.com/oscargicast}

\cvSkill{Python frameworks}{Django, FastAPI, Flask, Falcon, Tornado, CherryPy}
```

## Hard rules (reject anything that violates these)

- **Single column only.** No `multicol`, `paracol`, AltaCV/Deedy/Friggeri
  sidebars. They scramble reading order in Workday, Taleo, iCIMS.
- **No photo.** Workday and Greenhouse don't parse it and it breaks text
  flow for LLM parsers. `assets/picture.jpg` stays unreferenced in the
  repo — do not re-add `\photo{...}`.
- **No `\fancyhdr` for contact info.** Workday strips page headers during
  extraction. Contact goes in the document body (see the `\begin{center}`
  block at the top of `resume.tex`).
- **Every `\href` has visible URL text, with `https://` stripped**:
  - ✅ `\href{https://linkedin.com/in/oscargicast}{linkedin.com/in/oscargicast}`
  - ❌ `\href{https://linkedin.com/in/oscargicast}{LinkedIn}`
  - ❌ `\faLinkedin` + `\url{...}` in icon-only rows (FontAwesome glyphs
    are in the Private Use Area; parsers see nothing).
- **Mainstream fonts only**: Latin Modern (current), TeX Gyre, Charter,
  Source Sans/Serif, IBM Plex, Inter, EB Garamond. No `fontspec` with
  display fonts.
- **Standard section names**: Summary, Experience, Projects, Skills,
  Education, Certifications, Honors & Awards, Languages. No "My Journey"
  or similar creative headings.
- **Color — two-tone monochromatic palette, heading-only.** `pdftotext`
  strips all color, so ATS extraction is blind to it; the real risk is
  human readability in B&W printouts and low-contrast glare on screens.
  Allowed pattern: the `titleStrong` / `titleMid` pair defined in the
  preamble, consumed via `\color{titleStrong}` (hero name + `\titleformat`
  + rule) and `\cvHeading{...}` (all sub-titles). Forbidden: color for
  bullets, body text, dates, locations, italic company line, URLs, or
  any keyword; white-text "keyword stuffing"; any color below 4.5:1
  contrast for text; palettes that mix hues; color that encodes meaning
  (e.g., "red = current role"). The accent must be verifiable as
  visual-only: `pdftotext` output identical with or without it.
- **No tables for layout**, no `\quote{...}` decorative quote.

## Section order in this repo

Exactly what `resume.tex` `\input`s, in this order:

1. `sections/summary.tex`
2. `sections/experience.tex`
3. `sections/projects.tex`
4. `sections/skills.tex`
5. `sections/education.tex`
6. `sections/certifications.tex`
7. `sections/honors-awards.tex`
8. `sections/languages.tex`

Section files are LaTeX fragments — no `\documentclass`, no
`\begin{document}`. They are not compilable standalone.

For a senior engineer (8+ years), Experience comes **before** Education.
That's the industry pattern, against the undergrad convention of
Education-first.

## Canonical contact info

All contact data lives in `resume.tex` only, never in section files. If
an edit needs to update any of these, update it in `resume.tex` (header
`\begin{center}` block and `\hypersetup{}`) and nowhere else:

| Field     | Value                                         |
|-----------|-----------------------------------------------|
| Name      | Oscar Giraldo Castillo                        |
| Title     | Senior Full-Stack Engineer                    |
| Location  | Lima, Perú (remote)                           |
| Email     | oscar.gi.cast@gmail.com                       |
| Phone     | +51 907 898 162                               |
| LinkedIn  | linkedin.com/in/oscargicast                   |
| GitHub    | github.com/oscargicast                        |
| Blog      | oscargicast.com                               |

## Build

TeX toolchain is at `/Library/TeX/texbin/` (`pdflatex`, `latexmk`,
`pdffonts`, `pdftotext` all available).

```sh
make               # incremental; 'Nothing to be done' means up-to-date, NOT an error
make clean && make # force full rebuild (use after editing)
make view          # compile + open in Preview
make watch         # latexmk -pvc, rebuilds on save
make distclean     # remove build/ AND resume.pdf
```

`latexmk` writes intermediates to `build/` (gitignored) and the Makefile
copies `build/resume.pdf` to the repo root so the committed `resume.pdf`
(linked from README) stays in sync. After any edit, prefer
`make clean && make` so you can't accidentally publish a stale PDF.

## Known warnings and fixes

Two warnings had to be silenced; both fixes are already active in the
repo. Re-introducing either is a regression.

1. **`LaTeX Font Warning: Font shape 'T1/lmr/bx/sc' undefined`** — Latin
   Modern does not provide a bold-extended + smallcaps shape, so a
   `\titleformat{\section}{...\bfseries\scshape...}` triggers this warning
   on every section (visible per-file in IDE linters). **Fix**: remove
   `\scshape` from `\titleformat`. Section titles become bold Title-case
   (no smallcaps) — visually cleaner and modern for senior resumes.
   *Not recommended*: `\DeclareFontShape{T1}{lmr}{bx}{sc}{<->ssub * lmr/b/sc}{}`
   fails when placed at top of preamble because the `T1/lmr` family is
   not yet registered (lazy `.fd` load). Would need `\AtBeginDocument{...}`
   wrapping. Dropping `\scshape` is simpler and visually preferable.

2. **`Package hyperref Warning: Option 'bookmarks' has already been used`**
   — `\usepackage[hidelinks]{hyperref}` already sets `bookmarks=true`. An
   explicit `bookmarks=true` inside `\hypersetup{}` triggers the warning.
   **Fix**: omit `bookmarks=true` from `\hypersetup{}`. `hidelinks` already
   provides it.

## Density tuning (2-page preferred, 3-page acceptable)

**Page-count policy for this profile** (updated 2026-04 after a session
that added Argus/Rust, billing+inventory, Stripe, cometag firmware,
Chapatuplaza RAG, observability stack, and three verifiable certs):

- **2 pages is the preferred target**, not a hard ceiling.
- **3 pages is acceptable** when the user has explicitly asked to include
  substantive content (new projects, additional roles, verifiable cert
  URLs, observability stack) and the trade-off would be cutting content
  they just asked for. Recruiters prefer 3 honest pages over 2 crammed
  pages with verifiable work stripped out.
- **Never** drop user-requested content (cert URLs, project bullets,
  stack categories like Observability) *just* to hit 2 pages. Ask
  first if a trim is needed.

The reference doc proposes `margin=0.65in` and
`\titlespacing*{\section}{0pt}{10pt}{4pt}`. With 7+ roles and quantified
bullets, that yields **3 pages**. The verified 2-page recipe used in this
repo:

| Knob                      | Value used       | Floor (don't go past) |
|---------------------------|------------------|-----------------------|
| Font size                 | `11pt`           | `10pt`                |
| Page margin               | `0.45in`         | `0.45in` (at floor)   |
| Section top spacing       | `12pt` (before)  | `8pt`                 |
| Section bot spacing       | `5pt` (after)    | `2pt`                 |
| Itemize `topsep`          | `0pt`            | `0pt`                 |
| Itemize `itemsep`         | `0pt`            | `0pt`                 |
| `\cvEntry` leading vspace | `3pt`            | `0pt`                 |
| `\cvEntry` trailing vspace| `2pt`            | `0pt`                 |

**Readability rationale**: the dominant visual lever is *space around the
section title rule* — if it feels cramped, recruiters subconsciously see
"wall of text". `12pt` before / `5pt` after gives the rule room without
costing a whole page. After that, inter-entry breathing (`\cvEntry`
leading vspace 3pt) separates jobs; inside a job, bullets stay tight
(itemize 0/0) so the unit reads as one block.

**Trade-off when content grows**: if adding a role pushes past 2 pages,
do NOT first reduce margin below 0.45in or font below 11pt. Instead:
1. Merge redundant bullets (combine related outcomes with `;`).
2. Drop the oldest "Earlier roles" bullets to one-line.
3. Fold single-line standalone sections (Languages, Certifications) into
   `cvSkill` rows at the bottom of Skills — saves a section header.
4. Last resort: reduce `\cvEntry` leading vspace to 2pt (still legible).

If after steps 1–4 the resume still overflows, **ask the user** before
cutting substantive content. Accepting 3 pages is preferable to silently
dropping a project/cert/award they asked to include.

**Watch out for linter churn**: this repo has hooks that revert
`\titlespacing*` values toward the readability midrange (around
`{10pt}{5pt}`). Don't spend cycles fighting them — your aggressive
tight values will get rolled back, and the resume will end up at a
reasonable spacing either way.

## Bullet formula

Action verb + Context + Result. Seven top U.S. career centers teach the
same rule under five names (CAR, PAR, ACE, STAR, WHO/XYZ).

**Quantify when real numbers exist**: latency, throughput, cost savings,
team sizes, users onboarded, deploys/week, commit volume.

**Do not fabricate metrics.** Engineering outcomes are often not cleanly
quantifiable — architectural, behavioral, strategic. In that case,
**specific qualitative bullets** with concrete technical nouns (stack,
systems integrated, problem solved) beat fake percentages. Harvard's
rubric is explicit: *fact-based*.

- ❌ "Improved system performance by 40%" (unverifiable recruiter-bait)
- ✅ "Scaled Postgres master DB using Aurora Serverless v2 read replicas;
      built AWS Lambda health-check integrated with Slack + Sentry"

## Verifiable certifications (URLs in Certifications section)

For any cert with a public verification URL, include it as visible text
using the same URL-visibility rule as the rest of the resume. Strip the
`https://` prefix; keep enough of the path that the URL is copy-pasteable
and human-identifiable.

Canonical patterns:

```latex
%% Credly badges (AWS, Microsoft, Cisco, etc.)
\item \cvHeading{AWS Certified Cloud Practitioner} -- Amazon Web Services. \href{https://www.credly.com/badges/<uuid>/linked_in_profile}{credly.com/badges/<uuid>}

%% Coursera accomplishments
\item \cvHeading{<Course Title>} -- <Issuer> (<Month Year>). \href{https://www.coursera.org/account/accomplishments/verify/<CODE>}{coursera.org/verify/<CODE>}

%% Non-URL cert (official diploma, no public verification)
\item \cvHeading{<Cert Name>} -- <Issuer> (<Date>) --- <relevant metrics, e.g. 120 hours, grade 19/20>.
```

Notes:
- Drop the trailing `/linked_in_profile` from the visible Credly URL —
  the bare `credly.com/badges/<uuid>` is shorter and renders the same
  verification page. Keep the full URL inside `\href{...}` for the PDF
  link target.
- Put cert date in parentheses after the issuer (`Jun 2024`), not inline
  in the title — the title field is what ATS parses as the cert name.
- For diploma-style certs without a verification URL (e.g. university
  specialization), include metrics that make the cert auditable
  (hours, grade, issuing faculty) so reviewers don't mistake it for a
  MOOC badge.

## Testing checklist

Run after every non-trivial edit:

```sh
make clean && make                      # produces resume.pdf
pdffonts resume.pdf                     # every row must show emb yes / uni yes
pdftotext -layout resume.pdf -          # inspect reading order
```

In the `pdftotext` output confirm:

- Reading order is linear, top-to-bottom.
- Ligatures survive: "artificial" / "full-stack" / "office" are intact,
  not `arti cial` / `full -stack` / `o ce`.
- Accented characters render: `Perú`, `México`, `Ingeniería` appear with
  tilde/acute, not `?` or boxes.
- Each job keeps title, company, and dates on adjacent lines.
- URLs appear as visible text: `linkedin.com/in/oscargicast`, etc.
- Verifiable certs (Credly, Coursera) show both the cert title and the
  verification URL as visible text (never as a plain "verify" hyperlink).
- Page count: ≤ 2 pages preferred; ≤ 3 pages acceptable if the extra
  content is substantive and user-requested (projects, cert URLs,
  observability stack). Reject silent trims of user-requested material
  in pursuit of 2 pages.

Optional extra: paste the PDF into Claude/GPT with *"Extract job titles,
companies, dates, skills as JSON"*. If the LLM drops any role, an ATS
will too.

## Templates and patterns to reject

Do not introduce any of these into `resume.tex`:

- `moderncv` (any style / color) — internal tables for alignment, icon
  glyphs without ToUnicode maps, missing `\pdfgentounicode`.
- `Awesome-CV`, `AltaCV`, `Deedy-Resume`, `Friggeri` — two-column or
  sidebar templates. Open ATS-incompatibility issues confirmed in each.
- `\fancyhdr` / `\fancyhead` / `\fancyfoot` for any information the
  reader must keep.
- `multicol`, `paracol`, `minipage`-based side-by-side layouts.
- FontAwesome / Font Awesome icons without accompanying visible text.
- Decorative `\quote{...}` at the top of the document.
- `\photo{...}` or any `\includegraphics` for a headshot.
- `fontspec` with display fonts lacking complete Unicode CMAP tables.

## When asked "optimize my resume"

Propose a concrete diff, not a checklist. Always:

1. Read `resume.tex` and `sections/*.tex` and identify concrete
   violations of the hard rules above — cite file path and line number.
2. Extract the content (roles, bullets, education) so you can migrate
   without losing data.
3. Rewrite the preamble to the canonical block above if non-compliant.
4. Rewrite bullets only if they violate Action+Context+Result; don't
   rewrite bullets that already follow it.
5. Run the testing checklist (`pdffonts`, `pdftotext`) and report real
   output, not claims.

## Workday / Taleo escape hatch

Workday's "Autofill with Resume" sometimes mangles even clean PDFs. If
the user is applying to a Workday tenant, offer a parallel `.docx` from
the same LaTeX source:

```sh
pandoc resume.tex -o resume.docx
```

Oracle Taleo is also measurably safer on `.docx` than PDF. Keep both as
optional deliverables — don't commit `resume.docx` to the repo unless
explicitly requested.
