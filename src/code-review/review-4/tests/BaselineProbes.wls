#!/usr/bin/env wolframscript
(* Diagnostic probes for the PINNED BASELINE, not pass assertions for the new
   package. Run in a fresh kernel:
     wolframscript -file tests/BaselineProbes.wls /path/to/StradFixed.wl
   These probes were not executed during preparation. No HTTP code is loaded.
*)
Module[{arguments, baseline, x, e, value, saved, cap3, cap2},
  arguments = Rest[$ScriptCommandLine];
  If[Length[arguments] =!= 1,
    Print["Supply a local path to the pinned StradFixed.wl."]; Exit[2]];
  baseline = First[arguments];
  If[! FileExistsQ[baseline], Print["File not found: ", baseline]; Exit[2]];
  Get[baseline];
  Print["Kernel: ", $Version];
  Print["PolynomialQ[$Failed,x] = ", PolynomialQ[$Failed, x]];
  e = x + Sqrt[5 + 2 Sqrt[6]];
  value = TimeConstrained[RadicalDenest`Strad[e,
      "Solver" -> (0 &), "Factor" -> False], 30, $Aborted];
  Print["Untrusted solver in symbolic host: ", InputForm[value]];
  cap3 = Block[{RadicalDenest`Private`$cap = 1,
      RadicalDenest`Private`$visited = <||>},
    RadicalDenest`Private`newMultipliers[{1, (#^2 - # - 1 &), 2}, Null, 3]];
  cap2 = Block[{RadicalDenest`Private`$cap = 1,
      RadicalDenest`Private`$visited = <||>},
    RadicalDenest`Private`newMultipliers[{1, (#^2 - # - 16 &), 2}, Null, 2]];
  Print["Cap 1, q 3, discriminant 5: ", InputForm[cap3]];
  Print["Cap 1, q 2, discriminant 65: ", InputForm[cap2]];
  saved = Options[RadicalDenest`Strad];
  SetOptions[RadicalDenest`Strad, "Solver" -> (0 &), "Factor" -> False];
  value = TimeConstrained[RadicalDenest`Strad[e], 30, $Aborted];
  SetOptions[RadicalDenest`Strad, Sequence @@ saved];
  Print["Same solver supplied using SetOptions[Strad]: ", InputForm[value]];
  Print["Compare the preceding result with the explicit-option result."];
]
