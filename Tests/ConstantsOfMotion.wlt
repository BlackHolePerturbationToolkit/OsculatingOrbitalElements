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


(* ::Section:: *)
(* The map from the rates of (En, L, Q) to those of (p, e^2, x) *)

(* Moving the orbit in the direction (dp, de, dx) changes its constants of motion at rates found here by central
   differences at 60 digits. The map must recover the direction, as (dp, 2 e de, dx), to far better than machine precision. *)
elementRatesFromDirection[{a_, p_, e_, x_}, {dp_, de_, dx_}] := Module[{h = 10^-25, at},
	at[k_] := N[{a, p + k dp, e + k de, x + k dx}, 60];
	Values[OsculatingOrbitalElements`Private`OrbitalElementRates[N[a, 60], N[{p, e^2, x}, 60],
		constantsOfMotion @@ at[0], (constantsOfMotion @@ at[h] - constantsOfMotion @@ at[-h])/(2 h)]]
];

Table[
	VerificationTest[
		elementRatesFromDirection @@ c
		,
		{c[[2, 1]], 2 c[[1, 3]] c[[2, 2]], c[[2, 3]]}
		,
		SameTest -> withinTolerance[10^-20],
		TestID -> "Rates of (p, e^2, x) from those of (En, L, Q) at {a, p, e, x} = " <> ToString[c[[1]]] <>
			", direction " <> ToString[c[[2]]]
	],
	{c, {
		{{1/2, 10, 1/5, 4/5}, {3/10, -1/5, 1/10}},
		{{9/10, 7, 3/5, -3/10}, {-1, 1/10, 1/5}},
		{{0, 10, 1/5, 4/5}, {3/10, -1/5, 1/10}},
		(* A circular orbit stays circular, and the rate of e^2 vanishes *)
		{{1/2, 10, 0, 4/5}, {3/10, 0, 1/10}}}}]


(* ::Section:: *)
(* The regular solver's constants of motion, RegularEnergy and RegularLOverX, which take e^2 *)

regularConstants[a_, p_, e_, x_] := With[{En = OsculatingOrbitalElements`Private`RegularEnergy[a, p, e^2, x],
	l = OsculatingOrbitalElements`Private`RegularLOverX[a, p, e^2, x]},
	{En, x l, (1 - x^2) (a^2 (1 - En^2) + l^2)}];

VerificationTest[
	(* Exact inputs at 50 digits, against KerrGeodesics: prograde and retrograde, a = 0, and equatorial *)
	Max[Table[Abs[regularConstants @@ N[orbit, 50] - N[Values[KerrGeoConstantsOfMotion @@ orbit], 50]],
		{orbit, Flatten[Table[{a, 9, 2/5, x}, {a, {0, 1/2, 9/10}}, {x, {1, 4/5, 3/10, -3/10, -1}}], 1]}]]
	,
	0, SameTest -> withinTolerance[10^-40],
	TestID -> "Regular constants of motion at 50 digits"
]

Table[
	VerificationTest[
		regularConstants @@ orbit
		,
		N[If[orbit[[3]] == 0, {KerrGeoEnergy @@ #, KerrGeoAngularMomentum @@ #, KerrGeoCarterConstant @@ #} &[Rationalize[orbit, 0]],
			Values[KerrGeoConstantsOfMotion @@ Rationalize[orbit, 0]]]],
		SameTest -> withinTolerance[10^-12],
		TestID -> "Regular constants of motion at {a, p, e, x} = " <> ToString[orbit]
	],
	{orbit, {
		{0.5, 10., 0.2, 0.8},
		{0.9, 7.5, 0.5, -0.3},
		{0.5, 10., 0., 0.8},
		{0.5, 10., 10.^-8, 0.8},
		{0.9, 10., 0.2, 10.^-8},
		{0.9, 10., 0.2, 0.},
		{0.9, 10., 0., 0.},
		{0., 10., 0.2, 1.}}}]


(* ::Section:: *)
(* SeparatrixP: KerrGeoSeparatrix, safe for the values of x and e that an inspiral reaches *)

VerificationTest[
	With[{sep = OsculatingOrbitalElements`Private`SeparatrixP},
		{sep[0.5, 0.2, 1.], sep[0.5, 0.2, 1. - 10.^-16], sep[0.5, 0.2, 1. + 10.^-12], sep[0.5, 0.2, -1.], sep[0.5, 0.2, 0.],
			sep[0.5, 0., 0.8], sep[0., 0.2, 0.3]}]
	,
	{KerrGeoSeparatrix[0.5, 0.2, 1], KerrGeoSeparatrix[0.5, 0.2, 1], KerrGeoSeparatrix[0.5, 0.2, 1], KerrGeoSeparatrix[0.5, 0.2, -1],
		KerrGeoSeparatrix[0.5, 0.2, 0], Quiet[KerrGeoSeparatrix[0.5, 0., 0.8]], 6.4},
	SameTest -> withinTolerance[10^-10],
	TestID -> "SeparatrixP at x = 1., 0. and -1., near and beyond 1, at e = 0, and at a = 0"
]
