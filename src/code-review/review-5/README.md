# Radical denesting: review and proposed hardened implementation

Date: 2026-09-05

## Start here

- `review.pdf`: article, with mathematical proofs, prioritized findings, API and
  implementation notes, evidence limitations, and the complete proposed code.
- `review.tex`: LaTeX source. Compile from this directory with
  `pdflatex review.tex` twice. It includes `code/StradImproved.wl` as an appendix.
- `code/StradImproved.wl`: standalone, independently written Wolfram Language
  reference implementation, in the **RadicalDenestImproved`** context.
- `tests/regression.wlt`: 31 native Wolfram regression tests; **NOT RUN HERE**.
- `tests/run_tests.wls`: portable runner for that suite.
- `tests/original_reproducers.wl`: source-level probes for the original package;
  **NOT RUN HERE**. Load the original `StradFixed.wl` first.
- `tests/verify_math.py`: independent exact mathematical and lexical checks.
- `evidence/verification.json` and `.txt`: executed results, 165/165 passed.
- `SOURCE_ACCESS.md`: exactly what was and was not retrieved or executed.

**Read the source-access limitations before interpreting this as an audit.**
The complete current backend and current report bodies could not be retrieved.
This is a review of the available safety/wrapper code with a replacement design,
not a certified, source-complete patch or a native-Wolfram-tested release.

## Wolfram usage

```wl
Get["/absolute/path/to/code/StradImproved.wl"];
RadicalDenestImproved`Strad[Sqrt[5 + 2 Sqrt[6]]]
RadicalDenestImproved`Strad[Sqrt[4 + 3 Sqrt[2]]]
RadicalDenestImproved`DenestReport[
  x + Sqrt[5 + 2 Sqrt[6]],
  "Solver" -> Function[z, 0], (* deliberately invalid PROPOSAL *)
  "AllLevels" -> True, "TimeBudget" -> 20
]
```

Expected mathematical results for the first two examples are Sqrt[2]+Sqrt[3]
and 2^(1/4)(1+Sqrt[2]), respectively. These are not claimed runtime transcripts.
Use fully qualified symbols when comparing with the original `RadicalDenest``
package. Do not blindly replace the original file: interfaces deliberately differ.

Run the supplied native suite on a real Wolfram kernel:

```text
wolframscript -file tests/run_tests.wls
```

The runner uses its own file location, not the shell's current directory.
Run the independent checks with Python and SymPy installed:

```text
python tests/verify_math.py
```

## Contract and deliberate differences

The supported input model is pure exact scalar arithmetic with principal complex
Power. Algebraic constants must be explicit integers, rationals, Gaussian rational
complex constants, arithmetic and rational powers, or recognized algebraic Root /
AlgebraicNumber objects. The algebraicity predicate is conservative, not universal.

The walker descends only through List, Plus, Times, and rational/integer Power.
It does not transform arbitrary functions, held programs, rules, or associations.
Do not use it as a transformer of programs with side effects or custom UpValues.
An expression tree containing inexact reals/complex numbers is left unchanged;
this avoids promising preservation of floating-point evaluation order.

Every accepted numerical-island change must satisfy an exact RootReduce difference
check and strict decrease in the declared integer cost tuple. Symbolic-host
correctness follows from substitution of equal constants, not from an unchecked
whole-expression Simplify. Ambient $Assumptions is reset internally.

Custom solvers are untrusted for mathematical answers, but must still be ordinary
trusted Wolfram programs. TimeConstrained is not a sandbox. Malicious code,
AbortProtect, external processes, redefinitions of package internals, and effects
before argument evaluation cannot be contained by this package.

Each ENTRY POINT reads its own current Options, so SetOptions[Strad,...] is honored.
"AllLevels" enables bounded bottom-up passes, NOT unbounded fixed-point iteration.
"MaxTrials" is shared across a list and all passes; zero disables multiplier search
but not the elementary fast paths. "TimeBudget" -> 0 disables all transformation.
"MultiplierCap" bounds the automatic positive-integer seed range, not all user
multipliers; 1 and visible complementary-power seeds are also considered.

The engine has an outer kernel time constraint, a shared wall-clock deadline checked
at stage boundaries, and a kernel memory constraint. These are best-effort Wolfram
resource controls, not hard OS wall-time/RSS limits. Input evaluation, option
resolution, and lightweight final report/Print bookkeeping are outside the search
budget. Standalone Factorc/RationalizeDenominator helpers have separate generation
and certification allowances and are not end-to-end TimeBudget entry points.

"MaxDegree" is a POST-computation admission check for a minimal polynomial. It does
not prevent that polynomial's computation from initially using a larger extension.
There is no claimed global minimum-depth or non-denestability guarantee. The default
GCD solver handles degree 1 or 2; setting MaxSolveDegree to 3 or 4 permits Solve.

DenestReport returns Improved / Unchanged / Timeout / MemoryLimit / Disabled /
InvalidOptions. Unchanged includes unsupported or size-limited inputs: consult
counters, and never interpret it as a proof that denesting is impossible.
On a whole-call timeout or memory abort, the original expression is returned,
not a partly rebuilt host. LocalRecords may describe discarded intermediate steps
and are bounded by MaxRecords; they are kernel-checked equality records, not
standalone portable proof objects.

## Validation status

Executed under Python 3.13.5 and SymPy 1.14.0:
156 exact mathematical checks plus 4 lexical-balance checks and 5 static structural
checks. These establish neither that every Wolfram test passes nor that the Wolfram
implementation is bug-free. Native regression, performance, and version-compatibility
testing are prerequisites to production use.

No changes were made to the GitHub repository. No source-complete original snapshot
or commit hash was obtainable. The archive hashes identify the files in THIS delivery.
