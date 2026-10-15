(* ::Package:: *)

(* ForceModel: construction, properties, the built-in models against the earlier force functions, the mass-ratio
   convention, forces that add, and forces that depend on phi and t. *)

(* {a, p, e, x, psi_r, psi_theta}, and the same point with phi and t, as a force model takes it *)
orbit = {0.5, 10., 0.2, 0.8, 0.3, 0.4};
point = Join[orbit, {1.1, 50.}];
points = {orbit, {0.9, 7.5, 0.5, -0.3, 2., 4.}, {0., 10., 0.2, 1., 1., 0.}, {0.9, 10., 0., 0.05, 0., 1.}};
withPhiAndT[pt_] := Join[pt, {1.1, 50.}];
relativeDifference[a_, b_] := Max[Abs[a - b]]/Max[Abs[b]];
params = <|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8|>;


(* ::Section:: *)
(* Construction and properties *)

VerificationTest[
	model = ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, par}, par["k"] {1, 2, 3}], "Name" -> "Test", "Parameters" -> <|"k" -> 2|>,
		"ScalesWithMassRatio" -> False, "Citation" -> "Nobody"];
	{Head[model], model["Name"], model["Parameters"], model["ScalesWithMassRatio"], model["Citation"], model["Description"],
		Sort[model["Properties"]]}
	,
	{ForceModel, "Test", <|"k" -> 2|>, False, "Nobody", None,
		Sort[{"Name", "Description", "Function", "Parameters", "ScalesWithMassRatio", "ValidityCondition", "ValidityDescription", "Citation"}]},
	TestID -> "A custom model and its properties"
]

VerificationTest[
	(* {F_t, F_r, F_theta, F_phi}: the time component makes the force orthogonal to the velocity *)
	force = model @@ point;
	g = OsculatingOrbitalElements`Private`NumericOrbitGeometry @@ orbit;
	{Rest[force], force . {g["dtd\[Lambda]"], g["\[CapitalDelta]"] g["ur"], g["u\[Theta]"], g["d\[Phi]d\[Lambda]"]}}
	,
	{{2, 4, 6}, 0},
	SameTest -> withinTolerance[10^-12],
	TestID -> "Evaluating a model gives the covariant force, orthogonal to the velocity"
]

VerificationTest[
	ForceModel[model, "k" -> 3] @@ point // Rest
	,
	{3, 6, 9},
	TestID -> "Changing a parameter"
]

(* A symbol with only an eight-argument definition *)
f8[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_] := {1, 1, 1};

VerificationTest[
	(* With no parameters the function gets eight arguments *)
	ForceModel[f8] @@ point // Rest
	,
	{1, 1, 1},
	TestID -> "A model without parameters"
]

VerificationTest[
	ForceModel["Foo"]
	,
	$Failed, {ForceModel::name},
	TestID -> "Unknown built-in model"
]

VerificationTest[
	ForceModel["GasDrag", "Foo" -> 1]
	,
	$Failed, {ForceModel::param},
	TestID -> "Unknown parameter"
]

VerificationTest[
	ForceModel[{1, 2, 3} &, "Colour" -> "red"]
	,
	$Failed, {ForceModel::opt},
	TestID -> "Unknown option"
]

VerificationTest[
	ForceModel[{1, 2} &] @@ point
	,
	$Failed, {ForceModel::output},
	TestID -> "A function that does not return three numbers"
]

VerificationTest[
	model["Foo"]
	,
	Missing["NotAvailable", "Foo"], {ForceModel::prop},
	TestID -> "Unknown property"
]

VerificationTest[
	Head[Quiet[ToBoxes[ForceModel["FastGSF"]], FrontEndObject::notavail]]
	,
	InterpretationBox,
	TestID -> "Summary box"
]


(* ::Section:: *)
(* The built-in models against the earlier force functions *)

VerificationTest[
	Max[Table[relativeDifference[ForceModel["GasDrag", "Coefficient" -> 1] @@ withPhiAndT[pt],
		Values[OsculatingOrbitalElements`Private`KerrGasDragapex @@ pt]], {pt, points}]]
	,
	0, SameTest -> withinTolerance[10^-13],
	TestID -> "GasDrag with Coefficient 1 is KerrGasDragapex"
]

VerificationTest[
	Max[Table[relativeDifference[ForceModel["EMConservative"] @@ withPhiAndT[pt], Values[KerrEMCons @@ pt]], {pt, points}]]
	,
	0, SameTest -> withinTolerance[10^-13],
	TestID -> "EMConservative is KerrEMCons, including F_t"
]

VerificationTest[
	Max[Table[relativeDifference[OsculatingOrbitalElements`Private`fastGSFComponents @@ q, Values[SchwarzFastGSF @@ q]],
		{q, {{10., 0.1, 0.3}, {8.5, 0.15, 2.1}, {11., 0.1, 1.}, {7., 10.^-12, 0.}}}]]
	,
	0, SameTest -> withinTolerance[10^-10],
	TestID -> "The vectorised FastGSF fit agrees with SchwarzFastGSF"
]

VerificationTest[
	(* The sum is evaluated as numbers now, so it has to be fast *)
	First[AbsoluteTiming[Do[OsculatingOrbitalElements`Private`fastGSFComponents[10. + 10.^-9 i, 0.1, 0.3], {i, 200}]]]/200 < 0.001
	,
	True,
	TestID -> "The vectorised FastGSF fit takes under a millisecond"
]

VerificationTest[
	(* On the equator F_r = F^r r/(r - 2) and F_phi = r^2 F^phi, with SchwarzFastGSF's contravariant F^r and F^phi *)
	With[{r = 10./(1 + 0.1 Cos[0.3]), f = Values[SchwarzFastGSF[10., 0.1, 0.3]]},
		Rest[ForceModel["FastGSF"][0, 10., 0.1, 1., 0.3, 0., 1.1, 50.]] - {f[[1]] r/(r - 2), 0, r^2 f[[2]]}]
	,
	{0, 0, 0},
	SameTest -> withinTolerance[10^-12],
	TestID -> "FastGSF on the equator"
]


(* ::Section:: *)
(* In an inspiral *)

VerificationTest[
	OsculatingInspiral[<|params, "Force" -> "GasDrag"|>]
	,
	$Failed, {ForceModel::required},
	TestID -> "A required parameter with no value"
]

VerificationTest[
	OsculatingInspiral[<|params, "Force" -> {ForceModel["GasDrag", "Coefficient" -> 10^-5], ForceModel[{1, 2} &]}|>]
	,
	$Failed, {ForceModel::output},
	TestID -> "A force that fails at the initial orbit"
]

VerificationTest[
	OsculatingInspiral[<|params, "Force" -> "FastGSF"|>, IntegrationLimit -> 10]["StopReason"]
	,
	"IntegrationLimit", {ForceModel::range},
	TestID -> "A model used outside its range of validity gives a warning"
]

VerificationTest[
	(* GasDrag does not scale with the mass ratio, so epsilon only changes the separatrix buffer *)
	drag = ForceModel["GasDrag", "Coefficient" -> 10^-5];
	small = OsculatingInspiral[<|params, "Force" -> drag|>, IntegrationLimit -> 2000];
	large = OsculatingInspiral[<|params, "\[Epsilon]" -> 10^-3, "Force" -> drag|>, IntegrationLimit -> 2000];
	maxDifference[small, large, {"p", "e", "x", "r", "\[Phi]"}, Range[200., 2000., 200.]]
	,
	{0, 0, 0, 0, 0}, SameTest -> withinTolerance[0],
	TestID -> "A force that does not scale with the mass ratio"
]

VerificationTest[
	(* A custom force scales with the mass ratio by default: epsilon times the drag with k = 1 is the drag with k = epsilon.
	   The two differ in rounding, which changes the Runge-Kutta steps, so they agree to the integration error. With
	   InterpolationOrder -> All that holds between steps too. *)
	scaled = ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t},
		Rest[ForceModel["GasDrag", "Coefficient" -> 1][a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t]]]];
	maxDifference[OsculatingInspiral[<|params, "Force" -> scaled|>, IntegrationLimit -> 2000, InterpolationOrder -> All],
		OsculatingInspiral[<|params, "Force" -> drag|>, IntegrationLimit -> 2000, InterpolationOrder -> All],
		{"p", "e", "x", "r", "\[Phi]"}, Range[200., 2000., 200.]]
	,
	{0, 0, 0, 0, 0},
	SameTest -> withinTolerance[{10^-9, 10^-6, 10^-10, 10^-5, 10^-5}],
	TestID -> "A custom force scales with the mass ratio"
]

VerificationTest[
	(* Two forces against their sum written as one force, with InterpolationOrder -> All as above *)
	pair = OsculatingInspiral[<|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 1,
		"Force" -> {"FastGSF", ForceModel["GasDrag", "Coefficient" -> 10^-4]}|>, IntegrationLimit -> 1000, InterpolationOrder -> All];
	sum = ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t},
		10^-3 Rest[ForceModel["FastGSF"][a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t]] +
		10^-4 Rest[ForceModel["GasDrag", "Coefficient" -> 1][a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t]]], "ScalesWithMassRatio" -> False];
	single = OsculatingInspiral[<|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 1, "Force" -> sum|>, IntegrationLimit -> 1000,
		InterpolationOrder -> All];
	{#["Name"] & /@ pair["Force"], maxDifference[pair, single, {"p", "e", "r", "\[Phi]"}, Range[100., 1000., 100.]]}
	,
	{{"FastGSF", "GasDrag"}, {0, 0, 0, 0}},
	SameTest -> (#1[[1]] === #2[[1]] && withinTolerance[10^-6][#1[[2]], #2[[2]]] &),
	TestID -> "Several forces add"
]

VerificationTest[
	(* FastGSF at a = 0 on the equator against the earlier Schwarzschild solver with SchwarzFastGSF *)
	gsf = OsculatingInspiral[<|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 1, "Force" -> "FastGSF"|>, IntegrationLimit -> 3000];
	schwarzschild = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-3, 10, 0.1, 0, Force -> SchwarzFastGSF, IntegrationLimit -> 3000,
		AccuracyGoal -> 12, PrecisionGoal -> 12];
	maxDifference[gsf, schwarzschild, {"p", "e", "r", "\[Phi]"}, Range[300., 3000., 300.]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[{10^-7, 10^-5, 10^-4, 10^-5}],
	TestID -> "FastGSF agrees with SchwarzOsculatingOrbitalElementsTP"
]

VerificationTest[
	(* In Schwarzschild an inclined orbit is a rotated equatorial one, so p, e and r are the same, and x stays fixed *)
	tilted = OsculatingInspiral[<|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 0.6, "Force" -> "FastGSF"|>, IntegrationLimit -> 3000];
	Append[maxDifference[tilted, gsf, {"p", "e", "r"}, Range[300., 3000., 300.]], Abs[tilted["x"][3000.] - 0.6]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[{10^-7, 10^-5, 10^-4, 10^-10}],
	TestID -> "FastGSF on an inclined Schwarzschild orbit"
]

VerificationTest[
	(* A retrograde equatorial Schwarzschild orbit is the mirror image of the prograde one *)
	retrograde = OsculatingInspiral[<|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> -1, "Force" -> "FastGSF"|>, IntegrationLimit -> 3000];
	Append[maxDifference[retrograde, gsf, {"p", "e", "r"}, Range[300., 3000., 300.]],
		Max[Abs[retrograde["\[Phi]"][Range[300., 3000., 300.]] + gsf["\[Phi]"][Range[300., 3000., 300.]]]]]
	,
	{0, 0, 0, 0}, SameTest -> withinTolerance[{10^-7, 10^-5, 10^-4, 10^-4}],
	TestID -> "FastGSF on a retrograde orbit"
]


(* ::Section:: *)
(* Forces that depend on phi and t *)

VerificationTest[
	ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t}, {\[Phi], t, 0}]] @@ point // Rest
	,
	{1.1, 50., 0},
	TestID -> "A force model gets phi and t"
]

(* A uniform field in the equatorial plane, pointing along azimuth phi0: the gradient of c r Sin[theta] Cos[phi - phi0],
   which is not axisymmetric *)
uniformField[\[Phi]0_] := ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t},
	With[{r = p/(1 + e Cos[\[Psi]r]), cos\[Theta] = Sqrt[1 - x^2] Cos[\[Psi]\[Theta]]},
	With[{sin\[Theta] = Sqrt[1 - cos\[Theta]^2]},
		{sin\[Theta] Cos[\[Phi] - \[Phi]0], r cos\[Theta] Cos[\[Phi] - \[Phi]0], -r sin\[Theta] Sin[\[Phi] - \[Phi]0]}]]], "Name" -> "Uniform field"];
fieldParams = <|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "\[Psi]r" -> 0.5, "\[Psi]\[Theta]" -> 0.7|>;
fieldTimes = Range[200., 2000., 200.];

VerificationTest[
	(* Kerr is axisymmetric, so rotating both the force and the initial phi by 1.3 rotates the whole inspiral *)
	unrotated = OsculatingInspiral[<|fieldParams, "\[Phi]" -> 0, "Force" -> uniformField[0]|>, IntegrationLimit -> 2000];
	rotated = OsculatingInspiral[<|fieldParams, "\[Phi]" -> 1.3, "Force" -> uniformField[1.3]|>, IntegrationLimit -> 2000];
	Append[maxDifference[rotated, unrotated, {"p", "e", "x", "r", "\[Theta]"}, fieldTimes],
		Max[Abs[rotated["\[Phi]"][fieldTimes] - unrotated["\[Phi]"][fieldTimes] - 1.3]]]
	,
	(* Equal up to the Runge-Kutta error, about 10^-6; rotating only the force changes them by more than 10^-4 (below) *)
	{0, 0, 0, 0, 0, 0}, SameTest -> withinTolerance[{10^-6, 10^-6, 10^-8, 10^-5, 10^-5, 10^-5}],
	TestID -> "A non-axisymmetric force: rotating the force and the orbit together rotates the inspiral"
]

VerificationTest[
	(* Rotating only the force changes the inspiral, so the force really depends on phi *)
	forceOnly = OsculatingInspiral[<|fieldParams, "\[Phi]" -> 0, "Force" -> uniformField[1.3]|>, IntegrationLimit -> 2000];
	Max[maxDifference[forceOnly, unrotated, {"p", "e", "x"}, fieldTimes]] > 10^-4
	,
	True,
	TestID -> "A non-axisymmetric force: rotating only the force changes the inspiral"
]

(* Gas drag that is switched on at coordinate time t = 500 *)
lateDrag = ForceModel[Function[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t},
	UnitStep[t - 500] Rest[ForceModel["GasDrag", "Coefficient" -> 10^-5][a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t]]],
	"ScalesWithMassRatio" -> False];

VerificationTest[
	late = OsculatingInspiral[<|params, "Force" -> lateDrag|>, IntegrationLimit -> 2000];
	{Max[Abs[late["p"][Range[0., 490., 10.]] - 10]], late["p"][2000.] < 10 - 10^-4}
	,
	{0., True},
	TestID -> "A force that depends on t, in coordinate time"
]

VerificationTest[
	(* In Mino time the force still gets the coordinate time *)
	lateMino = OsculatingInspiral[<|params, "Force" -> lateDrag|>, Parametrisation -> "Mino", IntegrationLimit -> 20];
	{Max[Abs[lateMino["p"][Select[Range[0., 20., 0.1], lateMino["t"][#] < 490 &]] - 10]], lateMino["t"][20.] > 1000,
		lateMino["p"][20.] < 10 - 10^-4}
	,
	{0., True, True},
	TestID -> "A force that depends on t, in Mino time"
]
