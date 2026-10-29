(* ::Package:: *)

(* ::Title:: *)
(*Gas drag*)


(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*Relativistic gas drag (KerrGasDrag) as a ForceModel: F_\[Mu] = -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t), with k its \"Coefficient\". Its spatial components are -k {u_r, u_\[Theta], u_\[Phi]}, with u_\[Phi] = L, and F_t follows from orthogonality. It does not scale with the mass ratio. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


gasDragComponents[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_, parameters_] := With[{g = NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]]},
	-parameters["Coefficient"] {g["ur"], g["u\[Theta]"], g["L"]}];

builtInForceModels["GasDrag"] = ForceModel[<|
	"Name" -> "GasDrag",
	"Description" -> "Relativistic gas drag, F_\[Mu] = -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t), with k the Coefficient",
	"Function" -> gasDragComponents,
	"Parameters" -> <|"Coefficient" -> Missing["Required"]|>,
	"ScalesWithMassRatio" -> False,
	"ValidityCondition" -> (True &),
	"ValidityDescription" -> None,
	"Citation" -> "J. R. Gair, E. E. Flanagan, S. Drasco, T. Hinderer and S. Babak, Forced motion near black holes, arXiv:1012.5111, Appendix D"|>];
