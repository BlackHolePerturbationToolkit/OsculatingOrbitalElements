(* ::Package:: *)

(* ::Title:: *)
(*Fast first-order gravitational self-force (Schwarzschild)*)


(* ::Section:: *)
(*The fit's coefficients*)


(* ::Text:: *)
(*A fit to the first-order gravitational self-force in Schwarzschild, adapted from code by Niels Warburton. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* The coefficient files, from Data/FastGSF *)
dataA=Import[FileNameJoin[{$dataDirectory, "FastGSF", "a_n_jk"}],"Table"];
dataB=Import[FileNameJoin[{$dataDirectory, "FastGSF", "b_n_jk"}],"Table"];
dataC=Import[FileNameJoin[{$dataDirectory, "FastGSF", "c_n_jk"}],"Table"];
dataD=Import[FileNameJoin[{$dataDirectory, "FastGSF", "d_n_jk"}],"Table"];

(* The tables a, b, c and d, indexed [[n+1, j+1, k+1]], built once at load *)
fastGSFTables = With[{nmax = 7, kbar = 9},
	Table[data[[4+n,3+j kbar+2j;;3+(j+1) kbar+2j]], {data, {dataA, dataB, dataC, dataD}}, {n,0,nmax}, {j,0,4}]];


(* ::Section:: *)
(*Force model*)


(* ::Text:: *)
(*The fit of SchwarzFastGSF (Legacy/ForceFunctions.wl), numerically, with the sums over n, j and k as dot products: the contravariant {F^r, F^\[Phi]} for p, e and the radial anomaly \[Xi] (\[Psi]r here).*)


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
(*The fit as a ForceModel, scaled by the mass ratio. Its components lie in the orbital plane: F_r = (\[CapitalSigma]/\[CapitalDelta]) F^r, and r^2 F^\[Phi] along the particle's angular motion, which for a = 0 gives F_\[Theta] = r^2 F^\[Phi] u_\[Theta]/Sqrt[L^2 + Q] and F_\[Phi] = r^2 F^\[Phi] L/Sqrt[L^2 + Q] (\[PlusMinus] r^2 F^\[Phi] on an equatorial orbit).*)


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
