(* ::Package:: *)

(* ::Title:: *)
(*Post-Newtonian fluxes*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Peters*)


(* ::Text:: *)
(*Peters' leading-order rates for a binary with total mass M = 1, at first order in the mass ratio \[Epsilon] (the factor m1 m2 (m1 + m2) is \[Epsilon] (1 + \[Epsilon]) \[TildeTilde] \[Epsilon]). Peters gives da/dt and de/dt for the semi-major axis a = p/(1 - e^2); in terms of p,*)
(*dp/dt = -(64/5) \[Epsilon] (1 - e^2)^(3/2) (1 + 7 e^2/8)/p^3, de/dt = -(304/15) \[Epsilon] e (1 - e^2)^(3/2) (1 + 121 e^2/304)/p^4.*)
(*They are Newtonian: they ignore the spin, and leave x unchanged.*)


petersRates[a_, p_, e_, x_] := {
	-(64/5) (1 - e^2)^(3/2) (1 + 7/8 e^2)/p^3,
	-(304/15) e (1 - e^2)^(3/2) (1 + 121/304 e^2)/p^4,
	0};

builtInFluxModels["Peters"] = FluxModel[KeyTake[<|
	"Name" -> "Peters",
	"Description" -> "Leading-order gravitational-wave fluxes of p and e; Newtonian, so independent of the spin, and x is unchanged",
	"Function" -> petersRates,
	"Parameters" -> <||>,
	"Rates" -> {"p", "e", "x"},
	"ScalesWithMassRatio" -> True,
	"ValidityCondition" -> (True &),
	"ValidityDescription" -> "p \[GreaterGreater] 1, where the leading post-Newtonian order holds",
	"Citation" -> "P. C. Peters, Gravitational radiation and the motion of two point masses, Phys. Rev. 136, B1224 (1964)"|>,
	modelKeys[FluxModel]]];
