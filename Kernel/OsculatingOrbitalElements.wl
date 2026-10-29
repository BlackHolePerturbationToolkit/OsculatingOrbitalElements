(* ::Package:: *)

(* ::Title:: *)
(*Osculating Orbital Elements Package*)


(* ::Text:: *)
(*The package header. It declares every public symbol (usage messages, options and messages), then loads the implementation files into a shared private context. A public symbol must be declared here, or it is created as a private one.*)


(* ::Subsection::Closed:: *)
(*Begin Package*)


BeginPackage["OsculatingOrbitalElements`",{"KerrGeodesics`","KerrGeodesics`SpecialOrbits`","KerrGeodesics`ConstantsOfMotion`","KerrGeodesics`OrbitalFrequencies`"}]


(* ::Subsection:: *)
(*Usage Statements*)


(* ::Subsubsection:: *)
(*The inspiral interface*)


MessageName[OsculatingInspiral, "usage"] =
"OsculatingInspiral[params] integrates the osculating geodesic equations for an inspiral in Kerr spacetime and returns an OsculatingInspiralFunction. params is an Association with the keys:
\"a\": the spin, 0 \[LessEqual] a < 1 (a = 0 is Schwarzschild);
\"\[Epsilon]\": the small mass ratio, which multiplies the forces and fluxes that scale with it;
\"p\", \"e\", \"x\": the initial semi-latus rectum, eccentricity and inclination x = cos \[Iota], with x \[NotEqual] 0. An equatorial orbit, x = \[PlusMinus]1, stays in the plane, so its force must have no \[Theta] component there and its flux must not change x;
\"Force\": a ForceModel, the name of a built-in model (\"GasDrag\", \"EMConservative\" or \"FastGSF\"), a list of these, which add, or None;
\"Flux\": a FluxModel, the name of a built-in model (\"Peters\"), a list of these, or None. A flux changes only the slowly varying elements, at its orbit-averaged rates with respect to t. Give a force, a flux or both; with neither the orbit is a geodesic;
\"\[Psi]r\", \"\[Psi]\[Theta]\", \"\[Phi]\" (optional, default 0): the initial Darwin and Hughes phases and azimuth.
The options are Parametrisation, IntegrationLimit, SeparatrixBuffer, pMin, TimeMonitor, AccuracyGoal, PrecisionGoal, and any option of NDSolve. The default method, an 8th-order explicit Runge-Kutta method with goals 12, resolves the rapid swings of \[Phi] as near-polar orbits pass close to the poles; looser settings, or another Method, may not."

MessageName[OsculatingInspiralFunction, "usage"] =
"OsculatingInspiralFunction[assoc] represents an inspiral computed by OsculatingInspiral. inspiral[t] gives {t, r, \[Theta], \[Phi]} at time t: coordinate time, or Mino time with Parametrisation -> \"Mino\". inspiral[\"prop\"] gives a property, and inspiral[\"Properties\"] lists them. Quantities that change along the inspiral are functions of time, for example inspiral[\"p\"][t]: the position, the elements and phases, and the osculating geodesic's constants of motion (\"En\", \"L\", \"Q\", \"K\"), Boyer-Lindquist frequencies (\"\[CapitalOmega]r\", \"\[CapitalOmega]\[Theta]\", \"\[CapitalOmega]\[Phi]\") and action angles (\"\[CapitalPhi]r\", \"\[CapitalPhi]\[Theta]\", \"\[CapitalPhi]\[Phi]\"). \"Domain\" is the range of time, and \"StopReason\" why the integration stopped."

MessageName[OsculatingInspiral, "params"] = "The first argument, `1`, should be an Association of the inspiral's parameters."

MessageName[OsculatingInspiral, "unknown"] = "Unknown parameters `1`. The parameters are `2`."

MessageName[OsculatingInspiral, "missing"] = "Missing parameters `1`."

MessageName[OsculatingInspiral, "range"] = "The parameter \"`1`\" is `2`, but should be `3`."

MessageName[OsculatingInspiral, "polar"] = "Orbits that start exactly polar (x = 0) are not supported, since they pass through the poles, where Boyer-Lindquist coordinates are singular."

MessageName[OsculatingInspiral, "flux"] = "`1` is not a valid flux. Use a FluxModel, the name of a built-in model, a list of these, or None."

MessageName[OsculatingInspiral, "nodriver"] = "Give a \"Force\", a \"Flux\", or both. Use \"Force\" -> None for a geodesic."

MessageName[OsculatingInspiral, "fluxtime"] = "Fluxes are averages with respect to coordinate time, so an inspiral with a flux needs Parametrisation -> \"CoordinateTime\"."

MessageName[OsculatingInspiral, "force"] = "`1` is not a valid force. Use a ForceModel, the name of a built-in model, a list of these, or None."

MessageName[OsculatingInspiral, "eqforce"] = "The force has a nonzero \[Theta] component, `1`, in the equatorial plane, so the orbit would leave the plane. Equatorial orbits (x = \[PlusMinus]1) are integrated with x held fixed, so they need a force with no \[Theta] component in the plane."

MessageName[OsculatingInspiral, "eqflux"] = "The flux changes x at the rate `1` on an equatorial orbit. Equatorial orbits (x = \[PlusMinus]1) are integrated with x held fixed, so they need a flux that does not change x."

MessageName[OsculatingInspiral, "sep"] = "The initial orbit must lie outside the separatrix by more than the separatrix buffer, `1`: p = `2`, and the separatrix is at p = `3`."

MessageName[OsculatingInspiral, "param"] = "Invalid value `1` for Parametrisation. Use \"CoordinateTime\" or \"Mino\"."

MessageName[OsculatingInspiral, "nosol"] = "NDSolve did not return a solution."

MessageName[OsculatingInspiral, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or a stopping condition."

MessageName[OsculatingInspiralFunction, "prop"] = "\"`1`\" is not a property of the inspiral. The properties are `2`."

MessageName[ForceModel, "usage"] =
"ForceModel[f, opts] is a force for OsculatingInspiral. f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t] returns the covariant components {F_r, F_\[Theta], F_\[Phi]} at azimuth \[Phi] and coordinate time t on the geodesic with those elements and phases, with the model's parameters as a last argument if it has any; F_t follows from orthogonality to the velocity. \[Phi] and t allow forces that are not axisymmetric or stationary. f is only called with numbers, and an undefined phase (\[Psi]r at e = 0, \[Psi]\[Theta] on an equatorial orbit) is 0. The options are \"Name\", \"Description\", \"Parameters\" (an Association), \"ScalesWithMassRatio\" (True: multiplied by \[Epsilon]), \"ValidityCondition\" (a function of a, p, e, x), \"ValidityDescription\" and \"Citation\".
ForceModel[\"name\", param -> value, ...] is a built-in model: \"GasDrag\" (parameter \"Coefficient\", not scaled by \[Epsilon]), \"EMConservative\", or \"FastGSF\" (Schwarzschild).
ForceModel[model, param -> value, ...] changes a model's parameters. model[\"prop\"] gives a property, and model[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t] the covariant {F_t, F_r, F_\[Theta], F_\[Phi]} before any factor of \[Epsilon]."

MessageName[ForceModel, "name"] = "Unknown force model `1`. The built-in models are `2`."

MessageName[ForceModel, "opt"] = "Unknown option `1`. The options are `2`."

MessageName[ForceModel, "optval"] = "\"Name\" must be a string, \"Parameters\" an Association, and \"ScalesWithMassRatio\" True or False."

MessageName[ForceModel, "param"] = "`1` is not a parameter of the force model `2`. Its parameters are `3`."

MessageName[ForceModel, "required"] = "The force model `1` needs a value for its parameter \"`2`\"."

MessageName[ForceModel, "output"] = "The force model `1` returned `2` at {a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t} = `3`. It must return three real numbers {F_r, F_\[Theta], F_\[Phi]}."

MessageName[ForceModel, "range"] = "Warning: the force model `1` is valid for `2`, but the inspiral starts at a = `3`, p = `4`, e = `5`, x = `6`."

MessageName[ForceModel, "prop"] = "\"`1`\" is not a property of the force model. The properties are `2`."

MessageName[FluxModel, "usage"] =
"FluxModel[f, opts] is a flux for OsculatingInspiral: orbit-averaged rates of change of the slowly varying elements with respect to coordinate time. f[a, p, e, x], with the parameters as a last argument if there are any, returns the rates of the quantities in the option \"Rates\": {\"p\", \"e\", \"x\"} (the default) or {\"En\", \"L\", \"Q\"}. f is only called with numbers. A physical flux has de/dt \[Proportional] e near e = 0 and dx/dt \[Proportional] 1 - x^2 near x = \[PlusMinus]1. The other options are those of ForceModel.
FluxModel[\"name\", param -> value, ...] is a built-in model: \"Peters\", the leading-order gravitational-wave fluxes.
FluxModel[force] is the orbit average of a ForceModel that depends on neither \[Phi] nor t: its rates of E, L and Q averaged over the geodesic with respect to t, using its parameter \"Points\" points in each phase.
FluxModel[model, param -> value, ...] changes a model's parameters. model[\"prop\"] gives a property, and model[a, p, e, x] the rates before any factor of \[Epsilon]."

MessageName[FluxModel, "name"] = "Unknown flux model `1`. The built-in models are `2`."

MessageName[FluxModel, "opt"] = "Unknown option `1`. The options are `2`."

MessageName[FluxModel, "optval"] = "\"Name\" must be a string, \"Parameters\" an Association, and \"ScalesWithMassRatio\" True or False."

MessageName[FluxModel, "rates"] = "\"Rates\" is `1`, but must be {\"p\", \"e\", \"x\"} or {\"En\", \"L\", \"Q\"}."

MessageName[FluxModel, "param"] = "`1` is not a parameter of the flux model `2`. Its parameters are `3`."

MessageName[FluxModel, "required"] = "The flux model `1` needs a value for its parameter \"`2`\"."

MessageName[FluxModel, "output"] = "The flux model `1` returned `2` at {a, p, e, x} = `3`. It must return three real numbers."

MessageName[FluxModel, "range"] = "Warning: the flux model `1` is valid for `2`, but the inspiral starts at a = `3`, p = `4`, e = `5`, x = `6`."

MessageName[FluxModel, "prop"] = "\"`1`\" is not a property of the flux model. The properties are `2`."

MessageName[Parametrisation, "usage"] = "Parametrisation is an option for OsculatingInspiral, KerrOsculatingOrbitalElements, GenericKerrpexBL and GenericKerrREGBL which specifies the time variable: \"CoordinateTime\" (the default) for Boyer-Lindquist coordinate time t, or \"Mino\" for Mino time \[Lambda]."

MessageName[pMin, "usage"] = "pMin is an option for OsculatingInspiral, GenericKerrpexBL and GenericKerrREGBL which stops the integration when p falls to the given value. The default, None, does not."

MessageName[SeparatrixBuffer, "usage"] = "SeparatrixBuffer is an option for OsculatingInspiral, GenericKerrpexBL and GenericKerrREGBL which specifies how far outside the separatrix, in p, the integration stops. A number stops at p_sep plus that number. Automatic stops at p_sep + \[Epsilon] in OsculatingInspiral. In GenericKerrpexBL and GenericKerrREGBL it stops at p_sep + \[Eta] when the eccentricity components are evolved (always in GenericKerrREGBL), and at the separatrix itself otherwise."

MessageName[IntegrationLimit, "usage"] = "IntegrationLimit is an option which specifies the largest value of the time variable to integrate to. For OsculatingInspiral this is the coordinate time t, or Mino time \[Lambda] with Parametrisation -> \"Mino\"; the default, Automatic, is 10^7 in coordinate time and 10^4 in Mino time. The earlier functions use it too: \[Chi] for SchwarzOsculatingOrbitalElements and t for SchwarzOsculatingOrbitalElementsTP (default 10^6), and as for OsculatingInspiral for KerrOsculatingOrbitalElements, GenericKerrpexBL and GenericKerrREGBL."

MessageName[TimeMonitor, "usage"] = "TimeMonitor is an option for OsculatingInspiral (and the earlier Kerr functions) which shows the time variable's progress while the equations are integrated. The monitor is only shown in a notebook. The default is False for OsculatingInspiral."


(* ::Subsection:: *)
(*Options and Syntax Information*)


Options[ForceModel] = {"Name" -> "Custom", "Description" -> None, "Parameters" -> <||>, "ScalesWithMassRatio" -> True,
	"ValidityCondition" -> (True &), "ValidityDescription" -> None, "Citation" -> None};

Options[FluxModel] = {"Name" -> "Custom", "Description" -> None, "Parameters" -> <||>, "Rates" -> {"p", "e", "x"},
	"ScalesWithMassRatio" -> True, "ValidityCondition" -> (True &), "ValidityDescription" -> None, "Citation" -> None};

Options[OsculatingInspiral] = {Parametrisation -> "CoordinateTime", IntegrationLimit -> Automatic, SeparatrixBuffer -> Automatic, pMin -> None, TimeMonitor -> False, AccuracyGoal -> 12, PrecisionGoal -> 12};
SyntaxInformation[OsculatingInspiral] = {"ArgumentsPattern" -> {_, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[OsculatingInspiral]], Keys[Options[NDSolve]]]};

(* ::Subsection:: *)
(*Legacy declarations*)


(* ::Text:: *)
(*LEGACY: the functions that OsculatingInspiral, ForceModel and FluxModel supersede, with their messages and options. Their code is in Kernel/Legacy, loaded last; they keep working but should not be extended.*)


MessageName[SchwarzOsculatingOrbitalElements, "usage"] = 
"Legacy, superseded by OsculatingInspiral with \"a\" -> 0. SchwarzOsculatingOrbitalElements[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], t and \[Phi] as functions of the Darwin Parameter (\[Chi]) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[SchwarzOsculatingOrbitalElementsTP, "usage"] = 
"Legacy, superseded by OsculatingInspiral with \"a\" -> 0. SchwarzOsculatingOrbitalElementsTP[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], and \[Phi] as functions of the coordinate time (t) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[SchwarzOsculatingOrbitalElements, "InvalidForce"] =  "Error: Invalid Expression for Force."

MessageName[SchwarzOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[SchwarzOsculatingOrbitalElements, "OutOfRange"] =  "Warning: FastGSF model only defined up to p<12 and e<0.2"

MessageName[SchwarzOsculatingOrbitalElements, "sep"] = "Integration stopped at the separatrix at `1` = `2`."

MessageName[SchwarzOsculatingOrbitalElements, "limit"] = "Integration reached IntegrationLimit (`1` = `2`) before the separatrix."

MessageName[SchwarzOsculatingOrbitalElements, "nosol"] = "NDSolve did not return a solution."

MessageName[SchwarzOsculatingOrbitalElements, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or the separatrix."

MessageName[KerrOsculatingOrbitalElements, "usage"] = 
"Legacy, superseded by OsculatingInspiral. KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[GenericKerrpexBL, "usage"] = 
"Legacy, superseded by OsculatingInspiral. GenericKerrpexBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates  p, e, x, \[Psi]r, and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]. For equatorial orbits (x = \[PlusMinus]1), x is held fixed, the \[Psi]\[Theta] argument is ignored, \"\[Psi]\[Theta]\" is Missing, and force callbacks receive \[Psi]\[Theta] = 0; the force must have no \[Theta] component on the equatorial plane. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[GenericKerrREGBL, "usage"] =
"Legacy, superseded by OsculatingInspiral. GenericKerrREGBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], opts] uses the exact regular eccentricity-component equations with the same arguments and options as GenericKerrpexBL. It also returns \"\[Alpha]p\"=e Sin[\[Psi]r] and \"\[Beta]p\"=e Cos[\[Psi]r]. The returned \"\[Psi]r\" is a principal-value phase and is Missing at e=0; its initial argument is ignored when e0=0. Custom covariant force callbacks retain the pex arguments and must be independent of the radial phase at e=0 (where the callback receives zero). Equatorial orbits (x = \[PlusMinus]1), the result's \"StopReason\" and NDSolve options are handled as in GenericKerrpexBL."

MessageName[GenericKerrREGBL, "nosol"] = "NDSolve did not return a solution."

MessageName[GenericKerrpexBL, "nosol"] = "NDSolve did not return a solution."


MessageName[KerrOsculatingOrbitalElements, "InvalidForce"] = 
"Error: Invalid Expression for Force."

MessageName[KerrOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[KerrOsculatingOrbitalElements, "nosol"] = "NDSolve did not return a solution."

MessageName[KerrOsculatingOrbitalElements, "param"] = "Error: Invalid value `1` for Parametrisation. Use \"CoordinateTime\" or \"Mino\"."

MessageName[KerrOsculatingOrbitalElements, "eqforce"] = "Error: The force has a nonzero \[Theta] component (`1`) on the equatorial plane, so the orbit would leave it. Equatorial orbits (x = \[PlusMinus]1) need a force with no \[Theta] component there."

MessageName[KerrOsculatingOrbitalElements, "sep"] = "Integration stopped at the separatrix at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "sepbuf"] = "Integration stopped at the separatrix buffer (see SeparatrixBuffer) at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "pmin"] = "Integration stopped at p = pMin at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "limit"] = "Integration reached IntegrationLimit (`1` = `2`) before the separatrix."

MessageName[KerrOsculatingOrbitalElements, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or a stopping condition."

MessageName[Force, "usage"] = "Legacy, superseded by the \"Force\" parameter of OsculatingInspiral. Force is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the model to use when solving the oscualting goedesic euqaitons. 
By default, the appropriate Gas Drag model is used. 
One can replace this with the name of any of the included models, or provide functions for each component. "

MessageName[SchwarzFastGSF, "usage"]= "Legacy, superseded by ForceModel[\"FastGSF\"]. SchwarzFastGSF[p,e,\[Xi]] returns Fr and F\[Phi] in terms of p, e, and \[Xi]. 
This function is accurate to first order for p < 12 and e< 0.2"

MessageName[SchwarzGasDrag, "usage"]= "Legacy, superseded by ForceModel[\"GasDrag\", \"Coefficient\" -> k]. SchwarzGasDrag[p,e,\[Xi]] returns contravarient components of a relativistic drag force, {Fr F\[Phi]}, in terms of p, e, and \[Xi]."

MessageName[KerrGasDrag, "usage"]= "Legacy, superseded by ForceModel[\"GasDrag\", \"Coefficient\" -> k]. KerrGasDrag[a,En,L,K, \[Psi]r, \[Psi]\[Theta]] returns covarient components of a relativistic drag force, {at,ar,a\[Theta],a\[Phi]}, in terms of a, En, L and K."

MessageName[KerrGasDragVec, "usage"]= "Legacy, superseded by ForceModel[\"GasDrag\", \"Coefficient\" -> k]. KerrGasDragVec[a,En,L,K, \[Psi]r, \[Psi]\[Theta]] returns vector components of a relativistic drag force, {fr,f\[Theta],f\[Phi]}, in terms of a, En, L and K."

MessageName[KerrEMCons, "usage"]= "Legacy, superseded by ForceModel[\"EMConservative\"]. KerrEMCons[a,p,e,x, \[Psi]r, \[Psi]\[Theta]] returns covarient components of a relativistic electromagnetic force, {at,ar,a\[Theta],a\[Phi]}, in terms of a, p, e and x."


MessageName[ForceUpDown, "usage"] = "Legacy, superseded by the \"Force\" parameter of OsculatingInspiral. ForceUpDown is an option for KerrOsculatingOrbitalElements: \"Down\" (the default) when Force gives the covariant components {a_t, a_r, a_\[Theta], a_\[Phi]}, \"Up\" when it gives the contravariant {f^r, f^\[Theta], f^\[Phi]}."


(* ::Text:: *)
(*The earlier header also replaced the built-in usage messages of AccuracyGoal and PrecisionGoal; they are kept only as comments.*)


(*
MessageName[AccuracyGoal, "usage"] = "AccuracyGoal is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the AccuarcyGoal of NDSolve.
Default: Automatic"

MessageName[PrecisionGoal, "usage"]= "PrecisionGoal is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the PrecisionGoal of NDSolve.
Default: Automatic"
*)


Options[SchwarzOsculatingOrbitalElements] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[SchwarzOsculatingOrbitalElements]], Keys[Options[NDSolve]]]};

Options[SchwarzOsculatingOrbitalElementsTP] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElementsTP] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[SchwarzOsculatingOrbitalElementsTP]], Keys[Options[NDSolve]]]};

Options[KerrOsculatingOrbitalElements] = {IntegrationLimit-> Automatic, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->"CoordinateTime", ForceUpDown-> "Down",TimeMonitor->True};
SyntaxInformation[KerrOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _,_, _,_, _, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[KerrOsculatingOrbitalElements]], Keys[Options[NDSolve]]]};

Options[GenericKerrpexBL] = {IntegrationLimit-> Automatic, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->"CoordinateTime", ForceUpDown-> "Down",TimeMonitor->True,pMin -> None, SeparatrixBuffer -> Automatic};
SyntaxInformation[GenericKerrpexBL] = {"ArgumentsPattern"-> {_, _, _,_, _,_, _, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[GenericKerrpexBL]], Keys[Options[NDSolve]]]};

Options[GenericKerrREGBL] = Options[GenericKerrpexBL];
SyntaxInformation[GenericKerrREGBL] = {"ArgumentsPattern" -> {_, _, _, _, _, _, _, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[GenericKerrREGBL]], Keys[Options[NDSolve]]]};


(* ::Subsection:: *)
(*Load the implementation*)


(* ::Text:: *)
(*The implementation files have no BeginPackage of their own: read here, inside the private context, every private helper is visible to every file. Load order only matters for code that runs at load time, such as reading the FastGSF data.*)


(* ::Input::Initialization:: *)
Begin["`Private`"]

(*The package's Kernel directory and the data directory, found from this file's location*)
$packageDirectory = DirectoryName[$InputFileName];
$dataDirectory = FileNameJoin[{ParentDirectory[$packageDirectory], "Data"}];

Get[FileNameJoin[{$packageDirectory, "Utilities.wl"}]];
Get[FileNameJoin[{$packageDirectory, "OrbitalAngles.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Models.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "ForceModel.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "GasDrag.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "EMConservative.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "FastGSF.wl"}]];
Get[FileNameJoin[{$packageDirectory, "FluxModels", "FluxModel.wl"}]];
Get[FileNameJoin[{$packageDirectory, "FluxModels", "PostNewtonian.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "KerrPEX.wl"}]];
Get[FileNameJoin[{$packageDirectory, "InspiralObject.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Interface.wl"}]];


(* ::Subsection:: *)
(*Legacy code*)


(* ::Text:: *)
(*The earlier functions, and the code only they use (see Kernel/Legacy).*)


Get[FileNameJoin[{$packageDirectory, "Legacy", "Utilities.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "ForceFunctions.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "Schwarzschild.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "KerrELK.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "GenericKerr.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "LegacyEquations.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Legacy", "RegularPolar.wl"}]];


(* ::Subsection:: *)
(*End Package*)


(* ::Input::Initialization:: *)
End[]
EndPackage[]
