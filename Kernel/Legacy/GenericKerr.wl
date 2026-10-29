(* ::Package:: *)

(* ::Title:: *)
(*Kerr solvers in p, e, x: pex and REG*)


(* ::Text:: *)
(*LEGACY: kept so that the earlier functions keep working; do not extend. GenericKerrpexBL (p, e, x, with p, \[Alpha]p, \[Beta]p at small e) and GenericKerrREGBL (p, \[Alpha]p, \[Beta]p), with their builders and force resolvers, replaced by the regular solver (Solvers/KerrPEX.wl), with which they share polarPhaseRate.*)


(* ::Section:: *)
(*Systems*)


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
