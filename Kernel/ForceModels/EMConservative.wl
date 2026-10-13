(* ::Package:: *)

(* ::Title:: *)
(*Conservative electromagnetic force*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


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


