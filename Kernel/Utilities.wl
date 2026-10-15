(* ::Package:: *)

(* ::Title:: *)
(*Utilities*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Kerr Spacetime*)


(* ::Subsubsection::Closed:: *)
(*Separatrix*)


(* ::Text:: *)
(*The separatrix p for a, e and x, from KerrGeoSeparatrix, made safe for the values an inspiral reaches. KerrGeoSeparatrix only treats exact x = 1, 0 and -1 as the equatorial and polar cases, and does not evaluate at machine 1., 0. or -1., at |x| > 1, or within machine tolerance of 1 or -1. So x is clamped to [-1, 1], and within 10^-12 of \[PlusMinus]1 or 0 replaced by the exact value, which moves p_sep by far less than any stopping buffer.*)


SeparatrixP[a_?NumericQ, e_?NumericQ, x_?NumericQ] := With[{xc = Clip[x, {-1, 1}]}, Quiet[Which[
	PossibleZeroQ[a], 6 + 2 e,
	1 - Abs[xc] < 10^-12, KerrGeoSeparatrix[a, e, Sign[xc]],
	Abs[xc] < 10^-12, KerrGeoSeparatrix[a, e, 0],
	True, KerrGeoSeparatrix[a, e, xc]]]];


(* ::Subsubsection::Closed:: *)
(*Constants of Motion*)


(* ::Text:: *)
(*NDSolve evaluates the functions it calls many times per step with the same arguments, so they memoise their most recent value with memoLast, dropping the previous one. Memoising every call instead grows without bound over an inspiral.*)


SetAttributes[memoLast, HoldAll];
memoLast[f_Symbol, cache_Symbol, key_, value_] := With[{k = key, v = value},
	If[ListQ[cache], f[Sequence @@ cache] =.];
	cache = k;
	f[Sequence @@ k] = v];
(* ::Text:: *)
(*The regular solver's constants of motion. RegularEnergy and RegularLOverX take a, p, e^2 and x, and return the energy and \[ScriptL] = L/x, from which L = x \[ScriptL] and Q = (1 - x^2)(a^2 (1 - En^2) + \[ScriptL]^2). Unlike the functions above, they need no special cases at e = 0 or x = 0: they take e^2, as the regular radial variables give it, and \[ScriptL] stays finite for polar orbits, where L/x is 0/0.*)
(*They follow Schmidt's construction, as KerrGeodesics does, with two changes:*)
(*- L is replaced by x \[ScriptL]. Schmidt's h(r) is multiplied by x^2, which makes it r^2 - 2 r + a^2 zm.*)
(*- The conditions at the turning points r1 and r2 are replaced by their mean and their divided difference. These are sums of products of r1 and r2 with positive coefficients, so nothing cancels as r1 and r2 meet at e = 0.*)


regularConstants[a_, p_, e2_, x_] := Module[
	{e, r1, r2, zm, means, differences, rows, f, d, h, r, det, \[Kappa], \[Rho], \[Epsilon], \[Eta], \[Sigma], En2},
	e = Sqrt[e2];
	r1 = p/(1 - e);
	r2 = p/(1 + e);
	zm = 1 - x^2;
	(* For a polynomial with coefficients c, lowest power first: c . means is the mean of its values at r1 and r2, and
	   c . differences their divided difference *)
	means = {2, r1 + r2, r1^2 + r2^2, r1^3 + r2^3, r1^4 + r2^4}/2;
	differences = {0, 1, r1 + r2, r1^2 + r1 r2 + r2^2, r1^3 + r1^2 r2 + r1 r2^2 + r2^3};
	rows[c_] := {c . means, c . differences};
	f = rows[{a^4 zm, 2 a^2 x^2, a^2 (1 + zm), 0, 1}];
	d = rows[{a^4 zm, -2 a^2 zm, a^2 (1 + zm), -2, 1}];
	h = rows[{a^2 zm, -2, 1, 0, 0}];
	(* Schmidt's g(r) = 2 a r, with the factor 2 a taken out so that a = 0 needs no special case *)
	r = rows[{0, 1, 0, 0, 0}];
	det[{u1_, u2_}, {v1_, v2_}] := u1 v2 - v1 u2;
	\[Kappa] = det[d, h];
	\[Rho] = det[f, h];
	\[Epsilon] = det[d, r];
	\[Eta] = det[f, r];
	\[Sigma] = det[r, h];
	En2 = (\[Kappa] \[Rho] + 8 a^2 x^2 \[Epsilon] \[Sigma] -
		4 Abs[a] x Sqrt[\[Sigma] (4 a^2 \[Sigma] \[Epsilon]^2 x^2 + \[Rho] \[Epsilon] \[Kappa] - \[Eta] \[Kappa]^2)])/
		(\[Rho]^2 + 16 a^2 x^2 \[Eta] \[Sigma]);
	{Sqrt[En2], Sqrt[(\[Epsilon] - \[Eta] En2)/\[Sigma]]}
];

regularConstantsCache = None;
cachedRegularConstants[a_, p_, e2_, x_] := memoLast[cachedRegularConstants, regularConstantsCache, {a, p, e2, x},
	regularConstants[a, p, e2, x]];

RegularEnergy[a_?NumericQ, p_?NumericQ, e2_?NumericQ, x_?NumericQ] := First[cachedRegularConstants[a, p, e2, x]];
RegularLOverX[a_?NumericQ, p_?NumericQ, e2_?NumericQ, x_?NumericQ] := Last[cachedRegularConstants[a, p, e2, x]];


(* ::Subsubsection::Closed:: *)
(*Orbit geometry*)


(* ::Text:: *)
(*The quantities that the osculating equations share, at one point of the orbit. The point lies on a geodesic with constants En, L and Q, at radius r and polar phase \[Psi]\[Theta], moving radially at dr/d\[Lambda] = drd\[Lambda]; x is the geodesic's inclination parameter, so zm = 1 - x^2 and cos \[Theta] = Sqrt[zm] Cos[\[Psi]\[Theta]]. Each formulation knows r and dr/d\[Lambda] in its own variables, so it supplies them. The arguments may be symbolic, as the solvers build their equations from these expressions.*)
(*\[Beta] zp = \[Beta] + L^2/x^2 is 0/0 for polar orbits. Where L = x \[ScriptL] is symbolic, as in the regular solver, the x^2 cancels as the expression is built. NumericOrbitGeometry, which works with numbers, gives \[Beta] zp = \[Beta] + \[ScriptL]^2 directly to orbitGeometry, so it holds at x = 0.*)
(*The result has the arguments, under the keys "a", "En", "L", "Q", "r", "x" and "\[Psi]\[Theta]", and:*)
(*"K" = Q + (L - a En)^2, "\[Beta]" = a^2 (1 - En^2), "zm", "\[Beta]zp" = \[Beta] zp, "z" = cos^2 \[Theta] and "\[Theta]";*)
(*"\[CapitalSigma]", "\[CapitalDelta]", "\[Omega]" = Sqrt[r^2 + a^2], "F" = \[Omega]^2 En - a L, and the shorthands "H" and "G" of the polar phase equation;*)
(*the covariant velocities "ur" and "u\[Theta]", and "un", the velocity along the null tetrad's leg n;*)
(*"dtd\[Lambda]" and "d\[Phi]d\[Lambda]".*)


KerrOrbitGeometry[a_, {En_, L_, Q_}, {r_, x_, \[Psi]\[Theta]_}, drd\[Lambda]_] :=
	orbitGeometry[a, {En, L, Q}, {r, x, \[Psi]\[Theta]}, a^2 (1 - En^2) + L^2/x^2, drd\[Lambda]];

orbitGeometry[a_, {En_, L_, Q_}, {r_, x_, \[Psi]\[Theta]_}, \[Beta]zp_, drd\[Lambda]_] := Module[
	{K, \[Beta], zm, z, \[Theta], \[CapitalSigma], \[CapitalDelta], \[Omega], F, ur},
	K = Q + (L - a En)^2;
	\[Beta] = a^2 (1 - En^2);
	zm = 1 - x^2;
	z = zm Cos[\[Psi]\[Theta]]^2;
	\[Theta] = ArcCos[Sqrt[zm] Cos[\[Psi]\[Theta]]];
	\[CapitalSigma] = r^2 + a^2 z;
	\[CapitalDelta] = r^2 + a^2 - 2 r;
	\[Omega] = Sqrt[r^2 + a^2];
	F = \[Omega]^2 En - a L;
	ur = drd\[Lambda]/\[CapitalDelta];
	<|"a" -> a, "En" -> En, "L" -> L, "Q" -> Q, "r" -> r, "x" -> x, "\[Psi]\[Theta]" -> \[Psi]\[Theta],
		"K" -> K, "\[Beta]" -> \[Beta], "zm" -> zm, "\[Beta]zp" -> \[Beta]zp, "z" -> z, "\[Theta]" -> \[Theta],
		"\[CapitalSigma]" -> \[CapitalSigma], "\[CapitalDelta]" -> \[CapitalDelta], "\[Omega]" -> \[Omega], "F" -> F,
		"H" -> L - a En x^2,
		"G" -> \[Omega]^2 L/Sin[\[Theta]] - a^3 x^2 Sin[\[Theta]] En,
		"ur" -> ur,
		"u\[Theta]" -> Sqrt[zm] Sin[\[Psi]\[Theta]]/Sin[\[Theta]] Sqrt[\[Beta]zp - \[Beta] z],
		"un" -> -(F + \[CapitalDelta] ur)/(2 \[CapitalSigma]),
		"dtd\[Lambda]" -> En (\[Omega]^4/\[CapitalDelta] - a^2 (1 - z)) + a L (1 - \[Omega]^2/\[CapitalDelta]),
		"d\[Phi]d\[Lambda]" -> L/(1 - z) + a En (\[Omega]^2/\[CapitalDelta] - 1) - a^2 L/\[CapitalDelta]|>
];


(* ::Text:: *)
(*The force's components in the null tetrad, {a_n, A1, A2, A3}, from its covariant Boyer-Lindquist components {a_t, a_r, a_\[Theta], a_\[Phi]}. The phase equations use these.*)


NullTetradForce[g_Association, {at_, ar_, a\[Theta]_, a\[Phi]_}] := Module[{a, En, L, \[Theta], \[CapitalSigma]},
	{a, En, L, \[Theta], \[CapitalSigma]} = Lookup[g, {"a", "En", "L", "\[Theta]", "\[CapitalSigma]"}];
	{
		(g["\[Omega]"]^2 at - g["\[CapitalDelta]"] ar + a a\[Phi])/(2 \[CapitalSigma]),
		a\[Theta],
		-a Sin[\[Theta]] at - a\[Phi]/Sin[\[Theta]],
		a (L - a En Sin[\[Theta]]^2) at/\[CapitalSigma] + g["u\[Theta]"] a\[Theta]/\[CapitalSigma] +
			(L - a En Sin[\[Theta]]^2) a\[Phi]/(\[CapitalSigma] Sin[\[Theta]]^2)
	}
];


(* ::Text:: *)
(*The time component a_t of a force from its other covariant components, so that the force is orthogonal to the velocity: u^\[Mu] a_\[Mu] = 0, with u^t = (dt/d\[Lambda])/\[CapitalSigma], u^r = \[CapitalDelta] u_r/\[CapitalSigma], u^\[Theta] = u_\[Theta]/\[CapitalSigma] and u^\[Phi] = (d\[Phi]/d\[Lambda])/\[CapitalSigma].*)


OrthogonalTimeComponent[g_Association, {ar_, a\[Theta]_, a\[Phi]_}] :=
	-(g["\[CapitalDelta]"] g["ur"] ar + g["u\[Theta]"] a\[Theta] + g["d\[Phi]d\[Lambda]"] a\[Phi])/g["dtd\[Lambda]"];


(* ::Text:: *)
(*The geometry of the geodesic with elements p, e, x and phases \[Psi]r, \[Psi]\[Theta], as numbers, for force models that need the velocity, with d\[Psi]r/d\[Lambda] added under the key "d\[Psi]rd\[Lambda]". It uses the regular constants of motion, and \[Beta] zp = \[Beta] + \[ScriptL]^2, so it holds at e = 0, x = 0 and x = \[PlusMinus]1.*)


NumericOrbitGeometry[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ, \[Psi]r_?NumericQ, \[Psi]\[Theta]_?NumericQ] := Module[
	{e2, En, \[ScriptL], L, Q, K, \[Alpha]p, \[Beta]p, w, Z},
	e2 = e^2;
	En = RegularEnergy[a, p, e2, x];
	\[ScriptL] = RegularLOverX[a, p, e2, x];
	L = x \[ScriptL];
	Q = (1 - x^2) (a^2 (1 - En^2) + \[ScriptL]^2);
	K = Q + (L - a En)^2;
	\[Alpha]p = e Sin[\[Psi]r];
	\[Beta]p = e Cos[\[Psi]r];
	w = 1 + \[Beta]p;
	(* Z = (d\[Psi]r/d\[Lambda])^2, as in the REG and regular solvers *)
	Z = p - K (3 - e2 + 2 \[Beta]p)/p + a^2 Q (4 - e2 + 4 \[Beta]p + \[Beta]p^2)/p^2;
	Append[
		orbitGeometry[a, {En, L, Q}, {p/w, x, \[Psi]\[Theta]}, a^2 (1 - En^2) + \[ScriptL]^2, p \[Alpha]p Sqrt[Z]/w^2],
		"d\[Psi]rd\[Lambda]" -> Sqrt[Z]]
];


(* ::Subsubsection::Closed:: *)
(*Rates of change of the constants of motion and the orbital elements*)


(* ::Text:: *)
(*The rates of change with Mino time of En, L, K and Q under the covariant force {a_t, a_r, a_\[Theta], a_\[Phi]}, as an Association with those keys. K's rate is written with the radial velocity, which assumes the force is orthogonal to the velocity, so a_\[Theta] does not appear.*)


ConstantsOfMotionRates[g_Association, {at_, ar_, a\[Theta]_, a\[Phi]_}] := Module[{a, \[CapitalSigma], \[CapitalDelta], dEn, dL, dK},
	{a, \[CapitalSigma], \[CapitalDelta]} = Lookup[g, {"a", "\[CapitalSigma]", "\[CapitalDelta]"}];
	dEn = -\[CapitalSigma] at;
	dL = \[CapitalSigma] a\[Phi];
	dK = 2 \[CapitalSigma]/\[CapitalDelta] (-g["F"] (g["\[Omega]"]^2 at + a a\[Phi]) - \[CapitalDelta]^2 g["ur"] ar);
	<|"En" -> dEn, "L" -> dL, "K" -> dK, "Q" -> dK - 2 (g["L"] - a g["En"]) (dL - a dEn)|>
];


(* ::Text:: *)
(*The map from the rates of change of (En, L, Q) to those of (p, e^2, x), for an orbit with spin a, elements p, e^2 and x, and constants En, L and Q. It returns an Association with the keys "p", "e2" and "x". The rates may be with respect to any time, as the map is linear.*)
(*It gives e^2 rather than e, because the rate of e^2 has no division by e and stays finite for circular orbits; that of e is "e2"/(2 e). It does divide by x, so it is singular for polar orbits (x = 0).*)


OrbitalElementRates[a_, {p_, e2_, x_}, {En_, L_, Q_}, rates:{dEn_, dL_, dQ_}] := Module[{dK, zm, \[Beta], \[Beta]zp, dzm},
	dK = dQ + 2 (L - a En) (dL - a dEn);
	(* x, through zm = 1 - x^2 *)
	zm = 1 - x^2;
	\[Beta] = a^2 (1 - En^2);
	\[Beta]zp = \[Beta] + L^2/x^2;
	dzm = ((1 - zm) dK - 2 (L - a (1 - zm) En) (dL - a (1 - zm) dEn))/(\[Beta]zp - \[Beta] zm);
	Append[SlowElementRates[a, {p, e2}, {En, L, Q}, rates], "x" -> -dzm/(2 x)]
];


(* ::Text:: *)
(*The p and e^2 parts of OrbitalElementRates, an Association with the keys "p" and "e2"*)


SlowElementRates[a_, {p_, e2_}, {En_, L_, Q_}, {dEn_, dL_, dQ_}] := Module[
	{K, V, dK, dV, Dp, h0p, h1p, B0, B1},
	K = Q + (L - a En)^2;
	V = a^2 (1 - En^2) + L^2 + Q;
	dK = dQ + 2 (L - a En) (dL - a dEn);
	dV = -2 a^2 En dEn + 2 L dL + dQ;
	Dp = (p^3 - K p (3 - e2) + 4 a^2 Q)^2 - 4 e2 (K p - 2 a^2 Q)^2;
	h0p = -4 (1 - En^2) p^3 + 6 p^2 - 2 V p (1 + e2) + 2 K (1 + 3 e2);
	h1p = 6 p^2 - 4 V p + 2 K (3 + e2);
	B0 = 2 p^4 En dEn - p^2 (1 + e2) dV + 2 p (1 + 3 e2) dK - a^2 (1 + 6 e2 + e2^2) dQ;
	B1 = -2 p^2 dV + 2 p (3 + e2) dK - 4 a^2 (1 + e2) dQ;
	<|
		"p" -> p/Dp (
			-2 p^4 (K p - 2 a^2 Q) En dEn +
			p^2 (p^3 - 2 (1 - e2) (K p - a^2 Q)) dV -
			p (p^3 (3 + e2) - (1 - e2) ((7 + e2) K p - 8 a^2 Q)) dK +
			a^2 (2 p^3 (1 + e2) - (1 - e2) ((5 + 3 e2) K p - 2 a^2 Q (3 + e2))) dQ),
		"e2" -> p (h1p B0 - h0p B1)/(2 Dp)
	|>
];


(* ::Text:: *)
(*The rate of x from the rates of (En, L, Q), in a form that is regular at x = 0. It uses \[ScriptL] = L/x: with L = x \[ScriptL] the factor x in dzm cancels the 1/x, and \[Beta] zp - \[Beta] zm = \[ScriptL]^2 + \[Beta] x^2. At x = 0 it is dL/\[ScriptL].*)


RegularXRate[a_, x_, {En_, \[ScriptL]_}, {dEn_, dL_, dQ_}] := Module[{dK},
	dK = dQ + 2 (x \[ScriptL] - a En) (dL - a dEn);
	-(x dK - 2 (\[ScriptL] - a x En) (dL - a x^2 dEn))/(2 (\[ScriptL]^2 + a^2 (1 - En^2) x^2))
];
