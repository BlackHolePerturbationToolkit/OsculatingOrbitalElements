(* ::Package:: *)

(* ::Title:: *)
(*Interface*)


(* ::Text:: *)
(*OsculatingInspiral, and what the solvers share: reading options and integrating with NDSolve. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Section:: *)
(*OsculatingInspiral*)


(* ::Text:: *)
(*The parameters: their keys, which are required, the defaults of the others, and their allowed values. \"Force\", \"Flux\" or both is required too. \[CurlyEpsilon] and \[CurlyPhi] are accepted for \[Epsilon] and \[Phi].*)


$inspiralParameterKeys = {"a", "\[Epsilon]", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]", "Force", "Flux"};
$requiredInspiralParameters = {"a", "\[Epsilon]", "p", "e", "x"};
$inspiralParameterDefaults = <|"\[Psi]r" -> 0, "\[Psi]\[Theta]" -> 0, "\[Phi]" -> 0, "Force" -> None, "Flux" -> None|>;
$inspiralParameterAliases = {"\[CurlyEpsilon]" -> "\[Epsilon]", "\[CurlyPhi]" -> "\[Phi]"};

realQ[v_] := NumericQ[v] && TrueQ[Im[v] == 0];
$inspiralParameterRanges = {
	{"a", realQ[#] && 0 <= # < 1 &, "a real number with 0 \[LessEqual] a < 1"},
	{"\[Epsilon]", realQ[#] && # > 0 &, "a positive real number"},
	{"p", realQ[#] && # > 0 &, "a positive real number"},
	{"e", realQ[#] && 0 <= # < 1 &, "a real number with 0 \[LessEqual] e < 1"},
	{"x", realQ[#] && -1 <= # <= 1 &, "a real number with -1 \[LessEqual] x \[LessEqual] 1"},
	{"\[Psi]r", realQ, "a real number"},
	{"\[Psi]\[Theta]", realQ, "a real number"},
	{"\[Phi]", realQ, "a real number"}};


(* ::Text:: *)
(*The parameters with the defaults filled in, in a fixed order, or $Failed with a message. Whether the orbit is bound is checked by the solver, which knows the separatrix buffer.*)


InspiralParameters[params_Association] := Module[{parameters, unknown, missing, bad},
	parameters = KeyMap[Replace[$inspiralParameterAliases], params];
	unknown = Complement[Keys[parameters], $inspiralParameterKeys];
	If[unknown =!= {}, Message[OsculatingInspiral::unknown, unknown, $inspiralParameterKeys]; Return[$Failed]];
	missing = Complement[$requiredInspiralParameters, Keys[parameters]];
	If[missing =!= {}, Message[OsculatingInspiral::missing, missing]; Return[$Failed]];
	If[!KeyExistsQ[parameters, "Force"] && !KeyExistsQ[parameters, "Flux"], Message[OsculatingInspiral::nodriver]; Return[$Failed]];
	parameters = Join[$inspiralParameterDefaults, parameters];
	bad = SelectFirst[$inspiralParameterRanges, !TrueQ[#[[2]][parameters[#[[1]]]]] &];
	If[!MissingQ[bad], Message[OsculatingInspiral::range, bad[[1]], parameters[bad[[1]]], bad[[3]]]; Return[$Failed]];
	If[TrueQ[parameters["x"] == 0], Message[OsculatingInspiral::polar]; Return[$Failed]];
	KeyTake[parameters, $inspiralParameterKeys]
];


(* ::Text:: *)
(*The entry point, using the regular solver (regularSystem in Solvers/KerrPEX.wl). Normal stops are recorded in \"StopReason\"; only an early stop by NDSolve gives a message.*)


OsculatingInspiral[params_Association, opts:OptionsPattern[{OsculatingInspiral, NDSolve}]] := Module[{parameters, forces, fluxes, result},
	parameters = InspiralParameters[params];
	If[FailureQ[parameters], Return[$Failed]];
	(* The forces and fluxes as lists of models, each checked at the initial orbit *)
	forces = inspiralForceModels[parameters["Force"]];
	If[FailureQ[forces], Return[$Failed]];
	forces = checkForceModels[forces, Append[Lookup[parameters, {"a", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}], 0]];
	If[FailureQ[forces], Return[$Failed]];
	fluxes = inspiralFluxModels[parameters["Flux"]];
	If[FailureQ[fluxes], Return[$Failed]];
	fluxes = checkFluxModels[fluxes, Lookup[parameters, {"a", "p", "e", "x"}]];
	If[FailureQ[fluxes], Return[$Failed]];
	result = RunSolver[OsculatingInspiral, regularSystem, Join[forceModelDriver /@ #["Forces"], fluxModelDriver /@ #["Fluxes"]] &,
		parameters["\[Epsilon]"], parameters["a"], Lookup[parameters, {"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}], {opts},
		<|"Force" -> <|"Forces" -> forces, "Fluxes" -> fluxes|>, "MessageHead" -> OsculatingInspiral, "ReportStops" -> {"Other"}|>];
	If[FailureQ[result], Return[$Failed]];
	OsculatingInspiralFunction[Join[KeyDrop[result, "limit"], <|
		"Domain" -> {0, result["limit"]},
		"Parametrisation" -> If[MinoParametrisationQ[OptionValue[Parametrisation], OsculatingInspiral], "Mino", "CoordinateTime"],
		"Parameters" -> parameters,
		"Force" -> forces,
		"Flux" -> fluxes|>]]
];

OsculatingInspiral[params_ /; !AssociationQ[params], ___] := (Message[OsculatingInspiral::params, params]; $Failed);


(* ::Section:: *)
(*Options*)


(* ::Text:: *)
(*True for Mino time and False for coordinate time, given as a string or a symbol; otherwise $Failed with head's param message.*)


MinoParametrisationQ[param_, head_:KerrOsculatingOrbitalElements] := Switch[If[Head[param] === Symbol, SymbolName[param], param],
	"Mino", True,
	"CoordinateTime", False,
	_, Message[MessageName[head, "param"], param]; $Failed];


(* ::Text:: *)
(*IntegrationLimit is in the chosen time variable. Automatic is 10^7 in coordinate time and 10^4 in Mino time.*)


IntegrationLimitValue[limit_, minoQ_] := Replace[limit, Automatic -> If[minoQ, 10^4, 10^7]];


(* ::Text:: *)
(*The NDSolve options given to a public function. They come before the solver's own settings, so they take precedence. AccuracyGoal and PrecisionGoal are passed separately.*)


NDSolveOptions[opts___] := FilterRules[FilterRules[{opts}, Options[NDSolve]], Except[AccuracyGoal | PrecisionGoal]];


(* ::Text:: *)
(*The progress monitor needs a notebook front end.*)


MonitorQ[option_] := MatchQ[option, True | "True"] && $FrontEnd =!= Null;


(* ::Section:: *)
(*Integrating a system*)


(* ::Text:: *)
(*A system to integrate is an Association with:*)
(*"Unknowns": the unknown functions; where the integration ended is read from the first;*)
(*"Equations": the equations and initial conditions;*)
(*"Events": the stopping conditions, each stopEvent[condition, reason] or stopEvent[condition, reason, WhenEvent options], with reason "Separatrix", "SeparatrixBuffer" or "pMin". Like WhenEvent, stopEvent holds its condition;*)
(*"Method": NDSolve's Method for the system, or Automatic.*)


SetAttributes[stopEvent, HoldFirst];


(* ::Text:: *)
(*IntegrateSystem runs NDSolve for 0 <= s <= limit, and returns <|"Solution", "End", "StopReason"|>. The reason is that of the event that stopped it, "IntegrationLimit", or "Other" if NDSolve stopped early. Its settings are:*)
(*"Function", whose nosol message is issued, returning $Failed, if NDSolve gives no solution;*)
(*"MessageHead", "VariableName" and "ReportStops" (All by default), for the stop messages;*)
(*"AccuracyGoal", "PrecisionGoal" and "NDSolveOptions", for NDSolve;*)
(*"Monitor", to show progress, and "Quiet", to suppress NDSolve's messages (only the Schwarzschild solvers do).*)


IntegrateSystem[system_Association, s_, limit_, settings_Association] := Module[
	{stopReason = None, progress = 0, events, solve, monitored, sol, end, reason},
	events = system["Events"] /. stopEvent[condition_, why_, opts___] :> WhenEvent[condition, stopReason = why; "StopIntegration", opts];
	solve[] := NDSolve[
		Evaluate[Join[system["Equations"], events]],
		Evaluate[system["Unknowns"]],
		{s, 0, limit},
		Evaluate[Sequence @@ settings["NDSolveOptions"]],
		AccuracyGoal -> settings["AccuracyGoal"],
		PrecisionGoal -> settings["PrecisionGoal"],
		Evaluate[Sequence @@ If[system["Method"] === Automatic, {}, {Method -> system["Method"]}]],
		StepMonitor :> (progress = s)];
	monitored[] := If[settings["Monitor"], Monitor[solve[], Row[{settings["VariableName"], " = ", progress}]], solve[]];
	sol = If[settings["Quiet"], Quiet[monitored[]], monitored[]];
	If[!MatchQ[sol, {{__Rule}}],
		With[{function = settings["Function"]}, Message[MessageName[function, "nosol"]]];
		Return[$Failed]];
	end = (First[system["Unknowns"]] /. First[sol])["Domain"][[1, 2]];
	reason = Which[stopReason =!= None, stopReason, end == limit, "IntegrationLimit", True, "Other"];
	If[MatchQ[Lookup[settings, "ReportStops", All], All | {___, reason, ___}],
		StopMessage[settings["MessageHead"], settings["VariableName"], end, limit, reason]];
	<|"Solution" -> First[sol], "End" -> end, "StopReason" -> reason|>
];


(* ::Section:: *)
(*Running a solver*)


(* ::Text:: *)
(*A solver is a builder and a force resolver.*)
(*The builder takes the mass ratio, the spin, the initial values, a list of drivers and the settings "Mino", "pMin" and "SeparatrixBuffer". It returns a system (above) with "Variable", the independent variable, and "Outputs", which makes the result from NDSolve's solution; or $Failed with a message.*)
(*The force resolver turns the force into a list of drivers, or $Failed with a message. A force driver is <|"Type" -> "Force", "Function" -> f|>, where f takes the orbit's state (the elements and phases, and the keys of KerrOrbitGeometry) and returns {a_t, a_r, a_\[Theta], a_\[Phi]}. A flux driver has "Type" -> "Flux", and only the regular solver takes them.*)
(*RunSolver reads the options, resolves the force, and builds and integrates the system. It returns the outputs with "limit" and "StopReason". Its optional settings are "Force" (when not given as an option, as in OsculatingInspiral), "MessageHead" (KerrOsculatingOrbitalElements by default) and "ReportStops" (All by default).*)


RunSolver[function_, buildSystem_, forceDrivers_, \[Eta]_, a_, initial_List, {opts___}, settings_Association:<||>] := Module[
	{option, head, minoQ, drivers, system, integration},
	option[name_] := OptionValue[{function, NDSolve}, {opts}, name];
	head = Lookup[settings, "MessageHead", KerrOsculatingOrbitalElements];
	Needs["KerrGeodesics`"];
	minoQ = MinoParametrisationQ[option["Parametrisation"], head];
	If[FailureQ[minoQ], Return[$Failed]];
	drivers = forceDrivers[If[KeyExistsQ[settings, "Force"], settings["Force"], option["Force"]]];
	If[FailureQ[drivers], Return[$Failed]];
	system = buildSystem[\[Eta], a, initial, drivers,
		<|"Mino" -> minoQ, "pMin" -> option["pMin"], "SeparatrixBuffer" -> option["SeparatrixBuffer"]|>];
	If[FailureQ[system], Return[$Failed]];
	integration = IntegrateSystem[system, system["Variable"], IntegrationLimitValue[option["IntegrationLimit"], minoQ],
		<|"Function" -> function, "MessageHead" -> head,
			"VariableName" -> If[minoQ, "\[Lambda]", "t"], "AccuracyGoal" -> option["AccuracyGoal"],
			"PrecisionGoal" -> option["PrecisionGoal"], "NDSolveOptions" -> NDSolveOptions[opts],
			"Monitor" -> MonitorQ[option["TimeMonitor"]], "Quiet" -> False,
			"ReportStops" -> Lookup[settings, "ReportStops", All]|>];
	If[FailureQ[integration], Return[$Failed]];
	Join[system["Outputs"][integration["Solution"]], <|"limit" -> integration["End"], "StopReason" -> integration["StopReason"]|>]
];


(* ::Text:: *)
(*At the orbit's state, the sum of the force drivers' {a_t, a_r, a_\[Theta], a_\[Phi]}, and of the flux drivers' rates of the regular solver's {p, \[Alpha]p, \[Beta]p, x} with respect to t (see fluxVariableRates). Each is multiplied by the mass ratio \[Eta] unless its driver has "ScalesWithMassRatio" -> False.*)


driverTotal[type_String, drivers_List, state_Association, \[Eta]_] := With[{selected = Cases[drivers, KeyValuePattern["Type" -> type]]},
	If[selected === {}, {0, 0, 0, 0},
		Total[If[TrueQ[Lookup[#, "ScalesWithMassRatio", True]], \[Eta], 1] #["Function"][state] & /@ selected]]];

TotalForce[drivers_List, state_Association, \[Eta]_] := driverTotal["Force", drivers, state, \[Eta]];
TotalFlux[drivers_List, state_Association, \[Eta]_] := driverTotal["Flux", drivers, state, \[Eta]];


(* ::Text:: *)
(*Reports why an integration stopped.*)


StopMessage[head_, var_, end_, limit_, reason_] := Switch[reason,
	"Separatrix", Message[MessageName[head, "sep"], var, end],
	"SeparatrixBuffer", Message[MessageName[head, "sepbuf"], var, end],
	"pMin", Message[MessageName[head, "pmin"], var, end],
	"IntegrationLimit", Message[MessageName[head, "limit"], var, limit],
	_, Message[MessageName[head, "early"], var, end]];
