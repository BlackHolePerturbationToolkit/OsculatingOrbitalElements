(* ::Package:: *)

(* ::Title:: *)
(*Utilities*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Shared Functions*)


(* ::Text:: *)
(*Reports why an integration stopped. reason is set by the stopping event ("Separatrix", "SeparatrixBuffer" or "pMin"), or is None if no event fired.*)


StopMessage[head_, var_, end_, limit_, reason_] := Switch[reason,
	"Separatrix", Message[MessageName[head, "sep"], var, end],
	"SeparatrixBuffer", Message[MessageName[head, "sepbuf"], var, end],
	"pMin", Message[MessageName[head, "pmin"], var, end],
	_, If[end == limit, Message[MessageName[head, "limit"], var, limit], Message[MessageName[head, "early"], var, end]]];


(* ::Section:: *)
(*Kerr Spacetime*)


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
(*Parametrisation*)


(* ::Text:: *)
(*Accepts the Parametrisation option as a string or a symbol (e.g. "Mino" or Mino). Returns True for Mino time, False for coordinate time, and $Failed otherwise.*)


MinoParametrisationQ[param_] := Switch[If[Head[param] === Symbol, SymbolName[param], param],
	"Mino", True,
	"CoordinateTime", False,
	_, Message[KerrOsculatingOrbitalElements::param, param]; $Failed];


(* ::Subsubsection::Closed:: *)
(*Separatrix equation*)


SeparatrixEqELK[a_?NumericQ,En_?NumericQ,L_?NumericQ,k_?NumericQ]:=16 (-1+En) (1+En) (a^10 En^2-a^12 En^2-27 a^8 En^4+30 a^10 En^4+a^12 En^4-96 a^10 En^6+64 a^10 En^8-a^8 k+a^10 k+36 a^6 En^2 k-43 a^8 En^2 k+3 a^10 En^2 k+36 a^6 En^4 k+80 a^8 En^4 k-4 a^10 En^4 k+96 a^8 En^6 k-128 a^8 En^8 k-8 a^4 k^2+12 a^6 k^2-4 a^8 k^2-52 a^4 En^2 k^2+42 a^6 En^2 k^2-2 a^8 En^2 k^2-2 a^4 En^4 k^2-220 a^6 En^4 k^2+6 a^8 En^4 k^2+96 a^6 En^6 k^2+64 a^6 En^8 k^2-16 k^3+32 a^2 k^3-22 a^4 k^3+6 a^6 k^3-52 a^2 En^2 k^3+42 a^4 En^2 k^3-2 a^6 En^2 k^3+36 a^2 En^4 k^3+80 a^4 En^4 k^3-4 a^6 En^4 k^3-96 a^4 En^6 k^3-8 k^4+12 a^2 k^4-4 a^4 k^4+36 En^2 k^4-43 a^2 En^2 k^4+3 a^4 En^2 k^4-27 En^4 k^4+30 a^2 En^4 k^4+a^4 En^4 k^4-k^5+a^2 k^5+En^2 k^5-a^2 En^2 k^5-2 a^9 En L+2 a^11 En L+108 a^7 En^3 L-126 a^9 En^3 L+6 a^11 En^3 L+456 a^9 En^5 L-8 a^11 En^5 L-320 a^9 En^7 L-72 a^5 En k L+92 a^7 En k L-16 a^9 En k L-108 a^5 En^3 k L-188 a^7 En^3 k L-8 a^9 En^3 k L-440 a^7 En^5 k L+24 a^9 En^5 k L+512 a^7 En^7 k L+64 a^3 En k^2 L-88 a^5 En k^2 L+36 a^7 En k^2 L+4 a^3 En^3 k^2 L+440 a^5 En^3 k^2 L-12 a^7 En^3 k^2 L-136 a^5 En^5 k^2 L-24 a^7 En^5 k^2 L-192 a^5 En^7 k^2 L+40 a En k^3 L+4 a^3 En k^3 L-32 a^5 En k^3 L-36 a En^3 k^3 L-132 a^3 En^3 k^3 L+24 a^5 En^3 k^3 L+120 a^3 En^5 k^3 L+8 a^5 En^5 k^3 L-6 a En k^4 L+10 a^3 En k^4 L+6 a En^3 k^4 L-10 a^3 En^3 k^4 L+a^8 L^2-a^10 L^2-162 a^6 En^2 L^2+198 a^8 En^2 L^2-23 a^10 En^2 L^2-864 a^8 En^4 L^2+8 a^10 En^4 L^2+640 a^8 En^6 L^2+16 a^10 En^6 L^2+36 a^4 k L^2-49 a^6 k L^2+12 a^8 k L^2+108 a^4 En^2 k L^2+124 a^6 En^2 k L^2+68 a^8 En^2 k L^2+744 a^6 En^4 k L^2-48 a^8 En^4 k L^2-768 a^6 En^6 k L^2-32 a^8 En^6 k L^2-12 a^2 k^2 L^2+31 a^4 k^2 L^2-22 a^6 k^2 L^2-2 a^2 En^2 k^2 L^2-234 a^4 En^2 k^2 L^2-66 a^6 En^2 k^2 L^2-16 a^4 En^4 k^2 L^2+72 a^6 En^4 k^2 L^2+192 a^4 En^6 k^2 L^2+16 a^6 En^6 k^2 L^2-15 a^2 k^3 L^2+12 a^4 k^3 L^2+40 a^2 En^2 k^3 L^2+20 a^4 En^2 k^3 L^2-24 a^2 En^4 k^3 L^2-32 a^4 En^4 k^3 L^2-a^2 k^4 L^2+a^2 En^2 k^4 L^2+108 a^5 En L^3-138 a^7 En L^3+24 a^9 En L^3+816 a^7 En^3 L^3+40 a^9 En^3 L^3-640 a^7 En^5 L^3-64 a^9 En^5 L^3-36 a^3 En k L^3-4 a^5 En k L^3-88 a^7 En k L^3-552 a^5 En^3 k L^3-8 a^7 En^3 k L^3+512 a^5 En^5 k L^3+96 a^7 En^5 k L^3+14 a^3 En k^2 L^3+72 a^5 En k^2 L^3+56 a^3 En^3 k^2 L^3-40 a^5 En^3 k^2 L^3-64 a^3 En^5 k^2 L^3-32 a^5 En^5 k^2 L^3-8 a^3 En k^3 L^3+8 a^3 En^3 k^3 L^3-27 a^4 L^4+36 a^6 L^4-8 a^8 L^4-384 a^6 En^2 L^4-88 a^8 En^2 L^4+320 a^6 En^4 L^4+96 a^8 En^4 L^4-12 a^4 k L^4+32 a^6 k L^4+152 a^4 En^2 k L^4+64 a^6 En^2 k L^4-128 a^4 En^4 k L^4-96 a^6 En^4 k L^4-8 a^4 k^2 L^4-8 a^4 En^2 k^2 L^4+16 a^4 En^4 k^2 L^4+72 a^5 En L^5+64 a^7 En L^5-64 a^5 En^3 L^5-64 a^7 En^3 L^5-32 a^5 En k L^5+32 a^5 En^3 k L^5-16 a^6 L^6+16 a^6 En^2 L^6)


(* ::Subsubsection::Closed:: *)
(*Constants of Motion*)


(* ::Text:: *)
(*NDSolve evaluates these functions many times per step with the same arguments, so each one memoises its most recent value, dropping the previous one. Memoising every call instead grows without bound over an inspiral.*)


SetAttributes[memoLast, HoldAll];
memoLast[f_Symbol, cache_Symbol, key_, value_] := With[{k = key, v = value},
	If[ListQ[cache], f[Sequence @@ cache] =.];
	cache = k;
	f[Sequence @@ k] = v];
energyCache = angularMomentumCache = carterConstantCache = None;

Energy[a_?NumericQ, p_?NumericQ, e:(0|0.), x_?NumericQ] := memoLast[Energy, energyCache, {a, p, e, x}, \[Sqrt](((-3+p) (-2+p)^2 p^5
-2 a^5 x (-1+x^2) Sqrt[p^3+a^2 p (-1+x^2)]+a^4 p^2 (-1+x^2) (4-5 p (-1+x^2)+3 p^2 (-1+x^2))-a^6 (-1+x^2)^2 (x^2+p^2 (-1+x^2)-
p (1+2 x^2))+a^2 p^3 (4-4 x^2+p (12-7 x^2)-3 p^3 (-1+x^2)+p^2 (-13+10 x^2))+a (-2 p^(9/2) x Sqrt[p^2+a^2 (-1+x^2)]+4 p^3 x Sqrt[p^3+a^2 p (-1+x^2)])+
2 a^3 (2 p x (-1+x^2) Sqrt[p^3+a^2 p (-1+x^2)]-x^3 Sqrt[p^7+a^2 p^5 (-1+x^2)]))/
((p^2-a^2 (-1+x^2)) ((-3+p)^2 p^4-2 a^2 p^2 (3+2 p-3 x^2+p^2 (-1+x^2))+a^4 (-1+x^2) (-1+x^2+p^2 (-1+x^2)-2 p (1+x^2)))))];

Energy[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= memoLast[Energy, energyCache, {a,p,e,x},  1/4 \[Sqrt](((-1+e^2)^8 x^4 (-(1/((-1+e^2)^6 x^2))32 a^2 e^2 p^2 (-p^2+a^2 (-1+e^2) (-1+x^2)) 
(-p^3 (-4+3 p+e^2 (4+p))+a^2 (-1+e^2)^2 p^2 (-2+x^2)+a^4 (-1+e^2)^3 (-1+x^2))-32 x 
\[Sqrt](-(1/((-1+e^2)^12 x^8)) a^2 e^4 p^5 (a^4 (-1+e^2)^2+(-4 e^2+(-2+p)^2) p^2+2 a^2 p (-2+p+e^2 (2+p))) (-p^2+a^2 (-1+e^2) (-1+x^2))^3 (p^4-2 a^2 (1+e^2) p^2 
(-1+x^2)+a^4 (-1+e^2)^2 (-1+x^2)^2))+1/((-1+e^2)^8 x^4) 16 e^2 p^2 (p^4 (-3-e^2+p)+a^4 (-1+e^2)^2 (-1+x^2) (-1-x^2+p (-1+x^2)+e^2 (1+x^2))-2 a^2 p^2 
(1+e^4+p (-1+x^2)+e^2 (-2+p (-1+x^2)))) ((-4 e^2+(-2+p)^2) p^3+a^4 (-1+e^2)^2 (-1+x^2) ((-1+e^2) x^2+p (-1+x^2))-a^2 p^2 (4-3 x^2+e^4 x^2+2 p (-1+x^2)
+2 e^2 (-2+x^2+p (-1+x^2))))))/(e^2 p^2 (-4 a^2 (-1+e)^2 (1+e)^2 x^2 (-p^2+a^2 (-1+e^2) (-1+x^2)) (-(3+e^2) p^4+a^2 (-1+e^2)^2 p^2 (-2+x^2)+a^4 (-1+e^2)^3 (-1+x^2))
+((3+e^2-p) p^4-a^4 (-1+e^2)^2 (-1+x^2) (-1-x^2+p (-1+x^2)+e^2 (1+x^2))+2 a^2 p^2 (1+e^4+p (-1+x^2)+e^2 (-2+p (-1+x^2))))^2)))];

AngularMomentum[a_?NumericQ, p_?NumericQ, e:(0|0.), x_?NumericQ]:= memoLast[AngularMomentum, angularMomentumCache, {a,p,e,x}, Module[{En,g,d,h,f},

En = Energy[a,p,e,x];
g=2 a p;
d=(a^2+(-2+p) p) (p^2-a^2 (-1+x^2));
h=((-2+p) p-a^2 (-1+x^2))/x^2;
f=p^4+a^2 (p (2+p)-(a^2+(-2+p) p) (-1+x^2));
(-En g + x Sqrt[(-d h + En^2 (g^2+ f h))/x^2])/h

]];

AngularMomentum[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= memoLast[AngularMomentum, angularMomentumCache, {a,p,e,x}, Module[{En},
En = Energy[a,p,e,x];
-(((-1+e) x^2 (2 a En p-x \[Sqrt](1/((-1+e)^6 x^4) (a^2 (-1+e)^2+p (-2+2 e+p)) (-p^2+a^2 (-1+e)^2 (-1+x^2)) (p (-2+2 e+p-En^2 p)+a^2 (-1+e)^2 (-1+En^2) (-1+x^2)))
+e x \[Sqrt](1/((-1+e)^6 x^4) (a^2 (-1+e)^2+p (-2+2 e+p)) (-p^2+a^2 (-1+e)^2 (-1+x^2)) (p (-2+2 e+p-En^2 p)+a^2 (-1+e)^2 (-1+En^2) (-1+x^2)))))
/(-p (-2+2 e+p)+a^2 (-1+e)^2 (-1+x^2)))
]]

CarterConstant[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ]:= memoLast[CarterConstant, carterConstantCache, {a,p,e,x}, (-a^2 (-1+Energy[a,p,e,x]^2)+AngularMomentum[a,p,e,x]^2/x^2) (1-x^2)];


