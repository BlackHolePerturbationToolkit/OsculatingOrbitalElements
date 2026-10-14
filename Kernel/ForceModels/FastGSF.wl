(* ::Package:: *)

(* ::Title:: *)
(*Fast first-order gravitational self-force (Schwarzschild)*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Subsubsection::Closed:: *)
(*Default Self Force Model: Fast GSF by Warburton et al.*)


(* ::Text:: *)
(*A fast to evaluate function for the Gravitational Self Force. This code was adapted from that provided by Niels Warburton. The derivation of this function is discussed in [2]*)


(*Loading the files from the package's Data/FastGSF directory*)
dataA=Import[FileNameJoin[{$dataDirectory, "FastGSF", "a_n_jk"}],"Table"];
dataB=Import[FileNameJoin[{$dataDirectory, "FastGSF", "b_n_jk"}],"Table"];
dataC=Import[FileNameJoin[{$dataDirectory, "FastGSF", "c_n_jk"}],"Table"];
dataD=Import[FileNameJoin[{$dataDirectory, "FastGSF", "d_n_jk"}],"Table"];

(*Coefficient tables a, b, c and d, indexed as [[n+1, j+1, k+1]]. Built once here rather than on every call.*)
fastGSFTables = With[{nmax = 7, kbar = 9},
	Table[data[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]], {data, {dataA, dataB, dataC, dataD}}, {n,0,nmax}, {j,0,4}]];


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




(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*The same fit as SchwarzFastGSF, as numbers, with the sums over n, j and k done as dot products. It returns the contravariant {F^r, F^\[Phi]} for p, e and the radial anomaly \[Xi] (\[Psi]r in this package). SchwarzFastGSF keeps its symbolic sum, which the earlier Schwarzschild solvers expand once.*)


fastGSFComponents[p_?NumericQ, e_?NumericQ, \[Xi]_?NumericQ] := Module[{n = Range[0, 7], weights, sums, a, b, c, d},
	{a, b, c, d} = fastGSFTables;
	(* For each n: the sum over j and k of table[[n, j, k]] e^(2j) p^(-k) *)
	(* The zero powers are written as 1: at e = 0, 0.^0 would be Indeterminate *)
	sums[table_] := (table . (p^-Range[0, 9])) . Prepend[e^(2 Range[1, 4]), 1];
	weights = Prepend[e^Range[1, 7], 1/2];
	{
		p^-4 (weights Cos[n \[Xi]]) . sums[a] + p^-9 (weights Sin[n \[Xi]]) . sums[b],
		p^-8 (weights Sin[n \[Xi]]) . sums[c] + p^-11 (weights Cos[n \[Xi]]) . sums[d]
	}
];


(* ::Text:: *)
(*The fit as a ForceModel. Its components lie in the orbital plane: F_r = (\[CapitalSigma]/\[CapitalDelta]) F^r, and the in-plane angular component r^2 F^\[Phi] points along the particle's angular motion, which for a = 0 gives F_\[Theta] = r^2 F^\[Phi] u_\[Theta]/Sqrt[L^2 + Q] and F_\[Phi] = r^2 F^\[Phi] L/Sqrt[L^2 + Q]. On an equatorial orbit these are the usual F_\[Phi] = r^2 F^\[Phi], with the sign of x. It is the first-order self-force, so it scales with the mass ratio.*)


fastGSFForce[a_, p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_, t_] := Module[{g, fr, f\[Phi], angular, total},
	g = NumericOrbitGeometry[a, p, e, x, \[Psi]r, \[Psi]\[Theta]];
	{fr, f\[Phi]} = fastGSFComponents[p, e, \[Psi]r];
	angular = g["r"]^2 f\[Phi];
	total = Sqrt[g["L"]^2 + g["Q"]];
	{g["\[CapitalSigma]"]/g["\[CapitalDelta]"] fr, angular g["u\[Theta]"]/total, angular g["L"]/total}
];

builtInForceModels["FastGSF"] = ForceModel[<|
	"Name" -> "FastGSF",
	"Description" -> "Fit to the first-order gravitational self-force in Schwarzschild",
	"Function" -> fastGSFForce,
	"Parameters" -> <||>,
	"ScalesWithMassRatio" -> True,
	"ValidityCondition" -> (#1 == 0 && #2 <= 12 && #3 <= 0.2 &),
	"ValidityDescription" -> "a = 0, p \[LessEqual] 12 and e \[LessEqual] 0.2",
	"Citation" -> "Adapted from code by Niels Warburton"|>];
