(* ::Package:: *)
(* StradImproved.wl -- proposed, conservatively certified denesting engine.
   Review baseline: RadicalDenest commit
     6d7739bda3478f0d9cd70ffb9f7c49ee2576bee7
   This is a separate implementation, not an in-place patch to StradFixed.wl.
   Native Wolfram Language execution was NOT available during preparation.
   Run tests/RunTests.wls in a fresh kernel before adopting this package.

   Semantics: principal complex Power; exact numerical algebraic islands;
   inert mathematical Plus/Times/Power/List hosts only. Unknown/held heads
   are deliberately opaque. Callbacks are proposals, never proof oracles.
   Each public denesting call has one session budget across list elements
   and passes. Limits are cooperative kernel limits, not a security sandbox.
*)

BeginPackage["RadicalDenestImproved`"];

Strad::usage = "Strad[expr, opts] conservatively denests exact algebraic radicals. Strad[expr, True, opts] enables inner-first, repeated passes.";
DenestRadicals::usage = "DenestRadicals[expr, opts] is the option-driven denester. Unknown heads are opaque; symbolic hosts are not globally simplified.";
DenestCore::usage = "DenestCore[expr, opts] searches one exact algebraic target without traversing its symbolic host.";
DenestReport::usage = "DenestReport[expr, opts] returns an Association containing Result, Status, Limits, Statistics, Options, and bounded Trace.";
ExactAlgebraicQ::usage = "ExactAlgebraicQ[expr] recognizes supported exact explicit algebraic arithmetic, conservatively and with a time limit.";
CertifiedEqualQ::usage = "CertifiedEqualQ[a,b] returns True only after exact algebraic certification; False also includes unsupported or undecided inputs.";
RadicalDepth::usage = "RadicalDepth[expr] measures rational-power nesting, treating Root and AlgebraicNumber representations as opaque.";
RadicalCost::usage = "RadicalCost[expr] gives {opaque algebraic objects, radical depth, rational-power nodes, LeafCount, integer bit size}.";
Factorc::usage = "Factorc[expr] offers a bounded Factor proposal for an exact algebraic number, accepting it only if certified equal and cheaper. Symbolic inputs are unchanged.";
RationalizeDenominator::usage = "RationalizeDenominator[expr] uses a certified polynomial inverse for an exact algebraic denominator. Failure returns expr; this helper need not reduce RadicalCost.";

Options[Strad] = Options[DenestRadicals] = Options[DenestCore] =
 Options[DenestReport] = {
   "AllLevels" -> False, "Verbose" -> False, "Multipliers" -> Automatic,
   "MaxTrials" -> 400, "TimeBudget" -> 120, "MultiplierCap" -> 1000,
   "CertifyTime" -> 20, "Solver" -> Automatic, "Factor" -> True,
   "OperationTime" -> 5, "MemoryBudget" -> 268435456,
   "MaxRootOrder" -> 32, "MaxPolynomialDegree" -> 64,
   "MaxLeafCount" -> 20000, "MaxIntegerBits" -> 65536,
   "MaxPasses" -> 4, "UseToRadicals" -> True,
   "UseDiscriminants" -> True, "PrimeLimit" -> 8, "BatchSize" -> 32,
   "Trace" -> False, "MaxTraceEntries" -> 128
 };

Begin["`Private`"];

$active = False;
$defaultOptions = Options[DenestRadicals];
$cfg = Association[$defaultOptions];
$deadline = Infinity;
$stats = <||>; $limits = <||>; $events = {};

(* ---------- Session, option validation, and failure boundaries ---------- *)

newStats[] := <|"Trials" -> 0, "Operations" -> 0,
  "OperationTimeouts" -> 0, "OperationFailures" -> 0,
  "Certificates" -> 0, "CertificatesProved" -> 0,
  "CertificatesRejected" -> 0, "CertificatesUndecided" -> 0,
  "CandidatesAccepted" -> 0, "MultiplierProposals" -> 0,
  "MultipliersAdmitted" -> 0, "DuplicateMultipliers" -> 0,
  "PassesCompleted" -> 0|>;

bump[key_String] := AssociateTo[$stats, key -> (Lookup[$stats, key, 0] + 1)];
limitHit[key_String] := AssociateTo[$limits, key -> True];
remaining[] := Max[0, $deadline - AbsoluteTime[]];
expiredQ[] := If[remaining[] <= 0, limitHit["TimeBudget"]; True, False];

note[tag_String, data_: <||>] := (
  If[TrueQ[$cfg["Verbose"]], Print["[RadicalDenestImproved] ", tag]];
  If[TrueQ[$cfg["Trace"]] && Length[$events] < $cfg["MaxTraceEntries"],
    AppendTo[$events, <|"Event" -> tag, "Data" -> data|>]];
);

SetAttributes[bounded, HoldAll];
bounded[body_, kind_: "Operation"] := Module[{seconds, value},
  seconds = Min[remaining[], If[kind === "Certificate",
      $cfg["CertifyTime"], $cfg["OperationTime"]]];
  If[seconds <= 0,
    limitHit[If[remaining[] <= 0, "TimeBudget",
      If[kind === "Certificate", "CertifyTime", "OperationTime"]]];
    Return[$Failed]];
  bump["Operations"];
  value = Quiet[Check[
     TimeConstrained[body, seconds, operationTimedOut], operationFailed]];
  Which[
    value === operationTimedOut,
      bump["OperationTimeouts"]; note["OperationTimeout"];
      limitHit[If[kind === "Certificate", "CertifyTime", "OperationTime"]];
      If[remaining[] <= 0, limitHit["TimeBudget"]]; $Failed,
    value === operationFailed || value === $Failed || value === $Aborted,
      bump["OperationFailures"]; note["OperationFailure"]; $Failed,
    True, value
  ]
];

finiteNonnegativeQ[v_] := (IntegerQ[v] || Head[v] === Rational ||
    Head[v] === Real) && TrueQ[0 <= v < Infinity];
nonnegativeIntegerQ[v_] := IntegerQ[v] && v >= 0;
positiveIntegerQ[v_] := IntegerQ[v] && v >= 1;
booleanQ[v_] := v === True || v === False;

resolveOptions[head_Symbol, raw_List] := Module[{rules, names, unknown, cfg,
    nonneg, positive, times, bools, bad},
  rules = Flatten[raw]; names = First /@ Options[head];
  If[! AllTrue[rules, MatchQ[#, _Rule | _RuleDelayed] &],
    Return[Failure["InvalidOption", <|"MessageTemplate" ->
      "Options must be rules or lists of rules."|>]]];
  unknown = Complement[First /@ rules, names];
  If[unknown =!= {}, Return[Failure["UnknownOption", <|"Keys" -> unknown|>]]];
  (* OptionValue resolves each head's effective defaults, not just explicit
     rules. In particular, SetOptions[Strad,...] is not silently discarded. *)
  cfg = Association[Table[With[{name = key},
    name -> OptionValue[head, rules, name]], {key, names}]];
  nonneg = {"MaxTrials", "MultiplierCap", "MaxTraceEntries"};
  positive = {"MemoryBudget", "MaxRootOrder", "MaxPolynomialDegree",
    "MaxLeafCount", "MaxIntegerBits", "MaxPasses", "PrimeLimit", "BatchSize"};
  times = {"TimeBudget", "OperationTime", "CertifyTime"};
  bools = {"AllLevels", "Verbose", "Factor", "UseToRadicals",
    "UseDiscriminants", "Trace"};
  bad = Join[
    Select[nonneg, ! nonnegativeIntegerQ[cfg[#]] &],
    Select[positive, ! positiveIntegerQ[cfg[#]] &],
    Select[times, ! finiteNonnegativeQ[cfg[#]] &],
    Select[bools, ! booleanQ[cfg[#]] &]];
  If[! (cfg["Multipliers"] === Automatic || ListQ[cfg["Multipliers"]]),
    AppendTo[bad, "Multipliers"]];
  If[bad =!= {}, Return[Failure["InvalidOption", <|"Keys" -> bad,
    "MessageTemplate" -> "Invalid option values; all limits must be finite."|>]]];
  cfg
];

(* Standalone predicates/helpers get a separate 20-second budget. Inside a
   denesting call the same helpers use the existing, shared session. *)
SetAttributes[standalone, HoldAll];
standalone[body_, failure_] := If[TrueQ[$active], body,
  Block[{$active = True, $cfg = Association[$defaultOptions],
      $deadline = AbsoluteTime[] + 20, $stats = newStats[],
      $limits = <||>, $events = {}, $Assumptions = True},
    TimeConstrained[MemoryConstrained[body, 268435456, failure], 20, failure]]
];

(* ---------- Explicit algebraic grammar and representation metrics ---------- *)

rationalQ[e_] := IntegerQ[e] || Head[e] === Rational;
opaqueQ[e_] := MatchQ[e, _Root | _AlgebraicNumber];
arithmeticHeadQ[e_] := MemberQ[{Plus, Times, Power}, Head[e]];

algebraicFormQ[e_] := Which[
  rationalQ[e], True,
  Head[e] === Complex, rationalQ[Re[e]] && rationalQ[Im[e]],
  opaqueQ[e], True,
  MemberQ[{Plus, Times}, Head[e]], AllTrue[List @@ e, algebraicFormQ],
  Head[e] === Power && Length[e] === 2 && rationalQ[Last[e]],
    algebraicFormQ[First[e]],
  True, False
];

exactQ[e_] := algebraicFormQ[e] && TrueQ[bounded[
   NumericQ[e] && Precision[e] === Infinity && Element[e, Algebraics],
   "Certificate"]];
ExactAlgebraicQ[e_] := standalone[exactQ[e], False];

(* Unknown heads are opaque for traversal and radical metrics. Root payloads
   are charged as algebraic objects, not as radical formula subtrees. *)
shape[e_] := Module[{children, s, isRadical},
  If[opaqueQ[e], Return[{1, 0, 0}]];
  If[AtomQ[e] || ! MemberQ[{Plus, Times, Power, List}, Head[e]],
    Return[{0, 0, 0}]];
  children = List @@ e;
  If[children === {}, Return[{0, 0, 0}]];
  s = shape /@ children;
  isRadical = If[MatchQ[e, Power[_, _Rational]], 1, 0];
  {Total[s[[All, 1]]], Max[Prepend[s[[All, 2]], 0]] + isRadical,
    Total[s[[All, 3]]] + isRadical}
];

(* Integer/Rational atoms count their actual bit sizes, not just one leaf.
   LeafCount remains a separate, earlier component of the objective. *)
bitSize[e_] := Total[Cases[e,
    n_Integer :> 1 + IntegerLength[Abs[n], 2], {0, Infinity}]] +
  Total[Cases[e, r_Rational :>
    2 + IntegerLength[Abs[Numerator[r]], 2] +
      IntegerLength[Denominator[r], 2], {0, Infinity}]] +
  Total[Cases[e, z_Complex :> bitSize[Re[z]] + bitSize[Im[z]],
    {0, Infinity}]];
RadicalDepth[e_] := shape[e][[2]];
RadicalCost[e_] := With[{s = shape[e]},
  {s[[1]], s[[2]], s[[3]], LeafCount[e], bitSize[e]}];
cheaperQ[a_, b_] := Order[RadicalCost[a], RadicalCost[b]] === 1;
smallQ[e_] := If[LeafCount[e] > $cfg["MaxLeafCount"] ||
    bitSize[e] > $cfg["MaxIntegerBits"], limitHit["ExpressionSize"]; False, True];

certified[a_, b_] := Module[{r},
  bump["Certificates"];
  If[! smallQ[a] || ! smallQ[b] || ! exactQ[a] || ! exactQ[b],
    bump["CertificatesUndecided"]; Return[False]];
  If[a === b, bump["CertificatesProved"]; Return[True]];
  r = bounded[RootReduce[a - b], "Certificate"];
  Which[
    r === 0, bump["CertificatesProved"]; True,
    r === $Failed || ! FreeQ[r, RootReduce],
      bump["CertificatesUndecided"]; False,
    True, bump["CertificatesRejected"]; False
  ]
];
CertifiedEqualQ[a_, b_] := standalone[certified[a, b], False];

choose[target_, best_, candidate_, method_String] := Module[{},
  If[candidate === $Failed || candidate === $Aborted ||
      ! algebraicFormQ[candidate] || ! smallQ[candidate] ||
      ! cheaperQ[candidate, best], Return[best]];
  If[certified[candidate, target],
    bump["CandidatesAccepted"];
    note[method, <|"BeforeCost" -> RadicalCost[best],
      "AfterCost" -> RadicalCost[candidate]|>]; candidate,
    best]
];

validPolynomialQ[p_, x_, minimum_Integer : 1] := Module[{degree},
  If[! FreeQ[p, $Failed | $Aborted | operationFailed | operationTimedOut] ||
      ! smallQ[p] || ! TrueQ[PolynomialQ[p, x]], Return[False]];
  degree = Exponent[p, x];
  If[! IntegerQ[degree] || degree < minimum, Return[False]];
  If[degree > $cfg["MaxPolynomialDegree"],
    limitHit["PolynomialDegree"]; Return[False]];
  True
];

(* ---------- Certified algebraic inversion and conservative factoring ---------- *)

rationalizeRaw[e_] := Module[{t, numerator, denominator, x, p, c, inv},
  t = bounded[Together[e]];
  If[t === $Failed, Return[e]];
  numerator = Numerator[t]; denominator = Denominator[t];
  If[rationalQ[denominator] || ! smallQ[denominator] || ! exactQ[denominator],
    Return[e]];
  p = bounded[MinimalPolynomial[denominator, x]];
  If[! validPolynomialQ[p, x], Return[e]];
  c = CoefficientList[p, x];
  If[! AllTrue[c, rationalQ] || First[c] === 0, Return[e]];
  (* p(d)=0 implies d^(-1)=-(a1+a2 d+...+an d^(n-1))/a0.
     Horner evaluation avoids polynomial division over a moving extension. *)
  inv = bounded[-Fold[#1 denominator + #2 &, Last[c],
      Reverse[Rest[Most[c]]]]/First[c]];
  If[inv === $Failed || ! certified[denominator inv, 1], Return[e]];
  t = bounded[Expand[numerator inv]];
  If[t === $Failed || ! smallQ[t], e, t]
];
RationalizeDenominator[e_] := standalone[rationalizeRaw[e], e];

factorSafe[e_] := If[! smallQ[e] || ! exactQ[e], e,
  choose[e, e, bounded[Factor[e]], "Factor"]];
Factorc[e_] := standalone[factorSafe[e], e];

polish[target_, best_, candidate_] := Module[{b = best, t},
  If[candidate === $Failed || ! algebraicFormQ[candidate] ||
      ! smallQ[candidate], Return[b]];
  b = choose[target, b, candidate, "AlgebraicCandidate"];
  t = bounded[Simplify[candidate, Assumptions -> True]];
  b = choose[target, b, t, "SimplifyCandidate"];
  If[TrueQ[$cfg["Factor"]],
    b = choose[target, b, bounded[Factor[candidate]], "FactorCandidate"]];
  b
];

(* ---------- Exact low-degree constructions ---------- *)

quadraticParts[rho_] := Module[{e, radicals, root, c, x, polynomial, a, b},
  e = bounded[Expand[rho]];
  If[e === $Failed, Return[$Failed]];
  radicals = DeleteDuplicates[Cases[e,
    r : Power[c_?rationalQ, Rational[1, 2]] /; c > 0 :> r,
    {0, Infinity}]];
  If[Length[radicals] =!= 1, Return[$Failed]];
  root = First[radicals]; c = First[root];
  polynomial = e /. root -> x;
  If[! TrueQ[PolynomialQ[polynomial, x]] || Exponent[polynomial, x] =!= 1,
    Return[$Failed]];
  {a, b} = CoefficientList[polynomial, x];
  If[AllTrue[{a, b, c}, rationalQ], {a, b, c}, $Failed]
];

quadraticSquareCandidates[rho_] := Module[{parts, a, b, c, d, s, u, v,
    e, answer, sign = 1, rr = rho, result = {}},
  If[TrueQ[bounded[rr < 0, "Certificate"]], rr = -rr; sign = I];
  parts = quadraticParts[rr];
  If[parts === $Failed, Return[{}]];
  {a, b, c} = parts; d = a^2 - b^2 c;
  If[a > 0 && d >= 0,
    s = Sqrt[d];
    If[rationalQ[s],
      u = (a + s)/2; v = (a - s)/2;
      If[u >= 0 && v >= 0,
        AppendTo[result, sign (Sqrt[u] + Sign[b] Sqrt[v])]]]];
  (* The indirect criterion is -c d a rational square, NOT +c d. *)
  If[d < 0 && b > 0,
    e = Sqrt[b^2 - a^2/c];
    If[rationalQ[e] && 0 <= e <= b,
      answer = c^(1/4) (Sqrt[(b + e)/2] + Sign[a] Sqrt[(b - e)/2]);
      AppendTo[result, sign answer]]];
  result
];

rationalPolynomialRoots[p_, x_] := Module[{fl, linear, roots},
  If[! validPolynomialQ[p, x], Return[{}]];
  fl = bounded[FactorList[p]];
  If[fl === $Failed || ! ListQ[fl], Return[{}]];
  linear = Cases[fl, {f_, _Integer} /; PolynomialQ[f, x] &&
      Exponent[f, x] === 1 :> f];
  roots = (-Coefficient[#, x, 0]/Coefficient[#, x, 1] &) /@ linear;
  DeleteDuplicates[Select[roots, rationalQ]]
];

cubicQuadraticCandidates[rho_] := Module[{parts, a, b, c, norm, n, x,
    traces, candidates = {}, denominator, beta},
  parts = quadraticParts[rho]; If[parts === $Failed, Return[{}]];
  {a, b, c} = parts;
  norm = a^2 - b^2 c;
  n = Sign[norm] Abs[norm]^(1/3);
  If[! rationalQ[n], Return[{}]];
  traces = rationalPolynomialRoots[x^3 - 3 n x - 2 a, x];
  Do[
    denominator = trace^2 - n;
    If[denominator =!= 0,
      beta = trace/2 + b Sqrt[c]/denominator;
      (* A real negative cube root is not principal Power. The exact gate
         selects the correct root from this small roots-of-unity orbit. *)
      Do[AppendTo[candidates, beta (-1)^(2 k/3)], {k, 0, 2}]],
    {trace, traces}];
  candidates
];

honsbeekCandidates[rho_] := Module[{terms, a, b, ratio, t, roots,
    denominator, numerator, result = {}},
  If[Head[rho] =!= Plus || Length[rho] =!= 2, Return[{}]];
  terms = List @@ rho;
  If[! And @@ (TrueQ[bounded[Element[#, Reals], "Certificate"]] & /@ terms),
    Return[{}]];
  {a, b} = bounded[RootReduce[#^3], "Certificate"] & /@ terms;
  If[! AllTrue[{a, b}, rationalQ] || a === 0 || b === 0, Return[{}]];
  ratio = b/a;
  roots = rationalPolynomialRoots[t^4 + 4 t^3 + 8 ratio t - 4 ratio, t];
  Do[
    denominator = b - s^3 a;
    If[denominator > 0,
      numerator = -s^2 terms[[1]]^2/2 +
        s terms[[1]] terms[[2]] + terms[[2]]^2;
      AppendTo[result, numerator/Sqrt[denominator]];
      AppendTo[result, -numerator/Sqrt[denominator]]],
    {s, roots}];
  result
];

fastRoot[rho_, q_Integer] := Module[{candidates = {}, sq, rest, target},
  If[q === 1, Return[rho]];
  If[q > $cfg["MaxRootOrder"] || q < 1, Return[$Failed]];
  target = bounded[rho^(1/q)];
  If[target === $Failed, Return[$Failed]];
  If[rationalQ[rho], Return[target]];
  Which[
    q === 2,
      candidates = Join[quadraticSquareCandidates[rho], honsbeekCandidates[rho]],
    q === 3,
      candidates = cubicQuadraticCandidates[rho],
    EvenQ[q],
      sq = fastRoot[rho, 2];
      If[sq =!= $Failed,
        rest = fastRoot[sq, q/2];
        candidates = {If[rest === $Failed, sq^(2/q), rest]}]
  ];
  candidates = Select[DeleteDuplicates[candidates], certified[#, target] &];
  If[candidates === {}, $Failed, First[SortBy[candidates, RadicalCost]]]
];

fastPower[e_] := Module[{q, p, root},
  If[! MatchQ[e, Power[_, _Rational]], Return[$Failed]];
  p = Numerator[Last[e]]; q = Denominator[Last[e]];
  If[q > $cfg["MaxRootOrder"], limitHit["RootOrder"]; Return[$Failed]];
  root = fastRoot[First[e], q];
  If[root === $Failed, $Failed, bounded[root^p]]
];

(* ---------- A bounded FIFO multiplier search, with lazy finite batches ---------- *)

reductionOrder[e_] := Module[{nodes, d, q = 1},
  d = RadicalDepth[e];
  nodes = Select[Cases[e, Power[_, _Rational], {0, Infinity}],
      RadicalDepth[#] === d &];
  Do[
    q = LCM[q, Denominator[Last[node]]];
    If[q > $cfg["MaxRootOrder"], limitHit["RootOrder"]; Return[$Failed]],
    {node, nodes}];
  If[q < 2, $Failed, q]
];

complement[Power[b_, r_Rational]] := b^(Mod[-Numerator[r], Denominator[r]]/
    Denominator[r]);
complement[_] := 1;

multiplierSearch[target_, initialBest_] := Module[
  {best = initialBest, q, rho, queue = {}, seen = <||>, admitted = 0,
   proposed = 0, cursor = 1, cap = $cfg["MultiplierCap"], proposalCap,
   add, seeds, m, x, theta, p, gcd, gd, roots, mroot, candidate, degree,
   disc, factors, primes, digits, batchAttempts, j, k, z, r},
  If[cap === 0 || $stats["Trials"] >= $cfg["MaxTrials"],
    If[cap === 0, limitHit["MultiplierCap"], limitHit["MaxTrials"]];
    Return[best]];
  q = reductionOrder[target]; If[q === $Failed, Return[best]];
  rho = bounded[target^q]; If[rho === $Failed, Return[best]];
  proposalCap = 4 cap;
  (* This closure is the ONLY queue insertion point. It caps total admission,
     counts invalid/duplicate proposals too, and uses exact semantic keys. *)
  add[value_] := Module[{canonical, key},
    If[admitted >= cap, limitHit["MultiplierCap"]; Return[False]];
    If[proposed >= proposalCap, limitHit["MultiplierProposals"]; Return[False]];
    proposed++; bump["MultiplierProposals"];
    If[! smallQ[value] || ! exactQ[value], Return[False]];
    canonical = bounded[RootReduce[value], "Certificate"];
    If[canonical === $Failed || canonical === 0 || ! algebraicFormQ[canonical],
      Return[False]];
    key = With[{v = canonical}, HoldComplete[v]];
    If[KeyExistsQ[seen, key], bump["DuplicateMultipliers"]; Return[False]];
    AssociateTo[seen, key -> True]; AppendTo[queue, value];
    admitted++; bump["MultipliersAdmitted"]; True
  ];
  If[ListQ[$cfg["Multipliers"]],
    seeds = $cfg["Multipliers"],
    seeds = Join[{1, -1, 2, 3},
      Take[Cases[rho, Power[_, _Rational], {0, Infinity}], UpTo[cap]] /. 
        r : Power[_, _Rational] :> complement[r]]];
  Do[
    If[admitted >= cap || proposed >= proposalCap || expiredQ[], Break[]];
    add[seed], {seed, seeds}];
  While[cursor <= Length[queue] && ! expiredQ[],
    If[$stats["Trials"] >= $cfg["MaxTrials"], limitHit["MaxTrials"]; Break[]];
    m = queue[[cursor]]; cursor++; bump["Trials"];
    theta = bounded[RootReduce[m rho], "Certificate"];
    If[theta === $Failed, Continue[]];
    p = bounded[MinimalPolynomial[theta^(1/q), x]];
    If[! validPolynomialQ[p, x],
      note["MinimalPolynomialRejected"]; Continue[]];
    degree = Exponent[p, x];
    note["Trial", <|"Trial" -> $stats["Trials"], "Degree" -> degree,
      "RootOrder" -> q|>];
    (* The coefficient field is explicitly Q(theta), not an accidental
       extension generated by syntactically separate coefficients. *)
    gcd = bounded[PolynomialGCD[p, x^q - theta, Extension -> {theta}]];
    If[validPolynomialQ[gcd, x],
      gd = Exponent[gcd, x];
      If[gd < q,
        roots = If[gd === 1,
          {-Coefficient[gcd, x, 0]/Coefficient[gcd, x, 1]},
          r = bounded[Solve[gcd == 0, x]];
          If[ListQ[r], x /. r, {}]];
        If[TrueQ[$cfg["UseToRadicals"]],
          r = bounded[ToRadicals[roots]];
          If[ListQ[r], roots = r]];
        mroot = bounded[m^(1/q)];
        If[mroot =!= $Failed,
          (* No Outer/Flatten allocation of the full roots-of-unity orbit. *)
          Do[
            If[expiredQ[], Break[]];
            Do[
              If[expiredQ[], Break[]];
              candidate = bounded[z/mroot (-1)^(2 k/q)];
              best = polish[target, best, candidate],
              {k, 0, q - 1}],
            {z, roots}]]]];
    If[RadicalDepth[best] <= 1 && shape[best][[1]] === 0, Break[]];
    If[TrueQ[$cfg["UseDiscriminants"]] && admitted < cap &&
        proposed < proposalCap && ! expiredQ[],
      disc = bounded[Discriminant[p, x]];
      If[IntegerQ[disc] && disc =!= 0,
        factors = bounded[FactorInteger[Abs[disc]]];
        If[ListQ[factors],
          primes = Take[Cases[factors, {prime_Integer, _Integer} /;
              prime > 1 :> prime], UpTo[$cfg["PrimeLimit"]]];
          batchAttempts = 0;
          Do[
            If[admitted >= cap || proposed >= proposalCap ||
                batchAttempts >= $cfg["BatchSize"] || expiredQ[], Break[]];
            batchAttempts++; add[m prime], {prime, primes}];
          (* Enumerate only a bounded prefix of mixed-radix exponent vectors.
             Even when q^Length[primes] is large, that product set is NEVER built. *)
          j = 1;
          While[primes =!= {} && j < q^Length[primes] &&
              batchAttempts < $cfg["BatchSize"] && admitted < cap &&
              proposed < proposalCap && ! expiredQ[],
            digits = IntegerDigits[j, q, Length[primes]]; j++; batchAttempts++;
            add[m Times @@ MapThread[Power, {primes, digits}]]]]]];
  ];
  If[admitted >= cap, limitHit["MultiplierCap"]];
  If[proposed >= proposalCap, limitHit["MultiplierProposals"]];
  If[$stats["Trials"] >= $cfg["MaxTrials"], limitHit["MaxTrials"]];
  best
];

(* ---------- Numeric target processing and marker-free host traversal ---------- *)

improveNumber[target_] := Module[{best = target, t, solver},
  If[! smallQ[target] || ! exactQ[target], Return[target]];
  If[RadicalDepth[target] < 2 && shape[target][[1]] === 0, Return[target]];
  t = fastPower[target]; best = choose[target, best, t, "LowDegreeFormula"];
  solver = $cfg["Solver"];
  If[solver =!= Automatic,
    t = bounded[Catch[solver[target], _, Function[{value, tag}, $Failed]]];
    best = polish[target, best, t]];
  If[TrueQ[$cfg["UseToRadicals"]] && shape[target][[1]] > 0,
    best = choose[target, best, bounded[ToRadicals[target]], "ToRadicals"]];
  best = choose[target, best,
    bounded[Simplify[target, Assumptions -> True]], "SimplifyNumber"];
  If[TrueQ[$cfg["Factor"]],
    best = choose[target, best, bounded[Factor[target]], "FactorNumber"]];
  If[solver === Automatic && RadicalDepth[best] >= 2 && ! expiredQ[],
    best = multiplierSearch[target, best]];
  best
];

walk[e_] := Module[{r = e, numeric},
  If[expiredQ[], Return[e]];
  If[opaqueQ[e], Return[improveNumber[e]]];
  If[AtomQ[e], Return[e]];
  If[Head[e] === List, Return[walk /@ e]];
  If[! arithmeticHeadQ[e], Return[e]];
  numeric = smallQ[e] && exactQ[e];
  If[TrueQ[$cfg["AllLevels"]] || ! numeric ||
      ! MatchQ[e, Power[_, _Rational]], r = Map[walk, e]];
  If[numeric, improveNumber[r], r]
];

runSession[e_, config_Association, coreOnly_: False] :=
 Block[{$active = True, $cfg = config, $deadline = AbsoluteTime[] + config["TimeBudget"],
    $stats = newStats[], $limits = <||>, $events = {}, $Assumptions = True},
  Module[{snapshot = {e, Missing["NotComputed"]}, candidate,
      initialCost = Missing["NotComputed"], outcome,
      started = AbsoluteTime[], passes, status, result},
    passes = If[TrueQ[config["AllLevels"]] && ! TrueQ[coreOnly],
      config["MaxPasses"], 1];
    If[TrueQ[config["TimeBudget"] == 0], limitHit["TimeBudget"],
      outcome = TimeConstrained[
        MemoryConstrained[
          initialCost = RadicalCost[e]; snapshot = {e, initialCost};
          Do[
            If[expiredQ[], Break[]];
            candidate = If[TrueQ[coreOnly], improveNumber[First[snapshot]],
              walk[First[snapshot]]];
            bump["PassesCompleted"];
            (* Local numerical certificates compose through arithmetic/List
               hosts. A separate whole-pass cost check is still necessary:
               lexicographic maximum-depth costs are not compositional. *)
            If[candidate === First[snapshot] ||
                ! cheaperQ[candidate, First[snapshot]], Break[]];
            If[algebraicFormQ[e] && ! certified[candidate, e], Break[]];
            (* One assignment publishes value AND cost, after both have been
               computed. Interrupts cannot expose a half-updated snapshot. *)
            snapshot = {candidate, RadicalCost[candidate]};
            If[pass === passes && TrueQ[config["AllLevels"]] && ! TrueQ[coreOnly],
              limitHit["MaxPasses"]],
            {pass, passes}],
          config["MemoryBudget"], memoryStopped],
        config["TimeBudget"], timeStopped];
      If[outcome === memoryStopped, limitHit["MemoryBudget"]];
      If[outcome === timeStopped, limitHit["TimeBudget"]]
    ];
    status = If[First[snapshot] === e, "Unchanged", "Improved"];
    If[Length[$limits] > 0, status = status <> "WithLimits"];
    result = <|"Result" -> First[snapshot], "Status" -> status,
      "EqualityBasis" -> "Exact local certificates and arithmetic congruence",
      "InitialCost" -> initialCost, "FinalCost" -> Last[snapshot],
      "Statistics" -> $stats, "Limits" -> Keys[$limits],
      "ElapsedSeconds" -> (AbsoluteTime[] - started),
      "Options" -> config, "Trace" -> $events,
      "CompletenessClaim" -> False|>;
    result
  ]
];

invoke[e_, head_Symbol, rules_List, report_, core_] := Module[{config, result},
  config = resolveOptions[head, rules];
  If[FailureQ[config], Return[config]];
  result = runSession[e, config, core];
  If[TrueQ[report], result, result["Result"]]
];

Strad[e_, all : (True | False), opts : OptionsPattern[]] :=
  invoke[e, Strad, {"AllLevels" -> all, opts}, False, False];
Strad[e_, opts : OptionsPattern[]] := invoke[e, Strad, {opts}, False, False];
DenestRadicals[e_, all : (True | False), opts : OptionsPattern[]] :=
  invoke[e, DenestRadicals, {"AllLevels" -> all, opts}, False, False];
DenestRadicals[e_, opts : OptionsPattern[]] :=
  invoke[e, DenestRadicals, {opts}, False, False];
DenestCore[e_, opts : OptionsPattern[]] :=
  invoke[e, DenestCore, {opts}, False, True];
DenestReport[e_, opts : OptionsPattern[]] :=
  invoke[e, DenestReport, {opts}, True, False];

End[];
EndPackage[];
