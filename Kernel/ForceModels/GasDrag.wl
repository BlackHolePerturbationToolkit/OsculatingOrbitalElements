(* ::Package:: *)

(* ::Title:: *)
(*Gas drag*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*The relativistic gas drag of KerrGasDrag as a ForceModel, with strength k, its "Coefficient": F_\[Mu] = -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t). Its spatial components are -k {u_r, u_\[Theta], u_\[Phi]}, with u_\[Phi] = L, and F_t follows from orthogonality. It does not scale with the mass ratio.*)


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
