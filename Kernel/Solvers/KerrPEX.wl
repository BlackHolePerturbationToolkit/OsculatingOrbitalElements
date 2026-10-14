(* ::Package:: *)

(* ::Title:: *)
(*Kerr solvers in p, e, x: the regular solver behind OsculatingInspiral, and the earlier pex and REG solvers*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Systems*)


(* ::Text:: *)
(*Each builder returns the system for IntegrateSystem, with "Variable" and "Outputs" (see RunSolver in Interface.wl). Both build on the shared orbit geometry and rate maps in Utilities.wl. What is particular to each is how it writes the radial motion, and the equations for its radial variables.*)


(* ::Subsubsection:: *)
(*Polar phase*)


(* ::Text:: *)
(*The rate of \[Psi]\[Theta] with Mino time, which both solvers use, from the geometry and the force's null-tetrad components. It divides by Sqrt[zm], so it is singular for equatorial orbits. The regular polar formulation is to replace it (see the design document).*)


polarPhaseRate[g_Association, {an_, A1_, A2_, A3_}] := Module[{a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]},
  {a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]} = Lookup[g, {"a", "\[Psi]\[Theta]", "\[Beta]", "zm", "\[Beta]zp", "\[Theta]"}];
  Sqrt[\[Beta]zp - \[Beta] g["z"]] (
      1 + (1 - zm) g["\[CapitalSigma]"] A1 Cos[\[Psi]\[Theta]]/(Sqrt[zm] (\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["H"] a g["\[CapitalDelta]"] (A3 - 2 g["ur"] an)/(2 (\[Beta]zp - \[Beta] zm) g["un"]) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["G"] A2/(\[Beta]zp - \[Beta] zm)
];


(* ::Text:: *)
(*The regular solver's polar equations: the rates with Mino time of the polar components \[Alpha]\[Theta] = Sqrt[zm] Sin[\[Psi]\[Theta]], \[Beta]\[Theta] = Sqrt[zm] Cos[\[Psi]\[Theta]] = cos \[Theta], and x, from the geometry (in its polar-component form), \[ScriptL] = L/x and the covariant force. (\[Alpha]\[Theta], \[Beta]\[Theta], x) is a unit vector, which these equations keep at unit length, and they are regular for equatorial and polar orbits. The derivation is in the design document; it writes the rate of Q in its polar form, which assumes the force is orthogonal to the velocity.*)


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


(* ::Subsubsection:: *)
(*p, e, x equations (GenericKerrpexBL)*)


pexSystem[\[Eta]_, a_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_}, drivers_List, settings_Association] := Module[
  {
    minoQ, s, smallEQ, equatorialQ, equatorialRules, smallERules, initialConditions, unknowns, EoM, events, outputs,
    p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, \[Lambda], \[Alpha]p, \[Beta]p,
    En, L, Q, K, r, J, P, geometry, z, \[Theta], \[CapitalSigma], un,
    state, at, ar, a\[Theta], a\[Phi], an, A1, A2, A3, elementRates,
    r1, r2, \[CapitalSigma]1, \[CapitalSigma]2, \[CapitalDelta]1, \[CapitalDelta]2, F1, F2, \[Kappa]1, \[Kappa]2, Q1, Q2,
    C, \[ScriptCapitalD], \[Epsilon],
    dpd\[Lambda], ded\[Lambda], dxd\[Lambda], d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda],
    dtd\[Lambda], toS, icRules, forceAtStart, minimumP, pMinQ, bufferQ, deltaPSep, pSep,
    psol, esol, xsol, \[Psi]rsol, \[Psi]\[Theta]sol, \[Alpha]psol, \[Beta]psol, tsol, \[Phi]sol, rsol
  },

  minoQ = settings["Mino"];
  s = If[minoQ, \[Lambda], t];
  (* At small e, e and \[Psi]r are replaced by \[Alpha]p = e Sin[\[Psi]r] and \[Beta]p = e Cos[\[Psi]r]. *)
  smallEQ = e0 < 100 \[Eta];
  smallERules = If[smallEQ, {e[s] -> Sqrt[\[Alpha]p[s]^2 + \[Beta]p[s]^2], \[Psi]r[s] -> ArcTan[\[Beta]p[s], \[Alpha]p[s]]}, {}];
  (* Equatorial orbits (x = \[PlusMinus]1): x is held fixed and the polar equations are dropped. x is kept as an exact \[PlusMinus]1, since KerrGeoSeparatrix does not evaluate at x = \[PlusMinus]1. when a \[NotEqual] 0. *)
  equatorialQ = TrueQ[Abs[x0] == 1];
  equatorialRules = If[equatorialQ, {x[s] -> Sign[x0], \[Psi]\[Theta][s] -> 0}, {}];

  initialConditions = {
    p[0] == p0,
    If[smallEQ, \[Alpha]p[0] == e0 Sin[\[Psi]r0], e[0] == e0],
    If[equatorialQ, Nothing, x[0] == x0],
    If[smallEQ, \[Beta]p[0] == e0 Cos[\[Psi]r0], \[Psi]r[0] == \[Psi]r0],
    If[equatorialQ, Nothing, \[Psi]\[Theta][0] == \[Psi]\[Theta]0],
    \[Phi][0] == 0,
    If[minoQ, t[0] == 0, Nothing]
  };

  (* The osculating geodesic: its constants of motion, and its radial motion in terms of e and \[Psi]r. P is d\[Psi]r/d\[Lambda]. *)
  {En, L, Q} = {
    Energy[a, p[s], e[s], x[s]],
    AngularMomentum[a, p[s], e[s], x[s]],
    CarterConstant[a, p[s], e[s], x[s]]
  };
  r = p[s]/(1 + e[s] Cos[\[Psi]r[s]]);
  J = (1 - En^2) (1 - e[s]^2) + 2 (1 - En^2 - (1 - e[s]^2)/p[s]) (1 + e[s] Cos[\[Psi]r[s]]) +
    ((1 - En^2) (3 + e[s]^2)/(1 - e[s]^2) - 4/p[s] + (a^2 (1 - En^2) + L^2 + Q) (1 - e[s]^2)/p[s]^2) (1 + e[s] Cos[\[Psi]r[s]])^2;
  P = p[s] Sqrt[J]/(1 - e[s]^2);
  geometry = KerrOrbitGeometry[a, {En, L, Q}, {r, x[s], \[Psi]\[Theta][s]},
    p[s] e[s] Sin[\[Psi]r[s]] P/(1 + e[s] Cos[\[Psi]r[s]])^2];
  {K, z, \[Theta], \[CapitalSigma], un} = Lookup[geometry, {"K", "z", "\[Theta]", "\[CapitalSigma]", "un"}];

  (* The total force, per unit \[Eta] from each driver, and the rates of the slowly varying elements *)
  state = Join[<|"a" -> a, "p" -> p[s], "e" -> e[s], "x" -> x[s], "\[Psi]r" -> \[Psi]r[s], "\[Psi]\[Theta]" -> \[Psi]\[Theta][s]|>, geometry];
  {at, ar, a\[Theta], a\[Phi]} = TotalForce[drivers, state, \[Eta]];
  elementRates = OrbitalElementRates[a, {p[s], e[s]^2, x[s]}, {En, L, Q},
    Lookup[ConstantsOfMotionRates[geometry, {at, ar, a\[Theta], a\[Phi]}], {"En", "L", "Q"}]];
  dpd\[Lambda] = elementRates["p"];
  ded\[Lambda] = elementRates["e2"]/(2 e[s]);
  dxd\[Lambda] = elementRates["x"];

  (* The phases. The radial phase's equation uses these quantities at the turning points r1 and r2. *)
  {an, A1, A2, A3} = NullTetradForce[geometry, {at, ar, a\[Theta], a\[Phi]}];
  r1 = p[s]/(1 - e[s]);
  r2 = p[s]/(1 + e[s]);
  \[CapitalSigma]1 = r1^2 + a^2 z;
  \[CapitalSigma]2 = r2^2 + a^2 z;
  \[CapitalDelta]1 = r1^2 + a^2 - 2 r1;
  \[CapitalDelta]2 = r2^2 + a^2 - 2 r2;
  F1 = (r1^2 + a^2) En - a L;
  F2 = (r2^2 + a^2) En - a L;
  \[Kappa]1 = 4 En F1 r1 - 2 r1 \[CapitalDelta]1 - 2 (r1 - 1) (r1^2 + K);
  \[Kappa]2 = 4 En F2 r2 - 2 r2 \[CapitalDelta]2 - 2 (r2 - 1) (r2^2 + K);
  Q1 = -2 a L r r1 - a^4 En (r + r1) + a^3 L (r + r1) -
    a^2 En (r^3 + r^2 r1 + r1^3 + r r1 (-2 + r1)) -
    En r r1 (r r1 (r + r1) - 2 (r^2 + r r1 + r1^2)) -
    a^2 (2 a^2 En - 2 En r r1 + a L (-2 + r + r1)) z;
  Q2 = -2 a L r r2 - a^4 En (r + r2) + a^3 L (r + r2) -
    a^2 En (r^3 + r^2 r2 + r2^3 + r r2 (-2 + r2)) -
    En r r2 (r r2 (r + r2) - 2 (r^2 + r r2 + r2^2)) -
    a^2 (2 a^2 En - 2 En r r2 + a L (-2 + r + r2)) z;
  C = Q1 (1 - e[s])/\[Kappa]1 - Q2 (1 + e[s])/\[Kappa]2;
  \[ScriptCapitalD] = (1 - e[s])^2 (1 - Cos[\[Psi]r[s]]) \[CapitalDelta]1/\[Kappa]1 + (1 + e[s])^2 (1 + Cos[\[Psi]r[s]]) \[CapitalDelta]2/\[Kappa]2;
  \[Epsilon] = F1 (1 - e[s]) (r + r1)/\[Kappa]1 - F2 (1 + e[s]) (r + r2)/\[Kappa]2;
  d\[Psi]rd\[Lambda] = P + C A3 Sin[\[Psi]r[s]]/(2 (1 + e[s] Cos[\[Psi]r[s]]) un) +
    \[ScriptCapitalD] \[CapitalSigma] A3 P/(2 (1 + e[s] Cos[\[Psi]r[s]])^2 un) -
    a \[Epsilon] Sin[\[Theta]] Sin[\[Psi]r[s]] A2/(1 + e[s] Cos[\[Psi]r[s]]) +
    P an/(un (1 + e[s] Cos[\[Psi]r[s]])^2) (
      (1 - e[s])^2 (1 - Cos[\[Psi]r[s]]) \[CapitalSigma]1 F1/\[Kappa]1 + (1 + e[s])^2 (1 + Cos[\[Psi]r[s]]) \[CapitalSigma]2 F2/\[Kappa]2);
  d\[Psi]\[Theta]d\[Lambda] = polarPhaseRate[geometry, {an, A1, A2, A3}];

  (* At small e, the rates of \[Alpha]p and \[Beta]p *)
  d\[Alpha]d\[Lambda] = ded\[Lambda] Sin[\[Psi]r[s]] + e[s] d\[Psi]rd\[Lambda] Cos[\[Psi]r[s]];
  d\[Beta]d\[Lambda] = ded\[Lambda] Cos[\[Psi]r[s]] - e[s] d\[Psi]rd\[Lambda] Sin[\[Psi]r[s]];

  (* The equations in the selected time variable *)
  dtd\[Lambda] = geometry["dtd\[Lambda]"];
  toS = If[minoQ, 1, 1/dtd\[Lambda]];
  EoM = {
    D[p[s], s] == toS dpd\[Lambda],
    If[smallEQ, D[\[Alpha]p[s], s] == toS d\[Alpha]d\[Lambda], D[e[s], s] == toS ded\[Lambda]],
    If[equatorialQ, Nothing, D[x[s], s] == toS dxd\[Lambda]],
    If[smallEQ, D[\[Beta]p[s], s] == toS d\[Beta]d\[Lambda], D[\[Psi]r[s], s] == toS d\[Psi]rd\[Lambda]],
    If[equatorialQ, Nothing, D[\[Psi]\[Theta][s], s] == toS d\[Psi]\[Theta]d\[Lambda]],
    D[\[Phi][s], s] == toS geometry["d\[Phi]d\[Lambda]"],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  } /. smallERules /. equatorialRules;

  (* Equatorial orbits only stay in the plane if the force has no \[Theta] component there. *)
  If[equatorialQ,
    icRules = Cases[initialConditions, (f_[0] == v_) :> (f[s] -> v)];
    forceAtStart = Quiet[{at, ar, a\[Theta], a\[Phi]} /. smallERules /. equatorialRules /. icRules];
    If[TrueQ[Abs[forceAtStart[[3]]] > 10^-10 Max[Abs[forceAtStart]]],
      Message[KerrOsculatingOrbitalElements::eqforce, forceAtStart[[3]]/\[Eta]];
      Return[$Failed]]
  ];

  unknowns = {
    p,
    If[smallEQ, \[Alpha]p, e],
    If[equatorialQ, Nothing, x],
    If[smallEQ, \[Beta]p, \[Psi]r],
    If[equatorialQ, Nothing, \[Psi]\[Theta]],
    \[Phi],
    If[minoQ, t, Nothing]
  };

  minimumP = settings["pMin"];
  pMinQ = NumericQ[minimumP];
  (* The separatrix buffer is \[Eta] unless SeparatrixBuffer sets it. With a numeric buffer the e, \[Psi]r branch also stops at the buffer, rather than at the separatrix itself. *)
  bufferQ = NumericQ[settings["SeparatrixBuffer"]];
  deltaPSep = If[bufferQ, settings["SeparatrixBuffer"], \[Eta]];
  pSep[ee_?NumericQ, xx_?NumericQ] := Quiet[KerrGeoSeparatrix[a, ee, xx]];

  events = With[{u = s}, {
    If[pMinQ, stopEvent[p[u] - minimumP == 0, "pMin"], Nothing],
    Which[
      smallEQ, stopEvent[p[u] - pSep[Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2], x[u]] - deltaPSep == 0, "SeparatrixBuffer"],
      bufferQ, stopEvent[p[u] - pSep[e[u], x[u]] - deltaPSep == 0, "SeparatrixBuffer"],
      True, stopEvent[Evaluate[SeparatrixEqELK[a, En, L, K] == -10^-6], "Separatrix"]]
  }] /. equatorialRules;

  (* The result, made from NDSolve's solution *)
  outputs[rules_] := (
    {psol, \[Phi]sol} = {p, \[Phi]} /. rules;
    If[equatorialQ,
      xsol[u_] := Sign[x0];
      \[Psi]\[Theta]sol[u_] := Missing["UndefinedForEquatorialOrbit"],
      {xsol, \[Psi]\[Theta]sol} = {x, \[Psi]\[Theta]} /. rules
    ];
    If[minoQ, tsol = t /. rules, tsol[\[Tau]_?NumericQ] := \[Tau]];
    If[smallEQ,
      {\[Alpha]psol, \[Beta]psol} = {\[Alpha]p, \[Beta]p} /. rules;
      esol[u_?NumericQ] := Sqrt[\[Alpha]psol[u]^2 + \[Beta]psol[u]^2];
      \[Psi]rsol[u_?NumericQ] := ArcTan[\[Beta]psol[u], \[Alpha]psol[u]],
      {esol, \[Psi]rsol} = {e, \[Psi]r} /. rules
    ];
    rsol[u_] := psol[u]/(1 + esol[u] Cos[\[Psi]rsol[u]]);
    KeyTake[
      Join[derivedOutputs[a, psol, esol, xsol, \[Psi]\[Theta]sol, equatorialQ],
        <|"t" -> tsol, "r" -> rsol, "\[Phi]" -> \[Phi]sol, "p" -> psol, "e" -> esol, "x" -> xsol,
          "\[Psi]r" -> \[Psi]rsol, "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol|>],
      $outputKeys]);

  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM], "Events" -> events,
    "Method" -> {"EquationSimplification" -> "Solve"}, "Outputs" -> outputs|>
]


(* ::Subsubsection:: *)
(*Regular p, \[Alpha]p, \[Beta]p equations (GenericKerrREGBL)*)


regSystem[\[Eta]_, a_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_}, drivers_List, settings_Association] := Module[
  {
    minoQ, s, equatorialQ, equatorialRules, initialConditions, unknowns, EoM, events, outputs,
    p, x, \[Alpha]p, \[Beta]p, \[Psi]\[Theta], \[Phi], t, \[Lambda],
    eccentricity, radialPhase, e, e2, w, En, L, Q, K, r, Z, P, geometry, \[CapitalSigma], \[CapitalDelta],
    state, at, ar, a\[Theta], a\[Phi], an, A1, A2, A3, rates, elementRates,
    Zp, Ze2, Z\[Beta], ZK, ZQ,
    dpd\[Lambda], de2d\[Lambda], dxd\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda], d\[Psi]\[Theta]d\[Lambda],
    dtd\[Lambda], toS, icRules, forceAtStart, minimumP, pMinQ, deltaPSep, pSep,
    psol, esol, xsol, \[Alpha]psol, \[Beta]psol, \[Psi]rsol, \[Psi]\[Theta]sol, tsol, \[Phi]sol, rsol
  },

  minoQ = settings["Mino"];
  s = If[minoQ, \[Lambda], t];
  (* Equatorial orbits (x = \[PlusMinus]1): x is held fixed and the polar equations are dropped. x is kept as an exact \[PlusMinus]1, since KerrGeoSeparatrix does not evaluate at x = \[PlusMinus]1. when a \[NotEqual] 0. *)
  equatorialQ = TrueQ[Abs[x0] == 1];
  equatorialRules = If[equatorialQ, {x[s] -> Sign[x0], \[Psi]\[Theta][s] -> 0}, {}];

  initialConditions = {
    p[0] == p0,
    \[Alpha]p[0] == If[TrueQ[e0 == 0], 0, e0 Sin[\[Psi]r0]],
    If[equatorialQ, Nothing, x[0] == x0],
    \[Beta]p[0] == If[TrueQ[e0 == 0], 0, e0 Cos[\[Psi]r0]],
    If[equatorialQ, Nothing, \[Psi]\[Theta][0] == \[Psi]\[Theta]0],
    \[Phi][0] == 0,
    If[minoQ, t[0] == 0, Nothing]
  };

  (* Canonical zero selects the existing circular constants-of-motion formulas. *)
  eccentricity[aa_?NumericQ, bb_?NumericQ] :=
    If[TrueQ[aa == 0 && bb == 0], 0, Sqrt[aa^2 + bb^2]];

  (* Only legacy force callbacks need a phase. At e=0, zero is a callback
     convention; a physical force must be independent of this undefined phase. *)
  radialPhase[aa_?NumericQ, bb_?NumericQ] :=
    If[TrueQ[aa == 0 && bb == 0], 0, ArcTan[bb, aa]];

  (* The osculating geodesic: its constants of motion, and its radial motion in terms of \[Alpha]p and \[Beta]p.
     Z = P^2, where P = d\[Psi]r/d\[Lambda], is polynomial in \[Alpha]p and \[Beta]p. *)
  e2 = \[Alpha]p[s]^2 + \[Beta]p[s]^2;
  e = eccentricity[\[Alpha]p[s], \[Beta]p[s]];
  {En, L, Q} = {
    Energy[a, p[s], e, x[s]],
    AngularMomentum[a, p[s], e, x[s]],
    CarterConstant[a, p[s], e, x[s]]
  };
  K = Q + (L - a En)^2;
  w = 1 + \[Beta]p[s];
  r = p[s]/w;
  Z = p[s] - K (3 - e2 + 2 \[Beta]p[s])/p[s] +
    a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  P = Sqrt[Z];
  geometry = KerrOrbitGeometry[a, {En, L, Q}, {r, x[s], \[Psi]\[Theta][s]}, p[s] \[Alpha]p[s] P/w^2];
  {\[CapitalSigma], \[CapitalDelta]} = Lookup[geometry, {"\[CapitalSigma]", "\[CapitalDelta]"}];

  (* The total force, per unit \[Eta] from each driver, and the rates of the slowly varying elements. Force callbacks get the
     same arguments as in pex; the gas drag driver uses the geometry, so that it never reconstructs the radial phase. *)
  state = Join[<|"a" -> a, "p" -> p[s], "e" -> e, "x" -> x[s], "\[Psi]r" -> radialPhase[\[Alpha]p[s], \[Beta]p[s]],
    "\[Psi]\[Theta]" -> \[Psi]\[Theta][s]|>, geometry];
  {at, ar, a\[Theta], a\[Phi]} = TotalForce[drivers, state, \[Eta]];
  rates = ConstantsOfMotionRates[geometry, {at, ar, a\[Theta], a\[Phi]}];
  elementRates = OrbitalElementRates[a, {p[s], e2, x[s]}, {En, L, Q}, Lookup[rates, {"En", "L", "Q"}]];
  dpd\[Lambda] = elementRates["p"];
  de2d\[Lambda] = elementRates["e2"];
  dxd\[Lambda] = elementRates["x"];

  (* The eccentricity components, whose rates contain no division by e, \[Alpha]p or \[Beta]p. Zp, Ze2, Z\[Beta], ZK and ZQ are
     the partial derivatives of Z with respect to p, e^2, \[Beta]p, K and Q. *)
  Zp = 1 + K (3 - e2 + 2 \[Beta]p[s])/p[s]^2 -
    2 a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^3;
  Ze2 = K/p[s] - a^2 Q/p[s]^2;
  Z\[Beta] = -2 K/p[s] + a^2 Q (4 + 2 \[Beta]p[s])/p[s]^2;
  ZK = -(3 - e2 + 2 \[Beta]p[s])/p[s];
  ZQ = a^2 (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  d\[Beta]d\[Lambda] = w dpd\[Lambda]/p[s] - \[Alpha]p[s] P;
  d\[Alpha]d\[Lambda] = \[Beta]p[s] P + \[CapitalSigma] \[CapitalDelta] w^2 ar/(p[s] P) +
    \[Alpha]p[s] dpd\[Lambda]/p[s] - \[Alpha]p[s]/(2 Z) (
      (Zp + w Z\[Beta]/p[s]) dpd\[Lambda] + Ze2 de2d\[Lambda] + ZK rates["K"] + ZQ rates["Q"]
    );

  (* The polar phase, as in pex *)
  {an, A1, A2, A3} = NullTetradForce[geometry, {at, ar, a\[Theta], a\[Phi]}];
  d\[Psi]\[Theta]d\[Lambda] = polarPhaseRate[geometry, {an, A1, A2, A3}];

  (* The equations in the selected time variable *)
  dtd\[Lambda] = geometry["dtd\[Lambda]"];
  toS = If[minoQ, 1, 1/dtd\[Lambda]];
  EoM = {
    D[p[s], s] == toS dpd\[Lambda],
    D[\[Alpha]p[s], s] == toS d\[Alpha]d\[Lambda],
    If[equatorialQ, Nothing, D[x[s], s] == toS dxd\[Lambda]],
    D[\[Beta]p[s], s] == toS d\[Beta]d\[Lambda],
    If[equatorialQ, Nothing, D[\[Psi]\[Theta][s], s] == toS d\[Psi]\[Theta]d\[Lambda]],
    D[\[Phi][s], s] == toS geometry["d\[Phi]d\[Lambda]"],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  } /. equatorialRules;

  (* Equatorial orbits only stay in the plane if the force has no \[Theta] component there. *)
  If[equatorialQ,
    icRules = Cases[initialConditions, (f_[0] == v_) :> (f[s] -> v)];
    forceAtStart = Quiet[{at, ar, a\[Theta], a\[Phi]} /. equatorialRules /. icRules];
    If[TrueQ[Abs[forceAtStart[[3]]] > 10^-10 Max[Abs[forceAtStart]]],
      Message[KerrOsculatingOrbitalElements::eqforce, forceAtStart[[3]]/\[Eta]];
      Return[$Failed]]
  ];

  unknowns = {p, \[Alpha]p, If[equatorialQ, Nothing, x], \[Beta]p, If[equatorialQ, Nothing, \[Psi]\[Theta]], \[Phi], If[minoQ, t, Nothing]};
  minimumP = settings["pMin"];
  pMinQ = NumericQ[minimumP];
  deltaPSep = If[NumericQ[settings["SeparatrixBuffer"]], settings["SeparatrixBuffer"], \[Eta]];
  pSep[ee_?NumericQ, xx_?NumericQ] := Quiet[KerrGeoSeparatrix[a, ee, xx]];

  (* Use the same separatrix buffer as the component branch of GenericKerrpexBL. *)
  events = With[{u = s}, {
    If[pMinQ, stopEvent[p[u] - minimumP == 0, "pMin"], Nothing],
    stopEvent[p[u] - pSep[eccentricity[\[Alpha]p[u], \[Beta]p[u]], x[u]] - deltaPSep == 0, "SeparatrixBuffer"]
  }] /. equatorialRules;

  (* The result, made from NDSolve's solution *)
  outputs[rules_] := (
    {psol, \[Alpha]psol, \[Beta]psol, \[Phi]sol} = {p, \[Alpha]p, \[Beta]p, \[Phi]} /. rules;
    If[equatorialQ,
      xsol[u_] := Sign[x0];
      \[Psi]\[Theta]sol[u_] := Missing["UndefinedForEquatorialOrbit"],
      {xsol, \[Psi]\[Theta]sol} = {x, \[Psi]\[Theta]} /. rules
    ];
    If[minoQ, tsol = t /. rules, tsol[\[Tau]_?NumericQ] := \[Tau]];
    esol[u_?NumericQ] := If[TrueQ[e0 == 0 && u == 0], 0,
      eccentricity[\[Alpha]psol[u], \[Beta]psol[u]]];
    \[Psi]rsol[u_?NumericQ] := If[TrueQ[esol[u] == 0],
      Missing["UndefinedAtZeroEccentricity"], ArcTan[\[Beta]psol[u], \[Alpha]psol[u]]];
    (* r stays defined when the radial phase is not *)
    rsol[u_] := psol[u]/(1 + \[Beta]psol[u]);
    KeyTake[
      Join[derivedOutputs[a, psol, esol, xsol, \[Psi]\[Theta]sol, equatorialQ],
        <|"t" -> tsol, "r" -> rsol, "\[Phi]" -> \[Phi]sol, "p" -> psol, "e" -> esol, "x" -> xsol,
          "\[Psi]r" -> \[Psi]rsol, "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol, "\[Alpha]p" -> \[Alpha]psol, "\[Beta]p" -> \[Beta]psol|>],
      Join[$outputKeys, {"\[Alpha]p", "\[Beta]p"}]]);

  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM], "Events" -> events,
    "Method" -> {"EquationSimplification" -> "Solve"}, "Outputs" -> outputs|>
]


(* ::Subsubsection:: *)
(*Regular p, e, x equations (OsculatingInspiral)*)


(* ::Text:: *)
(*The default solver. It integrates p, the eccentricity components \[Alpha]p = e Sin[\[Psi]r] and \[Beta]p = e Cos[\[Psi]r] with the REG radial equations, and the polar unit vector (\[Alpha]\[Theta], \[Beta]\[Theta], x). These variables are regular for circular, equatorial and polar orbits, so no orbit needs special treatment, and a force can move an orbit out of the equatorial plane. The initial values are {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0, \[Phi]0}.*)
(*\[Phi] is integrated directly. Near the Boyer-Lindquist axis d\[Phi]/d\[Lambda] ~ L/Sin[\[Theta]]^2, so an orbit with small |x|, which passes Sin[\[Theta]] = |x| from the axis, swings \[Phi] by nearly \[Pi] in a time ~ |x|. NDSolve's default multistep method can step over that swing entirely: at its default goals \[Phi] was wrong by ~0.4 rad for a gas-drag inspiral at x = 0.01, and meaningless at x = 0.001. An 8th-order explicit Runge-Kutta method with goals of 11 or more resolves it down to |x| = 0.001 at least, so that is the default here, with goals 12 (see the Method below, and the AccuracyGoal and PrecisionGoal defaults of OsculatingInspiral). Over 5000M of gas-drag inspiral it is also about 4 times more accurate in r than the earlier solvers' defaults, and about twice as slow. Writing \[Phi] through Sin[\[Theta]] Exp[I \[Phi]] instead was tried and is worse: its equation divides by Sin[\[Theta]] Exp[-I \[Phi]], which amplifies any inconsistency with the polar variables near the axis.*)


regularSystem[\[Epsilon]_, a_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, \[Phi]0_}, drivers_List, settings_Association] := Module[
  {
    minoQ, s, initialConditions, unknowns, EoM, events, outputs,
    p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Phi], t, \[Lambda],
    e2, En, \[ScriptL], L, Q, K, w, r, Z, P, geometry, \[CapitalSigma], \[CapitalDelta], flux,
    state, at, ar, a\[Theta], a\[Phi], rates, elementRates, polarRates,
    Zp, Ze2, Z\[Beta], ZK, ZQ, dpd\[Lambda], de2d\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda],
    dtd\[Lambda], toS, minimumP, pMinQ, deltaPSep, initialPSep
  },

  minoQ = settings["Mino"];
  s = If[minoQ, \[Lambda], t];

  initialConditions = {
    p[0] == p0,
    \[Alpha]p[0] == e0 Sin[\[Psi]r0],
    \[Beta]p[0] == e0 Cos[\[Psi]r0],
    x[0] == x0,
    \[Alpha]\[Theta][0] == Sqrt[1 - x0^2] Sin[\[Psi]\[Theta]0],
    \[Beta]\[Theta][0] == Sqrt[1 - x0^2] Cos[\[Psi]\[Theta]0],
    \[Phi][0] == \[Phi]0,
    If[minoQ, t[0] == 0, Nothing]
  };

  (* The osculating geodesic: its constants of motion, and its radial motion in terms of \[Alpha]p and \[Beta]p, as in REG.
     Z = P^2, where P = d\[Psi]r/d\[Lambda], is polynomial in \[Alpha]p and \[Beta]p. *)
  e2 = \[Alpha]p[s]^2 + \[Beta]p[s]^2;
  En = RegularEnergy[a, p[s], e2, x[s]];
  \[ScriptL] = RegularLOverX[a, p[s], e2, x[s]];
  L = x[s] \[ScriptL];
  Q = (1 - x[s]^2) (a^2 (1 - En^2) + \[ScriptL]^2);
  K = Q + (L - a En)^2;
  w = 1 + \[Beta]p[s];
  r = p[s]/w;
  Z = p[s] - K (3 - e2 + 2 \[Beta]p[s])/p[s] +
    a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  P = Sqrt[Z];
  geometry = KerrOrbitGeometry[a, {En, L, Q}, {r, x[s], \[Alpha]\[Theta][s], \[Beta]\[Theta][s]}, p[s] \[Alpha]p[s] P/w^2];
  {\[CapitalSigma], \[CapitalDelta]} = Lookup[geometry, {"\[CapitalSigma]", "\[CapitalDelta]"}];

  (* The total force. Force models get the phases, which are set to 0 where they are undefined (e = 0, or an
     equatorial orbit); a physical force does not depend on them there. They also get \[Phi] and the coordinate time
     t, so that a force need not be axisymmetric or stationary. *)
  state = Join[<|"a" -> a, "p" -> p[s], "e" -> Sqrt[e2], "x" -> x[s], "\[Psi]r" -> phaseAngle[\[Alpha]p[s], \[Beta]p[s]],
    "\[Psi]\[Theta]" -> phaseAngle[\[Alpha]\[Theta][s], \[Beta]\[Theta][s]], "\[Phi]" -> \[Phi][s], "t" -> If[minoQ, t[s], s],
    "\[Alpha]p" -> \[Alpha]p[s], "\[Beta]p" -> \[Beta]p[s]|>, geometry];
  {at, ar, a\[Theta], a\[Phi]} = TotalForce[drivers, state, \[Epsilon]];

  (* The fluxes' rates of {p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta]}. They change only the slowly varying parts of these
     variables, leaving the phases at their geodesic rates (see fluxVariableRates in FluxModels/FluxModel.wl). They are
     averages with respect to t, so they need coordinate time. *)
  If[minoQ && MemberQ[drivers, KeyValuePattern["Type" -> "Flux"]], Message[OsculatingInspiral::fluxtime]; Return[$Failed]];
  flux = TotalFlux[drivers, state, \[Epsilon]];

  (* p and the eccentricity components, as in REG. Zp, Ze2, Z\[Beta], ZK and ZQ are the partial derivatives of Z with
     respect to p, e^2, \[Beta]p, K and Q. *)
  rates = ConstantsOfMotionRates[geometry, {at, ar, a\[Theta], a\[Phi]}];
  elementRates = OrbitalElementRates[a, {p[s], e2, x[s]}, {En, L, Q}, Lookup[rates, {"En", "L", "Q"}]];
  dpd\[Lambda] = elementRates["p"];
  de2d\[Lambda] = elementRates["e2"];
  Zp = 1 + K (3 - e2 + 2 \[Beta]p[s])/p[s]^2 -
    2 a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^3;
  Ze2 = K/p[s] - a^2 Q/p[s]^2;
  Z\[Beta] = -2 K/p[s] + a^2 Q (4 + 2 \[Beta]p[s])/p[s]^2;
  ZK = -(3 - e2 + 2 \[Beta]p[s])/p[s];
  ZQ = a^2 (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  d\[Beta]d\[Lambda] = w dpd\[Lambda]/p[s] - \[Alpha]p[s] P;
  d\[Alpha]d\[Lambda] = \[Beta]p[s] P + \[CapitalSigma] \[CapitalDelta] w^2 ar/(p[s] P) +
    \[Alpha]p[s] dpd\[Lambda]/p[s] - \[Alpha]p[s]/(2 Z) (
      (Zp + w Z\[Beta]/p[s]) dpd\[Lambda] + Ze2 de2d\[Lambda] + ZK rates["K"] + ZQ rates["Q"]
    );

  (* The polar unit vector *)
  polarRates = polarComponentRates[geometry, \[ScriptL], {at, ar, a\[Theta], a\[Phi]}];

  (* The equations in the selected time variable *)
  dtd\[Lambda] = geometry["dtd\[Lambda]"];
  toS = If[minoQ, 1, 1/dtd\[Lambda]];
  EoM = {
    D[p[s], s] == toS dpd\[Lambda] + flux[[1]],
    D[\[Alpha]p[s], s] == toS d\[Alpha]d\[Lambda] + flux[[2]],
    D[\[Beta]p[s], s] == toS d\[Beta]d\[Lambda] + flux[[3]],
    D[x[s], s] == toS polarRates["x"] + flux[[4]],
    D[\[Alpha]\[Theta][s], s] == toS polarRates["\[Alpha]\[Theta]"] + flux[[5]],
    D[\[Beta]\[Theta][s], s] == toS polarRates["\[Beta]\[Theta]"] + flux[[6]],
    D[\[Phi][s], s] == toS geometry["d\[Phi]d\[Lambda]"],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  };
  unknowns = {p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Phi], If[minoQ, t, Nothing]};

  (* Stop at pMin, or at the separatrix buffer, which is \[Epsilon] unless SeparatrixBuffer sets it *)
  minimumP = settings["pMin"];
  pMinQ = NumericQ[minimumP];
  deltaPSep = If[NumericQ[settings["SeparatrixBuffer"]], settings["SeparatrixBuffer"], \[Epsilon]];
  (* Otherwise the integration starts inside the buffer, and never meets the stopping condition *)
  initialPSep = SeparatrixP[a, e0, x0];
  If[!TrueQ[p0 > initialPSep + deltaPSep],
    Message[OsculatingInspiral::sep, deltaPSep, p0, initialPSep];
    Return[$Failed]];
  (* The events are located to 8 digits. Near the separatrix p changes steeply, and the default, the solver's own goals,
     can be more than the Runge-Kutta method's interpolation within a step supports (NDSolve::evcvmit). *)
  events = With[{u = s, location = "LocationMethod" -> {"Brent", AccuracyGoal -> 8, PrecisionGoal -> 8}}, {
    If[pMinQ, stopEvent[p[u] - minimumP == 0, "pMin", location], Nothing],
    stopEvent[p[u] - SeparatrixP[a, Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2], x[u]] - deltaPSep == 0, "SeparatrixBuffer", location]
  }];

  (* The result, made from NDSolve's solution. In coordinate time, t is the independent variable itself. *)
  outputs[rules_] := regularOutputs[a, Append[{p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Phi]} /. rules,
    If[minoQ, t /. rules, Function[{u}, u, {Listable}]]]];

  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM], "Events" -> events,
    "Method" -> {"ExplicitRungeKutta", "DifferenceOrder" -> 8, "EquationSimplification" -> "Solve"}, "Outputs" -> outputs|>
]


(* ::Text:: *)
(*The angle of the point (\[Beta], \[Alpha]), which is 0 at the origin, where the phase is undefined.*)


phaseAngle[\[Alpha]_?NumericQ, \[Beta]_?NumericQ] := If[TrueQ[\[Alpha] == 0 && \[Beta] == 0], 0, ArcTan[\[Beta], \[Alpha]]];


(* ::Text:: *)
(*The regular solver's outputs, each a listable function of the time variable, from the solutions for p, \[Alpha]p, \[Beta]p, x, \[Alpha]\[Theta], \[Beta]\[Theta], \[Phi] and t. The phases \[Psi]r and \[Psi]\[Theta] lie in (-\[Pi], \[Pi]], and are Missing where they are undefined: \[Psi]r at e = 0, and \[Psi]\[Theta] on an equatorial orbit.*)


regularOutputs[a_, {p_, \[Alpha]p_, \[Beta]p_, x_, \[Alpha]\[Theta]_, \[Beta]\[Theta]_, \[Phi]_, t_}] := Module[
  {e2, e, r, \[Theta], \[Psi]r, \[Psi]\[Theta], En, \[ScriptL], L, Q, K},
  e2 = Function[{u}, \[Alpha]p[u]^2 + \[Beta]p[u]^2, {Listable}];
  e = Function[{u}, Sqrt[e2[u]], {Listable}];
  r = Function[{u}, p[u]/(1 + \[Beta]p[u]), {Listable}];
  \[Theta] = Function[{u}, ArcCos[\[Beta]\[Theta][u]], {Listable}];
  \[Psi]r = Function[{u}, If[TrueQ[\[Alpha]p[u] == 0 && \[Beta]p[u] == 0],
    Missing["UndefinedAtZeroEccentricity"], ArcTan[\[Beta]p[u], \[Alpha]p[u]]], {Listable}];
  \[Psi]\[Theta] = Function[{u}, If[TrueQ[\[Alpha]\[Theta][u] == 0 && \[Beta]\[Theta][u] == 0],
    Missing["UndefinedForEquatorialOrbit"], ArcTan[\[Beta]\[Theta][u], \[Alpha]\[Theta][u]]], {Listable}];
  En = Function[{u}, RegularEnergy[a, p[u], e2[u], x[u]], {Listable}];
  \[ScriptL] = Function[{u}, RegularLOverX[a, p[u], e2[u], x[u]], {Listable}];
  L = Function[{u}, x[u] \[ScriptL][u], {Listable}];
  Q = Function[{u}, (1 - x[u]^2) (a^2 (1 - En[u]^2) + \[ScriptL][u]^2), {Listable}];
  K = Function[{u}, Q[u] + (L[u] - a En[u])^2, {Listable}];
  <|
    "Trajectory" -> {t, r, \[Theta], \[Phi]},
    "t" -> t, "r" -> r, "\[Theta]" -> \[Theta], "\[Phi]" -> \[Phi],
    "p" -> p, "e" -> e, "x" -> x,
    "\[Psi]r" -> \[Psi]r, "\[Psi]\[Theta]" -> \[Psi]\[Theta],
    "En" -> En, "L" -> L, "Q" -> Q, "K" -> K,
    "\[Alpha]p" -> \[Alpha]p, "\[Beta]p" -> \[Beta]p, "\[Alpha]\[Theta]" -> \[Alpha]\[Theta], "\[Beta]\[Theta]" -> \[Beta]\[Theta]
  |>
];


(* ::Subsubsection:: *)
(*Outputs*)


(* ::Text:: *)
(*The outputs of both solvers, in this order. REG adds "\[Alpha]p" and "\[Beta]p".*)


$outputKeys = {"t", "r", "\[Theta]", "\[Phi]", "En", "L", "K", "Q", "p", "e", "x", "\[Iota]", "\[Psi]r", "\[Psi]\[Theta]", "r1", "r2", "z1"};


(* ::Text:: *)
(*The outputs that follow from the solutions for p, e, x and \[Psi]\[Theta], each a function of the time variable. On an equatorial orbit \[Theta] is \[Pi]/2.*)


derivedOutputs[a_, psol_, esol_, xsol_, \[Psi]\[Theta]sol_, equatorialQ_] := Module[
  {zmsol, \[Theta]sol, Ensol, Lsol, Qsol, Ksol, r1sol, r2sol, \[Iota]sol},
  zmsol[u_] := 1 - xsol[u]^2;
  \[Theta]sol[u_] := If[equatorialQ, \[Pi]/2, ArcCos[Sqrt[zmsol[u]] Cos[\[Psi]\[Theta]sol[u]]]];
  Ensol[u_] := Energy[a, psol[u], esol[u], xsol[u]];
  Lsol[u_] := AngularMomentum[a, psol[u], esol[u], xsol[u]];
  Qsol[u_] := CarterConstant[a, psol[u], esol[u], xsol[u]];
  Ksol[u_] := Qsol[u] + (Lsol[u] - a Ensol[u])^2;
  r1sol[u_] := psol[u]/(1 - esol[u]);
  r2sol[u_] := psol[u]/(1 + esol[u]);
  \[Iota]sol[u_] := ArcCos[Lsol[u]/Sqrt[Ksol[u] + 2 a Lsol[u] Ensol[u] - a^2 Ensol[u]^2]];
  <|"\[Theta]" -> \[Theta]sol, "En" -> Ensol, "L" -> Lsol, "K" -> Ksol, "Q" -> Qsol, "\[Iota]" -> \[Iota]sol,
    "r1" -> r1sol, "r2" -> r2sol, "z1" -> zmsol|>
];


(* ::Section:: *)
(*Forces*)


(* ::Text:: *)
(*The Force option of GenericKerrpexBL and GenericKerrREGBL as a list of drivers (see RunSolver in Interface.wl). pex computes the gas drag from its elements, and REG from the geometry, so each has its own resolver. OsculatingInspiral uses ForceModels instead (ForceModels/ForceModel.wl).*)


callbackForceDriver[force_] := <|"Type" -> "Force", "Function" -> Function[state,
	Through[force[state["a"], state["p"], state["e"], state["x"], state["\[Psi]r"], state["\[Psi]\[Theta]"]]]]|>;

pexForceDrivers[force_] := Switch[force,
	{_, _, _, _}, {callbackForceDriver[force]},
	KerrGasDrag, {<|"Type" -> "Force", "Function" -> Function[state,
		Values[KerrGasDragapex[state["a"], state["p"], state["e"], state["x"], state["\[Psi]r"], state["\[Psi]\[Theta]"]]]]|>},
	_, Message[KerrOsculatingOrbitalElements::InvalidForce, force]; $Failed];

(* The same gas drag, written with the geometry: u_t = -En, u_\[Phi] = L and u^t = (dt/d\[Lambda])/\[CapitalSigma] *)
gasDragDriver = <|"Type" -> "Force", "Function" -> Function[state,
	{state["En"] - state["\[CapitalSigma]"]/state["dtd\[Lambda]"], -state["ur"], -state["u\[Theta]"], -state["L"]}]|>;

regForceDrivers[force_] := Switch[force,
	{_, _, _, _}, {callbackForceDriver[force]},
	KerrGasDrag, {gasDragDriver},
	_, Message[KerrOsculatingOrbitalElements::InvalidForce, force]; $Failed];




(* ::Section:: *)
(*Public Functions*)


GenericKerrpexBL[\[Eta]_, a_, p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, opts:OptionsPattern[{GenericKerrpexBL, NDSolve}]] :=
	RunSolver[GenericKerrpexBL, pexSystem, pexForceDrivers, \[Eta], a, {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0}, {opts}];

GenericKerrREGBL[\[Eta]_, a_, p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, opts:OptionsPattern[{GenericKerrREGBL, NDSolve}]] :=
	RunSolver[GenericKerrREGBL, regSystem, regForceDrivers, \[Eta], a, {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0}, {opts}];
