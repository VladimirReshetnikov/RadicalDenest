(* Predicted source-level regressions for StradFixed.wl, NOT EXECUTED here.
   Load the exact source snapshot under review FIRST, in a clean kernel.
   Use the returned values to confirm/refute the corresponding static claims.
   These probes do not assert facts about the unretrieved DenestCore body. *)
Clear[x];
a = Sqrt[5 + 2 Sqrt[6]];
Print["bad solver on a symbolic host: ",
  RadicalDenest`DenestRadicals[x + a, "Solver" -> Function[z, 0]]];
Print["same bad solver, entirely numeric host: ",
  RadicalDenest`DenestRadicals[a, "Solver" -> Function[z, 0]]];
Print["ambient assumption probe: ",
  Block[{$Assumptions = x > 0}, RadicalDenest`DenestRadicals[Sqrt[x^2]]]];
Print["advertised and actual cost arity: ",
  {RadicalDenest`RadicalCost::usage, Length[RadicalDenest`RadicalCost[a]]}];
(* Instrument, rather than time, the custom callback to inspect the boundary. *)
callbackCalls = 0;
Print["zero TimeBudget does not wrap the callback: ",
  RadicalDenest`DenestRadicals[a, "TimeBudget" -> 0,
    "Solver" -> Function[z, callbackCalls++; z]]];
Print["callback calls: ", callbackCalls];
(* This helper-level input demonstrates an insufficient aggregate-phase guard.
   It does NOT establish reachability from an ordinary public Factorc input. *)
Print["combine helper with positive aggregate factor: ",
  RadicalDenest`Private`combine[
    {{{-1, 2}, {2, 1}}, {{-1, 2}, {3, 1}}}, 1/2]];
