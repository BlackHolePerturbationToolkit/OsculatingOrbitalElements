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


