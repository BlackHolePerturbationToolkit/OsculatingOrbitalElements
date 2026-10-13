(* ::Package:: *)

(* ::Title:: *)
(*Inspiral object*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Text:: *)
(*OsculatingInspiralFunction[assoc] holds an inspiral computed by OsculatingInspiral, as KerrGeoOrbitFunction holds a geodesic. assoc has the solver's outputs (each a function of the time variable, see regularOutputs in Solvers/KerrPEX.wl), and:*)
(*"Domain": {0, end}, the range of the time variable;*)
(*"StopReason": why the integration stopped;*)
(*"Parametrisation": "CoordinateTime" or "Mino";*)
(*"Parameters": the parameters, with the defaults filled in;*)
(*"Force": the force that drove the inspiral.*)


(* ::Section:: *)
(*Properties*)


OsculatingInspiralFunction[assoc_Association]["Properties"] := Keys[assoc];

OsculatingInspiralFunction[assoc_Association][key_String] := If[KeyExistsQ[assoc, key],
	assoc[key],
	Message[OsculatingInspiralFunction::prop, key, Keys[assoc]]; Missing["NotAvailable", key]];

(* The position {t, r, \[Theta], \[Phi]} at one time or a list of times *)
OsculatingInspiralFunction[assoc_Association][s:(_?NumericQ | {__?NumericQ})] := Through[assoc["Trajectory"][s]];

OsculatingInspiralFunction /: Keys[OsculatingInspiralFunction[assoc_Association]] := Keys[assoc];


(* ::Section:: *)
(*Summary box*)


inspiralForceName[force_] := Replace[force, {None -> "None (geodesic)", _List -> "Custom {a_t, a_r, a_\[Theta], a_\[Phi]}"}];

OsculatingInspiralFunction /: MakeBoxes[inspiral:OsculatingInspiralFunction[assoc_Association], form:(StandardForm | TraditionalForm)] :=
Module[{parameters = assoc["Parameters"], end = assoc["Domain"][[2]], summary, extended},
	summary = {
		Row[{BoxForm`SummaryItem[{"a: ", parameters["a"]}], "  ", BoxForm`SummaryItem[{"\[Epsilon]: ", parameters["\[Epsilon]"]}]}],
		Row[{BoxForm`SummaryItem[{"Initial p: ", parameters["p"]}], "  ", BoxForm`SummaryItem[{"e: ", parameters["e"]}], "  ",
			BoxForm`SummaryItem[{"x: ", parameters["x"]}]}],
		BoxForm`SummaryItem[{"Force: ", inspiralForceName[parameters["Force"]]}]};
	extended = {
		BoxForm`SummaryItem[{If[assoc["Parametrisation"] === "Mino", "Mino time: ", "Coordinate time: "], assoc["Domain"]}],
		BoxForm`SummaryItem[{"Stop reason: ", assoc["StopReason"]}],
		Row[{BoxForm`SummaryItem[{"Final p: ", assoc["p"][end]}], "  ", BoxForm`SummaryItem[{"e: ", assoc["e"][end]}], "  ",
			BoxForm`SummaryItem[{"x: ", assoc["x"][end]}]}]};
	BoxForm`ArrangeSummaryBox[OsculatingInspiralFunction, inspiral, None, summary, extended, form]
];
