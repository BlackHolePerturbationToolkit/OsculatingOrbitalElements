(* ::Package:: *)

(* ::Title:: *)
(*Legacy equations*)


(* ::Text:: *)
(*LEGACY: kept for reference only; do not extend. Earlier versions of the ELK equations (KerrOscGeoEqs, KerrOscGeoEqsTP and KerrOscGeoEqsTPVecLessArg), which nothing calls.*)


(* ::Text:: *)
(*Usage messages for functions that no longer exist. They are kept as comments so that they do not create undefined public symbols.*)


(*
MessageName[KerrOsculatingOrbitalElementsTPVec, "usage"] = 
"KerrOsculatingOrbitalElementsTPVec[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{fr, f\[Theta] f\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of proper time (t) using a given by contravarient components of an acceleration (fr, f\[Theta], f\[Phi]) a mass ratio given by \[Eta]."

MessageName[KerrOsculatingOrbitalElementsTP, "usage"] = 
"KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta], Force->{at, ar, a\[Theta] a\[Phi]}] calculates En, L, K, \[Psi]r and \[Psi]\[Theta] as functions of proper time (t) using a given by covariant components of an acceleration (at, ar, a\[Theta], a\[Phi]) a mass ratio given by \[Eta]."
*)


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


