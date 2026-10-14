(* ::Package:: *)

(* ::Title:: *)
(*Osculating Orbital Elements Package*)


(* ::Text:: *)
(*Package header. It declares every public symbol (usage messages, options and messages) and then loads the implementation files into a shared private context. Public symbols must be declared here; a symbol first used in an implementation file is created as a private symbol.*)


(* ::Subsection::Closed:: *)
(*Begin Package*)


BeginPackage["OsculatingOrbitalElements`",{"KerrGeodesics`","KerrGeodesics`SpecialOrbits`","KerrGeodesics`ConstantsOfMotion`"}]


(* ::Subsection:: *)
(*Usage Statements*)


(* ::Subsubsection:: *)
(*The inspiral interface*)


MessageName[OsculatingInspiral, "usage"] =
"OsculatingInspiral[params] integrates the osculating geodesic equations for an inspiral in Kerr spacetime and returns an OsculatingInspiralFunction. params is an Association with these keys:
\"a\": the spin, 0 \[LessEqual] a < 1.
\"\[Epsilon]\": the small mass ratio, which multiplies the forces and fluxes that scale with it.
\"p\", \"e\", \"x\": the initial semi-latus rectum, eccentricity and inclination x = cos \[Iota], with x \[NotEqual] 0. x = \[PlusMinus]1 is an equatorial orbit, and a = 0 is Schwarzschild.
\"Force\": a ForceModel, the name of a built-in model (\"GasDrag\", \"EMConservative\" or \"FastGSF\"), a list of these, whose forces add, or None.
\"Flux\": a FluxModel, the name of a built-in model (\"Peters\"), a list of these, or None. A flux changes only the slowly varying elements, at its orbit-averaged rates with respect to t; the phases advance at their geodesic rates, plus the effect of any force. Give \"Force\", \"Flux\" or both; with neither force nor flux the orbit is a geodesic.
\"\[Psi]r\", \"\[Psi]\[Theta]\", \"\[Phi]\" (optional, default 0): the initial Darwin and Hughes phases and azimuth.
The options are Parametrisation, IntegrationLimit, SeparatrixBuffer, pMin, TimeMonitor, AccuracyGoal, PrecisionGoal, and any option of NDSolve. By default NDSolve uses an 8th-order explicit Runge-Kutta method with AccuracyGoal and PrecisionGoal 12, which resolves the rapid swings of \[Phi] as near-polar orbits pass close to the poles; looser settings, or another Method, may not."

MessageName[OsculatingInspiralFunction, "usage"] =
"OsculatingInspiralFunction[assoc] represents an inspiral computed by OsculatingInspiral. inspiral[t] gives {t, r, \[Theta], \[Phi]} at coordinate time t, or at Mino time if Parametrisation -> \"Mino\" was used. inspiral[\"prop\"] gives a property, and inspiral[\"Properties\"] lists them. Quantities that change along the inspiral are functions of the time variable, for example inspiral[\"p\"][t]. \"Domain\" is the range of the time variable, and \"StopReason\" why the integration stopped."

MessageName[OsculatingInspiral, "params"] = "The first argument, `1`, should be an Association of the inspiral's parameters."

MessageName[OsculatingInspiral, "unknown"] = "Unknown parameters `1`. The parameters are `2`."

MessageName[OsculatingInspiral, "missing"] = "Missing parameters `1`."

MessageName[OsculatingInspiral, "range"] = "The parameter \"`1`\" is `2`, but should be `3`."

MessageName[OsculatingInspiral, "polar"] = "Orbits that start exactly polar (x = 0) are not supported, since they pass through the poles, where Boyer-Lindquist coordinates are singular."

MessageName[OsculatingInspiral, "flux"] = "`1` is not a valid flux. Use a FluxModel, the name of a built-in model, a list of these, or None."

MessageName[OsculatingInspiral, "nodriver"] = "Give a \"Force\", a \"Flux\", or both. Use \"Force\" -> None for a geodesic."

MessageName[OsculatingInspiral, "fluxtime"] = "Fluxes are averages with respect to coordinate time, so an inspiral with a flux needs Parametrisation -> \"CoordinateTime\"."

MessageName[OsculatingInspiral, "force"] = "`1` is not a valid force. Use a ForceModel, the name of a built-in model, a list of these, or None."

MessageName[OsculatingInspiral, "sep"] = "The initial orbit must lie outside the separatrix by more than the separatrix buffer, `1`: p = `2`, and the separatrix is at p = `3`."

MessageName[OsculatingInspiral, "param"] = "Invalid value `1` for Parametrisation. Use \"CoordinateTime\" or \"Mino\"."

MessageName[OsculatingInspiral, "nosol"] = "NDSolve did not return a solution."

MessageName[OsculatingInspiral, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or a stopping condition."

MessageName[OsculatingInspiralFunction, "prop"] = "\"`1`\" is not a property of the inspiral. The properties are `2`."

MessageName[ForceModel, "usage"] =
"ForceModel[f, opts] is a force for OsculatingInspiral. f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t] returns the covariant components {F_r, F_\[Theta], F_\[Phi]} of the force at the point with azimuth \[Phi] and coordinate time t on the geodesic with those elements and phases, or f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, params] if the model has parameters. A force may ignore \[Phi] and t; they allow forces that are not axisymmetric or stationary. F_t follows from orthogonality to the velocity. f is only called with numbers; where a phase is undefined (\[Psi]r at e = 0, \[Psi]\[Theta] on an equatorial orbit) it is 0. The options are \"Name\", \"Description\", \"Parameters\" (an Association), \"ScalesWithMassRatio\" (True: the force is multiplied by \[Epsilon]), \"ValidityCondition\" (a function of a, p, e, x), \"ValidityDescription\" and \"Citation\".
ForceModel[\"name\", param -> value, ...] is a built-in model: \"GasDrag\" (parameter \"Coefficient\", not scaled by \[Epsilon]), \"EMConservative\" and \"FastGSF\" (Schwarzschild).
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
"FluxModel[f, opts] is a flux for OsculatingInspiral: orbit-averaged rates of change of the slowly varying elements, with respect to coordinate time. f[a, p, e, x] returns the rates of the quantities given by the option \"Rates\": {\"p\", \"e\", \"x\"} (the default) or {\"En\", \"L\", \"Q\"}. With parameters, f[a, p, e, x, params]. f is only called with numbers. A physical flux has de/dt \[Proportional] e near e = 0 and dx/dt \[Proportional] 1 - x^2 near x = \[PlusMinus]1; a flux keeps a circular orbit circular and an equatorial orbit equatorial. The other options are those of ForceModel: \"Name\", \"Description\", \"Parameters\", \"ScalesWithMassRatio\" (True by default), \"ValidityCondition\", \"ValidityDescription\" and \"Citation\".
FluxModel[\"name\", param -> value, ...] is a built-in model: \"Peters\", the leading-order gravitational-wave fluxes.
FluxModel[force] is the orbit average of a ForceModel that depends on neither \[Phi] nor t: its rates of E, L and Q averaged over the geodesic's radial and polar motion with respect to t, using its parameter \"Points\" points in each phase.
FluxModel[model, param -> value, ...] changes a model's parameters. model[\"prop\"] gives a property, and model[a, p, e, x] the rates, before any factor of \[Epsilon]."

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


(* ::Subsubsection:: *)
(*Earlier functions*)


MessageName[SchwarzOsculatingOrbitalElements, "usage"] = 
"SchwarzOsculatingOrbitalElements[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], t and \[Phi] as functions of the Darwin Parameter (\[Chi]) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[SchwarzOsculatingOrbitalElementsTP, "usage"] = 
"SchwarzOsculatingOrbitalElementsTP[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], and \[Phi] as functions of the coordinate time (t) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[SchwarzOsculatingOrbitalElements, "InvalidForce"] =  "Error: Invalid Expression for Force."

MessageName[SchwarzOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[SchwarzOsculatingOrbitalElements, "OutOfRange"] =  "Warning: FastGSF model only defined up to p<12 and e<0.2"

MessageName[SchwarzOsculatingOrbitalElements, "sep"] = "Integration stopped at the separatrix at `1` = `2`."

MessageName[SchwarzOsculatingOrbitalElements, "limit"] = "Integration reached IntegrationLimit (`1` = `2`) before the separatrix."

MessageName[SchwarzOsculatingOrbitalElements, "nosol"] = "NDSolve did not return a solution."

MessageName[SchwarzOsculatingOrbitalElements, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or the separatrix."

MessageName[KerrOsculatingOrbitalElements, "usage"] = 
"KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[GenericKerrpexBL, "usage"] = 
"GenericKerrpexBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates  p, e, x, \[Psi]r, and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]. For equatorial orbits (x = \[PlusMinus]1), x is held fixed, the \[Psi]\[Theta] argument is ignored, \"\[Psi]\[Theta]\" is Missing, and force callbacks receive \[Psi]\[Theta] = 0; the force must have no \[Theta] component on the equatorial plane. The result's \"StopReason\" says why the integration stopped: \"Separatrix\", \"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early. Options of NDSolve are passed to NDSolve."

MessageName[TimeMonitor, "usage"] = "TimeMonitor is an option for KerrOsculatingOrbitalElementsTPVec that controls whether a progress monitor showing elapsed computation time is displayed. Set to True to enable, False to disable. The monitor is only shown when a notebook front end is available."

MessageName[GenericKerrREGBL, "usage"] =
"GenericKerrREGBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], opts] uses the exact regular eccentricity-component equations with the same arguments and options as GenericKerrpexBL. It also returns \"\[Alpha]p\"=e Sin[\[Psi]r] and \"\[Beta]p\"=e Cos[\[Psi]r]. The returned \"\[Psi]r\" is a principal-value phase and is Missing at e=0; its initial argument is ignored when e0=0. Custom covariant force callbacks retain the pex arguments and must be independent of the radial phase at e=0 (where the callback receives zero). Equatorial orbits (x = \[PlusMinus]1), the result's \"StopReason\" and NDSolve options are handled as in GenericKerrpexBL."

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

MessageName[SeparatrixBuffer, "usage"] = "SeparatrixBuffer is an option for OsculatingInspiral, GenericKerrpexBL and GenericKerrREGBL which specifies how far outside the separatrix, in p, the integration stops. A number stops at p_sep plus that number. Automatic stops at p_sep + \[Epsilon] in OsculatingInspiral. In GenericKerrpexBL and GenericKerrREGBL it stops at p_sep + \[Eta] when the eccentricity components are evolved (always in GenericKerrREGBL), and at the separatrix itself otherwise."

MessageName[IntegrationLimit, "usage"] = 
"IntegrationLimit is an option which specifies the largest value of the independent variable to integrate to: \[Chi] for SchwarzOsculatingOrbitalElements, t for SchwarzOsculatingOrbitalElementsTP, and t or \[Lambda] (set by Parametrisation) for KerrOsculatingOrbitalElements, GenericKerrpexBL and GenericKerrREGBL.
SchwarzOsculatingOrbitalElements Default: 1000000
KerrOsculatingOrbitalElements Default: Automatic, which is 10^7 in coordinate time and 10^4 in Mino time"

MessageName[Force, "usage"] = "Force is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the model to use when solving the oscualting goedesic euqaitons. 
By default, the appropriate Gas Drag model is used. 
One can replace this with the name of any of the included models, or provide functions for each component. "

MessageName[AccuracyGoal, "usage"] = "AccuracyGoal is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the AccuarcyGoal of NDSolve.
Default: Automatic"

MessageName[PrecisionGoal, "usage"]= "PrecisionGoal is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the PrecisionGoal of NDSolve.
Default: Automatic"

MessageName[SchwarzFastGSF, "usage"]= "SchwarzFastGSF[p,e,\[Xi]] returns Fr and F\[Phi] in terms of p, e, and \[Xi]. 
This function is accurate to first order for p < 12 and e< 0.2"

MessageName[SchwarzGasDrag, "usage"]= "SchwarzGasDrag[p,e,\[Xi]] returns contravarient components of a relativistic drag force, {Fr F\[Phi]}, in terms of p, e, and \[Xi]."

MessageName[KerrGasDrag, "usage"]= "KerrGasDrag[a,En,L,K, \[Psi]r, \[Psi]\[Theta]] returns covarient components of a relativistic drag force, {at,ar,a\[Theta],a\[Phi]}, in terms of a, En, L and K."

MessageName[KerrGasDragVec, "usage"]= "KerrGasDragVec[a,En,L,K, \[Psi]r, \[Psi]\[Theta]] returns vector components of a relativistic drag force, {fr,f\[Theta],f\[Phi]}, in terms of a, En, L and K."

MessageName[KerrEMCons, "usage"]= "KerrEMCons[a,p,e,x, \[Psi]r, \[Psi]\[Theta]] returns covarient components of a relativistic electromagnetic force, {at,ar,a\[Theta],a\[Phi]}, in terms of a, p, e and x."


(* ::Subsection:: *)
(*Options and Syntax Information*)


Options[ForceModel] = {"Name" -> "Custom", "Description" -> None, "Parameters" -> <||>, "ScalesWithMassRatio" -> True,
	"ValidityCondition" -> (True &), "ValidityDescription" -> None, "Citation" -> None};

Options[FluxModel] = {"Name" -> "Custom", "Description" -> None, "Parameters" -> <||>, "Rates" -> {"p", "e", "x"},
	"ScalesWithMassRatio" -> True, "ValidityCondition" -> (True &), "ValidityDescription" -> None, "Citation" -> None};

Options[OsculatingInspiral] = {Parametrisation -> "CoordinateTime", IntegrationLimit -> Automatic, SeparatrixBuffer -> Automatic, pMin -> None, TimeMonitor -> False, AccuracyGoal -> 12, PrecisionGoal -> 12};
SyntaxInformation[OsculatingInspiral] = {"ArgumentsPattern" -> {_, OptionsPattern[]}, "OptionNames" -> ToString /@ Union[Keys[Options[OsculatingInspiral]], Keys[Options[NDSolve]]]};

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
(*The implementation files have no BeginPackage of their own. They are read here, inside the private context, so every private helper is visible to every file. Load order only matters for code that runs at load time, such as reading the FastGSF data.*)


(* ::Input::Initialization:: *)
Begin["`Private`"]

(*The package's Kernel directory and the data directory, found from this file's location*)
$packageDirectory = DirectoryName[$InputFileName];
$dataDirectory = FileNameJoin[{ParentDirectory[$packageDirectory], "Data"}];

Get[FileNameJoin[{$packageDirectory, "Utilities.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Models.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "ForceModel.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "GasDrag.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "EMConservative.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "FastGSF.wl"}]];
Get[FileNameJoin[{$packageDirectory, "FluxModels", "FluxModel.wl"}]];
Get[FileNameJoin[{$packageDirectory, "FluxModels", "PostNewtonian.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "Schwarzschild.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "KerrELK.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "KerrPEX.wl"}]];
Get[FileNameJoin[{$packageDirectory, "InspiralObject.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Interface.wl"}]];


(* ::Subsection:: *)
(*Legacy code*)


(* ::Text:: *)
(*Unused code, kept for reference and loaded last. It is not used by the current interface and should not be extended. See Kernel/Legacy.*)


Get[FileNameJoin[{$packageDirectory, "Legacy", "LegacyEquations.wl"}]];


(* ::Subsection:: *)
(*End Package*)


(* ::Input::Initialization:: *)
End[]
EndPackage[]


(* ::Subsection:: *)
(*References*)
