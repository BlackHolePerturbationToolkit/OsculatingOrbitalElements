(* ::Package:: *)

(* The osculating geodesic's Boyer-Lindquist frequencies and action angles, as properties of the inspiral (Kernel/OrbitalAngles.wl).
   The angles follow Lynch and Burke, arXiv:2411.04955. Along a geodesic each angle is its frequency times t plus a
   constant, which tests the conversion and its signs; the reference values below come from the notebook that goes with
   the paper (github.com/Philip-Lynch/KerrOrbitalAngleConversion), which fixes the conventions. *)

angleKeys = {"\[CapitalPhi]r", "\[CapitalPhi]\[Theta]", "\[CapitalPhi]\[Phi]"};
frequencyKeys = {"\[CapitalOmega]r", "\[CapitalOmega]\[Theta]", "\[CapitalOmega]\[Phi]"};

(* The largest change in Phi - Omega t over the samples, for each angle, or "Missing" for an undefined angle *)
geodesicDrift[params_, opts___] := Module[{inspiral, samples, \[CapitalOmega]},
	inspiral = OsculatingInspiral[<|params, "\[Epsilon]" -> 10^-3, "Force" -> None|>, opts, IntegrationLimit -> 3000, InterpolationOrder -> All];
	samples = Range[0., inspiral["Domain"][[2]], inspiral["Domain"][[2]]/100];
	\[CapitalOmega] = inspiral[#][0.] & /@ frequencyKeys;
	Table[With[{values = inspiral[angleKeys[[k]]][samples]},
		If[MemberQ[values, _Missing], "Missing",
			Max[Abs[values - First[values] - \[CapitalOmega][[k]] (inspiral["t"][samples] - inspiral["t"][0.])]]]], {k, 3}]];


(* ::Section:: *)
(* Frequencies *)

VerificationTest[
	inspiral = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.3, "x" -> 0.8, "\[Psi]r" -> 5, "\[Psi]\[Theta]" -> 2,
		"Force" -> ForceModel["GasDrag", "Coefficient" -> 10^-4]|>, IntegrationLimit -> 2000];
	Table[{inspiral[#][t] & /@ frequencyKeys, Values[KerrGeoFrequencies[0.9, inspiral["p"][t], inspiral["e"][t], inspiral["x"][t]]]}, {t, {0., 1000., 2000.}}]
	,
	Table[{#, #} &[Values[KerrGeoFrequencies[0.9, inspiral["p"][t], inspiral["e"][t], inspiral["x"][t]]]], {t, {0., 1000., 2000.}}],
	TestID -> "The frequencies are KerrGeodesics' at the osculating elements"
]

VerificationTest[
	(* A symbolic time leaves them unevaluated, so NIntegrate and Plot work *)
	{Head[inspiral["\[CapitalOmega]r"][s]], Head[inspiral["\[CapitalPhi]r"][s]] =!= Missing, NumericQ[NIntegrate[inspiral["\[CapitalOmega]\[Phi]"][t], {t, 0, 10}]]}
	,
	{OsculatingOrbitalElements`Private`BoyerLindquistFrequency, True, True},
	TestID -> "Frequencies and angles with a symbolic time"
]


(* ::Section:: *)
(* Angles *)

VerificationTest[
	OsculatingOrbitalElements`Private`BoyerLindquistAngles[0.9, 10, 0.3, 0.8, 1.2, 0.5, 10.]
	,
	{0.7656854348230824, -0.08668173749108432, 9.26425231590158},
	SameTest -> withinTolerance[10^-11],
	TestID -> "The conversion agrees with the notebook of the paper"
]

VerificationTest[
	(* Phases beyond (-pi, pi] give angles beyond it, by the same whole turns *)
	OsculatingOrbitalElements`Private`BoyerLindquistAngles[0.5, 12, 0.5, -0.4, 4.0 + 2 Pi, 5.5 - 4 Pi, -3.] -
		OsculatingOrbitalElements`Private`BoyerLindquistAngles[0.5, 12, 0.5, -0.4, 4.0, 5.5, -3.]
	,
	{2 Pi, -4 Pi, 0},
	SameTest -> withinTolerance[10^-11],
	TestID -> "Whole turns of the phases are whole turns of the angles"
]

VerificationTest[
	{inspiral[#][0.] & /@ angleKeys, OsculatingOrbitalElements`Private`BoyerLindquistAngles[0.9, 10, 0.3, 0.8, 5, 2, 0]}
	,
	{#, #} &[OsculatingOrbitalElements`Private`BoyerLindquistAngles[0.9, 10, 0.3, 0.8, 5, 2, 0]],
	SameTest -> (withinTolerance[10^-12][#1[[1]], #1[[2]]] &),
	TestID -> "The initial angles are those of the initial phases, with psi_r = 5 kept beyond pi"
]

VerificationTest[
	Table[geodesicDrift[params], {params, {
		<|"a" -> 0.9, "p" -> 10, "e" -> 0.3, "x" -> 0.8, "\[Psi]r" -> 1, "\[Psi]\[Theta]" -> 2, "\[Phi]" -> 0.5|>,
		<|"a" -> 0.9, "p" -> 12, "e" -> 0.5, "x" -> -0.5, "\[Psi]r" -> 4, "\[Psi]\[Theta]" -> -1|>,
		<|"a" -> 0, "p" -> 10, "e" -> 0.2, "x" -> 0.6|>,
		<|"a" -> 0.9, "p" -> 10, "e" -> 0.3, "x" -> 0.05|>}}]
	,
	ConstantArray[{0, 0, 0}, 4],
	SameTest -> withinTolerance[10^-8],
	TestID -> "Along geodesics each angle advances at its frequency: prograde, retrograde, Schwarzschild and near-polar"
]

VerificationTest[
	geodesicDrift[<|"a" -> 0.9, "p" -> 10, "e" -> 0.3, "x" -> 0.8, "\[Psi]r" -> 1, "\[Psi]\[Theta]" -> 2, "\[Phi]" -> 0.5|>,
		Parametrisation -> "Mino", IntegrationLimit -> 20]
	,
	{0, 0, 0},
	SameTest -> withinTolerance[10^-9],
	TestID -> "Along a geodesic in Mino time, each angle advances at its frequency in t"
]

VerificationTest[
	{geodesicDrift[<|"a" -> 0.7, "p" -> 9, "e" -> 0.4, "x" -> 1, "\[Psi]r" -> 2|>],
		geodesicDrift[<|"a" -> 0.7, "p" -> 9, "e" -> 0, "x" -> 0.5, "\[Psi]\[Theta]" -> 1|>]}
	,
	{{0, "Missing", 0}, {"Missing", 0, 0}},
	SameTest -> (#1[[1, 2]] === "Missing" && #1[[2, 1]] === "Missing" &&
		withinTolerance[10^-8][Cases[#1, _?NumericQ, Infinity], Cases[#2, _?NumericQ, Infinity]] &),
	TestID -> "Equatorial and circular geodesics: the undefined angle is Missing, and the others advance at their frequencies"
]

VerificationTest[
	(* The accumulated angles against the integral of the frequencies: they differ only by the force's effect on the
	   angles, 0.03 in Phi_r here, far less than a turn, so no turn is lost *)
	Table[Abs[inspiral[angleKeys[[k]]][2000.] - inspiral[angleKeys[[k]]][0.] -
		NIntegrate[inspiral[frequencyKeys[[k]]][t], {t, 0, 2000}, MaxRecursion -> 20]], {k, 3}]
	,
	{0, 0, 0},
	SameTest -> withinTolerance[0.1],
	TestID -> "Over an inspiral the angles accumulate, following the integral of the frequencies"
]

VerificationTest[
	SubsetQ[inspiral["Properties"], Join[angleKeys, frequencyKeys]]
	,
	True,
	TestID -> "The frequencies and angles are properties"
]
