# Second audit of StradFixed.wl

Prepared for Vladimir Reshetnikov, 5 September 2026.

## Contents

- `radical_denesting_audit.pdf` and `.tex`: the comprehensive review, proofs,
  proposed architecture, compatibility notes, limitations, and bibliography.
- `StradImproved.wl`: the proposed replacement implementation in the separate
  context `RadicalDenestImproved\``. It does not modify or load the old package.
- `tests/Regression.wlt`: native Wolfram Language MUnit regressions.
- `tests/RunTests.wls`: a fresh-kernel runner and JSON result exporter.
- `tests/BaselineProbes.wls`: diagnostic probes for the pinned original package.
- `verification/verify.py`, `results.json`, `transcript.txt`: independently run
  exact mathematical checks, a finite scheduler model, and limited lexical checks.
- `verification/fetch_baseline.py`: optional, user-run download of the pinned
  baseline; verifies its Git blob SHA-1 before saving. The package and tests
  never download or execute remote code automatically.
- `PROVENANCE.json`: source version, review scope, and execution limitations.

## Validation status

**Native Wolfram Language tests were not executed.** The Wolfram connector
returned an MCP HTTP 404 and there was no local Wolfram kernel. The revised code
is a proposed implementation, not a native-tested production release.

The supplied independent Python checks were executed with Python 3.13.5 and
SymPy 1.14.0. They check the mathematical constructions, branch conditions,
small polynomial GCD examples, the cap counterexamples, a finite queue model,
and balanced Wolfram delimiters/comments/strings. They do not establish Wolfram
pattern matching, evaluation order, option handling, or performance. See
`verification/results.json` for exact counts and hashes.

## Load and use

```wolfram
Get["/full/path/to/StradImproved.wl"];

RadicalDenestImproved`Strad[Sqrt[4 + 3 Sqrt[2]]]
RadicalDenestImproved`Strad[(49 + 20 Sqrt[6])^(1/4), True]
RadicalDenestImproved`DenestReport[
  Sqrt[1 + Sqrt[2]],
  "TimeBudget" -> 10, "MaxTrials" -> 30, "Trace" -> True
]
```

Use fully qualified names when comparing with `RadicalDenest\`Strad`; both
packages intentionally export familiar names. Each new public entry point
honors **its own** `Options` and effective `SetOptions` defaults. Changing one
head's defaults does not implicitly change the others.

Every changed numerical node is checked against that node's immutable target.
A custom `"Solver"` is a candidate generator, not a proof oracle. It replaces
only the general multiplier search; inexpensive built-in/formula proposals
remain enabled. A nonalgebraic, incorrect, or undecided callback result is not
accepted. Ordinary callback `Throw` is caught; callbacks are not sandboxed and
can still perform arbitrary side effects or protect themselves from interrupts.

## Deliberate compatibility differences

The implementation is a conservative redesign, not a drop-in guarantee of the
same search order, output form, coverage, or speed.

- It traverses `Plus`, `Times`, `Power`, and `List`. Unknown/held heads are opaque.
  It does not globally `Simplify` a symbolic host, and ignores ambient assumptions
  while performing numeric work. Normal evaluation of arguments occurs before
  entry, as for ordinary Wolfram functions; the package is not a held AST editor.
- The numerical grammar is rational/Gaussian-rational arithmetic, rational powers,
  and exact `Root`/`AlgebraicNumber` objects. Transcendental-looking exact constants
  are not a way to hide radical complexity. Roots of unity use rational powers
  of `-1`, not unevaluated exponentials. Kernel simplification can of course
  convert an input to a supported form before the package sees it.
- Default `"AllLevels" -> False` processes outermost fractional powers and
  arithmetic components in one pass. `True` also processes inner nodes first
  and repeats successful whole passes up to `"MaxPasses"`. `DenestCore` handles
  one numerical target and does not traverse a symbolic host.
- Lists and repeated passes share the top-level time, memory, and trial budget.
  `"MultiplierCap"` is per numerical search target, across all its seed and
  generated batches. The shared trial budget applies across all such targets.
  The proposal-attempt bound is four times that per-target admission cap.
- `"MaxTrials" -> 0` disables multiplier trials, not formula fast paths.
  `"TimeBudget" -> 0` does no denesting work; cost metadata is `Missing`.
  All numeric limits must be finite. Invalid/unknown options return `Failure`.
- `"Limits"` reports thresholds reached, not a proof that a useful candidate was
  left unexamined. Timeouts of individual operations also appear in statistics.
  `Unchanged`, with or without limits, never means that denesting is impossible.
- The cost is `{opaque algebraic objects, radical depth, radical nodes,
  LeafCount, integer bit size}`. `I` is an exact Gaussian-rational atom in this
  syntactic cost model, not a claim about minimum depth over the field Q.
- `Factorc` is now a certified numeric `Factor` proposal; symbolic inputs are
  unchanged. It no longer reproduces the old custom factorizer's repertoire.
  `RationalizeDenominator` uses a certified local inverse and is not required to
  improve the denesting cost. Standalone predicates/helpers get a 20-second
  budget; inside a denesting session they share the existing session.

Wolfram `TimeConstrained`/`MemoryConstrained` provide cooperative resource
controls, not hard real-time or process-isolation guarantees. Argument creation,
option resolution, and final small report assembly are outside the timed body.
There is no unrestricted completeness, minimum-depth, or speed claim.

## Run the native tests

From the extracted directory, in a fresh kernel:

```text
wolframscript -file tests/RunTests.wls
```

The runner writes `tests/native-results.json` and exits nonzero for test failures.
To investigate the baseline separately:

```text
python verification/fetch_baseline.py
wolframscript -file tests/BaselineProbes.wls verification/StradFixed.baseline.wl
```

The second command prints diagnostic observations, not a pass/fail certification.
Keep the baseline and improved package tests in separate fresh kernels.

## Re-run the independent checks

Python 3.9 or later and SymPy are required:

```text
python -m pip install sympy
python verification/verify.py
```

No floating-point identity test is used by this script. Some identities are
checked coefficientwise in a quotient ring; branch conclusions use explicit
sign conditions. The finite scheduler model is not a translation of every
Wolfram evaluation detail.

## Rebuild the PDF

A TeX Live/MiKTeX installation with Libertinus, AMS packages, geometry, microtype,
listings, booktabs, longtable, ragged2e, xurl, hyperref, and fancyhdr is sufficient:

```text
pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_audit.tex
pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_audit.tex
pdflatex -interaction=nonstopmode -halt-on-error radical_denesting_audit.tex
```

The article is self-contained: its bibliography and displayed code excerpts are
embedded in the `.tex` file. No external images or font files are distributed.
