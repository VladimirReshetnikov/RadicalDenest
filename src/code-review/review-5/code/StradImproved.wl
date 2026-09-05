(* ::Package:: *)
(* Independently written reference implementation, 2026-09-05.
   NOT a source-complete patch of StradFixed.wl. See SOURCE_ACCESS.md.
   Native Wolfram Language execution was unavailable during this review.
   Scope: exact scalar arithmetic; principal complex Power; fail-closed
   local certification. Custom solvers are proposals, not proof oracles.
   This is not a sandbox for hostile Wolfram Language programs. *)

BeginPackage["RadicalDenestImproved`"];
Strad::usage = "Strad[e, options] attempts certified radical simplification. Strad[e, True] enables repeated bottom-up passes.";
DenestRadicals::usage = "DenestRadicals[e, options] returns a certified improvement or the original evaluated expression.";
DenestCore::usage = "DenestCore[e, options] restricts the entry point to an explicit exact algebraic expression.";
DenestReport::usage = "DenestReport[e, options] returns the value, outcome, counters, and bounded local equality records.";
ExactAlgebraicQ::usage = "ExactAlgebraicQ[e] conservatively recognizes the supported explicit algebraic grammar; it is not a universal algebraicity decision procedure.";
EqualityStatus::usage = "EqualityStatus[a,b,t] returns Equal, Different, or Unknown as a string, using exact RootReduce under a time limit.";
CertifiedEqualQ::usage = "CertifiedEqualQ[a,b,t] is True only when EqualityStatus[a,b,t] is Equal (default t=5).";
RadicalDepth::usage = "RadicalDepth[e] measures rational-Power depth. Root objects are separately penalized by RadicalCost.";
RadicalCost::usage = "RadicalCost[e] is {opaque algebraic objects, depth, rational-power nodes, integer bit cost, leaf count}.";
RationalizeDenominator::usage = "RationalizeDenominator[e,t] attempts an exactly certified rational-denominator form of a supported algebraic number.";
Factorc::usage = "Factorc[e,t] is a certified numeric Factor proposal, not the original symbolic factoring interface.";

Options[DenestRadicals] = {
  "AllLevels" -> False, "Verbose" -> False, "Multipliers" -> Automatic,
  "MaxTrials" -> 64, "TimeBudget" -> 60, "MultiplierCap" -> 32,
  "CertifyTime" -> 5, "StageTime" -> 5, "Solver" -> Automatic,
  "Factor" -> True, "MaxPasses" -> 3, "MaxDegree" -> 64,
  "MaxRootIndex" -> 24, "MaxSolveDegree" -> 2,
  "MaxLeafCount" -> 4096, "MaxBytes" -> 4194304,
  "MemoryBudget" -> 268435456, "MaxRecords" -> 128
};
Options[Strad] = Options[DenestRadicals];
Options[DenestCore] = Options[DenestRadicals];
Options[DenestReport] = Options[DenestRadicals];

Begin["`Private`"];
rationalQ[e_] := MatchQ[e, _Integer | _Rational];
finiteNonnegativeQ[e_] := NumberQ[e] && TrueQ[Im[e] == 0] && TrueQ[e >= 0];

(* This grammar deliberately excludes trigonometric/special-function disguises,
   arbitrary numeric heads, inexact constants, and symbolic parameters. *)
ExactAlgebraicQ[e_] := Which[
  rationalQ[e], True,
  Head[e] === Complex, rationalQ[Re[e]] && rationalQ[Im[e]],
  AtomQ[e], False,
  MemberQ[{Plus, Times}, Head[e]], AllTrue[List @@ e, ExactAlgebraicQ],
  Head[e] === Power && Length[e] == 2,
    rationalQ[e[[2]]] && ExactAlgebraicQ[e[[1]]],
  MemberQ[{Root, AlgebraicNumber}, Head[e]],
    TrueQ[NumericQ[e] && Precision[e] === Infinity &&
      Quiet[Check[Element[e, Algebraics], False]]],
  True, False
];

RadicalDepth[e_] := Which[
  AtomQ[e], 0,
  MemberQ[{Root, AlgebraicNumber}, Head[e]], 0,
  Head[e] === Power && MatchQ[e[[2]], _Rational], 1 + RadicalDepth[e[[1]]],
  True, Max[Prepend[RadicalDepth /@ (List @@ e), 0]]
];
bitCost[n_Integer] := IntegerLength[Abs[n], 2];
bitCost[q_Rational] := bitCost[Numerator[q]] + bitCost[Denominator[q]];
bitCost[z_Complex] := bitCost[Re[z]] + bitCost[Im[z]];
bitCost[_] := 0;
RadicalCost[e_] := {
  Count[e, _Root | _AlgebraicNumber, {0, Infinity}], RadicalDepth[e],
  Count[e, Power[_, _Rational], {0, Infinity}],
  Total[bitCost /@ Cases[e, _Integer | _Rational | _Complex, {0, Infinity}]], LeafCount[e]
};
lessQ[a_, b_] := Module[{pairs, first},
  pairs = Select[Transpose[{RadicalCost[a], RadicalCost[b]}], #[[1]] =!= #[[2]] &];
  If[pairs === {}, False, first = First[pairs]; TrueQ[first[[1]] < first[[2]]]]
];

canonicalNonzeroQ[e_] := e =!= 0 &&
  MatchQ[e, _Integer | _Rational | _Complex | _Root | _AlgebraicNumber] &&
  TrueQ[NumericQ[e] && Precision[e] === Infinity];
classify[e_] := Which[e === 0, "Equal", canonicalNonzeroQ[e], "Different", True, "Unknown"];
EqualityStatus[a_, b_, t_:5] := Module[{r},
  If[!finiteNonnegativeQ[t] || TrueQ[t == 0], Return["Unknown"]];
  r = TimeConstrained[
    Block[{$Assumptions = True}, Quiet[Check[
      If[ExactAlgebraicQ[a] && ExactAlgebraicQ[b], RootReduce[a - b], $Failed], $Failed]]],
    t, $Failed];
  classify[r]
];
CertifiedEqualQ[a_, b_, t_:5] := EqualityStatus[a, b, t] === "Equal";

(* Public diagnostic helpers use their own time allowance. They are not called
   from the engine, whose private stage[] shares one per-call deadline. *)
Factorc[e_, t_:5] := Module[{p},
  If[!finiteNonnegativeQ[t] || TrueQ[t == 0], Return[e]];
  p = TimeConstrained[Quiet[Check[If[ExactAlgebraicQ[e], Factor[e], e], e]], t, e];
  If[CertifiedEqualQ[p, e, t], p, e]
];
rationalizeProposal[e_] := Module[{u, a, n, d, p, q, c},
  a = Together[e]; n = Numerator[a]; d = Denominator[a];
  If[d === 1, Return[e]];
  p = MinimalPolynomial[d, u];
  If[!PolynomialQ[p, u], Return[e]];
  c = p /. u -> 0;
  If[c === 0, Return[e]];
  q = PolynomialQuotient[p, u - d, u] /. u -> 0;
  Expand[-n q/c]
];
RationalizeDenominator[e_, t_:5] := Module[{p},
  If[!finiteNonnegativeQ[t] || TrueQ[t == 0], Return[e]];
  p = TimeConstrained[Quiet[Check[
    If[ExactAlgebraicQ[e], rationalizeProposal[e], e], e]], t, e];
  If[CertifiedEqualQ[p, e, t], p, e]
];

(* Resolve CURRENT defaults of the function actually called, not just explicit
   options. DeleteDuplicatesBy preserves the first explicit value, like the
   usual Wolfram option convention. Unknown names are rejected. *)
flattenOptions[items_List] := Flatten[(If[ListQ[#], flattenOptions[#], {#}] & /@ items), 1];
configuration[f_, explicit_List] := Module[{known, given, cfg, nonnegative, positive},
  given = flattenOptions[explicit];
  known = First /@ Options[f];
  If[!AllTrue[given, MatchQ[#, _Rule | _RuleDelayed] && MemberQ[known, First[#]] &],
    Return[$Failed]];
  cfg = Association[(First[#] -> Last[#] &) /@
    DeleteDuplicatesBy[Join[given, Options[f]], First]];
  If[!AllTrue[{"AllLevels", "Verbose", "Factor"}, MemberQ[{True, False}, cfg[#]] &], Return[$Failed]];
  nonnegative = {"MaxTrials", "MultiplierCap", "MaxRecords"};
  positive = {"MaxPasses", "MaxDegree", "MaxRootIndex", "MaxSolveDegree", "MaxLeafCount", "MaxBytes", "MemoryBudget"};
  If[!AllTrue[nonnegative, IntegerQ[cfg[#]] && cfg[#] >= 0 &], Return[$Failed]];
  If[!AllTrue[positive, IntegerQ[cfg[#]] && cfg[#] > 0 &], Return[$Failed]];
  If[!AllTrue[{"TimeBudget", "CertifyTime", "StageTime"}, finiteNonnegativeQ[cfg[#]] &], Return[$Failed]];
  If[cfg["MaxSolveDegree"] > 4, Return[$Failed]];
  If[!(cfg["Multipliers"] === Automatic || ListQ[cfg["Multipliers"]]), Return[$Failed]];
  If[!MatchQ[cfg["Solver"], Automatic | _Function | _Symbol], Return[$Failed]];
  cfg
];

(* Dynamic variables are private and localized by run[]. No persistent cache. *)
SetAttributes[stage, HoldAll];
stage[body_, limit_] := Module[{t, answer},
  t = Min[limit, $deadline - AbsoluteTime[]];
  If[!TrueQ[t > 0], $stageFailures++; Return[$Failed]];
  answer = TimeConstrained[Quiet[Check[body, $Failed]], t, $Failed];
  If[answer === $Failed, $stageFailures++]; answer
];
tick[] := If[AbsoluteTime[] >= $deadline, Throw[timeoutToken, $stopTag]];
withinBoundsQ[e_] := LeafCount[e] <= $cfg["MaxLeafCount"] && ByteCount[e] <= $cfg["MaxBytes"];
proof[a_, b_] := Module[{answer, status},
  answer = stage[If[ExactAlgebraicQ[a] && ExactAlgebraicQ[b], RootReduce[a - b], $Failed], $cfg["CertifyTime"]];
  status = classify[answer]; If[status === "Unknown", $unknown++]; status
];
accept[proposal_, original_, current_] := Module[{status},
  tick[];
  If[!withinBoundsQ[proposal] || !ExactAlgebraicQ[proposal] || !lessQ[proposal, current], Return[current]];
  status = proof[proposal, original];
  If[status =!= "Equal", Return[current]];
  $accepted++;
  If[Length[$records] < $cfg["MaxRecords"],
    AppendTo[$records, <|"Before" -> original, "After" -> proposal,
      "Method" -> "RootReduceDifference", "Residual" -> 0|>]];
  proposal
];

(* A local norm fast path. Both signs are proposals. This handles branch
   selection through the SAME acceptance gate, not by numerical sign tests. *)
quadraticProposals[e_] := Module[{a, b, c, z, rad, s, p, d, h, u, v, out = {}},
  If[Head[e] =!= Power || e[[2]] =!= 1/2, Return[{}]];
  rad = Expand[e[[1]]];
  s = DeleteDuplicates[Cases[rad, Power[q_?rationalQ, 1/2] :> Sqrt[q], {0, Infinity}]];
  If[Length[s] =!= 1, Return[{}]];
  s = First[s]; c = s^2;
  If[!rationalQ[c] || !TrueQ[c > 0], Return[{}]];
  p = rad /. s -> z;
  If[!PolynomialQ[p, z] || Exponent[p, z] =!= 1, Return[{}]];
  {a, b} = CoefficientList[p, z];
  If[!rationalQ[a] || !rationalQ[b], Return[{}]];
  d = Sqrt[a^2 - b^2 c];
  If[rationalQ[d],
    u = Sqrt[(a + d)/2]; v = Sqrt[(a - d)/2];
    out = Join[out, {u + v, u - v, -u + v, -u - v}]];
  h = Sqrt[b^2 - a^2/c];
  If[rationalQ[h],
    u = Sqrt[(b + h)/2]; v = Sqrt[(b - h)/2];
    out = Join[out, c^(1/4) {u + v, u - v, -u + v, -u - v}]];
  DeleteDuplicates[out]
];

reductionIndex[e_] := Module[{d, nodes},
  d = RadicalDepth[e];
  nodes = Select[Cases[e, Power[_, _Rational], {0, Infinity}], RadicalDepth[#] == d &];
  If[nodes === {}, 1, LCM @@ (Denominator[#[[2]]] & /@ nodes)]
];
multiplierSeeds[R_] := Module[{visible, seeds},
  If[ListQ[$cfg["Multipliers"]], Return[DeleteDuplicates[$cfg["Multipliers"]]]];
  visible = Cases[R, Power[b_?rationalQ, q_Rational] :> b^(1 - q), {0, Infinity}];
  seeds = Join[{1}, visible, Range[$cfg["MultiplierCap"]]];
  DeleteDuplicates[seeds]
];
smallRoots[g_, x_, d_] := Module[{c, sol},
  c = CoefficientList[g, x];
  Which[
    d == 1, {-c[[1]]/c[[2]]},
    d == 2, {(-c[[2]] + Sqrt[c[[2]]^2 - 4 c[[1]] c[[3]]])/(2 c[[3]]),
             (-c[[2]] - Sqrt[c[[2]]^2 - 4 c[[1]] c[[3]]])/(2 c[[3]])},
    d <= $cfg["MaxSolveDegree"],
      sol = Solve[g == 0, x]; If[ListQ[sol], x /. sol, {}],
    True, {}
  ]
];
gcdSearch[original_, initial_] := Module[
  {best = initial, r, R, seeds, m, x, p, g, degree, roots, root, k, candidate},
  r = reductionIndex[original];
  If[!IntegerQ[r] || r < 2 || r > $cfg["MaxRootIndex"] || $trials >= $cfg["MaxTrials"], Return[best]];
  R = stage[Expand[original^r], $cfg["StageTime"]];
  If[R === $Failed || !withinBoundsQ[R] || !ExactAlgebraicQ[R], Return[best]];
  seeds = multiplierSeeds[R];
  Do[
    tick[]; If[$trials >= $cfg["MaxTrials"], Break[]];
    (* Invalid seeds do not consume expensive trial slots, but are finite input. *)
    If[!withinBoundsQ[m] || !ExactAlgebraicQ[m] || proof[m, 0] =!= "Different", Continue[]];
    $trials++;
    p = stage[MinimalPolynomial[(m R)^(1/r), x], $cfg["StageTime"]];
    If[p === $Failed || !PolynomialQ[p, x] || !withinBoundsQ[p], Continue[]];
    If[Exponent[p, x] > $cfg["MaxDegree"], $degreeSkips++; Continue[]];
    g = stage[PolynomialGCD[p, x^r - m R, Extension -> Automatic], $cfg["StageTime"]];
    If[g === $Failed || !PolynomialQ[g, x] || !withinBoundsQ[g], Continue[]];
    degree = Exponent[g, x];
    If[!IntegerQ[degree] || degree < 1 || degree >= r || degree > $cfg["MaxSolveDegree"], Continue[]];
    roots = stage[smallRoots[g, x, degree], $cfg["StageTime"]];
    If[!ListQ[roots], Continue[]];
    Do[
      If[!FreeQ[root, x] || !withinBoundsQ[root] || !ExactAlgebraicQ[root], Continue[]];
      Do[
        candidate = stage[Expand[root/m^(1/r) (-1)^(2 k/r)], $cfg["StageTime"]];
        best = accept[candidate, original, best], {k, 0, r - 1}],
      {root, roots}],
    {m, seeds}];
  best
];

(* No marker language and no ReplaceRepeated. Numerical islands are certified
   against their original value. Symbolic hosts are rebuilt only by congruence
   through List, Plus, Times and rational/integer Power. Other heads are opaque. *)
island[e_] := Module[{best = e, p, proposals, rebuilt},
  tick[];
  If[RadicalDepth[e] < 2 && FreeQ[e, _Root | _AlgebraicNumber], Return[e]];
  If[TrueQ[$cfg["AllLevels"]] && !AtomQ[e] && MemberQ[{Plus, Times, Power}, Head[e]],
    rebuilt = Map[walk, e]; best = accept[rebuilt, e, best]];
  If[$cfg["Solver"] =!= Automatic,
    p = stage[$cfg["Solver"][e], $cfg["StageTime"]];
    best = accept[p, e, best]];
  If[!FreeQ[e, _Root | _AlgebraicNumber],
    p = stage[ToRadicals[e], $cfg["StageTime"]]; best = accept[p, e, best]];
  proposals = stage[quadraticProposals[e], $cfg["StageTime"]];
  If[ListQ[proposals], Do[best = accept[p, e, best], {p, proposals}]];
  p = stage[RootReduce[e], $cfg["StageTime"]]; best = accept[p, e, best];
  If[TrueQ[$cfg["Factor"]], p = stage[Factor[e], $cfg["StageTime"]]; best = accept[p, e, best]];
  p = stage[Simplify[e, Assumptions -> True], $cfg["StageTime"]]; best = accept[p, e, best];
  If[RadicalDepth[best] >= 2, best = gcdSearch[e, best]];
  best
];
walk[e_] := Module[{h},
  tick[];
  If[!withinBoundsQ[e], Return[e]];
  If[ExactAlgebraicQ[e], Return[island[e]]];
  If[AtomQ[e], Return[e]];
  h = Head[e];
  If[MemberQ[{List, Plus, Times}, h] || (h === Power && rationalQ[e[[2]]]), Map[walk, e], e]
];
workflow[e_, coreOnly_] := Module[{best = e, next, passes, i},
  If[!withinBoundsQ[e], Return[e]];
  (* No promises about preservation of floating-point evaluation order. *)
  If[!FreeQ[e, _Real | _Complex?InexactNumberQ], Return[e]];
  If[coreOnly && !ExactAlgebraicQ[e], Return[e]];
  passes = If[TrueQ[$cfg["AllLevels"]], $cfg["MaxPasses"], 1];
  For[i = 1, i <= passes, i++,
    next = If[coreOnly, island[best], walk[best]];
    If[!lessQ[next, best], Break[]]; best = next];
  best
];
run[e_, cfg_, coreOnly_:False] := Module[{answer, status, inputCost, outputCost},
  If[cfg === $Failed, Return[<|"Value" -> e, "Status" -> "InvalidOptions"|>]];
  If[TrueQ[cfg["TimeBudget"] == 0], Return[<|"Value" -> e, "Status" -> "Disabled", "Trials" -> 0|>]];
  Block[{$cfg = cfg, $deadline = AbsoluteTime[] + cfg["TimeBudget"],
    $stopTag = Unique["denestStop$"], $trials = 0, $stageFailures = 0,
    $unknown = 0, $accepted = 0, $degreeSkips = 0, $records = {}, $Assumptions = True},
    answer = Catch[TimeConstrained[
      MemoryConstrained[Module[{v = workflow[e, coreOnly]},
        {v, If[withinBoundsQ[e], RadicalCost[e], Missing["SizeLimit"]],
            If[withinBoundsQ[v], RadicalCost[v], Missing["SizeLimit"]]}],
        cfg["MemoryBudget"], memoryToken],
      cfg["TimeBudget"], timeoutToken], $stopTag];
    status = Which[answer === timeoutToken, "Timeout", answer === memoryToken, "MemoryLimit",
      SameQ[First[answer], e], "Unchanged", True, "Improved"];
    (* Atomic rollback: never return a partly rebuilt host after interruption. *)
    If[MemberQ[{"Timeout", "MemoryLimit"}, status],
      answer = e; inputCost = outputCost = Missing["Interrupted"],
      {answer, inputCost, outputCost} = answer];
    If[TrueQ[cfg["Verbose"]], Print["RadicalDenestImproved: ", status, "; multiplier trials = ", $trials]];
    <|"Value" -> answer, "Status" -> status, "Trials" -> $trials,
      "StageFailures" -> $stageFailures, "UnknownCertificates" -> $unknown,
      "DegreeSkips" -> $degreeSkips, "AcceptedLocalSteps" -> $accepted,
      "RecordsTruncated" -> ($accepted > Length[$records]), "LocalRecords" -> $records,
      "TrialLimitReached" -> ($trials >= cfg["MaxTrials"]),
      "InputCost" -> inputCost, "OutputCost" -> outputCost,
      "SearchIsComplete" -> False|>
  ]
];

Strad[e_, opts:OptionsPattern[]] := run[e, configuration[Strad, {opts}]]["Value"];
Strad[e_, all:(True|False), opts:OptionsPattern[]] :=
  run[e, configuration[Strad, Join[{"AllLevels" -> all}, {opts}]]]["Value"];
DenestRadicals[e_, opts:OptionsPattern[]] := run[e, configuration[DenestRadicals, {opts}]]["Value"];
DenestRadicals[e_, all:(True|False), opts:OptionsPattern[]] :=
  run[e, configuration[DenestRadicals, Join[{"AllLevels" -> all}, {opts}]]]["Value"];
DenestCore[e_, opts:OptionsPattern[]] := run[e, configuration[DenestCore, {opts}], True]["Value"];
DenestReport[e_, opts:OptionsPattern[]] := run[e, configuration[DenestReport, {opts}]];

End[];
EndPackage[];
