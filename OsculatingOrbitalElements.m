(* ::Package:: *)

(* ::Title:: *)
(*Osculating Orbital Elements Package*)


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

MessageName[KerrOsculatingOrbitalElements, "usage"] = 
"KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of Mino time (\[Lambda]) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]."

MessageName[KerrOsculatingOrbitalElementsTPVec, "usage"] = 
"KerrOsculatingOrbitalElementsTPVec[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{fr, f\[Theta] f\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of proper time (t) using a given by contravarient components of an acceleration (fr, f\[Theta], f\[Phi]) a mass ratio given by \[Eta]."

MessageName[TimeMonitor, "usage"] = "TimeMonitor is an option for KerrOsculatingOrbitalElementsTPVec that controls whether a progress monitor showing elapsed computation time is displayed. Set to True to enable, False to disable."

MessageName[KerrOsculatingOrbitalElementsTP, "usage"] = 
"KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of proper time (t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]."


MessageName[KerrOsculatingOrbitalElements, "InvalidForce"] = 
"Error: Invalid Expression for Force."

MessageName[KerrOsculatingOrbitalElements, "ICs"] =  "Error: The initial conditions given do not describe a bound orbit."

MessageName[IntegrationLimit, "usage"] = 
"IntegrationLimit is an option for SchwarzOsculatingOrbitalElements and KerrOsculatingOrbitalElements which specifies the maximum value of \[Chi] or \[Lambda] to use when solving the equations of motion.
SchwarzOsculatingOrbitalElements Default: 1000000
KerrOsculatingOrbitalElements Default: 10000"

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


(* ::Subsection::Closed:: *)
(*Options and Syntax Information*)


Options[SchwarzOsculatingOrbitalElements] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}};

Options[SchwarzOsculatingOrbitalElementsTP] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> SchwarzGasDrag};
SyntaxInformation[SchwarzOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _, _, OptionsPattern[]}};

Options[KerrOsculatingOrbitalElements] = {IntegrationLimit-> 10000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->CoordinateTime, ForceUpDown-> "Down",TimeMonitor->True};
SyntaxInformation[KerrOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _,_, _,_, OptionsPattern[]}};

Options[GenericKerrpexBL] = {IntegrationLimit-> 10000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic, Force -> KerrGasDrag, Parametrisation ->CoordinateTime, ForceUpDown-> "Down",TimeMonitor->True,pMin -> None};
SyntaxInformation[KerrOsculatingOrbitalElements] = {"ArgumentsPattern"-> {_, _, _,_, _,_, OptionsPattern[]}};



(* ::Input::Initialization:: *)
Begin["`Private`"]


(* ::Section:: *)
(*Schwarzschild Spacetime*)


(* ::Subsection::Closed:: *)
(*Private Functions*)


(* ::Subsubsection::Closed:: *)
(*Orbital Evolution: Version 1 *)


(* ::Text:: *)
(*This seems to be the fastest version of the Osculating Geodesics Equations which can be found in Warburton et al [1].  Equations are kept in terms of p,e, and \[Xi]. *)
(*However, this method is undefined when e = 0, and so the equation for \[Xi]' diverges for small values of e. *)


(* ::Input::Initialization:: *)
SchwarzOscGeoEqs1[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M =1, \[Mu], f0,f1,f2,f3,\[Beta], evolutionEqns,initialConditions, psol,esol,\[Xi]sol,tsol, \[Phi]sol, p,e,\[Xi],t,\[Phi],\[Chi], rsol, \[Theta]sol, progress = 0}, 
\[Mu] = \[Eta] M;


(*Defining useful quantites to make the final equations more compact*)
f0 [x_] := ((p[x]-2-2e[x] Cos[\[Xi][x]])(p[x]-3-e[x]^2))/(((p[x]-2)^2-4e[x]^2)^(1/2) ((p[x]-6)^2-4e[x]^2));
f1[x_] := (p[x]-6-2e[x]Cos[\[Xi][x]])^(1/2);
f2[x_] := (1+e[x]Cos[\[Xi][x]])^-2;
f3[x_] := f1[x]^2 e[x]Cos[\[Xi][x]]+2(p[x]-3);
\[Beta][x_] := p[x]-6-2e[x]^2;


(*Define the initial Conditions*)
initialConditions = {p[0] ==p0 ,  e[0] == e0, \[Xi][0] == \[Xi]0, t[0] == 0, \[Phi][0] == 0};

(*Defining the Evolution equations*)
evolutionEqns = { t'[\[Chi]] == (M p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]]),
				p'[\[Chi]] == \[Eta]((2 p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]]))p[\[Chi]]f0[\[Chi]]f1[\[Chi]](p[\[Chi]]^(1/2) f1[\[Chi]]f2[\[Chi]](p[\[Chi]]-3-e[\[Chi]]^2 Cos[\[Xi][\[Chi]]]^2)M F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] - e[\[Chi]]Sin[\[Xi][\[Chi]]] Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]), 
				e'[\[Chi]] == \[Eta](( p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]]))f0[\[Chi]](p[\[Chi]]^(1/2) f2[\[Chi]](\[Beta][\[Chi]]f3[\[Chi]]Cos[\[Xi][\[Chi]]]+e[\[Chi]](p[\[Chi]]^2-10p[\[Chi]]+12+4e[\[Chi]]^2)) M F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] + \[Beta][\[Chi]]f1[\[Chi]]Sin[\[Xi][\[Chi]]] Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]),

				\[Xi]'[\[Chi]] == 1-\[Eta](( p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]])) f0[\[Chi]]/e[\[Chi]] (p[\[Chi]]^(1/2) f2[\[Chi]]Sin[\[Xi][\[Chi]]]((p[\[Chi]]-6)f3[\[Chi]]-4e[\[Chi]]^3 Cos[\[Xi][\[Chi]]]) M F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]- f1[\[Chi]]((p[\[Chi]]-6)Cos[\[Xi][\[Chi]]]+2e[\[Chi]]) Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] ),
				\[Phi]'[\[Chi]] ==  Sqrt[p[\[Chi]]/(p[\[Chi]]-6-2e[\[Chi]] Cos[\[Xi][\[Chi]]])]};

(*Solving the Evolution Equaitons*)
Print["Starting NDSolve..."];
{{psol,esol,\[Xi]sol,tsol, \[Phi]sol}}= Monitor[{p,e,\[Xi],t,\[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2e[\[Chi]] -0.001 == 0, "StopIntegration"]}, {p,e,\[Xi],t,\[Phi]},{\[Chi],0, IntegrationLimit}, AccuracyGoal->Accuracy,PrecisionGoal->Precision, StepMonitor :> (progress = \[Chi])],  "\[Chi] = "<> ToString[progress]]//Quiet;

(*Punging Message*)
If[psol["Domain"][[1,2]] < IntegrationLimit, Print["Unbound orbit encountered."]];

(*Return associations for p, e, \[Xi], t and \[Phi] as functions of \[Chi]*)
rsol[\[Chi]_] := (M psol[\[Chi]])/(1-esol[\[Chi]] Cos[\[Xi]sol[\[Chi]]]);
\[Theta]sol[\[Chi]_]:= \[Pi]/2;
<|"t"-> tsol, "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol, "limit" -> psol["Domain"][[1,2]] |>
]


(* ::Input::Initialization:: *)
SchwarzOscGeoEqsTP[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M =1, \[Mu], f0,f1,f2,f3,\[Beta], evolutionEqns,initialConditions, psol,esol,\[Xi]sol,tsol, \[Phi]sol, p,e,\[Xi],t,\[Phi],\[Chi], rsol, \[Theta]sol, progress = 0}, 
\[Mu] = \[Eta] M;


(*Defining useful quantites to make the final equations more compact*)
f0 [x_] := ((p[x]-2-2e[x] Cos[\[Xi][x]])(p[x]-3-e[x]^2))/(((p[x]-2)^2-4e[x]^2)^(1/2) ((p[x]-6)^2-4e[x]^2));
f1[x_] := (p[x]-6-2e[x]Cos[\[Xi][x]])^(1/2);
f2[x_] := (1+e[x]Cos[\[Xi][x]])^-2;
f3[x_] := f1[x]^2 e[x]Cos[\[Xi][x]]+2(p[x]-3);
\[Beta][x_] := p[x]-6-2e[x]^2;


(*Define the initial Conditions*)
initialConditions = {p[0] ==p0 ,  e[0] == e0, \[Xi][0] == \[Xi]0, \[Phi][0] == 0};

(*Defining the Evolution equations*)
evolutionEqns = { 
				p'[t] == \[Eta] ((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]])/(M p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])((2 p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])/((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]]))p[t]f0[t]f1[t](p[t]^(1/2) f1[t]f2[t](p[t]-3-e[t]^2 Cos[\[Xi][t]]^2)M F\[Phi][p[t],e[t],\[Xi][t]] - e[t]Sin[\[Xi][t]] Fr[p[t],e[t],\[Xi][t]]), 

				e'[t] == \[Eta] ((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]])/(M p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])(( p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])/((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]]))f0[t](p[t]^(1/2) f2[t](\[Beta][t]f3[t]Cos[\[Xi][t]]+e[t](p[t]^2-10p[t]+12+4e[t]^2)) M F\[Phi][p[t],e[t],\[Xi][t]] + \[Beta][t]f1[t]Sin[\[Xi][t]] Fr[p[t],e[t],\[Xi][t]]),

				\[Xi]'[t] ==((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]]) /(M p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])-\[Eta] ((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]])/(M p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])(( p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])/((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]])) f0[t]/e[t] (p[t]^(1/2) f2[t]Sin[\[Xi][t]]((p[t]-6)f3[t]-4e[t]^3 Cos[\[Xi][t]]) M F\[Phi][p[t],e[t],\[Xi][t]]- f1[t]((p[t]-6)Cos[\[Xi][t]]+2e[t]) Fr[p[t],e[t],\[Xi][t]] ),
				\[Phi]'[t] ==((p[t]-2-2e[t] Cos[\[Xi][t]])(1+e[t] Cos[\[Xi][t]])^2 Sqrt[p[t]-6-2e[t]Cos[\[Xi][t]]])/(M p[t]^2 Sqrt[(p[t]-2)^2 -4e[t]^2])  Sqrt[p[t]/(p[t]-6-2e[t] Cos[\[Xi][t]])]};

(*Solving the Evolution Equaitons*)
Print["Starting NDSolve..."];
{{psol,esol,\[Xi]sol, \[Phi]sol}}= Monitor[{p,e,\[Xi],\[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[t]-6-2e[t] -0.001 == 0, "StopIntegration"]}, {p,e,\[Xi],\[Phi]},{t,0, IntegrationLimit}, AccuracyGoal->Accuracy,PrecisionGoal->Precision, StepMonitor :> (progress = t)],  "t = "<> ToString[progress]]//Quiet;

(*Punging Message*)
If[psol["Domain"][[1,2]] < IntegrationLimit, Print["Unbound orbit encountered."]];

(*Return associations for p, e, \[Xi], t and \[Phi] as functions of \[Chi]*)
rsol[t_] := (M psol[t])/(1-esol[t] Cos[\[Xi]sol[t]]);
\[Theta]sol[t_]:= \[Pi]/2;
<| "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol, "limit" -> psol["Domain"][[1,2]] |>
]


(* ::Subsubsection::Closed:: *)
(*Orbital Evolution: Version 2*)


(* ::Text:: *)
(*The equations are recast to be in terms of p, \[Alpha], \[Beta], which was formulated by Pound and Poisson [2]. This isn't as fast as version 1, but it is well defined for small values of e. *)


(* ::Input::Initialization:: *)
SchwarzOscGeoEqs2[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M=1, \[Mu], evolutionEqns,initialConditions, \[CapitalPsi],\[CapitalOmega],\[Alpha]0,\[Beta]0,psol, \[Alpha]sol, \[Beta]sol, esol, \[Xi]sol, \[Phi]sol, tsol, rsol, \[Theta]sol,p,e,\[Xi],\[Alpha],\[Beta],t,\[Phi],\[Chi], progress = 0},

\[Mu] = \[Eta] M;
(*Recast our initial conditions*)
\[Alpha]0 = e0 Sin[-\[Xi]0];
\[Beta]0 = e0 Cos[-\[Xi]0];

(*Define useful quantities, which will convert r,e,w, and v into expressions for \[Alpha] and \[Beta]*)
\[CapitalPsi][\[Chi]_] := \[Alpha][\[Chi]] Sin[\[Chi]];
\[CapitalOmega][\[Chi]_] := \[Beta][\[Chi]]Cos[\[Chi]];
e[\[Chi]_] := (\[Alpha][\[Chi]]^2 + \[Beta][\[Chi]]^2)^(1/2);
\[Xi][\[Chi]_] := \[Chi]- ArcTan[\[Beta][\[Chi]],\[Alpha][\[Chi]]];

(*Define the initial Conditions*)
initialConditions = { p[0] == p0, \[Alpha][0] ==\[Alpha]0 ,  \[Beta][0] == \[Beta]0,t[0] ==  0, \[Phi][0] ==0};

(*Define the evolution equations*)

evolutionEqns = {p'[\[Chi]] == \[Eta] (2p[\[Chi]]^(7/2) M Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])](p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)(p[\[Chi]]-3-(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)  F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) - \[Eta] (2p[\[Chi]]^3 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)(\[Beta][\[Chi]] Sin[\[Chi]] - \[Alpha][\[Chi]] Cos[\[Chi]]) Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),

\[Alpha]'[\[Chi]] == \[Eta]((p[\[Chi]]^(5/2) M (p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2) F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]] + \[CapitalOmega][\[Chi]])]((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) (4\[Beta][\[Chi]](\[Alpha][\[Chi]] \[Beta][\[Chi]] Cos[2\[Chi]] + 1/2 (\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)Sin[2\[Chi]])+(2(p[\[Chi]]-3)+(p[\[Chi]]-6)(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)((p[\[Chi]]-6)Sin[\[Chi]] - 2\[Alpha][\[Chi]](\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])) + \[Alpha][\[Chi]](p[\[Chi]]^2-10p[\[Chi]] +12 + 4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2)))- (p[\[Chi]]^2 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)((p[\[Chi]]-6-2\[Alpha][\[Chi]]^2)Cos[\[Chi]]+2\[Beta][\[Chi]](1+\[CapitalPsi][\[Chi]])) Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]] )/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)),

\[Beta]'[\[Chi]] == \[Eta]((p[\[Chi]]^(5/2) M (p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2) F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]] + \[CapitalOmega][\[Chi]])]((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) (-4\[Alpha][\[Chi]](\[Alpha][\[Chi]] \[Beta][\[Chi]] Cos[2\[Chi]] + 1/2 (\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)Sin[2\[Chi]])+(2(p[\[Chi]]-3)+(p[\[Chi]]-6)(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)((p[\[Chi]]-6)Cos[\[Chi]] - 2\[Beta][\[Chi]](\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])) + \[Beta][\[Chi]](p[\[Chi]]^2-10p[\[Chi]] +12 + 4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))) +(p[\[Chi]]^2 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)((p[\[Chi]]-6-2\[Beta][\[Chi]]^2)Sin[\[Chi]]+2\[Alpha][\[Chi]](1+\[CapitalOmega][\[Chi]]))Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)),
t'[\[Chi]]== (p[\[Chi]]^2 M Sqrt[(p[\[Chi]]-2)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2)])/((p[\[Chi]]-2-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]]))Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])] (1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),

\[Phi]'[\[Chi]] ==  Sqrt[p[\[Chi]]/(p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]]))]};


(*Solving the evolution equations*)
Print["Starting NDSolve..."];
{{psol,\[Alpha]sol,\[Beta]sol,tsol,\[Phi]sol}}= Monitor[{p,\[Alpha],\[Beta],t, \[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2)^(1/2) -0.001 == 0, "StopIntegration"]}, {p,\[Alpha],\[Beta],t,\[Phi]},{\[Chi],0,IntegrationLimit},AccuracyGoal->Accuracy,PrecisionGoal->Precision, Method->{"EquationSimplification"->"Solve"},StepMonitor :> (progress = \[Chi])],  "\[Chi] = "<> ToString[progress]]//Quiet;

(*Punging Message*)
If[psol["Domain"][[1,2]] < IntegrationLimit, Print["Unbound orbit encountered."]];

rsol[\[Chi]_] := (M psol[\[Chi]] )/(1+ \[Alpha]sol[\[Chi]] Sin[\[Chi]]+ \[Beta]sol[\[Chi]]Cos[\[Chi]] ); 
esol[\[Chi]_] := (\[Alpha]sol[\[Chi]]^2 + \[Beta]sol[\[Chi]]^2)^(1/2);
\[Xi]sol[\[Chi]_] := \[Chi]- ArcTan[\[Beta]sol[\[Chi]],\[Alpha]sol[\[Chi]]];
\[Theta]sol[\[Chi]_] := \[Pi]/2;

(*Return associations for the varibales as functions of \[Chi]*)
<| "t"-> tsol, "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol , "limit" -> tsol["Domain"][[1,2]]|>
]


(* ::Subsection::Closed:: *)
(*Public Functions*)


(* ::Subsubsection::Closed:: *)
(*Default Self Force Model: Fast GSF by Warburton et al.*)


(* ::Text:: *)
(*A fast to evaluate function for the Gravitational Self Force. This code was adapted from that provided by Niels Warburton. The derivation of this function is discussed in [2]*)


SetDirectory[FileNameJoin[{$UserBaseDirectory,"Applications", "OsculatingOrbitalElements", "DataFiles"}]];
(*Loading the files*)
dataA=Import["a_n_jk","Table"];
dataB=Import["b_n_jk","Table"];
dataC=Import["c_n_jk","Table"];
dataD=Import["d_n_jk","Table"];


(* ::Input::Initialization:: *)
SchwarzFastGSF[p_,e_,\[Xi]_, M_:1]:= Module[{FrCons, FrDiss,F\[Phi]Cons,F\[Phi]Diss, nmax,jbar,kbar,ki, a, b, c, d}, 

(*Make sue the files are stored in the same ddirectory as the notebook*)
(*Might make this editable in futre for greater ease of use*)
(*SetDirectory[FileNameJoin[{$UserBaseDirectory,"Applications", "OsculatingOrbitalElements", "DataFiles"}]];

(*Loading the files*)
dataA=Import["a_n_jk","Table"];
dataB=Import["b_n_jk","Table"];
dataC=Import["c_n_jk","Table"];
dataD=Import["d_n_jk","Table"];*)
(*Setting constants*)
nmax=7;
jbar=4;
kbar=9;
ki[1]=2;
ki[2]=9/2;
ki[3]=4;
ki[4]=11/2;

(*Calculating the tables a, b, c, and d*)
Table[a[1][n]=Table[dataA[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]],{j,0,4}],{n,0,nmax}];
Table[b[1][n]=Table[dataB[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]],{j,0,4}],{n,0,nmax}];
Table[c[1][n]=Table[dataC[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]],{j,0,4}],{n,0,nmax}];
Table[d[1][n]=Table[dataD[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]],{j,0,4}],{n,0,nmax}];

(*Calculating the companants of the graviational self force*)
FrCons=1/p^ki[1] Sum[If[n==0,1/2,1]a[1][n][[j+1,k+1]]p^(-ki[1]-k) e^(n+2j) Cos[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
FrDiss=1/p^ki[2] Sum[If[n==0,1/2,1]b[1][n][[j+1,k+1]]p^(-ki[2]-k) e^(n+2j) Sin[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Cons=1/p^ki[3] Sum[If[n==0,1/2,1]c[1][n][[j+1,k+1]]p^(-ki[3]-k) e^(n+2j) Sin[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Diss=1/p^ki[4] Sum[If[n==0,1/2,1]d[1][n][[j+1,k+1]]p^(-ki[4]-k) e^(n+2j) Cos[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];

(*Retuning the componants as a 4 vector*)
<|"Fr" -> (FrDiss + FrCons), "F\[Phi]" -> M(F\[Phi]Cons + F\[Phi]Diss)|>]


(* ::Subsubsection::Closed:: *)
(*Relativistic Gas Drag for Schwarzschild*)


(* ::Text:: *)
(*Relativistic Gas Drag Force for Schwarzschild spacetime as described in Appendix  D of "Forced Motion near a Black Hole" [5]*)


SchwarzGasDrag[p_, e_, \[Xi]_, M_:1]:= Module[{Fr, F\[Phi], ur, u\[Phi]}, 
ur = e Sin [\[Xi]] Sqrt[(p - 6 - 2e Cos[\[Xi]])/(p(p-3-e^2))];
u\[Phi] = (1+e Cos[\[Xi]])^2/(p M Sqrt[p-3-e^2]);
(*Retuning the componants as a 4 vector*)
<|"Fr" -> -ur, "F\[Phi]" ->  - u\[Phi]|>
]


(* ::Subsubsection:: *)
(*Osculating Orbital Element Evolution on Schwarzschild*)


(* ::Text:: *)
(*The function which controls checks the initial conditions passed in to make sure that they are valid. It then passes information to the Evolution function for calculation. *)


(* ::Text:: *)
(*First definition for if the self force is not specified.*)


(* ::Text:: *)
(*Second definition for when the self force components are specified.*)


(* ::Input::Initialization:: *)
SchwarzOsculatingOrbitalElements[\[Eta]_?NumericQ, p0_?NumericQ, e0_?NumericQ, \[Xi]0_?NumericQ, OptionsPattern[]]:= Module[{flag,error, Fr, F\[Phi]},
	(*Seperatrix condition for bound orbits in Schwarzschild Spacetime*)
	If[p0 < 6 + 2 e0, 
		Message[SchwarzOsculatingOrbitalElements::ICs];,
(* Go throught the different cases to assign functions to Fr and F\[Phi] *)
Switch[OptionValue["Force"],
			{_,_}, {Fr,F\[Phi]} = OptionValue["Force"];,
			SchwarzGasDrag, Fr[p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["Fr"]; F\[Phi][p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["F\[Phi]"];,
			SchwarzFastGSF, If[p0> 12.0 || e0 > 0.2,Message[SchwarzOsculatingOrbitalElements::OutOfRange];];
				Fr[p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["Fr"];
				F\[Phi][p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["F\[Phi]"];,
			_, Message[SchwarzOsculatingOrbitalElements::InvalidForce];  Return[]];

(*If[flag\[Equal] error, Return[]];(*If there's an error, return Null*)*)
		(*Decide which method to use*)
		If[e0> 0.05,
			(*Faster, but bad for small e0 values*)
			SchwarzOscGeoEqs1[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]],
			(*Slower, but works for arbitrily small values of e0*)
			SchwarzOscGeoEqs2[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]]
		]
	]
]

SchwarzOsculatingOrbitalElementsTP[\[Eta]_?NumericQ, p0_?NumericQ, e0_?NumericQ, \[Xi]0_?NumericQ, OptionsPattern[]]:= Module[{flag,error, Fr, F\[Phi]},
	(*Seperatrix condition for bound orbits in Schwarzschild Spacetime*)
	If[p0 < 6 + 2 e0, 
		Message[SchwarzOsculatingOrbitalElements::ICs];,
(* Go throught the different cases to assign functions to Fr and F\[Phi] *)
Switch[OptionValue["Force"],
			{_,_}, {Fr,F\[Phi]} = OptionValue["Force"];,
			SchwarzGasDrag, Fr[p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["Fr"]; F\[Phi][p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["F\[Phi]"];,
			SchwarzFastGSF, If[p0> 12.0 || e0 > 0.2,Message[SchwarzOsculatingOrbitalElements::OutOfRange];];
				Fr[p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["Fr"];
				F\[Phi][p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["F\[Phi]"];,
			_, Message[SchwarzOsculatingOrbitalElements::InvalidForce];  Return[]];

(*If[flag\[Equal] error, Return[]];(*If there's an error, return Null*)*)
		(*Decide which method to use*)
		If[e0> 0.05,
			(*Faster, but bad for small e0 values*)
			SchwarzOscGeoEqsTP[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]],
			(*Slower, but works for arbitrily small values of e0*)
			SchwarzOscGeoEqs2[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]]
		]
	]
]


(* ::Section:: *)
(*Kerr Spacetime*)


(* ::Subsection:: *)
(*Private Functions*)


(* ::Subsubsection::Closed:: *)
(*Roots of the Radial Potential*)


(* ::Text:: *)
(*We first must find the roots of the radial potential for a given value of a, En, L, and K. We note that the best performance comes from using analytic solutions of the roots for the integration (but taking care to account for when their values switch). We then use numerical functions to reconstruct functions for various quantities after the EoM have been solved.*)


Root1[a_?NumericQ, En_?NumericQ, L_?NumericQ, K_?NumericQ] := -(1/(2 (-1+En^2)))+1/2 \[Sqrt](1/(-1+En^2)^2-(2 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))+(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2)))+1/2 \[Sqrt](2/(-1+En^2)^2-(4 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))-(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))-(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2))+(-(8/(-1+En^2)^3)-(16 K)/(-1+En^2)+(8 (-a^2+2 a^2 En^2-K-2 a En L))/(-1+En^2)^2)/(4 \[Sqrt](1/(-1+En^2)^2-(2 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))+(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2)))));


Root2[a_?NumericQ, En_?NumericQ, L_?NumericQ, K_?NumericQ]:= -(1/(2 (-1+En^2)))-1/2 \[Sqrt](1/(-1+En^2)^2-(2 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))+(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2)))+1/2 \[Sqrt](2/(-1+En^2)^2-(4 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))-(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))-(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2))-(-(8/(-1+En^2)^3)-(16 K)/(-1+En^2)+(8 (-a^2+2 a^2 En^2-K-2 a En L))/(-1+En^2)^2)/(4 \[Sqrt](1/(-1+En^2)^2-(2 (-a^2+2 a^2 En^2-K-2 a En L))/(3 (-1+En^2))+(2^(1/3) (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)))/(3 (-1+En^2) (108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3))+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)+\[Sqrt](-4 (-12 K+(-a^2+2 a^2 En^2-K-2 a En L)^2+12 (-1+En^2) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^3+(108 (-1+En^2) K^2-36 K (-a^2+2 a^2 En^2-K-2 a En L)+2 (-a^2+2 a^2 En^2-K-2 a En L)^3+108 (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2)-72 (-1+En^2) (-a^2+2 a^2 En^2-K-2 a En L) (a^4 En^2-a^2 K-2 a^3 En L+a^2 L^2))^2))^(1/3)/(3 2^(1/3) (-1+En^2)))));


NumRoot1[a_?NumericQ, En_?NumericQ, L_?NumericQ, K_?NumericQ] :=  Module[{Vr, r, r1,r2,r3,r4},
(*Radial Potential*)
Vr = (En(r^2 + a^2) - a L )^2 - (r^2 + a^2 - 2r) (r^2+ K);
(*Finds roots and sorts them from largest to smallest *)
 {r1,r2,r3,r4} = Sort[ Re[r/.Solve[Vr == 0, r]], Greater];
 r1
];


NumRoot2[a_?NumericQ, En_?NumericQ, L_?NumericQ, K_?NumericQ] :=  Module[{Vr, r, r1,r2,r3,r4},
(*Radial Potential*)
Vr = (En(r^2 + a^2) - a L )^2 - (r^2 + a^2 - 2r) (r^2+ K);
(*Finds roots and sorts them from largest to smallest *)
 {r1,r2,r3,r4} = Sort[ Re[r/.Solve[Vr == 0, r]], Greater];
 r2
];


(* ::Subsubsection::Closed:: *)
(*Evolution Equations*)


KerrOscGeoEqs[\[Eta]_,a_,En_,L_,K_,\[Psi]r_,\[Psi]\[Theta]_,t_, \[Phi]_, at_,ar_,a\[Theta]_,a\[Phi]_, \[Lambda]_]:= Module[{Vr,r1, r2, p, e, r, \[Beta],Q, zm, zp, \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2, \[Omega], F, F1, F2, H, \[Theta], \[Kappa]1, \[Kappa]2, z, Q1, Q2,C,\[ScriptCapitalD],\[Epsilon], J, P, G, ur, u\[Theta], utup, u\[Phi]up, ut, u\[Phi], un, uztup, uz\[Phi]up, uzt, an,A1, A2, A3, dEd\[Lambda], dLd\[Lambda], dKd\[Lambda], d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda], Eqns, psol, esol, rsol, tsol, \[Phi]sol, \[Alpha],dtd\[Lambda],d\[Phi]d\[Lambda]},
(*Have to compare which of these two values is bigger/smaller as the definition of the roots flip in certain areas of te parameter space*)
r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]] ;


(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)

\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;

\[CapitalDelta] = r^2 + a^2 - 2r;
\[CapitalDelta]1 = r1^2 + a^2 - 2r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2r2;

\[Omega] = Sqrt[r^2+ a^2];

F = (r^2+ a^2) En- a L;
F1 = (r1^2+ a^2) En- a L;
F2 = (r2^2+ a^2) En- a L;

H = L - a En (1- zm (*Cos[\[Psi]\[Theta]]^2*)); (* Fixed typo found by Lisa Drummond *)
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];

\[Kappa]1 = 4En F1 r1 - 2 r1 \[CapitalDelta]1 - 2(r1-1)(r1^2 + K);
\[Kappa]2 = 4En F2 r2 - 2 r2 \[CapitalDelta]2 - 2(r2-1)(r2^2 + K);

Q1 = - 2 a L r r1 - a^4 En(r+r1) + a^3 L(r+r1) - a^2 En(r^3 + r^2 r1 + r1^3 + r r1(-2 + r1)) - En r r1 ( r r1 (r + r1) - 2(r^2 + r r1 + r1^2)) - a^2 (2a^2 En - 2En r r1 + a L(-2 + r + r1)) zm Cos[\[Psi]\[Theta]]^2;

Q2 = - 2 a L r r2 - a^4 En(r+r2) + a^3 L(r+r2) - a^2 En(r^3 + r^2 r2 + r2^3 + r r2(-2 + r2)) - En r r2 ( r r2 (r + r2) - 2(r^2 + r r2+ r2^2)) - a^2 (2a^2 En - 2En r r2 + a L(-2 + r + r2)) zm Cos[\[Psi]\[Theta]]^2;
C = (Q1 (1- e))/\[Kappa]1 - (Q2 (1+ e))/\[Kappa]2; 

\[ScriptCapitalD] = (1-e)^2 (1 - Cos[\[Psi]r]) \[CapitalDelta]1/\[Kappa]1 + (1+e)^2 (1 + Cos[\[Psi]r]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e)(r+r1))/\[Kappa]1 - (F2 (1+ e) (r + r2))/\[Kappa]2;  
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 
G =  (\[Omega]^2 L)/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*Convert from BL to Null Tetrad Componets*)

an = \[Omega]^2/(2\[CapitalSigma]) \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] - \[CapitalDelta]/(2\[CapitalSigma]) \[Eta] ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + a/(2\[CapitalSigma]) \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];

A1 = \[Eta] a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
A2 = -a Sin[\[Theta]] \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] - 1/Sin[\[Theta]] \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
A3 = (a(L - a En Sin[\[Theta]]^2))/\[CapitalSigma] \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + u\[Theta]/\[CapitalSigma] \[Eta] a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + (L - a En Sin[\[Theta]]^2)/(\[CapitalSigma] Sin[\[Theta]]^2) \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] ;  

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];
(*Osculating Geodesic Equations*)
(*Using simpler equations for the evolution of E, L and K*)
Eqns = {
D[En , \[Lambda]]== -\[CapitalSigma] \[Eta] at [a, En, L, K, \[Psi]r, \[Psi]\[Theta]], 

D[L, \[Lambda]] == \[CapitalSigma] \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]],   
D[K, \[Lambda]] == (2\[CapitalSigma])/\[CapitalDelta] (- \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]](\[Omega]^4 En - a \[Omega]^2 L) + \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]](a^2 L -a \[Omega]^2 En) - \[CapitalDelta]^2  ur \[Eta] ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]) + r^2(dtd\[Lambda] \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + (\[CapitalDelta] ur) \[Eta] ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]  + u\[Theta] \[Eta] a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + d\[Phi]d\[Lambda] \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]]),  
D[\[Psi]r, \[Lambda]] == P  +(C A3 Sin[\[Psi]r])/(2(1 + e Cos[\[Psi]r]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e Cos[\[Psi]r])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r] A2)/(1 + e Cos[\[Psi]r])  +  (P an)/(un ( 1 + e Cos[\[Psi]r])^2) ((1-e)^2 (1 - Cos[\[Psi]r]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e)^2 (1+Cos[\[Psi]r]) (\[CapitalSigma]2 F2)/\[Kappa]2),

 D[\[Psi]\[Theta], \[Lambda]] == Sqrt[\[Beta](zp - z)]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta]])/(\[Beta] Sqrt[zm](zp - zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(zp - zm) \[Beta] un) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] G A2 )/(\[Beta](zp - zm)),
  D[t, \[Lambda]] == En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]),
  D[\[Phi], \[Lambda]] == L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta] 
};

Eqns
]


KerrOscGeoEqsTP[\[Eta]_,a_,En_,L_,K_,\[Psi]r_,\[Psi]\[Theta]_, \[Phi]_, at_,ar_,a\[Theta]_,a\[Phi]_, t_]:= Module[{Vr,r1, r2, p, e, r, \[Beta],Q, zm, zp, \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2, \[Omega], F, F1, F2, H, \[Theta], \[Kappa]1, \[Kappa]2, z, Q1, Q2,C,\[ScriptCapitalD],\[Epsilon], J, P, G, ur, u\[Theta], utup, u\[Phi]up, ut, u\[Phi], un, uztup, uz\[Phi]up, uzt, an,A1, A2, A3, dEd\[Lambda], dLd\[Lambda], dKd\[Lambda], d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda], Eqns, psol, esol, rsol, tsol, \[Phi]sol, \[Alpha],dtd\[Lambda],d\[Phi]d\[Lambda]},
(*Have to compare which of these two values is bigger/smaller as the definition of the roots flip in certain areas of te parameter space*)
r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]] ;


(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)

\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;

\[CapitalDelta] = r^2 + a^2 - 2r;
\[CapitalDelta]1 = r1^2 + a^2 - 2r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2r2;

\[Omega] = Sqrt[r^2+ a^2];

F = (r^2+ a^2) En- a L;
F1 = (r1^2+ a^2) En- a L;
F2 = (r2^2+ a^2) En- a L;

H = L - a En (1- zm (*Cos[\[Psi]\[Theta]]^2*)); (* Fixed typo found by Lisa Drummond *)
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];

\[Kappa]1 = 4En F1 r1 - 2 r1 \[CapitalDelta]1 - 2(r1-1)(r1^2 + K);
\[Kappa]2 = 4En F2 r2 - 2 r2 \[CapitalDelta]2 - 2(r2-1)(r2^2 + K);

Q1 = - 2 a L r r1 - a^4 En(r+r1) + a^3 L(r+r1) - a^2 En(r^3 + r^2 r1 + r1^3 + r r1(-2 + r1)) - En r r1 ( r r1 (r + r1) - 2(r^2 + r r1 + r1^2)) - a^2 (2a^2 En - 2En r r1 + a L(-2 + r + r1)) zm Cos[\[Psi]\[Theta]]^2;

Q2 = - 2 a L r r2 - a^4 En(r+r2) + a^3 L(r+r2) - a^2 En(r^3 + r^2 r2 + r2^3 + r r2(-2 + r2)) - En r r2 ( r r2 (r + r2) - 2(r^2 + r r2+ r2^2)) - a^2 (2a^2 En - 2En r r2 + a L(-2 + r + r2)) zm Cos[\[Psi]\[Theta]]^2;
C = (Q1 (1- e))/\[Kappa]1 - (Q2 (1+ e))/\[Kappa]2; 

\[ScriptCapitalD] = (1-e)^2 (1 - Cos[\[Psi]r]) \[CapitalDelta]1/\[Kappa]1 + (1+e)^2 (1 + Cos[\[Psi]r]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e)(r+r1))/\[Kappa]1 - (F2 (1+ e) (r + r2))/\[Kappa]2;  
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 
G =  (\[Omega]^2 L)/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*Convert from BL to Null Tetrad Componets*)

an = \[Omega]^2/(2\[CapitalSigma]) \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] - \[CapitalDelta]/(2\[CapitalSigma]) \[Eta] ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + a/(2\[CapitalSigma]) \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];

A1 = \[Eta] a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
A2 = -a Sin[\[Theta]] \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] - 1/Sin[\[Theta]] \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
A3 = (a(L - a En Sin[\[Theta]]^2))/\[CapitalSigma] \[Eta] at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + u\[Theta]/\[CapitalSigma] \[Eta] a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + (L - a En Sin[\[Theta]]^2)/(\[CapitalSigma] Sin[\[Theta]]^2) \[Eta] a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] ;  

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];
(*Osculating Geodesic Equations*)
(*Using simpler equations for the evolution of E, L and K*)
Eqns = {
D[En , t]== -\[CapitalSigma] \[Eta] 1/dtd\[Lambda]  at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]], 

D[L, t] == \[CapitalSigma] \[Eta] 1/dtd\[Lambda]  a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]],   
D[K, t] == \[Eta]/dtd\[Lambda]  ((2\[CapitalSigma])/\[CapitalDelta] (-  at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]](\[Omega]^4 En - a \[Omega]^2 L) +   a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]](a^2 L -a \[Omega]^2 En) - \[CapitalDelta]^2  ur   ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]) + r^2(dtd\[Lambda]   at[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + (\[CapitalDelta] ur)   ar[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]  + u\[Theta]   a\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] + d\[Phi]d\[Lambda]   a\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]])),  
D[\[Psi]r, t] == 1/dtd\[Lambda]  (P  +(C A3 Sin[\[Psi]r])/(2(1 + e Cos[\[Psi]r]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e Cos[\[Psi]r])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r] A2)/(1 + e Cos[\[Psi]r])  +  (P an)/(un ( 1 + e Cos[\[Psi]r])^2) ((1-e)^2 (1 - Cos[\[Psi]r]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e)^2 (1+Cos[\[Psi]r]) (\[CapitalSigma]2 F2)/\[Kappa]2)),
 D[\[Psi]\[Theta], t] == 1/dtd\[Lambda]  (Sqrt[\[Beta](zp - z)]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta]])/(\[Beta] Sqrt[zm](zp - zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(zp - zm) \[Beta] un) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] G A2 )/(\[Beta](zp - zm))),
  D[\[Phi], t] == 1/dtd\[Lambda]  (L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta] )
};

Eqns
]


KerrOscGeoEqsTPVecLessArg[\[Eta]_,a_,En_,L_,K_,\[Psi]r_,\[Psi]\[Theta]_, \[Phi]_,fr_,f\[Theta]_,f\[Phi]_, t_]:= Module[{Vr,r1, ft,r2, p, e, r, \[Beta],Q, zm, zp, \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2, \[Omega], F, F1, F2, H, \[Theta], \[Kappa]1, \[Kappa]2, z, Q1, Q2,C,\[ScriptCapitalD],\[Epsilon], J, P, G, ur, u\[Theta], utup, u\[Phi]up, ut, u\[Phi], un, uztup, uz\[Phi]up, uzt, an,A1, A2, A3, dEd\[Lambda], dLd\[Lambda], dKd\[Lambda], d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda], Eqns, psol, esol, rsol, tsol, \[Phi]sol, \[Alpha],dtd\[Lambda],d\[Phi]d\[Lambda]},
(*Have to compare which of these two values is bigger/smaller as the definition of the roots flip in certain areas of te parameter space*)
r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]] ;

(*ft from ortogonality condition*)



(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)

\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;

\[CapitalDelta] = r^2 + a^2 - 2r;
\[CapitalDelta]1 = r1^2 + a^2 - 2r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2r2;

\[Omega] = Sqrt[r^2+ a^2];

F = (r^2+ a^2) En- a L;
F1 = (r1^2+ a^2) En- a L;
F2 = (r2^2+ a^2) En- a L;

H = L - a En (1- zm (*Cos[\[Psi]\[Theta]]^2*)); (* Fixed typo found by Lisa Drummond *)
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];

\[Kappa]1 = 4En F1 r1 - 2 r1 \[CapitalDelta]1 - 2(r1-1)(r1^2 + K);
\[Kappa]2 = 4En F2 r2 - 2 r2 \[CapitalDelta]2 - 2(r2-1)(r2^2 + K);

Q1 = - 2 a L r r1 - a^4 En(r+r1) + a^3 L(r+r1) - a^2 En(r^3 + r^2 r1 + r1^3 + r r1(-2 + r1)) - En r r1 ( r r1 (r + r1) - 2(r^2 + r r1 + r1^2)) - a^2 (2a^2 En - 2En r r1 + a L(-2 + r + r1)) zm Cos[\[Psi]\[Theta]]^2;

Q2 = - 2 a L r r2 - a^4 En(r+r2) + a^3 L(r+r2) - a^2 En(r^3 + r^2 r2 + r2^3 + r r2(-2 + r2)) - En r r2 ( r r2 (r + r2) - 2(r^2 + r r2+ r2^2)) - a^2 (2a^2 En - 2En r r2 + a L(-2 + r + r2)) zm Cos[\[Psi]\[Theta]]^2;
C = (Q1 (1- e))/\[Kappa]1 - (Q2 (1+ e))/\[Kappa]2; 

\[ScriptCapitalD] = (1-e)^2 (1 - Cos[\[Psi]r]) \[CapitalDelta]1/\[Kappa]1 + (1+e)^2 (1 + Cos[\[Psi]r]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e)(r+r1))/\[Kappa]1 - (F2 (1+ e) (r + r2))/\[Kappa]2;  
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 
G =  (\[Omega]^2 L)/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*Convert from BL to Null Tetrad Componets*)

an = \[Omega]^2/(2\[CapitalSigma]) \[Eta] (-2 a f\[Phi] [a, En, L, K, \[Psi]r, \[Psi]\[Theta]]p (1+e Cos[\[Psi]r]) (-1+zm Cos[\[Psi]\[Theta]]^2)+(1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])) (p^2-2 p (1+e Cos[\[Psi]r])+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2) - \[CapitalDelta]/(2\[CapitalSigma]) \[Eta] (-(((p^2/(1+e Cos[\[Psi]r])^2+a^2 zm Cos[\[Psi]\[Theta]]^2) fr[a,En,L,K,\[Psi]r,\[Psi]\[Theta]])/(a^2+(p (-2+p-2 e Cos[\[Psi]r]))/(1+e Cos[\[Psi]r])^2))) + a/(2\[CapitalSigma]) \[Eta] (1-zm Cos[\[Psi]\[Theta]]^2) ((2 a p (1+e Cos[\[Psi]r]) (1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)+(-a^2-p^2/(1+e Cos[\[Psi]r])^2+(a^2 p (1+e Cos[\[Psi]r]) (-2+zm+zm Cos[2 \[Psi]\[Theta]]))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)) f\[Phi][a,En,L,K,\[Psi]r,\[Psi]\[Theta]]);


A1 = \[Eta] (-(p^2/(1+e Cos[\[Psi]r])^2)-a^2 zm Cos[\[Psi]\[Theta]]^2) f\[Theta][a,En,L,K,\[Psi]r,\[Psi]\[Theta]];
A2 = -a Sin[\[Theta]] \[Eta] (-2 a f\[Phi] [a, En, L, K, \[Psi]r, \[Psi]\[Theta]]p (1+e Cos[\[Psi]r]) (-1+zm Cos[\[Psi]\[Theta]]^2)+(1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])) (p^2-2 p (1+e Cos[\[Psi]r])+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2) - 1/Sin[\[Theta]] \[Eta] (1-zm Cos[\[Psi]\[Theta]]^2) ((2 a p (1+e Cos[\[Psi]r]) (1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)+(-a^2-p^2/(1+e Cos[\[Psi]r])^2+(a^2 p (1+e Cos[\[Psi]r]) (-2+zm+zm Cos[2 \[Psi]\[Theta]]))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)) f\[Phi][a,En,L,K,\[Psi]r,\[Psi]\[Theta]]);
A3 = (a(L - a En Sin[\[Theta]]^2))/\[CapitalSigma] \[Eta] (-2 a f\[Phi] [a, En, L, K, \[Psi]r, \[Psi]\[Theta]]p (1+e Cos[\[Psi]r]) (-1+zm Cos[\[Psi]\[Theta]]^2)+(1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])) (p^2-2 p (1+e Cos[\[Psi]r])+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2) + u\[Theta]/\[CapitalSigma] \[Eta] (-(p^2/(1+e Cos[\[Psi]r])^2)-a^2 zm Cos[\[Psi]\[Theta]]^2) f\[Theta][a,En,L,K,\[Psi]r,\[Psi]\[Theta]] + (L - a En Sin[\[Theta]]^2)/(\[CapitalSigma] Sin[\[Theta]]^2) \[Eta] (1-zm Cos[\[Psi]\[Theta]]^2) ((2 a p (1+e Cos[\[Psi]r]) (1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)+(-a^2-p^2/(1+e Cos[\[Psi]r])^2+(a^2 p (1+e Cos[\[Psi]r]) (-2+zm+zm Cos[2 \[Psi]\[Theta]]))/(p^2+a^2 zm (1+e Cos[\[Psi]r])^2 Cos[\[Psi]\[Theta]]^2)) f\[Phi][a,En,L,K,\[Psi]r,\[Psi]\[Theta]]) ;  

(*ft[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]=1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])*);

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];
(*Osculating Geodesic Equations*)
(*Using simpler equations for the evolution of E, L and K*)
Eqns = {
D[En , t]== -((f\[Phi][a,En,L,K,\[Psi]r,\[Psi]\[Theta]] (a^2+(-2+r) r) (L (-2+r) r-2 a En r (-1+z)+a^2 L z) \[Eta])/(En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z))))+(e fr[a,En,L,K,\[Psi]r,\[Psi]\[Theta]] \[Sqrt]((-1+e^2) (-1+En^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/r^2-(4 p)/r^2+((3+e^2) (-1+En^2) p^2)/((-1+e^2) r^2)+(2 (-1+e^2+p-En^2 p))/r) r^2 (-2 r+r^2+a^2 z) \[Eta] Sin[\[Psi]r])/((-1+e^2) En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z)))-(f\[Theta][a,En,L,K,\[Psi]r,\[Psi]\[Theta]] (a^2+(-2+r) r) (-2 r+r^2+a^2 z) Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] \[Eta] Sin[\[Psi]\[Theta]])/(En Sqrt[1-z] (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z))), 

D[L, t] == (f\[Phi][a,En,L,K,\[Psi]r,\[Psi]\[Theta]] (a^2+(-2+r) r) (-1+z) \[Eta] (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r+r z-zm)-a^2 En r zm Cos[2 \[Psi]\[Theta]]))/(En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z)))+(2 a e fr[a,En,L,K,\[Psi]r,\[Psi]\[Theta]] \[Sqrt]((-1+e^2) (-1+En^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/r^2-(4 p)/r^2+((3+e^2) (-1+En^2) p^2)/((-1+e^2) r^2)+(2 (-1+e^2+p-En^2 p))/r) r^3 (-1+z) \[Eta] Sin[\[Psi]r])/((-1+e^2) En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z)))+(2 a f\[Theta][a,En,L,K,\[Psi]r,\[Psi]\[Theta]] r (a^2+(-2+r) r) Sqrt[1-z] Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] \[Eta] Sin[\[Psi]\[Theta]])/(En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z))),    
D[K, t] == -((f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] \[Eta] (2 En L (-2+r) r^7-2 a (-2+r) r^5 (L^2-En^2 r^2 (-1+z))-2 a^8 En L (-2+z) z^2+2 a^9 En^2 (-1+z) z^2+2 a^7 z (-L^2 z+En^2 r (-1+z) (2 r (1+z)-zm))+a^4 En L r^3 (2 z^2-2 r (-2-5 z+z^2)+z (-12+zm)-2 zm)-2 a^6 En L r z (r (-4-z+z^2)-z (-2+zm)+zm)+a^2 En L r^4 (-4 z+2 r^2 (3+z)+2 zm-r (8+2 z+zm))+2 a^5 r (-L^2 z (-2 z+r (2+z))+En^2 r^2 (-1+z) (r (1+4 z+z^2)-zm-z (2+zm)))-2 a^3 r^3 (L^2 (r-4 z+2 r z)-En^2 r (-1+z) (-2 z+2 r^2 (1+z)+zm-r (2+2 z+zm)))-a^2 En r (L (-2+r) r^3-a^2 L r^2 (-2+z)+2 a En (-1+r) r^3 (-1+z)+2 a^5 En (-1+z) z-2 a^4 L (-1+z) z+2 a^3 En r^2 (-1+z^2)) zm Cos[2 \[Psi]\[Theta]]))/(En (r^2+a^2 z) (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z))))+(fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] (r^2+a^2 z) \[Eta] ((-1+e^2) En (a^2+(-2+r) r) ur (r^2+2 a^2 z)+e r^2 (2 a^2 En-2 a L+En r^2) \[Sqrt](1/((-1+e^2) r^2) (a^2 (-1+e^2)^2 (-1+2 En^2)-(-1+e^2)^2 K-2 a (-1+e^2)^2 En L+4 p-4 e^2 p-3 p^2-e^2 p^2+3 En^2 p^2+e^2 En^2 p^2+2 r-4 e^2 r+2 e^4 r-2 p r+2 e^2 p r+2 En^2 p r-2 e^2 En^2 p r-r^2+2 e^2 r^2-e^4 r^2+En^2 r^2-2 e^2 En^2 r^2+e^4 En^2 r^2)) Sin[\[Psi]r]))/((-1+e^2) En (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z)))-(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] (a^2+(-2+r) r) (r^2+a^2 z) \[Eta] (En r^2 u\[Theta] Sqrt[1-z]+(2 a^2 En-2 a L+En r^2) Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] Sin[\[Psi]\[Theta]]))/(En Sqrt[1-z] (-2 a L r+En r^4+a^4 En z+a^2 En r (2+r-2 z+r z))),  
D[\[Psi]r, t] == 1/dtd\[Lambda]  (P  +(C A3 Sin[\[Psi]r])/(2(1 + e Cos[\[Psi]r]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e Cos[\[Psi]r])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r] A2)/(1 + e Cos[\[Psi]r])  +  (P an)/(un ( 1 + e Cos[\[Psi]r])^2) ((1-e)^2 (1 - Cos[\[Psi]r]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e)^2 (1+Cos[\[Psi]r]) (\[CapitalSigma]2 F2)/\[Kappa]2)),
 D[\[Psi]\[Theta], t] == 1/dtd\[Lambda]  (Sqrt[\[Beta](zp - z)]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta]])/(\[Beta] Sqrt[zm](zp - zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(zp - zm) \[Beta] un) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] G A2 )/(\[Beta](zp - zm))),
  D[\[Phi], t] == 1/dtd\[Lambda]  (L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta] )
};

Eqns
]


(* ::Subsubsection::Closed:: *)
(*Separatrix equation*)


SeparatrixEqELK[a_?NumericQ,En_?NumericQ,L_?NumericQ,k_?NumericQ]:=16 (-1+En) (1+En) (a^10 En^2-a^12 En^2-27 a^8 En^4+30 a^10 En^4+a^12 En^4-96 a^10 En^6+64 a^10 En^8-a^8 k+a^10 k+36 a^6 En^2 k-43 a^8 En^2 k+3 a^10 En^2 k+36 a^6 En^4 k+80 a^8 En^4 k-4 a^10 En^4 k+96 a^8 En^6 k-128 a^8 En^8 k-8 a^4 k^2+12 a^6 k^2-4 a^8 k^2-52 a^4 En^2 k^2+42 a^6 En^2 k^2-2 a^8 En^2 k^2-2 a^4 En^4 k^2-220 a^6 En^4 k^2+6 a^8 En^4 k^2+96 a^6 En^6 k^2+64 a^6 En^8 k^2-16 k^3+32 a^2 k^3-22 a^4 k^3+6 a^6 k^3-52 a^2 En^2 k^3+42 a^4 En^2 k^3-2 a^6 En^2 k^3+36 a^2 En^4 k^3+80 a^4 En^4 k^3-4 a^6 En^4 k^3-96 a^4 En^6 k^3-8 k^4+12 a^2 k^4-4 a^4 k^4+36 En^2 k^4-43 a^2 En^2 k^4+3 a^4 En^2 k^4-27 En^4 k^4+30 a^2 En^4 k^4+a^4 En^4 k^4-k^5+a^2 k^5+En^2 k^5-a^2 En^2 k^5-2 a^9 En L+2 a^11 En L+108 a^7 En^3 L-126 a^9 En^3 L+6 a^11 En^3 L+456 a^9 En^5 L-8 a^11 En^5 L-320 a^9 En^7 L-72 a^5 En k L+92 a^7 En k L-16 a^9 En k L-108 a^5 En^3 k L-188 a^7 En^3 k L-8 a^9 En^3 k L-440 a^7 En^5 k L+24 a^9 En^5 k L+512 a^7 En^7 k L+64 a^3 En k^2 L-88 a^5 En k^2 L+36 a^7 En k^2 L+4 a^3 En^3 k^2 L+440 a^5 En^3 k^2 L-12 a^7 En^3 k^2 L-136 a^5 En^5 k^2 L-24 a^7 En^5 k^2 L-192 a^5 En^7 k^2 L+40 a En k^3 L+4 a^3 En k^3 L-32 a^5 En k^3 L-36 a En^3 k^3 L-132 a^3 En^3 k^3 L+24 a^5 En^3 k^3 L+120 a^3 En^5 k^3 L+8 a^5 En^5 k^3 L-6 a En k^4 L+10 a^3 En k^4 L+6 a En^3 k^4 L-10 a^3 En^3 k^4 L+a^8 L^2-a^10 L^2-162 a^6 En^2 L^2+198 a^8 En^2 L^2-23 a^10 En^2 L^2-864 a^8 En^4 L^2+8 a^10 En^4 L^2+640 a^8 En^6 L^2+16 a^10 En^6 L^2+36 a^4 k L^2-49 a^6 k L^2+12 a^8 k L^2+108 a^4 En^2 k L^2+124 a^6 En^2 k L^2+68 a^8 En^2 k L^2+744 a^6 En^4 k L^2-48 a^8 En^4 k L^2-768 a^6 En^6 k L^2-32 a^8 En^6 k L^2-12 a^2 k^2 L^2+31 a^4 k^2 L^2-22 a^6 k^2 L^2-2 a^2 En^2 k^2 L^2-234 a^4 En^2 k^2 L^2-66 a^6 En^2 k^2 L^2-16 a^4 En^4 k^2 L^2+72 a^6 En^4 k^2 L^2+192 a^4 En^6 k^2 L^2+16 a^6 En^6 k^2 L^2-15 a^2 k^3 L^2+12 a^4 k^3 L^2+40 a^2 En^2 k^3 L^2+20 a^4 En^2 k^3 L^2-24 a^2 En^4 k^3 L^2-32 a^4 En^4 k^3 L^2-a^2 k^4 L^2+a^2 En^2 k^4 L^2+108 a^5 En L^3-138 a^7 En L^3+24 a^9 En L^3+816 a^7 En^3 L^3+40 a^9 En^3 L^3-640 a^7 En^5 L^3-64 a^9 En^5 L^3-36 a^3 En k L^3-4 a^5 En k L^3-88 a^7 En k L^3-552 a^5 En^3 k L^3-8 a^7 En^3 k L^3+512 a^5 En^5 k L^3+96 a^7 En^5 k L^3+14 a^3 En k^2 L^3+72 a^5 En k^2 L^3+56 a^3 En^3 k^2 L^3-40 a^5 En^3 k^2 L^3-64 a^3 En^5 k^2 L^3-32 a^5 En^5 k^2 L^3-8 a^3 En k^3 L^3+8 a^3 En^3 k^3 L^3-27 a^4 L^4+36 a^6 L^4-8 a^8 L^4-384 a^6 En^2 L^4-88 a^8 En^2 L^4+320 a^6 En^4 L^4+96 a^8 En^4 L^4-12 a^4 k L^4+32 a^6 k L^4+152 a^4 En^2 k L^4+64 a^6 En^2 k L^4-128 a^4 En^4 k L^4-96 a^6 En^4 k L^4-8 a^4 k^2 L^4-8 a^4 En^2 k^2 L^4+16 a^4 En^4 k^2 L^4+72 a^5 En L^5+64 a^7 En L^5-64 a^5 En^3 L^5-64 a^7 En^3 L^5-32 a^5 En k L^5+32 a^5 En^3 k L^5-16 a^6 L^6+16 a^6 En^2 L^6)


(* ::Subsubsection::Closed:: *)
(*Constants of Motion*)


Energy[a_?NumericQ, p_?NumericQ, (0|0.), x_?NumericQ] := Energy[a, p, 0, x] =\[Sqrt](((-3+p) (-2+p)^2 p^5
-2 a^5 x (-1+x^2) Sqrt[p^3+a^2 p (-1+x^2)]+a^4 p^2 (-1+x^2) (4-5 p (-1+x^2)+3 p^2 (-1+x^2))-a^6 (-1+x^2)^2 (x^2+p^2 (-1+x^2)-
p (1+2 x^2))+a^2 p^3 (4-4 x^2+p (12-7 x^2)-3 p^3 (-1+x^2)+p^2 (-13+10 x^2))+a (-2 p^(9/2) x Sqrt[p^2+a^2 (-1+x^2)]+4 p^3 x Sqrt[p^3+a^2 p (-1+x^2)])+
2 a^3 (2 p x (-1+x^2) Sqrt[p^3+a^2 p (-1+x^2)]-x^3 Sqrt[p^7+a^2 p^5 (-1+x^2)]))/
((p^2-a^2 (-1+x^2)) ((-3+p)^2 p^4-2 a^2 p^2 (3+2 p-3 x^2+p^2 (-1+x^2))+a^4 (-1+x^2) (-1+x^2+p^2 (-1+x^2)-2 p (1+x^2)))));

Energy[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= Energy[a,p,e,x]=  1/4 \[Sqrt](((-1+e^2)^8 x^4 (-(1/((-1+e^2)^6 x^2))32 a^2 e^2 p^2 (-p^2+a^2 (-1+e^2) (-1+x^2)) 
(-p^3 (-4+3 p+e^2 (4+p))+a^2 (-1+e^2)^2 p^2 (-2+x^2)+a^4 (-1+e^2)^3 (-1+x^2))-32 x 
\[Sqrt](-(1/((-1+e^2)^12 x^8)) a^2 e^4 p^5 (a^4 (-1+e^2)^2+(-4 e^2+(-2+p)^2) p^2+2 a^2 p (-2+p+e^2 (2+p))) (-p^2+a^2 (-1+e^2) (-1+x^2))^3 (p^4-2 a^2 (1+e^2) p^2 
(-1+x^2)+a^4 (-1+e^2)^2 (-1+x^2)^2))+1/((-1+e^2)^8 x^4) 16 e^2 p^2 (p^4 (-3-e^2+p)+a^4 (-1+e^2)^2 (-1+x^2) (-1-x^2+p (-1+x^2)+e^2 (1+x^2))-2 a^2 p^2 
(1+e^4+p (-1+x^2)+e^2 (-2+p (-1+x^2)))) ((-4 e^2+(-2+p)^2) p^3+a^4 (-1+e^2)^2 (-1+x^2) ((-1+e^2) x^2+p (-1+x^2))-a^2 p^2 (4-3 x^2+e^4 x^2+2 p (-1+x^2)
+2 e^2 (-2+x^2+p (-1+x^2))))))/(e^2 p^2 (-4 a^2 (-1+e)^2 (1+e)^2 x^2 (-p^2+a^2 (-1+e^2) (-1+x^2)) (-(3+e^2) p^4+a^2 (-1+e^2)^2 p^2 (-2+x^2)+a^4 (-1+e^2)^3 (-1+x^2))
+((3+e^2-p) p^4-a^4 (-1+e^2)^2 (-1+x^2) (-1-x^2+p (-1+x^2)+e^2 (1+x^2))+2 a^2 p^2 (1+e^4+p (-1+x^2)+e^2 (-2+p (-1+x^2))))^2)));

AngularMomentum[a_?NumericQ, p_?NumericQ, (0|0.), x_?NumericQ]:= AngularMomentum[a,p,0,x]= Module[{En,g,d,h,f},

En = Energy[a,p,0,x];
g=2 a p;
d=(a^2+(-2+p) p) (p^2-a^2 (-1+x^2));
h=((-2+p) p-a^2 (-1+x^2))/x^2;
f=p^4+a^2 (p (2+p)-(a^2+(-2+p) p) (-1+x^2));
(-En g + x Sqrt[(-d h + En^2 (g^2+ f h))/x^2])/h

];

AngularMomentum[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= AngularMomentum[a,p,e,x]= Module[{En},
En = Energy[a,p,e,x];
-(((-1+e) x^2 (2 a En p-x \[Sqrt](1/((-1+e)^6 x^4) (a^2 (-1+e)^2+p (-2+2 e+p)) (-p^2+a^2 (-1+e)^2 (-1+x^2)) (p (-2+2 e+p-En^2 p)+a^2 (-1+e)^2 (-1+En^2) (-1+x^2)))
+e x \[Sqrt](1/((-1+e)^6 x^4) (a^2 (-1+e)^2+p (-2+2 e+p)) (-p^2+a^2 (-1+e)^2 (-1+x^2)) (p (-2+2 e+p-En^2 p)+a^2 (-1+e)^2 (-1+En^2) (-1+x^2)))))
/(-p (-2+2 e+p)+a^2 (-1+e)^2 (-1+x^2)))
]

CarterConstant[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= CarterConstant[a,p,e,x] = (-a^2 (-1+Energy[a,p,e,x]^2)+AngularMomentum[a,p,e,x]^2/x^2) (1-x^2);



(* ::Subsection:: *)
(*Public Functions*)


(* ::Subsubsection::Closed:: *)
(*Relativistic Gas Drag for Kerr*)


KerrGasDrag[a_, En_, L_, K_, \[Psi]r_, \[Psi]\[Theta]_] := Module[{ur,u\[Theta],u\[Phi]up,utup,ut,u\[Phi],un,uztup,uz\[Phi]up, uzt,at,ar,a\[Theta],a\[Phi], r1, r2, p, e, r, \[Beta], Q, zm, zp, z, \[CapitalSigma], \[CapitalDelta], \[Omega],F, \[Theta], P, J }, 

r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]] ;

(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)
\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalDelta] = r^2 + a^2 - 2r;
\[Omega] = Sqrt[r^2+ a^2];
F = (r^2+ a^2) En- a L;
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
u\[Phi]up =  1/\[CapitalSigma] (L/(1 - zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta] -1) - (a^2 L)/\[CapitalDelta]);
utup = 1/\[CapitalSigma] (En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L (1 - \[Omega]^2/\[CapitalDelta])); 
ut = -(1 - (2r)/\[CapitalSigma])utup -(2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] u\[Phi]up; 
u\[Phi] = -((2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma])utup + ((\[Omega]^4 -\[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] u\[Phi]up ;   
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*ZAMO Velocities*)
uztup =  Sqrt[(\[Omega]^4- \[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))/(\[CapitalSigma] \[CapitalDelta] )]; 
uz\[Phi]up = (2 a r)/Sqrt[\[CapitalSigma] \[CapitalDelta] (\[Omega]^4- \[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))];  
uzt = -(1 - (2 r)/\[CapitalSigma]) uztup  - (2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] uz\[Phi]up; 
(*Gas Drag*)

at = -(ut + uzt/(uzt utup));
ar = -(ur);
a\[Theta] = -(u\[Theta]);
a\[Phi] = -(u\[Phi]);

<|"at" -> at, "ar" -> ar, "a\[Theta]" -> a\[Theta], "a\[Phi]" ->   a\[Phi]|>
]


KerrGasDragVec[a_, En_, L_, K_, \[Psi]r_, \[Psi]\[Theta]_] := Module[{ft,fr,f\[Theta],f\[Phi],r1, r2, p, e, r, \[Beta], Q, zm, zp, z, \[CapitalSigma], \[CapitalDelta], \[Omega],F, \[Theta], P, J }, 

r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]] ;


(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)
\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalDelta] = r^2 + a^2 - 2r;
\[Omega] = Sqrt[r^2+ a^2];
F = (r^2+ a^2) En- a L;
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 


fr=(e p P (a^2+(-2+r) r) Sin[\[Psi]r])/(\[CapitalDelta] (1+e Cos[\[Psi]r])^2 (r^2+a^2 zm Cos[\[Psi]\[Theta]]^2));
f\[Theta]=(Sqrt[zm] Sqrt[(-z+zp) \[Beta]] Sin[\[Psi]\[Theta]])/(Sqrt[1-zm Cos[\[Psi]\[Theta]]^2] (r^2+a^2 zm Cos[\[Psi]\[Theta]]^2));
f\[Phi]=-((2 a En r-2 L r+L r^2+a^2 L z-2 a En r z)/((a^2-2 r+r^2) (-1+z) (r^2+a^2 z)))-(2 a r \[CapitalDelta] \[CapitalSigma])/((a^2-2 r+r^2) (r^2+a^2 z) (-a^2 En \[CapitalDelta]+a L \[CapitalDelta]+a^2 En z \[CapitalDelta]-a L \[Omega]^2+En \[Omega]^4));

<| "fr" -> fr, "f\[Theta]" -> f\[Theta], "f\[Phi]" ->   f\[Phi]|>
]


KerrGasDragapex[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_] := Module[{En,L,Q,ur,u\[Theta],u\[Phi]up,utup,ut,u\[Phi],un,uztup,uz\[Phi]up, uzt,at,ar,a\[Theta],a\[Phi], r1, r2, r, \[Beta], zm, zp, z, \[CapitalSigma], \[CapitalDelta], \[Omega],F, \[Theta], P, J }, 

r1 = p/(1 - e);
r2 = p/(1 + e) ;

{En,L,Q} = {Energy[a,p,e,x],AngularMomentum[a,p,e,x],CarterConstant[a,p,e,x]};

(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);

(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)
\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalDelta] = r^2 + a^2 - 2r;
\[Omega] = Sqrt[r^2+ a^2];
F = (r^2+ a^2) En- a L;
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
u\[Phi]up =  1/\[CapitalSigma] (L/(1 - zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta] -1) - (a^2 L)/\[CapitalDelta]);
utup = 1/\[CapitalSigma] (En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L (1 - \[Omega]^2/\[CapitalDelta])); 
ut = -(1 - (2r)/\[CapitalSigma])utup -(2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] u\[Phi]up; 
u\[Phi] = -((2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma])utup + ((\[Omega]^4 -\[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] u\[Phi]up ;   
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*ZAMO Velocities*)
uztup =  Sqrt[(\[Omega]^4- \[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))/(\[CapitalSigma] \[CapitalDelta] )]; 
uz\[Phi]up = (2 a r)/Sqrt[\[CapitalSigma] \[CapitalDelta] (\[Omega]^4- \[CapitalDelta] a^2 (1-zm Cos[\[Psi]\[Theta]]^2))];  
uzt = -(1 - (2 r)/\[CapitalSigma]) uztup  - (2 a r(1-zm Cos[\[Psi]\[Theta]]^2))/\[CapitalSigma] uz\[Phi]up; 
(*Gas Drag*)

at = -(ut + uzt/(uzt utup));
ar = -(ur);
a\[Theta] = -(u\[Theta]);
a\[Phi] = -(u\[Phi]);

<|"at" -> at, "ar" -> ar, "a\[Theta]" -> a\[Theta], "a\[Phi]" ->   a\[Phi]|>
]


(* ::Subsubsection::Closed:: *)
(*Conservative forces (Electromagnetic Force)*)


KerrEMCons[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_] :=Module[{r ,z,\[CapitalSigma],\[CapitalDelta],En,L,Q,J,P,ur,zpl,zm,u\[Theta],utup,u\[Phi]up, at, ar, a\[Theta],a\[Phi]},
(*radial coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
(*polar coordinate*)
z=Sqrt[1-x^2] Cos[\[Psi]\[Theta]];

\[CapitalSigma]=r^2+a^2z^2;
\[CapitalDelta]=r^2+a^2-2  r;

(*Constants of motion*)
{En,L,Q} = {Energy[a,p,e,x],AngularMomentum[a,p,e,x],CarterConstant[a,p,e,x]};

(*Particle's velocity*)
(*r-velocity: ur=\[CapitalDelta]^-1dr/d\[Lambda]*)
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (a^2(1-En^2) + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 
ur=p e Sin[\[Psi]r]P/(\[CapitalDelta] (1+e Cos[\[Psi]r])^2);
(*\[Theta]-velocity: u\[Theta]=d\[Theta]/d\[Lambda]*)
zpl=Sqrt[a^2(1-En^2)+L^2/x^2];(*polar root*)
zm=Sqrt[1-x^2];(*polar root*)
u\[Theta]=zm Sin[\[Psi]\[Theta]]Sqrt[(zpl^2-a^2(1-En^2)zm^2 Cos[ \[Psi]\[Theta]]^2)/(1-zm^2 Cos[ \[Psi]\[Theta]]^2)];
(*t-velocity: Ut=dt/d\[Lambda]*)
utup=(r^2+a^2)((r^2+a^2)En-a L)/\[CapitalDelta]-a(a (1-z^2)En-L);
(*\[Phi]-velocity: Uf=d\[Phi]/d\[Lambda]*)
u\[Phi]up=a ((r^2+a^2)En-a L)/\[CapitalDelta]-(a En-L/(1-z^2));

(*acceleration*)
at =  a/\[CapitalSigma]^3((1+ z^2)(r^2-a^2z^2)\[CapitalDelta] ur+2r z Sqrt[(1-z^2)](r^2-a^2)u\[Theta]);
ar = 1/\[CapitalSigma]^3( a(1+z^2)(a^2z^2-r^2)utup+u\[Phi]up(1-z^2)(r^5+2r^3a^2+r a^4+2 a^2r^2-2 a^4+a^4(r-1)(1-z^2)^2-a^2(2r a^2-3 a^2+2r^3+r^2)(1-z^2)));
a\[Theta] = 1/\[CapitalSigma]^3z Sqrt[(1-z^2)](2 a r(a^2-r^2)utup+(r^6+a^2r^4-2a^4 r+2a^2r^2\[CapitalDelta] z^2+a^4\[CapitalDelta] z^4)u\[Phi]up);
a\[Phi] = 1/\[CapitalSigma]^3((1-z^2)(r^5+2r^3a^2+r a^4+2 a^2r^2-2 a^4+a^4(r-1)(1-z^2)^2-a^2(2r a^2-3 a^2+2r^3+r^2)(1-z^2))\[CapitalDelta] ur+z Sqrt[(1-z^2)](r^6+a^2r^4-2a^4 r +2a^2r^2\[CapitalDelta] z^2+a^4\[CapitalDelta] z^4)u\[Theta]);

<|"at" -> at, "ar" -> ar, "a\[Theta]" -> a\[Theta], "a\[Phi]" ->   a\[Phi]|>
]


(* ::Subsubsection:: *)
(*Kerr Osculating Geodesics Solver*)


KerrOsculatingOrbitalElements[\[Eta]_, a_, p0_, e0_,x0_, \[Psi]r0_, \[Psi]\[Theta]0_, OptionsPattern[]] := Module[{atV, arV, a\[Theta]V, a\[Phi]V,solve,downQ,monitorQ, \[Lambda], En, L, k, \[Psi]r, \[Psi]\[Theta],t,\[Phi], En0, L0, K0, Q0, ICs, Ensol,Lsol, Ksol, Qsol, \[Psi]rsol,\[Psi]\[Theta]sol,tsol, \[Phi]sol, r1sol, r2sol, psol, esol, rsol,\[Theta]sol,\[Iota]sol,zmsol, xsol, zsol, Equations, p, e,\[Theta]inc,\[Theta]incsol, progress = 0, limit,frVal, f\[Theta]Val, f\[Phi]Val,drag,dragFn,dragArgs,dragVal, r1, r2, r, \[Beta], Q,C, zm, zp, z, \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2, \[Omega], F, F1, F2, H, \[Theta], \[Kappa]1, \[Kappa]2, Q1, Q2, \[ScriptCapitalD], \[Epsilon], J, P, G, ur, u\[Theta], un, an, A1, A2, A3, dtd\[Lambda], d\[Phi]d\[Lambda], minoQ, RHSE, RHSL, RHSK, RHSpsir, RHSpsi\[Theta], RHS\[Phi], Eqns, s, unknowns, sol, rules, K, tt},
(*Load in Kerr Geodesics Package*)
Needs["KerrGeodesics`"];
(*Determine that Initial Conditions are stable*)
If[KerrGeoOrbitType[a,p0,e0,x0][[1]]=="Bound",



(*Determine the Initial Conditions*)

{En0, L0, Q0} = Values[KerrGeoConstantsOfMotion[a, p0, e0, x0]];
K0 = Q0 + (L0 - a En0)^2 ;

ICs = {
  En[0]  == En0,
  L[0]   == L0,
  k[0]   == K0,
  \[Psi]r[0]  == \[Psi]r0,
  \[Psi]\[Theta][0]  == \[Psi]\[Theta]0,
  \[Phi][0]   == 0,
  If[MatchQ[OptionValue["Parametrisation"] , "Mino"], t[0] == 0, Nothing]
};




r1 = Max[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];
r2 = Min[Re[Root1[a, En, L, K]],Re[Root2[a, En, L, K]]];


(*p and e*)
e = (r1 - r2)/(r1 + r2); 
p = (2 r1 r2)/(r1 + r2);
(*r coordinate*)
r = p/(1 + e Cos[\[Psi]r]) ;
\[Beta]= a^2 (1 - En^2);
Q = K - (L - a En)^2;
(*Polar Roots*)
zm = 1/(2\[Beta]) ((L^2+ Q + \[Beta]) - Sqrt[(L^2 + Q + \[Beta])^2 - 4\[Beta] Q ] ); 
zp = 1/(2\[Beta]) ((L^2+ Q + \[Beta])+ Sqrt[(L^2+ Q + \[Beta])^2 - 4\[Beta] Q] );
z = zm Cos[\[Psi]\[Theta]]^2;

(*Useful Shorthand*)

\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta]]^2;

\[CapitalDelta] = r^2 + a^2 - 2r;
\[CapitalDelta]1 = r1^2 + a^2 - 2r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2r2;

\[Omega] = Sqrt[r^2+ a^2];

F = (r^2+ a^2) En- a L;
F1 = (r1^2+ a^2) En- a L;
F2 = (r2^2+ a^2) En- a L;

H = L - a En (1- zm (*Cos[\[Psi]\[Theta]]^2*)); (* Fixed typo found by Lisa Drummond *)
\[Theta] = ArcCos[Sqrt[zm]Cos[\[Psi]\[Theta]]];

\[Kappa]1 = 4En F1 r1 - 2 r1 \[CapitalDelta]1 - 2(r1-1)(r1^2 + K);
\[Kappa]2 = 4En F2 r2 - 2 r2 \[CapitalDelta]2 - 2(r2-1)(r2^2 + K);

Q1 = - 2 a L r r1 - a^4 En(r+r1) + a^3 L(r+r1) - a^2 En(r^3 + r^2 r1 + r1^3 + r r1(-2 + r1)) - En r r1 ( r r1 (r + r1) - 2(r^2 + r r1 + r1^2)) - a^2 (2a^2 En - 2En r r1 + a L(-2 + r + r1)) zm Cos[\[Psi]\[Theta]]^2;

Q2 = - 2 a L r r2 - a^4 En(r+r2) + a^3 L(r+r2) - a^2 En(r^3 + r^2 r2 + r2^3 + r r2(-2 + r2)) - En r r2 ( r r2 (r + r2) - 2(r^2 + r r2+ r2^2)) - a^2 (2a^2 En - 2En r r2 + a L(-2 + r + r2)) zm Cos[\[Psi]\[Theta]]^2;
C = (Q1 (1- e))/\[Kappa]1 - (Q2 (1+ e))/\[Kappa]2; 

\[ScriptCapitalD] = (1-e)^2 (1 - Cos[\[Psi]r]) \[CapitalDelta]1/\[Kappa]1 + (1+e)^2 (1 + Cos[\[Psi]r]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e)(r+r1))/\[Kappa]1 - (F2 (1+ e) (r + r2))/\[Kappa]2;  
J = (1-En^2)(1-e^2) + 2(1 - En^2-(1-e^2)/p)(1 + e Cos[\[Psi]r]) + ((1 - En^2) (3+ e^2)/(1 - e^2) - 4/p+ (\[Beta] + L^2 +Q) (1-e^2)/p^2)(1+e Cos[\[Psi]r])^2;
P = (p Sqrt[J])/(1 - e^2); 
G =  (\[Omega]^2 L)/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p e Sin[\[Psi]r] P)/(\[CapitalDelta] (1+ e Cos[\[Psi]r])^2); 
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta](zp - z)];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

(*Convert from BL to Null Tetrad Componets*)

an =  (f\[Phi]Val (a^2+(-2+r) r) \[Eta] (2 L+a En (-2+zm)+a En zm Cos[2 \[Psi]\[Theta]]))/(4 En \[CapitalSigma])+(frVal \[CapitalDelta] \[Eta])/(2 (a^2-2 r+r^2)  )-(e frVal Sqrt[J] r^2 \[Eta] Sin[\[Psi]r])/(2 (-1+e) (1+e) En \[CapitalSigma])+(f\[Theta]Val (a^2+(-2+r) r) Sqrt[zm] \[Eta] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/(2 En \[CapitalSigma] Sqrt[1-zm Cos[\[Psi]\[Theta]]^2]);


A1 = \[Eta] (-(p^2/(1+e Cos[\[Psi]r])^2)-a^2 zm Cos[\[Psi]\[Theta]]^2) f\[Theta]Val;
A2 = (f\[Phi]Val (a^2 En-a L+En r^2) \[Eta] Sqrt[2-zm-zm Cos[2 \[Psi]\[Theta]]])/(Sqrt[2] En)+(a e frVal Sqrt[J] r^2 Sqrt[1-z] \[Eta] Sin[\[Psi]r])/((-1+e^2) En (a^2+(-2+r) r))-(a f\[Theta]Val Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] \[Eta] Sin[\[Psi]\[Theta]])/En ;
A3 = -((f\[Phi]Val (a^2 En-a L+En r^2) (L+a En (-1+z)) \[Eta])/(En \[CapitalSigma]))-(a e frVal Sqrt[J] r^2 (L+a En (-1+z)) \[Eta] Sin[\[Psi]r])/((-1+e^2) En (a^2+(-2+r) r) \[CapitalSigma])+(f\[Theta]Val \[Eta] (-u\[Theta] (r^2+a^2 z)+(a (L+a En (-1+z)) Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] Sin[\[Psi]\[Theta]])/(En Sqrt[1-z])))/\[CapitalSigma];  

(*ft[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]=1/En (f\[Phi][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] L-(e fr[a, En, L, K, \[Psi]r, \[Psi]\[Theta]] p^2 \[Sqrt]((-1+e^2) (-1+En^2)+(2 (-1+e^2+p-En^2 p) (1+e Cos[\[Psi]r]))/p+(((3+e^2) (-1+En^2))/(-1+e^2)+((1-e^2) (a^2 (1-2 En^2)+K+2 a En L))/p^2-4/p) (1+e Cos[\[Psi]r])^2) Sin[\[Psi]r])/((-1+e^2) (a^2+(-2+p) p+2 e (a^2-p) Cos[\[Psi]r]+a^2 e^2 Cos[\[Psi]r]^2))+(f\[Theta][a, En, L, K, \[Psi]r, \[Psi]\[Theta]] Sqrt[zm] Sqrt[a^2 (-1+En^2) (-zp+zm Cos[\[Psi]\[Theta]]^2)] Sin[\[Psi]\[Theta]])/Sqrt[1-zm Cos[\[Psi]\[Theta]]^2])*);

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];
(*Osculating Geodesic Equations*)

minoQ = MatchQ[OptionValue["Parametrisation"], "Mino"];
(*Using simpler equations for the evolution of E, L and K*)

(* Assign the force components *)
Switch[{OptionValue["ForceUpDown"], OptionValue["Force"]},

  {"Down", {_, _, _, _}},
    {atV, arV, a\[Theta]V, a\[Phi]V} = Through[OptionValue["Force"][a, En, L, K, \[Psi]r, \[Psi]\[Theta]]];
    downQ = True;,

  {"Down", KerrGasDrag},
    drag = KerrGasDrag[a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
    {atV, arV, a\[Theta]V, a\[Phi]V} = {drag["at"], drag["ar"], drag["a\[Theta]"], drag["a\[Phi]"]};
    downQ = True;,

  {"Up", {_, _, _}},
    {frVal, f\[Theta]Val, f\[Phi]Val} = Through[OptionValue["Force"][a, En, L, K, \[Psi]r, \[Psi]\[Theta]]];
    downQ = False;,

  {"Up", KerrGasDragVec},
    drag = KerrGasDragVec[a, En, L, K, \[Psi]r, \[Psi]\[Theta]];
    {frVal, f\[Theta]Val, f\[Phi]Val} = {drag["fr"], drag["f\[Theta]"], drag["f\[Phi]"]};
    downQ = False;,

  _,
    Message[KerrOsculatingOrbitalElements::InvalidForce, OptionValue["Force"]];
    Return[$Failed]];

(* --- 2. Down -> Up:  f^mu = -g^{mu nu} a_nu --- *)
If[downQ,
  frVal = -(\[CapitalDelta]/\[CapitalSigma]) arV;
  f\[Theta]Val = -a\[Theta]V/\[CapitalSigma];
  f\[Phi]Val = (2 a r atV)/(\[CapitalSigma] \[CapitalDelta]) - ((\[CapitalDelta] - a^2 (1 - z))/(\[CapitalSigma] \[CapitalDelta] (1 - z))) a\[Phi]V];
			



(*Using simpler equations for the evolution of E, L and K*)

{RHSE, RHSL, RHSK, RHSpsir, RHSpsi\[Theta], RHS\[Phi]} =({
  If[minoQ, 1, 1/dtd\[Lambda] ]  (-((f\[Phi]Val (L (-2+r) r-2 a En r (-1+z)+a^2 L z) \[Eta])/(En))+(e frVal Sqrt[J] r^2 (-2 r+\[CapitalSigma]) \[Eta] Sin[\[Psi]r])/((-1+e^2) En \[CapitalDelta])-(f\[Theta]Val (-2 r+\[CapitalSigma]) Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] \[Eta] Sin[\[Psi]\[Theta]])/(En Sqrt[1-z])),
If[minoQ, 1, 1/dtd\[Lambda] ]((f\[Phi]Val \[CapitalDelta]  dtd\[Lambda] (-1+z) \[Eta])/En+(2 a e frVal Sqrt[J] r^3 (-1+z) \[Eta] Sin[\[Psi]r])/( (-1+e^2) En \[CapitalDelta])+(2 a f\[Theta]Val r Sqrt[1-z] Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] \[Eta] Sin[\[Psi]\[Theta]])/( En)),    
 If[minoQ, 1, 1/dtd\[Lambda] ](-((2 f\[Phi]Val F (L+a En (-1+z)) \[CapitalSigma] \[Eta])/( En))+(frVal \[CapitalSigma] \[Eta] ((-1+e^2) En \[CapitalDelta] ur (r^2+2 a^2 z)+e Sqrt[J] r^2 (2 F - En r^2) Sin[\[Psi]r]))/( (-1+e^2) En \[CapitalDelta])-(f\[Theta]Val \[CapitalSigma] \[Eta] (En r^2 u\[Theta] Sqrt[1-z]+(2 F - En r^2) Sqrt[zm] Sqrt[a^2 (-1+En^2) (z-zp)] Sin[\[Psi]\[Theta]]))/( En Sqrt[1-z])),  
 If[minoQ, 1, 1/dtd\[Lambda] ]  (P  +(C A3 Sin[\[Psi]r])/(2(1 + e Cos[\[Psi]r]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e Cos[\[Psi]r])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r] A2)/(1 + e Cos[\[Psi]r])  +  (P an)/(un ( 1 + e Cos[\[Psi]r])^2) ((1-e)^2 (1 - Cos[\[Psi]r]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e)^2 (1+Cos[\[Psi]r]) (\[CapitalSigma]2 F2)/\[Kappa]2)),
 If[minoQ, 1, 1/dtd\[Lambda] ] (Sqrt[\[Beta](zp - z)]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta]])/(\[Beta] Sqrt[zm](zp - zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(zp - zm) \[Beta] un) + (Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] G A2 )/(\[Beta](zp - zm))),
 If[minoQ, 1, 1/dtd\[Lambda] ] (L/(1-zm Cos[\[Psi]\[Theta]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta] )
}/.{En-> En[s], L->L[s],K->k[s],\[Psi]r->\[Psi]r[s],\[Psi]\[Theta]->\[Psi]\[Theta][s],\[Phi]->\[Phi][s]});

Eqns = {
D[En[s] , s]== RHSE,
D[L[s], s] == RHSL,    
D[k[s], s] == RHSK,  
D[\[Psi]r[s], s] == RHSpsir ,
D[\[Psi]\[Theta][s], s] == RHSpsi\[Theta],
D[\[Phi][s], s] == RHS\[Phi],
If[minoQ, D[t[s], s] == dtd\[Lambda] /. {En -> En[s], L -> L[s], K -> k[s],
                                    \[Psi]r -> \[Psi]r[s], \[Psi]\[Theta] -> \[Psi]\[Theta][s]}, Nothing]
};
  
			
		

s = If[minoQ, \[Lambda], t];
unknowns = {En, L, k, \[Psi]r, \[Psi]\[Theta], \[Phi], If[minoQ, t, Nothing]};





Print["Starting NDSolve..."];
limit = OptionValue["IntegrationLimit"]  If[minoQ, 1, 10^3];

(* Solve the Evolution Equations *)
monitorQ = MatchQ[OptionValue["TimeMonitor"], "True"|True];
solve[] := NDSolve[
  Evaluate@Join[
    ICs,
    Eqns,
    {
      WhenEvent[
        Evaluate[
          SeparatrixEqELK[a, En[s], L[s], k[s]] == -10^-6
        ],
        Print["Separatrix reached."];
        "StopIntegration"
      ]
    }
  ],
  unknowns,
  {s, 0, limit},

  AccuracyGoal -> OptionValue["AccuracyGoal"],
  PrecisionGoal -> OptionValue["PrecisionGoal"],
  Method -> {"EquationSimplification" -> "Solve"},

  StepMonitor :> (progress = s)
];

sol = If[
  monitorQ, Monitor[
    solve[],
    Row[{
      If[minoQ, "\[Lambda]", "t"],
      " = ",
      progress
    }]
  ],

  solve[]
];

If[! MatchQ[sol, {{__Rule}}],
   Message[KerrOsculatingOrbitalElements::nosol]; Return[$Failed]];

rules = First[sol];
{Ensol, Lsol, Ksol, \[Psi]rsol, \[Psi]\[Theta]sol, \[Phi]sol} = {En, L, k, \[Psi]r, \[Psi]\[Theta], \[Phi]} /. rules;
If[minoQ, tsol = t /. rules, tsol[\[Tau]_?NumericQ] := \[Tau]];


(*If orbit plunges or escapes*)	
If[Ensol["Domain"][[1,2]]  == limit, Print["Limit reached."]];
	
(*Funcitons for Useful Properties of the Orbit*)

Qsol[\[Lambda]_] := Ksol[\[Lambda]] - (Lsol[\[Lambda]] - a Ensol[\[Lambda]])^2;

(*Using Numeric versions of the roots to avoid the roots flipping*)
r1sol[\[Lambda]_] := NumRoot1[a, Ensol[\[Lambda]], Lsol[\[Lambda]], Ksol[\[Lambda]]];
r2sol[\[Lambda]_] := NumRoot2[a, Ensol[\[Lambda]], Lsol[\[Lambda]], Ksol[\[Lambda]]];

psol[\[Lambda]_] := (2 r1sol[\[Lambda]] r2sol[\[Lambda]]  )/(r1sol[\[Lambda]] + r2sol[\[Lambda]]);
esol[\[Lambda]_] := (r1sol[\[Lambda]] - r2sol[\[Lambda]])/(r1sol[\[Lambda]] + r2sol[\[Lambda]]);
rsol[\[Lambda]_] := psol[\[Lambda]]/(1 + esol[\[Lambda]] Cos[\[Psi]rsol[\[Lambda]]]); 

zmsol[\[Lambda]_]:= 1/(2 a^2 (1 - Ensol[\[Lambda]]^2)) ((Lsol[\[Lambda]]^2+ Qsol[\[Lambda]] + a^2 (1 - Ensol[\[Lambda]]^2)) - Sqrt[(Lsol[\[Lambda]]^2 + Qsol[\[Lambda]] + a^2 (1 - Ensol[\[Lambda]]^2))^2 - 4 (a^2) (1 - Ensol[\[Lambda]]^2) Qsol[\[Lambda]] ] ); 
xsol[\[Lambda]_]:= Sign[Lsol[\[Lambda]]]Sqrt[1 - zmsol[\[Lambda]]];

\[Theta]sol[\[Lambda]_] :=  ArcCos[Sqrt[zmsol[\[Lambda]]]Cos[\[Psi]\[Theta]sol[\[Lambda]]]];
\[Iota]sol[\[Lambda]_] := ArcCos[Lsol[\[Lambda]]/Sqrt[Ksol[\[Lambda]] + 2 a Lsol[\[Lambda]] Ensol[\[Lambda]] - a^2 Ensol[\[Lambda]]^2]];

(*Retrun the results*)
<| "t" -> tsol, "r" -> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol, 
"En"-> Ensol, "L"-> Lsol, "K" -> Ksol, "Q" -> Qsol, 
"p"-> psol, "e"-> esol, "x" -> xsol, "\[Iota]" -> \[Iota]sol,
"\[Psi]r" -> \[Psi]rsol, "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol, 
"r1"-> r1sol, "r2" -> r2sol, "z1"-> zmsol, "limit" -> Ensol["Domain"][[1,2]]|>
 ,
Message[KerrOsculatingOrbitalElements::ICs];]
]


GenericKerrpexBL[ \[Eta]_, a_, p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, OptionsPattern[]] := Module[
  {
    initialConditions, EoM, events, unknowns, minoQ, monitorQ,
    limit, pMin, pMinQ, progress = 0, solve, sol, rules, s,
    p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, \[Lambda], 
    En, L, Q, K, r1, r2, r, \[Beta], zm, \[Beta]zp, z,
    \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2,
    \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2,
    \[Omega], \[Omega]1, \[Omega]2, F, F1, F2, H, \[Theta],
    \[Kappa]1, \[Kappa]2, Q1, Q2, C, \[ScriptCapitalD], \[Epsilon],
    J, P, G, ur, urup, u\[Theta], u\[Theta]up, un,
    at, ar, a\[Theta], a\[Phi], an, A1, A2, A3,
    dEd\[Lambda], dLd\[Lambda], dKd\[Lambda],
    dr1d\[Lambda], dr2d\[Lambda], dpd\[Lambda], ded\[Lambda],
    dzmd\[Lambda], dxd\[Lambda], dtd\[Lambda], d\[Phi]d\[Lambda],
    d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda],
    psol, esol, xsol, \[Psi]rsol, \[Psi]\[Theta]sol, tsol, \[Phi]sol,
    rsol, \[Theta]sol, Ensol, Lsol, Ksol, Qsol,
    r1sol, r2sol, zmsol, \[Iota]sol,
    \[CapitalUpsilon]tsol, \[CapitalUpsilon]rsol,
    \[CapitalUpsilon]zsol, \[CapitalUpsilon]\[Phi]sol
  },

  Needs["KerrGeodesics`"];

  minoQ = MatchQ[OptionValue["Parametrisation"], "Mino"];
  monitorQ = MatchQ[OptionValue["TimeMonitor"], True | "True"];

  initialConditions = {
    p[0] == p0,
    e[0] == e0,
    x[0] == x0,
    \[Psi]r[0] == \[Psi]r0,
    \[Psi]\[Theta][0] == \[Psi]\[Theta]0,
    \[Phi][0] == 0,
    If[minoQ, t[0] == 0, Nothing]
  };
  
  

  (* Constants of motion and radial roots. *)
  {En, L, Q} = {
    Energy[a, p[s], e[s], x[s]],
    AngularMomentum[a, p[s], e[s], x[s]],
    CarterConstant[a, p[s], e[s], x[s]]
  };

K = Q + (L - a En)^2;
r1 = p[s]/(1 - e[s]);
r2 = p[s]/(1 + e[s]);
r = p[s]/(1 + e[s] Cos[\[Psi]r[s]]);

\[Beta] = a^2 (1 - En^2);
zm = 1 - x[s]^2;
\[Beta]zp = a^2 (1 - En^2) + L^2/(1 - zm);
z = zm Cos[\[Psi]\[Theta][s]]^2;

 (* Useful shorthand. *)
\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;

\[CapitalDelta] = r^2 + a^2 - 2 r;
\[CapitalDelta]1 = r1^2 + a^2 - 2 r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2 r2;

\[Omega] = Sqrt[r^2 + a^2];
\[Omega]1 = Sqrt[r1^2 + a^2];
\[Omega]2 = Sqrt[r2^2 + a^2];

F = (r^2 + a^2) En - a L;
F1 = (r1^2 + a^2) En - a L;
F2 = (r2^2 + a^2) En - a L;

H = L - a En x[s]^2;
\[Theta] = ArcCos[Sqrt[zm] Cos[\[Psi]\[Theta][s]]];

\[Kappa]1 = 4 En F1 r1 - 2 r1 \[CapitalDelta]1 -
    2 (r1 - 1) (r1^2 + K);
\[Kappa]2 = 4 En F2 r2 - 2 r2 \[CapitalDelta]2 -
    2 (r2 - 1) (r2^2 + K);

Q1 = -2 a L r r1 - a^4 En (r + r1) + a^3 L (r + r1) -
    a^2 En (r^3 + r^2 r1 + r1^3 + r r1 (-2 + r1)) -
    En r r1 (r r1 (r + r1) - 2 (r^2 + r r1 + r1^2)) -
    a^2 (2 a^2 En - 2 En r r1 + a L (-2 + r + r1))
      zm Cos[\[Psi]\[Theta][s]]^2;

Q2 = -2 a L r r2 - a^4 En (r + r2) + a^3 L (r + r2) -
    a^2 En (r^3 + r^2 r2 + r2^3 + r r2 (-2 + r2)) -
    En r r2 (r r2 (r + r2) - 2 (r^2 + r r2 + r2^2)) -
    a^2 (2 a^2 En - 2 En r r2 + a L (-2 + r + r2))
      zm Cos[\[Psi]\[Theta][s]]^2;

C = Q1 (1 - e[s])/\[Kappa]1 - Q2 (1 + e[s])/\[Kappa]2;

\[ScriptCapitalD] =(1 - e[s])^2 (1 - Cos[\[Psi]r[s]]) \[CapitalDelta]1/\[Kappa]1 +(1 + e[s])^2 (1 + Cos[\[Psi]r[s]]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e[s])(r+r1))/\[Kappa]1 - (F2 (1+ e[s]) (r + r2))/\[Kappa]2; 

J = (1-En^2)(1-e[s]^2) + 2(1 - En^2-(1-e[s]^2)/p[s])(1 + e[s] Cos[\[Psi]r[s]]) + ((1 - En^2) (3+ e[s]^2)/(1 - e[s]^2) - 4/p[s]+ (\[Beta] + L^2 +Q) (1-e[s]^2)/p[s]^2)(1+e[s] Cos[\[Psi]r[s]])^2;

P = p[s] Sqrt[J]/(1 - e[s]^2);
G = \[Omega]^2 L/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p[s] e[s] Sin[\[Psi]r[s]] P)/(\[CapitalDelta] (1+ e[s] Cos[\[Psi]r[s]])^2); 
urup = \[CapitalDelta]/\[CapitalSigma] ur;
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta][s]])/Sin[\[Theta]] Sqrt[\[Beta]zp - \[Beta] z];
u\[Theta]up = u\[Theta]/\[CapitalSigma];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 


(* Assign the force components *)
Switch[{OptionValue["Force"]},

  {{_, _, _, _}},
    {at, ar, a\[Theta], a\[Phi]} = \[Eta] Through[OptionValue["Force"][a, p[s], e[s], x[s], \[Psi]r[s], \[Psi]\[Theta][s]]];,

  {KerrGasDrag},
   {at, ar, a\[Theta], a\[Phi]} = \[Eta] Values[
    KerrGasDragapex[
      a, p[s], e[s], x[s], \[Psi]r[s], \[Psi]\[Theta][s]
    ]];
    ,_,
    Message[KerrOsculatingOrbitalElements::InvalidForce, OptionValue["Force"]];
    Return[$Failed]];








(*Orbital Element Evolution*)
dEd\[Lambda] = -\[CapitalSigma] at;
dLd\[Lambda] = \[CapitalSigma] a\[Phi]; 
dKd\[Lambda] = (2\[CapitalSigma])/\[CapitalDelta] (-at(\[Omega]^4 En - a \[Omega]^2 L) + a\[Phi] (a^2 L -a \[Omega]^2 En) - \[CapitalDelta]^2 ur ar);  

dr1d\[Lambda] = -2 F1/\[Kappa]1 (\[Omega]1^2 dEd\[Lambda] - a dLd\[Lambda]) + \[CapitalDelta]1/\[Kappa]1 dKd\[Lambda];  
dr2d\[Lambda] = -2 F2/\[Kappa]2 (\[Omega]2^2 dEd\[Lambda] - a dLd\[Lambda]) + \[CapitalDelta]2/\[Kappa]2 dKd\[Lambda];  

dpd\[Lambda] = (2 r2^2)/(r1+r2)^2 dr1d\[Lambda] + (2 r1^2)/(r1+r2)^2 dr2d\[Lambda];
ded\[Lambda] = (2 r2)/(r1+r2)^2 dr1d\[Lambda] -(2 r1)/(r1+r2)^2 dr2d\[Lambda];


(*Convert from BL to Null Tetrad Componets*)

an = \[Omega]^2/(2\[CapitalSigma])  at - \[CapitalDelta]/(2\[CapitalSigma]) ar + a/(2\[CapitalSigma]) a\[Phi];

A1 = a\[Theta];
A2 = -a Sin[\[Theta]] at - 1/Sin[\[Theta]] a\[Phi];
A3 = (a(L - a En Sin[\[Theta]]^2))/\[CapitalSigma]  at + u\[Theta]/\[CapitalSigma] a\[Theta] + (L - a En Sin[\[Theta]]^2)/(\[CapitalSigma] Sin[\[Theta]]^2) a\[Phi] ; 

d\[Psi]rd\[Lambda] = P  +(C A3 Sin[\[Psi]r[s]])/(2(1 + e[s] Cos[\[Psi]r[s]]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e[s] Cos[\[Psi]r[s]])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r[s]] A2)/(1 + e[s] Cos[\[Psi]r[s]])  +  (P an)/(un ( 1 + e[s] Cos[\[Psi]r[s]])^2) ((1-e[s])^2 (1 - Cos[\[Psi]r[s]]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e[s])^2 (1+Cos[\[Psi]r[s]]) (\[CapitalSigma]2 F2)/\[Kappa]2);

d\[Psi]\[Theta]d\[Lambda] = Sqrt[\[Beta]zp - \[Beta] z]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta][s]])/(Sqrt[zm](\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(\[Beta]zp -\[Beta] zm)  un) + (Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] G A2 )/((\[Beta]zp - \[Beta] zm));

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta][s]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta][s]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];

dzmd\[Lambda] = 1/(\[Beta]zp - \[Beta] zm) ((1-zm)dKd\[Lambda] - 2(L - a(1-zm)En)(dLd\[Lambda] - a (1-zm)dEd\[Lambda]));  
dxd\[Lambda] = -(1/(2x[s]))dzmd\[Lambda];

  (* The first six equations use the selected parametrisation. *)
  EoM = {
    D[p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dpd\[Lambda],
    D[e[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] ded\[Lambda],
    D[x[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dxd\[Lambda],
    D[\[Psi]r[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Psi]rd\[Lambda],
    D[\[Psi]\[Theta][s], s] ==
      If[minoQ, 1, 1/dtd\[Lambda]] d\[Psi]\[Theta]d\[Lambda],
    D[\[Phi][s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Phi]d\[Lambda],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  };

  s = If[minoQ, \[Lambda], t];
  unknowns = {
    p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi],
    If[minoQ, t, Nothing]
  };

  limit = OptionValue["IntegrationLimit"] If[minoQ, 1, 10^3];
  pMin = OptionValue["pMin"];
  pMinQ = NumericQ[pMin];

  events = With[{u = s},
    {
      If[
        pMinQ,
        WhenEvent[
          p[u] - pMin == 0,
          Print["pMin reached."];
          "StopIntegration"
        ],
        Nothing
      ],
      WhenEvent[
  Evaluate[
    SeparatrixEqELK[a, En, L, K] == -10^-6
  ],
  Print["Separatrix reached."];
  "StopIntegration"
]
    }
  ];

  Print["Starting NDSolve..."];

  solve[] := NDSolve[
    Evaluate@Join[initialConditions, EoM, events],
    unknowns,
    {s, 0, limit},
    AccuracyGoal -> OptionValue["AccuracyGoal"],
    PrecisionGoal -> OptionValue["PrecisionGoal"],
    Method -> {"EquationSimplification" -> "Solve"},
    StepMonitor :> (progress = s)
  ];

  sol = If[
    monitorQ,
    Monitor[
      solve[],
      Row[{If[minoQ, "\[Lambda]", "t"], " = ", progress}]
    ],
    solve[]
  ];

  If[
    ! MatchQ[sol, {{__Rule}}],
    Message[GenericKerrpexBL::nosol];
    Return[$Failed]
  ];

  rules = First[sol];
  {psol, esol, xsol, \[Psi]rsol, \[Psi]\[Theta]sol, \[Phi]sol} =
    {p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi]} /. rules;

  If[
    minoQ,
    tsol = t /. rules,
    tsol[\[Tau]_?NumericQ] := \[Tau]
  ];

  If[psol["Domain"][[1, 2]] == limit, Print["Limit reached."]];

  (* Derived quantities. *)
  zmsol[u_] := 1 - xsol[u]^2;
  rsol[u_] := psol[u]/(1 + esol[u] Cos[\[Psi]rsol[u]]);
  \[Theta]sol[u_] := ArcCos[Sqrt[zmsol[u]] Cos[\[Psi]\[Theta]sol[u]]];

  Ensol[u_] := Energy[a, psol[u], esol[u], xsol[u]];
  Lsol[u_] := AngularMomentum[a, psol[u], esol[u], xsol[u]];
  Qsol[u_] := CarterConstant[a, psol[u], esol[u], xsol[u]];
  Ksol[u_] := Qsol[u] + (Lsol[u] - a Ensol[u])^2;

  r1sol[u_] := psol[u]/(1 - esol[u]);
  r2sol[u_] := psol[u]/(1 + esol[u]);
  \[Iota]sol[u_] := ArcCos[
    Lsol[u]/Sqrt[
      Ksol[u] + 2 a Lsol[u] Ensol[u] - a^2 Ensol[u]^2
    ]
  ];

  
  <|
    "t" -> tsol,
    "r" -> rsol,
    "\[Theta]" -> \[Theta]sol,
    "\[Phi]" -> \[Phi]sol,
    "En" -> Ensol,
    "L" -> Lsol,
    "K" -> Ksol,
    "Q" -> Qsol,
    "p" -> psol,
    "e" -> esol,
    "x" -> xsol,
    "\[Iota]" -> \[Iota]sol,
    "\[Psi]r" -> \[Psi]rsol,
    "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol,
    "r1" -> r1sol,
    "r2" -> r2sol,
    "z1" -> zmsol,
    "limit" -> psol["Domain"][[1, 2]]
  |>
]


(* ::Subsection:: *)
(*End Package*)


(* ::Input::Initialization:: *)
End[]
EndPackage[]


(* ::Subsection:: *)
(*References*)
