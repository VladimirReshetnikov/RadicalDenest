# Radical-denesting code audit

## Start here

- `review.pdf`: complete article, including proofs, findings, repairs, and the full line-numbered original source.
- `review.tex`: self-contained LaTeX source (with two local code listings).

## Source and scope

`source.wl` is a byte-for-byte copy of the uploaded source. It is NOT patched.
SHA-256: 693a2825f1e2b8912e55371b90dc8ed115bc33ee707dd3a4521eb22bcd2ccc93

The source was fully inspected but was NOT executed in a Wolfram kernel in this session.
The review separates static findings, mathematical proofs, independent executed checks,
and proposed Wolfram regression tests.

## Executed verification

`independent_checks.py` performed 26 successful checks using Python 3.13.5
and SymPy 1.14.0. It verifies mathematical identities, exact minimal polynomials
and GCDs, and small models of source invariants. It does not emulate or execute Wolfram Language.
Results: `verification_results.json` and `verification_results.txt`.

Re-run with:

    python independent_checks.py

SymPy is required. The report records the installed version on every run.

## Proposed repairs and unexecuted Wolfram tests

`safe_candidate_kernel.wl` implements one conservative, exact-verified multiplier trial.
It is NOT a complete replacement for the original scheduler and has NOT been executed
in a Wolfram kernel during this review. It exports a candidate scorer as a separate policy.

`regression_tests.wlt` asserts desired behavior. Several tests are expected to fail
against the original program; this is intentional. It includes checks for the proposed
kernel as well. No target-kernel pass count is claimed.

Run in a fresh kernel:

    wolframscript -file run_tests.wl

The runner records the actual kernel version and restores the original Print attributes.
The supplied source itself globally unprotects Print, so avoid loading it casually into
a valuable interactive kernel. Tests use finite per-evaluation time budgets.

## Building the PDF

Run from this directory:

    pdflatex -interaction=nonstopmode -halt-on-error review.tex
    pdflatex -interaction=nonstopmode -halt-on-error review.tex

A TeX installation with libertinus, geometry, microtype, mathtools, amssymb, amsthm,
booktabs, longtable, array, tabularx, xcolor, enumitem, listings, fancyhdr, hyperref,
and bookmark is required. No font binaries are distributed in this archive.

The article cites the supplied source by physical line number and official Wolfram
documentation for language semantics. Source-line numbers match `source.wl`.
