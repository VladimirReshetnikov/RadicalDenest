(* Run: wolframscript -file tests/run_tests.wls
   This runner itself awaits a native Wolfram validation run. *)
base = DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]];
source = FileNameJoin[{base,"code","StradImproved.wl"}];
If[!FileExistsQ[source], Print["Package source not found: ",source]; Exit[2]];
loaded = Quiet[Check[Get[source], $Failed]];
If[loaded === $Failed, Print["Package loading failed."]; Exit[2]];
report = TestReport[FileNameJoin[{base,"tests","StradImproved.wlt"}]];
Put[report, FileNameJoin[{base,"verification","native_test_report.wl"}]];
props = report["Properties"];
passed = If[MemberQ[props,"ReportSucceeded"], TrueQ[report["ReportSucceeded"]],
  If[MemberQ[props,"TestsFailedCount"], TrueQ[report["TestsFailedCount"] === 0], False]];
Export[FileNameJoin[{base,"verification","native_run_metadata.json"}],
  <|"NativeWolframExecuted"->True, "WolframVersion"->$Version,
    "SystemID"->$SystemID, "SourceSHA256"->IntegerString[FileHash[source,"SHA256"],16,64],
    "ReportSucceeded"->passed, "AvailableReportProperties"->props|>, "RawJSON"];
Print[report]; Exit[If[passed,0,1]];
