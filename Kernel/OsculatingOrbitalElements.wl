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


MessageName[SchwarzOsculatingOrbitalElements, "usage"] = 
"SchwarzOsculatingOrbitalElements[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], t and \[Phi] as functions of the Darwin Parameter (\[Chi]) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]."

MessageName[SchwarzOsculatingOrbitalElementsTP, "usage"] = 
"SchwarzOsculatingOrbitalElementsTP[\[Eta], p, e, \[Xi], Force-> {Fr, F\[Phi]}] calculates p, e, \[Xi], and \[Phi] as functions of the coordinate time (t) using the contravarient components of an acceleration (Fr,F\[Phi]) and a mass ratio given by \[Eta]."

MessageName[SchwarzOsculatingOrbitalElements, "InvalidForce"] =  "Error: Invalid Expression for Force."

MessageName[SchwarzOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[SchwarzOsculatingOrbitalElements, "OutOfRange"] =  "Warning: FastGSF model only defined up to p<12 and e<0.2"

MessageName[SchwarzOsculatingOrbitalElements, "sep"] = "Integration stopped at the separatrix at `1` = `2`."

MessageName[SchwarzOsculatingOrbitalElements, "limit"] = "Integration reached IntegrationLimit (`1` = `2`) before the separatrix."

MessageName[SchwarzOsculatingOrbitalElements, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or the separatrix."

MessageName[KerrOsculatingOrbitalElements, "usage"] = 
"KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]."

MessageName[GenericKerrpexBL, "usage"] = 
"GenericKerrpexBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates  p, e, x, \[Psi]r, and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) or coordinate time(t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]. For equatorial orbits (x = \[PlusMinus]1), x is held fixed, the \[Psi]\[Theta] argument is ignored, \"\[Psi]\[Theta]\" is Missing, and force callbacks receive \[Psi]\[Theta] = 0; the force must have no \[Theta] component on the equatorial plane."

MessageName[TimeMonitor, "usage"] = "TimeMonitor is an option for KerrOsculatingOrbitalElementsTPVec that controls whether a progress monitor showing elapsed computation time is displayed. Set to True to enable, False to disable. The monitor is only shown when a notebook front end is available."

MessageName[GenericKerrREGBL, "usage"] =
"GenericKerrREGBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], opts] uses the exact regular eccentricity-component equations with the same arguments and options as GenericKerrpexBL. It also returns \"\[Alpha]p\"=e Sin[\[Psi]r] and \"\[Beta]p\"=e Cos[\[Psi]r]. The returned \"\[Psi]r\" is a principal-value phase and is Missing at e=0; its initial argument is ignored when e0=0. Custom covariant force callbacks retain the pex arguments and must be independent of the radial phase at e=0 (where the callback receives zero). Equatorial orbits (x = \[PlusMinus]1) are handled as in GenericKerrpexBL."

MessageName[GenericKerrREGBL, "nosol"] = "NDSolve did not return a solution."

MessageName[GenericKerrpexBL, "nosol"] = "NDSolve did not return a solution."


MessageName[KerrOsculatingOrbitalElements, "InvalidForce"] = 
"Error: Invalid Expression for Force."

MessageName[KerrOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[KerrOsculatingOrbitalElements, "nosol"] = "NDSolve did not return a solution."

MessageName[KerrOsculatingOrbitalElements, "param"] = "Error: Invalid value `1` for Parametrisation. Use \"CoordinateTime\" or \"Mino\"."

MessageName[KerrOsculatingOrbitalElements, "eqforce"] = "Error: The force has a nonzero \[Theta] component (`1`) on the equatorial plane, so the orbit would leave it. Equatorial orbits (x = \[PlusMinus]1) need a force with no \[Theta] component there."

MessageName[KerrOsculatingOrbitalElements, "sep"] = "Integration stopped at the separatrix at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "sepbuf"] = "Integration stopped at the separatrix safety boundary (p = p_sep + \[Eta]) at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "pmin"] = "Integration stopped at p = pMin at `1` = `2`."

MessageName[KerrOsculatingOrbitalElements, "limit"] = "Integration reached IntegrationLimit (`1` = `2`) before the separatrix."

MessageName[KerrOsculatingOrbitalElements, "early"] = "Warning: NDSolve stopped at `1` = `2`, before reaching IntegrationLimit or a stopping condition."

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


Options[SchwarzOsculatingOrbitalElements] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}};

Options[SchwarzOsculatingOrbitalElementsTP] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElementsTP] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}};

Options[KerrOsculatingOrbitalElements] = {IntegrationLimit-> Automatic, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->"CoordinateTime", ForceUpDown-> "Down",TimeMonitor->True};
SyntaxInformation[KerrOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _,_, _,_, _, OptionsPattern[]}};

Options[GenericKerrpexBL] = {IntegrationLimit-> Automatic, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->"CoordinateTime", ForceUpDown-> "Down",TimeMonitor->True,pMin -> None};
SyntaxInformation[GenericKerrpexBL] = {"ArgumentsPattern"-> {_, _, _,_, _,_, _, OptionsPattern[]}};

Options[GenericKerrREGBL] = Options[GenericKerrpexBL];
SyntaxInformation[GenericKerrREGBL] = {"ArgumentsPattern" -> {_, _, _, _, _, _, _, OptionsPattern[]}};


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
Get[FileNameJoin[{$packageDirectory, "ForceModels", "GasDrag.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "EMConservative.wl"}]];
Get[FileNameJoin[{$packageDirectory, "ForceModels", "FastGSF.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "Schwarzschild.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "KerrELK.wl"}]];
Get[FileNameJoin[{$packageDirectory, "Solvers", "KerrPEX.wl"}]];


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
