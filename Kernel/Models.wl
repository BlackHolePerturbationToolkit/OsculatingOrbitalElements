(* ::Package:: *)

(* ::Title:: *)
(*Force and flux models*)


(* ::Text:: *)
(*What ForceModel and FluxModel share. A model is head[assoc], with head ForceModel or FluxModel and these keys in assoc (and any the head adds):*)
(*"Name"; "Description" (or None); "Function", called only with numbers, with the parameters appended when there are any; "Parameters", where Missing["Required"] marks one with no default; "ScalesWithMassRatio" (multiplied by \[Epsilon]); "ValidityCondition", a function of (a, p, e, x), and "ValidityDescription" (or None); "Citation" (or None).*)
(*The head's options give the defaults, and it has the messages opt, optval, name, param, required, output, range and prop. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Section:: *)
(*Construction*)


$modelKeys = {"Name", "Description", "Function", "Parameters", "ScalesWithMassRatio", "ValidityCondition",
	"ValidityDescription", "Citation"};

(* The keys of a model with this head, in order: the shared ones, then the head's own *)
modelKeys[head_Symbol] := Join[$modelKeys, Complement[Keys[Options[head]], $modelKeys]];


(* ::Text:: *)
(*A model from its function and the head's options, or $Failed with a message*)


newModel[head_Symbol, f_, opts_List] := Module[{settings, unknown, model},
	settings = Association[opts];
	unknown = Complement[Keys[settings], Keys[Options[head]]];
	If[unknown =!= {}, Message[MessageName[head, "opt"], First[unknown], Keys[Options[head]]]; Return[$Failed]];
	model = Join[Association[Options[head]], settings, <|"Function" -> f|>];
	If[!StringQ[model["Name"]] || !AssociationQ[model["Parameters"]] || !BooleanQ[model["ScalesWithMassRatio"]],
		Message[MessageName[head, "optval"]]; Return[$Failed]];
	head[KeyTake[model, modelKeys[head]]]
];


(* ::Text:: *)
(*A model with new parameter values, which must be existing parameters*)


modelWithParameters[head_Symbol, assoc_Association, parameters_List] := Module[{unknown},
	unknown = Complement[Keys[parameters], Keys[assoc["Parameters"]]];
	If[unknown =!= {}, Message[MessageName[head, "param"], First[unknown], assoc["Name"], Keys[assoc["Parameters"]]]; Return[$Failed]];
	head[Append[assoc, "Parameters" -> Join[assoc["Parameters"], Association[parameters]]]]
];


(* ::Section:: *)
(*Properties and evaluation*)


modelProperty[head_Symbol, assoc_Association, key_String] := If[KeyExistsQ[assoc, key],
	assoc[key],
	Message[MessageName[head, "prop"], key, Keys[assoc]]; Missing["NotAvailable", key]];

modelMissingParameters[model_] := Keys[Select[model["Parameters"], MissingQ]];


(* ::Text:: *)
(*The model's function at the numbers args (parameters appended, if any), if it gives n real numbers; otherwise $Failed with a message.*)


callModel[model_, args_List, n_Integer] := Module[{parameters = model["Parameters"], result},
	result = If[parameters === <||>, model["Function"] @@ args, model["Function"] @@ Append[args, parameters]];
	If[VectorQ[result, realQ] && Length[result] == n,
		result,
		(* MessageName holds its first argument, so the head is put in with With *)
		With[{head = Head[model]}, Message[MessageName[head, "output"], model["Name"], Short[result], args]]; $Failed]
];


(* ::Section:: *)
(*In OsculatingInspiral*)


(* ::Text:: *)
(*The "Force" or "Flux" parameter as a list of models: None, a model, a built-in name, or a list of these. $Failed with a message if one is invalid (OsculatingInspiral's message tag) or lacks a required parameter.*)


resolveModels[head_Symbol, spec_, tag_String] := Module[{models, incomplete},
	models = Map[
		Which[
			MatchQ[#, _head] && AssociationQ[First[#]], #,
			StringQ[#], head[#],
			True, Message[MessageName[OsculatingInspiral, tag], #]; $Failed] &,
		Which[spec === None, {}, ListQ[spec], spec, True, {spec}]];
	If[MemberQ[models, $Failed], Return[$Failed]];
	incomplete = SelectFirst[models, modelMissingParameters[#] =!= {} &];
	If[!MissingQ[incomplete],
		Message[MessageName[head, "required"], incomplete["Name"], First[modelMissingParameters[incomplete]]];
		Return[$Failed]];
	models
];


(* ::Text:: *)
(*A warning for each model used outside its range of validity at the initial orbit*)


checkModelValidity[models_List, {a_, p_, e_, x_}] := Scan[
	If[!TrueQ[#["ValidityCondition"][a, p, e, x]],
		With[{head = Head[#]},
			Message[MessageName[head, "range"], #["Name"], Replace[#["ValidityDescription"], None -> "a restricted range"], a, p, e, x]]] &,
	models];


(* ::Text:: *)
(*A model's function as a solver needs it: component[i, args] is the i-th component of f[args]. It only evaluates for numbers, so it stays unevaluated in the symbolic equations, and caches the last value, as NDSolve evaluates every component at the same arguments.*)


cachedComponents[f_] := Module[{evaluate, component, cache = None},
	evaluate[args__?NumericQ] := memoLast[evaluate, cache, {args}, f[args]];
	component[i_, args__?NumericQ] := With[{value = evaluate[args]}, If[ListQ[value], value[[i]], Indeterminate]];
	component
];


(* ::Section:: *)
(*Summary box*)


modelSummaryBox[model_, form_] := With[{assoc = First[model]},
	BoxForm`ArrangeSummaryBox[Head[model], model, None,
		{
			BoxForm`SummaryItem[{"Name: ", assoc["Name"]}],
			BoxForm`SummaryItem[{"Parameters: ", assoc["Parameters"]}],
			BoxForm`SummaryItem[{"Scales with mass ratio: ", assoc["ScalesWithMassRatio"]}]},
		{
			If[KeyExistsQ[assoc, "Rates"], BoxForm`SummaryItem[{"Rates of: ", assoc["Rates"]}], Nothing],
			If[assoc["Description"] === None, Nothing, BoxForm`SummaryItem[{"Description: ", assoc["Description"]}]],
			If[assoc["ValidityDescription"] === None, Nothing, BoxForm`SummaryItem[{"Valid for: ", assoc["ValidityDescription"]}]],
			If[assoc["Citation"] === None, Nothing, BoxForm`SummaryItem[{"Citation: ", assoc["Citation"]}]]},
		form]
];
