(* ::Package:: *)

(* Bad input returns $Failed with a message, each stopping condition reports itself with a message, and the
   Parametrisation and IntegrationLimit options behave as documented. FindRoot::brmp comes from KerrGeoOrbitType,
   which the ELK solver calls, and is suppressed. *)

kerrArgs = {10^-3, 0.5, 10, 0.2, 0.8, 0, 0};


(* ::Section:: *)
(* Bad input *)

VerificationTest[
	SchwarzOsculatingOrbitalElements[10^-2, 5, 0.2, 0]
	,
	$Failed, {SchwarzOsculatingOrbitalElements::ICs},
	TestID -> "SchwarzOsculatingOrbitalElements: orbit inside the separatrix"
]

VerificationTest[
	SchwarzOsculatingOrbitalElementsTP[10^-2, 5, 0.2, 0]
	,
	$Failed, {SchwarzOsculatingOrbitalElements::ICs},
	TestID -> "SchwarzOsculatingOrbitalElementsTP: orbit inside the separatrix"
]

VerificationTest[
	Quiet[KerrOsculatingOrbitalElements[10^-2, 0.5, 3, 0.2, 0.8, 0, 0], FindRoot::brmp]
	,
	$Failed, {KerrOsculatingOrbitalElements::ICs},
	TestID -> "KerrOsculatingOrbitalElements: unbound orbit"
]

VerificationTest[
	SchwarzOsculatingOrbitalElements[10^-2, 10, 0.2, 0, Force -> foo]
	,
	$Failed, {SchwarzOsculatingOrbitalElements::InvalidForce},
	TestID -> "SchwarzOsculatingOrbitalElements: invalid force"
]

VerificationTest[
	SchwarzOsculatingOrbitalElementsTP[10^-2, 10, 0.2, 0, Force -> foo]
	,
	$Failed, {SchwarzOsculatingOrbitalElements::InvalidForce},
	TestID -> "SchwarzOsculatingOrbitalElementsTP: invalid force"
]

VerificationTest[
	Quiet[KerrOsculatingOrbitalElements[Sequence @@ kerrArgs, Force -> foo], FindRoot::brmp]
	,
	$Failed, {KerrOsculatingOrbitalElements::InvalidForce},
	TestID -> "KerrOsculatingOrbitalElements: invalid force"
]

VerificationTest[
	GenericKerrpexBL[Sequence @@ kerrArgs, Force -> foo]
	,
	$Failed, {KerrOsculatingOrbitalElements::InvalidForce},
	TestID -> "GenericKerrpexBL: invalid force"
]

VerificationTest[
	GenericKerrREGBL[Sequence @@ kerrArgs, Force -> foo]
	,
	$Failed, {KerrOsculatingOrbitalElements::InvalidForce},
	TestID -> "GenericKerrREGBL: invalid force"
]

VerificationTest[
	KerrOsculatingOrbitalElements[Sequence @@ kerrArgs, Parametrisation -> "foo"]
	,
	$Failed, {KerrOsculatingOrbitalElements::param},
	TestID -> "KerrOsculatingOrbitalElements: invalid Parametrisation"
]

VerificationTest[
	GenericKerrpexBL[Sequence @@ kerrArgs, Parametrisation -> foo]
	,
	$Failed, {KerrOsculatingOrbitalElements::param},
	TestID -> "GenericKerrpexBL: invalid Parametrisation"
]

VerificationTest[
	GenericKerrREGBL[Sequence @@ kerrArgs, Parametrisation -> "foo"]
	,
	$Failed, {KerrOsculatingOrbitalElements::param},
	TestID -> "GenericKerrREGBL: invalid Parametrisation"
]


(* ::Section:: *)
(* Stopping conditions *)

VerificationTest[
	AssociationQ[GenericKerrpexBL[Sequence @@ kerrArgs]]
	,
	True, {KerrOsculatingOrbitalElements::sep},
	TestID -> "GenericKerrpexBL stops at the separatrix"
]

VerificationTest[
	(* e0 < 100 eta selects the small-e branch, which stops at a buffer outside the separatrix *)
	AssociationQ[GenericKerrpexBL[10^-3, 0.5, 10, 10^-4, 0.8, 0, 0]]
	,
	True, {KerrOsculatingOrbitalElements::sepbuf},
	TestID -> "GenericKerrpexBL, small e: stops at the separatrix buffer"
]

VerificationTest[
	AssociationQ[GenericKerrREGBL[Sequence @@ kerrArgs]]
	,
	True, {KerrOsculatingOrbitalElements::sepbuf},
	TestID -> "GenericKerrREGBL stops at the separatrix buffer"
]

VerificationTest[
	sol = GenericKerrREGBL[Sequence @@ kerrArgs, pMin -> 9];
	sol["p"][sol["limit"]]
	,
	9, {KerrOsculatingOrbitalElements::pmin}, SameTest -> withinTolerance[10^-6],
	TestID -> "GenericKerrREGBL stops at pMin"
]

VerificationTest[
	Quiet[AssociationQ[KerrOsculatingOrbitalElements[Sequence @@ kerrArgs]], FindRoot::brmp]
	,
	True, {KerrOsculatingOrbitalElements::sep},
	TestID -> "KerrOsculatingOrbitalElements stops at the separatrix"
]

VerificationTest[
	AssociationQ[SchwarzOsculatingOrbitalElements[10^-3, 12, 0.3, 0]]
	,
	True, {SchwarzOsculatingOrbitalElements::sep},
	TestID -> "SchwarzOsculatingOrbitalElements stops at the separatrix"
]

VerificationTest[
	AssociationQ[SchwarzOsculatingOrbitalElementsTP[10^-3, 12, 0.03, 0]]
	,
	True, {SchwarzOsculatingOrbitalElements::sep},
	TestID -> "SchwarzOsculatingOrbitalElementsTP, small e: stops at the separatrix"
]


(* ::Section:: *)
(* IntegrationLimit is in the units of the chosen time variable *)

VerificationTest[
	GenericKerrpexBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, IntegrationLimit -> 500]["limit"]
	,
	500., {KerrOsculatingOrbitalElements::limit},
	TestID -> "GenericKerrpexBL: IntegrationLimit -> 500 integrates to t = 500"
]

VerificationTest[
	Quiet[KerrOsculatingOrbitalElements[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, Parametrisation -> "Mino", IntegrationLimit -> 3]["limit"], FindRoot::brmp]
	,
	3., {KerrOsculatingOrbitalElements::limit},
	TestID -> "KerrOsculatingOrbitalElements, Mino: IntegrationLimit -> 3 integrates to lambda = 3"
]

VerificationTest[
	SchwarzOsculatingOrbitalElementsTP[10^-5, 12, 0.03, 0, IntegrationLimit -> 300]["limit"]
	,
	300., {SchwarzOsculatingOrbitalElements::limit},
	TestID -> "SchwarzOsculatingOrbitalElementsTP: IntegrationLimit -> 300 integrates to t = 300"
]


(* ::Section:: *)
(* Parametrisation accepts strings and symbols *)

VerificationTest[
	sol = quietStops@GenericKerrpexBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, Parametrisation -> Mino, IntegrationLimit -> 0.5];
	{Head[sol["t"]], sol["limit"]}
	,
	{InterpolatingFunction, 0.5},
	TestID -> "GenericKerrpexBL: Parametrisation -> Mino (symbol) integrates in Mino time"
]

VerificationTest[
	sol = quietStops@GenericKerrREGBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, Parametrisation -> "Mino", IntegrationLimit -> 0.5];
	{Head[sol["t"]], sol["limit"]}
	,
	{InterpolatingFunction, 0.5},
	TestID -> "GenericKerrREGBL: Parametrisation -> \"Mino\" integrates in Mino time"
]

VerificationTest[
	sol = quietStops@GenericKerrpexBL[10^-5, 0.5, 10, 0.2, 0.8, 0, 0, Parametrisation -> CoordinateTime, IntegrationLimit -> 500];
	{sol["t"][100.], sol["limit"]}
	,
	{100., 500.},
	TestID -> "GenericKerrpexBL: Parametrisation -> CoordinateTime (symbol) integrates in coordinate time"
]
