(* Native MUnit tests. These were supplied, not executed during this review.
   Load StradImproved.wl first; all public names are fully qualified. *)

VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[5 + 2 Sqrt[6]], Sqrt[2] + Sqrt[3]],
  True, TestID -> "exact-equality-positive"]
VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[3 - 2 Sqrt[2]], 1 - Sqrt[2]],
  False, TestID -> "reject-wrong-square-root-branch"]
VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[2], Sqrt[2] + 10^-100],
  False, TestID -> "no-numerical-tolerance-acceptance"]
VerificationTest[
  Module[{x}, RadicalDenestImproved`CertifiedEqualQ[x, x]],
  False, TestID -> "symbolic-equality-is-not-algebraic-certificate"]
VerificationTest[
  {RadicalDenestImproved`ExactAlgebraicQ[Pi],
   RadicalDenestImproved`ExactAlgebraicQ[N[Sqrt[2]]],
   RadicalDenestImproved`ExactAlgebraicQ[(1 + I)/2]},
  {False, False, True}, TestID -> "supported-exact-domain"]

VerificationTest[
  Module[{x}, RadicalDenestImproved`Private`validPolynomialQ[$Failed, x]],
  False, TestID -> "failed-is-not-an-accepted-polynomial"]
VerificationTest[
  Module[{x}, RadicalDenestImproved`Private`validPolynomialQ[7, x]],
  False, TestID -> "constant-is-not-a-minimal-polynomial"]
VerificationTest[
  RadicalDenestImproved`RadicalDepth[Root[#^5 - # - 1 &, 1]],
  0, TestID -> "root-payload-is-opaque"]
VerificationTest[
  First[RadicalDenestImproved`RadicalCost[Root[#^5 - # - 1 &, 1]]],
  1, TestID -> "root-representation-is-not-free"]
VerificationTest[
  RadicalDenestImproved`RadicalCost[{}],
  {0, 0, 0, LeafCount[{}], 0}, TestID -> "empty-list-metrics"]

VerificationTest[
  Module[{e = Sqrt[5 + 2 Sqrt[6]], r},
    r = RadicalDenestImproved`Strad[e];
    TrueQ[RootReduce[r - e] === 0] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "direct-quadratic-denesting"]
VerificationTest[
  Module[{e = Sqrt[3 - 2 Sqrt[2]], r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, Sqrt[2] - 1] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "negative-coefficient-positive-root"]
VerificationTest[
  Module[{e = Sqrt[4 + 3 Sqrt[2]], r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, 2^(1/4) (1 + Sqrt[2])] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "indirect-fourth-root-minus-sign"]
VerificationTest[
  Module[{e = Sqrt[-4 + 3 Sqrt[2]], r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, 2^(1/4) (Sqrt[2] - 1)] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "indirect-negative-rational-part"]
VerificationTest[
  Module[{e = Sqrt[-3 - 2 Sqrt[2]], r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, I (1 + Sqrt[2])]],
  True, TestID -> "negative-radicand-principal-square-root"]
VerificationTest[
  Module[{e = (49 + 20 Sqrt[6])^(1/4), r},
    r = RadicalDenestImproved`Strad[e, True];
    RadicalDenestImproved`CertifiedEqualQ[r, Sqrt[2] + Sqrt[3]] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "composite-index-without-cost-neutral-stall"]
VerificationTest[
  Module[{e = (3 + 2 Sqrt[2])^(-1/2), r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, Sqrt[2] - 1]],
  True, TestID -> "negative-rational-exponent"]
VerificationTest[
  Module[{e = (7 + 5 Sqrt[2])^(1/3), r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r, 1 + Sqrt[2]] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "cubic-trace-norm"]
VerificationTest[
  Module[{e = (7 - 5 Sqrt[2])^(1/3), r},
    r = RadicalDenestImproved`Strad[e];
    TrueQ[RootReduce[r - e] === 0] &&
      ! RadicalDenestImproved`CertifiedEqualQ[r, 1 - Sqrt[2]]],
  True, TestID -> "negative-real-cubic-is-not-real-root"]
VerificationTest[
  Module[{e = Sqrt[5^(1/3) - 4^(1/3)], r},
    r = RadicalDenestImproved`Strad[e];
    RadicalDenestImproved`CertifiedEqualQ[r,
      (2^(1/3) + 20^(1/3) - 25^(1/3))/3] &&
      RadicalDenestImproved`RadicalDepth[r] === 1],
  True, TestID -> "honsbeek-ramanujan-square-of-cube-roots"]

VerificationTest[
  Module[{x, e, r},
    e = x + Sqrt[5 + 2 Sqrt[6]];
    r = RadicalDenestImproved`Strad[e, "Solver" -> (0 &), "Factor" -> False];
    TrueQ[RootReduce[(r - x) - (e - x)] === 0]],
  True, TestID -> "untrusted-solver-in-symbolic-host"]
VerificationTest[
  Module[{x, e, r},
    e = Sqrt[x^2] + Sqrt[5 + 2 Sqrt[6]];
    r = Block[{$Assumptions = x > 0}, RadicalDenestImproved`Strad[e]];
    TrueQ[RootReduce[(r - e) /. x -> -2] === 0]],
  True, TestID -> "ambient-assumptions-do-not-rewrite-host"]
VerificationTest[
  Module[{f, e}, e = f[Sqrt[5 + 2 Sqrt[6]]];
    SameQ[RadicalDenestImproved`Strad[e], e]],
  True, TestID -> "unknown-head-is-opaque"]
VerificationTest[
  SameQ[RadicalDenestImproved`Strad[HoldComplete[Sqrt[5 + 2 Sqrt[6]]]],
    HoldComplete[Sqrt[5 + 2 Sqrt[6]]]],
  True, TestID -> "held-input-is-opaque"]
VerificationTest[
  Module[{x, e}, e = (x + 1) (x - 1);
    SameQ[RadicalDenestImproved`Factorc[e], e]],
  True, TestID -> "symbolic-factorc-is-conservative"]
VerificationTest[
  Module[{e = 1/(1 + Sqrt[2]), r},
    r = RadicalDenestImproved`RationalizeDenominator[e];
    RadicalDenestImproved`CertifiedEqualQ[r, Sqrt[2] - 1]],
  True, TestID -> "horner-inverse"]
VerificationTest[
  Module[{x, e, r}, e = x/(1 + Sqrt[2]);
    r = RadicalDenestImproved`RationalizeDenominator[e];
    RadicalDenestImproved`CertifiedEqualQ[r /. x -> 1, Sqrt[2] - 1]],
  True, TestID -> "symbolic-numerator-local-inverse-certificate"]
VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[I] (-1 + I), -Sqrt[2]],
  True, TestID -> "aggregate-positive-factor-is-not-termwise-license"]

VerificationTest[
  Module[{saved, e = Sqrt[5 + 2 Sqrt[6]], r},
    saved = Options[RadicalDenestImproved`Strad];
    SetOptions[RadicalDenestImproved`Strad, "TimeBudget" -> 0];
    r = RadicalDenestImproved`Strad[e];
    SetOptions[RadicalDenestImproved`Strad, Sequence @@ saved]; SameQ[r, e]],
  True, TestID -> "setoptions-strad-is-effective"]
VerificationTest[
  Module[{saved, e = Sqrt[5 + 2 Sqrt[6]], r},
    saved = Options[RadicalDenestImproved`DenestRadicals];
    SetOptions[RadicalDenestImproved`DenestRadicals, "TimeBudget" -> 0];
    r = RadicalDenestImproved`DenestRadicals[e];
    SetOptions[RadicalDenestImproved`DenestRadicals, Sequence @@ saved]; SameQ[r, e]],
  True, TestID -> "setoptions-wrapper-is-effective"]
VerificationTest[
  Module[{r}, r = RadicalDenestImproved`DenestReport[Sqrt[5 + 2 Sqrt[6]],
      "TimeBudget" -> 0];
    r["Statistics"]["Trials"] === 0 && MemberQ[r["Limits"], "TimeBudget"] &&
      SameQ[r["Result"], Sqrt[5 + 2 Sqrt[6]]]],
  True, TestID -> "zero-budget-no-work"]
VerificationTest[
  And @@ (FailureQ[RadicalDenestImproved`Strad[Sqrt[1 + Sqrt[2]], #]] & /@
    {"MultiplierCap" -> Infinity, "MultiplierCap" -> -1,
     "MultiplierCap" -> 1/2, "MaxTrials" -> -1,
     "TimeBudget" -> Infinity, "TimeBudget" -> -1,
     "MaxRootOrder" -> 0, "AllLevels" -> "yes", "Bogus" -> 1}),
  True, TestID -> "invalid-options-fail-explicitly"]
VerificationTest[
  Module[{r}, r = RadicalDenestImproved`DenestReport[Sqrt[1 + Sqrt[2]],
      "Multipliers" -> Range[20], "MultiplierCap" -> 1,
      "UseDiscriminants" -> False, "TimeBudget" -> 20];
    r["Statistics"]["MultipliersAdmitted"] <= 1 && r["Statistics"]["Trials"] <= 1],
  True, TestID -> "forced-list-obeys-total-target-cap"]
VerificationTest[
  Module[{r}, r = RadicalDenestImproved`DenestReport[
      {Sqrt[1 + Sqrt[2]], Sqrt[1 + Sqrt[3]]},
      "MaxTrials" -> 1, "Multipliers" -> {1}, "TimeBudget" -> 30];
    r["Statistics"]["Trials"] <= 1],
  True, TestID -> "trial-budget-shared-across-list"]
VerificationTest[
  Module[{r}, r = RadicalDenestImproved`DenestReport[Sqrt[1 + Sqrt[2]],
      "Trace" -> True, "MaxTraceEntries" -> 1, "MaxTrials" -> 2,
      "TimeBudget" -> 20]; Length[r["Trace"]] <= 1],
  True, TestID -> "bounded-diagnostics"]
VerificationTest[
  Module[{e = Sqrt[5 + 2 Sqrt[6]], r},
    r = RadicalDenestImproved`Strad[e, "Solver" -> (Throw["bad", "callback"] &)];
    TrueQ[RootReduce[r - e] === 0]],
  True, TestID -> "callback-throw-is-not-a-rewrite"]
VerificationTest[
  Module[{examples, results},
    examples = {Sqrt[2 + Sqrt[3]], Sqrt[4 + 3 Sqrt[2]],
      (7 - 5 Sqrt[2])^(1/3), (49 + 20 Sqrt[6])^(1/4)};
    results = RadicalDenestImproved`Strad[examples, True];
    And @@ MapThread[
      (TrueQ[RootReduce[#1 - #2] === 0] &&
        Order[RadicalDenestImproved`RadicalCost[#1],
          RadicalDenestImproved`RadicalCost[#2]] =!= -1) &,
      {results, examples}]],
  True, TestID -> "each-example-equal-and-no-more-expensive"]
