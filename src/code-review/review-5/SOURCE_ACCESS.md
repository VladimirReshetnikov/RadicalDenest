# Source and execution access ledger

Date of attempted access: 2026-09-05. No commit hash for the inspected branch was
successfully retrieved; branch URLs are mutable. A complete original source file
was not obtained and is NOT included or silently reconstructed.

## Current repository material

1. https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/docs/report
   Directory and README inspected. Individual current report text was not obtained.
   A prior Library report with the same subject/title was read as background only;
   it is not treated as identical to the current repository version.

2. https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/docs/literature
   Directory and README inspected, not all paper files or manifests. Relevant
   primary literature was obtained from author/institutional copies listed below.
   This is NOT a claim to have read all 46 PDFs described by that directory README.

3. https://github.com/VladimirReshetnikov/RadicalDenest/blob/main/src/corrected/StradFixed.wl
   GitHub metadata reported 504 physical lines (456 lines of code), 28.5 KB.
   The initial raw-text response exposed the package header, options, predicates,
   cost functions, RationalizeDenominator, Factorc/fullfactor/combine,
   DenestRadicals/Strad wrapper, recursiveCore, normalizeRadicand, and the first
   rationalQ definition introducing the following quadratic section.
   The browser's raw-text parser showed a total of 473 lines, but only its first
   260 lines were readable. Those parser line numbers are NOT GitHub physical
   source-line numbers. Hence findings cite FUNCTION NAMES, not guessed line ranges.
   The remaining quadratic helpers, DenestCore body, and multiplier backend were
   NOT inspected. Subsequent raw/blob/continuation and clone/download attempts
   failed. No claim about a particular defect in that unseen body is made.

4. https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/src/code-review/unified
   Directory and README inspected. The modular report bodies and full test logs
   could not be retrieved. The README reports an earlier native Wolfram 15.0.1
   Windows execution and a corrected implementation. That is repository-reported
   evidence, not a run performed for this delivery. The prior Library review of
   the ORIGINAL implementation was used only as historical/mathematical context.

## Primary material inspected selectively

- Borodin, Fagin, Hopcroft, Tompa (1985), Decreasing the Nesting Depth of Expressions
  Involving Square Roots. Relevant theory and global-cancellation discussion.
  https://www.cs.toronto.edu/~bor/Papers/decreasing-nesting-depth-for-expressions.pdf
- Gkioulekas (2017; author manuscript dated 2016), On the denesting of nested square
  roots. Direct and indirect norm formulas.
  https://faculty.utrgv.edu/eleftherios.gkioulekas/papers/submitted/denesting-square-roots.pdf
- Jeffrey and Rich (1999), Simplifying Square Roots of Square Roots by Denesting.
  Branches, traversal, recursive complexity measure and termination.
  https://cybertester.com/data/denest.pdf
- Honsbeek (2005), Radical Extensions and Galois Groups. Introduction and selected
  chapter-3 material, especially Theorem 104 and formula (3.5), printed pp. 62-63.
  https://www.math.ru.nl/~bosma/students/honsbeek/M_Honsbeek_thesis.pdf
- Landau, How to Tangle with a Nested Radical, 1991 technical-report copy.
  Selected introductory discussion; historical claims not substituted for later work.
  https://web.cs.umass.edu/publication/docs/1991/UM-CS-1991-076.pdf

Relevant PDF pages were viewed as images as well as text where available.
Official Wolfram docs were consulted for Power, RootReduce, PossibleZeroQ,
Simplify, TimeConstrained, MemoryConstrained, Options, PolynomialGCD,
$MaxExtraPrecision, and related resource semantics. Full URLs are in review.tex.

## Execution

- Connected WolframContext and WolframLanguageEvaluator calls both failed before
  executing code: HTTP 404 at the Wolfram MCP SSE endpoint.
- No local Wolfram kernel/wolframscript was available.
- Attempted installation of an alternative evaluator failed due to network/DNS.
  No Mathics or other emulation was run or presented as Wolfram verification.
- Container outbound repository requests failed; browser access to other primary
  literature/documentation remained available.
- Python/SymPy exact checks and local lexical/static checks DID execute; their
  full results are in evidence/verification.json and evidence/verification.txt.
- The LaTeX article was compiled and its rendered PDF pages inspected locally.

## What the code deliverable means

StradImproved.wl is an independently written reference implementation inspired by
and mathematically compatible with the visible multiplier/GCD/phase-orbit design.
It is NOT a diff, a provenance-preserving modification of all original code,
a reproduction of unseen logic, or a claim of native-Wolfram-tested compatibility.
