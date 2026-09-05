# RadicalDenest

Analysis, correction and literature survey of `Strad.wl`, a Wolfram Language
program that denests radicals: it rewrites an expression such as
`Sqrt[5 + 2 Sqrt[6]]` as `Sqrt[2] + Sqrt[3]`, or `(2^(1/3) - 1)^(1/3)` as
`(1 - 2^(1/3) + 4^(1/3))/9^(1/3)`, whenever an expression with fewer nested
root extractions exists and can be found.

The repository has three parts: the program and its corrected version (`src/`),
a code review of the program built from three independent reviews plus
kernel experiments (`src/code-review/`), and a research guide to the
mathematical and computer-algebra literature on radical denesting together with
the freely available sources themselves (`docs/`).

## Layout

```
.
├── LICENSE                       MIT-0
├── README.md                     this file (AGENTS.md and CLAUDE.md are symlinks to it)
├── src/
│   ├── original/Strad.wl         the program under review, unchanged (585 lines)
│   ├── corrected/StradFixed.wl   corrected and hardened version, context RadicalDenest`
│   └── code-review/
│       ├── review-1/             three independent reviews of Strad.wl, each with
│       ├── review-2/             its own report (PDF + LaTeX), test suite and
│       ├── review-3/             proposed replacement kernel
│       └── unified/              unified analysis: report, LaTeX source, Wolfram
│                                 harness, raw logs, generated result tables
└── docs/
    ├── report/                   unified research guide to the denesting literature
    ├── literature/               downloaded papers, theses, documentation, web resources
    └── scripts/                  the download tooling that produced docs/literature
```

## The program and its correction (`src/`)

`src/original/Strad.wl` is the input to the whole project. Its architecture is
a marker wrapper around radicals, a multiplier search using minimal polynomials
and polynomial GCDs over algebraic extensions, a roots-of-unity orbit over the
candidates, and a final numerical check. The reviews and experiments found
defects in each stage: loss of the principal branch when a power is
re-extracted, branch-unsafe power identities, results accepted on the strength
of `PossibleZeroQ` "assuming zero" messages, a comparator that reverses lists,
unbounded searches, and silent failures on symbolic input.

`src/corrected/StradFixed.wl` keeps the architecture but makes correctness
independent of the heuristics. Every result is certified equal to the input by
exact algebra (`RootReduce` or `PossibleZeroQ` with
`Method -> "ExactAlgebraics"`), is strictly simpler under an explicit radical
cost or is the input itself, and the search stops within a trial or time
budget. Public symbols: `Strad`, `DenestRadicals`, `DenestCore`,
`RationalizeDenominator`, `Factorc`, `RadicalDepth`, `RadicalCost`,
`ExactAlgebraicQ`, `CertifiedEqualQ`. See `src/corrected/README.md` for usage
and `src/corrected/KNOWN_GAPS.md` for the denestable inputs it is known to
leave unchanged, with diagnoses and proposed fixes.

## The code review (`src/code-review/`)

`review-1`, `review-2` and `review-3` are three independent reviews of the
original program, each with a PDF report and LaTeX source, a copy of the
reviewed file, a Wolfram test suite and a proposed safer kernel. They were the
starting material for the unified analysis.

`unified/unified_analysis.pdf` compares the three reviews, reconstructs the
algorithm, proves the supporting mathematics, executes the program and the
reviews' test suites in Wolfram 15.0.1, catalogues 27 defects with evidence,
presents the corrected implementation and evaluates it on the same battery, and
lists future improvements. Everything reported there is reproducible from
`unified/harness/` (Wolfram scripts, absolute paths at their top) and is
recorded verbatim in `unified/logs/`; `unified/tables/` holds the result
tables generated from those logs. Build with three passes of `pdflatex` from
`src/code-review/unified/`; the listings appendix reads the two `.wl` files
from `src/`.

## The literature (`docs/`)

`docs/report/radical_denesting_unified.pdf` is *Radical Denesting: A Unified
Research Guide* (48 pages, 103 annotated bibliography entries). It was built by
consolidating four AI-generated research reports and then merging the three
unified syntheses that had been prepared from them. It covers the classical
square-root theory with proofs, Ramanujan's identities, the precise
higher-index criteria of Honsbeek and the cubic-in-quadratic test, the
algorithmic literature from Caviness–Fateman and Zippel through Borodin–Fagin–
Hopcroft–Tompa, Landau, Blömer, Horng–Huang and Cotner, field theory and
complexity models, equality testing, the actual contracts of the denesters in
SymPy, Maxima, Wolfram Language, Maple, SageMath, PARI/GP and FLINT/Calcium,
infinite radicals, a correction ledger, and reading paths. `docs/report/verify.py`
runs 59 exact SymPy checks of the identities used; its transcript and JSON
record sit beside it. The typography follows the ProveIt
`Analysis/FabiusFunction/docs` house style.

`docs/literature/` is the dataset of freely available sources cited in the
guide: 102 assets (54 PDFs, 49 TeX sources) covering 66 works, arranged as
`papers/<record>/` and `web_resources/<record>/`, with `download_manifest.json`
as the authoritative index (per-file SHA-256, origin URL, retrieval method,
evidence level). Six articles that existed only as poor scans also have
corrected re-typesettings under `retypeset-2026/`; `RETYPESET_ARTICLES.md`
describes them. Twenty-six planned assets could not be retrieved
(paywalls, bot blocks, dead hosts); the manifest lists them.

`docs/scripts/` contains the three independently written download packages
that were compared, the one that was selected and corrected
(`radical_literature_retrieval_package`), its helper scripts for supplementary
routes and manually obtained files, and a README recording the comparison, the
corrections and the outcome of both download passes.

## Requirements

- Wolfram Language 15 with `wolframscript` for the program and the harness.
  A single-seat license allows one kernel at a time; the harness scripts run
  sequentially.
- A TeX distribution with `pdflatex` (MiKTeX and TeX Live both work) for the
  reports. The research guide uses the Libertinus fonts and falls back to
  Latin Modern if they are absent.
- Python 3.10+ with SymPy for `docs/report/verify.py` and for the download
  scripts (which need no third-party packages).

## Conventions

Line endings are LF (`.gitattributes`, `.editorconfig`); PDFs and images are
binary. Log files are ignored by git, so recorded transcripts are stored with a
`.txt` extension. Everything is released under the MIT-0 license (`LICENSE`).
