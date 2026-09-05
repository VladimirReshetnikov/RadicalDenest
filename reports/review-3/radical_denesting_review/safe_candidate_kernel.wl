(* Proposed, conservative replacement for ONE multiplier trial.
   This file has not been executed in a Wolfram kernel in this review.
   It is not a complete denester or a completeness claim. *)

BeginPackage["RadicalDenestingAudit`"];
ExactAlgebraicNumberQ::usage =
  "Test for an explicitly known, exact numeric algebraic value.";
ExactAlgebraicEqualQ::usage =
  "Conservatively certify equality of exact algebraic values.";
TryDenestCandidate::usage =
  "TryDenestCandidate[original,q,m] returns verified candidates.";
RadicalDepth::usage =
  "Count the maximum number of rational-power nodes on a path.";
CandidateCost::usage =
  "Return an explicit representation cost, penalizing Root objects.";
BestImprovement::usage =
  "Retain the original unless a certified candidate improves cost.";
Options[TryDenestCandidate] = {"TimeBudget" -> 30};

Begin["`Private`"];

ExactAlgebraicNumberQ[e_] := TrueQ[
  NumericQ[e] && Precision[e] === Infinity &&
  Quiet[Check[Element[e, Algebraics], False]]
];

ExactAlgebraicEqualQ[a_, b_] :=
  If[ExactAlgebraicNumberQ[a] && ExactAlgebraicNumberQ[b],
    Quiet[Check[RootReduce[a - b] === 0, False]],
    False
  ];

TryDenestCandidate[original_, q_, multiplier_,
    OptionsPattern[]] := Module[{budget = OptionValue["TimeBudget"]},
  If[!(NumericQ[budget] && TrueQ[0 < budget < Infinity]),
    Return[Failure["InvalidBudget", <|"Budget" -> budget|>]]];
  TimeConstrained[
    trialBody[original, q, multiplier], budget,
    Failure["BudgetExceeded", <|"Multiplier" -> multiplier|>]
  ]
];

trialBody[original_, q_, multiplier_] := Module[
  {x, rho, beta, p, g, d, e, rules, roots, candidates, verified,
   metadata},
  If[!IntegerQ[q] || q < 2,
    Return[Failure["InvalidRootOrder", <|"Order" -> q|>]]];
  If[!ExactAlgebraicNumberQ[original] ||
     !ExactAlgebraicNumberQ[multiplier],
    Return[Failure["InvalidInput", <||>]]];
  If[ExactAlgebraicEqualQ[multiplier, 0],
    Return[Failure["ZeroMultiplier", <||>]]];

  rho = original^q;
  beta = (multiplier rho)^(1/q);
  p = Quiet[Check[MinimalPolynomial[beta, x], $Failed]];
  If[p === $Failed || !PolynomialQ[p, x],
    Return[Failure["MinimalPolynomialFailed", <||>]]];
  d = Exponent[p, x];
  If[!IntegerQ[d] || d < 1,
    Return[Failure["InvalidMinimalPolynomialDegree", <||>]]];

  g = Quiet[Check[
    PolynomialGCD[p, x^q - multiplier rho,
                  Extension -> Automatic], $Failed]];
  If[g === $Failed || !PolynomialQ[g, x],
    Return[Failure["PolynomialGCDFailed", <||>]]];
  e = Exponent[g, x];
  If[!IntegerQ[e] || e < 1 || e > q,
    Return[Failure["InconsistentGCDDegree", <|"Degree" -> e|>]]];

  metadata = <|"Original" -> original,
    "Multiplier" -> multiplier, "RootOrder" -> q,
    "MinimalPolynomial" -> Function[Evaluate[p /. x -> Slot[1]]],
    "RationalDegree" -> d, "RelativeGCDDegree" -> e|>;
  If[e == q,
    Return[Join[metadata, <|"Status" -> "NoDegreeReduction",
                           "Candidates" -> {}|>]]];

  rules = Quiet[Check[Solve[g == 0, x], $Failed]];
  If[rules === $Failed || !ListQ[rules],
    Return[Failure["SolveFailed", metadata]]];
  roots = Quiet[Check[x /. rules, $Failed]];
  If[!ListQ[roots] || !FreeQ[roots, x] ||
     !AllTrue[roots, ExactAlgebraicNumberQ],
    Return[Failure["UnresolvedRoots", metadata]]];

  candidates = Quiet[Check[
    Flatten[Outer[Times, roots/multiplier^(1/q),
      Exp[2 Pi I Range[0, q - 1]/q]]], $Failed]];
  If[!ListQ[candidates],
    Return[Failure["CandidateConstructionFailed", metadata]]];
  verified = DeleteDuplicates[
    Select[candidates, ExactAlgebraicEqualQ[#, original] &],
    ExactAlgebraicEqualQ];
  Join[metadata, <|"Status" ->
    If[verified === {}, "NoCandidate", "Candidate"],
    "Candidates" -> verified|>]
];

RadicalDepth[e_] := If[AtomQ[e], 0,
  If[MatchQ[e, Power[_, _Rational]],
    1 + RadicalDepth[e[[1]]],
    Max[Prepend[RadicalDepth /@ (List @@ e), 0]]
  ]
];

CandidateCost[e_] := {
  Count[e, _Root | _AlgebraicNumber, {0, Infinity}],
  RadicalDepth[e],
  Count[e, Power[_, _Rational], {0, Infinity}],
  LeafCount[e]
};

BestImprovement[original_, candidates_List] := Module[
  {valid, best, oldCost, newCost},
  If[!ExactAlgebraicNumberQ[original],
    Return[Failure["InvalidInput", <||>]]];
  valid = Select[candidates, ExactAlgebraicEqualQ[#, original] &];
  best = First[SortBy[Prepend[valid, original], CandidateCost]];
  oldCost = CandidateCost[original];
  newCost = CandidateCost[best];
  If[newCost =!= oldCost && OrderedQ[{newCost, oldCost}],
    best, original]
];

End[];
EndPackage[];
