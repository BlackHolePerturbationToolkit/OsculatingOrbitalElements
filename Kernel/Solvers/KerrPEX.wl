(* ::Package:: *)

(* ::Title:: *)
(*The regular solver behind OsculatingInspiral*)


(* ::Section:: *)
(*Systems*)


(* ::Text:: *)
(*The builder returns a system for IntegrateSystem, with \"Variable\" and \"Outputs\" (see RunSolver in Interface.wl). The earlier pex and REG solvers are in Legacy/GenericKerr.wl. Loaded into the package's private context by Kernel/OsculatingOrbitalElements.wl.*)


(* ::Subsubsection:: *)
(*Polar phase*)


(* ::Text:: *)
(*The Mino-time rate of \[Psi]\[Theta] from the geometry and the force's null-tetrad components. It divides by Sqrt[zm], so equatorial orbits are a special case. The legacy solvers use it too.*)


polarPhaseRate[g_Association, {an_, A1_, A2_, A3_}] := Module[{a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]},
  {a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]} = Lookup[g, {"a", "\[Psi]\[Theta]", "\[Beta]", "zm", "\[Beta]zp", "\[Theta]"}];
  Sqrt[\[Beta]zp - \[Beta] g["z"]] (
      1 + (1 - zm) g["\[CapitalSigma]"] A1 Cos[\[Psi]\[Theta]]/(Sqrt[zm] (\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["H"] a g["\[CapitalDelta]"] (A3 - 2 g["ur"] an)/(2 (\[Beta]zp - \[Beta] zm) g["un"]) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["G"] A2/(\[Beta]zp - \[Beta] zm)
];


(* ::Subsubsection:: *)
(*The regular solver*)


(* ::Text:: *)
(*It integrates p and the eccentricity components \[Alpha]p = e Sin[\[Psi]r], \[Beta]p = e Cos[\[Psi]r] with the REG radial equations, which are regular for circular orbits; x, with a rate regular at x = 0 (RegularXRate), so an inspiral can pass from prograde to retrograde; \[Psi]\[Theta]; and \[Phi]. The initial values are {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0, \[Phi]0}.*)
(*Equatorial orbits (x0 = \[PlusMinus]1) are a special case, as in the legacy solvers: x is held at exactly \[PlusMinus]1, the polar equations are dropped and \[Theta] = \[Pi]/2. So the force must have no \[Theta] component in the plane, and a flux must not change x; both are checked at the start. A regular polar formulation without this restriction is on hold (Legacy/RegularPolar.wl).*)
(*The method is an 8th-order explicit Runge-Kutta method, with goals 12 by default. Near the axis d\[Phi]/d\[Lambda] ~ L/Sin[\[Theta]]^2, so an orbit with small |x| swings \[Phi] by nearly \[Pi] in a time ~ |x|; NDSolve's default multistep method can step over the swing, while this resolves it down to |x| = 0.001. Its stiffness test only stops after 100 stability-limited steps in a row, rather than 3 in 5, which falsely stopped long Mino-time runs; the steps are the same.*)


regularSystem[\[Epsilon]_, a_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, \[Phi]0_}, drivers_List, settings_Association] := Module[
  {
    minoQ, s, equatorialQ, equatorialRules, initialConditions, unknowns, EoM, events, outputs, atStart,
    p, \[Alpha]p, \[Beta]p, x, \[Psi]\[Theta], \[Phi], t, \[Lambda],
    e2, En, \[ScriptL], L, Q, K, w, r, Z, P, geometry, \[CapitalSigma], \[CapitalDelta], flux,
    state, at, ar, a\[Theta], a\[Phi], rates, F, Dp, Ap, Bp, Hp, CAlpha, JAlpha,
    dpd\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda], dxd\[Lambda], d\[Psi]\[Theta]d\[Lambda],
    dtd\[Lambda], toS, minimumP, pMinQ, deltaPSep, initialPSep
  },

  minoQ = settings["Mino"];
  s = If[minoQ, \[Lambda], t];
  (* Equatorial orbits: x is held at exactly \[PlusMinus]1, and \[Psi]\[Theta], which is undefined, at 0 *)
  equatorialQ = TrueQ[Abs[x0] == 1];
  equatorialRules = If[equatorialQ, {x[s] -> Sign[x0], \[Psi]\[Theta][s] -> 0}, {}];

  initialConditions = {
    p[0] == p0,
    \[Alpha]p[0] == e0 Sin[\[Psi]r0],
    \[Beta]p[0] == e0 Cos[\[Psi]r0],
    If[equatorialQ, Nothing, x[0] == x0],
    If[equatorialQ, Nothing, \[Psi]\[Theta][0] == \[Psi]\[Theta]0],
    \[Phi][0] == \[Phi]0,
    If[minoQ, t[0] == 0, Nothing]
  };

  (* The osculating geodesic, with its radial motion in \[Alpha]p and \[Beta]p as in REG: Z = P^2, with P = d\[Psi]r/d\[Lambda],
     is polynomial in them. With L = x \[ScriptL] the geometry's \[Beta] zp is \[Beta] + \[ScriptL]^2, regular at x = 0. *)
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
  geometry = KerrOrbitGeometry[a, {En, L, Q}, {r, x[s], \[Psi]\[Theta][s]}, p[s] \[Alpha]p[s] P/w^2];
  {\[CapitalSigma], \[CapitalDelta]} = Lookup[geometry, {"\[CapitalSigma]", "\[CapitalDelta]"}];

  (* The total force. Force models get \[Psi]r in (-\[Pi], \[Pi]] and \[Psi]\[Theta] as integrated, each 0 where undefined (e = 0,
     or an equatorial orbit), and \[Phi] and the coordinate time t. *)
  state = Join[<|"a" -> a, "p" -> p[s], "e" -> Sqrt[e2], "x" -> x[s], "\[Psi]r" -> phaseAngle[\[Alpha]p[s], \[Beta]p[s]],
    "\[Psi]\[Theta]" -> \[Psi]\[Theta][s], "\[Phi]" -> \[Phi][s], "t" -> If[minoQ, t[s], s],
    "\[Alpha]p" -> \[Alpha]p[s], "\[Beta]p" -> \[Beta]p[s]|>, geometry];
  {at, ar, a\[Theta], a\[Phi]} = TotalForce[drivers, state, \[Epsilon]];

  (* The fluxes' rates of {p, \[Alpha]p, \[Beta]p, x} (fluxVariableRates). They are averages with respect to t, so they
     need coordinate time. *)
  If[minoQ && MemberQ[drivers, KeyValuePattern["Type" -> "Flux"]], Message[OsculatingInspiral::fluxtime]; Return[$Failed]];
  flux = TotalFlux[drivers, state, \[Epsilon]];

  (* An equatorial orbit stays in the plane only if the force has no \[Theta] component there, and the flux does not change x *)
  If[equatorialQ,
    atStart = Quiet[{{at, ar, a\[Theta], a\[Phi]}, flux} /. equatorialRules /.
      Cases[initialConditions, (f_[0] == v_) :> (f[s] -> v)] /. s -> 0];
    If[TrueQ[Abs[atStart[[1, 3]]] > 10^-10 Max[Abs[atStart[[1]]]]],
      Message[OsculatingInspiral::eqforce, atStart[[1, 3]]]; Return[$Failed]];
    If[TrueQ[Abs[atStart[[2, 4]]] > 10^-10 Max[Abs[atStart[[2]]]]],
      Message[OsculatingInspiral::eqflux, atStart[[2, 4]]]; Return[$Failed]]
  ];

  (* p and the eccentricity components, as in REG but written directly in the force components, so the rate of e^2
     and the partial derivatives of Z are not needed. There is no division by e, \[Alpha]p or \[Beta]p.
     F = (r^2 + a^2) En - a L. *)
  F = geometry["F"];
  Dp = (p[s]^3 - K p[s] (3 - e2) + 4 a^2 Q)^2 - 4 e2 (K p[s] - 2 a^2 Q)^2;
  Ap = p[s]^3 - 2 (1 - e2) (K p[s] - a^2 Q);
  Bp = K p[s] - 2 a^2 Q;
  Hp = Ap (p[s]^2 - p[s] (3 + e2) + 2 a^2 (1 + e2)) +
    (1 - e2)^2 (p[s] - a^2) Bp;
  dpd\[Lambda] = 2 \[CapitalSigma] p[s]/Dp (
    (p[s]^2 (p[s]^2 Bp En - a Ap (L - a En)) - r^2 F Hp/\[CapitalDelta]) at +
    a (Ap (p[s]^2 En - 2 a (1 + e2) (L - a En)) +
      a (1 - e2)^2 Bp (L - a En) - F Hp/\[CapitalDelta]) (a\[Phi] + a at) -
    p[s] \[Alpha]p[s] P Hp ar/w^2
  );
  CAlpha = p[s]^2 + K (3 \[Alpha]p[s]^2 + w (w - 8)) +
    4 a^2 Q (3 w - \[Alpha]p[s]^2)/p[s];
  JAlpha = p[s] (w (4 - w) - \[Alpha]p[s]^2) -
    a^2 (4 w - \[Alpha]p[s]^2);
  d\[Beta]d\[Lambda] = -\[Alpha]p[s] P + w dpd\[Lambda]/p[s];
  d\[Alpha]d\[Lambda] = \[Beta]p[s] P + (
    \[Alpha]p[s] CAlpha dpd\[Lambda]/2 +
    \[CapitalSigma] p[s] P (\[CapitalDelta] w^4 - \[Alpha]p[s]^2 JAlpha) ar/w^2 -
    \[CapitalSigma] \[Alpha]p[s] F JAlpha ((r^2 + a^2) at + a a\[Phi])/\[CapitalDelta] +
    \[CapitalSigma] \[Alpha]p[s] a^2 (4 w - \[Alpha]p[s]^2) (L - a En) (a\[Phi] + a at)
  )/(p[s]^2 Z + \[Alpha]p[s]^2 (K p[s] - a^2 Q));

  (* x, from the rates of the constants of motion, and the polar phase *)
  rates = ConstantsOfMotionRates[geometry, {at, ar, a\[Theta], a\[Phi]}];
  dxd\[Lambda] = RegularXRate[a, x[s], {En, \[ScriptL]}, Lookup[rates, {"En", "L", "Q"}]];
  d\[Psi]\[Theta]d\[Lambda] = polarPhaseRate[geometry, NullTetradForce[geometry, {at, ar, a\[Theta], a\[Phi]}]];

  (* The equations in the selected time variable *)
  dtd\[Lambda] = geometry["dtd\[Lambda]"];
  toS = If[minoQ, 1, 1/dtd\[Lambda]];
  EoM = {
    D[p[s], s] == toS dpd\[Lambda] + flux[[1]],
    D[\[Alpha]p[s], s] == toS d\[Alpha]d\[Lambda] + flux[[2]],
    D[\[Beta]p[s], s] == toS d\[Beta]d\[Lambda] + flux[[3]],
    If[equatorialQ, Nothing, D[x[s], s] == toS dxd\[Lambda] + flux[[4]]],
    If[equatorialQ, Nothing, D[\[Psi]\[Theta][s], s] == toS d\[Psi]\[Theta]d\[Lambda]],
    D[\[Phi][s], s] == toS geometry["d\[Phi]d\[Lambda]"],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  } /. equatorialRules;
  unknowns = {p, \[Alpha]p, \[Beta]p, If[equatorialQ, Nothing, x], If[equatorialQ, Nothing, \[Psi]\[Theta]], \[Phi], If[minoQ, t, Nothing]};

  (* Stop at pMin, or at the separatrix buffer, which is \[Epsilon] unless SeparatrixBuffer sets it *)
  minimumP = settings["pMin"];
  pMinQ = NumericQ[minimumP];
  deltaPSep = If[NumericQ[settings["SeparatrixBuffer"]], settings["SeparatrixBuffer"], \[Epsilon]];
  (* Otherwise the integration starts inside the buffer, and never meets the stopping condition *)
  initialPSep = SeparatrixP[a, e0, x0];
  If[!TrueQ[p0 > initialPSep + deltaPSep],
    Message[OsculatingInspiral::sep, deltaPSep, p0, initialPSep];
    Return[$Failed]];
  (* Events are located to 8 digits: near the separatrix the solver's own goals can be more than the Runge-Kutta
     interpolation within a step supports (NDSolve::evcvmit). *)
  events = With[{u = s, location = "LocationMethod" -> {"Brent", AccuracyGoal -> 8, PrecisionGoal -> 8}}, {
    If[pMinQ, stopEvent[p[u] - minimumP == 0, "pMin", location], Nothing],
    stopEvent[p[u] - SeparatrixP[a, Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2], x[u]] - deltaPSep == 0, "SeparatrixBuffer", location]
  }] /. equatorialRules;

  (* The result from NDSolve's solution. In coordinate time t is the independent variable; on an equatorial orbit x is
     constant and \[Psi]\[Theta] is None. *)
  outputs[rules_] := regularOutputs[a, Join[
    {p, \[Alpha]p, \[Beta]p} /. rules,
    If[equatorialQ, {Function[{u}, Evaluate[N[Sign[x0]]], {Listable}], None}, {x, \[Psi]\[Theta]} /. rules],
    {\[Phi] /. rules, If[minoQ, t /. rules, Function[{u}, u, {Listable}]]}], \[Psi]r0];

  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM], "Events" -> events,
    "Method" -> {"ExplicitRungeKutta", "DifferenceOrder" -> 8, "EquationSimplification" -> "Solve",
      "StiffnessTest" -> {True, "MaxRepetitions" -> {100, 100}}},
    "Outputs" -> outputs|>
]


(* ::Text:: *)
(*The angle of (\[Beta], \[Alpha]), 0 at the origin: \[Psi]r from \[Alpha]p and \[Beta]p.*)


phaseAngle[\[Alpha]_?NumericQ, \[Beta]_?NumericQ] := If[TrueQ[\[Alpha] == 0 && \[Beta] == 0], 0, ArcTan[\[Beta], \[Alpha]]];


(* ::Text:: *)
(*The solver's outputs, each a listable function of the time variable, from the solutions for p, \[Alpha]p, \[Beta]p, x, \[Psi]\[Theta] (None on an equatorial orbit), \[Phi] and t, and the initial \[Psi]r0. The phases accumulate, as \[Phi] does: \[Psi]\[Theta] as integrated, and \[Psi]r with its turns counted (continuousRadialPhase). The frequencies and action angles come from OrbitalAngles.wl. \[Psi]r and \[CapitalPhi]r are Missing at e = 0, and \[Psi]\[Theta] and \[CapitalPhi]\[Theta] on an equatorial orbit.*)


regularOutputs[a_, {p_, \[Alpha]p_, \[Beta]p_, x_, \[Psi]\[Theta]_, \[Phi]_, t_}, \[Psi]r0_] := Module[
  {equatorialQ, undefined, circular, e2, e, r, \[Theta], \[Psi]r, En, \[ScriptL], L, Q, K, \[Psi]\[Theta]Angle, angle, frequency},
  equatorialQ = \[Psi]\[Theta] === None;
  undefined[reason_] := Function[{u}, Missing[reason], {Listable}];
  circular = Function[{u}, TrueQ[\[Alpha]p[u] == 0 && \[Beta]p[u] == 0]];
  e2 = Function[{u}, \[Alpha]p[u]^2 + \[Beta]p[u]^2, {Listable}];
  e = Function[{u}, Sqrt[e2[u]], {Listable}];
  r = Function[{u}, p[u]/(1 + \[Beta]p[u]), {Listable}];
  \[Psi]r = continuousRadialPhase[\[Alpha]p, \[Beta]p, \[Psi]r0];
  \[Theta] = If[equatorialQ,
    Function[{u}, Evaluate[N[\[Pi]/2]], {Listable}],
    Function[{u}, ArcCos[Sqrt[1 - x[u]^2] Cos[\[Psi]\[Theta][u]]], {Listable}]];
  En = Function[{u}, RegularEnergy[a, p[u], e2[u], x[u]], {Listable}];
  \[ScriptL] = Function[{u}, RegularLOverX[a, p[u], e2[u], x[u]], {Listable}];
  L = Function[{u}, x[u] \[ScriptL][u], {Listable}];
  Q = Function[{u}, (1 - x[u]^2) (a^2 (1 - En[u]^2) + \[ScriptL][u]^2), {Listable}];
  K = Function[{u}, Q[u] + (L[u] - a En[u])^2, {Listable}];
  frequency[i_] := Function[{u}, BoyerLindquistFrequency[i, a, p[u], e[u], x[u]], {Listable}];
  \[Psi]\[Theta]Angle = If[equatorialQ, Function[{u}, 0], \[Psi]\[Theta]];
  angle[i_] := Function[{u}, BoyerLindquistAngle[i, a, p[u], e[u], x[u], \[Psi]r[u], \[Psi]\[Theta]Angle[u], \[Phi][u]], {Listable}];
  <|
    "Trajectory" -> {t, r, \[Theta], \[Phi]},
    "t" -> t, "r" -> r, "\[Theta]" -> \[Theta], "\[Phi]" -> \[Phi],
    "p" -> p, "e" -> e, "x" -> x,
    "\[Psi]r" -> Function[{u}, If[circular[u], Missing["UndefinedAtZeroEccentricity"], \[Psi]r[u]], {Listable}],
    "\[Psi]\[Theta]" -> If[equatorialQ, undefined["UndefinedForEquatorialOrbit"], \[Psi]\[Theta]],
    "En" -> En, "L" -> L, "Q" -> Q, "K" -> K,
    "\[Alpha]p" -> \[Alpha]p, "\[Beta]p" -> \[Beta]p,
    "\[CapitalOmega]r" -> frequency[1], "\[CapitalOmega]\[Theta]" -> frequency[2], "\[CapitalOmega]\[Phi]" -> frequency[3],
    "\[CapitalPhi]r" -> Function[{u}, If[circular[u], Missing["UndefinedAtZeroEccentricity"], angle[1][u]], {Listable}],
    "\[CapitalPhi]\[Theta]" -> If[equatorialQ, undefined["UndefinedForEquatorialOrbit"], angle[2]],
    "\[CapitalPhi]\[Phi]" -> angle[3]
  |>
];
