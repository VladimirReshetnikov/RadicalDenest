RADICAL DENESTING: A UNIFIED LITERATURE AND IMPLEMENTATION REPORT
Prepared for Vladimir Reshetnikov
Sources checked: 5 September 2026

CONTENTS
  radical_denesting_unified.pdf   Compiled 29-page report
  radical_denesting_unified.tex   Self-contained LaTeX source
  verify_examples.py             Exact algebraic verification suite
  verification_results.txt       Output of the supplied suite (SymPy 1.14.0)
  README.txt                     This file

The report consolidates four supplied reports into a single thematic account,
with 93 annotated bibliography entries, source-access labels, corrected
mathematical and bibliographic claims, and reproducible exact examples.
Related conference/journal versions and access mirrors are grouped.

BUILD THE PDF
Use a reasonably current TeX Live or MiKTeX installation with the standard
packages named in the preamble (including newtx, mathtools, microtype, needspace,
listings, fancyhdr, and hyperref). No fonts are bundled.

  latexmk -pdf radical_denesting_unified.tex

Alternatively, run the following command twice (or until references settle):

  pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_unified.tex

The bibliography is embedded in the .tex file; there are no external .bib or
image dependencies and no network access is needed for compilation.

RUN THE EXACT CHECKS
Python 3.10+ and SymPy are required. The recorded run used SymPy 1.14.0.

  python verify_examples.py

The suite checks square-root denesting, real cube and fifth roots, polynomial
identity certificates, a minimal polynomial, and 210 constructed cases of the
quadratic-field cubic criterion. It is not a general denester or a cross-CAS
performance benchmark. A None result from quadratic_cuberoot means that the
specified quadratic-field representation fails, not that every possible
unnested radical representation is impossible.

SOURCE EVIDENCE
T: relevant source text consulted; A: publisher/institutional metadata or
abstract checked; D: documentation/source inspected; B: retained background or
bibliographic lead not audited at theorem level. The bibliography and audit
appendix make limitations explicit. The linked papers and software are not
redistributed in this archive.
