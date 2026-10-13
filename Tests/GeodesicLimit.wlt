(* ::Package:: *)

(* Geodesic limit: with eta = 1e-10 every solver, in each of its branches, should follow the geodesic from KerrGeodesics.
   Compares r, Cos[theta] and phi over 1000 M of coordinate time. *)

$eta = 10^-10;
$times = Range[100., 1000., 100.];
$tolerance = 10^-4;


(* ::Section:: *)
(* Schwarzschild *)

VerificationTest[
	sol = quietStops@SchwarzOsculatingOrbitalElementsTP[$eta, 10, 0.5, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0, 10, 0.5, 1}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "SchwarzOsculatingOrbitalElementsTP, e0 = 0.5 (p, e, xi equations)"
]

VerificationTest[
	sol = quietStops@SchwarzOsculatingOrbitalElementsTP[$eta, 10, 0.04, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0, 10, 0.04, 1}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "SchwarzOsculatingOrbitalElementsTP, e0 = 0.04 (p, alpha, beta equations)"
]

VerificationTest[
	sol = quietStops@SchwarzOsculatingOrbitalElements[$eta, 10, 0.5, 0, IntegrationLimit -> 10];
	geodesicDeviation[sol, {0, 10, 0.5, 1}, Range[1., 10., 1.], sol["t"]]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "SchwarzOsculatingOrbitalElements, e0 = 0.5 (p, e, xi equations)"
]

VerificationTest[
	sol = quietStops@SchwarzOsculatingOrbitalElements[$eta, 10, 0.04, 0, IntegrationLimit -> 10];
	geodesicDeviation[sol, {0, 10, 0.04, 1}, Range[1., 10., 1.], sol["t"]]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "SchwarzOsculatingOrbitalElements, e0 = 0.04 (p, alpha, beta equations)"
]


(* ::Section:: *)
(* Kerr, inclined *)

VerificationTest[
	sol = quietStops@KerrOsculatingOrbitalElements[$eta, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0.2, 0.8}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "KerrOsculatingOrbitalElements (ELK)"
]

VerificationTest[
	sol = quietStops@GenericKerrpexBL[$eta, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0.2, 0.8}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrpexBL, e0 = 0.2 (p, e, psi_r equations)"
]

VerificationTest[
	(* e0 < 100 eta selects the small-e branch *)
	sol = quietStops@GenericKerrpexBL[$eta, 0.5, 10, 10^-9, 0.8, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 10^-9, 0.8}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrpexBL, e0 = 1e-9 (small-e branch)"
]

VerificationTest[
	sol = quietStops@GenericKerrREGBL[$eta, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0.2, 0.8}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrREGBL, e0 = 0.2"
]

VerificationTest[
	sol = quietStops@GenericKerrREGBL[$eta, 0.5, 10, 0, 0.8, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0, 0.8}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrREGBL, e0 = 0"
]


(* ::Section:: *)
(* Kerr, equatorial *)

VerificationTest[
	sol = quietStops@GenericKerrpexBL[$eta, 0.5, 10, 0.2, 1, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0.2, 1}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrpexBL, equatorial prograde x0 = 1"
]

VerificationTest[
	sol = quietStops@GenericKerrREGBL[$eta, 0.5, 10, 0.2, -1, 0, 0, IntegrationLimit -> 1000];
	geodesicDeviation[sol, {0.5, 10, 0.2, -1}, $times]
	,
	{0, 0, 0}, SameTest -> withinTolerance[$tolerance],
	TestID -> "GenericKerrREGBL, equatorial retrograde x0 = -1"
]
