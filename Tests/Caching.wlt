(* ::Package:: *)

(* Energy, AngularMomentum and CarterConstant memoise only their most recent value (memoLast). Memoising every call grew without bound over an inspiral. *)

VerificationTest[
	quietStops@GenericKerrpexBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 2000];
	Length[DownValues[#]] & /@ {
		OsculatingOrbitalElements`Private`Energy,
		OsculatingOrbitalElements`Private`AngularMomentum,
		OsculatingOrbitalElements`Private`CarterConstant}
	,
	(* The definitions (2, 2 and 1) plus one cached value each *)
	{3, 3, 2}
	,
	TestID -> "After a solve each function caches only one value"
]

VerificationTest[
	sol = quietStops@GenericKerrpexBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 2000];
	{sol["En"][100.], sol["L"][100.], sol["Q"][100.]}
	,
	Values[KerrGeoConstantsOfMotion[0.5, sol["p"][100.], sol["e"][100.], sol["x"][100.]]]
	,
	SameTest -> withinTolerance[10^-11],
	TestID -> "Constants of motion read from a solution after the solve, with no messages"
]

VerificationTest[
	With[{energy = OsculatingOrbitalElements`Private`Energy},
		{energy[0.5, 10., 0.2, 0.8], energy[0.5, 11., 0.2, 0.8], energy[0.5, 10., 0.2, 0.8]}]
	,
	{KerrGeoEnergy[0.5, 10., 0.2, 0.8], KerrGeoEnergy[0.5, 11., 0.2, 0.8], KerrGeoEnergy[0.5, 10., 0.2, 0.8]}
	,
	SameTest -> withinTolerance[10^-12],
	TestID -> "Alternating arguments never return a stale cached value"
]

VerificationTest[
	OsculatingInspiral[<|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Force" -> ForceModel["GasDrag", "Coefficient" -> 10^-5]|>, IntegrationLimit -> 2000];
	Length[DownValues[OsculatingOrbitalElements`Private`cachedRegularConstants]]
	,
	(* The definition plus one cached value *)
	2
	,
	TestID -> "After an OsculatingInspiral solve the regular constants of motion cache only one value"
]
