(* ::Package:: *)

(* ::Title:: *)
(*Utilities*)


(* ::Text:: *)
(*Shared helpers: the separatrix, the regular constants of motion, the orbit geometry, and the rates of change of the constants and elements under a force. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Section:: *)
(*Kerr Spacetime*)


(* ::Subsubsection::Closed:: *)
(*Separatrix*)


(* ::Text:: *)
(*p at the separatrix, from KerrGeoSeparatrix. That only evaluates the polar and equatorial cases at exact x = 0 and \[PlusMinus]1, so x is clamped to [-1, 1] and replaced by the exact value within 10^-12 of them, which moves p_sep far less than any stopping buffer.*)


SeparatrixP[a_?NumericQ, e_?NumericQ, x_?NumericQ] := With[{xc = Clip[x, {-1, 1}]}, Quiet[Which[
	PossibleZeroQ[a], 6 + 2 e,
	1 - Abs[xc] < 10^-12, KerrGeoSeparatrix[a, e, Sign[xc]],
	Abs[xc] < 10^-12, KerrGeoSeparatrix[a, e, 0],
	True, KerrGeoSeparatrix[a, e, xc]]]];


(* ::Subsubsection::Closed:: *)
(*Caching*)


(* ::Text:: *)
(*memoLast caches only the most recent value of f. NDSolve calls the same functions many times per step with the same arguments; caching every call would grow without bound over an inspiral.*)


SetAttributes[memoLast, HoldAll];
memoLast[f_Symbol, cache_Symbol, key_, value_] := With[{k = key, v = value},
	If[ListQ[cache], f[Sequence @@ cache] =.];
	cache = k;
	f[Sequence @@ k] = v];


(* ::Subsubsection::Closed:: *)
(*Constants of motion*)


(* ::Text:: *)
(*RegularEnergy and RegularLOverX: the energy and \[ScriptL] = L/x of the geodesic with spin a and elements p, e^2 and x, from which L = x \[ScriptL] and Q = (1 - x^2)(a^2 (1 - En^2) + \[ScriptL]^2). They need no special cases at e = 0 or x = 0. They follow Schmidt's construction, as KerrGeodesics does, with two changes:*)
(*- L = x \[ScriptL], which turns x^2 times Schmidt's h(r) into r^2 - 2 r + a^2 zm;*)
(*- the conditions at the turning points r1 and r2 are replaced by their mean and divided difference, which do not cancel as r1 and r2 meet at e = 0.*)


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
(*The quantities the osculating equations share, at a point of the geodesic with constants En, L and Q: radius r, polar phase \[Psi]\[Theta] (cos \[Theta] = Sqrt[1 - x^2] Cos[\[Psi]\[Theta]]) and radial velocity dr/d\[Lambda] = drd\[Lambda]. The arguments may be symbolic. The result has the arguments and:*)
(*"K" = Q + (L - a En)^2, "\[Beta]" = a^2 (1 - En^2), "zm" = 1 - x^2, "\[Beta]zp" = \[Beta] zp, "z" = cos^2 \[Theta], "\[Theta]";*)
(*"\[CapitalSigma]", "\[CapitalDelta]", "\[Omega]" = Sqrt[r^2 + a^2], "F" = \[Omega]^2 En - a L, and "H" and "G", shorthands of the polar phase equation;*)
(*the covariant velocities "ur" and "u\[Theta]", "un" along the null tetrad leg n, "dtd\[Lambda]" and "d\[Phi]d\[Lambda]".*)
(*\[Beta] zp = \[Beta] + L^2/x^2 is 0/0 at x = 0. With a symbolic L = x \[ScriptL], as in the regular solver, the x^2 cancels; NumericOrbitGeometry gives \[Beta] + \[ScriptL]^2 to orbitGeometry directly.*)


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
(*The force's null-tetrad components {a_n, A1, A2, A3}, for the phase equations, from its covariant components {a_t, a_r, a_\[Theta], a_\[Phi]}.*)


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
(*a_t from the other covariant components, so that the force is orthogonal to the velocity, u^\[Mu] a_\[Mu] = 0.*)


OrthogonalTimeComponent[g_Association, {ar_, a\[Theta]_, a\[Phi]_}] :=
	-(g["\[CapitalDelta]"] g["ur"] ar + g["u\[Theta]"] a\[Theta] + g["d\[Phi]d\[Lambda]"] a\[Phi])/g["dtd\[Lambda]"];


(* ::Text:: *)
(*The geometry at numeric elements p, e, x and phases \[Psi]r, \[Psi]\[Theta], for force models that need the velocity, with "d\[Psi]rd\[Lambda]" added. It holds at e = 0 and x = 0, \[PlusMinus]1.*)


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
(*Rates of change*)


(* ::Text:: *)
(*The Mino-time rates of En, L, K and Q under the covariant force {a_t, a_r, a_\[Theta], a_\[Phi]}. K's rate uses the radial velocity, which assumes u^\[Mu] a_\[Mu] = 0.*)


ConstantsOfMotionRates[g_Association, {at_, ar_, a\[Theta]_, a\[Phi]_}] := Module[{a, \[CapitalSigma], \[CapitalDelta], dEn, dL, dK},
	{a, \[CapitalSigma], \[CapitalDelta]} = Lookup[g, {"a", "\[CapitalSigma]", "\[CapitalDelta]"}];
	dEn = -\[CapitalSigma] at;
	dL = \[CapitalSigma] a\[Phi];
	dK = 2 \[CapitalSigma]/\[CapitalDelta] (-g["F"] (g["\[Omega]"]^2 at + a a\[Phi]) - \[CapitalDelta]^2 g["ur"] ar);
	<|"En" -> dEn, "L" -> dL, "K" -> dK, "Q" -> dK - 2 (g["L"] - a g["En"]) (dL - a dEn)|>
];


(* ::Text:: *)
(*The rates of p and e^2, as "p" and "e2", from those of (En, L, Q), with respect to any time. e^2 is used as its rate stays finite at e = 0.*)


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
(*The rate of x from those of (En, L, Q), written with \[ScriptL] = L/x so that it is regular at x = 0, where it is dL/\[ScriptL].*)


RegularXRate[a_, x_, {En_, \[ScriptL]_}, {dEn_, dL_, dQ_}] := Module[{dK},
	dK = dQ + 2 (x \[ScriptL] - a En) (dL - a dEn);
	-(x dK - 2 (\[ScriptL] - a x En) (dL - a x^2 dEn))/(2 (\[ScriptL]^2 + a^2 (1 - En^2) x^2))
];
