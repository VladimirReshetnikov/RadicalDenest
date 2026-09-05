# Technical audit of the supplied radical-denesting program

Prepared 5 September 2026.

## Main deliverables

- `article.pdf`: the 34-page article, with proofs, worked examples, source-line
  references, prioritized findings, documentation references, and the complete
  original source listing.
- `article.tex`: the LaTeX source of the article.

The analysis covers `Strad`, `DenestRadicals3`, `denest11`, the multiplier search,
minimal-polynomial/GCD candidate generation, denominator rationalization, nesting
helpers, and the custom factorization subsystem.

## Evidence and execution boundary

The supplied Wolfram Language program was reviewed statically. It was **not run
in a Wolfram kernel** for this audit. No end-to-end Wolfram timing, observed message
transcript, or passing Wolfram regression count is claimed.

`verify_algebra.py` **was run**, using Python 3, SymPy 1.14.0, and mpmath 1.3.0.
It independently checks the worked minimal polynomials and GCDs, the negative and
complex branch counterexamples, the equal-degree pruning counterexample,
denominator-rationalization identities, comparator logic, and candidate counts.
It is not a Wolfram Language emulator and does not execute the original program.

`safer_core.wl` and `regression_tests.wlt` are **unexecuted Wolfram proposals**.
The former is a guarded one-multiplier component, not a complete replacement
radical denester. Exact equality and a lower-degree GCD do not by themselves
certify a better radical representation. The article explains these boundaries.
Several legacy-code regression tests are deliberately expected to fail: their
expected results express the preservation contract, not observed legacy output.
A Wolfram release may pre-simplify some example expressions before a faulty path
is reached. The mathematical counterexamples and the source defects must be
kept distinct from a kernel-specific runtime reproduction.

## Included files

| File | Purpose |
| --- | --- |
| `article.pdf` | Rendered article |
| `article.tex` | Article source |
| `original.wl` | Byte-for-byte copy of the uploaded `Pasted text.txt` |
| `verify_algebra.py` | Executed independent verification script |
| `verification_results.txt` | Captured output of the verification run |
| `verification_results.json` | Structured output of the same run |
| `safer_core.wl` | Unexecuted guarded trial-component proposal |
| `regression_tests.wlt` | Unexecuted expected-behavior Wolfram tests |
| `README.md` | This file |
| `SHA256SUMS.txt` | Checksums for every other file in this directory |

Original source SHA-256:

```
693a2825f1e2b8912e55371b90dc8ed115bc33ee707dd3a4521eb22bcd2ccc93
```

The original file has 585 physical lines and retains its original CRLF line
endings. Source references in the article use those physical line numbers.

## Rebuild the PDF

Keep `original.wl` beside `article.tex`. A TeX installation containing the packages
listed in the preamble is required; this includes `newtxtext`, `newtxmath`,
`amsmath`, `amsthm`, `mathtools`, `listings`, `longtable`, `microtype`, `xurl`,
`hyperref`, and `bookmark`. No external image or font files are included or needed.

Run from this directory:

```sh
pdflatex -interaction=nonstopmode -halt-on-error article.tex
pdflatex -interaction=nonstopmode -halt-on-error article.tex
```

A third pass may be appropriate after editing headings or references. PDF byte
checksums can differ after rebuilding because of compilation metadata.

## Rerun the independent checks

With SymPy and mpmath installed:

```sh
python verify_algebra.py > verification_results.txt
```

The script also rewrites `verification_results.json` next to itself. An assertion
failure exits unsuccessfully. No network requests or Wolfram service are used.
Re-running or editing files will naturally make the original checksum manifest
out of date.

## Run the proposed Wolfram regressions separately

Use a **fresh, disposable Wolfram kernel**. The original program defines many
symbols in the current context and unprotects `Print` at load time. The test suite
records and restores the prior attributes of `Print`, but it does not isolate all
of the original definitions or undo arbitrary effects of evaluating the code.

In a Wolfram notebook or kernel, evaluate with the actual extracted path:

```wl
TestReport[FileNameJoin[{"/path/to/radical_denesting_review",
   "regression_tests.wlt"}]]
```

The suite loads `original.wl` and `safer_core.wl` relative to its own path. It bounds
selected legacy calls by 20 seconds, but this is not a total-suite memory or time
limit. Record the Wolfram version and inspect failures and messages rather than
interpreting all failures as the same kind of defect.

## Verify archive integrity

On systems with `sha256sum`, run from this directory:

```sh
sha256sum -c SHA256SUMS.txt
```

The checksum manifest does not include itself. The ZIP archive includes no build
logs, temporary page renders, Python bytecode, or font files.
