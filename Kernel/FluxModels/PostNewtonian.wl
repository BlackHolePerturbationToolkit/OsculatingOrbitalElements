(* ::Package:: *)

(* ::Title:: *)
(*Post-Newtonian fluxes*)


(* ::Section:: *)
(*Peters*)


(* ::Text:: *)
(*Peters' leading-order rates for total mass M = 1, at first order in the mass ratio \[Epsilon] (m1 m2 (m1 + m2) = \[Epsilon] (1 + \[Epsilon]) \[TildeTilde] \[Epsilon]), from his da/dt and de/dt with a = p/(1 - e^2):*)
(*dp/dt = -(64/5) \[Epsilon] (1 - e^2)^(3/2) (1 + 7 e^2/8)/p^3, de/dt = -(304/15) \[Epsilon] e (1 - e^2)^(3/2) (1 + 121 e^2/304)/p^4.*)
(*They are Newtonian: independent of the spin, with x unchanged. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


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
