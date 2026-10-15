(* ::Package:: *)

(* ::Title:: *)
(*The regular polar formulation (on hold)*)


(* ::Text:: *)
(*ON HOLD: not used by the current interface, OsculatingInspiral. Its regular solver integrates x and the polar phase \[Psi]\[Theta], and treats equatorial orbits (x = \[PlusMinus]1) as a special case (Solvers/KerrPEX.wl). This file keeps the parts of the regular polar formulation, in which (\[Alpha]\[Theta], \[Beta]\[Theta], x) = (Sqrt[zm] Sin[\[Psi]\[Theta]], Sqrt[zm] Cos[\[Psi]\[Theta]], x) is a unit vector integrated in place of (x, \[Psi]\[Theta]), until the formulation is settled; it may change. OsculatingInspiral used it at commit 7e644fe, whose regularSystem shows how the pieces fit, and Notes/RegularFormulation.md derives it. Nothing calls these functions, and no test covers them. Kernel/OsculatingOrbitalElements.wl loads this file last, into the package's private context.*)


(* ::Section:: *)
(*Geometry*)


(* ::Text:: *)
(*KerrOrbitGeometry (Utilities.wl) with the polar position given by the components \[Alpha]\[Theta] and \[Beta]\[Theta] = cos \[Theta], rather than by \[Psi]\[Theta]. Then \[Beta] zp = Q + L^2 + \[Beta] x^2, which is regular everywhere. The result has the keys of KerrOrbitGeometry, with "\[Alpha]\[Theta]" and "\[Beta]\[Theta]" in place of "\[Psi]\[Theta]".*)


polarComponentGeometry[a_, {En_, L_, Q_}, {r_, x_, \[Alpha]\[Theta]_, \[Beta]\[Theta]_}, drd\[Lambda]_] := Module[
	{K, \[Beta], zm, \[Beta]zp, z, \[Theta], \[CapitalSigma], \[CapitalDelta], \[Omega], F, ur},
	K = Q + (L - a En)^2;
	\[Beta] = a^2 (1 - En^2);
	zm = 1 - x^2;
	\[Beta]zp = Q + L^2 + \[Beta] x^2;
	z = \[Beta]\[Theta]^2;
	\[Theta] = ArcCos[\[Beta]\[Theta]];
	\[CapitalSigma] = r^2 + a^2 z;
	\[CapitalDelta] = r^2 + a^2 - 2 r;
	\[Omega] = Sqrt[r^2 + a^2];
	F = \[Omega]^2 En - a L;
	ur = drd\[Lambda]/\[CapitalDelta];
	<|"a" -> a, "En" -> En, "L" -> L, "Q" -> Q, "r" -> r, "x" -> x, "\[Alpha]\[Theta]" -> \[Alpha]\[Theta], "\[Beta]\[Theta]" -> \[Beta]\[Theta],
		"K" -> K, "\[Beta]" -> \[Beta], "zm" -> zm, "\[Beta]zp" -> \[Beta]zp, "z" -> z, "\[Theta]" -> \[Theta],
		"\[CapitalSigma]" -> \[CapitalSigma], "\[CapitalDelta]" -> \[CapitalDelta], "\[Omega]" -> \[Omega], "F" -> F,
		"H" -> L - a En x^2,
		"G" -> \[Omega]^2 L/Sin[\[Theta]] - a^3 x^2 Sin[\[Theta]] En,
		"ur" -> ur,
		"u\[Theta]" -> \[Alpha]\[Theta]/Sin[\[Theta]] Sqrt[\[Beta]zp - \[Beta] z],
		"un" -> -(F + \[CapitalDelta] ur)/(2 \[CapitalSigma]),
		"dtd\[Lambda]" -> En (\[Omega]^4/\[CapitalDelta] - a^2 (1 - z)) + a L (1 - \[Omega]^2/\[CapitalDelta]),
		"d\[Phi]d\[Lambda]" -> L/(1 - z) + a En (\[Omega]^2/\[CapitalDelta] - 1) - a^2 L/\[CapitalDelta]|>
];


(* ::Section:: *)
(*Equations*)


(* ::Text:: *)
(*The rates with Mino time of the polar components \[Alpha]\[Theta], \[Beta]\[Theta] and x, from the geometry (polarComponentGeometry), \[ScriptL] = L/x and the covariant force. (\[Alpha]\[Theta], \[Beta]\[Theta], x) is a unit vector, which these equations keep at unit length, and they are regular for equatorial and polar orbits. They write the rate of Q in its polar form, which assumes the force is orthogonal to the velocity.*)


polarComponentRates[g_Association, \[ScriptL]_, {at_, ar_, a\[Theta]_, a\[Phi]_}] := Module[
  {a, En, L, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Beta], \[Theta], \[CapitalSigma], W, denominator},
  {a, En, L, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Beta], \[Theta], \[CapitalSigma]} =
    Lookup[g, {"a", "En", "L", "x", "\[Alpha]\[Theta]", "\[Beta]\[Theta]", "\[Beta]", "\[Theta]", "\[CapitalSigma]"}];
  (* W = d\[Theta]/d\[Lambda] up to sign, and \[Beta](zp - zm) *)
  W = Sqrt[g["\[Beta]zp"] - \[Beta] \[Beta]\[Theta]^2];
  denominator = g["\[Beta]zp"] - \[Beta] g["zm"];
  <|
    "\[Alpha]\[Theta]" -> \[Beta]\[Theta] W +
      \[CapitalSigma] (x^2 W a\[Theta]/Sin[\[Theta]] - \[Alpha]\[Theta] (a^2 En x^2 at + L a\[Phi]/Sin[\[Theta]]^2))/denominator,
    "\[Beta]\[Theta]" -> -\[Alpha]\[Theta] W,
    "x" -> -\[CapitalSigma] \[Alpha]\[Theta] (x W a\[Theta]/Sin[\[Theta]] - \[Alpha]\[Theta] (a^2 En x at + \[ScriptL] a\[Phi]/Sin[\[Theta]]^2))/denominator
  |>
];


(* ::Section:: *)
(*Fluxes*)


(* ::Text:: *)
(*A flux's rates of the polar components, from its rate of x, dx/dt. The flux changes x but not \[Psi]\[Theta], so d\[Alpha]\[Theta]/dt = ((dzm/dt)/(2 zm)) \[Alpha]\[Theta] and d\[Beta]\[Theta]/dt = ((dzm/dt)/(2 zm)) \[Beta]\[Theta], with (dzm/dt)/(2 zm) = -x (dx/dt)/zm. The ratio is finite for a physical flux, as dx/dt ~ zm near x = \[PlusMinus]1. On an equatorial orbit (\[Alpha]\[Theta] = \[Beta]\[Theta] = 0) it is 0/0, and the contribution is 0, as is that to x: the flux keeps the orbit equatorial. zm is taken as \[Alpha]\[Theta]^2 + \[Beta]\[Theta]^2, which unlike 1 - x^2 does not lose digits near the equator. The result is {dx/dt, d\[Alpha]\[Theta]/dt, d\[Beta]\[Theta]/dt}.*)


polarComponentFluxRates[x_, \[Alpha]\[Theta]_, \[Beta]\[Theta]_, dx_] := Module[{zm, zRatio},
	zm = \[Alpha]\[Theta]^2 + \[Beta]\[Theta]^2;
	zRatio = If[zm == 0, 0, -x dx/zm];
	{If[zm == 0, 0, dx], zRatio \[Alpha]\[Theta], zRatio \[Beta]\[Theta]}
];
