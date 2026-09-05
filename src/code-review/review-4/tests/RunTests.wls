#!/usr/bin/env wolframscript
(* Run from any directory: wolframscript -file tests/RunTests.wls.
   Property discovery supports both current and legacy TestReportObject APIs.
   An unknown result schema, empty run, or runtime failure is a failed run. *)
Module[{directory, report, properties, results, outcomes, runtime = {},
    succeeded = 0, failed = 0, total = 0, passed = False,
    summary, path, schema = "Unsupported", expected = 37},
  directory = DirectoryName[$InputFileName];
  Get[FileNameJoin[{directory, "..", "StradImproved.wl"}]];
  report = TestReport[FileNameJoin[{directory, "Regression.wlt"}]];
  If[Head[report] === TestReportObject,
    properties = Quiet[Check[report["Properties"], {}]];
    If[! ListQ[properties], properties = {}];
    Which[
      MemberQ[properties, "Results"] && MemberQ[properties, "ReportSucceeded"],
        schema = "Results/ReportSucceeded";
        results = report["Results"];
        If[ListQ[results],
          outcomes = (#["Outcome"] &) /@ results;
          total = Length[outcomes]; succeeded = Count[outcomes, "Succeeded"];
          failed = total - succeeded];
        If[MemberQ[properties, "RuntimeFailures"], runtime = report["RuntimeFailures"]];
        passed = TrueQ[report["ReportSucceeded"]] && total === expected &&
          failed === 0 && runtime === {},
      And @@ (MemberQ[properties, #] & /@
          {"TestsSucceededCount", "TestsFailedCount"}),
        schema = "LegacyCountProperties";
        succeeded = report["TestsSucceededCount"];
        failed = report["TestsFailedCount"];
        If[IntegerQ[succeeded] && IntegerQ[failed], total = succeeded + failed];
        passed = IntegerQ[succeeded] && IntegerQ[failed] &&
          total === expected && failed === 0,
      True, Null
    ]
  ];
  summary = <|"WolframVersion" -> $Version, "SystemID" -> $SystemID,
    "Schema" -> schema, "ExpectedTests" -> expected,
    "TestsTotal" -> total, "TestsSucceeded" -> succeeded,
    "TestsFailed" -> failed, "RuntimeFailureCount" -> Length[runtime],
    "Passed" -> TrueQ[passed]|>;
  path = FileNameJoin[{directory, "native-results.json"}];
  Export[path, summary, "RawJSON"];
  Print[report]; Print[summary];
  Exit[If[TrueQ[passed], 0, 1]]
]
