(* ::Package:: *)

(* ::Title:: *)
(*Kerr solver in En, L, K (ELK)*)


(* ::Text:: *)
(*LEGACY: kept so that the earlier functions keep working; do not extend. KerrOsculatingOrbitalElements, replaced by OsculatingInspiral. An ELK option for OsculatingInspiral would start from these equations.*)


(* ::Subsubsection::Closed:: *)
(*Kerr Osculating Geodesics Solver*)


KerrOsculatingOrbitalElements[\[Eta]_, a_, p0_, e0_,x0_, \[Psi]r0_, \[Psi]\[Theta]0_, opts:OptionsPattern[{KerrOsculatingOrbitalElements, NDSolve}]] := Module[{atV, arV, a\[Theta]V, a\[Phi]V,solve,downQ,monitorQ, \[Lambda], En, L, k, \[Psi]r, \[Psi]\[Theta],t,\[Phi], En0, L0, K0, Q0, ICs, Ensol,Lsol, Ksol, Qsol, \[Psi]rsol,\[Psi]\[Theta]sol,tsol, \[Phi]sol, r1sol, r2sol, psol, esol, rsol,\[Theta]sol,\[Iota]sol,zmsol, xsol, zsol, Equations, p, e,\[Theta]inc,\[Theta]incsol, progress = 0, limit,frVal, f\[Theta]Val, f\[Phi]Val,drag,dragFn,dragArgs,dragVal, r1, r2, r, \[Beta], Q,C, zm, zp, z, \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2, \[Omega], F, F1, F2, H, \[Theta], \[Kappa]1, \[Kappa]2, Q1, Q2, \[ScriptCapitalD], \[Epsilon], J, P, G, ur, u\[Theta], un, an, A1, A2, A3, dtd\[Lambda], d\[Phi]d\[Lambda], minoQ, RHSE, RHSL, RHSK, RHSpsir, RHSpsi\[Theta], RHS\[Phi], Eqns, s, unknowns, sol, rules, K, tt, integration},
(*Load in Kerr Geodesics Package*)
Needs["KerrGeodesics`"];
minoQ = MinoParametrisationQ[OptionValue["Parametrisation"]];
If[FailureQ[minoQ], Return[$Failed]];
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
  If[minoQ, t[0] == 0, Nothing]
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





limit = IntegrationLimitValue[OptionValue["IntegrationLimit"], minoQ];

(* Solve the Evolution Equations *)
integration = IntegrateSystem[
    <|"Unknowns" -> unknowns, "Equations" -> Join[ICs, Eqns],
      "Events" -> {stopEvent[Evaluate[SeparatrixEqELK[a, En[s], L[s], k[s]] == -10^-6], "Separatrix"]},
      "Method" -> {"EquationSimplification" -> "Solve"}|>,
    s, limit,
    <|"Function" -> KerrOsculatingOrbitalElements, "MessageHead" -> KerrOsculatingOrbitalElements,
      "VariableName" -> If[minoQ, "\[Lambda]", "t"], "AccuracyGoal" -> OptionValue["AccuracyGoal"],
      "PrecisionGoal" -> OptionValue["PrecisionGoal"], "NDSolveOptions" -> NDSolveOptions[opts],
      "Monitor" -> MonitorQ[OptionValue["TimeMonitor"]], "Quiet" -> False|>];
If[FailureQ[integration], Return[$Failed]];

rules = integration["Solution"];
{Ensol, Lsol, Ksol, \[Psi]rsol, \[Psi]\[Theta]sol, \[Phi]sol} = {En, L, k, \[Psi]r, \[Psi]\[Theta], \[Phi]} /. rules;
If[minoQ, tsol = t /. rules, tsol[\[Tau]_?NumericQ] := \[Tau]];

	
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
"r1"-> r1sol, "r2" -> r2sol, "z1"-> zmsol, "limit" -> Ensol["Domain"][[1,2]], "StopReason" -> integration["StopReason"]|>
 ,
Message[KerrOsculatingOrbitalElements::ICs]; $Failed]
]


