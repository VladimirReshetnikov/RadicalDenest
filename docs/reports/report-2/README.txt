RADICAL DENESTING: A UNIFIED RESEARCH REPORT
Research and documentation audit: 5 September 2026

This package consolidates the four reports supplied in reports.zip into a
single 39-page report with 99 annotated bibliography entries. It includes
classical results, field-theoretic foundations, algorithms and complexity,
Ramanujan-type identities, later research, CAS documentation, exact examples,
and an appendix explaining corrections and deduplication decisions.

FILES
  radical_denesting_unified.pdf  Compiled report with linked references.
  radical_denesting_unified.tex  Self-contained LaTeX source and bibliography.
  verify_examples.py            Exact algebraic checks and SymPy experiments.
  verification_results.json     Recorded results of the successful test run.
  README.txt                    This file.

BUILD THE REPORT
  latexmk -pdf radical_denesting_unified.tex

Alternatively, run pdflatex repeatedly until cross-references and the table
of contents stabilize. A standard TeX Live installation with New PX fonts
and the packages named in the preamble is required. There is no external
bibliography database, illustration dependency, or proprietary font file.

RUN THE EXACT CHECKS
  python verify_examples.py

Requires Python 3.10+ and SymPy. The included results were generated with
Python 3.13.5 and SymPy 1.14.0; all exact assertions passed. The script writes
verification_results.json beside itself. No network access is needed.

EVIDENCE AND LIMITATIONS
The bibliography marks original-text consultation, official documentation
or code, metadata/abstract verification, and retained background leads
separately. A full-text label does not assert independent verification of
every proof in that work. Some unverified leads are explicitly retained in
the audit appendix rather than presented as established findings.

Only SymPy was executed for the CAS comparison. Maple, Maxima, Wolfram
Language, SageMath, PARI/GP, and FriCAS were not run. Their discussed features
are documentation/code findings, not claimed runtime experiments. Failure
of a simplifier is not used as a proof that an expression cannot denest.

The source papers and original AI reports are not redistributed here.
Publication and documentation links are supplied in the report itself.
