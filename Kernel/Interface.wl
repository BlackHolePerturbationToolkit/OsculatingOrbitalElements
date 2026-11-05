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
	{"e", realQ[#] && 0 <= # &, "a nonnegative real number"},
	{"x", realQ[#] && -1 <= # <= 1 &, "a real number with -1 \[LessEqual] x \[LessEqual] 1"},
	{"\[Psi]r", realQ, "a real number"},
	{"\[Psi]\[Theta]", realQ, "a real number"},
	{"\[Phi]", realQ, "a real number"}};


(* ::Text:: *)
(*The parameters with the defaults filled in, in a fixed order, or $Failed with a message. The solver checks the separatrix buffer.*)


(* For e >= 1, require real timelike constants and an exterior scattering pericentre.
   The polynomial below equals p (1+e)^2 R'(rp)/(2e), with rp = p/(1+e).
   In Schwarzschild these conditions give p > Max[3+e^2, 6+2e]. *)
scatteringInitialDataQ[a_, p_, e_, x_] := Quiet[Check[Module[
    {En, \[ScriptL], L, Q, K, rp},
    If[TrueQ[a == 0], Return[TrueQ[p > Max[3 + e^2, 6 + 2 e]]]];
    {En, \[ScriptL]} = regularConstants[a, p, e^2, x];
    If[!VectorQ[{En, \[ScriptL]}, realQ] || !TrueQ[En > 0 && \[ScriptL] > 0 &&
        \[ScriptL]^2 + a^2 (1 - En^2) > 0], Return[False]];
    L = x \[ScriptL];
    Q = (1 - x^2) (\[ScriptL]^2 + a^2 (1 - En^2));
    K = Q + (L - a En)^2;
    rp = p/(1 + e);
    TrueQ[rp > 1 + Sqrt[1 - a^2] &&
        p^3 - (1 + e) (3 - e) K p + 4 a^2 Q (1 + e) > 0]
], False]];


InspiralParameters[params_Association, angular_:"Standard"] := Module[{parameters, unknown, missing, bad},
	parameters = KeyMap[Replace[$inspiralParameterAliases], params];
	unknown = Complement[Keys[parameters], $inspiralParameterKeys];
	If[unknown =!= {}, Message[OsculatingInspiral::unknown, unknown, $inspiralParameterKeys]; Return[$Failed]];
	missing = Complement[$requiredInspiralParameters, Keys[parameters]];
	If[missing =!= {}, Message[OsculatingInspiral::missing, missing]; Return[$Failed]];
	If[!KeyExistsQ[parameters, "Force"] && !KeyExistsQ[parameters, "Flux"], Message[OsculatingInspiral::nodriver]; Return[$Failed]];
	parameters = Join[$inspiralParameterDefaults, parameters];
	bad = SelectFirst[$inspiralParameterRanges, !TrueQ[#[[2]][parameters[#[[1]]]]] &];
	If[!MissingQ[bad], Message[OsculatingInspiral::range, bad[[1]], parameters[bad[[1]]], bad[[3]]]; Return[$Failed]];
	(* Unbound initial data are supported here for local forces. Orbit-averaged
	   fluxes retain their bound-orbit restriction. Start at a finite positive radius. *)
	If[TrueQ[parameters["e"] >= 1] && !MemberQ[{None, {}}, parameters["Flux"]],
		Message[OsculatingInspiral::range, "e", parameters["e"], "less than 1 when using orbit-averaged fluxes"]; Return[$Failed]];
	If[!TrueQ[1 + parameters["e"] Cos[parameters["\[Psi]r"]] > 0],
		Message[OsculatingInspiral::range, "\[Psi]r", parameters["\[Psi]r"], "a phase with 1 + e Cos[psi_r] > 0"]; Return[$Failed]];
	If[TrueQ[parameters["e"] >= 1] &&
		!scatteringInitialDataQ[Sequence @@ Lookup[parameters, {"a", "p", "e", "x"}]],
		Message[OsculatingInspiral::range, "e", parameters["e"],
			"an eccentricity admitting real timelike constants and an exterior scattering pericentre at the given a, p, x"]; Return[$Failed]];
	If[angular === "Standard" && TrueQ[parameters["x"] == 0], Message[OsculatingInspiral::polar]; Return[$Failed]];
	KeyTake[parameters, $inspiralParameterKeys]
];


(* ::Text:: *)
(*The entry point selects regularSystem (Standard) or hklSystem (HKLambda).
  Both use the same radial REG equations and integration runner.
  Normal stops are recorded in \"StopReason\"; only an early stop by NDSolve gives a message.*)


OsculatingInspiral[params_Association, opts:OptionsPattern[{OsculatingInspiral, NDSolve}]] := Module[{parameters, forces, fluxes, result, angular, chart, builder, driver},
	angular = OptionValue[AngularVariables];
	chart = OptionValue[AngularChart];
	If[!MemberQ[{"Standard", "HKLambda"}, angular], Message[OsculatingInspiral::angular, angular]; Return[$Failed]];
	If[!MemberQ[{Automatic, -1, 1}, chart], Message[OsculatingInspiral::chart, chart]; Return[$Failed]];
	parameters = InspiralParameters[params, angular];
	If[FailureQ[parameters], Return[$Failed]];
	(* The forces and fluxes as lists of models, each checked at the initial orbit *)
	forces = inspiralForceModels[parameters["Force"]];
	If[FailureQ[forces], Return[$Failed]];
	forces = If[angular === "HKLambda",
		checkModelValidity[forces, Lookup[parameters, {"a", "p", "e", "x"}]]; forces,
		checkForceModels[forces, Append[Lookup[parameters, {"a", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}], 0]]];
	If[FailureQ[forces], Return[$Failed]];
	fluxes = inspiralFluxModels[parameters["Flux"]];
	If[FailureQ[fluxes], Return[$Failed]];
	If[angular === "HKLambda" && fluxes =!= {}, Message[OsculatingInspiral::hklflux]; Return[$Failed]];
	fluxes = checkFluxModels[fluxes, Lookup[parameters, {"a", "p", "e", "x"}]];
	If[FailureQ[fluxes], Return[$Failed]];
	builder = If[angular === "HKLambda", hklSystem, regularSystem];
	driver = If[angular === "HKLambda", hklForceModelDriver, forceModelDriver];
	result = RunSolver[OsculatingInspiral, builder, Join[driver /@ #["Forces"], fluxModelDriver /@ #["Fluxes"]] &,
		parameters["\[Epsilon]"], parameters["a"], Lookup[parameters, {"p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]"}], {opts},
		<|"Force" -> <|"Forces" -> forces, "Fluxes" -> fluxes|>, "MessageHead" -> OsculatingInspiral, "ReportStops" -> {"Other"},
			"SystemSettings" -> <|"AngularChart" -> chart|>|>];
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
(*"Events": the stopping conditions, each stopEvent[condition, reason] or stopEvent[condition, reason, WhenEvent options], with reason "Separatrix", "SeparatrixBuffer", "pMin" or "AngularChartBoundary". Like WhenEvent, stopEvent holds its condition;*)
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
(*The builder takes the mass ratio, the spin, the initial values, a list of drivers and the settings "Mino", "pMin", "SeparatrixBuffer", "WorkingPrecision", "AccuracyGoal" and "PrecisionGoal", plus optional "SystemSettings" (AngularChart for HKLambda). It returns a system (above) with "Variable", the independent variable, and "Outputs", which makes the result from NDSolve's solution; or $Failed with a message.*)
(*The force resolver turns the force into a list of drivers, or $Failed with a message. A force driver is <|"Type" -> "Force", "Function" -> f|>, where f takes the orbit's state and returns covariant force components: {a_t, a_r, a_theta, a_phi} for Standard, or {a_t, a_r, a_phi, AH} for HKLambda (see Solvers/KerrHKL.wl). A flux driver has "Type" -> "Flux", and only the Standard solver takes them.*)
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
		Join[<|"Mino" -> minoQ, "pMin" -> option["pMin"], "SeparatrixBuffer" -> option["SeparatrixBuffer"],
			"WorkingPrecision" -> option[WorkingPrecision], "AccuracyGoal" -> option[AccuracyGoal],
			"PrecisionGoal" -> option[PrecisionGoal]|>, Lookup[settings, "SystemSettings", <||>]]];
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
(*At the orbit's state, sum the force vectors in the chosen solver's component order,
  or the flux rates of Standard's {p, alpha_p, beta_p, x} with respect to t (see fluxVariableRates).
  Each is multiplied by the mass ratio eta unless its driver has "ScalesWithMassRatio" -> False.*)


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
