(* ::Package:: *)

(* ::Title:: *)
(*Flux models*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Text:: *)
(*FluxModel[assoc] holds a flux for OsculatingInspiral: orbit-averaged rates of change of the slowly varying elements, with respect to coordinate time. assoc has the keys that force and flux models share (see Models.wl), and "Rates": the quantities whose rates the function gives, {"p", "e", "x"} or {"En", "L", "Q"}. Its "Function", f, is called as f[a, p, e, x], with the parameters appended when there are any, and returns the three rates.*)
(*The built-in models are in the other files of FluxModels/, which add themselves to builtInFluxModels.*)


(* ::Section:: *)
(*Construction*)


builtInFluxModels = <||>;

$fluxRates = {{"p", "e", "x"}, {"En", "L", "Q"}};


(* ::Text:: *)
(*A custom model, from its function and options. As for ForceModel, every pattern FluxModel[assoc_Association] below is wrapped in HoldPattern.*)


FluxModel[f:Except[_String | _Association | _FluxModel | _ForceModel | _Rule], opts___Rule] := With[{model = newModel[FluxModel, f, {opts}]},
	Which[
		FailureQ[model], $Failed,
		!MemberQ[$fluxRates, model["Rates"]], Message[FluxModel::rates, model["Rates"]]; $Failed,
		True, model]];


(* ::Text:: *)
(*A built-in model by name, new parameter values for a model, and the orbit average of a force*)


FluxModel[name_String, parameters___Rule] := If[KeyExistsQ[builtInFluxModels, name],
	FluxModel[builtInFluxModels[name], parameters],
	Message[FluxModel::name, name, Keys[builtInFluxModels]]; $Failed];

FluxModel[HoldPattern[FluxModel[assoc_Association]], parameters___Rule] := modelWithParameters[FluxModel, assoc, {parameters}];

FluxModel[force:HoldPattern[ForceModel[_Association]], parameters___Rule] := FluxModel[orbitAveragedFlux[force], parameters];


(* ::Section:: *)
(*Properties and evaluation*)


HoldPattern[FluxModel[assoc_Association]]["Properties"] := Keys[assoc];

HoldPattern[FluxModel[assoc_Association]][key_String] := modelProperty[FluxModel, assoc, key];

(* The rates, before any factor of \[Epsilon] *)
HoldPattern[FluxModel[assoc_Association]][a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ] := fluxModelRates[FluxModel[assoc], a, p, e, x];

fluxModelRates[model_FluxModel, args__] := callModel[model, {args}, 3];


(* ::Section:: *)
(*In a solver*)


(* ::Text:: *)
(*The rates of the regular solver's variables {p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta]} from the flux at this state, with respect to t and before any factor of \[Epsilon]. The flux changes e and x but not the phases, so*)
(*d\[Alpha]p/dt = ((de/dt)/e) \[Alpha]p and d\[Beta]p/dt = ((de/dt)/e) \[Beta]p, and d\[Alpha]\[Theta]/dt = ((dzm/dt)/(2 zm)) \[Alpha]\[Theta] and d\[Beta]\[Theta]/dt = ((dzm/dt)/(2 zm)) \[Beta]\[Theta], with (dzm/dt)/(2 zm) = -x (dx/dt)/zm.*)
(*These ratios are finite for a physical flux, as de/dt ~ e near e = 0 and dx/dt ~ zm near x = \[PlusMinus]1. At exactly e = 0, or on an equatorial orbit (\[Alpha]\[Theta] = \[Beta]\[Theta] = 0), they are 0/0, and the contribution is 0: a flux keeps a circular orbit circular and an equatorial orbit equatorial. zm is taken as \[Alpha]\[Theta]^2 + \[Beta]\[Theta]^2, which unlike 1 - x^2 does not lose digits near the equator.*)


fluxVariableRates[model_FluxModel, a_, p_, \[Alpha]p_, \[Beta]p_, x_, \[Alpha]\[Theta]_, \[Beta]\[Theta]_] := Module[{e2, zm, rates, dp, eRatio, dx, zRatio},
	e2 = \[Alpha]p^2 + \[Beta]p^2;
	zm = \[Alpha]\[Theta]^2 + \[Beta]\[Theta]^2;
	rates = fluxModelRates[model, a, p, Sqrt[e2], x];
	If[FailureQ[rates], Return[$Failed]];
	{dp, eRatio, dx} = If[model["Rates"] === {"p", "e", "x"},
		{rates[[1]], If[e2 == 0, 0, rates[[2]]/Sqrt[e2]], rates[[3]]},
		constantsToElementRates[a, p, e2, x, rates]];
	If[zm == 0, dx = 0];
	zRatio = If[zm == 0, 0, -x dx/zm];
	{dp, eRatio \[Alpha]p, eRatio \[Beta]p, dx, zRatio \[Alpha]\[Theta], zRatio \[Beta]\[Theta]}
];


(* ::Text:: *)
(*{dp/dt, (de/dt)/e, dx/dt} from the rates of (En, L, Q). (de/dt)/e = (de^2/dt)/(2 e^2), which is accurate to about 10^-16/e^2 relative to the flux, so a flux given for (p, e, x) is better for nearly circular orbits. The rate of x is in the form that is regular at x = 0.*)


constantsToElementRates[a_, p_, e2_, x_, {dEn_, dL_, dQ_}] := Module[{En, \[ScriptL], L, Q, rates},
	En = RegularEnergy[a, p, e2, x];
	\[ScriptL] = RegularLOverX[a, p, e2, x];
	L = x \[ScriptL];
	Q = (1 - x^2) (a^2 (1 - En^2) + \[ScriptL]^2);
	rates = SlowElementRates[a, {p, e2}, {En, L, Q}, {dEn, dL, dQ}];
	{rates["p"], If[e2 == 0, 0, rates["e2"]/(2 e2)], RegularXRate[a, x, {En, \[ScriptL]}, {dEn, dL, dQ}]}
];


(* ::Text:: *)
(*The "Flux" parameter of OsculatingInspiral as a list of FluxModels (see resolveModels in Models.wl), and the check at the initial orbit {a, p, e, x}, as for forces*)


inspiralFluxModels[flux_] := resolveModels[FluxModel, flux, "flux"];

checkFluxModels[models_List, {a_, p_, e_, x_}] := Module[{failed},
	failed = SelectFirst[models, FailureQ[fluxModelRates[#, Sequence @@ N[{a, p, e, x}]]] &];
	If[!MissingQ[failed], Return[$Failed]];
	checkModelValidity[models, {a, p, e, x}];
	models
];


(* ::Text:: *)
(*A model as a solver driver of type "Flux" (see RunSolver and TotalFlux in Interface.wl). As for forces, its function is called once for each state, only with numbers, and its six rates are separate functions.*)


fluxModelDriver[model_FluxModel] := Module[{evaluate, component, cache = None},
	evaluate[args__?NumericQ] := memoLast[evaluate, cache, {args}, fluxVariableRates[model, args]];
	component[i_, args__?NumericQ] := With[{value = evaluate[args]}, If[ListQ[value], value[[i]], Indeterminate]];
	<|"Type" -> "Flux", "ScalesWithMassRatio" -> model["ScalesWithMassRatio"],
		"Function" -> Function[state, Table[
			component[i, state["a"], state["p"], state["\[Alpha]p"], state["\[Beta]p"], state["x"], state["\[Alpha]\[Theta]"], state["\[Beta]\[Theta]"]],
			{i, 6}]]|>
];


(* ::Section:: *)
(*The orbit average of a force*)


(* ::Text:: *)
(*The flux of a ForceModel: its rates of change of En, L and Q, averaged over the geodesic with respect to t. In Mino time the radial and polar motions separate, d\[Psi]r/d\[Lambda] depending only on \[Psi]r and d\[Psi]\[Theta]/d\[Lambda] only on \[Psi]\[Theta], so the Mino-time average over a non-resonant orbit is a double integral over the phases with weight 1/((d\[Psi]r/d\[Lambda]) (d\[Psi]\[Theta]/d\[Lambda])). The average with respect to t divides the Mino-time averages by that of dt/d\[Lambda]. The integrals are trapezoidal sums over "Points" equally spaced values of each phase, which converge exponentially for these smooth periodic integrands; a circular orbit needs one radial point and an equatorial orbit one polar point.*)
(*The force is evaluated at \[Phi] = 0 and t = 0, so it must not depend on them.*)


orbitAveragedFlux[force_] := FluxModel[KeyTake[<|
	"Name" -> "OrbitAverage[" <> force["Name"] <> "]",
	"Description" -> "The force " <> force["Name"] <> " averaged over the radial and polar motion of the geodesic, with respect to t",
	"Function" -> Function[{a, p, e, x, parameters}, orbitAveragedRates[force, a, p, e, x, parameters["Points"]]],
	"Parameters" -> <|"Points" -> 16|>,
	"Rates" -> {"En", "L", "Q"},
	"ScalesWithMassRatio" -> force["ScalesWithMassRatio"],
	"ValidityCondition" -> force["ValidityCondition"],
	"ValidityDescription" -> force["ValidityDescription"],
	"Citation" -> force["Citation"]|>, modelKeys[FluxModel]]];

orbitAveragedRates[force_, a_, p_, e_, x_, n_Integer?Positive] := Catch[
	With[{sums = minoTimeSums[a, p, e, x, n, Function[{g, \[Psi]r, \[Psi]\[Theta]},
			With[{f = force[a, p, e, x, \[Psi]r, \[Psi]\[Theta], 0, 0]},
				If[FailureQ[f], Throw[$Failed]];
				{Sequence @@ Lookup[ConstantsOfMotionRates[g, f], {"En", "L", "Q"}], g["dtd\[Lambda]"]}]]]},
		Most[First[sums]]/Last[First[sums]]]];


(* ::Text:: *)
(*The weighted sums for the Mino-time average over the geodesic of f[g, \[Psi]r, \[Psi]\[Theta]], where g is the geometry at the phases: {sum of w f, sum of w}, so the average is their ratio. f may return a list.*)


minoTimeSums[a_, p_, e_, x_, n_Integer?Positive, f_] := Module[{nr, n\[Theta], total = 0, weights = 0},
	nr = If[e == 0, 1, n];
	n\[Theta] = If[Abs[x] == 1, 1, n];
	Do[
		With[{g = NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]]},
			With[{w = 1/(g["d\[Psi]rd\[Lambda]"] Sqrt[g["\[Beta]zp"] - g["\[Beta]"] g["z"]])},
				total += w f[g, \[Psi]r, \[Psi]\[Theta]];
				weights += w]],
		{\[Psi]r, 2. Pi Range[0, nr - 1]/nr}, {\[Psi]\[Theta], 2. Pi Range[0, n\[Theta] - 1]/n\[Theta]}];
	{total, weights}
];


(* ::Section:: *)
(*Summary box*)


FluxModel /: MakeBoxes[model:FluxModel[_Association], form:(StandardForm | TraditionalForm)] := modelSummaryBox[model, form];
