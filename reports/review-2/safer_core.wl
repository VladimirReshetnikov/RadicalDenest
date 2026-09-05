(* A guarded one-multiplier algebraic step, not a replacement denester.
   This file was reviewed statically, but NOT executed in a Wolfram kernel.
   It retains the original target and certifies equality with RootReduce.
   It does not promise a reduction in radical nesting or a radical-only result.
*)
BeginPackage["RadicalAudit`"];
CertifiedMultiplierStep::usage =
  "CertifiedMultiplierStep[target,k,m] searches one multiplier and returns an Association or Failure.";
ExactAlgebraicEqualQ::usage =
  "ExactAlgebraicEqualQ[a,b] accepts only an exact RootReduce[a-b] result of zero.";
Begin["`Private`"];

exactAlgebraicQ[z_] := TrueQ[NumericQ[z]] &&
  SameQ[Precision[z], Infinity] && TrueQ[Element[z, Algebraics]];

ExactAlgebraicEqualQ[a_, b_] :=
  TrueQ[Quiet[Check[RootReduce[a - b] === 0, False]]];

Options[CertifiedMultiplierStep] = {TimeConstraint -> 20};
CertifiedMultiplierStep[target_, k_, multiplier_, OptionsPattern[]] :=
 Module[{budget = OptionValue[TimeConstraint]},
  If[! (budget === Infinity ||
      (TrueQ[NumericQ[budget]] && TrueQ[budget > 0])),
   Return[Failure["InvalidTimeConstraint", <|"Value" -> budget|>]]];
  TimeConstrained[
   Quiet[Check[
     certifiedStep[target, k, multiplier],
     Failure["AlgebraicOperationFailed", <||>]
   ]],
   budget,
   Failure["TimeLimit", <|"Seconds" -> budget|>]
  ]
 ];

certifiedStep[target_, k_, multiplier_] :=
 Module[{t, a, p, g, dg, rules, roots, candidates, accepted},
  If[! (IntegerQ[k] && k >= 2),
   Return[Failure["InvalidRootOrder", <|"Order" -> k|>]]];
  If[! exactAlgebraicQ[target],
   Return[Failure["InvalidTarget", <|"Target" -> target|>]]];
  If[ExactAlgebraicEqualQ[target, 0],
   Return[<|"Status" -> "Trivial", "Candidates" -> {0}|>]];
  If[! exactAlgebraicQ[multiplier] ||
      ExactAlgebraicEqualQ[multiplier, 0],
   Return[Failure["InvalidMultiplier", <|"Multiplier" -> multiplier|>]]];

  (* Preserve the available radical expression for the coefficient field.
     Do not replace the equality target by the principal root of a. *)
  a = target^k;
  p = MinimalPolynomial[(multiplier a)^(1/k), t];
  g = PolynomialGCD[p, t^k - multiplier a,
      Extension -> Automatic];
  If[! PolynomialQ[g, t],
   Return[Failure["InvalidGCD", <|"GCD" -> g|>]]];
  dg = Exponent[g, t];
  If[! (IntegerQ[dg] && 1 <= dg <= k),
   Return[Failure["InconsistentGCD", <|"GCD" -> g|>]]];
  If[dg == k,
   Return[<|"Status" -> "NoLowerDegreeGCD",
     "AbsoluteDegree" -> Exponent[p, t], "GCDDegree" -> dg,
     "Candidates" -> {}|>]];

  rules = Solve[g == 0, t];
  If[! ListQ[rules] || ! AllTrue[rules, ListQ],
   Return[Failure["UnresolvedSolve", <|"SolveResult" -> rules|>]]];
  roots = t /. rules;
  candidates = Flatten[Outer[Times,
      roots/multiplier^(1/k), Exp[2 Pi I Range[0, k - 1]/k]]];
  accepted = Select[candidates,
    exactAlgebraicQ[#] && ExactAlgebraicEqualQ[#, target] &];
  If[accepted === {},
   Return[Failure["NoCertifiedCandidate", <|
     "Multiplier" -> multiplier, "GCDDegree" -> dg|>]]];
  <|"Status" -> "CertifiedCandidates",
    "AbsoluteDegree" -> Exponent[p, t], "GCDDegree" -> dg,
    "Candidates" -> SortBy[DeleteDuplicates[accepted], LeafCount]|>
 ];
End[];
EndPackage[];
