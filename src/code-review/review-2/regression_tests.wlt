(* Proposed regression tests. NOT executed in a Wolfram kernel for this audit.
   Run in a fresh disposable kernel. Several tests are expected to FAIL on
   original.wl: their expectations state the intended preservation contract.
   The original file unprotects Print; this suite restores its prior attributes.
*)
ClearAll[auditBounded, auditEqual, auditPrintAttributesBefore,
  auditPrintAttributesAfter, auditDirectory];
SetAttributes[auditBounded, HoldFirst];
auditBounded[expr_] := TimeConstrained[expr, 20, $Aborted];
auditEqual[a_, b_] := TrueQ[Quiet[Check[RootReduce[a - b] === 0, False]]];
auditDirectory = DirectoryName[$InputFileName];
auditPrintAttributesBefore = Attributes[Print];
Get[FileNameJoin[{auditDirectory, "original.wl"}]];
auditPrintAttributesAfter = Attributes[Print];
Attributes[Print] = auditPrintAttributesBefore;

VerificationTest[
 auditPrintAttributesAfter, auditPrintAttributesBefore,
 TestID -> "Loading must not change Print attributes"]

VerificationTest[
 (#1[[1]] <= #[[2]] &)[{2, 1}, {3, 1}], True,
 TestID -> "Prime comparator must compare the two primes"]

VerificationTest[
 auditEqual[auditBounded[denest11[-Sqrt[3 + 2 Sqrt[2]], {1}]],
   -1 - Sqrt[2]], True,
 TestID -> "Direct denest11 must preserve a negative original branch"]

VerificationTest[
 auditEqual[auditBounded[DenestRadicals3[(-1 + 2 I Sqrt[2])^(3/2)]],
   -5 + I Sqrt[2]], True,
 TestID -> "Public wrapper must preserve a complex 3/2 power"]

VerificationTest[
 auditEqual[auditBounded[DenestRadicals3[
   Sqrt[-1 + 2 I Sqrt[2]] Sqrt[-2 + 2 I Sqrt[3]]]],
   (1 + I Sqrt[2]) (1 + I Sqrt[3])], True,
 TestID -> "Merged square roots must preserve the original product branch"]

VerificationTest[
 Module[{z}, (Factorc[Sqrt[z^2]] /. z -> -1)], 1,
 TestID -> "Factorc must not flatten a symbolic square under a square root"]

(* Explicit Global`f is intentional: it tests the original placeholder name. *)
ClearAll[Global`f];
VerificationTest[
 auditBounded[DenestRadicals3[Global`f[1], False, Identity]], Global`f[1],
 TestID -> "Caller function f must not be consumed as an internal marker"]

ClearAll[Global`x];
VerificationTest[
 Simplify[RationalizeDenominator[Global`x/(1 + Sqrt[2])] -
   Global`x/(1 + Sqrt[2])] === 0, True,
 TestID -> "Rationalization must preserve a numerator named x"]

VerificationTest[
 auditEqual[auditBounded[DenestRadicals3[Sqrt[5 + 2 Sqrt[6]]]],
   Sqrt[2] + Sqrt[3]], True,
 TestID -> "Positive real worked example preserves value"]

VerificationTest[
 auditEqual[RationalizeDenominator[1/(1 + Sqrt[2])], Sqrt[2] - 1], True,
 TestID -> "Minimal-polynomial denominator rationalization"]

VerificationTest[
 auditEqual[auditBounded[DenestRadicals3[
    Sqrt[3 + 2 Sqrt[3 + 2 Sqrt[2]]], True]],
    Sqrt[3 + 2 Sqrt[3 + 2 Sqrt[2]]]], True,
 TestID -> "All-level traversal preserves nested value"]

Get[FileNameJoin[{auditDirectory, "safer_core.wl"}]];
VerificationTest[
 MatchQ[RadicalAudit`CertifiedMultiplierStep[Sqrt[3 + 2 Sqrt[2]], 2, 0],
   _Failure], True,
 TestID -> "Guarded step rejects zero multiplier"]

VerificationTest[
 MatchQ[RadicalAudit`CertifiedMultiplierStep[Sqrt[2], 1, 1], _Failure], True,
 TestID -> "Guarded step rejects root order one"]

VerificationTest[
 Module[{r = RadicalAudit`CertifiedMultiplierStep[
     -Sqrt[3 + 2 Sqrt[2]], 2, 1]},
   AssociationQ[r] && r["Candidates"] =!= {} &&
    AllTrue[r["Candidates"], auditEqual[#, -1 - Sqrt[2]] &]], True,
 TestID -> "Guarded step certifies the original negative target"]

VerificationTest[
 Module[{r = RadicalAudit`CertifiedMultiplierStep[
     (-1 + 2 I Sqrt[2])^(3/2), 2, 1]},
   AssociationQ[r] && r["Candidates"] =!= {} &&
    AllTrue[r["Candidates"], auditEqual[#, -5 + I Sqrt[2]] &]], True,
 TestID -> "Guarded step certifies the original complex target"]
