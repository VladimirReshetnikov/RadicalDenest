# Radical-denesting code review

## Main deliverables

- radical_code_review.pdf: the 38-page article.
- radical_code_review.tex: self-contained LaTeX source. All three source-code
  appendices are embedded, so compilation does not require external listing files.

The article reviews the supplied Wolfram Language functions DenestRadicals3,
denest11, Strad, and their helpers. It includes a source map, mathematical
justification of the algebraic core, 14 prioritized findings, exact branch and
power-rule counterexamples, search-cost analysis, and a staged repair strategy.

## Supporting files and evidence boundary

- original.wl: unchanged bytes of the supplied Pasted text.txt attachment.
- verify_algebra.py: independent algebra, elementary counting, and source-rule
  checks. This does NOT execute or emulate the supplied Wolfram program.
- test_results.json: generated results; 45 checks passed. One check contains
  21 high-precision numerical phase-recovery sanity cases. Those numerical
  cases supplement, rather than replace, the proof in the article.
- run_wolfram_audit.wl: 14 regression contracts for a real Wolfram kernel.
  These were NOT executed during this review. Some are expected to fail on
  the original source because they test desired correctness guarantees.
- verified_multiplier_trial.wl: a proposed defensive, single-multiplier
  component. It was NOT executed in a Wolfram kernel and is NOT a complete
  replacement for the original denester. Certified equality is distinct
  from improved radical depth; the component exposes that distinction.

The original source and all proposed Wolfram code were inspected statically,
not executed in a Wolfram kernel. The article carefully distinguishes
source-established facts, independently checked mathematical examples,
and unexecuted end-to-end regression probes. No original-program benchmark
or test-coverage claim is made.

## Rebuild the PDF

Use a LaTeX installation such as TeX Live with the packages named in the
preamble (amsmath, amssymb, amsthm, mathtools, geometry, microtype, booktabs,
longtable, array, tabularx, xcolor, listings, fancyhdr, enumitem, hyperref,
bookmark, and Latin Modern). From this directory, run:

    pdflatex -interaction=nonstopmode -halt-on-error radical_code_review.tex
    pdflatex -interaction=nonstopmode -halt-on-error radical_code_review.tex
    pdflatex -interaction=nonstopmode -halt-on-error radical_code_review.tex

No shell escape, external bibliography processor, or network access is needed.
The supplied PDF was compiled successfully and its rendered pages inspected.

## Reproduce the independent checks

Dependencies used: Python 3.13.5, SymPy 1.14.0, mpmath 1.3.0.
Run:

    python verify_algebra.py

This regenerates test_results.json beside the script. An unsuccessful check
raises AssertionError. It does not require or contact a Wolfram service.

## Execute the unrun Wolfram regression contracts

Use a fresh/disposable Wolfram kernel with wolframscript, from this directory:

    wolframscript -file run_wolfram_audit.wl

WARNING: original.wl clears several global symbols and executes
Unprotect[Print] at load time. The runner restores the original Print
attributes on normal completion and an ordinary abort, but a disposable
kernel is still required. Individual algorithm calls have a 20-second
TimeConstrained wrapper. Expect failing contracts; they are diagnostic.
The defensive component should be loaded and tested separately.

## Source integrity

Original attachment: Pasted text.txt
Bytes: 21199
SHA-256: 693a2825f1e2b8912e55371b90dc8ed115bc33ee707dd3a4521eb22bcd2ccc93

Review date: September 5, 2026.
The original source was supplied by the user. No additional author,
original publication date, supported kernel version, or license was inferred.
