(* ::Package:: *)

(* ::Title:: *)
(*Regression cases*)


(* ::Text:: *)
(*Fixed solver outputs that Regression.wlt compares with ReferenceOutputs.wl. MakeReferenceOutputs.wls evaluates the same cases to create that file. Each case evaluates to a flat list of machine numbers. Load TestSetup.wl first.*)


emForce = {KerrEMCons[##]["at"] &, KerrEMCons[##]["ar"] &, KerrEMCons[##]["a\[Theta]"] &, KerrEMCons[##]["a\[Phi]"] &};
kerrArgs = {10^-5, 0.5, 10, 0.2, 0.8, 0, 0};

(* The integration limit followed by the given outputs at the end of the integration *)
summary[sol_, keys_List] := Join[{sol["limit"]}, endValues[sol, keys]];

(* The same for an inspiral from OsculatingInspiral *)
inspiralSummary[insp_, keys_List] := With[{end = insp["Domain"][[2]]}, Join[{end}, insp[#][end] & /@ keys]];
inspiralParams = <|"a" -> 0.5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "\[Psi]r" -> 0.3, "\[Psi]\[Theta]" -> 0.4, "Force" -> ForceModel["GasDrag", "Coefficient" -> 10^-5]|>;

regressionCases = <|

	"Schwarzschild Darwin parameter, gas drag, e0 = 0.3" :>
		With[{sol = quietStops@SchwarzOsculatingOrbitalElements[10^-4, 20, 0.3, 0.2]},
			Append[summary[sol, {"t", "p", "e", "\[Xi]", "\[Phi]"}], sol["r"][20.]]],

	"Schwarzschild Darwin parameter, gas drag, e0 = 0.03" :>
		With[{sol = quietStops@SchwarzOsculatingOrbitalElements[10^-4, 20, 0.03, 0.2]},
			Append[summary[sol, {"t", "p", "e", "\[Xi]", "\[Phi]"}], sol["r"][20.]]],

	"Schwarzschild coordinate time, gas drag, e0 = 0.3" :>
		With[{sol = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 20, 0.3, 0.2]},
			Append[summary[sol, {"p", "e", "\[Xi]", "\[Phi]"}], sol["r"][1000.]]],

	"Schwarzschild coordinate time, gas drag, e0 = 0.03" :>
		With[{sol = quietStops@SchwarzOsculatingOrbitalElementsTP[10^-4, 20, 0.03, 0.2]},
			Append[summary[sol, {"p", "e", "\[Xi]", "\[Phi]"}], sol["r"][1000.]]],

	"SchwarzFastGSF values" :>
		Flatten[Values /@ {SchwarzFastGSF[10., 0.1, 0.3], SchwarzFastGSF[8.5, 0.15, 2.1], SchwarzFastGSF[11., 0.1, 1.]}],

	"Schwarzschild Darwin parameter, FastGSF" :>
		summary[quietStops@SchwarzOsculatingOrbitalElements[10^-5, 10, 0.1, 0, Force -> SchwarzFastGSF, IntegrationLimit -> 200],
			{"t", "p", "e", "\[Xi]", "\[Phi]"}],

	"ELK, gas drag" :>
		summary[quietStops@KerrOsculatingOrbitalElements[Sequence @@ kerrArgs, IntegrationLimit -> 2000],
			{"En", "L", "K", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}],

	"ELK, Mino time" :>
		summary[quietStops@KerrOsculatingOrbitalElements[Sequence @@ kerrArgs, Parametrisation -> "Mino", IntegrationLimit -> 0.5],
			{"En", "L", "K", "t", "\[Phi]"}],

	"pex, gas drag" :>
		summary[quietStops@GenericKerrpexBL[Sequence @@ kerrArgs, IntegrationLimit -> 5000],
			{"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}],

	"pex, electromagnetic force" :>
		summary[quietStops@GenericKerrpexBL[Sequence @@ kerrArgs, Force -> emForce, IntegrationLimit -> 5000],
			{"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}],

	"pex, small-e branch" :>
		summary[quietStops@GenericKerrpexBL[10^-5, 0.5, 10, 5*10^-4, 0.8, 0, 0, IntegrationLimit -> 5000],
			{"p", "e", "x", "\[Psi]r", "\[Phi]"}],

	"pex, Mino time" :>
		summary[quietStops@GenericKerrpexBL[Sequence @@ kerrArgs, Parametrisation -> "Mino", IntegrationLimit -> 0.5],
			{"p", "e", "x", "t", "\[Phi]"}],

	"pex, equatorial x0 = 1" :>
		summary[quietStops@GenericKerrpexBL[10^-4, 0.5, 12, 0.3, 1, 0.7, 0, IntegrationLimit -> 20000],
			{"p", "e", "\[Psi]r", "\[Phi]"}],

	"REG, gas drag" :>
		summary[quietStops@GenericKerrREGBL[Sequence @@ kerrArgs, IntegrationLimit -> 5000],
			{"p", "\[Alpha]p", "\[Beta]p", "x", "\[Psi]\[Theta]", "\[Phi]"}],

	"REG, e0 = 0" :>
		summary[quietStops@GenericKerrREGBL[10^-5, 0.5, 10, 0, 0.8, 0, 0, IntegrationLimit -> 5000],
			{"p", "\[Alpha]p", "\[Beta]p", "x", "\[Psi]\[Theta]", "\[Phi]"}],

	"REG, Mino time" :>
		summary[quietStops@GenericKerrREGBL[Sequence @@ kerrArgs, Parametrisation -> "Mino", IntegrationLimit -> 0.5],
			{"p", "\[Alpha]p", "\[Beta]p", "x", "t", "\[Phi]"}],

	"REG, equatorial x0 = -1." :>
		summary[quietStops@GenericKerrREGBL[10^-4, 0.5, 12, 0.3, -1., 0.7, 0, IntegrationLimit -> 20000],
			{"p", "\[Alpha]p", "\[Beta]p", "\[Phi]"}],

	"OsculatingInspiral, gas drag" :>
		inspiralSummary[OsculatingInspiral[inspiralParams, IntegrationLimit -> 2000],
			{"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]", "r", "\[Theta]"}],

	"OsculatingInspiral, e0 = 0" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "e" -> 0|>, IntegrationLimit -> 2000],
			{"p", "\[Alpha]p", "\[Beta]p", "x", "\[Phi]", "r"}],

	"OsculatingInspiral, a = 0, x0 = 1" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "a" -> 0, "x" -> 1|>, IntegrationLimit -> 2000],
			{"p", "e", "x", "\[Psi]r", "\[Phi]", "r"}],

	"OsculatingInspiral, Mino time" :>
		inspiralSummary[OsculatingInspiral[inspiralParams, Parametrisation -> "Mino", IntegrationLimit -> 10],
			{"t", "p", "e", "x", "\[Phi]"}],

	"OsculatingInspiral, electromagnetic force" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "Force" -> "EMConservative"|>, IntegrationLimit -> 2000],
			{"p", "e", "x", "\[Psi]r", "\[Phi]"}],

	"OsculatingInspiral, to the separatrix buffer" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "a" -> 0.9, "\[Epsilon]" -> 10^-3, "p" -> 12, "e" -> 0.3, "x" -> 0.5,
			"Force" -> ForceModel["GasDrag", "Coefficient" -> 10^-3]|>],
			{"p", "e", "x", "\[Phi]"}],

	"OsculatingInspiral, FastGSF" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "a" -> 0, "\[Epsilon]" -> 10^-3, "p" -> 10, "e" -> 0.1, "x" -> 1, "Force" -> "FastGSF"|>,
			IntegrationLimit -> 2000], {"p", "e", "\[Psi]r", "\[Phi]", "r"}],

	"Force models" :>
		Flatten[{
			ForceModel["GasDrag", "Coefficient" -> 1][0.5, 10., 0.2, 0.8, 0.3, 0.4, 1.1, 50.],
			ForceModel["EMConservative"][0.5, 10., 0.2, 0.8, 0.3, 0.4, 1.1, 50.],
			ForceModel["FastGSF"][0, 10., 0.1, 1., 0.3, 0., 1.1, 50.],
			ForceModel["FastGSF"][0, 10., 0.1, 0.6, 0.3, 0.7, 1.1, 50.]}],

	"OsculatingInspiral, Peters flux" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "a" -> 0.9, "\[Epsilon]" -> 10^-2, "p" -> 12, "e" -> 0.3, "x" -> 0.7, "Force" -> None,
			"Flux" -> "Peters"|>, IntegrationLimit -> 3000], {"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]", "r"}],

	"OsculatingInspiral, averaged gas drag flux on the equator" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "x" -> 1, "Force" -> None,
			"Flux" -> FluxModel[ForceModel["GasDrag", "Coefficient" -> 10^-5]]|>, IntegrationLimit -> 1000], {"p", "e", "x", "\[Psi]r", "\[Phi]"}],

	"OsculatingInspiral, force and flux" :>
		inspiralSummary[OsculatingInspiral[<|inspiralParams, "Flux" -> "Peters"|>, IntegrationLimit -> 2000],
			{"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}],

	"Flux models" :>
		Flatten[{
			FluxModel["Peters"][0.9, 12., 0.3, 0.7],
			FluxModel[ForceModel["GasDrag", "Coefficient" -> 1], "Points" -> 8][0.5, 10., 0.2, 0.8],
			OsculatingOrbitalElements`Private`constantsToElementRates[0.9, 9., 0.09, 0.4, {-2. 10^-5, -3. 10^-4, 10^-3}],
			OsculatingOrbitalElements`Private`constantsToElementRates[0.9, 9., 0.09, 0., {-2. 10^-5, -3. 10^-4, 10^-3}]}] + 0.,

	"Regular constants of motion" :>
		Flatten[Table[
			{OsculatingOrbitalElements`Private`RegularEnergy @@ orbit, OsculatingOrbitalElements`Private`RegularLOverX @@ orbit},
			{orbit, {{0.5, 10., 0.04, 0.8}, {0.9, 7.5, 0.25, -0.3}, {0.5, 10., 0., 0.8}, {0.9, 10., 0.04, 0.}, {0., 10., 0.09, 1.}}}]],

	"Constants of motion" :>
		Flatten[Table[
			{OsculatingOrbitalElements`Private`Energy @@ orbit,
			 OsculatingOrbitalElements`Private`AngularMomentum @@ orbit,
			 OsculatingOrbitalElements`Private`CarterConstant @@ orbit},
			{orbit, {{0.5, 10., 0.2, 0.8}, {0.9, 7.5, 0.5, 0.3}, {0.5, 10., 0, 0.8}, {0.5, 10., 0.2, 1}}}]],

	"Gas drag and electromagnetic force values" :>
		(* KerrGasDrag and KerrGasDragVec take En, L and K = Q + (L - a En)^2; use those of {a, p, e, x} = {0.5, 10, 0.2, 0.8} *)
		With[{constants = Values[KerrGeoConstantsOfMotion[0.5, 10., 0.2, 0.8]]},
		With[{elk = {constants[[1]], constants[[2]], constants[[3]] + (constants[[2]] - 0.5 constants[[1]])^2}},
		Flatten[{
			Values[KerrGasDrag[0.5, Sequence @@ elk, 0.3, 0.4]],
			Values[KerrGasDragVec[0.5, Sequence @@ elk, 0.3, 0.4]],
			Values[OsculatingOrbitalElements`Private`KerrGasDragapex[0.5, 10., 0.2, 0.8, 0.3, 0.4]],
			Values[OsculatingOrbitalElements`Private`KerrGasDragapex[0, 10., 0.2, 0.8, 0.3, 0.4]],
			Values[KerrEMCons[0.5, 10., 0.2, 0.8, 0.3, 0.4]],
			Values[SchwarzGasDrag[10., 0.2, 0.3]]}]]]
|>;
