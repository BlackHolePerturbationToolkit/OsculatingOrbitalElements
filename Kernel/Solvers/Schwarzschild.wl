(* ::Package:: *)

(* ::Title:: *)
(*Schwarzschild solvers*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Subsection::Closed:: *)
(*Private Functions*)


(* ::Subsubsection::Closed:: *)
(*Orbital Evolution: Version 1 *)


(* ::Text:: *)
(*This seems to be the fastest version of the Osculating Geodesics Equations which can be found in Warburton et al [1].  Equations are kept in terms of p,e, and \[Xi]. *)
(*However, this method is undefined when e = 0, and so the equation for \[Xi]' diverges for small values of e. *)


(* ::Input::Initialization:: *)
SchwarzOscGeoEqs1[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M =1, \[Mu], f0,f1,f2,f3,\[Beta], evolutionEqns,initialConditions, psol,esol,\[Xi]sol,tsol, \[Phi]sol, p,e,\[Xi],t,\[Phi],\[Chi], rsol, \[Theta]sol, progress = 0, stopReason = None}, 
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
{{psol,esol,\[Xi]sol,tsol, \[Phi]sol}}= Monitor[{p,e,\[Xi],t,\[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2e[\[Chi]] -0.001 == 0, stopReason = "Separatrix"; "StopIntegration"]}, {p,e,\[Xi],t,\[Phi]},{\[Chi],0, IntegrationLimit}, AccuracyGoal->Accuracy,PrecisionGoal->Precision, StepMonitor :> (progress = \[Chi])],  "\[Chi] = "<> ToString[progress]]//Quiet;

(*Report why the integration stopped*)
StopMessage[SchwarzOsculatingOrbitalElements, "\[Chi]", psol["Domain"][[1,2]], IntegrationLimit, stopReason];

(*Return associations for p, e, \[Xi], t and \[Phi] as functions of \[Chi]*)
rsol[\[Chi]_] := (M psol[\[Chi]])/(1+esol[\[Chi]] Cos[\[Xi]sol[\[Chi]]]);
\[Theta]sol[\[Chi]_]:= \[Pi]/2;
<|"t"-> tsol, "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol, "limit" -> psol["Domain"][[1,2]] |>
]


(* ::Input::Initialization:: *)
SchwarzOscGeoEqsTP[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M =1, \[Mu], f0,f1,f2,f3,\[Beta], evolutionEqns,initialConditions, psol,esol,\[Xi]sol,tsol, \[Phi]sol, p,e,\[Xi],t,\[Phi],\[Chi], rsol, \[Theta]sol, progress = 0, stopReason = None}, 
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
{{psol,esol,\[Xi]sol, \[Phi]sol}}= Monitor[{p,e,\[Xi],\[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[t]-6-2e[t] -0.001 == 0, stopReason = "Separatrix"; "StopIntegration"]}, {p,e,\[Xi],\[Phi]},{t,0, IntegrationLimit}, AccuracyGoal->Accuracy,PrecisionGoal->Precision, StepMonitor :> (progress = t)],  "t = "<> ToString[progress]]//Quiet;

(*Report why the integration stopped*)
StopMessage[SchwarzOsculatingOrbitalElements, "t", psol["Domain"][[1,2]], IntegrationLimit, stopReason];

(*Return associations for p, e, \[Xi] and \[Phi] as functions of t*)
rsol[t_] := (M psol[t])/(1+esol[t] Cos[\[Xi]sol[t]]);
\[Theta]sol[t_]:= \[Pi]/2;
<| "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol, "limit" -> psol["Domain"][[1,2]] |>
]


(* ::Subsubsection::Closed:: *)
(*Orbital Evolution: Version 2*)


(* ::Text:: *)
(*The equations are recast to be in terms of p, \[Alpha], \[Beta], which was formulated by Pound and Poisson [2]. This isn't as fast as version 1, but it is well defined for small values of e. *)


(* ::Input::Initialization:: *)
SchwarzOscGeoEqs2[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M=1, \[Mu], evolutionEqns,initialConditions, \[CapitalPsi],\[CapitalOmega],\[Alpha]0,\[Beta]0,psol, \[Alpha]sol, \[Beta]sol, esol, \[Xi]sol, \[Phi]sol, tsol, rsol, \[Theta]sol,p,e,\[Xi],\[Alpha],\[Beta],t,\[Phi],\[Chi], progress = 0, stopReason = None},

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
{{psol,\[Alpha]sol,\[Beta]sol,tsol,\[Phi]sol}}= Monitor[{p,\[Alpha],\[Beta],t, \[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2)^(1/2) -0.001 == 0, stopReason = "Separatrix"; "StopIntegration"]}, {p,\[Alpha],\[Beta],t,\[Phi]},{\[Chi],0,IntegrationLimit},AccuracyGoal->Accuracy,PrecisionGoal->Precision, Method->{"EquationSimplification"->"Solve"},StepMonitor :> (progress = \[Chi])],  "\[Chi] = "<> ToString[progress]]//Quiet;

(*Report why the integration stopped*)
StopMessage[SchwarzOsculatingOrbitalElements, "\[Chi]", psol["Domain"][[1,2]], IntegrationLimit, stopReason];

rsol[\[Chi]_] := (M psol[\[Chi]] )/(1+ \[Alpha]sol[\[Chi]] Sin[\[Chi]]+ \[Beta]sol[\[Chi]]Cos[\[Chi]] ); 
esol[\[Chi]_] := (\[Alpha]sol[\[Chi]]^2 + \[Beta]sol[\[Chi]]^2)^(1/2);
\[Xi]sol[\[Chi]_] := \[Chi]- ArcTan[\[Beta]sol[\[Chi]],\[Alpha]sol[\[Chi]]];
\[Theta]sol[\[Chi]_] := \[Pi]/2;

(*Return associations for the varibales as functions of \[Chi]*)
<| "t"-> tsol, "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol , "limit" -> tsol["Domain"][[1,2]]|>
]


(* ::Text:: *)
(*Coordinate time version of Version 2. The Darwin parameter \[Chi] is evolved alongside p, \[Alpha], and \[Beta], and each equation is divided by dt/d\[Chi].*)


(* ::Input::Initialization:: *)
SchwarzOscGeoEqs2TP[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M=1, \[Mu], evolutionEqns,initialConditions, \[CapitalPsi],\[CapitalOmega],dtd\[Chi],\[Alpha]0,\[Beta]0,psol, \[Alpha]sol, \[Beta]sol, \[Chi]sol, esol, \[Xi]sol, \[Phi]sol, rsol, \[Theta]sol,p,e,\[Xi],\[Alpha],\[Beta],t,\[Phi],\[Chi], progress = 0, stopReason = None},

\[Mu] = \[Eta] M;
(*Recast our initial conditions*)
\[Alpha]0 = e0 Sin[-\[Xi]0];
\[Beta]0 = e0 Cos[-\[Xi]0];

(*Define useful quantities, which will convert r,e,w, and v into expressions for \[Alpha] and \[Beta]*)
\[CapitalPsi][t_] := \[Alpha][t] Sin[\[Chi][t]];
\[CapitalOmega][t_] := \[Beta][t]Cos[\[Chi][t]];
e[t_] := (\[Alpha][t]^2 + \[Beta][t]^2)^(1/2);
\[Xi][t_] := \[Chi][t]- ArcTan[\[Beta][t],\[Alpha][t]];
dtd\[Chi][t_] := (p[t]^2 M Sqrt[(p[t]-2)^2-4(\[Alpha][t]^2+\[Beta][t]^2)])/((p[t]-2-2(\[CapitalPsi][t]+\[CapitalOmega][t]))Sqrt[p[t]-6-2(\[CapitalPsi][t]+\[CapitalOmega][t])] (1+\[CapitalPsi][t]+\[CapitalOmega][t])^2);

(*Define the initial Conditions*)
initialConditions = { p[0] == p0, \[Alpha][0] ==\[Alpha]0 ,  \[Beta][0] == \[Beta]0, \[Chi][0] == 0, \[Phi][0] ==0};

(*Define the evolution equations*)

evolutionEqns = {p'[t] == 1/dtd\[Chi][t] (\[Eta] (2p[t]^(7/2) M Sqrt[p[t]-6-2(\[CapitalPsi][t]+\[CapitalOmega][t])](p[t]-3-\[Alpha][t]^2-\[Beta][t]^2)(p[t]-3-(\[CapitalPsi][t]+\[CapitalOmega][t])^2)  F\[Phi][p[t], e[t], \[Xi][t]])/(((p[t]-6)^2-4(\[Alpha][t]^2+\[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^4) - \[Eta] (2p[t]^3 M(p[t]-3-\[Alpha][t]^2-\[Beta][t]^2)(\[Beta][t] Sin[\[Chi][t]] - \[Alpha][t] Cos[\[Chi][t]]) Fr[p[t], e[t], \[Xi][t]])/(((p[t]-6)^2-4(\[Alpha][t]^2+\[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^2)),

\[Alpha]'[t] == 1/dtd\[Chi][t] (\[Eta]((p[t]^(5/2) M (p[t]-3-\[Alpha][t]^2-\[Beta][t]^2) F\[Phi][p[t], e[t], \[Xi][t]])/(Sqrt[p[t]-6-2(\[CapitalPsi][t] + \[CapitalOmega][t])]((p[t]-6)^2-4(\[Alpha][t]^2+\[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^4) (4\[Beta][t](\[Alpha][t] \[Beta][t] Cos[2\[Chi][t]] + 1/2 (\[Alpha][t]^2-\[Beta][t]^2)Sin[2\[Chi][t]])+(2(p[t]-3)+(p[t]-6)(\[CapitalPsi][t]+\[CapitalOmega][t])-2(\[CapitalPsi][t]+\[CapitalOmega][t])^2)((p[t]-6)Sin[\[Chi][t]] - 2\[Alpha][t](\[CapitalPsi][t]+\[CapitalOmega][t])) + \[Alpha][t](p[t]^2-10p[t] +12 + 4(\[Alpha][t]^2+ \[Beta][t]^2)))- (p[t]^2 M(p[t]-3-\[Alpha][t]^2-\[Beta][t]^2)((p[t]-6-2\[Alpha][t]^2)Cos[\[Chi][t]]+2\[Beta][t](1+\[CapitalPsi][t])) Fr[p[t], e[t], \[Xi][t]] )/(((p[t]-6)^2-4(\[Alpha][t]^2+ \[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^2))),

\[Beta]'[t] == 1/dtd\[Chi][t] (\[Eta]((p[t]^(5/2) M (p[t]-3-\[Alpha][t]^2-\[Beta][t]^2) F\[Phi][p[t], e[t], \[Xi][t]])/(Sqrt[p[t]-6-2(\[CapitalPsi][t] + \[CapitalOmega][t])]((p[t]-6)^2-4(\[Alpha][t]^2+\[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^4) (-4\[Alpha][t](\[Alpha][t] \[Beta][t] Cos[2\[Chi][t]] + 1/2 (\[Alpha][t]^2-\[Beta][t]^2)Sin[2\[Chi][t]])+(2(p[t]-3)+(p[t]-6)(\[CapitalPsi][t]+\[CapitalOmega][t])-2(\[CapitalPsi][t]+\[CapitalOmega][t])^2)((p[t]-6)Cos[\[Chi][t]] - 2\[Beta][t](\[CapitalPsi][t]+\[CapitalOmega][t])) + \[Beta][t](p[t]^2-10p[t] +12 + 4(\[Alpha][t]^2+ \[Beta][t]^2))) +(p[t]^2 M(p[t]-3-\[Alpha][t]^2-\[Beta][t]^2)((p[t]-6-2\[Beta][t]^2)Sin[\[Chi][t]]+2\[Alpha][t](1+\[CapitalOmega][t]))Fr[p[t], e[t], \[Xi][t]])/(((p[t]-6)^2-4(\[Alpha][t]^2+ \[Beta][t]^2))(1+\[CapitalPsi][t]+\[CapitalOmega][t])^2))),
\[Chi]'[t] == 1/dtd\[Chi][t],

\[Phi]'[t] == 1/dtd\[Chi][t] Sqrt[p[t]/(p[t]-6-2(\[CapitalPsi][t]+\[CapitalOmega][t]))]};


(*Solving the evolution equations*)
{{psol,\[Alpha]sol,\[Beta]sol,\[Chi]sol,\[Phi]sol}}= Monitor[{p,\[Alpha],\[Beta],\[Chi], \[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[t]-6-2(\[Alpha][t]^2+\[Beta][t]^2)^(1/2) -0.001 == 0, stopReason = "Separatrix"; "StopIntegration"]}, {p,\[Alpha],\[Beta],\[Chi],\[Phi]},{t,0,IntegrationLimit},AccuracyGoal->Accuracy,PrecisionGoal->Precision, Method->{"EquationSimplification"->"Solve"},StepMonitor :> (progress = t)],  "t = "<> ToString[progress]]//Quiet;

(*Report why the integration stopped*)
StopMessage[SchwarzOsculatingOrbitalElements, "t", psol["Domain"][[1,2]], IntegrationLimit, stopReason];

rsol[t_] := (M psol[t] )/(1+ \[Alpha]sol[t] Sin[\[Chi]sol[t]]+ \[Beta]sol[t]Cos[\[Chi]sol[t]] ); 
esol[t_] := (\[Alpha]sol[t]^2 + \[Beta]sol[t]^2)^(1/2);
\[Xi]sol[t_] := \[Chi]sol[t]- ArcTan[\[Beta]sol[t],\[Alpha]sol[t]];
\[Theta]sol[t_] := \[Pi]/2;

(*Return associations for the varibales as functions of t*)
<| "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol,"p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol , "limit" -> psol["Domain"][[1,2]]|>
]


(* ::Subsection:: *)
(*Public Functions*)


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
		Message[SchwarzOsculatingOrbitalElements::ICs]; $Failed,
(* Go throught the different cases to assign functions to Fr and F\[Phi] *)
Switch[OptionValue["Force"],
			{_,_}, {Fr,F\[Phi]} = OptionValue["Force"];,
			SchwarzGasDrag, Fr[p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["Fr"]; F\[Phi][p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["F\[Phi]"];,
			SchwarzFastGSF, If[p0> 12.0 || e0 > 0.2,Message[SchwarzOsculatingOrbitalElements::OutOfRange];];
				Fr[p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["Fr"];
				F\[Phi][p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["F\[Phi]"];,
			_, Message[SchwarzOsculatingOrbitalElements::InvalidForce];  Return[$Failed]];

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
		Message[SchwarzOsculatingOrbitalElements::ICs]; $Failed,
(* Go throught the different cases to assign functions to Fr and F\[Phi] *)
Switch[OptionValue["Force"],
			{_,_}, {Fr,F\[Phi]} = OptionValue["Force"];,
			SchwarzGasDrag, Fr[p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["Fr"]; F\[Phi][p_,e_,\[Xi]_]:=SchwarzGasDrag[p, e, \[Xi]]["F\[Phi]"];,
			SchwarzFastGSF, If[p0> 12.0 || e0 > 0.2,Message[SchwarzOsculatingOrbitalElements::OutOfRange];];
				Fr[p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["Fr"];
				F\[Phi][p_,e_,\[Xi]_]:=SchwarzFastGSF[p, e, \[Xi]]["F\[Phi]"];,
			_, Message[SchwarzOsculatingOrbitalElements::InvalidForce];  Return[$Failed]];

(*If[flag\[Equal] error, Return[]];(*If there's an error, return Null*)*)
		(*Decide which method to use*)
		If[e0> 0.05,
			(*Faster, but bad for small e0 values*)
			SchwarzOscGeoEqsTP[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]],
			(*Slower, but works for arbitrily small values of e0*)
			SchwarzOscGeoEqs2TP[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]]
		]
	]
]


