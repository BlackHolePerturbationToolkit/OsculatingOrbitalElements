(* ::Package:: *)

(* ::Title:: *)
(*Flux models*)


(* ::Text:: *)
(*FluxModel[assoc] is a flux for OsculatingInspiral: orbit-averaged rates of change of the slowly varying elements with respect to coordinate time. assoc has the keys of Models.wl and "Rates", {"p", "e", "x"} or {"En", "L", "Q"}: the quantities whose rates its function f[a, p, e, x] (parameters appended, if any) returns.*)
(*The built-in models, in the other files here, add themselves to builtInFluxModels. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Section:: *)
(*Construction*)


builtInFluxModels = <||>;

$fluxRates = {{"p", "e", "x"}, {"En", "L", "Q"}};


(* ::Text:: *)
(*A custom model. As for ForceModel, the patterns FluxModel[assoc_Association] are wrapped in HoldPattern.*)


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
(*The flux's rates of the solver's {p, \[Alpha]p, \[Beta]p, x}, with respect to t and before any factor of \[Epsilon]. It changes e but not \[Psi]r, so (d\[Alpha]p/dt, d\[Beta]p/dt) = ((de/dt)/e) (\[Alpha]p, \[Beta]p): finite for a physical flux, which has de/dt ~ e, and 0 at e = 0, so a circular orbit stays circular. It does not change \[Psi]\[Theta].*)


fluxVariableRates[model_FluxModel, a_, p_, \[Alpha]p_, \[Beta]p_, x_] := Module[{e2, rates, dp, eRatio, dx},
	e2 = \[Alpha]p^2 + \[Beta]p^2;
	rates = fluxModelRates[model, a, p, Sqrt[e2], x];
	If[FailureQ[rates], Return[$Failed]];
	{dp, eRatio, dx} = If[model["Rates"] === {"p", "e", "x"},
		{rates[[1]], If[e2 == 0, 0, rates[[2]]/Sqrt[e2]], rates[[3]]},
		constantsToElementRates[a, p, e2, x, rates]];
	{dp, eRatio \[Alpha]p, eRatio \[Beta]p, dx}
];


(* ::Text:: *)
(*{dp/dt, (de/dt)/e, dx/dt} from the rates of (En, L, Q). (de/dt)/e = (de^2/dt)/(2 e^2) loses accuracy like 10^-16/e^2, so a flux for nearly circular orbits is better given for (p, e, x).*)


constantsToElementRates[a_, p_, e2_, x_, {dEn_, dL_, dQ_}] := Module[{En, \[ScriptL], L, Q, rates},
	En = RegularEnergy[a, p, e2, x];
	\[ScriptL] = RegularLOverX[a, p, e2, x];
	L = x \[ScriptL];
	Q = (1 - x^2) (a^2 (1 - En^2) + \[ScriptL]^2);
	rates = SlowElementRates[a, {p, e2}, {En, L, Q}, {dEn, dL, dQ}];
	{rates["p"], If[e2 == 0, 0, rates["e2"]/(2 e2)], RegularXRate[a, x, {En, \[ScriptL]}, {dEn, dL, dQ}]}
];


(* ::Text:: *)
(*The \"Flux\" parameter as a list of FluxModels, and their check at the initial {a, p, e, x}, as for forces*)


inspiralFluxModels[flux_] := resolveModels[FluxModel, flux, "flux"];

checkFluxModels[models_List, {a_, p_, e_, x_}] := Module[{failed},
	failed = SelectFirst[models, FailureQ[fluxModelRates[#, Sequence @@ N[{a, p, e, x}]]] &];
	If[!MissingQ[failed], Return[$Failed]];
	checkModelValidity[models, {a, p, e, x}];
	models
];


(* ::Text:: *)
(*A model as a solver driver of type \"Flux\" (see TotalFlux in Interface.wl).*)


fluxModelDriver[model_FluxModel] := With[{component = cachedComponents[fluxVariableRates[model, ##] &]},
	<|"Type" -> "Flux", "ScalesWithMassRatio" -> model["ScalesWithMassRatio"],
		"Function" -> Function[state, Table[
			component[i, state["a"], state["p"], state["\[Alpha]p"], state["\[Beta]p"], state["x"]],
			{i, 4}]]|>
];


(* ::Section:: *)
(*The orbit average of a force*)


(* ::Text:: *)
(*The flux of a ForceModel: its rates of En, L and Q averaged over the geodesic with respect to t. In Mino time the radial and polar motions separate, so for a non-resonant orbit the Mino-time average is a double integral over the phases with weight 1/((d\[Psi]r/d\[Lambda]) (d\[Psi]\[Theta]/d\[Lambda])); the average over t divides it by that of dt/d\[Lambda]. The integrals are trapezoidal sums over "Points" values of each phase, which converge exponentially; a circular or equatorial orbit needs one point in the trivial phase. The force is evaluated at \[Phi] = t = 0, so it must not depend on them.*)


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
(*{sum of w f, sum of w} for the Mino-time average over the geodesic of f[g, \[Psi]r, \[Psi]\[Theta]], with g the geometry at the phases. f may return a list.*)


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
