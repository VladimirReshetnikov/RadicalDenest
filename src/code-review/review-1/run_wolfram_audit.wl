(* Regression contracts for the UNMODIFIED supplied source.
   NOT EXECUTED in a Wolfram kernel during this review.
   Some tests are EXPECTED TO FAIL: they expose defects, rather than documenting
   correct existing behavior. Run only in a fresh/disposable kernel because
   original.wl clears global definitions and unprotects System`Print.
   Invocation: wolframscript -file run_wolfram_audit.wl
   The original Print attributes are restored on normal completion or Abort. *)
ClearAll[auditEqualQ, auditEval];
auditEqualQ[a_, b_] :=
  TrueQ[Quiet[Check[RootReduce[a - b] === 0, False]]];
SetAttributes[auditEval, HoldAll];
auditEval[expr_] :=
  TimeConstrained[Block[{$Output = {}}, Quiet[expr]], 20, $TimedOut];

Module[{dir, savedPrintAttributes, report, protectionOK},
 dir = DirectoryName[$InputFileName];
 savedPrintAttributes = Attributes[Print];
 CheckAbort[
  Get[FileNameJoin[{dir, "original.wl"}]];
  protectionOK = MemberQ[Attributes[Print], Protected];
  report = TestReport[{
    VerificationTest[protectionOK, True,
      TestID -> "loading-preserves-Print-protection"],
    VerificationTest[(#1[[1]] <= #[[2]] &)[{2, 1}, {3, 1}], True,
      TestID -> "prime-comparator-orders-2-before-3"],
    VerificationTest[
      auditEqualQ[RationalizeDenominator[1/(1 + Sqrt[2])],
        Sqrt[2] - 1], True, TestID -> "rationalizer-real"],
    VerificationTest[
      auditEqualQ[RationalizeDenominator[1/(1 + I)], (1 - I)/2],
      True, TestID -> "rationalizer-complex"],
    VerificationTest[
      auditEqualQ[auditEval[denest11[Sqrt[3 + 2 Sqrt[2]], {1}]],
        1 + Sqrt[2]], True, TestID -> "direct-denesting-success"],
    VerificationTest[
      auditEqualQ[auditEval[denest11[Sqrt[5 + 2 Sqrt[6]], {2}]],
        Sqrt[2] + Sqrt[3]], True,
      TestID -> "rational-multiplier-success"],
    VerificationTest[
      auditEqualQ[auditEval[denest11[-Sqrt[3 + 2 Sqrt[2]], {1}]],
        -1 - Sqrt[2]], True, TestID -> "negative-original-branch"],
    VerificationTest[
      auditEqualQ[auditEval[denest11[
        Sqrt[-1 + 2 I Sqrt[2]] Sqrt[-2 + 2 I Sqrt[3]], {1}]],
        (1 + I Sqrt[2]) (1 + I Sqrt[3])],
      True, TestID -> "grouped-complex-original-branch"],
    VerificationTest[
      auditEqualQ[auditEval[DenestRadicals3[
        Sqrt[-1 + 2 I Sqrt[2]] Sqrt[-2 + 2 I Sqrt[3]]]],
        (1 + I Sqrt[2]) (1 + I Sqrt[3])],
      True, TestID -> "public-wrapper-complex-product"],
    VerificationTest[
      Module[{t}, auditEqualQ[
        auditEval[Factorc[Sqrt[t^2]]] /. t -> -2, 2]],
      True, TestID -> "nested-power-symbolic-branch"],
    VerificationTest[
      Module[{t}, auditEqualQ[
        auditEval[Factorc[Sqrt[t + t^2]]] /. t -> -2, Sqrt[2]]],
      True, TestID -> "factored-sum-symbolic-branch"],
    VerificationTest[
      MatchQ[auditEval[denest11[Sqrt[3 + 2 Sqrt[2]], {0}]], _Failure],
      True, TestID -> "zero-multiplier-controlled-rejection"],
    VerificationTest[
      auditEqualQ[auditEval[denest11[Sqrt[3 + 2 Sqrt[2]], {}]],
        Sqrt[3 + 2 Sqrt[2]]], True, TestID -> "empty-seed-list-no-change"],
    VerificationTest[
      auditEqualQ[auditEval[DenestRadicals3[
        Sqrt[3 + 2 Sqrt[2]], True]], 1 + Sqrt[2]],
      True, TestID -> "alllevels-basic-correctness"]
    }];
  Attributes[Print] = savedPrintAttributes;
  Print[report];
  Print["Kernel version: ", $Version];,
  Attributes[Print] = savedPrintAttributes;
  Abort[]
  ]
 ];
