(* ::Package:: *)
(* StradImproved.wl -- conservative, certificate-gated radical denesting.
   Proposed implementation, 2026-09-05. Native Wolfram execution is PENDING.
   See the accompanying article and tests before production use.
   Side-by-side context: this file does not overwrite RadicalDenest`.
   Ordinary argument evaluation and user callbacks are NOT sandboxed. *)

BeginPackage["RadicalDenestImproved`"];
Strad::usage = "Strad[e, opts] improves exact algebraic numeric subexpressions in arithmetic/List hosts. Every accepted numeric rewrite has an exact certificate. No minimum-depth guarantee.";
DenestRadicals::usage = "DenestRadicals[e, opts] has the same engine as Strad, with independently configurable defaults.";
DenestCore::usage = "DenestCore[e, opts] searches only the whole exact numeric expression e.";
RadicalDepth::usage = "RadicalDepth[e] counts noninteger rational-power nesting; integer powers do not add depth.";
RadicalCost::usage = "RadicalCost[e] is {opaque algebraic objects, depth, rational-power nodes, LeafCount, largest root index, integer-bit cost}.";
ExactAlgebraicQ::usage = "ExactAlgebraicQ[e] conservatively checks exact numeric algebraicity, with a five-second operation allowance.";
CertifiedEqualQ::usage = "CertifiedEqualQ[a,b] returns True only after exact numeric algebraic predicates and RootReduce[a-b]===0, within a five-second allowance.";
Factorc::usage = "Factorc[e,opts] conservatively tries FactorTerms on exact numeric e, accepting only a cheaper exactly equal radical expression. Symbolic e is unchanged.";
RationalizeDenominator::usage = "RationalizeDenominator[e,opts] rationalizes a nonzero algebraic denominator of exact numeric e, with exact certification. Unlike Strad, it need not lower cost.";

Options[Strad] = {
  "AllLevels" -> False, "Verbose" -> False, "Multipliers" -> Automatic,
  "MaxTrials" -> 100, "TimeBudget" -> 30, "MultiplierCap" -> 64,
  "CertifyTime" -> 5, "OperationTime" -> 5, "Solver" -> Automatic,
  "Factor" -> False, "MaxPasses" -> 4, "MaxDegree" -> 32,
  "MaxRootIndex" -> 16, "MaxLeafCount" -> 20000,
  "MaxCandidates" -> 128, "MemoryBudget" -> 268435456,
  "DetailedResult" -> False
};
Options[DenestRadicals] = Options[Strad];
Options[DenestCore] = Options[Strad];
Options[Factorc] = Options[Strad];
Options[RationalizeDenominator] = Options[Strad];

Begin["`Private`"];

rationalQ[e_] := MatchQ[e, _Integer | _Rational];
finiteNonnegativeQ[e_] := MatchQ[e, _Integer | _Rational | _Real] &&
  TrueQ[0 <= e < Infinity];
finitePositiveQ[e_] := finiteNonnegativeQ[e] && TrueQ[e > 0];
nonnegativeIntegerQ[e_] := IntegerQ[e] && e >= 0;
positiveIntegerQ[e_] := IntegerQ[e] && e > 0;

resolveOptions[head_, supplied_List] := Module[{defaults, cfg, keys, bad, checks},
  defaults = Options[head]; keys = First /@ defaults;
  If[!AllTrue[supplied, MatchQ[#, _Rule | _RuleDelayed] &],
    Return[Failure["InvalidOptions", <|"Reason" -> "Expected option rules."|>]]];
  bad = Complement[First /@ supplied, keys];
  If[bad =!= {}, Return[Failure["UnknownOption", <|"Options" -> bad|>]]];
  (* Association keeps the last occurrence; reversing implements first-rule wins. *)
  cfg = Join[Association[defaults], Association[Reverse[supplied]]];
  checks = {
    AllTrue[Lookup[cfg, {"AllLevels", "Verbose", "Factor", "DetailedResult"}],
      (# === True || # === False) &],
    finiteNonnegativeQ[cfg["TimeBudget"]],
    AllTrue[Lookup[cfg, {"CertifyTime", "OperationTime"}], finitePositiveQ],
    AllTrue[Lookup[cfg, {"MaxTrials", "MultiplierCap", "MaxCandidates"}], nonnegativeIntegerQ],
    AllTrue[Lookup[cfg, {"MaxPasses", "MaxDegree", "MaxRootIndex", "MaxLeafCount", "MemoryBudget"}], positiveIntegerQ],
    cfg["Multipliers"] === Automatic || ListQ[cfg["Multipliers"]],
    cfg["Solver"] === Automatic || MatchQ[cfg["Solver"], _Function | _Symbol]
  };
  If[And @@ checks, cfg,
    Failure["InvalidOptionValue", <|"Reason" -> "See the documented option domains."|>]]
];

RadicalDepth[e_] := Which[
  AtomQ[e], 0,
  MatchQ[e, Power[_, _Rational]], 1 + RadicalDepth[e[[1]]],
  True, Max[Prepend[RadicalDepth /@ (List @@ e), 0]]
];
RadicalCost[e_] := Module[{indices, bits},
  indices = Cases[e, Power[_, p_Rational] :> Denominator[p], {0, Infinity}];
  bits = Total[Cases[e,
    n_Integer :> IntegerLength[Abs[n] + 1, 2], {0, Infinity}]] +
    Total[Cases[e, n_Rational :>
      IntegerLength[Abs[Numerator[n]] + 1, 2] + IntegerLength[Denominator[n], 2],
      {0, Infinity}]];
  {Count[e, _Root | _AlgebraicNumber, {0, Infinity}], RadicalDepth[e],
    Length[indices], LeafCount[e], Max[Prepend[indices, 0]], bits}
];
cheaperQ[a_, b_] := Order[RadicalCost[a], RadicalCost[b]] === 1;

(* Numerical expressions admissible for output. No hidden Root, trig, Exp,
   Surd, or symbolic constants may masquerade as depth-zero denesting. *)
radicalExpressionQ[e_] := Which[
  rationalQ[e], True,
  Head[e] === Complex, rationalQ[Re[e]] && rationalQ[Im[e]],
  AtomQ[e], False,
  Head[e] === Plus || Head[e] === Times, AllTrue[List @@ e, radicalExpressionQ],
  Head[e] === Power, rationalQ[e[[2]]] && radicalExpressionQ[e[[1]]],
  True, False
];
rawAlgebraicQ[e_] := TrueQ[NumericQ[e] && Precision[e] === Infinity &&
  Quiet[Check[Element[e, Algebraics], False]]];
ExactAlgebraicQ[e_] := Block[{$Assumptions = True},
  TrueQ[TimeConstrained[Quiet[Check[rawAlgebraicQ[e], False]], 5, False]]];
CertifiedEqualQ[a_, b_] := Block[{$Assumptions = True},
  TrueQ[TimeConstrained[Quiet[Check[
    rawAlgebraicQ[a] && rawAlgebraicQ[b] && RootReduce[a - b] === 0,
    False]], 5, False]]];

(* All internal costly operations share the dynamic request deadline. *)
SetAttributes[bounded, HoldAll];
bounded[body_, allowance_] := Module[{left, result, budget},
  left = $deadline - AbsoluteTime[];
  If[left <= 0, $stop = "TimeBudget"; Throw[Null, $stopTag]];
  budget = Min[allowance, left];
  result = TimeConstrained[Quiet[Check[body, $Failed]], budget, $operationTimedOut];
  If[result === $operationTimedOut,
    $operationTimeouts++; Return[$Failed]];
  result
];
SetAttributes[operation, HoldAll];
operation[body_] := bounded[body, $cfg["OperationTime"]];
algebraicQ[e_] := TrueQ[bounded[rawAlgebraicQ[e], $cfg["CertifyTime"]]];
certify[a_, b_] := TrueQ[bounded[
  rawAlgebraicQ[a] && rawAlgebraicQ[b] && RootReduce[a - b] === 0,
  $cfg["CertifyTime"]]];
smallQ[e_] := FreeQ[e, Indeterminate | ComplexInfinity | _DirectedInfinity] &&
  LeafCount[e] <= $cfg["MaxLeafCount"];

(* The single acceptance boundary. It is used AFTER each proposed polish. *)
acceptCandidate[candidate_, original_, incumbent_, method_] := Module[{ok},
  If[candidate === $Failed || !smallQ[candidate] || !radicalExpressionQ[candidate],
    Return[incumbent]];
  If[!cheaperQ[candidate, incumbent], Return[incumbent]];
  ok = certify[candidate, original];
  If[!ok, $rejected++; Return[incumbent]];
  AppendTo[$pendingCertificates, <|"Before" -> original, "After" -> candidate,
    "Method" -> method, "Verifier" -> "RootReduce", "Residual" -> 0|>];
  If[TrueQ[$cfg["Verbose"]], Print["Certified rewrite (", method, "): ", candidate]];
  candidate
];

rationalizedCandidate[e_] := Module[{z, n, d, x, p, coefficients, q},
  z = operation[Together[e]];
  If[z === $Failed, Return[$Failed]];
  n = Numerator[z]; d = Denominator[z];
  If[d === 1, Return[z]];
  If[!algebraicQ[d] || certify[d, 0], Return[$Failed]];
  p = operation[MinimalPolynomial[d, x]];
  If[p === $Failed || !PolynomialQ[p, x], Return[$Failed]];
  coefficients = CoefficientList[p, x];
  If[Length[coefficients] < 2 || First[coefficients] === 0, Return[$Failed]];
  q = operation[-n Sum[coefficients[[j + 1]] d^(j - 1),
      {j, 1, Length[coefficients] - 1}]/First[coefficients]];
  q
];

(* Extract a real quadratic-field element as a + b Sqrt[c]. The coefficient
   is absorbed into c via the square of the single nonrational summand;
   this avoids brittle Orderless/Flat coefficient patterns. *)
quadraticParts[e_] := Module[{z, terms, rs, ns, a, t, c, b},
  z = operation[Expand[e]]; If[z === $Failed, Return[$Failed]];
  terms = If[Head[z] === Plus, List @@ z, {z}];
  rs = Select[terms, rationalQ]; ns = Select[terms, !rationalQ[#] &];
  If[Length[ns] =!= 1, Return[$Failed]];
  a = Total[rs]; t = First[ns];
  c = operation[RootReduce[t^2]];
  If[!rationalQ[c] || !TrueQ[c > 0], Return[$Failed]];
  b = operation[Sign[t]];
  If[!MemberQ[{-1, 1}, b] || !certify[t, b Sqrt[c]], Return[$Failed]];
  {a, b, c}
];

realQuadraticSquareRoot[a_, b_, c_] := Module[{value, delta, d, h, res},
  value = a + b Sqrt[c];
  If[TrueQ[operation[value < 0]],
    res = realQuadraticSquareRoot[-a, -b, c];
    Return[If[res === $Failed, $Failed, I res]]];
  If[!TrueQ[operation[value >= 0]], Return[$Failed]];
  delta = a^2 - b^2 c;
  If[TrueQ[delta >= 0],
    d = Sqrt[delta];
    If[rationalQ[d] && TrueQ[a >= d],
      Return[Sqrt[(a + d)/2] + Sign[b] Sqrt[(a - d)/2]]]];
  If[TrueQ[delta < 0] && b > 0,
    h = Sqrt[b^2 - a^2/c];
    If[rationalQ[h],
      Return[c^(1/4) (Sqrt[(b + h)/2] + Sign[a] Sqrt[(b - h)/2])]]];
  $Failed
];

quadraticCubicRoots[a_, b_, c_] := Module[{norm, q, x, f, fl, ts, v},
  norm = a^2 - b^2 c; q = Surd[norm, 3];
  If[!rationalQ[q], Return[{}]];
  f = x^3 - 3 q x - 2 a;
  fl = operation[FactorList[f]];
  If[!ListQ[fl], Return[{}]];
  ts = Cases[fl, {p_, _Integer} /; PolynomialQ[p, x] && Exponent[p, x] === 1 :>
      -Coefficient[p, x, 0]/Coefficient[p, x, 1]];
  DeleteCases[Table[
    If[!rationalQ[t] || t^2 - q === 0, $Failed,
      v = b/(t^2 - q);
      If[TrueQ[(t/2)^2 - c v^2 == q], t/2 + v Sqrt[c], $Failed]],
    {t, ts}], $Failed]
];

cheapPowerCandidates[e_] := Module[{p, r, numerator, parts, root, roots, a, b, c, norm},
  If[!MatchQ[e, Power[_, _Rational]], Return[{}]];
  p = e[[2]]; r = Denominator[p]; numerator = Numerator[p];
  If[!MemberQ[{2, 3}, r], Return[{}]];
  If[r === 2 && Head[e[[1]]] === Complex,
    a = Re[e[[1]]]; b = Im[e[[1]]]; norm = Sqrt[a^2 + b^2];
    If[rationalQ[a] && rationalQ[b] && rationalQ[norm],
      Return[{(Sqrt[(norm + a)/2] + I Sign[b] Sqrt[(norm - a)/2])^numerator}]]];
  parts = quadraticParts[e[[1]]]; If[parts === $Failed, Return[{}]];
  {a, b, c} = parts;
  If[r === 2,
    root = realQuadraticSquareRoot[a, b, c];
    Return[If[root === $Failed, {}, {root^numerator}]]];
  roots = quadraticCubicRoots[a, b, c];
  (* Integer powers are safe. The phase orbit selects the principal Power,
     including negative real radicands; real Surd is not silently substituted. *)
  Flatten[Table[((-1)^(2 k/3) root)^numerator,
    {root, roots}, {k, 0, 2}], 1]
];

reductionIndex[e_] := Module[{d, nodes, r = 1, den},
  d = RadicalDepth[e];
  nodes = Select[Cases[e, Power[_, _Rational], {0, Infinity}],
    RadicalDepth[#] === d &];
  Do[den = Denominator[node[[2]]]; r = LCM[r, den];
    If[r > $cfg["MaxRootIndex"], Return[0]], {node, nodes}];
  r
];

(* This queue deliberately replaces, rather than reproduces, the original
   history-sensitive scheduler. Its cap includes 1 and user multipliers.
   Invariant: Length[queue] <= MultiplierCap, before AND after every insertion. *)
multiplierSearch[e_, incumbent_] := Module[
  {r, a, x, queue = {}, seen = <||>, cursor = 1, best = incumbent,
   enqueue, offer, m, p, degree, g, dg, roots, candidate, pol, disc,
   fl, primes, terms, fs, complement, proposed = 0, cap, forced, can},
  cap = $cfg["MultiplierCap"];
  If[cap === 0 || $cfg["MaxTrials"] === 0 || $cfg["MaxCandidates"] === 0,
    Return[best]];
  r = reductionIndex[e]; If[r < 2, Return[best]];
  a = operation[e^r]; If[a === $Failed, Return[best]];
  enqueue[value_] := Module[{normalized, id},
    If[Length[queue] >= cap, Return[Null]];
    If[!smallQ[value] || !algebraicQ[value], Return[Null]];
    normalized = operation[RootReduce[value]];
    If[normalized === $Failed || normalized === 0, Return[Null]];
    id = ToString[normalized, InputForm];
    If[!KeyExistsQ[seen, id],
      AssociateTo[seen, id -> True]; AppendTo[queue, value]; $enqueued++];
    Null
  ];
  offer[value_, method_] := If[proposed < $cfg["MaxCandidates"],
    proposed++; $candidates++;
    best = acceptCandidate[value, e, best, method]];
  forced = $cfg["Multipliers"];
  If[ListQ[forced],
    Do[If[Length[queue] >= cap, Break[]]; enqueue[value], {value, forced}],
    enqueue[1];
    pol = operation[Expand[a]];
    If[pol =!= $Failed && smallQ[pol],
      terms = If[Head[pol] === Plus, List @@ pol, {pol}];
      Do[If[Length[queue] >= cap, Break[]];
        fs = If[Head[term] === Times, List @@ term, {term}];
        complement = operation[Times @@ (Replace[#,
            {Power[base_, exponent_Rational] :>
              base^(Mod[-Numerator[exponent], Denominator[exponent]]/Denominator[exponent]),
             _ -> 1}] & /@ fs)];
        If[complement =!= $Failed, enqueue[complement]], {term, terms}]]];
  While[cursor <= Length[queue] && proposed < $cfg["MaxCandidates"],
    If[$trials >= $cfg["MaxTrials"], $trialLimit = True; Break[]];
    m = queue[[cursor]]; cursor++; $trials++;
    p = operation[MinimalPolynomial[(m a)^(1/r), x]];
    If[p === $Failed || !PolynomialQ[p, x] || !smallQ[p], Continue[]];
    degree = Exponent[p, x];
    If[degree > $cfg["MaxDegree"], $degreeSkips++; Continue[]];
    (* No current-best-degree gate: every admitted multiplier gets this stage. *)
    g = operation[PolynomialGCD[p, x^r - m a, Extension -> Automatic]];
    If[g =!= $Failed && PolynomialQ[g, x],
      dg = Exponent[g, x];
      If[0 < dg < r,
        roots = If[dg === 1,
          {-Coefficient[g, x, 0]/Coefficient[g, x, 1]},
          operation[x /. Solve[g == 0, x]]];
        If[ListQ[roots],
          Do[
            If[proposed >= $cfg["MaxCandidates"], Break[]];
            Do[
              If[proposed >= $cfg["MaxCandidates"], Break[]];
              candidate = operation[(-1)^(2 k/r) root/m^(1/r)];
              If[candidate =!= $Failed,
                offer[candidate, "MultiplierOrbit"];
                If[proposed < $cfg["MaxCandidates"] && smallQ[candidate],
                  can = operation[ToRadicals[candidate]];
                  If[can =!= $Failed && can =!= candidate,
                    offer[can, "MultiplierOrbit/ToRadicals"]]]],
              {k, 0, r - 1}], {root, roots}]]]];
    (* Stream prime powers; never form Divisors or a Cartesian product. *)
    If[forced === Automatic && Length[queue] < cap,
      disc = operation[Discriminant[p, x]];
      If[IntegerQ[disc] && disc =!= 0,
        fl = operation[FactorInteger[Abs[disc]]];
        If[ListQ[fl],
          primes = First /@ fl;
          Do[If[Length[queue] >= cap, Break[]];
            If[TrueQ[operation[PrimeQ[prime]]],
              Do[If[Length[queue] >= cap, Break[]]; enqueue[m prime^j],
                {j, 1, r - 1}]], {prime, primes}]]]];
  ];
  best
];

improveNumeric[e_] := Module[{best = e, cand, candidates, reduced, solver},
  If[!smallQ[e], Return[e]];
  If[RadicalDepth[e] < 2 && FreeQ[e, _Root | _AlgebraicNumber] &&
    !MatchQ[e, Power[_Complex, _Rational]] &&
    $cfg["Solver"] === Automatic && !TrueQ[$cfg["Factor"]], Return[e]];
  If[!algebraicQ[e], Return[e]];
  candidates = cheapPowerCandidates[e];
  Do[best = acceptCandidate[cand, e, best, "QuadraticField"], {cand, candidates}];
  (* RootReduce can discover global cancellation. Its opaque output is not
     accepted merely because its syntactic radical depth is zero. *)
  reduced = operation[RootReduce[e]];
  If[reduced =!= $Failed,
    best = acceptCandidate[reduced, e, best, "RootReduce/radical-output"]];
  If[TrueQ[$cfg["Factor"]],
    cand = operation[FactorTerms[e]];
    best = acceptCandidate[cand, e, best, "FactorTerms"]];
  solver = $cfg["Solver"];
  If[solver =!= Automatic,
    cand = operation[solver[e]];
    best = acceptCandidate[cand, e, best, "CustomSolver"]];
  If[!FreeQ[e, _Root | _AlgebraicNumber],
    cand = operation[ToRadicals[e]];
    best = acceptCandidate[cand, e, best, "ToRadicals"]];
  If[solver === Automatic && RadicalDepth[e] >= 2 && RadicalDepth[best] >= 2,
    best = multiplierSearch[e, best]];
  best
];

(* Pure arithmetic congruence only: unknown/held heads are not traversed.
   Symbols in hosts are never simplified using ambient assumptions. *)
walk[e_] := Module[{h, rebuilt},
  If[AtomQ[e], Return[e]];
  h = Head[e];
  If[MemberQ[{Root, AlgebraicNumber}, h], Return[improveNumeric[e]]];
  If[!MemberQ[{Plus, Times, Power, List}, h], Return[e]];
  If[h === Power && !rationalQ[e[[2]]], Return[e]];
  rebuilt = If[h === Power, Power[walk[e[[1]]], e[[2]]], Map[walk, e]];
  If[h === List, Return[rebuilt]];
  If[!FreeQ[rebuilt, _Real] || !NumericQ[rebuilt], Return[rebuilt]];
  improveNumeric[rebuilt]
];

run[e_, cfg_Association, mode_] := Block[
  {$cfg = cfg, $deadline, $stopTag = Unique["requestStop$"], $stop = "Completed",
   $operationTimedOut = Unique["operationTimeout$"], $operationTimeouts = 0,
   $trials = 0, $enqueued = 0, $candidates = 0, $rejected = 0, $degreeSkips = 0,
   $trialLimit = False, $pendingCertificates = {}, $Assumptions = True},
  Module[{start = AbsoluteTime[], committed = {e, {}},
    current, passes, pass, previous, result, report},
    $deadline = start + cfg["TimeBudget"];
    If[cfg["TimeBudget"] === 0 || TrueQ[cfg["TimeBudget"] == 0],
      $stop = "TimeBudget",
      result = TimeConstrained[
        MemoryConstrained[
          Catch[
            If[!smallQ[e], $stop = "InputSize"; Throw[Null, $stopTag]];
            passes = If[TrueQ[cfg["AllLevels"]], cfg["MaxPasses"], 1];
            Do[
              $pendingCertificates = {}; previous = committed[[1]];
              current = Switch[mode,
                "Core", improveNumeric[previous],
                "Factor", If[algebraicQ[previous],
                  acceptCandidate[operation[FactorTerms[previous]], previous, previous, "FactorTerms"], previous],
                "Rationalize", If[algebraicQ[previous],
                  Module[{cand = rationalizedCandidate[previous]},
                    If[cand =!= $Failed && smallQ[cand] && radicalExpressionQ[cand] && certify[cand, previous],
                      AppendTo[$pendingCertificates, <|"Before" -> previous, "After" -> cand,
                        "Method" -> "RationalizeDenominator", "Verifier" -> "RootReduce", "Residual" -> 0|>];
                      cand, previous]], previous],
                _, walk[previous]
              ];
              If[current === previous, Break[]];
              If[!smallQ[current] || (mode =!= "Rationalize" && !cheaperQ[current, previous]), Break[]];
              (* Finish the numeric whole-input certificate before committing.
                 Symbolic arithmetic/List hosts rely on local congruence. *)
              If[rawAlgebraicQ[previous] && !certify[current, previous], Break[]];
              If[AbsoluteTime[] >= $deadline, $stop = "TimeBudget"; Throw[Null, $stopTag]];
              committed = {current, Join[committed[[2]], $pendingCertificates]},
              {pass, passes}],
            $stopTag],
          cfg["MemoryBudget"], $stop = "MemoryBudget"; Null],
        cfg["TimeBudget"], $stop = "TimeBudget"; Null]
    ];
    report = <|"Expression" -> committed[[1]],
      "Outcome" -> If[committed[[1]] === e, "Unchanged", If[mode === "Rationalize", "Rewritten", "Improved"]],
      "SearchStatus" -> $stop, "TrialLimitReached" -> $trialLimit,
      "OperationTimeouts" -> $operationTimeouts, "DegreeSkips" -> $degreeSkips,
      "MultiplierTrials" -> $trials, "MultipliersEnqueued" -> $enqueued,
      "OrbitCandidates" -> $candidates, "RejectedEqualities" -> $rejected,
      "ElapsedSeconds" -> AbsoluteTime[] - start,
      "Certificates" -> committed[[2]],
      "NativeValidation" -> "Pending; see accompanying test suite"|>;
    If[TrueQ[cfg["DetailedResult"]], report, committed[[1]]]
  ]
];

entry[head_, e_, rules_List, mode_] := Module[{cfg = resolveOptions[head, rules]},
  If[FailureQ[cfg], cfg, run[e, cfg, mode]]];
Strad[e_, opts : OptionsPattern[]] := entry[Strad, e, {opts}, "Walk"];
Strad[e_, all : (True | False), opts : OptionsPattern[]] :=
  entry[Strad, e, {"AllLevels" -> all, opts}, "Walk"];
DenestRadicals[e_, opts : OptionsPattern[]] := entry[DenestRadicals, e, {opts}, "Walk"];
DenestRadicals[e_, all : (True | False), opts : OptionsPattern[]] :=
  entry[DenestRadicals, e, {"AllLevels" -> all, opts}, "Walk"];
DenestCore[e_, opts : OptionsPattern[]] := entry[DenestCore, e, {opts}, "Core"];
Factorc[e_, opts : OptionsPattern[]] := entry[Factorc, e, {opts}, "Factor"];
RationalizeDenominator[e_, opts : OptionsPattern[]] :=
  entry[RationalizeDenominator, e, {opts}, "Rationalize"];

End[];
EndPackage[];
