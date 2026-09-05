# Unified analysis of `Strad.wl`

Main deliverables:

- `unified_analysis.pdf` — the report (compare the three reviews, reconstruct the
  algorithm, prove the supporting mathematics, execute the program and the
  reviews' test suites in Wolfram 15.0.1, catalogue 27 defects, present and
  evaluate the corrected implementation, list future improvements).
- `unified_analysis.tex` plus `sec_*.tex`, `app_listings.tex` — LaTeX source.
  Build with `pdflatex` (three passes) from this directory; the listings
  appendix reads `../../original/Strad.wl` and
  `../../corrected/StradFixed.wl`.
- `tables/*.tex` — result tables generated mechanically by
  `harness/export_tables.wl` from the recorded runs.
- `harness/` — all Wolfram scripts used for the experiments, including the
  four probing scripts `probe_gaps_*.wl` that search for denestable inputs
  the corrected version misses (findings in `src/corrected/KNOWN_GAPS.md`).
- `logs/` — the raw outputs of every run reported in the document.

The corrected implementation itself is `src/corrected/StradFixed.wl`. The
three independent reviews that this document compares are the sibling
directories `../review-1`, `../review-2` and `../review-3`.

Kernel used for every execution: 15.0.1 for Microsoft Windows (64-bit)
(July 2, 2026). The scripts contain absolute paths at their top; adjust them
before re-running.
