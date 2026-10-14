(* ::Package:: *)

(* ::Title:: *)
(*Gas drag*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Schwarzschild*)


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


(* ::Section:: *)
(*Kerr*)


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

(*Polar root. zm = 1 - x^2 defines x; computing it from \[Beta] instead divides by zero when a = 0*)
zm = 1 - x^2;
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
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta]])/Sin[\[Theta]] Sqrt[\[Beta] + L^2/x^2 - \[Beta] z]; (*\[Beta] zp = \[Beta] + L^2/(1 - zm)*)
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




(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*The relativistic gas drag of KerrGasDrag as a ForceModel, with strength k, its "Coefficient": F_\[Mu] = -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t). Its spatial components are -k {u_r, u_\[Theta], u_\[Phi]}, with u_\[Phi] = L, and F_t follows from orthogonality. It does not scale with the mass ratio.*)


gasDragComponents[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_, parameters_] := With[{g = NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]]},
	-parameters["Coefficient"] {g["ur"], g["u\[Theta]"], g["L"]}];

builtInForceModels["GasDrag"] = ForceModel[<|
	"Name" -> "GasDrag",
	"Description" -> "Relativistic gas drag, F_\[Mu] = -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t), with k the Coefficient",
	"Function" -> gasDragComponents,
	"Parameters" -> <|"Coefficient" -> Missing["Required"]|>,
	"ScalesWithMassRatio" -> False,
	"ValidityCondition" -> (True &),
	"ValidityDescription" -> None,
	"Citation" -> "J. R. Gair, E. E. Flanagan, S. Drasco, T. Hinderer and S. Babak, Forced motion near black holes, arXiv:1012.5111, Appendix D"|>];
