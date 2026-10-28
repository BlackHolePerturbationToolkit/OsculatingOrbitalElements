(* ::Package:: *)

(* ::Title:: *)
(*Frequencies and Boyer-Lindquist action angles*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Text:: *)
(*The Boyer-Lindquist frequencies (\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]) of a geodesic, and the conversion from its quasi-Keplerian phases (\[Psi]r, \[Psi]\[Theta], \[Phi]) to its Boyer-Lindquist action angles (\[CapitalPhi]r, \[CapitalPhi]\[Theta], \[CapitalPhi]\[Phi]), which advance at the constant rates \[CapitalOmega]r, \[CapitalOmega]\[Theta] and \[CapitalOmega]\[Phi] in coordinate time. The conversion follows P. Lynch and O. Burke, "A note on the conversion of orbital angles for extreme mass ratio inspirals", Class. Quantum Grav. 42, 167001 (2025), arXiv:2411.04955, and its code (github.com/Philip-Lynch/KerrOrbitalAngleConversion), with the Fujita-Hikida solution for the geodesic:*)
(*- the Mino-time phases qr and q\[Theta] follow from \[Psi]r and \[Psi]\[Theta]. All four are 0 at the same points: periapsis, and where cos \[Theta] is largest;*)
(*- \[CapitalPhi]r = qr + \[CapitalOmega]r \[CapitalDelta]t, \[CapitalPhi]\[Theta] = q\[Theta] + \[CapitalOmega]\[Theta] \[CapitalDelta]t and \[CapitalPhi]\[Phi] = \[Phi] - \[CapitalDelta]\[Phi] + \[CapitalOmega]\[Phi] \[CapitalDelta]t, where \[CapitalDelta]t(qr, q\[Theta]) and \[CapitalDelta]\[Phi](qr, q\[Theta]) are the oscillating parts of t and \[Phi] along the geodesic, zero at qr = q\[Theta] = 0.*)
(*Along a geodesic, then, each \[CapitalPhi] is \[CapitalOmega] t plus a constant. The angles are continuous in the phases: a phase that has wound n times gives an angle that has too.*)
(*The geodesic's constants come from RegularEnergy and RegularLOverX (Utilities.wl), and the frequencies from KerrGeoFrequencies. In the regular constants Q = (1 - x^2)(\[Beta] + \[ScriptL]^2), and the polar root of the code, zp, is Sqrt[\[Beta] + \[ScriptL]^2], so the polar quantities stay finite at a = 0. The conversion needs no special case at e = 0 or x = \[PlusMinus]1, where the radial or polar oscillations vanish; there the phase that is undefined can be any value. It does need x \[NotEqual] 0, where \[CapitalDelta]\[Phi] is L times a divergent integral.*)


(* ::Section:: *)
(*The geodesic*)


(* ::Text:: *)
(*The quantities the conversion needs, for spin a and elements p, e, x: the constants En and L, the radial roots r1 > r2 > r3 > r4 (r1 and r2 the turning points), the horizons, and the elliptic parameters kr and kz, in Mathematica's convention (the parameter m = k^2).*)


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
(*The phase \[Psi] reduced to [0, 2 \[Pi]), and the number of whole turns taken off. The conversions work on the reduced phase, which is symmetric about \[Pi], and add the turns back, so they are continuous.*)


reducedPhase[\[Psi]_] := With[{m = Mod[\[Psi], 2 \[Pi]]}, {\[Psi] - m, m}];


(* ::Text:: *)
(*qr from \[Psi]r. With r = p/(1 + e cos \[Psi]r), sin^2 of the Jacobi amplitude is ((r - r2)(r1 - r3))/((r - r3)(r1 - r2)), and (r - r2)/(r1 - r2) = sin^2(\[Psi]r/2)(1 - e)/(1 + e cos \[Psi]r), which avoids the cancellation in r - r2 and r1 - r2 at small e. At e = 0 it gives qr = \[Psi]r.*)


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
(*\[CapitalDelta]t and \[CapitalDelta]\[Phi], the oscillating parts of t(\[Lambda]) and \[Phi](\[Lambda]) along the geodesic, as functions of the Mino-time phases: {\[CapitalDelta]t, \[CapitalDelta]\[Phi]}. They are periodic in qr and q\[Theta], so the phases are reduced to [0, 2 \[Pi]) first, which keeps the cancellation in each bracket, a multiple of the phase minus an incomplete integral, from growing as the phases wind.*)


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
(*The Boyer-Lindquist frequencies {\[CapitalOmega]r, \[CapitalOmega]\[Theta], \[CapitalOmega]\[Phi]} from KerrGeoFrequencies, whose keys are display forms, so its values are taken in order. Plotting all three, or the angles, evaluates them at the same elements, so the last value is kept.*)


boyerLindquistFrequenciesCache = None;
BoyerLindquistFrequencies[a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ] := memoLast[BoyerLindquistFrequencies,
	boyerLindquistFrequenciesCache, {a, p, e, x}, Values[KerrGeoFrequencies[a, p, e, x]]];


(* ::Text:: *)
(*The Boyer-Lindquist action angles {\[CapitalPhi]r, \[CapitalPhi]\[Theta], \[CapitalPhi]\[Phi]} of the geodesic with spin a and elements p, e, x, at the phases \[Psi]r and \[Psi]\[Theta] and azimuth \[Phi]. A phase that is undefined (\[Psi]r at e = 0, \[Psi]\[Theta] at x = \[PlusMinus]1) can be given as any value; the angle it gives is then meaningless, but the others are not affected.*)


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
(*Single components, which only evaluate for numbers. The inspiral's outputs use them, so that a symbolic time, as NIntegrate or Plot may give, leaves them unevaluated rather than taking a part of an unevaluated call.*)


BoyerLindquistFrequency[i_Integer, a_?NumericQ, p_?NumericQ, e_?NumericQ, x_?NumericQ] := BoyerLindquistFrequencies[a, p, e, x][[i]];
BoyerLindquistAngle[i_Integer, args__?NumericQ] := BoyerLindquistAngles[args][[i]];


(* ::Section:: *)
(*A continuous radial phase*)


(* ::Text:: *)
(*The regular solver integrates \[Alpha]p = e sin \[Psi]r and \[Beta]p = e cos \[Psi]r, which give \[Psi]r only up to whole turns. This counts the turns at the solver's steps, where \[Psi]r changes by much less than \[Pi] from one step to the next, starting from the initial phase \[Psi]r0, and interpolates the result linearly. Between steps \[Psi]r is the value nearest that interpolation, so it is continuous, and the same function of the time variable as the solution. The result is a listable function of the time variable.*)


wrapAngle[d_] := d - 2 \[Pi] Round[d/(2 \[Pi])];

continuousRadialPhase[\[Alpha]p_, \[Beta]p_, \[Psi]r0_] := Module[{grid, phases, turns, reference},
	grid = Flatten[\[Alpha]p["Grid"]];
	phases = MapThread[phaseAngle, {\[Alpha]p[grid], \[Beta]p[grid]}];
	turns = FoldList[#1 + wrapAngle[#2[[2]] - #2[[1]]] &, \[Psi]r0 + wrapAngle[First[phases] - \[Psi]r0], Partition[phases, 2, 1]];
	reference = Interpolation[Transpose[{grid, turns}], InterpolationOrder -> 1];
	Function[{u}, reference[u] + wrapAngle[phaseAngle[\[Alpha]p[u], \[Beta]p[u]] - reference[u]], {Listable}]
];
