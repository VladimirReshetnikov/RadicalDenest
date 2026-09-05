RADICAL DENESTING: A UNIFIED RESEARCH GUIDE
Research cutoff: September 5, 2026

CONTENTS

radical_denesting_unified.pdf
    The unified report: 45 pages and 86 annotated bibliography entries.

radical_denesting_unified.tex
    Complete, self-contained LaTeX source. Bibliographic entries are embedded
    in the source; no external .bib file, images, or source-report files are
    needed to compile it.

verify.py
    Reproducible exact mathematical checks and selected observed SymPy
    sqrtdenest outputs. Includes a restricted cubic-in-quadratic denesting
    procedure. This is not a general denesting implementation.

verification_results.txt
    Execution transcript: 26 exact checks passed under Python 3.13.5 and
    SymPy 1.14.0. No other CAS was executed for this report.

source_inventory.tsv
    Names, byte lengths, SHA-256 hashes, and roles of all 10 non-directory
    members of the supplied reports.zip archive. They comprise four reports
    plus alternate renderings and illustrations, not ten independent reports.

source_links.tsv
    A deduplicated provenance register of literal HTTP(S) links found in the
    four supplied Markdown reports. Formatting escapes are normalized in the
    URL column; the literal_variants column preserves the original spellings.
    Bibliographic records expressed only through the original assistants'
    opaque citation markers are not recoverable as URLs by this extraction.
    Inclusion here is NOT independent endorsement or a successful-link test.
    The report's annotated bibliography is the curated source guide, and
    contains additional sources not present in this input-link register.

quality_checks.txt
    Build, citation, PDF, and computation checks performed for the release.

SHA256SUMS.txt
    SHA-256 hashes of the release files other than this checksum file.

BUILDING THE PDF

Use a recent TeX Live installation (or an equivalent LaTeX distribution).
From the directory containing the .tex file, run:

    pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_unified.tex
    pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_unified.tex
    pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_unified.tex

Three runs settle the table of contents, citations, and cross-references.
Alternatively:

    latexmk -pdf radical_denesting_unified.tex

The source uses the standard article class and packages including newpxtext,
newpxmath, amsmath, amsthm, mathtools, geometry, microtype, booktabs, longtable,
enumitem, xcolor, fancyhdr, titlesec, listings, xurl, hyperref, bookmark, and
etoolbox. No shell escape or network access is required. Fonts are supplied
by the TeX distribution, not included in this archive.

RUNNING THE EXACT CHECKS

Python 3.10 or later is required. For the tested SymPy version:

    python -m pip install sympy==1.14.0
    python verify.py

Polynomial reduction proves the selected algebraic identities; separate
rational inequalities select the even-root branches. The non-denesting
interpretation of some cases relies on the cited structural theorems, not
on a claim that the script implements those theorems.

EDITORIAL AND EVIDENCE NOTES

The four AI-generated reports were treated as discovery leads. Overlapping
exposition and publication versions were consolidated. Mathematical mistakes,
misdated bibliography entries, and overbroad complexity or software claims
were corrected or qualified. The report distinguishes finite denesting from
infinite-radical convergence, equality from comparison, field normalization
from minimum-depth optimization, and real from complex branch conventions.

Access labels in the bibliography distinguish inspected relevant full text,
authoritative metadata or abstracts, documentation or author source, and
retained background or unresolved leads. Full-text inspection does not mean
that every theorem in a source was independently verified. The report is
not claimed to be an exhaustive bibliography. Sources behind access barriers
are not described as having been fully read. Proprietary or unavailable CAS
examples are explicitly labeled unexecuted.

No copies of third-party papers, input reports, or font files are distributed
in this release. Consult the bibliography for their source locations.

INPUT ARCHIVE

Filename: reports.zip
SHA-256: 807612a46993418ac6340c18f751b318a63dd1b5f4eee68e99de003af355fe97
