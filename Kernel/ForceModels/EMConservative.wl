(* ::Package:: *)

(* ::Title:: *)
(*Conservative electromagnetic force*)


(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*KerrEMCons as a ForceModel, with the same normalisation: no parameters, and scaled by the mass ratio. Its velocities come from the regular geometry, so unlike KerrEMCons it holds at x = 0. F_t follows from orthogonality. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


emConservativeComponents[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_] := Module[{g, r, z, \[CapitalSigma], \[CapitalDelta], ur, u\[Theta], utup, u\[Phi]up, radial},
	g = NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]];
	{r, \[CapitalSigma], \[CapitalDelta], ur, u\[Theta], utup, u\[Phi]up} =
		Lookup[g, {"r", "\[CapitalSigma]", "\[CapitalDelta]", "ur", "u\[Theta]", "dtd\[Lambda]", "d\[Phi]d\[Lambda]"}];
	(* z is cos \[Theta] *)
	z = Sqrt[1 - x^2] Cos[\[Psi]\[Theta]];
	radial = r^5 + 2 r^3 a^2 + r a^4 + 2 a^2 r^2 - 2 a^4 + a^4 (r - 1) (1 - z^2)^2 - a^2 (2 r a^2 - 3 a^2 + 2 r^3 + r^2) (1 - z^2);
	{
		1/\[CapitalSigma]^3 (a (1 + z^2) (a^2 z^2 - r^2) utup + u\[Phi]up (1 - z^2) radial),
		1/\[CapitalSigma]^3 z Sqrt[1 - z^2] (2 a r (a^2 - r^2) utup + (r^6 + a^2 r^4 - 2 a^4 r + 2 a^2 r^2 \[CapitalDelta] z^2 + a^4 \[CapitalDelta] z^4) u\[Phi]up),
		-1/\[CapitalSigma]^3 ((1 - z^2) radial \[CapitalDelta] ur + z Sqrt[1 - z^2] (r^6 + a^2 r^4 - 2 a^4 r + 2 a^2 r^2 \[CapitalDelta] z^2 + a^4 \[CapitalDelta] z^4) u\[Theta])
	}
];

builtInForceModels["EMConservative"] = ForceModel[<|
	"Name" -> "EMConservative",
	"Description" -> "The conservative electromagnetic force of KerrEMCons",
	"Function" -> emConservativeComponents,
	"Parameters" -> <||>,
	"ScalesWithMassRatio" -> True,
	"ValidityCondition" -> (True &),
	"ValidityDescription" -> None,
	"Citation" -> None|>];
