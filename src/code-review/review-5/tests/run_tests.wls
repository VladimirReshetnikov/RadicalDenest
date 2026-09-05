(* Run: wolframscript -file tests/run_tests.wls, from any working directory. *)
base = DirectoryName[ExpandFileName[$InputFileName]];
Get[FileNameJoin[{base, "..", "code", "StradImproved.wl"}]];
report = TestReport[FileNameJoin[{base, "regression.wlt"}]];
Print[$Version];
Print[report];
Export[FileNameJoin[{base, "native_test_summary.txt"}],
 ToString[{$Version, report}, InputForm], "Text"];
If[!MatchQ[report, _TestReportObject], Print["No valid TestReportObject was produced."]; Exit[2]];
succeeded = report["TestsSucceededCount"]; failed = report["TestsFailedCount"];
If[!IntegerQ[succeeded] || !IntegerQ[failed] || succeeded + failed =!= 31,
  Print["The complete 31-test suite did not run."]; Exit[2]];
If[failed > 0, Exit[1], Exit[0]];
