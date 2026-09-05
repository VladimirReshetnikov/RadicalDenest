(* Native Wolfram tests: supplied, NOT EXECUTED in the review environment.
   Run using tests/run_tests.wls; assertions on unchanged outputs never assert
   non-denestability. Tests compare values, not a preferred printed formula. *)

VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`Strad[Sqrt[5 + 2 Sqrt[6]]], Sqrt[2] + Sqrt[3]],
 True, TestID -> "direct-square-value"]
VerificationTest[
 RadicalDenestImproved`RadicalDepth[RadicalDenestImproved`Strad[Sqrt[5 + 2 Sqrt[6]]]],
 1, TestID -> "direct-square-depth"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`Strad[Sqrt[4 + 3 Sqrt[2]]], 2^(1/4) (1 + Sqrt[2])],
 True, TestID -> "indirect-fourth-root-value"]
VerificationTest[
 RadicalDenestImproved`RadicalDepth[RadicalDenestImproved`Strad[Sqrt[4 + 3 Sqrt[2]]]],
 1, TestID -> "indirect-fourth-root-depth"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`Strad[Sqrt[3 - 2 Sqrt[2]]], Sqrt[2] - 1],
 True, TestID -> "small-positive-branch"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`Strad[Sqrt[-5 - 2 Sqrt[6]]], I (Sqrt[2] + Sqrt[3])],
 True, TestID -> "negative-radicand-principal-square-root"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`Strad[(41 - 29 Sqrt[2])^(1/5)], (41 - 29 Sqrt[2])^(1/5)],
 True, TestID -> "principal-fifth-power-preserved"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[1 - Sqrt[2], (41 - 29 Sqrt[2])^(1/5)],
 False, TestID -> "real-fifth-root-is-not-principal-power"]
VerificationTest[
 Module[{x, a = Sqrt[5 + 2 Sqrt[6]], y},
  y = RadicalDenestImproved`Strad[x + a, "Solver" -> Function[z, 0]];
  RadicalDenestImproved`CertifiedEqualQ[y - x, a]],
 True, TestID -> "bad-zero-solver-in-symbolic-host-rejected"]
VerificationTest[
 Module[{x, a = Sqrt[5 + 2 Sqrt[6]], y},
  y = RadicalDenestImproved`Strad[x + a, "Solver" -> Function[z, $Failed]];
  FreeQ[y, $Failed] && RadicalDenestImproved`CertifiedEqualQ[y - x, a]],
 True, TestID -> "failed-solver-does-not-leak"]
VerificationTest[
 Module[{x, a = Sqrt[5 + 2 Sqrt[6]], y},
  y = RadicalDenestImproved`Strad[x + a, "Solver" -> Function[z, 1.41421356237]];
  FreeQ[y, _Real] && RadicalDenestImproved`CertifiedEqualQ[y - x, a]],
 True, TestID -> "approximate-solver-does-not-leak"]
VerificationTest[
 Module[{x}, Block[{$Assumptions = x > 0},
  SameQ[RadicalDenestImproved`Strad[Sqrt[x^2]], Sqrt[x^2]]]],
 True, TestID -> "ambient-assumptions-do-not-rewrite-host"]
VerificationTest[
 Module[{x, h}, SameQ[RadicalDenestImproved`Strad[h[Sqrt[5 + 2 Sqrt[6]]]],
 h[Sqrt[5 + 2 Sqrt[6]]]]], True, TestID -> "unknown-head-is-opaque"]
VerificationTest[
 RadicalDenestImproved`ExactAlgebraicQ[Pi], False, TestID -> "transcendental-constant-rejected"]
VerificationTest[
 RadicalDenestImproved`ExactAlgebraicQ[Sqrt[2] + 3^(1/3)], True,
 TestID -> "explicit-algebraic-grammar"]
VerificationTest[
 RadicalDenestImproved`EqualityStatus[Sqrt[2], -Sqrt[2]], "Different",
 TestID -> "conjugates-distinguished"]
VerificationTest[
 RadicalDenestImproved`EqualityStatus[Sqrt[2], Sqrt[2], 0], "Unknown",
 TestID -> "zero-certification-budget-is-unknown"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], r},
  r = RadicalDenestImproved`DenestReport[a, {"TimeBudget" -> 0}];
  {r["Value"] === a, r["Trials"], r["Status"]}],
 {True, 0, "Disabled"}, TestID -> "zero-total-budget-is-noop"]
VerificationTest[
 RadicalDenestImproved`DenestReport[Sqrt[5 + 2 Sqrt[6]], "MaxTrials" -> -1]["Status"],
 "InvalidOptions", TestID -> "invalid-integer-option"]
VerificationTest[
 RadicalDenestImproved`DenestReport[Sqrt[5 + 2 Sqrt[6]], "TimeBudget" -> "bad"]["Status"],
 "InvalidOptions", TestID -> "invalid-time-option"]
VerificationTest[
 RadicalDenestImproved`DenestReport[Sqrt[5 + 2 Sqrt[6]], "UnknownOption" -> 1]["Status"],
 "InvalidOptions", TestID -> "unknown-option-rejected"]
VerificationTest[
 Module[{defaults, a = Sqrt[5 + 2 Sqrt[6]], result},
  defaults = Options[RadicalDenestImproved`Strad];
  Internal`WithLocalSettings[
   SetOptions[RadicalDenestImproved`Strad, "TimeBudget" -> 0],
   result = RadicalDenestImproved`Strad[a],
   Options[RadicalDenestImproved`Strad] = defaults];
  SameQ[result, a]], True, TestID -> "SetOptions-on-alias-is-honored"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], r},
  r = RadicalDenestImproved`DenestReport[a, "MaxTrials" -> 0];
  r["Trials"] === 0 && RadicalDenestImproved`CertifiedEqualQ[r["Value"], a]],
 True, TestID -> "zero-trials-disables-only-multiplier-search"]
VerificationTest[
 Module[{a = {Sqrt[2 + Sqrt[2]], Sqrt[3 + Sqrt[3]]}, r},
  r = RadicalDenestImproved`DenestReport[a, "MaxTrials" -> 1];
  r["Trials"] <= 1], True, TestID -> "shared-list-trial-budget"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], b},
  b = RadicalDenestImproved`Strad[a, True];
  SameQ[RadicalDenestImproved`Strad[b, True], b]],
 True, TestID -> "simple-idempotence"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], mixed},
  mixed = {1.0, a}; SameQ[RadicalDenestImproved`Strad[mixed], mixed]],
 True, TestID -> "inexact-tree-policy-is-conservative"]
VerificationTest[
 RadicalDenestImproved`CertifiedEqualQ[
  RadicalDenestImproved`RationalizeDenominator[1/(1 + Sqrt[2])], Sqrt[2] - 1],
 True, TestID -> "rationalization-certificate"]
VerificationTest[
 Module[{x}, SameQ[RadicalDenestImproved`Factorc[Sqrt[x^2]], Sqrt[x^2]]],
 True, TestID -> "factor-helper-refuses-symbolic-transform"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], r},
  r = RadicalDenestImproved`DenestReport[a, "Multipliers" -> {0, Pi, 1.0, 2}];
  RadicalDenestImproved`CertifiedEqualQ[r["Value"], a]],
 True, TestID -> "invalid-seeds-do-not-change-value"]
VerificationTest[
 Module[{a = Sqrt[5 + 2 Sqrt[6]], r},
  r = RadicalDenestImproved`DenestReport[a, "MaxRecords" -> 0];
  r["LocalRecords"] === {} && RadicalDenestImproved`CertifiedEqualQ[r["Value"], a]],
 True, TestID -> "bounded-certificate-records"]
VerificationTest[
 Module[{a = (2^(1/3) - 1)^(1/3), b},
  b = RadicalDenestImproved`DenestCore[a, "Multipliers" -> {9}, "Factor" -> False];
  RadicalDenestImproved`CertifiedEqualQ[b, a] && RadicalDenestImproved`RadicalDepth[b] == 1],
 True, TestID -> "ramanujan-cubic-multiplier-nine"]
