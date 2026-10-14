(* ::Package:: *)

(* FluxModel and flux-driven inspirals: construction, Peters' fluxes against their analytic solution, the (E, L, Q) form,
   circular and equatorial orbits, and fluxes against the forces they average. *)

params = <|"a" -> 0.9, "\[Epsilon]" -> 10^-2, "p" -> 12, "e" -> 0.3, "x" -> 0.7|>;
drag = ForceModel["GasDrag", "Coefficient" -> 10^-5];

(* The change in an element between the first and last windows of width w, each averaged over the window, so that the
   orbital oscillations of osculating elements mostly cancel *)
windowMean[f_, t_, w_] := NIntegrate[f[s], {s, t - w/2, t + w/2}, MaxRecursion -> 20]/w;
secularChange[sol_, key_, tmax_, w_] := windowMean[sol[key], tmax - w/2, w] - windowMean[sol[key], w/2, w];
radialPeriod[a_, p_, e_, x_] := 2 Pi/Values[KerrGeoFrequencies[a, p, e, x, "Time" -> "BoyerLindquist"]][[1]];


(* ::Section:: *)
(* Construction and properties *)

VerificationTest[
	model = FluxModel[Function[{a, p, e, x, par}, par["k"] {-1, -e, 0}], "Name" -> "Test", "Parameters" -> <|"k" -> 2|>,
		"ScalesWithMassRatio" -> False];
	{Head[model], model["Name"], model["Rates"], model["Parameters"], model["ScalesWithMassRatio"], model[0.5, 10., 0.2, 0.8],
		FluxModel[model, "k" -> 3][0.5, 10., 0.2, 0.8]}
	,
	{FluxModel, "Test", {"p", "e", "x"}, <|"k" -> 2|>, False, {-2, -0.4, 0}, {-3, -0.6, 0}},
	TestID -> "A custom flux and its properties"
]

VerificationTest[
	FluxModel[{0, 0, 0} &, "Rates" -> {"a", "b", "c"}]
	,
	$Failed, {FluxModel::rates},
	TestID -> "Rates must be of (p, e, x) or (En, L, Q)"
]

VerificationTest[
	{FluxModel["Foo"], FluxModel["Peters", "Foo" -> 1], FluxModel[{0, 0, 0} &, "Colour" -> "red"], FluxModel[{1, 2} &][0.5, 10., 0.2, 0.8]}
	,
	{$Failed, $Failed, $Failed, $Failed}, {FluxModel::name, FluxModel::param, FluxModel::opt, FluxModel::output},
	TestID -> "Errors"
]

VerificationTest[
	Head[Quiet[ToBoxes[FluxModel["Peters"]], FrontEndObject::notavail]]
	,
	InterpretationBox,
	TestID -> "Summary box"
]


(* ::Section:: *)
(* In OsculatingInspiral *)

VerificationTest[
	OsculatingInspiral[params]
	,
	$Failed, {OsculatingInspiral::nodriver},
	TestID -> "A force, a flux or both is needed"
]

VerificationTest[
	OsculatingInspiral[<|params, "Flux" -> foo|>]
	,
	$Failed, {OsculatingInspiral::flux},
	TestID -> "Invalid flux"
]

VerificationTest[
	OsculatingInspiral[<|params, "Flux" -> "Peters"|>, Parametrisation -> "Mino"]
	,
	$Failed, {OsculatingInspiral::fluxtime},
	TestID -> "Fluxes need coordinate time"
]

VerificationTest[
	OsculatingInspiral[<|params, "Flux" -> FluxModel[Function[{a, p, e, x, par}, {0, 0, 0}], "Parameters" -> <|"k" -> Missing["Required"]|>]|>]
	,
	$Failed, {FluxModel::required},
	TestID -> "A required parameter with no value"
]

VerificationTest[
	insp = OsculatingInspiral[<|params, "Flux" -> {"Peters"}|>, IntegrationLimit -> 100];
	{#["Name"] & /@ insp["Flux"], insp["Force"], Head[Quiet[ToBoxes[insp], FrontEndObject::notavail]]}
	,
	{{"Peters"}, {}, InterpretationBox},
	TestID -> "The inspiral records its fluxes"
]


(* ::Section:: *)
(* Peters' fluxes *)

VerificationTest[
	FluxModel["Peters"][0, 12., 0.3, 0.7]
	,
	{-(64/5) (1 - 0.09)^(3/2) (1 + 7/8 0.09)/12^3, -(304/15) 0.3 (1 - 0.09)^(3/2) (1 + 121/304 0.09)/12^4, 0},
	SameTest -> withinTolerance[10^-16],
	TestID -> "Peters' rates"
]

VerificationTest[
	(* Peters' p and e keep p/(e^(12/19) (1 + 121 e^2/304)^(870/2299)) constant, and x does not change *)
	peters = OsculatingInspiral[<|params, "Flux" -> "Peters"|>, IntegrationLimit -> 5000];
	times = Range[0., 5000., 250.];
	constant = peters["p"][times]/(peters["e"][times]^(12/19) (1 + 121/304 peters["e"][times]^2)^(870/2299));
	{(Max[constant] - Min[constant])/Mean[constant], peters["p"][5000.] < 11.7, peters["e"][5000.] < 0.29, Max[Abs[peters["x"][times] - 0.7]]}
	,
	(* e falls by about 0.013 here, so a factor of 2 in the rate of e would change the constant by about 3% *)
	{0, True, True, 0},
	SameTest -> withinTolerance[10^-5],
	TestID -> "With Peters' fluxes p and e follow the analytic solution"
]

VerificationTest[
	(* A circular orbit stays circular, and p^4 = p0^4 - (256/5) epsilon t *)
	circular = OsculatingInspiral[<|params, "e" -> 0, "Flux" -> "Peters"|>, IntegrationLimit -> 5000];
	{Max[circular["e"][times]], Max[Abs[circular["p"][times]^4 - (12^4 - 256/5 10^-2 times)]]/12^4}
	,
	{0., 0},
	SameTest -> withinTolerance[10^-12],
	TestID -> "With Peters' fluxes a circular orbit stays circular"
]

VerificationTest[
	(* Two fluxes add: two halves of Peters' rates are Peters' rates *)
	half = FluxModel[0.5 OsculatingOrbitalElements`Private`petersRates[##] &, "Name" -> "Half Peters"];
	maxDifference[OsculatingInspiral[<|params, "Flux" -> {half, half}|>, IntegrationLimit -> 5000], peters, {"p", "e", "x", "r", "\[Phi]"},
		Range[500., 5000., 500.]]
	,
	{0, 0, 0, 0, 0}, SameTest -> withinTolerance[10^-5],
	TestID -> "Several fluxes add"
]


(* ::Section:: *)
(* Fluxes and forces together *)

VerificationTest[
	(* A zero flux leaves a force-driven inspiral exactly unchanged *)
	zero = FluxModel[{0, 0, 0} &, "Name" -> "Zero"];
	alone = OsculatingInspiral[<|params, "\[Epsilon]" -> 10^-5, "Force" -> drag|>, IntegrationLimit -> 2000];
	withZero = OsculatingInspiral[<|params, "\[Epsilon]" -> 10^-5, "Force" -> drag, "Flux" -> zero|>, IntegrationLimit -> 2000];
	maxDifference[alone, withZero, {"p", "e", "x", "r", "\[Theta]", "\[Phi]"}, Range[100., 2000., 100.]]
	,
	{0, 0, 0, 0, 0, 0}, SameTest -> withinTolerance[0],
	TestID -> "A zero flux leaves a force-driven inspiral unchanged"
]

VerificationTest[
	(* With a zero flux and no force the phases advance at their geodesic rates: the orbit is the geodesic *)
	geodesicDeviation[OsculatingInspiral[<|params, "\[Epsilon]" -> 10^-5, "Flux" -> zero|>, IntegrationLimit -> 1000],
		Lookup[params, {"a", "p", "e", "x"}], Range[100., 1000., 100.]]
	,
	{0, 0, 0}, SameTest -> withinTolerance[10^-4],
	TestID -> "With a zero flux and no force the orbit is a geodesic"
]


(* ::Section:: *)
(* Fluxes given as rates of (En, L, Q) *)

VerificationTest[
	(* The conversion to rates of p, e^2 and x agrees with OrbitalElementRates away from x = 0 *)
	Module[{a = 0.9, p = 9., e2 = 0.09, x = 0.4, rates = {-2. 10^-5, -3. 10^-4, 10^-3}, En, l, L, Q, direct},
		En = OsculatingOrbitalElements`Private`RegularEnergy[a, p, e2, x];
		l = OsculatingOrbitalElements`Private`RegularLOverX[a, p, e2, x];
		L = x l; Q = (1 - x^2) (a^2 (1 - En^2) + l^2);
		direct = OsculatingOrbitalElements`Private`OrbitalElementRates[a, {p, e2, x}, {En, L, Q}, rates];
		OsculatingOrbitalElements`Private`constantsToElementRates[a, p, e2, x, rates] - {direct["p"], direct["e2"]/(2 e2), direct["x"]}]
	,
	{0, 0, 0},
	SameTest -> withinTolerance[10^-12],
	TestID -> "(En, L, Q) rates convert to (p, e, x) rates"
]

VerificationTest[
	(* At x = 0 the rate of x is finite: dL/l *)
	Module[{a = 0.9, p = 9., e2 = 0.09, rates = {-2. 10^-5, -3. 10^-4, 10^-3}},
		OsculatingOrbitalElements`Private`constantsToElementRates[a, p, e2, 0., rates][[3]] -
			rates[[2]]/OsculatingOrbitalElements`Private`RegularLOverX[a, p, e2, 0.]]
	,
	0,
	SameTest -> withinTolerance[10^-15],
	TestID -> "The rate of x from (En, L, Q) rates is regular at x = 0"
]


(* ::Section:: *)
(* A force against its orbit-averaged flux *)

VerificationTest[
	averaged = FluxModel[drag];
	{averaged["Name"], averaged["Rates"], averaged["Parameters"], averaged["ScalesWithMassRatio"],
		(* the average converges quickly in the number of points *)
		Max[Abs[FluxModel[averaged, "Points" -> 8][0.5, 10., 0.2, 0.8] - averaged[0.5, 10., 0.2, 0.8]]/Abs[averaged[0.5, 10., 0.2, 0.8]]] < 10^-6}
	,
	{"OrbitAverage[GasDrag]", {"En", "L", "Q"}, <|"Points" -> 16|>, False, True},
	TestID -> "The orbit average of a force"
]

VerificationTest[
	(* The orbit average's weights, against KerrGeodesics: the Mino-time averages of dt/dlambda and dphi/dlambda are
	   Gamma and Upsilon_phi (the last and third of KerrGeoFrequencies' Mino-time values). dphi/dlambda ~ L/Sin[theta]^2
	   varies strongly over a near-polar orbit's polar motion, which needs more points: at x = 0.4 the error is 2 10^-3
	   with 16 points, 2 10^-6 with 32 and 3 10^-12 with 64. *)
	Table[
		With[{sums = OsculatingOrbitalElements`Private`minoTimeSums[Sequence @@ orbit, 64, {#1["dtd\[Lambda]"], #1["d\[Phi]d\[Lambda]"]} &]},
			First[sums]/Last[sums]/Values[KerrGeoFrequencies[Sequence @@ orbit, "Time" -> "Mino"]][[{4, 3}]] - 1],
		{orbit, {{0.9, 7., 0.3, 0.4}, {0.9, 9., 0.3, -0.6}, {0.5, 10., 0., 0.8}, {0.5, 10., 0.2, 1.}}}]
	,
	ConstantArray[0, {4, 2}],
	SameTest -> withinTolerance[10^-9],
	TestID -> "The orbit average gives the Mino-time averages of dt/dlambda and dphi/dlambda"
]

VerificationTest[
	(* On the equator: the averaged flux needs one polar point, and keeps x = 1 exactly *)
	equatorial = <|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 1|>;
	force = OsculatingInspiral[<|equatorial, "Force" -> drag|>, IntegrationLimit -> 3000];
	flux = OsculatingInspiral[<|equatorial, "Flux" -> averaged|>, IntegrationLimit -> 3000];
	w = 3 radialPeriod[0.5, 10., 0.2, 1.];
	{secularChange[force, "p", 3000, w] - secularChange[flux, "p", 3000, w], secularChange[force, "e", 3000, w] - secularChange[flux, "e", 3000, w],
		Max[Abs[flux["x"][Range[0., 3000., 100.]] - 1]], secularChange[flux, "p", 3000, w]}
	,
	(* the change in p is -0.475 *)
	{0, 0, 0, -0.475},
	SameTest -> withinTolerance[{10^-4, 10^-5, 0, 10^-3}],
	TestID -> "Gas drag on the equator: the force and its averaged flux give the same secular changes"
]

VerificationTest[
	(* Inclined, with 4 points in each phase *)
	inclined = <|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8|>;
	force = OsculatingInspiral[<|inclined, "Force" -> drag|>, IntegrationLimit -> 2000];
	flux = OsculatingInspiral[<|inclined, "Flux" -> FluxModel[averaged, "Points" -> 4]|>, IntegrationLimit -> 2000];
	w = 3 radialPeriod[0.5, 10., 0.2, 0.8];
	{secularChange[force, "p", 2000, w] - secularChange[flux, "p", 2000, w], secularChange[force, "e", 2000, w] - secularChange[flux, "e", 2000, w],
		(secularChange[force, "x", 2000, w] - secularChange[flux, "x", 2000, w])/secularChange[force, "x", 2000, w]}
	,
	(* the changes are -0.26 in p, 0.0012 in e and 5 10^-6 in x; the e difference is O(epsilon) *)
	{0, 0, 0},
	SameTest -> withinTolerance[{10^-3, 10^-4, 10^-2}],
	TestID -> "Gas drag on an inclined orbit: the force and its averaged flux give the same secular changes"
]

VerificationTest[
	(* One force and the averaged flux of another, against both forces *)
	schwarzschild = <|"a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 1|>;
	both = OsculatingInspiral[<|schwarzschild, "Force" -> {drag, "FastGSF"}|>, IntegrationLimit -> 3000];
	mixed = OsculatingInspiral[<|schwarzschild, "Force" -> drag, "Flux" -> FluxModel[ForceModel["FastGSF"]]|>, IntegrationLimit -> 3000];
	w = 3 radialPeriod[0., 10., 0.1, 1.];
	{secularChange[both, "p", 3000, w] - secularChange[mixed, "p", 3000, w], secularChange[both, "e", 3000, w] - secularChange[mixed, "e", 3000, w]}
	,
	(* the changes are -0.65 in p and 0.0022 in e; the e difference is O(epsilon) *)
	{0, 0},
	SameTest -> withinTolerance[{10^-3, 5*10^-4}],
	TestID -> "Gas drag and FastGSF: drag plus the averaged FastGSF flux agrees with both forces"
]


(* ::Section:: *)
(* A flux that changes x *)

VerificationTest[
	(* The polar components follow x, so (alpha_theta, beta_theta, x) stays a unit vector, up to the integration error.
	   Then the largest cos(theta) over a polar oscillation, Sqrt[alpha_theta^2 + beta_theta^2], is Sqrt[1 - x^2]. With
	   the flux's term in the polar components wrong in sign, the length would change by about 0.2 here. *)
	tilt = FluxModel[Function[{a, p, e, x}, {0, 0, -2 10^-4 (1 - x^2)}], "Name" -> "Tilt", "ScalesWithMassRatio" -> False];
	tilted = OsculatingInspiral[<|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Flux" -> tilt|>, IntegrationLimit -> 3000];
	times = Range[0., 3000., 1.];
	{tilted["x"][3000.] < 0.75, Max[Abs[tilted["\[Alpha]\[Theta]"][times]^2 + tilted["\[Beta]\[Theta]"][times]^2 + tilted["x"][times]^2 - 1]]}
	,
	{True, 0},
	SameTest -> (First[#1] && withinTolerance[10^-5][Last[#1], Last[#2]] &),
	TestID -> "A flux that changes x: the polar components follow it"
]
