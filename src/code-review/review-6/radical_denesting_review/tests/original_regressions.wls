(* Optional source-implied reproductions for the reviewed StradFixed.wl.
   These were NOT run here. Run in a FRESH native kernel, passing the exact
   reviewed original file as a final command-line argument. Do not test an
   unbounded option without the outer watchdog below. *)
args = Rest[$ScriptCommandLine];
If[Length[args]<1, Print["Pass the path to StradFixed.wl."]; Exit[2]];
Get[Last[args]];
Clear[x];
e = x + Sqrt[3+2 Sqrt[2]];
Print["Input: ",e];
Print["Custom zero solver (source predicts incorrect x): ",
  TimeConstrained[RadicalDenest`Strad[e,"Solver"->(0&),"Factor"->False],10,$Aborted]];
(* Pure helper-level cap counterexample; the polynomial has five distinct
   discriminant primes. x^2+2310 has discriminant -9240. *)
Do[
  Print["Cap ",cap," -> ",
    TimeConstrained[
      Block[{RadicalDenest`Private`$cap=cap, RadicalDenest`Private`$visited=<||>},
        RadicalDenest`Private`newMultipliers[{1,Function[z,z^2+2310],2},Null,2]],
      10,$Aborted]],
  {cap,{0,1,7}}];
Print["Infinite cap helper (expected outer timeout): ",
  TimeConstrained[
    Block[{RadicalDenest`Private`$cap=Infinity, RadicalDenest`Private`$visited=<||>},
      RadicalDenest`Private`newMultipliers[{1,Function[z,z^2+2310],2},Null,2]],
    1,$Aborted]];
