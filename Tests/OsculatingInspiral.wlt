(* ::Package:: *)

(* OsculatingInspiral and the inspiral object: parameter validation, properties, stopping, options, equatorial orbits,
   and forces with a theta component, including inspirals that pass through x = 0. *)

drag[k_] := ForceModel["GasDrag", "Coefficient" -> k];
params = <|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Force" -> drag[10^-5]|>;


(* ::Section:: *)
(* Parameter validation *)

VerificationTest[
	OsculatingInspiral[{0.5, 10^-5, 10, 0.2, 0.8}]
	,
	$Failed, {OsculatingInspiral::params},
	TestID -> "The parameters must be an Association"
]

VerificationTest[
	OsculatingInspiral[Append[params, "q" -> 1]]
	,
	$Failed, {OsculatingInspiral::unknown},
	TestID -> "Unknown parameters are rejected"
]

VerificationTest[
	OsculatingInspiral[KeyDrop[params, {"e", "Force"}]]
	,
	$Failed, {OsculatingInspiral::missing},
	TestID -> "Missing parameters are rejected"
]

VerificationTest[
	OsculatingInspiral[Append[params, "Flux" -> 1]]
	,
	$Failed, {OsculatingInspiral::flux},
	TestID -> "Fluxes are not supported yet"
]

Table[
	VerificationTest[
		OsculatingInspiral[Append[params, change]]
		,
		$Failed, {OsculatingInspiral::range},
		TestID -> "Out of range: " <> ToString[change, InputForm]
	],
	{change, {"a" -> 1, "a" -> -0.1, "\[Epsilon]" -> 0, "p" -> -1, "e" -> 1, "x" -> 1.5, "\[Psi]r" -> I, "x" -> "a"}}]

VerificationTest[
	OsculatingInspiral[Append[params, "x" -> 0]]
	,
	$Failed, {OsculatingInspiral::polar},
	TestID -> "Orbits starting exactly polar are rejected"
]

VerificationTest[
	OsculatingInspiral[Append[params, "p" -> 4]]
	,
	$Failed, {OsculatingInspiral::sep},
	TestID -> "Orbits inside the separatrix are rejected"
]

VerificationTest[
	OsculatingInspiral[params, SeparatrixBuffer -> 6]
	,
	$Failed, {OsculatingInspiral::sep},
	TestID -> "Orbits inside the separatrix buffer are rejected"
]

VerificationTest[
	OsculatingInspiral[Append[params, "Force" -> foo]]
	,
	$Failed, {OsculatingInspiral::force},
	TestID -> "Invalid forces are rejected"
]

VerificationTest[
	OsculatingInspiral[Append[params, "Force" -> KerrGasDrag]]
	,
	$Failed, {OsculatingInspiral::force},
	TestID -> "The earlier force forms are not accepted"
]

VerificationTest[
	OsculatingInspiral[params, Parametrisation -> "foo"]
	,
	$Failed, {OsculatingInspiral::param},
	TestID -> "Invalid Parametrisation is rejected"
]

VerificationTest[
	(* \[CurlyEpsilon] and \[CurlyPhi] are accepted for \[Epsilon] and \[Phi] *)
	insp = OsculatingInspiral[<|"a" -> 0.5, "\[CurlyEpsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "\[CurlyPhi]" -> 1,
		"Force" -> drag[10^-5]|>, IntegrationLimit -> 100];
	{insp["Parameters"]["\[Epsilon]"], insp["\[Phi]"][0]}
	,
	{10^-5, 1.},
	TestID -> "Alternative spellings of epsilon and phi"
]


(* ::Section:: *)
(* The inspiral object *)

VerificationTest[
	insp = OsculatingInspiral[params, IntegrationLimit -> 500];
	{Head[insp], insp["Domain"], insp["StopReason"], insp["Parametrisation"], insp["Parameters"], insp["Force"]}
	,
	{OsculatingInspiralFunction, {0, 500.}, "IntegrationLimit", "CoordinateTime",
		<|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "\[Psi]r" -> 0, "\[Psi]\[Theta]" -> 0, "\[Phi]" -> 0,
			"Force" -> drag[10^-5], "Flux" -> None|>, {drag[10^-5]}},
	TestID -> "Reaching IntegrationLimit is recorded, with no message"
]

VerificationTest[
	Sort[insp["Properties"]] === Sort[Keys[insp]] &&
	SubsetQ[insp["Properties"], {"Trajectory", "t", "r", "\[Theta]", "\[Phi]", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "En", "L", "Q",
		"K", "\[Alpha]p", "\[Beta]p", "Domain", "StopReason", "Parametrisation", "Parameters", "Force"}]
	,
	True,
	TestID -> "Properties"
]

VerificationTest[
	{insp[100.], insp[{100., 200.}] // Dimensions, insp["p"][{100., 200.}] // Dimensions}
	,
	{{100., insp["r"][100.], insp["\[Theta]"][100.], insp["\[Phi]"][100.]}, {4, 2}, {2}},
	TestID -> "inspiral[t] gives {t, r, theta, phi}, and properties are listable"
]

VerificationTest[
	insp["foo"]
	,
	Missing["NotAvailable", "foo"], {OsculatingInspiralFunction::prop},
	TestID -> "Unknown properties"
]

VerificationTest[
	(* The summary box needs a front end for some of its parts *)
	Head[Quiet[ToBoxes[insp], FrontEndObject::notavail]]
	,
	InterpretationBox,
	TestID -> "Summary box"
]

VerificationTest[
	{insp["e"][0], insp["\[Psi]r"][0], insp["x"][0], insp["\[Psi]\[Theta]"][0], insp["\[Phi]"][0]}
	,
	{0.2, 0., 0.8, 0., 0.},
	SameTest -> withinTolerance[10^-14],
	TestID -> "The initial elements and phases"
]

VerificationTest[
	insp = OsculatingInspiral[<|params, "e" -> 0, "\[Psi]r" -> 1|>, IntegrationLimit -> 100];
	{insp["e"][0], insp["\[Psi]r"][0]}
	,
	{0., Missing["UndefinedAtZeroEccentricity"]},
	TestID -> "psi_r is undefined at e = 0"
]

VerificationTest[
	insp = OsculatingInspiral[<|params, "\[Psi]r" -> 5, "\[Psi]\[Theta]" -> -4, "\[Phi]" -> 7|>, IntegrationLimit -> 100];
	{insp["\[Psi]r"][0], insp["\[Psi]\[Theta]"][0], insp["\[Phi]"][0]}
	,
	{5., -4., 7.},
	SameTest -> withinTolerance[10^-12],
	TestID -> "Initial phases outside (-pi, pi] are kept"
]

VerificationTest[
	(* The phases and phi accumulate: they grow steadily rather than wrapping at pi *)
	insp = OsculatingInspiral[params, IntegrationLimit -> 2000];
	{Min[Differences[insp[#][Range[0., 2000., 1.]]]] > 0 & /@ {"\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"},
		insp[#][2000.] & /@ {"\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}}
	,
	{{True, True, True}, {42.8, 59.8, 61.7}},
	SameTest -> (#1[[1]] === #2[[1]] && withinTolerance[0.1][#1[[2]], #2[[2]]] &),
	TestID -> "The phases and phi accumulate"
]

VerificationTest[
	(* Up to whole turns, psi_r is the angle of the integrated eccentricity components *)
	With[{samples = Range[0., 2000., 1.]}, With[{e = insp["e"][samples], \[Psi]r = insp["\[Psi]r"][samples]},
		Max[Abs[Join[e Sin[\[Psi]r] - insp["\[Alpha]p"][samples], e Cos[\[Psi]r] - insp["\[Beta]p"][samples]]]]]]
	,
	0,
	SameTest -> withinTolerance[10^-13],
	TestID -> "psi_r agrees with alpha_p = e sin psi_r and beta_p = e cos psi_r"
]

VerificationTest[
	(* In Mino time the geodesic's radial and polar motions are periodic, so each phase gains exactly 2 pi per period *)
	insp = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.3, "x" -> 0.8, "\[Psi]r" -> 1, "\[Psi]\[Theta]" -> 2,
		"Force" -> None|>, Parametrisation -> "Mino", IntegrationLimit -> 20, InterpolationOrder -> All];
	With[{periods = 2 Pi/Values[KerrGeoFrequencies[0.9, 10, 0.3, 0.8, Time -> "Mino"]][[;; 2]]},
		Table[(insp[#2][n #1] - insp[#2][0])/(2 Pi) - n & @@@ Transpose[{periods, {"\[Psi]r", "\[Psi]\[Theta]"}}], {n, 5}]]
	,
	ConstantArray[0, {5, 2}],
	SameTest -> withinTolerance[10^-11],
	TestID -> "Along a geodesic in Mino time psi_r and psi_theta gain 2 pi per period"
]

VerificationTest[
	(* Equal to the constants of motion of the osculating geodesic *)
	insp = OsculatingInspiral[params, IntegrationLimit -> 1000];
	{insp["En"][500.], insp["L"][500.], insp["Q"][500.]}
	,
	Values[KerrGeoConstantsOfMotion[0.5, insp["p"][500.], insp["e"][500.], insp["x"][500.]]],
	SameTest -> withinTolerance[10^-12],
	TestID -> "Constants of motion"
]


(* ::Section:: *)
(* Stopping, and options *)

VerificationTest[
	insp = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 12, "e" -> 0.3, "x" -> 0.5, "Force" -> drag[10^-3]|>];
	end = insp["Domain"][[2]];
	{insp["StopReason"], insp["p"][end] - KerrGeoSeparatrix[0.9, insp["e"][end], insp["x"][end]]}
	,
	{"SeparatrixBuffer", 10^-3},
	SameTest -> (#1[[1]] === #2[[1]] && withinTolerance[10^-8][#1[[2]], #2[[2]]] &),
	TestID -> "An inspiral stops epsilon outside the separatrix, with no message"
]

VerificationTest[
	insp = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 12, "e" -> 0.3, "x" -> 0.5, "Force" -> drag[10^-3]|>,
		SeparatrixBuffer -> 0.5];
	end = insp["Domain"][[2]];
	{insp["StopReason"], insp["p"][end] - KerrGeoSeparatrix[0.9, insp["e"][end], insp["x"][end]]}
	,
	{"SeparatrixBuffer", 0.5},
	SameTest -> (#1[[1]] === #2[[1]] && withinTolerance[10^-8][#1[[2]], #2[[2]]] &),
	TestID -> "SeparatrixBuffer"
]

VerificationTest[
	insp = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 12, "e" -> 0.3, "x" -> 0.5, "Force" -> drag[10^-3]|>, pMin -> 11];
	{insp["StopReason"], insp["p"][insp["Domain"][[2]]]}
	,
	{"pMin", 11},
	SameTest -> (#1[[1]] === #2[[1]] && withinTolerance[10^-8][#1[[2]], #2[[2]]] &),
	TestID -> "pMin"
]

VerificationTest[
	OsculatingInspiral[params, IntegrationLimit -> 5000, MaxSteps -> 20]["StopReason"]
	,
	"Other", {NDSolve::mxst, OsculatingInspiral::early},
	TestID -> "NDSolve options are passed on, and an early stop is reported"
]

VerificationTest[
	mino = OsculatingInspiral[params, Parametrisation -> "Mino", IntegrationLimit -> 20];
	coordinate = OsculatingInspiral[params, IntegrationLimit -> 2500];
	{mino["Parametrisation"], mino["Domain"],
		Max[Table[With[{t = mino["t"][l]}, Abs[{mino["p"][l], mino["r"][l], mino["\[Phi]"][l]} -
			{coordinate["p"][t], coordinate["r"][t], coordinate["\[Phi]"][t]}]], {l, 2., 20., 2.}]]}
	,
	{"Mino", {0, 20.}, 0},
	SameTest -> (Most[#1] === Most[#2] && withinTolerance[10^-5][Last[#1], Last[#2]] &),
	TestID -> "Mino time gives the same inspiral as coordinate time"
]

VerificationTest[
	(* With NDSolve's default stiffness test this geodesic stopped at lambda = 734 as "stiff", although its steps were
	   steady (see regularSystem) *)
	long = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.3, "x" -> 0.8, "\[Psi]r" -> 1, "\[Psi]\[Theta]" -> 2,
		"\[Phi]" -> 0.5, "Force" -> None|>, Parametrisation -> "Mino", IntegrationLimit -> 800];
	{long["StopReason"], long["Domain"]}
	,
	{"IntegrationLimit", {0, 800.}},
	TestID -> "A long geodesic in Mino time is not stopped as stiff"
]


(* ::Section:: *)
(* Equatorial orbits: x is held at exactly +-1, so the orbit stays in the plane *)

VerificationTest[
	Table[With[{equatorial = OsculatingInspiral[<|params, "x" -> x0|>, IntegrationLimit -> 1000]},
		{equatorial["StopReason"], equatorial["x"][{0., 1000.}], equatorial["\[Theta]"][500.], equatorial["\[Psi]\[Theta]"][500.],
			equatorial["Q"][500.], equatorial[500.][[3]]}],
		{x0, {1, -1.}}]
	,
	{{"IntegrationLimit", {1., 1.}, N[Pi/2], Missing["UndefinedForEquatorialOrbit"], 0., N[Pi/2]},
		{"IntegrationLimit", {-1., -1.}, N[Pi/2], Missing["UndefinedForEquatorialOrbit"], 0., N[Pi/2]}},
	TestID -> "An equatorial orbit stays in the plane: x is +-1, theta is Pi/2, psi_theta is undefined and Q is 0"
]

VerificationTest[
	OsculatingInspiral[<|params, "x" -> 1, "Force" -> ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t}, {0, 1, 0}]]|>]
	,
	$Failed, {OsculatingInspiral::eqforce},
	TestID -> "On an equatorial orbit, a force with a theta component in the plane is rejected"
]

VerificationTest[
	(* F_theta = cos(theta), which is zero in the plane: the orbit is a geodesic there *)
	upward = ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t}, {0, Sqrt[1 - x^2] Cos[\[Psi]\[Theta]], 0}]];
	With[{inspiral = OsculatingInspiral[<|params, "x" -> 1, "Force" -> upward|>, IntegrationLimit -> 500]},
		{inspiral["StopReason"], inspiral["p"][500.], inspiral["e"][500.], inspiral["x"][500.]}]
	,
	{"IntegrationLimit", 10, 0.2, 1.},
	SameTest -> (#1[[{1, 4}]] === #2[[{1, 4}]] && withinTolerance[10^-9][#1[[2 ;; 3]], #2[[2 ;; 3]]] &),
	TestID -> "On an equatorial orbit, a force whose theta component vanishes in the plane is accepted"
]

VerificationTest[
	OsculatingInspiral[<|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 1, "Force" -> None,
		"Flux" -> FluxModel[Function[{a, p, e, x}, {0, 0, -10^-3}]]|>]
	,
	$Failed, {OsculatingInspiral::eqflux},
	TestID -> "On an equatorial orbit, a flux that changes x is rejected"
]

VerificationTest[
	(* Starting 10^-12 from the equator tilts the orbit by Sqrt[2 10^-12], and uses the general polar equations *)
	equatorial = OsculatingInspiral[<|params, "x" -> 1|>, IntegrationLimit -> 3000];
	nearEquatorial = OsculatingInspiral[<|params, "x" -> 1 - 10^-12|>, IntegrationLimit -> 3000];
	maxDifference[equatorial, nearEquatorial, {"p", "e", "x", "r", "\[Theta]", "\[Phi]"}, Range[300., 3000., 300.]]
	,
	{0, 0, 0, 0, 0, 0}, SameTest -> withinTolerance[{10^-8, 10^-6, 10^-9, 10^-5, 3*10^-6, 10^-5}],
	TestID -> "The solution is continuous at the equator"
]


(* ::Section:: *)
(* Forces with a theta component, projected orthogonal to the velocity (k + (k.u) u for a covector k) and so written as
   drivers and given to RunSolver directly. Against REG, the regular solver uses InterpolationOrder -> All: its default
   interpolation between steps is off by up to 10^-6 in r, as large as the tolerances. An error of 1% in a force term
   changes the results by 10^-3 or more. *)

runWithDriver[builder_, driver_, \[Epsilon]_, a_, initial_, opts___] := OsculatingOrbitalElements`Private`RunSolver[
	OsculatingInspiral, builder, Function[force, {<|"Type" -> "Force", "Function" -> driver|>}], \[Epsilon], a, initial, {opts},
	<|"Force" -> None, "MessageHead" -> OsculatingInspiral, "ReportStops" -> {"Other"}|>];

(* A constant push towards increasing theta *)
vertical = Function[state, With[{u\[Theta] = state["u\[Theta]"]/state["\[CapitalSigma]"]},
	{-state["En"] u\[Theta], state["ur"] u\[Theta], 1 + state["u\[Theta]"] u\[Theta], state["L"] u\[Theta]}]];

(* A retrograde torque, k = -2 Sin[theta]^2 dphi, which has a bounded physical component near the axis *)
torque = Function[state, With[{s2 = 1 - state["z"], u\[Phi] = state["d\[Phi]d\[Lambda]"]/state["\[CapitalSigma]"]},
	-2 {-state["En"] s2 u\[Phi], state["ur"] s2 u\[Phi], state["u\[Theta]"] s2 u\[Phi], s2 (1 + state["L"] u\[Phi])}]];

VerificationTest[
	regular = runWithDriver[OsculatingOrbitalElements`Private`regularSystem, vertical, 10^-5, 0.5, {10, 0.2, 0.95, 0, 0, 0},
		IntegrationLimit -> 3000, AccuracyGoal -> 13, PrecisionGoal -> 13, InterpolationOrder -> All];
	reg = runWithDriver[OsculatingOrbitalElements`Private`regSystem, vertical, 10^-5, 0.5, {10, 0.2, 0.95, 0, 0},
		IntegrationLimit -> 3000, AccuracyGoal -> 13, PrecisionGoal -> 13];
	maxDifference[regular, reg, {"p", "e", "x", "r", "\[Theta]", "\[Phi]"}, Range[300., 3000., 300.]]
	,
	{0, 0, 0, 0, 0, 0}, SameTest -> withinTolerance[{10^-9, 10^-7, 10^-10, 10^-6, 10^-6, 10^-6}],
	TestID -> "A theta force on an inclined orbit: the regular solver agrees with REG"
]

VerificationTest[
	crossing = runWithDriver[OsculatingOrbitalElements`Private`regularSystem, torque, 10^-3, 0.9, {20, 0.1, 0.05, 0, 0, 0},
		IntegrationLimit -> 1500, InterpolationOrder -> All];
	{crossing["StopReason"], crossing["x"][1500.] < -0.2}
	,
	{"IntegrationLimit", True},
	TestID -> "A torque drives an inspiral through x = 0, from prograde to retrograde"
]

VerificationTest[
	(* Slow variables after the crossing, against REG, which steps over the 0/0 in its x equation *)
	reg = runWithDriver[OsculatingOrbitalElements`Private`regSystem, torque, 10^-3, 0.9, {20, 0.1, 0.05, 0, 0},
		IntegrationLimit -> 1500, AccuracyGoal -> 13, PrecisionGoal -> 13];
	maxDifference[crossing, reg, {"p", "e", "x", "r"}, Range[400., 1500., 100.]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[{10^-6, 10^-7, 10^-6, 10^-5}],
	TestID -> "Through x = 0, p, e, x and r agree with REG"
]

VerificationTest[
	(* Near-polar orbits swing phi by nearly pi each time they pass close to the axis; the default method resolves it *)
	polar = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.01, "Force" -> drag[10^-5]|>,
		IntegrationLimit -> 3000];
	reg = quietStops@GenericKerrREGBL[10^-5, 0.9, 10, 0.2, 0.01, 0, 0, IntegrationLimit -> 3000, AccuracyGoal -> 13, PrecisionGoal -> 13];
	Max[Table[With[{a = polar[t], b = reg /@ {"t", "r", "\[Theta]", "\[Phi]"}},
		Norm[{Sin[a[[3]]] Cos[a[[4]]], Sin[a[[3]]] Sin[a[[4]]], Cos[a[[3]]]} -
			{Sin[b[[3]][t]] Cos[b[[4]][t]], Sin[b[[3]][t]] Sin[b[[4]][t]], Cos[b[[3]][t]]}]], {t, 1., 3000., 1.}]]
	,
	0, SameTest -> withinTolerance[10^-4],
	TestID -> "A near-polar inspiral (x = 0.01): the direction to the particle agrees with REG"
]
