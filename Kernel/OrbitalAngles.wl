(* ::Package:: *)

(* ::Title:: *)
(*Frequencies and Boyer-Lindquist action angles*)


(* ::Text:: *)
(*The osculating geodesic's Boyer-Lindquist frequencies and action angles. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Text:: *)
(*The action angles (\[CapitalPhi]r, \[CapitalPhi]\[Theta], \[CapitalPhi]\[Phi]) advance at the constant rates (\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]) in coordinate time. The conversion from the phases (\[Psi]r, \[Psi]\[Theta], \[Phi]) follows P. Lynch and O. Burke, Class. Quantum Grav. 42, 167001 (2025), arXiv:2411.04955, and its code (github.com/Philip-Lynch/KerrOrbitalAngleConversion), with the Fujita-Hikida solution for the geodesic:*)
(*- the Mino-time phases qr and q\[Theta] follow from \[Psi]r and \[Psi]\[Theta]; all four are 0 at periapsis and where cos \[Theta] is largest;*)
(*- \[CapitalPhi]r = qr + \[CapitalOmega]r \[CapitalDelta]t, \[CapitalPhi]\[Theta] = q\[Theta] + \[CapitalOmega]\[Theta] \[CapitalDelta]t and \[CapitalPhi]\[Phi] = \[Phi] - \[CapitalDelta]\[Phi] + \[CapitalOmega]\[Phi] \[CapitalDelta]t, where \[CapitalDelta]t(qr, q\[Theta]) and \[CapitalDelta]\[Phi](qr, q\[Theta]) are the oscillating parts of t and \[Phi] along the geodesic, zero at qr = q\[Theta] = 0.*)
(*So along a geodesic each \[CapitalPhi] is \[CapitalOmega] t plus a constant, and whole turns of a phase are whole turns of its angle.*)
(*The constants come from RegularEnergy and RegularLOverX, so the code's polar root, zp = Sqrt[\[Beta] + \[ScriptL]^2], is finite at a = 0. No special case is needed at e = 0 or x = \[PlusMinus]1, where the undefined phase may take any value. x = 0 is excluded: there \[CapitalDelta]\[Phi] is L times a divergent integral.*)


(* ::Section:: *)
(*The geodesic*)


(* ::Text:: *)
(*What the conversion needs, for spin a and elements p, e, x: En, L, the radial roots r1 > r2 > r3 > r4, the horizons, and the elliptic parameters kr and kz (Mathematica's convention, m = k^2).*)


angleGeometry[a_, p_, e_, x_] := Module[{e2, En, \[ScriptL], L, Q, \[Beta], r1, r2, sum, product, r3, r4, rp, rm},
	e2 = e^2;
	En = RegularEnergy[a, p, e2, x];
	\[ScriptL] = RegularLOverX[a, p, e2, x];
	L = x \[ScriptL];
	\[Beta] = a^2 (1 - En^2);
	Q = (1 - x^2) (\[Beta] + \[ScriptL]^2);
	r1 = p/(1 - e);
	r2 = p/(1 + e);
	(* r3 + r4 and r3 r4, from the radial potential *)
	sum = 2/(1 - En^2) - r1 - r2;
	product = a^2 Q/((1 - En^2) r1 r2);
	r3 = (sum + Sqrt[sum^2 - 4 product])/2;
	r4 = If[r3 == 0, 0, product/r3];
	rp = 1 + Sqrt[1 - a^2];
	rm = 1 - Sqrt[1 - a^2];
	<|"a" -> a, "p" -> p, "e" -> e, "x" -> x, "En" -> En, "L" -> L, "r1" -> r1, "r2" -> r2, "r3" -> r3, "r4" -> r4,
		"rp" -> rp, "rm" -> rm,
		"kr" -> (r1 - r2) (r3 - r4)/((r1 - r3) (r2 - r4)),
		"zp" -> Sqrt[\[Beta] + \[ScriptL]^2],
		"zm2" -> 1 - x^2,
		"kz" -> \[Beta] (1 - x^2)/(\[Beta] + \[ScriptL]^2)|>
];


(* ::Section:: *)
(*Mino-time phases*)


(* ::Text:: *)
(*{whole turns, the phase reduced to [0, 2 \[Pi])}. The conversions work on the reduced phase, which is symmetric about \[Pi], and add the turns back.*)


reducedPhase[\[Psi]_] := With[{m = Mod[\[Psi], 2 \[Pi]]}, {\[Psi] - m, m}];


(* ::Text:: *)
(*qr from \[Psi]r. sin^2 of the Jacobi amplitude is ((r - r2)(r1 - r3))/((r - r3)(r1 - r2)), with (r - r2)/(r1 - r2) = sin^2(\[Psi]r/2)(1 - e)/(1 + e cos \[Psi]r), which does not cancel at small e. At e = 0, qr = \[Psi]r.*)


minoRadialPhase[g_Association, \[Psi]r_] := Module[{bulk, \[Psi], e, r, s2, q},
	{bulk, \[Psi]} = reducedPhase[\[Psi]r];
	e = g["e"];
	r = g["p"]/(1 + e Cos[\[Psi]]);
	s2 = Min[1, Sin[\[Psi]/2]^2 (1 - e)/(1 + e Cos[\[Psi]]) (g["r1"] - g["r3"])/(r - g["r3"])];
	q = \[Pi] EllipticF[ArcSin[Sqrt[s2]], g["kr"]]/EllipticK[g["kr"]];
	bulk + If[\[Psi] <= \[Pi], q, 2 \[Pi] - q]
];


(* ::Text:: *)
(*q\[Theta] from \[Psi]\[Theta], with cos \[Theta] = Sqrt[1 - x^2] cos \[Psi]\[Theta]. At x = \[PlusMinus]1 it gives q\[Theta] = \[Psi]\[Theta].*)


minoPolarPhase[g_Association, \[Psi]\[Theta]_] := Module[{bulk, \[Psi], q},
	{bulk, \[Psi]} = reducedPhase[\[Psi]\[Theta]];
	q = \[Pi]/2 - \[Pi] EllipticF[ArcSin[Cos[\[Psi]]], g["kz"]]/(2 EllipticK[g["kz"]]);
	bulk + If[\[Psi] <= \[Pi], q, 2 \[Pi] - q]
];


(* ::Section:: *)
(*Oscillating parts of t and \[Phi]*)


(* ::Text:: *)
(*{\[CapitalDelta]t, \[CapitalDelta]\[Phi]}, the oscillating parts of t(\[Lambda]) and \[Phi](\[Lambda]) along the geodesic. They are periodic in qr and q\[Theta], so the phases are reduced mod 2 \[Pi] first, which stops the cancellation in each bracket growing as the phases wind.*)


oscillatingTimeAndAzimuth[g_Association, qrIn_, qzIn_] := Module[
	{a, En, L, r1, r2, r3, r4, rp, rm, kr, kz, zp, zm2, qr, qz, hr, hp, hm, ampR, ampZ, radial, tr, tz, \[Phi]r, \[Phi]z},
	{a, En, L, r1, r2, r3, r4, rp, rm, kr, kz, zp, zm2} =
		Lookup[g, {"a", "En", "L", "r1", "r2", "r3", "r4", "rp", "rm", "kr", "kz", "zp", "zm2"}];
	qr = Mod[qrIn, 2 \[Pi]];
	qz = Mod[qzIn, 2 \[Pi]];
	hr = (r1 - r2)/(r1 - r3);
	hp = hr (r3 - rp)/(r2 - rp);
	hm = hr (r3 - rm)/(r2 - rm);
	ampR = JacobiAmplitude[EllipticK[kr] qr/\[Pi], kr];
	ampZ = JacobiAmplitude[2 EllipticK[kz] (qz + \[Pi]/2)/\[Pi], kz];
	(* The oscillating part of an integral of the third kind over the radial motion *)
	radial[h_] := EllipticPi[h, kr] qr/\[Pi] - EllipticPi[h, ampR, kr];
	tr = -En/Sqrt[(1 - En^2) (r1 - r3) (r2 - r4)] (
		4 (r2 - r3) radial[hr] -
		4 (r2 - r3)/(rp - rm) (
			-(-2 a^2 + rm (4 - a L/En)) radial[hm]/((r2 - rm) (r3 - rm)) +
			(-2 a^2 + rp (4 - a L/En)) radial[hp]/((r2 - rp) (r3 - rp))) +
		(r2 - r3) (r1 + r2 + r3 + r4) radial[hr] +
		(r1 - r3) (r2 - r4) (EllipticE[kr] qr/\[Pi] - EllipticE[ampR, kr] +
			hr Sin[ampR] Cos[ampR] Sqrt[1 - kr Sin[ampR]^2]/(1 - hr Sin[ampR]^2)));
	tz = En zp (2 (qz + \[Pi]/2) EllipticE[kz]/\[Pi] - EllipticE[ampZ, kz])/(1 - En^2);
	\[Phi]r = 2 a En (
		-(2 rm - a L/En) (r2 - r3) radial[hm]/((r2 - rm) (r3 - rm)) +
		(2 rp - a L/En) (r2 - r3) radial[hp]/((r2 - rp) (r3 - rp)))/
		((rp - rm) Sqrt[(1 - En^2) (r1 - r3) (r2 - r4)]);
	\[Phi]z = -L/zp (2 (qz + \[Pi]/2) EllipticPi[zm2, kz]/\[Pi] - EllipticPi[zm2, ampZ, kz]);
	{tr + tz, \[Phi]r + \[Phi]z}
];


(* ::Section:: *)
(*Frequencies and angles*)


(* ::Text:: *)
(*{\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]} from KerrGeoFrequencies, whose keys are display forms, so its values are taken in order. The last value is cached, as the three frequencies and the angles are evaluated at the same elements.*)


boyerLindquistFrequenciesCache = None;
BoyerLindquistFrequencies[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ] := memoLast[BoyerLindquistFrequencies,
	boyerLindquistFrequenciesCache, {a, p, e, x}, Values[KerrGeoFrequencies[a, p, e, x]]];


(* ::Text:: *)
(*{\[CapitalPhi]r, \[CapitalPhi]\[Theta], \[CapitalPhi]\[Phi]} for spin a, elements p, e, x, phases \[Psi]r, \[Psi]\[Theta] and azimuth \[Phi]. An undefined phase (\[Psi]r at e = 0, \[Psi]\[Theta] at x = \[PlusMinus]1) may take any value: its own angle is then meaningless, but the others are unaffected.*)


boyerLindquistAnglesCache = None;
BoyerLindquistAngles[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ, \[Psi]r_?NumericQ, \[Psi]\[Theta]_?NumericQ, \[Phi]_?NumericQ] :=
	memoLast[BoyerLindquistAngles, boyerLindquistAnglesCache, {a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi]},
		Module[{g, qr, qz, \[CapitalDelta]t, \[CapitalDelta]\[Phi], \[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]},
			g = angleGeometry[a, p, e, x];
			qr = minoRadialPhase[g, \[Psi]r];
			qz = minoPolarPhase[g, \[Psi]\[Theta]];
			{\[CapitalDelta]t, \[CapitalDelta]\[Phi]} = oscillatingTimeAndAzimuth[g, qr, qz];
			{\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]} = BoyerLindquistFrequencies[a, p, e, x];
			{qr + \[CapitalOmega]r \[CapitalDelta]t, qz + \[CapitalOmega]\[Theta] \[CapitalDelta]t, \[Phi] - \[CapitalDelta]\[Phi] + \[CapitalOmega]\[Phi] \[CapitalDelta]t}]];


(* ::Text:: *)
(*Single components, which only evaluate for numbers, so that a symbolic time (from NIntegrate or Plot) leaves them unevaluated.*)


BoyerLindquistFrequency[i_Integer, a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ] := BoyerLindquistFrequencies[a, p, e, x][[i]];
BoyerLindquistAngle[i_Integer, args__?NumericQ] := BoyerLindquistAngles[args][[i]];


(* ::Section:: *)
(*A continuous radial phase*)


(* ::Text:: *)
(*\[Alpha]p and \[Beta]p give \[Psi]r only up to whole turns. The turns are counted from samples at the solver's steps and interpolated linearly; between samples \[Psi]r is the value nearest that interpolation. The result is a listable function of the time variable.*)


(* ::Text:: *)
(*Near e = 0, \[Psi]r can turn by nearly \[Pi] within a step. A step that changes \[Psi]r by more than \[Pi]/2 is halved, up to 50 times, until every change is smaller. A change that stays larger, or that spans a sample within round-off of e = 0, is taken in the sense in which \[Psi]r turns, the sign of \[Beta]p \[Alpha]p' - \[Alpha]p \[Beta]p'. Samples within round-off of e = 0 have no direction and are skipped.*)


(* ::Text:: *)
(*The count starts from \[Psi]r0. If e = 0 at the start, where \[Psi]r0 is undefined, it starts from the first resolved phase, taken in [-3\[Pi]/4, 5\[Pi]/4). A circular orbit becomes eccentric at \[Psi]r = 0 or \[Pi] under a tangential force and at \[PlusMinus]\[Pi]/2 under a radial one, so this keeps all four starts away from the branch cut.*)


wrapAngle[d_] := d - 2 \[Pi] Round[d/(2 \[Pi])];

continuousRadialPhase[\[Alpha]p_, \[Beta]p_, \[Psi]r0_] := Module[
	{grid, floor, d\[Alpha]p, d\[Beta]p, resolvedQ, phase, sense, turn, refine, \[Alpha]s, \[Beta]s, resolved, points, start, pieces, knots, reference},
	grid = Flatten[\[Alpha]p["Grid"]];
	floor = 10^(2 - Replace[Precision[Last[grid]], MachinePrecision -> $MachinePrecision]);
	{d\[Alpha]p, d\[Beta]p} = Derivative[1] /@ {\[Alpha]p, \[Beta]p};
	resolvedQ[u_] := \[Alpha]p[u]^2 + \[Beta]p[u]^2 > floor^2;
	phase[u_] := ArcTan[\[Beta]p[u], \[Alpha]p[u]];
	(* The sign of d\[Psi]r/du *)
	sense[u_] := Sign[\[Beta]p[u] d\[Alpha]p[u] - \[Alpha]p[u] d\[Beta]p[u]];
	(* The change d, or d \[PlusMinus] 2\[Pi] if that turns in the sense s instead *)
	turn[d_, s_] := Which[s > 0 && d < 0, d + 2 \[Pi], s < 0 && d > 0, d - 2 \[Pi], True, d];
	(* The changes from {u1, \[Psi]1} to {u2, \[Psi]2}, each with the time at which its piece ends *)
	refine[{u1_, \[Psi]1_}, {u2_, \[Psi]2_}, depth_] := With[{d = wrapAngle[\[Psi]2 - \[Psi]1], um = (u1 + u2)/2},
		Which[
			Abs[d] <= \[Pi]/2, {{u2, d}},
			depth == 0 || !(u1 < um < u2) || !resolvedQ[um], {{u2, turn[d, Sign[sense[u1] + sense[u2]]]}},
			True, With[{middle = {um, phase[um]}}, Join[refine[{u1, \[Psi]1}, middle, depth - 1], refine[middle, {u2, \[Psi]2}, depth - 1]]]]];

	{\[Alpha]s, \[Beta]s} = {\[Alpha]p[grid], \[Beta]p[grid]};
	resolved = Thread[\[Alpha]s^2 + \[Beta]s^2 > floor^2];
	(* e stays at 0 *)
	If[FreeQ[resolved, True], Return[Function[{u}, \[Psi]r0 + wrapAngle[phaseAngle[\[Alpha]p[u], \[Beta]p[u]] - \[Psi]r0], {Listable}]]];
	points = Transpose[{Pick[grid, resolved], MapThread[ArcTan, Pick[#, resolved] & /@ {\[Beta]s, \[Alpha]s}]}];
	start = If[First[resolved], \[Psi]r0 + wrapAngle[points[[1, 2]] - \[Psi]r0], Mod[points[[1, 2]], 2 \[Pi], -3 \[Pi]/4]];
	pieces = Join @@ MapThread[refine[#1, #2, 50] &, {Most[points], Rest[points]}];
	knots = Transpose[{Prepend[pieces[[All, 1]], points[[1, 1]]], FoldList[Plus, start, pieces[[All, 2]]]}];
	(* Before the first resolved sample and after the last, the count is constant *)
	If[knots[[1, 1]] > First[grid], PrependTo[knots, {First[grid], start}]];
	If[knots[[-1, 1]] < Last[grid], AppendTo[knots, {Last[grid], knots[[-1, 2]]}]];
	reference = Interpolation[knots, InterpolationOrder -> 1];
	Function[{u}, reference[u] + wrapAngle[phaseAngle[\[Alpha]p[u], \[Beta]p[u]] - reference[u]], {Listable}]
];
