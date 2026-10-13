(* ::Package:: *)

(* Agreement between independent formulations of the same inspiral, with the default gas drag. *)


(* ::Section:: *)
(* Kerr: ELK, pex and REG *)

(* Tight NDSolve goals make the formulations agree to about 1e-8 in r. At the default goals they differ by about 1e-5,
   as much as a 1% error in one of pex's force terms would change r, so such an error would go unnoticed. *)
kerrArgs = {10^-5, 0.5, 10, 0.2, 0.8, 0, 0};
kerrGoals = Sequence[AccuracyGoal -> 11, PrecisionGoal -> 11];
kerrSamples = Range[500., 5000., 500.];

VerificationTest[
	elk = quietStops@KerrOsculatingOrbitalElements[Sequence @@ kerrArgs, IntegrationLimit -> 5000, kerrGoals];
	pex = quietStops@GenericKerrpexBL[Sequence @@ kerrArgs, IntegrationLimit -> 5000, kerrGoals];
	reg = quietStops@GenericKerrREGBL[Sequence @@ kerrArgs, IntegrationLimit -> 5000, kerrGoals];
	AllTrue[{elk, pex, reg}, AssociationQ]
	,
	True,
	TestID -> "Kerr: ELK, pex and REG solve the same inspiral"
]

VerificationTest[
	(* Tolerances for p, e, x, r and phi *)
	maxDifference[elk, pex, {"p", "e", "x", "r", "\[Phi]"}, kerrSamples]
	,
	{0, 0, 0, 0, 0}, SameTest -> withinTolerance[{10^-9, 10^-9, 10^-11, 10^-6, 3*10^-6}],
	TestID -> "Kerr: ELK agrees with pex in p, e, x, r and phi"
]

VerificationTest[
	maxDifference[reg, pex, {"p", "e", "x", "r", "\[Phi]"}, kerrSamples]
	,
	{0, 0, 0, 0, 0}, SameTest -> withinTolerance[{10^-9, 10^-7, 10^-11, 2*10^-6, 3*10^-6}],
	TestID -> "Kerr: REG agrees with pex in p, e, x, r and phi"
]


(* ::Section:: *)
(* Schwarzschild: coordinate time against the Darwin parameter *)

(* The Schwarzschild solves are fast, so tighter NDSolve goals keep integration error well below the tolerances. *)
schwarzschildGoals = Sequence[AccuracyGoal -> 12, PrecisionGoal -> 12];

(* p_TP(t(chi)) against p_chi(chi), and likewise for e, r and phi *)
timeVsDarwin[e0_] := Module[{chi, tp, chis},
	chi = quietStops@SchwarzOsculatingOrbitalElements[10^-4, 20, e0, 0.4, IntegrationLimit -> 60, schwarzschildGoals];
	tp = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 20, e0, 0.4, IntegrationLimit -> 20000, schwarzschildGoals];
	chis = Subdivide[0., 0.9 chi["limit"], 12];
	Table[Max[Abs[(tp[k] /@ (chi["t"] /@ chis)) - (chi[k] /@ chis)]], {k, {"p", "e", "r", "\[Phi]"}}]];

VerificationTest[
	timeVsDarwin[0.3]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[10^-5],
	TestID -> "Schwarzschild e0 = 0.3: coordinate-time solver agrees with the Darwin-parameter solver"
]

VerificationTest[
	timeVsDarwin[0.03]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[10^-5],
	TestID -> "Schwarzschild e0 = 0.03: coordinate-time solver agrees with the Darwin-parameter solver"
]


(* ::Section:: *)
(* Schwarzschild: continuity across the e0 = 0.05 switch between the (p, e, xi) and (p, alpha, beta) equations *)

VerificationTest[
	above = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 20, 0.05 + 10^-8, 0, IntegrationLimit -> 20000, schwarzschildGoals];
	below = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 20, 0.05, 0, IntegrationLimit -> 20000, schwarzschildGoals];
	maxDifference[above, below, {"p", "e", "r", "\[Phi]"}, Subdivide[0., 0.9 Min[above["limit"], below["limit"]], 12]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[10^-5],
	TestID -> "Schwarzschild coordinate time: continuous across e0 = 0.05"
]

VerificationTest[
	above = quietStops@SchwarzOsculatingOrbitalElements[10^-4, 20, 0.05 + 10^-8, 0, IntegrationLimit -> 60, schwarzschildGoals];
	below = quietStops@SchwarzOsculatingOrbitalElements[10^-4, 20, 0.05, 0, IntegrationLimit -> 60, schwarzschildGoals];
	maxDifference[above, below, {"t", "p", "e", "r", "\[Phi]"}, Subdivide[0., 0.9 Min[above["limit"], below["limit"]], 12]]
	,
	{0, 0, 0, 0, 0}, SameTest -> withinTolerance[10^-4],
	TestID -> "Schwarzschild Darwin parameter: continuous across e0 = 0.05"
]


(* ::Section:: *)
(* Kerr at a = 0 on the equator against Schwarzschild. The drag forces are identical there. *)

VerificationTest[
	schwarzschild = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 12, 0.3, 0.7, IntegrationLimit -> 20000];
	kerr = quietStops@GenericKerrpexBL[10^-4, 0, 12, 0.3, 1, 0.7, 0, IntegrationLimit -> 20000];
	maxDifference[kerr, schwarzschild, {"p", "e", "r", "\[Phi]"}, Subdivide[0., 0.95 schwarzschild["limit"], 8]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[10^-8],
	TestID -> "a = 0, x = 1: pex agrees with SchwarzOsculatingOrbitalElementsTP"
]

VerificationTest[
	kerr = quietStops@GenericKerrREGBL[10^-4, 0, 12, 0.3, 1, 0.7, 0, IntegrationLimit -> 20000];
	maxDifference[kerr, schwarzschild, {"p", "e", "r", "\[Phi]"}, Subdivide[0., 0.95 schwarzschild["limit"], 8]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[10^-4],
	TestID -> "a = 0, x = 1: REG agrees with SchwarzOsculatingOrbitalElementsTP"
]
