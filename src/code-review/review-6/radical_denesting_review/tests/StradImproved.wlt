(* Native Wolfram regression suite. NOT executed in the supplied review.
   Load ../code/StradImproved.wl before TestReport on this file. *)
Begin["RadicalDenestImprovedTests`"];
ClearAll[d, eq, depth, improves, x, f];
d[e_, opts___] := RadicalDenestImproved`Strad[e, opts];
eq[a_, b_] := TrueQ[RootReduce[a-b] === 0];
depth[e_] := RadicalDenestImproved`RadicalDepth[e];
improves[e_, target_] := Module[{v = d[e, "MaxTrials" -> 0]},
  eq[v,target] && depth[v] < depth[e]];

VerificationTest[improves[Sqrt[3+2 Sqrt[2]], 1+Sqrt[2]], True, TestID -> "direct-plus"]
VerificationTest[improves[Sqrt[3-2 Sqrt[2]], Sqrt[2]-1], True, TestID -> "direct-minus"]
VerificationTest[improves[Sqrt[5+2 Sqrt[6]], Sqrt[2]+Sqrt[3]], True, TestID -> "two-surds"]
VerificationTest[improves[Sqrt[4+3 Sqrt[2]], 2^(1/4) (1+Sqrt[2])], True, TestID -> "indirect-plus"]
VerificationTest[improves[Sqrt[-4+3 Sqrt[2]], 2^(1/4) (Sqrt[2]-1)], True, TestID -> "indirect-minus"]
VerificationTest[eq[d[Sqrt[-3-2 Sqrt[2]], "MaxTrials"->0], I (1+Sqrt[2])], True, TestID -> "imaginary-square-root"]
VerificationTest[Module[{v=d[Sqrt[3+4 I], "MaxTrials"->0]},
  eq[v,2+I] && depth[v]===0], True, TestID -> "complex-square-root"]
VerificationTest[improves[(26+15 Sqrt[3])^(1/3), 2+Sqrt[3]], True, TestID -> "cubic-quadratic"]
VerificationTest[improves[(2+Sqrt[5])^(1/3), (1+Sqrt[5])/2], True, TestID -> "cubic-golden-ratio"]
VerificationTest[eq[d[(-26-15 Sqrt[3])^(1/3), "MaxTrials"->0], (-1)^(1/3)(2+Sqrt[3])], True, TestID -> "principal-negative-cube"]
VerificationTest[improves[(3+2 Sqrt[2])^(3/2), (1+Sqrt[2])^3], True, TestID -> "rational-power-numerator"]
VerificationTest[eq[d[(3+2 Sqrt[2])^(-1/2), "MaxTrials"->0], Sqrt[2]-1], True, TestID -> "reciprocal-root"]

(* Adversarial candidates: the callback is a candidate producer, not a proof. *)
VerificationTest[
  eq[d[x+Sqrt[3+2 Sqrt[2]], "Solver"->(0&)]-x, 1+Sqrt[2]],
  True, TestID -> "symbolic-host-reject-zero"]
VerificationTest[
  eq[d[Sqrt[3+2 Sqrt[2]], "Solver"->(-1-Sqrt[2]&)], 1+Sqrt[2]],
  True, TestID -> "reject-opposite-branch"]
VerificationTest[
  FreeQ[d[Sqrt[3+2 Sqrt[2]], "Solver"->(N[#,20]&)], _Real],
  True, TestID -> "reject-inexact-candidate"]
VerificationTest[
  d[x+Sqrt[2+Sqrt[2]], "Solver"->(0&)] =!= x,
  True, TestID -> "symbolic-host-without-fastpath"]
VerificationTest[
  RadicalDenestImproved`Private`radicalExpressionQ[Inactive[Cos][Pi/8]],
  False, TestID -> "grammar-reject-hidden-function"]
VerificationTest[
  RadicalDenestImproved`Private`radicalExpressionQ[Root[#^5-#-1&,1]],
  False, TestID -> "grammar-reject-root-object"]
VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[2]+Sqrt[3],Sqrt[3]-Sqrt[2]],
  False, TestID -> "same-minpoly-not-equality"]
VerificationTest[
  RadicalDenestImproved`CertifiedEqualQ[Sqrt[3+2 Sqrt[2]],1+Sqrt[2]],
  True, TestID -> "exact-certificate"]

VerificationTest[Block[{$Assumptions=x>0}, d[Sqrt[x^2]]], Sqrt[x^2], TestID -> "ambient-assumptions-isolated"]
VerificationTest[d[HoldComplete[Sqrt[3+2 Sqrt[2]]]], HoldComplete[Sqrt[3+2 Sqrt[2]]], TestID -> "held-input-unchanged"]
VerificationTest[d[f[Sqrt[3+2 Sqrt[2]]]], f[Sqrt[3+2 Sqrt[2]]], TestID -> "unknown-head-not-traversed"]
VerificationTest[d[{1.25, Sqrt[3+2 Sqrt[2]]}, "MaxTrials"->0], {1.25,1+Sqrt[2]}, TestID -> "mixed-exact-inexact-list"]
VerificationTest[d[0], 0, TestID -> "zero"]
VerificationTest[d[7/5], 7/5, TestID -> "rational-no-op"]
VerificationTest[d[Indeterminate], Indeterminate, TestID -> "invalid-value-preserved"]
VerificationTest[d[Sqrt[3+2 Sqrt[2]], "TimeBudget"->0], Sqrt[3+2 Sqrt[2]], TestID -> "zero-budget-no-op"]
VerificationTest[FailureQ[d[Sqrt[2], "MultiplierCap"->Infinity]], True, TestID -> "infinite-cap-invalid"]
VerificationTest[FailureQ[d[Sqrt[2], "MaxTrials"->-1]], True, TestID -> "negative-trials-invalid"]
VerificationTest[FailureQ[d[Sqrt[2], "TimeBudget"->-1]], True, TestID -> "negative-budget-invalid"]
VerificationTest[FailureQ[d[Sqrt[2], "AllLevels"->"yes"]], True, TestID -> "boolean-option-invalid"]
VerificationTest[FailureQ[d[Sqrt[2], "NotAnOption"->1]], True, TestID -> "unknown-option-invalid"]
VerificationTest[
  Module[{saved=Options[RadicalDenestImproved`Strad], out},
    SetOptions[RadicalDenestImproved`Strad, "TimeBudget"->0];
    out=d[Sqrt[3+2 Sqrt[2]]];
    Options[RadicalDenestImproved`Strad]=saved;
    out], Sqrt[3+2 Sqrt[2]], TestID -> "setoptions-respected"]
VerificationTest[
  d[Sqrt[3+2 Sqrt[2]], "TimeBudget"->0, "TimeBudget"->30],
  Sqrt[3+2 Sqrt[2]], TestID -> "first-explicit-option-wins"]
VerificationTest[
  d[Sqrt[3+2 Sqrt[2]], "MultiplierCap"->0, "DetailedResult"->True]["MultiplierTrials"],
  0, TestID -> "zero-cap-no-search"]
VerificationTest[
  Module[{r=d[{Sqrt[2+Sqrt[2]],Sqrt[1+Sqrt[3]]}, "MaxTrials"->1,
    "MultiplierCap"->2, "TimeBudget"->5, "DetailedResult"->True]},
    r["MultiplierTrials"] <= 1], True, TestID -> "shared-list-trials"]
VerificationTest[
  Module[{r=d[Sqrt[2+Sqrt[2]], "MultiplierCap"->1, "MaxTrials"->2,
    "AllLevels"->False, "TimeBudget"->5, "DetailedResult"->True]},
    r["MultipliersEnqueued"] <= 1], True, TestID -> "queue-cap-one-node"]
VerificationTest[
  Module[{r=d[Sqrt[3+2 Sqrt[2]], "MaxTrials"->0, "DetailedResult"->True]},
    Length[r["Certificates"]]>0 &&
      AllTrue[r["Certificates"], eq[#["After"],#["Before"]]&]],
  True, TestID -> "recheck-certificate-log"]
VerificationTest[
  Module[{e=1/(1+Sqrt[2]),v},
    v=RadicalDenestImproved`RationalizeDenominator[e]; eq[e,v]],
  True, TestID -> "rationalization-equality"]
VerificationTest[RadicalDenestImproved`Factorc[x^2-1], x^2-1, TestID -> "symbolic-factorc-conservative"]
VerificationTest[Order[{0,1,2},{0,2,1}], 1, TestID -> "cost-order-direction"]

(* Capability acceptance test for the retained multiplier architecture.
   It may expose an implementation defect or a conservative timeout: do not
   turn its failure into a false theorem of non-denestability. *)
VerificationTest[
  Module[{e=(2^(1/3)-1)^(1/3),v},
    v=RadicalDenestImproved`DenestCore[e, "Multipliers"->{9},
      "MultiplierCap"->1, "MaxTrials"->1, "TimeBudget"->30];
    eq[e,v] && depth[v]<depth[e]],
  True, TestID -> "ramanujan-forced-multiplier-nine"]
End[];
