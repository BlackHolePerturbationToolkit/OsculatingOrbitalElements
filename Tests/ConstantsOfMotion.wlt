(* ::Package:: *)

(* The package's own Energy, AngularMomentum and CarterConstant, which the pex and REG solvers use, against KerrGeodesics. *)

constantsOfMotion[a_, p_, e_, x_] := {
	OsculatingOrbitalElements`Private`Energy[a, p, e, x],
	OsculatingOrbitalElements`Private`AngularMomentum[a, p, e, x],
	OsculatingOrbitalElements`Private`CarterConstant[a, p, e, x]};

Table[
	VerificationTest[
		constantsOfMotion @@ orbit
		,
		Values[KerrGeoConstantsOfMotion @@ orbit]
		,
		SameTest -> withinTolerance[10^-11],
		TestID -> "Constants of motion at {a, p, e, x} = " <> ToString[orbit]
	],
	{orbit, {
		{0.5, 10., 0.2, 0.8},
		{0.9, 7.5, 0.5, 0.3},
		{0.5, 12., 0.3, -0.6},
		{0, 10., 0.2, 0.8},
		{0.5, 10., 0, 0.8},
		{0.5, 10., 0., 0.8},
		{0.5, 10., 0.2, 1},
		{0.5, 10., 0.2, -1},
		{0.5, 10., 0, 1},
		{0.9, 6., 0.1, 1}}}]
