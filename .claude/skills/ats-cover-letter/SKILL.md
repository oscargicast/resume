---
name: ats-cover-letter
description: >
  Use when editing per-company LaTeX cover letters under `cover-letters/` in
  this repo. Inherits ATS-proof rules from `ats-resume` (glyphtounicode +
  pdfgentounicode, `\DisableLigatures`, no fancyhdr, visible URL text,
  mainstream fonts) AND enforces cover-letter-specific conventions: one-page
  cap, shared preamble, concrete posting-anchored opener, no em/en-dashes,
  noun-led bullet callouts, direct closer. Triggers on: "cover letter",
  "carta de presentación", "carta de postulación", "cover-letter.tex",
  "cover-letters/".
---

# ats-cover-letter

Authoritative guide for editing cover letters under `cover-letters/` in
this repo. Mirrors the ATS-proof rules from `ats-resume` and layers cover-
letter structure, writing, and build conventions on top. When this skill
and `CLAUDE.md` disagree, this skill wins for cover-letter edits.

## Relationship to `ats-resume`

Everything `ats-resume` enforces about the preamble applies here too:

- `\input{glyphtounicode}` + `\pdfgentounicode=1` for the ATS ligature fix.
- `\DisableLigatures[f]{encoding = *, family = *}` as belt-and-suspenders.
- Latin Modern via `lmodern` + `microtype`.
- Visible URL text with `https://` stripped; FontAwesome icons only as
  decoration next to the full URL/email/phone.
- No `\fancyhdr` for contact info. Header is body text in a
  `\begin{center}` block.
- Two-tone `titleStrong` / `titleMid` color palette, heading-only.
- No photo, no multi-column, no `moderncv`, no `AltaCV` / `Deedy-Resume`,
  no `fontspec` display fonts.

The shared preamble (`cover-letters/_common/cover-letter-preamble.tex`)
inherits those rules verbatim. Do not drift. If `ats-resume` updates the
canonical preamble, port the change over in the same commit.

What this skill adds on top of `ats-resume`:

1. One-page hard cap (not 2–3 like the resume).
2. Wider margins (0.8in vs 0.45in) for letter-style reading flow.
3. Cover-letter structure (date, role line, salutation, body, closer).
4. Writing rules for persuasive prose (opener, bullets, closer, register).
5. Per-company folder layout + Makefile pattern rule.
6. Left-align everything, ragged-right body (see *Hard rules* below).

## Folder layout

```
cover-letters/
├── _common/
│   └── cover-letter-preamble.tex        # shared preamble + \coverHeader
└── <company-slug>/
    ├── cover-letter.tex                  # per-company source
    ├── cover-letter.pdf                  # committed build output
    └── job-posting.md                    # captured job description (reference)
```

**Slug convention**: lower-kebab-case, `<company>-<role-short>`, e.g.
`robots-and-pencils-ai-engineer`. Short. The role suffix disambiguates
multiple applications at the same company. Avoid dates in the slug; the
posting's date lives inside `job-posting.md`.

## Shared preamble: single source of truth

`cover-letters/_common/cover-letter-preamble.tex` is the only place the
preamble lives. Per-company `cover-letter.tex` files **must** start with:

```latex
\input{../_common/cover-letter-preamble.tex}
\begin{document}
\coverHeader
...
```

Never copy the preamble into a per-company file. Changes that affect every
letter go in `_common/`; changes that affect one letter stay in that
letter's `cover-letter.tex` after the `\input`.

The preamble exports:

- All ATS-proof preamble settings (see `ats-resume` for the full spec).
- `\AtBeginDocument{\raggedright}` — global ragged-right for the body
  (see *Hard rules* below).
- `\cvHeading{text}` — same semantics as the resume's, for bolded sub-
  titles in `titleMid` color.
- `\coverHeader` — renders the same identity and contact block as
  `resume.tex`, followed by a thin `titleStrong` horizontal rule.

## Hard rules

Layout/typography rules specific to cover letters. These are in addition
to everything `ats-resume` enforces.

- **Left-align everything (ragged-right).** Do not use justified text in
  the body. Justification (the LaTeX default) stretches inter-word space
  on short lines and creates visible "rivers"; on a letter-width column
  with English prose that reads like a press release, not like human
  correspondence. The shared preamble enforces this with
  `\AtBeginDocument{\raggedright}`, which takes effect once the document
  body starts. The header's `\begin{center} ... \end{center}` block opens
  its own group and still centers correctly — `\centering` inside the
  `center` environment overrides the global `\raggedright` locally and
  the ragged-right setting is restored after `\end{center}`. Do not add
  per-paragraph `\justifying` or `\begin{flushleft}` wrappers; the global
  default is sufficient. Do not re-enable justification at the letter
  level "for a cleaner right edge" — a ragged edge is the intended look.
- **One page.** The body must fit on one page without shrinking the
  `_common/cover-letter-preamble.tex` margin or font size. If it
  overflows, tighten the prose. See *Testing checklist* below.

**Contact data is canonical in `resume.tex`.** The `\coverHeader` macro
must stay in sync with the resume header. When email/phone/URL changes
in `resume.tex`, update `cover-letters/_common/cover-letter-preamble.tex`
in the same commit.

## Structure of a cover letter

Every letter uses this order (matches the reference implementation at
`cover-letters/robots-and-pencils-ai-engineer/`):

1. `\coverHeader` — identity + contact.
2. **Date line** in written English: `April 24, 2026`. Not ISO, not
   localized Spanish, not day-first British.
3. **Company + role line**: `\cvHeading{Company Name}: Role (Location,
   Mode)`. Colon separator between company and role. Never em-dash.
4. **Salutation**: `Dear <Company> Hiring Team,` (the team form keeps it
   warm without faking a name you don't have; avoid "To Whom It May
   Concern").
5. **Opening paragraph**: posting-anchored. See *Opener pattern* below.
6. **Current-role paragraph** with up to two bulleted callouts on the
   most-relevant current-role projects.
7. **Pre-current-role paragraph** stitching 2–3 earlier projects that
   hit posting keywords.
8. **Fundamentals paragraph**: language-years, stack breadth, leadership,
   AI-tool fluency (e.g. Claude Code).
9. **One-sentence closer** naming 2–3 things you'd walk through + sign-off.

Target length: **one page, no spacing hacks**. If the body overflows,
tighten the prose — do not shrink the margin, font, or line spacing.

## Writing rules (the "AI-text tell" ban)

AI-generated prose has telltale markers. Reject all of these:

- **Em/en-dash between clauses.** No `—`, no ` -- `, no ` – `. Replace
  with:
  - Comma (apposition).
  - Colon (label:value or topic:elaboration).
  - Semicolon (coordinate clauses).
  - Period (new sentence).
  Hyphens inside compound words are fine: `single-table`, `event-driven`,
  `multi-agent`, `LLM-callable`, `line-for-line`, `AI-assisted`.
- **Buzzword bridges.** Ban: "maps directly to", "overlap tightly with",
  "aligns perfectly with", "is a strong fit for", "wealth of experience".
  Replace with a concrete claim that names stack, service, or outcome.
- **Puffed opener clichés.** Ban: "I am writing to express my interest
  in", "I was excited to see your posting for", "As a seasoned engineer".
- **Hedging qualifiers.** Ban: "I believe", "I feel", "I think". State
  directly.
- **Fabricated metrics.** Follow `ats-resume`'s Bullet formula: specific
  qualitative beats fake percentages. Use counts, versions, and named
  tools, not "improved by X%".
- **Inconsistent contractions.** Pick contracted register (I'm, I've,
  I'd, that's) and stay there, or pick uncontracted (I am, I have, I
  would, that is) and stay there. Mixing reads as machine-edited.
- **Wall-of-text paragraphs over 6 lines.** Break with a semicolon list
  or split into two paragraphs.

## Opener pattern

The opener must name **at least three specific technologies, services,
or frameworks from the posting** and tie them to Oscar's actual stack.
Model:

> I'm applying for the `<Role>` role. Your posting describes `<concrete
> thing they are building>` running on `<service A>`, `<service B>`, and
> `<service C>`, with `<specific nice-to-have>` on the Nice-to-Have
> list. That's almost line-for-line the stack I've been shipping on at
> `<current company>` since `<Month Year>`, and earlier at `<prior
> company>` and `<prior company>`.

This is assertive without claiming fit beyond the facts. It also forces
you to read the posting closely enough to find three services. If you
can't, the role is probably not a match and the letter won't carry.

## Bullet callouts

Up to **two** bullets, inside the current-role paragraph, for highlight
projects. Noun-led (not verb-led like resume bullets) — a cover-letter
bullet points at a thing, it doesn't claim an action:

```latex
\begin{itemize}
  \item \cvHeading{<Project>}, <one-line stack sketch>: <the 2-3
        concrete features that map to the posting>. <Optional
        posting-keyword callout clause>.
  \item \cvHeading{<Project>}, <stack>: <features>.
\end{itemize}
```

**The negation pattern** ("not a prototype", "not something I'd be
learning on the job", "not a re-learn") is the strongest rhetorical
move available. Use it at most **once** per letter; save it for the
single strongest claim.

## Closer

One sentence. Direct. Offers a specific next step by naming the
project(s) you'd walk through.

- ✅ `Happy to walk through <project A>, <project B>, or <project C> on a call.`
- ❌ `I would welcome the opportunity to discuss further.`
- ❌ `Looking forward to hearing from you.`
- ❌ `Please find my resume attached.`

End with `Best regards,` + newline + `\cvHeading{Oscar Giraldo Castillo}`.
Never `Sincerely yours,` / `Kind regards,` / `Warmly,` in this repo —
pick one sign-off and keep it consistent across letters.

## Truthfulness constraint

Every claim must map to a verifiable line in `resume.tex` /
`sections/*.tex` or a real project in `sections/projects.tex`. If the
cover letter says "at SpaceAG I ran X", `sections/experience.tex` must
contain the matching bullet. Do not invent projects or stretch scope to
match a posting keyword.

When a required skill is genuinely not in Oscar's background, do not
paper over it. Either:

- Acknowledge transferable experience honestly ("the serverless-on-Lambda
  shape carries over to Python on day one"), or
- Omit the claim and let the resume speak for itself.

## Build

```sh
make cover-letters   # builds every cover-letters/*/cover-letter.tex
make clean && make cover-letters   # force full rebuild after edits
```

The Makefile pattern rule compiles each letter under
`build/cover-letters/<slug>/` with `latexmk`, then copies
`cover-letter.pdf` next to its source. Intermediate artifacts stay under
`build/` (gitignored); `cover-letter.pdf` is committed alongside each
source so it can be uploaded without a rebuild.

## Testing checklist

```sh
make clean && make cover-letters
pdffonts cover-letters/<slug>/cover-letter.pdf       # emb yes / uni yes for every row
pdftotext -layout cover-letters/<slug>/cover-letter.pdf -
```

In the `pdftotext` output confirm:

- **One page** — no page-break marker, no second header copy, no
  orphaned sign-off on a second page.
- Reading order is linear, top-to-bottom.
- Ligatures survive (`artificial`, `full-stack`, `office` intact — never
  `arti cial` / `full -stack` / `o ce`).
- `Perú` renders with the accent (not `?` or a box).
- URLs appear as visible text (`linkedin.com/in/oscargicast`, etc.);
  identifier is copy-pasteable.
- The opener namechecks **≥ 3 specific services or technologies** from
  the posting.
- Zero em-dash / en-dash characters anywhere in the body.
- Salutation + closer are present and match the conventions above.

## Adding a new cover letter

1. `cp -r cover-letters/robots-and-pencils-ai-engineer/
   cover-letters/<new-slug>/`.
2. Replace `job-posting.md` with the new posting. Include: company,
   role, location/mode, URL, saved-on date, full posting text, and a
   short "my strongest alignment points" section you'll draw from.
3. Rewrite `cover-letter.tex` body. Keep the
   `\input{../_common/cover-letter-preamble.tex}` line. Follow the
   structure above. The *Opener pattern* is the single highest-leverage
   rewrite — get it right, the rest follows.
4. `make cover-letters`.
5. Run the testing checklist.
6. Commit both `cover-letter.tex` and `cover-letter.pdf` (and the
   reference `job-posting.md`).

## Reference implementation

`cover-letters/robots-and-pencils-ai-engineer/` is the canonical example.
Structure, tone, and density are calibrated there. When in doubt, read
that letter first and copy its shape before drifting.
