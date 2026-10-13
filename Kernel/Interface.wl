(* ::Package:: *)

(* ::Title:: *)
(*Interface*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Text:: *)
(*Machinery shared by the public functions: reading their options, and integrating a system of equations with NDSolve. The new entry point (phase 3 of the refactor) will also live here.*)


(* ::Section:: *)
(*Options*)


(* ::Text:: *)
(*Accepts the Parametrisation option as a string or a symbol (e.g. "Mino" or Mino). Returns True for Mino time, False for coordinate time, and $Failed otherwise.*)


MinoParametrisationQ[param_] := Switch[If[Head[param] === Symbol, SymbolName[param], param],
	"Mino", True,
	"CoordinateTime", False,
	_, Message[KerrOsculatingOrbitalElements::param, param]; $Failed];


(* ::Text:: *)
(*IntegrationLimit is in the units of the chosen time variable. Automatic means 10^7 in coordinate time and 10^4 in Mino time.*)


IntegrationLimitValue[limit_, minoQ_] := Replace[limit, Automatic -> If[minoQ, 10^4, 10^7]];


(* ::Text:: *)
(*NDSolve options given to a public function are passed to NDSolve ahead of the solver's own settings, so they take precedence. AccuracyGoal and PrecisionGoal are options of the public functions themselves and are passed separately.*)


NDSolveOptions[opts___] := FilterRules[FilterRules[{opts}, Options[NDSolve]], Except[AccuracyGoal | PrecisionGoal]];


(* ::Text:: *)
(*The progress monitor needs a notebook front end.*)


MonitorQ[option_] := MatchQ[option, True | "True"] && $FrontEnd =!= Null;


(* ::Section:: *)
(*Integrating a system*)


(* ::Text:: *)
(*A solver describes the system to integrate as an Association with these keys:*)
(*"Unknowns": the unknown functions, in the order NDSolve receives them. Where the integration ended is read from the first one.*)
(*"Equations": the equations and initial conditions, in terms of the independent variable.*)
(*"Events": the stopping conditions, each written stopEvent[condition, reason]. Like WhenEvent, stopEvent holds its condition. The reason is "Separatrix", "SeparatrixBuffer" or "pMin".*)
(*"Method": the NDSolve Method option for this system, or Automatic.*)


SetAttributes[stopEvent, HoldFirst];


(* ::Text:: *)
(*IntegrateSystem runs NDSolve for 0 <= s <= limit. It returns <|"Solution" -> rules, "End" -> end, "StopReason" -> reason|>, where the reason is that of the event that stopped the integration, "IntegrationLimit", or "Other" if NDSolve stopped early for another reason. It issues the matching stop message. If NDSolve gives no solution, it issues the calling function's nosol message and returns $Failed. The settings are:*)
(*"Function": the public function, for its nosol message.*)
(*"MessageHead": the symbol that the stop messages are attached to.*)
(*"VariableName": the independent variable's name, for the messages and the progress monitor.*)
(*"AccuracyGoal", "PrecisionGoal", "NDSolveOptions": passed to NDSolve.*)
(*"Monitor": whether to show the progress monitor.*)
(*"Quiet": whether to suppress NDSolve's own messages. Only the Schwarzschild solvers do, as they always have.*)


IntegrateSystem[system_Association, s_, limit_, settings_Association] := Module[
	{stopReason = None, progress = 0, events, solve, monitored, sol, end, reason},
	events = system["Events"] /. stopEvent[condition_, why_] :> WhenEvent[condition, stopReason = why; "StopIntegration"];
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
	StopMessage[settings["MessageHead"], settings["VariableName"], end, limit, reason];
	<|"Solution" -> First[sol], "End" -> end, "StopReason" -> reason|>
];


(* ::Section:: *)
(*Running a solver*)


(* ::Text:: *)
(*A solver is described by two functions.*)
(*The builder takes the mass ratio, the spin, the initial elements {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0}, a list of drivers and the settings "Mino", "pMin" and "SeparatrixBuffer". It returns a system with the keys IntegrateSystem needs, plus "Variable", the independent variable, and "Outputs", a function that makes the result from NDSolve's solution. It returns $Failed, with a message, if it cannot build the system.*)
(*The force resolver turns the Force option into a list of drivers, or returns $Failed with a message. A force driver is <|"Type" -> "Force", "Function" -> f|>, where f takes the orbit's state as an Association and returns the covariant components {a_t, a_r, a_\[Theta], a_\[Phi]} per unit \[Eta]. The state has the keys "a", "p", "e", "x", "\[Psi]r" and "\[Psi]\[Theta]", and those of KerrOrbitGeometry (Utilities.wl). Several forces are added. Fluxes, which will only change the slowly varying elements, come later.*)
(*RunSolver reads the options, resolves the force, builds and integrates the system, and returns the result with "limit" and "StopReason" added.*)


RunSolver[function_, buildSystem_, forceDrivers_, \[Eta]_, a_, initial_List, {opts___}] := Module[
	{option, minoQ, drivers, system, integration},
	option[name_] := OptionValue[{function, NDSolve}, {opts}, name];
	Needs["KerrGeodesics`"];
	minoQ = MinoParametrisationQ[option["Parametrisation"]];
	If[FailureQ[minoQ], Return[$Failed]];
	drivers = forceDrivers[option["Force"]];
	If[FailureQ[drivers], Return[$Failed]];
	system = buildSystem[\[Eta], a, initial, drivers,
		<|"Mino" -> minoQ, "pMin" -> option["pMin"], "SeparatrixBuffer" -> option["SeparatrixBuffer"]|>];
	If[FailureQ[system], Return[$Failed]];
	integration = IntegrateSystem[system, system["Variable"], IntegrationLimitValue[option["IntegrationLimit"], minoQ],
		<|"Function" -> function, "MessageHead" -> KerrOsculatingOrbitalElements,
			"VariableName" -> If[minoQ, "\[Lambda]", "t"], "AccuracyGoal" -> option["AccuracyGoal"],
			"PrecisionGoal" -> option["PrecisionGoal"], "NDSolveOptions" -> NDSolveOptions[opts],
			"Monitor" -> MonitorQ[option["TimeMonitor"]], "Quiet" -> False|>];
	If[FailureQ[integration], Return[$Failed]];
	Join[system["Outputs"][integration["Solution"]], <|"limit" -> integration["End"], "StopReason" -> integration["StopReason"]|>]
];


(* ::Text:: *)
(*The sum of the force drivers' components {a_t, a_r, a_\[Theta], a_\[Phi]} for the orbit's state, per unit \[Eta]. Builders call this.*)


TotalForce[drivers_List, state_Association] := With[{forces = Cases[drivers, KeyValuePattern["Type" -> "Force"]]},
	If[forces === {}, {0, 0, 0, 0}, Total[#["Function"][state] & /@ forces]]];


(* ::Text:: *)
(*Reports why an integration stopped.*)


StopMessage[head_, var_, end_, limit_, reason_] := Switch[reason,
	"Separatrix", Message[MessageName[head, "sep"], var, end],
	"SeparatrixBuffer", Message[MessageName[head, "sepbuf"], var, end],
	"pMin", Message[MessageName[head, "pmin"], var, end],
	"IntegrationLimit", Message[MessageName[head, "limit"], var, limit],
	_, Message[MessageName[head, "early"], var, end]];
