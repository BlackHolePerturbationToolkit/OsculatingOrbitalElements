(* ::Package:: *)

(* ::Title:: *)
(*Force models*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Text:: *)
(*ForceModel[assoc] holds a force for OsculatingInspiral. assoc has the keys that force and flux models share (see Models.wl). Its "Function", f, is called as f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t], with the parameters appended when there are any. \[Phi] and the coordinate time t let a force break axial symmetry or depend on time, as the tidal field of a third body does. f returns the covariant {F_r, F_\[Theta], F_\[Phi]}; F_t follows from orthogonality to the velocity.*)
(*The built-in models are in the other files of ForceModels/, which add themselves to builtInForceModels.*)


(* ::Section:: *)
(*Construction*)


builtInForceModels = <||>;


(* ::Text:: *)
(*A custom model, from its function and options. The constructor accepts almost any first argument, so every pattern ForceModel[assoc_Association] below is wrapped in HoldPattern: otherwise, when the definition is made, the pattern itself is evaluated as a call to the constructor.*)


ForceModel[f:Except[_String | _Association | _ForceModel | _FluxModel | _Rule], opts___Rule] := newModel[ForceModel, f, {opts}];


(* ::Text:: *)
(*A built-in model by name, and new parameter values for a model*)


ForceModel[name_String, parameters___Rule] := If[KeyExistsQ[builtInForceModels, name],
	ForceModel[builtInForceModels[name], parameters],
	Message[ForceModel::name, name, Keys[builtInForceModels]]; $Failed];

ForceModel[HoldPattern[ForceModel[assoc_Association]], parameters___Rule] := modelWithParameters[ForceModel, assoc, {parameters}];


(* ::Section:: *)
(*Properties and evaluation*)


HoldPattern[ForceModel[assoc_Association]]["Properties"] := Keys[assoc];

HoldPattern[ForceModel[assoc_Association]][key_String] := modelProperty[ForceModel, assoc, key];

(* The covariant {F_t, F_r, F_\[Theta], F_\[Phi]} at this point of the geodesic with these elements, before any factor of \[Epsilon].
   The geometry does not depend on \[Phi] or t, since Kerr is stationary and axisymmetric. *)
HoldPattern[ForceModel[assoc_Association]][a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ, \[Psi]r_?NumericQ, \[Psi]\[Theta]_?NumericQ,
	\[Phi]_?NumericQ, t_?NumericQ] := Module[{spatial},
	spatial = forceModelComponents[ForceModel[assoc], a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t];
	If[FailureQ[spatial], Return[$Failed]];
	Prepend[spatial, OrthogonalTimeComponent[NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]], spatial]]
];


(* ::Text:: *)
(*The model's {F_r, F_\[Theta], F_\[Phi]}, or $Failed with a message if its function does not return three real numbers*)


forceModelComponents[model_ForceModel, args__] := callModel[model, {args}, 3];


(* ::Section:: *)
(*In a solver*)


(* ::Text:: *)
(*The "Force" parameter of OsculatingInspiral as a list of ForceModels (see resolveModels in Models.wl)*)


inspiralForceModels[force_] := resolveModels[ForceModel, force, "force"];


(* ::Text:: *)
(*Checks the models at the start of an inspiral, {a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t}: each must give three numbers there, and a model outside its range of validity gives a warning. Returns $Failed if a model fails.*)


checkForceModels[models_List, {a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_}] := Module[{failed},
	failed = SelectFirst[models, FailureQ[forceModelComponents[#, Sequence @@ N[{a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t}]]] &];
	If[!MissingQ[failed], Return[$Failed]];
	checkModelValidity[models, {a, p, e, x}];
	models
];


(* ::Text:: *)
(*A model as a solver driver (see RunSolver in Interface.wl). Its function is called once for each state, only with numbers: the components are separate functions so that they stay unevaluated in the symbolic equations, and the most recent result is cached.*)


forceModelDriver[model_ForceModel] := Module[{evaluate, component, cache = None},
	evaluate[args__?NumericQ] := memoLast[evaluate, cache, {args}, forceModelComponents[model, args]];
	component[i_, args__?NumericQ] := With[{value = evaluate[args]}, If[ListQ[value], value[[i]], Indeterminate]];
	<|"Type" -> "Force", "ScalesWithMassRatio" -> model["ScalesWithMassRatio"],
		"Function" -> Function[state, With[{spatial = Table[
				component[i, state["a"], state["p"], state["e"], state["x"], state["\[Psi]r"], state["\[Psi]\[Theta]"], state["\[Phi]"],
					state["t"]], {i, 3}]},
			Prepend[spatial, OrthogonalTimeComponent[state, spatial]]]]|>
];


(* ::Section:: *)
(*Summary box*)


ForceModel /: MakeBoxes[model:ForceModel[_Association], form:(StandardForm | TraditionalForm)] := modelSummaryBox[model, form];
