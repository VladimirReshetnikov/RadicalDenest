(* A conservative, single-multiplier reference component for the article.
   This is NOT a complete replacement denester, and was not executed in a
   Wolfram kernel during this review. The original target is never discarded.
   Load this file separately; it does not load or modify the supplied code. *)
BeginPackage["RadicalAudit`"];
VerifiedMultiplierTrial::usage =
  "VerifiedMultiplierTrial[beta, r, m] tries one nonzero exact algebraic multiplier, preserving the original branch. A verified candidate is not a certificate of radical-depth reduction.";
Begin["`Private`"];

ClearAll[exactAlgebraicValueQ, exactEqualQ];
exactAlgebraicValueQ[z_] :=
  TrueQ[NumericQ[z] && Precision[z] === Infinity &&
    Element[z, Algebraics]];
exactEqualQ[a_, b_] :=
  TrueQ[Quiet[Check[RootReduce[a - b] === 0, False]]];

Options[VerifiedMultiplierTrial] = {TimeConstraint -> 30};
VerifiedMultiplierTrial[beta_, r_, m_, OptionsPattern[]] :=
 Module[{limit = OptionValue[TimeConstraint]},
  If[!(limit === Infinity ||
      TrueQ[NumericQ[limit] && Im[limit] == 0 && limit > 0]),
   Return[Failure["InvalidTimeConstraint", <||>]]];
  TimeConstrained[
   Quiet[Check[
     Module[{x, radicand, scaled, minpoly, g, d, rules,
       roots, phases, candidates, valid, best},
      If[!TrueQ[IntegerQ[r] && r >= 2],
       Return[Failure["InvalidRootDegree", <|"Degree" -> r|>]]];
      If[!exactAlgebraicValueQ[beta] || !exactAlgebraicValueQ[m],
       Return[Failure["ExactAlgebraicInputsRequired", <||>]]];
      If[exactEqualQ[m, 0],
       Return[Failure["ZeroMultiplier", <||>]]];
      If[exactEqualQ[beta, 0],
       Return[<|"Status" -> "Unchanged", "Value" -> 0,
         "Verified" -> True|>]];
      radicand = beta^r;
      scaled = m radicand;
      minpoly = MinimalPolynomial[scaled^(1/r), x];
      If[!PolynomialQ[minpoly, x],
       Return[Failure["MinimalPolynomialFailed", <||>]]];
      g = PolynomialGCD[minpoly, x^r - scaled,
        Extension -> Automatic];
      d = Exponent[g, x];
      If[!PolynomialQ[g, x] || !IntegerQ[d],
       Return[Failure["PolynomialGCDFailed", <||>]]];
      If[!(1 <= d < r),
       Return[<|"Status" -> "NoProperGCD", "Value" -> beta,
         "GCDDegree" -> d|>]];
      rules = Solve[g == 0, x];
      If[!ListQ[rules] || rules === {} ||
        !TrueQ[And @@ (MatchQ[#, {_Rule}] & /@ rules)],
       Return[Failure["UnexpectedSolveResult", <||>]]];
      roots = x /. rules;
      phases = Table[Exp[2 Pi I k/r], {k, 0, r - 1}];
      candidates = Flatten[
        Outer[Times, roots/m^(1/r), phases], 1];
      valid = Select[candidates,
        exactAlgebraicValueQ[#] && exactEqualQ[#, beta] &];
      valid = SortBy[valid, LeafCount];
      valid = DeleteDuplicates[valid, exactEqualQ];
      If[valid === {},
       Return[Failure["NoCertifiedCandidate", <||>]]];
      best = First[valid];
      <|"Status" -> "VerifiedCandidate", "Original" -> beta,
        "Value" -> best, "Verified" -> True,
        "Multiplier" -> m, "GCDDegree" -> d,
        "ContainsRootObjects" ->
          !FreeQ[best, _Root | _AlgebraicNumber]|>
      ],
     Failure["EvaluationFailed", <||>]]],
   limit, Failure["TimeLimit", <||>]]
  ];
End[];
EndPackage[];
