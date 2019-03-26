(* ::Package:: *)

(* ::Title:: *)
(*Osculating Orbital Elements Package*)


(* ::Subsection:: *)
(*Begin Package*)


BeginPackage["OsculatingOrbitalElements`"]


(* ::Subsection:: *)
(*Usage Statements*)


MessageName[OsculatingOrbitalElementsEvolutionSchwarzschild, "usage"] = 
"OsculatingOrbitalElementEvolutionSchwarzschild[Fr,F\[Phi], \[Eta], p0, e0, \[Xi]0, t0, \[Phi]0] calculates {p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]],t[\[Chi]],\[Phi][\[Chi]]} using a Gravitaional Self Force given by Fr,F\[Phi] and a mass ratio given by \[Eta]."

MessageName[IntegrationLimit, "usage"] = 
"IntegrationLimit is an option for OsculatingOrbitalElementEvolutionSchwarzschild which specifies the value of \[Chi] up to which the functions for p, e, \[Xi], t, and \[Phi] will be evlauated."

MessageName[AccuracyGoal, "usage"] = "AccuracyGoal is an option for OsculatingOrbitalElementEvolutionSchwarzschild which specifies the AccuarcyGoal of NDSolve"

MessageName[PrecisionGoal, "usage"]= "PrecisionGoal is an option for OsculatingOrbitalElementEvolutionSchwarzschild which specifies the PrecisionGoal of NDSolve"

MessageName[FastGSF, "usage"]= "FastGSF[\[Eta],p,e,\[Xi]] returns Fr and F\[Phi] in terms of p, e, and \[Xi] for a mass ratio \[Eta]. 
This function is accurate to first order for p < 12 and e< 0.2"


(* ::Subsection:: *)
(*Options and Syntax Information*)


Options[OsculatingOrbitalElementEvolutionSchwarzschild] = {IntegrationLimit-> 1000000, AccuracyGoal-> Automatic, PrecisionGoal -> Automatic};


(* ::Subsection:: *)
(*Defining Private Functions*)


(* ::Input::Initialization:: *)
Begin["`Private`"]


(* ::Subsubsection:: *)
(*Orbital Evolution: Version 1 *)


(* ::Text:: *)
(*This seems to be the fastest and most accurate method. Equations are kept in terms of p,e, and \[Xi]. *)
(*However, this method is undefined when e = 0, and so the equation for \[Xi]' diverges for small values of e. *)


(* ::Input::Initialization:: *)
EvolutionV1[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,t0_,\[Phi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M =1, \[Mu], f0,f1,f2,f3,\[Beta], evolutionEqns,initialConditions, psol,esol,\[Xi]sol,tsol, \[Phi]sol, p,e,\[Xi],t,\[Phi],\[Chi], rsol, \[Theta]sol}, 
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
				p'[\[Chi]] == ((2 M p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]]))p[\[Chi]]f0[\[Chi]]f1[\[Chi]](p[\[Chi]]^(1/2) f1[\[Chi]]f2[\[Chi]](p[\[Chi]]-3-e[\[Chi]]^2 Cos[\[Xi][\[Chi]]]^2) M/\[Mu] F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] - e[\[Chi]]Sin[\[Xi][\[Chi]]] Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]/\[Mu]), 
				e'[\[Chi]] == ((M p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]]))f0[\[Chi]](p[\[Chi]]^(1/2) f2[\[Chi]](\[Beta][\[Chi]]f3[\[Chi]]Cos[\[Xi][\[Chi]]]+e[\[Chi]](p[\[Chi]]^2-10p[\[Chi]]+12+4e[\[Chi]]^2)) M/\[Mu] F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] + \[Beta][\[Chi]]f1[\[Chi]]Sin[\[Xi][\[Chi]]] Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]/\[Mu]),

				\[Xi]'[\[Chi]] == 1-((M p[\[Chi]]^2 Sqrt[(p[\[Chi]]-2)^2 -4e[\[Chi]]^2])/((p[\[Chi]]-2-2e[\[Chi]] Cos[\[Xi][\[Chi]]])(1+e[\[Chi]] Cos[\[Xi][\[Chi]]])^2 Sqrt[p[\[Chi]]-6-2e[\[Chi]]Cos[\[Xi][\[Chi]]]])) f0[\[Chi]]/e[\[Chi]] (p[\[Chi]]^(1/2) f2[\[Chi]]Sin[\[Xi][\[Chi]]]((p[\[Chi]]-6)f3[\[Chi]]-4e[\[Chi]]^3 Cos[\[Xi][\[Chi]]]) M/\[Mu] F\[Phi][p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]]- f1[\[Chi]]((p[\[Chi]]-6)Cos[\[Xi][\[Chi]]]+2e[\[Chi]]) Fr[p[\[Chi]],e[\[Chi]],\[Xi][\[Chi]]] /\[Mu]),
				\[Phi]'[\[Chi]] ==  Sqrt[p[\[Chi]]/(p[\[Chi]]-6-2e[\[Chi]] Cos[\[Xi][\[Chi]]])]};
(*Solving the Evolution Equaitons*)
{{psol,esol,\[Xi]sol,tsol, \[Phi]sol}}= {p,e,\[Xi],t,\[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2e[\[Chi]] -0.001 == 0, "StopIntegration"]}, {p,e,\[Xi],t,\[Phi]},{\[Chi],0, IntegrationLimit}, AccuracyGoal->Accuracy,PrecisionGoal->Precision];

(*Return associations for p, e, \[Xi], t and \[Phi] as functions of \[Chi]*)
rsol[\[Chi]_] := (M psol[\[Chi]])/(1-esol[\[Chi]] Cos[\[Xi]sol[\[Chi]]]);
\[Theta]sol[\[Chi]_]:= \[Pi]/2;
<|"p" -> psol, "e" -> esol, "\[Xi]" -> \[Xi]sol, "t"-> tsol,"r" -> rsol, "\[Theta]"-> \[Theta]sol, "\[Phi]"-> \[Phi]sol|>
]


(* ::Subsubsection:: *)
(*Orbital Evolution: Version 2*)


(* ::Text:: *)
(*The equations are recast to be in terms of p, \[Alpha], \[Beta]. This isn't as fast or as accurate as version 1, but it is well defined for small values of e. *)


(* ::Input::Initialization:: *)
EvolutionV2[\[Eta]_,Fr_,F\[Phi]_, p0_, e0_, \[Xi]0_,t0_,\[Phi]0_,IntegrationLimit_, Accuracy_, Precision_]:= Module[{M=1, \[Mu], evolutionEqns,initialConditions, \[CapitalPsi],\[CapitalOmega],\[Alpha]0,\[Beta]0,psol, \[Alpha]sol, \[Beta]sol, esol, \[Xi]sol, \[Phi]sol, tsol, rsol, \[Theta]sol,p,e,\[Xi],\[Alpha],\[Beta],t,\[Phi],\[Chi]},

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
initialConditions = { p[0] == p0, \[Alpha][0] ==\[Alpha]0 ,  \[Beta][0] == \[Beta]0,t[0] ==  t0, \[Phi][0] ==\[Phi]0};

(*Define the evolution equations*)
(*There's no way around it, these things are ugly*)

evolutionEqns = {p'[\[Chi]] == (2p[\[Chi]]^(7/2) M^2 Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])](p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)(p[\[Chi]]-3-(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2) \[Mu]^-1 F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) - (2p[\[Chi]]^3 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)(\[Beta][\[Chi]] Sin[\[Chi]] - \[Alpha][\[Chi]] Cos[\[Chi]]) \[Mu]^-1 Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),

\[Alpha]'[\[Chi]] == (p[\[Chi]]^(5/2) M^2 (p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2) \[Mu]^-1 F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]] + \[CapitalOmega][\[Chi]])]((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) (4\[Beta][\[Chi]](\[Alpha][\[Chi]] \[Beta][\[Chi]] Cos[2\[Chi]] + 1/2 (\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)Sin[2\[Chi]])+(2(p[\[Chi]]-3)+(p[\[Chi]]-6)(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)((p[\[Chi]]-6)Sin[\[Chi]] - 2\[Alpha][\[Chi]](\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])) + \[Alpha][\[Chi]](p[\[Chi]]^2-10p[\[Chi]] +12 + 4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2)))- (p[\[Chi]]^2 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)((p[\[Chi]]-6-2\[Alpha][\[Chi]]^2)Cos[\[Chi]]+2\[Beta][\[Chi]](1+\[CapitalPsi][\[Chi]]))\[Mu]^-1 Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]] )/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),

\[Beta]'[\[Chi]] == (p[\[Chi]]^(5/2) M^2 (p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2) \[Mu]^-1 F\[Phi][p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]] + \[CapitalOmega][\[Chi]])]((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^4) (-4\[Alpha][\[Chi]](\[Alpha][\[Chi]] \[Beta][\[Chi]] Cos[2\[Chi]] + 1/2 (\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)Sin[2\[Chi]])+(2(p[\[Chi]]-3)+(p[\[Chi]]-6)(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2)((p[\[Chi]]-6)Cos[\[Chi]] - 2\[Beta][\[Chi]](\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])) + \[Beta][\[Chi]](p[\[Chi]]^2-10p[\[Chi]] +12 + 4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))) +(p[\[Chi]]^2 M(p[\[Chi]]-3-\[Alpha][\[Chi]]^2-\[Beta][\[Chi]]^2)((p[\[Chi]]-6-2\[Beta][\[Chi]]^2)Sin[\[Chi]]+2\[Alpha][\[Chi]](1+\[CapitalOmega][\[Chi]]))\[Mu]^-1 Fr[p[\[Chi]], e[\[Chi]], \[Xi][\[Chi]]])/(((p[\[Chi]]-6)^2-4(\[Alpha][\[Chi]]^2+ \[Beta][\[Chi]]^2))(1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),
t'[\[Chi]]== (p[\[Chi]]^2 M Sqrt[(p[\[Chi]]-2)^2-4(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2)])/((p[\[Chi]]-2-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]]))Sqrt[p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])] (1+\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]])^2),

\[Phi]'[\[Chi]] ==  Sqrt[p[\[Chi]]/(p[\[Chi]]-6-2(\[CapitalPsi][\[Chi]]+\[CapitalOmega][\[Chi]]))]};


(*Solving the evolution equations*)
{{psol,\[Alpha]sol,\[Beta]sol,tsol,\[Phi]sol}}= {p,\[Alpha],\[Beta],t, \[Phi]}/.NDSolve[{Join[evolutionEqns,initialConditions],WhenEvent[p[\[Chi]]-6-2(\[Alpha][\[Chi]]^2+\[Beta][\[Chi]]^2)^(1/2) -0.001 == 0, "StopIntegration"]}, {p,\[Alpha],\[Beta],t,\[Phi]},{\[Chi],0,IntegrationLimit},AccuracyGoal->Accuracy,PrecisionGoal->Precision, Method->{"EquationSimplification"->"Residual"} ];

rsol[\[Chi]_] := (M psol[\[Chi]] )/(1+ \[Alpha]sol[\[Chi]] Sin[\[Chi]]+ \[Beta]sol[\[Chi]]Cos[\[Chi]] ); 
esol[\[Chi]_] := (\[Alpha]sol[\[Chi]]^2 + \[Beta]sol[\[Chi]]^2)^(1/2);
\[Xi]sol[\[Chi]_] := \[Chi]- ArcTan[\[Beta]sol[\[Chi]],\[Alpha]sol[\[Chi]]];
\[Theta]sol[\[Chi]_] := \[Pi]/2;

(*Return associations for the varibales as functions of \[Chi]*)
<| "p" -> psol, "e"-> esol,  "\[Xi]" -> \[Xi]sol, "t"-> tsol, "r"-> rsol, "\[Theta]" -> \[Theta]sol, "\[Phi]"-> \[Phi]sol|>
]


(* ::Subsection:: *)
(*Defining Public Functions*)


(* ::Subsubsection:: *)
(*Default Self Force Model: Fast GSF by Niels Warburton*)


(* ::Text:: *)
(*A fast to evaluate function for the Gravitational Self Force. This code was adapted from that provided by Niels Warburton. The derivation of this function is discussed in [2]*)


(* ::Input::Initialization:: *)
FastGSF[\[Eta]_,p_,e_,v_, M_:1]:= Module[{FrCons, FrDiss,F\[Phi]Cons,F\[Phi]Diss, nmax,jbar,kbar,ki, a, b, c, d, dataA,dataB,dataC,dataD}, 

(*Make sue the files are stored in the same ddirectory as the notebook*)
(*Might make this editable in futre for greater ease of use*)
SetDirectory[FileNameJoin[{$UserBaseDirectory,"Applications", "OsculatingOrbitalElements", "DataFiles"}]];

(*Loading the files*)
dataA=Import["a_n_jk","Table"];
dataB=Import["b_n_jk","Table"];
dataC=Import["c_n_jk","Table"];
dataD=Import["d_n_jk","Table"];
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
FrCons=1/p^ki[1] Sum[If[n==0,1/2,1]a[1][n][[j+1,k+1]]p^(-ki[1]-k) e^(n+2j) Cos[n v],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
FrDiss=1/p^ki[2] Sum[If[n==0,1/2,1]b[1][n][[j+1,k+1]]p^(-ki[2]-k) e^(n+2j) Sin[n v],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Cons=1/p^ki[3] Sum[If[n==0,1/2,1]c[1][n][[j+1,k+1]]p^(-ki[3]-k) e^(n+2j) Sin[n v],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Diss=1/p^ki[4] Sum[If[n==0,1/2,1]d[1][n][[j+1,k+1]]p^(-ki[4]-k) e^(n+2j) Cos[n v],{n,0,nmax},{j,0,jbar},{k,0,kbar}];

(*Retuning the componants as a 4 vector*)
<|"Fr" -> \[Eta]^2 (FrDiss + FrCons), "F\[Phi]" -> \[Eta]^2 M(F\[Phi]Cons + F\[Phi]Diss)|>]


(* ::Subsubsection:: *)
(*Osculating Orbital Element Evolution on Schwarzschild*)


(* ::Text:: *)
(*The function which controls checks the initial conditions passed in to make sure that they are valid. It then passes information to the Evolution function for calculation. *)


(* ::Text:: *)
(*First definition for if the self force is not specified.*)


(* ::Text:: *)
(*Second definition for when the self force components are specified.*)


(* ::Input::Initialization:: *)
OsculatingOrbitalElementEvolutionSchwarzschild[Fr_,F\[Phi]_,\[Eta]_, p0_, e0_, \[Xi]0_, t0_:0, \[Phi]0_:0, OptionsPattern[]]:= Module[{},
	(*Seperatrix condition for bound orbits in Schwarzschild Spacetime*)
	If[p0 < 6 + 2 e0,
		(*Error Message*)
		Print["Error: The intial conditions you have given do not satisfy the condition for a bound orbit: p >= 6 + 2 e"],
		(*Decide which method to use*)
		If[e0> 0.05,
			(*Faster, seemingly more accurate, but bad for small e0 values*)
			EvolutionV1[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,t0,\[Phi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]],
			(*Slower, less accurate, but works for arbitrily small values of e0*)
			EvolutionV2[\[Eta],Fr,F\[Phi], p0, e0, \[Xi]0,t0,\[Phi]0,OptionValue["IntegrationLimit"], OptionValue["AccuracyGoal"], OptionValue["PrecisionGoal"]]
		]
	]
]


(* ::Subsection:: *)
(*End Package*)


(* ::Input::Initialization:: *)
End[]
EndPackage[]
