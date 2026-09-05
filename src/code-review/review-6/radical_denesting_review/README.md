# Radical denesting after the first repair

Review date: 5 September 2026

## Start here

Open `review.pdf` for the 26-page article. Its editable, self-contained LaTeX source is `review.tex`.
The proposed replacement is `code/StradImproved.wl`. It uses the separate context
`RadicalDenestImproved\`` and does not overwrite the original package.

**Native Wolfram validation is pending.** Neither the replacement nor the supplied
native regression suite was executed in a Wolfram kernel during this review. Two
attempts to reach the available Wolfram service failed with HTTP 404; no local
Wolfram kernel was present. This is proposed source accompanied by tests, not a
claim of a production-certified release.

The executed independent Python/SymPy checks passed: 33 named checks, including
312 rational parameter cases. These establish the tested identities and finite
control-flow models, not Wolfram Language implementation semantics. The separate
lexical check establishes balanced delimiters/comments/strings only.

## Files

- `review.pdf`, `review.tex`: article, proofs, prioritized findings, compatibility notes,
  option reference, validation boundaries, and embedded bibliography.
- `code/StradImproved.wl`: proposed conservative replacement.
- `tests/StradImproved.wlt`: 43 native Wolfram regression tests.
- `tests/run_tests.wls`: native runner, report capture, kernel-version metadata,
  and replacement-source SHA-256 capture.
- `tests/original_regressions.wls`: focused reproductions against a separately
  supplied copy of the reviewed original.
- `verification/verify_mathematics.py`: executed exact mathematics and finite-model checks.
- `verification/verification_results.json`: recorded independent results.
- `verification/check_wl_structure.py`: executed lexical delimiter check.
- `verification/wl_structure_results.json`: its recorded results.
- `verification/native_status.json`: explicitly pending native-validation record.
- `SOURCE_ACCESS.md`: consulted material and retrieval limitations.
- `requirements-verification.txt`: version used for independent mathematical checks.
- `build.sh`: optional article build command.
- `SHA256SUMS`: hashes of all distributed files other than the manifest itself.

No third-party literature PDFs, original-repository snapshot, or font files are included.

## Intended Wolfram usage

From the archive's root directory, in a modern Wolfram kernel:

```wl
Get["code/StradImproved.wl"];
result = RadicalDenestImproved`Strad[
  x + Sqrt[4 + 3 Sqrt[2]],
  "AllLevels" -> True,
  "MaxTrials" -> 20,
  "TimeBudget" -> 10,
  "DetailedResult" -> True
];
result["Expression"]
result["Certificates"]
```

This is an intended usage example, not a recorded native transcript. No tested
Wolfram-version range is asserted.

Run the native tests before depending on the implementation:

```sh
wolframscript -file tests/run_tests.wls
```

This creates `verification/native_test_report.wl` and
`verification/native_run_metadata.json`. Those files are deliberately absent from
this distribution; no successful native output has been fabricated. Retain the
kernel version, source hash, options, and complete failure report when comparing
results. A conservative timeout or an unchanged expression is not a proof of
non-denestability. The forced-multiplier Ramanujan test is intentionally a capability
acceptance test, not merely a check that unchanged input is equal to itself.

Optional original-code reproductions, in a fresh kernel:

```sh
wolframscript -file tests/original_regressions.wls /absolute/path/to/StradFixed.wl
```

## Compatibility and safety boundaries

The replacement is a redesign, not a fully behavior-preserving textual patch.
It preserves familiar entry-point names in a new package context. Every numeric
candidate, including a custom solver result and a polished result, goes through
one exact-equality, admissible-output, and strict-cost acceptance boundary.
Standalone denominator rationalization is the documented exception to the
strict-cost requirement; it still requires an exact equality check.

Pure `Plus`, `Times`, rational `Power`, and `List` hosts are traversed. Arbitrary
held heads and user-defined heads are not traversed; symbolic hosts are not
simplified under ambient assumptions. Ordinary argument evaluation occurs before
entry, and callbacks are trusted executable code, not sandboxed code.

`"MaxTrials"` is shared across the entire request. `"MultiplierCap"` counts all
admitted multipliers per numeric node, including initial and supplied entries.
`"MaxCandidates"` is an orbit-proposal cap per numeric node; cheap methods are
separate. `"MaxRootIndex"` caps the multiplier reduction index, not every root index
in a supplied candidate. `"MaxDegree"` is checked after construction of the minimal
polynomial; time and memory controls surround that construction.

`"AllLevels" -> False` means one bottom-up pass; `True` allows up to
`"MaxPasses"` strictly improving passes. An explicit multiplier list replaces the
automatic initial stream. The bounded prime-power queue does not reproduce all
paths of the original eager subset-product scheduler. Coverage must be benchmarked,
not assumed to be a superset of the original implementation.

Time and memory limits follow the kernel's cooperative semantics and are not
security isolation or a hard external wall-clock/process-memory guarantee. A timed
out pass is discarded; the last fully committed pass is returned. Certificate logs
are recheckable CAS audit records, not independent formal proof objects.

## Reproduce the executed independent checks

The recorded environment was Python 3.13.5 and SymPy 1.14.0.

```sh
python verification/verify_mathematics.py
python verification/check_wl_structure.py
```

These scripts overwrite their respective JSON result files. Timing values can
change, so successful reruns can legitimately invalidate `SHA256SUMS` for those
files. The mathematical checks use exact arithmetic; they do not call Wolfram.

## Rebuild the article

A TeX Live installation with New PX, Inconsolata, listings, and tcolorbox is needed.
The bibliography is embedded, and there are no external figures.

```sh
sh build.sh
```

Equivalently, run `pdflatex -interaction=nonstopmode -halt-on-error review.tex`
three times. Rendering metadata can change on rebuilding, so the new PDF hash can
differ. The distributed PDF was visually inspected across all pages and compiled
without overfull/underfull boxes or LaTeX warnings in its final build.

## Source provenance

The current public code rendering and relevant parts of the current report were
inspected through mutable `main` URLs. The literature-directory and prior-review
READMEs were accessible, but the prior review's body files/detailed logs and the
literature manifest could not be retrieved reliably. Relevant original papers were
consulted through alternative accessible public copies. No original commit ID or
byte-level original-source hash was obtained. `SOURCE_ACCESS.md` distinguishes
these access levels; the article does not treat an older Library copy as the
current repository snapshot.
