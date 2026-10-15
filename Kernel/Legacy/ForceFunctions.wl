(* ::Package:: *)

(* ::Title:: *)
(*Force functions with the earlier signatures*)


(* ::Text:: *)
(*LEGACY CODE: not used by the current interface, OsculatingInspiral. Kept so that the earlier functions keep working; do not extend it. SchwarzGasDrag, KerrGasDrag, KerrGasDragVec, KerrGasDragapex, KerrEMCons and SchwarzFastGSF, which the earlier solvers take through their Force option. The ForceModels "GasDrag", "EMConservative" and "FastGSF" replace them; SchwarzFastGSF uses the coefficient tables that ForceModels/FastGSF.wl reads. Kernel/OsculatingOrbitalElements.wl loads this file last, into the package's private context.*)


(* ::Section:: *)
(*Gas drag*)


(* ::Subsection:: *)
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


(* ::Subsection:: *)
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
(*Conservative electromagnetic force*)


(* ::Subsubsection:: *)
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
a\[Phi] = -1/\[CapitalSigma]^3((1-z^2)(r^5+2r^3a^2+r a^4+2 a^2r^2-2 a^4+a^4(r-1)(1-z^2)^2-a^2(2r a^2-3 a^2+2r^3+r^2)(1-z^2))\[CapitalDelta] ur+z Sqrt[(1-z^2)](r^6+a^2r^4-2a^4 r +2a^2r^2\[CapitalDelta] z^2+a^4\[CapitalDelta] z^4)u\[Theta]);

<|"at" -> at, "ar" -> ar, "a\[Theta]" -> a\[Theta], "a\[Phi]" ->   a\[Phi]|>
]




(* ::Section:: *)
(*Fast first-order gravitational self-force*)


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

(*The tables a, b, c, and d*)
{a, b, c, d} = fastGSFTables;

(*Calculating the companants of the graviational self force*)
FrCons=1/p^ki[1] Sum[If[n==0,1/2,1]a[[n+1,j+1,k+1]]p^(-ki[1]-k) e^(n+2j) Cos[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
FrDiss=1/p^ki[2] Sum[If[n==0,1/2,1]b[[n+1,j+1,k+1]]p^(-ki[2]-k) e^(n+2j) Sin[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Cons=1/p^ki[3] Sum[If[n==0,1/2,1]c[[n+1,j+1,k+1]]p^(-ki[3]-k) e^(n+2j) Sin[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];
F\[Phi]Diss=1/p^ki[4] Sum[If[n==0,1/2,1]d[[n+1,j+1,k+1]]p^(-ki[4]-k) e^(n+2j) Cos[n \[Xi]],{n,0,nmax},{j,0,jbar},{k,0,kbar}];

(*Retuning the componants as a 4 vector*)
<|"Fr" -> (FrDiss + FrCons), "F\[Phi]" -> M(F\[Phi]Cons + F\[Phi]Diss)|>]
