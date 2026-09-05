(* Run with: wolframscript -file run_tests.wl
   Original-source tests intentionally assert desired behavior.
   The original source is expected to fail several assertions. *)
auditBase = DirectoryName[$InputFileName];
auditPrintAttributesBefore = Attributes[Print];
Get[FileNameJoin[{auditBase, "source.wl"}]];
auditPrintAttributesAfter = Attributes[Print];
Get[FileNameJoin[{auditBase, "safe_candidate_kernel.wl"}]];

SetAttributes[AuditEvaluate, HoldAll];
AuditEvaluate[expr_] := TimeConstrained[
  Quiet[Check[Block[{Print = (Null &)}, expr], $Failed]],
  30, $Aborted];

auditReport = CheckAbort[
  TestReport[FileNameJoin[{auditBase, "regression_tests.wlt"}]],
  $Aborted];

(* The source alters only protection, but restore the full attribute set. *)
Unprotect[Print];
Attributes[Print] = auditPrintAttributesBefore;
Print["Kernel: ", $Version];
Print[auditReport];
Put[{$Version, auditReport},
  FileNameJoin[{auditBase, "wolfram_test_report.wl"}]];
