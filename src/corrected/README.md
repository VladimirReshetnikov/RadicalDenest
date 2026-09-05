# StradFixed.wl

A corrected and hardened version of `src/original/Strad.wl`, keeping its
architecture (wrapper, radical markers, multiplier search with minimal
polynomials and polynomial GCDs over algebraic extensions, roots-of-unity
orbit) but making correctness independent of the heuristics.

```wl
Get["src/corrected/StradFixed.wl"];
Strad[Sqrt[5 + 2 Sqrt[6]]]                       (* Sqrt[2] + Sqrt[3] *)
Strad[(-1 + 2 I Sqrt[2])^(3/2)]                  (* -5 + I Sqrt[2]; the original returns 5 - I Sqrt[2] *)
Strad[Sqrt[16 - 2 Sqrt[29] + 2 Sqrt[55 - 10 Sqrt[29]]], True]   (* Sqrt[5] + Sqrt[11 - 2 Sqrt[29]] *)
Strad[expr, "Verbose" -> True, "MaxTrials" -> 100, "TimeBudget" -> 30]
DenestCore[Sqrt[5 + 2 Sqrt[6]], "Multipliers" -> {2}]
```

Guarantees for exact algebraic input: the result is certified equal to the
input by exact algebra (`RootReduce` / `PossibleZeroQ` with
`Method -> "ExactAlgebraics"`), it is strictly simpler under an explicit
radical-complexity cost or it is the input itself, no kernel message is
produced on the normal path, and the search stops within `"MaxTrials"` trials
or `"TimeBudget"` seconds. Symbolic hosts are left untouched; only exact
numeric algebraic subexpressions are factored, marked and denested.

Public symbols (context ``RadicalDenest` ``): `Strad`, `DenestRadicals`,
`DenestCore`, `RationalizeDenominator`, `Factorc`, `RadicalDepth`,
`RadicalCost`, `ExactAlgebraicQ`, `CertifiedEqualQ`.

See `src/code-review/unified/unified_analysis.pdf`, Section 7, for the change list,
and Section 5 for the test results on the same battery as the original.
