(* ::Package:: *)

(* ::Title:: *)
(*Inspiral object*)


(* ::Text:: *)
(*OsculatingInspiralFunction[assoc] holds an inspiral, as KerrGeoOrbitFunction holds a geodesic. assoc has the solver's outputs (functions of the time variable; see regularOutputs in Solvers/KerrPEX.wl), "Domain" ({0, end}), "StopReason", "Parametrisation" ("CoordinateTime" or "Mino"), "Parameters" (with the defaults filled in), and "Force" and "Flux" (lists of models). Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


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


inspiralModelNames[models_List] := If[models === {}, "None", Row[#["Name"] & /@ models, ", "]];

OsculatingInspiralFunction /: MakeBoxes[inspiral:OsculatingInspiralFunction[assoc_Association], form:(StandardForm | TraditionalForm)] :=
Module[{parameters = assoc["Parameters"], end = assoc["Domain"][[2]], summary, extended},
	summary = {
		Row[{BoxForm`SummaryItem[{"a: ", parameters["a"]}], "  ", BoxForm`SummaryItem[{"\[Epsilon]: ", parameters["\[Epsilon]"]}]}],
		Row[{BoxForm`SummaryItem[{"Initial p: ", parameters["p"]}], "  ", BoxForm`SummaryItem[{"e: ", parameters["e"]}], "  ",
			BoxForm`SummaryItem[{"x: ", parameters["x"]}]}],
		BoxForm`SummaryItem[{"Force: ", inspiralModelNames[assoc["Force"]]}],
		BoxForm`SummaryItem[{"Flux: ", inspiralModelNames[assoc["Flux"]]}]};
	extended = {
		BoxForm`SummaryItem[{If[assoc["Parametrisation"] === "Mino", "Mino time: ", "Coordinate time: "], assoc["Domain"]}],
		BoxForm`SummaryItem[{"Stop reason: ", assoc["StopReason"]}],
		Row[{BoxForm`SummaryItem[{"Final p: ", assoc["p"][end]}], "  ", BoxForm`SummaryItem[{"e: ", assoc["e"][end]}], "  ",
			BoxForm`SummaryItem[{"x: ", assoc["x"][end]}]}]};
	BoxForm`ArrangeSummaryBox[OsculatingInspiralFunction, inspiral, None, summary, extended, form]
];
