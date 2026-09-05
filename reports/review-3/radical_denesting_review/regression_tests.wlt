(* UNEXECUTED Wolfram regression assertions.
   Run through run_tests.wl in a fresh kernel.
   Several tests are EXPECTED TO FAIL for the original source.
   AuditEvaluate times out each evaluation and suppresses diagnostics. *)

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[denest11[Sqrt[5 + 2 Sqrt[6]], {2}]],
    Sqrt[2] + Sqrt[3]], True,
  TestID -> "Original: classical forced multiplier succeeds"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[denest11[-Sqrt[5 + 2 Sqrt[6]], {2}]],
    -Sqrt[2] - Sqrt[3]], True,
  TestID -> "Original F1: preserve a negative direct-core target"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[denest11[(-1 + 2 I Sqrt[2])^(3/2), {1}]],
    -5 + I Sqrt[2]], True,
  TestID -> "Original F1: preserve a complex three-halves power"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[denest11[
      Sqrt[-1 + 2 I Sqrt[2]] Sqrt[-2 + 2 I Sqrt[3]], {1}]],
    (1 + I Sqrt[2]) (1 + I Sqrt[3])], True,
  TestID -> "Original F1: preserve a merged product in the core"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[DenestRadicals3[
      Sqrt[-1 + 2 I Sqrt[2]] Sqrt[-2 + 2 I Sqrt[3]],
      False, Function[t, denest11[t, {1}]]]],
    (1 + I Sqrt[2]) (1 + I Sqrt[3])], True,
  TestID -> "Original F1: wrapper product integration"]

VerificationTest[
  AuditEvaluate[Module[{x, y, original, changed},
    original = Sqrt[-x - y];
    changed = Factorc[original];
    RootReduce[(changed - original) /. {x -> -1, y -> -1}] === 0]],
  True, TestID -> "Original F2: symbolic factorization preserves branches"]

VerificationTest[
  Module[{original = Sqrt[5 + 2 Sqrt[6]], result},
    result = AuditEvaluate[denest11[original, {0}]];
    MatchQ[result, _Failure] ||
      RadicalDenestingAudit`ExactAlgebraicEqualQ[result, original]],
  True, TestID -> "Original F5: invalid multiplier has a safe outcome"]

VerificationTest[
  (#1[[1]] <= #[[2]] &)[{2, 1}, {3, 1}], True,
  TestID -> "Original F3: verbatim prime comparator orders increasing primes"]

VerificationTest[
  AuditEvaluate[Module[{p = {2, 3, 5, 7, 11, 0}},
    p = DeleteCases[p, 0][[1 ;; Min[10, Length[p]]]];
    p]], {2, 3, 5, 7, 11},
  TestID -> "Original F4: verbatim stale-length slice is safe"]

VerificationTest[
  10^Max[5, Ceiling[Log[1000]/Log[10]]] - 1 <= 1000,
  True, TestID -> "Original F7: nominal multiplier cap is respected"]

VerificationTest[
  auditPrintAttributesBefore === auditPrintAttributesAfter,
  True, TestID -> "Original F10: loading preserves Print attributes"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[RationalizeDenominator[1/(Sqrt[2] + Sqrt[3])]],
    Sqrt[3] - Sqrt[2]], True,
  TestID -> "Original: reciprocal identity with a quartic denominator"]

VerificationTest[
  RadicalDenestingAudit`ExactAlgebraicEqualQ[
    AuditEvaluate[RationalizeDenominator[1/(1 + I Sqrt[2])]],
    (1 - I Sqrt[2])/3], True,
  TestID -> "Original: reciprocal identity with a complex denominator"]

VerificationTest[
  AuditEvaluate[denest11[2 + Sqrt[3]]] === 2 + Sqrt[3],
  True, TestID -> "Original: unchanged nonnested input"]

VerificationTest[
  And @@ Table[
    RadicalDenestingAudit`ExactAlgebraicEqualQ[
      AuditEvaluate[DenestRadicals3[
        Sqrt[7 + 2 Sqrt[5 + 2 Sqrt[6]]], mode, Identity]],
      Sqrt[7 + 2 Sqrt[5 + 2 Sqrt[6]]]],
    {mode, {False, True}}], True,
  TestID -> "Original: wrapper modes preserve value with Identity solver"]

VerificationTest[
  Module[{r = RadicalDenestingAudit`TryDenestCandidate[
      -Sqrt[5 + 2 Sqrt[6]], 2, 2]},
    AssociationQ[r] && r["Status"] === "Candidate" &&
      Length[r["Candidates"]] >= 1 &&
      AllTrue[r["Candidates"],
        RadicalDenestingAudit`ExactAlgebraicEqualQ[
          #, -Sqrt[2] - Sqrt[3]] &]],
  True, TestID -> "Proposed kernel: negative branch is certified"]

VerificationTest[
  Module[{r = RadicalDenestingAudit`TryDenestCandidate[
      (-1 + 2 I Sqrt[2])^(3/2), 2, 1]},
    AssociationQ[r] && r["Status"] === "Candidate" &&
      Length[r["Candidates"]] >= 1 &&
      AllTrue[r["Candidates"],
        RadicalDenestingAudit`ExactAlgebraicEqualQ[#,-5+I Sqrt[2]] &]],
  True, TestID -> "Proposed kernel: three-halves branch is certified"]

VerificationTest[
  MatchQ[RadicalDenestingAudit`TryDenestCandidate[
    Sqrt[5 + 2 Sqrt[6]], 2, 0], _Failure],
  True, TestID -> "Proposed kernel: reject zero multiplier"]

VerificationTest[
  MatchQ[RadicalDenestingAudit`TryDenestCandidate[
    Sqrt[5 + 2 Sqrt[6]], 1, 2], _Failure],
  True, TestID -> "Proposed kernel: reject invalid root order"]

VerificationTest[
  MatchQ[RadicalDenestingAudit`TryDenestCandidate[
    Sqrt[5 + 2 Sqrt[6]], 2, 2.0], _Failure],
  True, TestID -> "Proposed kernel: reject inexact multiplier"]
