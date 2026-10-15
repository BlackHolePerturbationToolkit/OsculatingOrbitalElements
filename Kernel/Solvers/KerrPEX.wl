(* ::Package:: *)

(* ::Title:: *)
(*Kerr solver in p, e, x: the regular solver behind OsculatingInspiral*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Section:: *)
(*Systems*)


(* ::Text:: *)
(*The builder returns the system for IntegrateSystem, with "Variable" and "Outputs" (see RunSolver in Interface.wl). It builds on the shared orbit geometry and rate maps in Utilities.wl. The earlier pex and REG solvers are in Legacy/GenericKerr.wl.*)


(* ::Subsubsection:: *)
(*Polar phase*)


(* ::Text:: *)
(*The rate of \[Psi]\[Theta] with Mino time, from the geometry and the force's null-tetrad components. It divides by Sqrt[zm], so it is singular for equatorial orbits, which the solvers treat as a special case. The legacy solvers (Legacy/GenericKerr.wl) use it too.*)


polarPhaseRate[g_Association, {an_, A1_, A2_, A3_}] := Module[{a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]},
  {a, \[Psi]\[Theta], \[Beta], zm, \[Beta]zp, \[Theta]} = Lookup[g, {"a", "\[Psi]\[Theta]", "\[Beta]", "zm", "\[Beta]zp", "\[Theta]"}];
  Sqrt[\[Beta]zp - \[Beta] g["z"]] (
      1 + (1 - zm) g["\[CapitalSigma]"] A1 Cos[\[Psi]\[Theta]]/(Sqrt[zm] (\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["H"] a g["\[CapitalDelta]"] (A3 - 2 g["ur"] an)/(2 (\[Beta]zp - \[Beta] zm) g["un"]) +
    Cos[\[Psi]\[Theta]] Sin[\[Psi]\[Theta]] g["G"] A2/(\[Beta]zp - \[Beta] zm)
];


(* ::Subsubsection:: *)
(*Regular p, e, x equations (OsculatingInspiral)*)


(* ::Text:: *)
(*The default solver. It integrates p and the eccentricity components \[Alpha]p = e Sin[\[Psi]r] and \[Beta]p = e Cos[\[Psi]r] with the REG radial equations, which are regular for circular orbits, and x and the polar phase \[Psi]\[Theta]. The rate of x is in the form that is regular at x = 0 (RegularXRate in Utilities.wl), so an inspiral can pass from prograde to retrograde. The initial values are {p0, e0, x0, \[Psi]r0, \[Psi]\[Theta]0, \[Phi]0}.*)
(*Equatorial orbits (x0 = \[PlusMinus]1) are a special case, as in the legacy solvers: the \[Psi]\[Theta] equation divides by Sqrt[zm], so x is held at exactly \[PlusMinus]1, the polar equations are dropped, and \[Theta] = \[Pi]/2. The orbit can then only stay in the plane, so the force must have no \[Theta] component there, and a flux must not change x; both are checked at the start. A regular polar formulation, which would let a force lift an equatorial orbit out of the plane, is on hold (Legacy/RegularPolar.wl).*)
(*\[Phi] is integrated directly. Near the Boyer-Lindquist axis d\[Phi]/d\[Lambda] ~ L/Sin[\[Theta]]^2, so an orbit with small |x|, which passes Sin[\[Theta]] = |x| from the axis, swings \[Phi] by nearly \[Pi] in a time ~ |x|. NDSolve's default multistep method can step over that swing entirely: at its default goals \[Phi] was wrong by ~0.4 rad for a gas-drag inspiral at x = 0.01, and meaningless at x = 0.001. An 8th-order explicit Runge-Kutta method with goals of 11 or more resolves it down to |x| = 0.001 at least, so that is the default here, with goals 12 (see the Method below, and the AccuracyGoal and PrecisionGoal defaults of OsculatingInspiral). Over 5000M of gas-drag inspiral it is also about 4 times more accurate in r than the earlier solvers' defaults, and about twice as slow. Writing \[Phi] through Sin[\[Theta]] Exp[I \[Phi]] instead was tried and is worse: its equation divides by Sin[\[Theta]] Exp[-I \[Phi]], which amplifies any error in the polar variables near the axis.*)


regularSystem[\[Epsilon]_, a_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, \[Phi]0_}, drivers_List, settings_Association] := Module[
  {
    minoQ, s, equatorialQ, equatorialRules, initialConditions, unknowns, EoM, events, outputs, atStart,
    p, \[Alpha]p, \[Beta]p, x, \[Psi]\[Theta], \[Phi], t, \[Lambda],
    e2, En, \[ScriptL], L, Q, K, w, r, Z, P, geometry, \[CapitalSigma], \[CapitalDelta], flux,
    state, at, ar, a\[Theta], a\[Phi], rates, elementRates,
    Zp, Ze2, Z\[Beta], ZK, ZQ, dpd\[Lambda], de2d\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda], dxd\[Lambda], d\[Psi]\[Theta]d\[Lambda],
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

  (* The osculating geodesic: its constants of motion, and its radial motion in terms of \[Alpha]p and \[Beta]p, as in REG.
     Z = P^2, where P = d\[Psi]r/d\[Lambda], is polynomial in \[Alpha]p and \[Beta]p. With L = x \[ScriptL], the geometry's
     \[Beta] zp = \[Beta] + L^2/x^2 is \[Beta] + \[ScriptL]^2, which is regular at x = 0. *)
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

  (* The total force. Force models get the phases, \[Psi]r in (-\[Pi], \[Pi]] and \[Psi]\[Theta] as integrated, which are set to
     0 where they are undefined (e = 0, or an equatorial orbit); a physical force does not depend on them there. They
     also get \[Phi] and the coordinate time t, so that a force need not be axisymmetric or stationary. *)
  state = Join[<|"a" -> a, "p" -> p[s], "e" -> Sqrt[e2], "x" -> x[s], "\[Psi]r" -> phaseAngle[\[Alpha]p[s], \[Beta]p[s]],
    "\[Psi]\[Theta]" -> \[Psi]\[Theta][s], "\[Phi]" -> \[Phi][s], "t" -> If[minoQ, t[s], s],
    "\[Alpha]p" -> \[Alpha]p[s], "\[Beta]p" -> \[Beta]p[s]|>, geometry];
  {at, ar, a\[Theta], a\[Phi]} = TotalForce[drivers, state, \[Epsilon]];

  (* The fluxes' rates of {p, \[Alpha]p, \[Beta]p, x}. They change only the slowly varying parts of these variables, leaving
     the phases at their geodesic rates (see fluxVariableRates in FluxModels/FluxModel.wl). They are averages with
     respect to t, so they need coordinate time. *)
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

  (* p and the eccentricity components, as in REG. Zp, Ze2, Z\[Beta], ZK and ZQ are the partial derivatives of Z with
     respect to p, e^2, \[Beta]p, K and Q. *)
  rates = ConstantsOfMotionRates[geometry, {at, ar, a\[Theta], a\[Phi]}];
  elementRates = SlowElementRates[a, {p[s], e2}, {En, L, Q}, Lookup[rates, {"En", "L", "Q"}]];
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

  (* x and the polar phase *)
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
  (* The events are located to 8 digits. Near the separatrix p changes steeply, and the default, the solver's own goals,
     can be more than the Runge-Kutta method's interpolation within a step supports (NDSolve::evcvmit). *)
  events = With[{u = s, location = "LocationMethod" -> {"Brent", AccuracyGoal -> 8, PrecisionGoal -> 8}}, {
    If[pMinQ, stopEvent[p[u] - minimumP == 0, "pMin", location], Nothing],
    stopEvent[p[u] - SeparatrixP[a, Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2], x[u]] - deltaPSep == 0, "SeparatrixBuffer", location]
  }] /. equatorialRules;

  (* The result, made from NDSolve's solution. In coordinate time, t is the independent variable itself. On an
     equatorial orbit x is constant, and \[Psi]\[Theta] is None. *)
  outputs[rules_] := regularOutputs[a, Join[
    {p, \[Alpha]p, \[Beta]p} /. rules,
    If[equatorialQ, {Function[{u}, Evaluate[N[Sign[x0]]], {Listable}], None}, {x, \[Psi]\[Theta]} /. rules],
    {\[Phi] /. rules, If[minoQ, t /. rules, Function[{u}, u, {Listable}]]}]];

  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM], "Events" -> events,
    "Method" -> {"ExplicitRungeKutta", "DifferenceOrder" -> 8, "EquationSimplification" -> "Solve"}, "Outputs" -> outputs|>
]


(* ::Text:: *)
(*The angle of the point (\[Beta], \[Alpha]), which is 0 at the origin, where the phase is undefined. It gives \[Psi]r from \[Alpha]p and \[Beta]p.*)


phaseAngle[\[Alpha]_?NumericQ, \[Beta]_?NumericQ] := If[TrueQ[\[Alpha] == 0 && \[Beta] == 0], 0, ArcTan[\[Beta], \[Alpha]]];


(* ::Text:: *)
(*The regular solver's outputs, each a listable function of the time variable, from the solutions for p, \[Alpha]p, \[Beta]p, x, \[Psi]\[Theta], \[Phi] and t. \[Psi]\[Theta] is None for an equatorial orbit, where \[Theta] = \[Pi]/2. The phases \[Psi]r and \[Psi]\[Theta] are given in (-\[Pi], \[Pi]], and are Missing where they are undefined: \[Psi]r at e = 0, and \[Psi]\[Theta] on an equatorial orbit.*)


regularOutputs[a_, {p_, \[Alpha]p_, \[Beta]p_, x_, \[Psi]\[Theta]_, \[Phi]_, t_}] := Module[
  {e2, e, r, \[Theta], \[Psi]r, \[Psi]\[Theta]Output, En, \[ScriptL], L, Q, K},
  e2 = Function[{u}, \[Alpha]p[u]^2 + \[Beta]p[u]^2, {Listable}];
  e = Function[{u}, Sqrt[e2[u]], {Listable}];
  r = Function[{u}, p[u]/(1 + \[Beta]p[u]), {Listable}];
  \[Psi]r = Function[{u}, If[TrueQ[\[Alpha]p[u] == 0 && \[Beta]p[u] == 0],
    Missing["UndefinedAtZeroEccentricity"], ArcTan[\[Beta]p[u], \[Alpha]p[u]]], {Listable}];
  If[\[Psi]\[Theta] === None,
    \[Theta] = Function[{u}, Evaluate[N[\[Pi]/2]], {Listable}];
    \[Psi]\[Theta]Output = Function[{u}, Missing["UndefinedForEquatorialOrbit"], {Listable}],
    \[Theta] = Function[{u}, ArcCos[Sqrt[1 - x[u]^2] Cos[\[Psi]\[Theta][u]]], {Listable}];
    \[Psi]\[Theta]Output = Function[{u}, ArcTan[Cos[\[Psi]\[Theta][u]], Sin[\[Psi]\[Theta][u]]], {Listable}]];
  En = Function[{u}, RegularEnergy[a, p[u], e2[u], x[u]], {Listable}];
  \[ScriptL] = Function[{u}, RegularLOverX[a, p[u], e2[u], x[u]], {Listable}];
  L = Function[{u}, x[u] \[ScriptL][u], {Listable}];
  Q = Function[{u}, (1 - x[u]^2) (a^2 (1 - En[u]^2) + \[ScriptL][u]^2), {Listable}];
  K = Function[{u}, Q[u] + (L[u] - a En[u])^2, {Listable}];
  <|
    "Trajectory" -> {t, r, \[Theta], \[Phi]},
    "t" -> t, "r" -> r, "\[Theta]" -> \[Theta], "\[Phi]" -> \[Phi],
    "p" -> p, "e" -> e, "x" -> x,
    "\[Psi]r" -> \[Psi]r, "\[Psi]\[Theta]" -> \[Psi]\[Theta]Output,
    "En" -> En, "L" -> L, "Q" -> Q, "K" -> K,
    "\[Alpha]p" -> \[Alpha]p, "\[Beta]p" -> \[Beta]p
  |>
];
