(* ::Package:: *)

(* Equatorial orbits (x = +-1) in the legacy pex and REG solvers, which hold them in the plane and reject forces with a
   theta component there. OsculatingInspiral's equatorial case is tested in OsculatingInspiral.wlt. *)

VerificationTest[
	equatorial = quietStops@GenericKerrpexBL[10^-4, 0.5, 12, 0.3, 1, 0.7, 0, IntegrationLimit -> 20000];
	{equatorial["x"][100.], equatorial["\[Theta]"][100.], equatorial["\[Psi]\[Theta]"][100.]}
	,
	{1, Pi/2, Missing["UndefinedForEquatorialOrbit"]}
	,
	TestID -> "pex, x0 = 1: x stays 1, theta is Pi/2 and psi_theta is undefined"
]

VerificationTest[
	equatorial["Q"][100.]
	,
	0, SameTest -> withinTolerance[10^-12],
	TestID -> "pex, x0 = 1: Carter constant is zero"
]

Table[
	VerificationTest[
		pexSolution = quietStops@GenericKerrpexBL[10^-4, 0.5, 12, 0.3, x0, 0.7, 0, IntegrationLimit -> 20000];
		regSolution = quietStops@GenericKerrREGBL[10^-4, 0.5, 12, 0.3, x0, 0.7, 0, IntegrationLimit -> 20000];
		maxDifference[pexSolution, regSolution, {"p", "e", "r", "\[Phi]"},
			Subdivide[0., 0.95 Min[pexSolution["limit"], regSolution["limit"]], 8]]
		,
		{0, 0, 0, 0}, SameTest -> withinTolerance[10^-3],
		TestID -> "x0 = " <> ToString[x0] <> ": pex and REG agree"
	],
	(* -1. also checks the workaround for KerrGeoSeparatrix, which does not evaluate at x = -1. when a != 0 *)
	{x0, {1, -1.}}]

VerificationTest[
	GenericKerrpexBL[10^-4, 0.5, 12, 0.3, 1, 0, 0, Force -> {0 &, 0 &, 0.1 &, 0 &}]
	,
	$Failed, {KerrOsculatingOrbitalElements::eqforce},
	TestID -> "pex, x0 = 1: a force with a theta component on the plane is rejected"
]

VerificationTest[
	GenericKerrREGBL[10^-4, 0.5, 12, 0.3, 1, 0, 0, Force -> {0 &, 0 &, 0.1 &, 0 &}]
	,
	$Failed, {KerrOsculatingOrbitalElements::eqforce},
	TestID -> "REG, x0 = 1: a force with a theta component on the plane is rejected"
]

VerificationTest[
	(* The theta component 0.1 Sqrt[1 - x^2] Cos[psi_theta] vanishes on the plane *)
	AssociationQ[quietStops@GenericKerrpexBL[10^-4, 0.5, 12, 0.3, 1, 0, 0,
		Force -> {0 &, 0 &, 0.1 Sqrt[1 - #4^2] Cos[#6] &, 0 &}, IntegrationLimit -> 1000]]
	,
	True,
	TestID -> "pex, x0 = 1: a force whose theta component vanishes on the plane is accepted"
]
