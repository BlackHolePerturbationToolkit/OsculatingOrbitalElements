(* ::Package:: *)

(* ::Title:: *)
(*Kerr solvers in p, e, x (pex) and the regular p, \[Alpha], \[Beta] form (REG)*)


(* ::Text:: *)
(*Part of the OsculatingOrbitalElements package. Kernel/OsculatingOrbitalElements.wl loads this file into the package's private context, so it cannot be loaded on its own.*)


(* ::Subsubsection:: *)
(*GenericKerrpexBL*)


GenericKerrpexBL[ \[Eta]_, a_, p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, OptionsPattern[]] := Module[
  {
    initialConditions, EoM, events, unknowns, minoQ, monitorQ,
    limit, pMin, pMinQ, progress = 0, solve, sol, rules, s,
    p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, \[Lambda], aze0Q,
    En, L, Q, K, r1, r2, r, \[Beta], zm, \[Beta]zp, z,
    \[CapitalSigma], \[CapitalSigma]1, \[CapitalSigma]2,
    \[CapitalDelta], \[CapitalDelta]1, \[CapitalDelta]2,
    \[Omega], \[Omega]1, \[Omega]2, F, F1, F2, H, \[Theta],
    \[Kappa]1, \[Kappa]2, Q1, Q2, C, \[ScriptCapitalD], \[Epsilon],
    J, P, G, ur, urup, u\[Theta], u\[Theta]up, un,
    at, ar, a\[Theta], a\[Phi], an, A1, A2, A3,
    dEd\[Lambda], dLd\[Lambda], dKd\[Lambda],
    dr1d\[Lambda], dr2d\[Lambda], dpd\[Lambda], ded\[Lambda],
    dzmd\[Lambda], dxd\[Lambda], dtd\[Lambda], d\[Phi]d\[Lambda],
    d\[Psi]rd\[Lambda], d\[Psi]\[Theta]d\[Lambda],
    psol, esol, xsol, \[Psi]rsol, \[Psi]\[Theta]sol, tsol, \[Phi]sol,
    rsol, \[Theta]sol, Ensol, Lsol, Ksol, Qsol,
    r1sol, r2sol, zmsol, \[Iota]sol,
    \[CapitalUpsilon]tsol, \[CapitalUpsilon]rsol,
    \[CapitalUpsilon]zsol, \[CapitalUpsilon]\[Phi]sol,
    smallEQ, smallERules, standardEoM, smallEEoM, sepExpr,deltaPSep, pSep,
\[Alpha]p, \[Beta]p,
d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda],
\[Alpha]psol, \[Beta]psol, equatorialQ, equatorialRules, icRules, forceAtStart, stopReason = None
  },

  Needs["KerrGeodesics`"];

  minoQ = MinoParametrisationQ[OptionValue["Parametrisation"]];
  If[FailureQ[minoQ], Return[$Failed]];
  monitorQ = MatchQ[OptionValue["TimeMonitor"], True | "True"] && $FrontEnd =!= Null;
  smallEQ = e0 < 100 \[Eta];
  (* Equatorial orbits (x = \[PlusMinus]1): x is held fixed and the polar equations are dropped. x is kept as an exact \[PlusMinus]1, since KerrGeoSeparatrix does not evaluate at x = \[PlusMinus]1. when a \[NotEqual] 0. *)
  equatorialQ = TrueQ[Abs[x0] == 1];
  equatorialRules = If[equatorialQ, {x[s] -> Sign[x0], \[Psi]\[Theta][s] -> 0}, {}];

  initialConditions = {
  p[0] == p0,

  If[
    smallEQ,
    \[Alpha]p[0] == e0 Sin[\[Psi]r0],
    e[0] == e0
  ],

  If[equatorialQ, Nothing, x[0] == x0],

  If[
    smallEQ,
    \[Beta]p[0] == e0 Cos[\[Psi]r0],
    \[Psi]r[0] == \[Psi]r0
  ],

  If[equatorialQ, Nothing, \[Psi]\[Theta][0] == \[Psi]\[Theta]0],
  \[Phi][0] == 0,

  If[minoQ, t[0] == 0, Nothing]
};
  
  

  (* Constants of motion and radial roots. *)
  {En, L, Q} = {
    Energy[a, p[s], e[s], x[s]],
    AngularMomentum[a, p[s], e[s], x[s]],
    CarterConstant[a, p[s], e[s], x[s]]
  };

K = Q + (L - a En)^2;
r1 = p[s]/(1 - e[s]);
r2 = p[s]/(1 + e[s]);
r = p[s]/(1 + e[s] Cos[\[Psi]r[s]]);

\[Beta] = a^2 (1 - En^2);
zm = 1 - x[s]^2;
\[Beta]zp = a^2 (1 - En^2) + L^2/(1 - zm);
z = zm Cos[\[Psi]\[Theta][s]]^2;

 (* Useful shorthand. *)
\[CapitalSigma] = r^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;
\[CapitalSigma]1 = r1^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;
\[CapitalSigma]2 = r2^2 + a^2 zm Cos[\[Psi]\[Theta][s]]^2;

\[CapitalDelta] = r^2 + a^2 - 2 r;
\[CapitalDelta]1 = r1^2 + a^2 - 2 r1;
\[CapitalDelta]2 = r2^2 + a^2 - 2 r2;

\[Omega] = Sqrt[r^2 + a^2];
\[Omega]1 = Sqrt[r1^2 + a^2];
\[Omega]2 = Sqrt[r2^2 + a^2];

F = (r^2 + a^2) En - a L;
F1 = (r1^2 + a^2) En - a L;
F2 = (r2^2 + a^2) En - a L;

H = L - a En x[s]^2;
\[Theta] = ArcCos[Sqrt[zm] Cos[\[Psi]\[Theta][s]]];

\[Kappa]1 = 4 En F1 r1 - 2 r1 \[CapitalDelta]1 -
    2 (r1 - 1) (r1^2 + K);
\[Kappa]2 = 4 En F2 r2 - 2 r2 \[CapitalDelta]2 -
    2 (r2 - 1) (r2^2 + K);

Q1 = -2 a L r r1 - a^4 En (r + r1) + a^3 L (r + r1) -
    a^2 En (r^3 + r^2 r1 + r1^3 + r r1 (-2 + r1)) -
    En r r1 (r r1 (r + r1) - 2 (r^2 + r r1 + r1^2)) -
    a^2 (2 a^2 En - 2 En r r1 + a L (-2 + r + r1))
      zm Cos[\[Psi]\[Theta][s]]^2;

Q2 = -2 a L r r2 - a^4 En (r + r2) + a^3 L (r + r2) -
    a^2 En (r^3 + r^2 r2 + r2^3 + r r2 (-2 + r2)) -
    En r r2 (r r2 (r + r2) - 2 (r^2 + r r2 + r2^2)) -
    a^2 (2 a^2 En - 2 En r r2 + a L (-2 + r + r2))
      zm Cos[\[Psi]\[Theta][s]]^2;

C = Q1 (1 - e[s])/\[Kappa]1 - Q2 (1 + e[s])/\[Kappa]2;

\[ScriptCapitalD] =(1 - e[s])^2 (1 - Cos[\[Psi]r[s]]) \[CapitalDelta]1/\[Kappa]1 +(1 + e[s])^2 (1 + Cos[\[Psi]r[s]]) \[CapitalDelta]2/\[Kappa]2;

\[Epsilon] = (F1(1-e[s])(r+r1))/\[Kappa]1 - (F2 (1+ e[s]) (r + r2))/\[Kappa]2; 

J = (1-En^2)(1-e[s]^2) + 2(1 - En^2-(1-e[s]^2)/p[s])(1 + e[s] Cos[\[Psi]r[s]]) + ((1 - En^2) (3+ e[s]^2)/(1 - e[s]^2) - 4/p[s]+ (\[Beta] + L^2 +Q) (1-e[s]^2)/p[s]^2)(1+e[s] Cos[\[Psi]r[s]])^2;

P = p[s] Sqrt[J]/(1 - e[s]^2);
G = \[Omega]^2 L/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

(*Particle Velocities*)
ur = (p[s] e[s] Sin[\[Psi]r[s]] P)/(\[CapitalDelta] (1+ e[s] Cos[\[Psi]r[s]])^2); 
urup = \[CapitalDelta]/\[CapitalSigma] ur;
u\[Theta] = (Sqrt[zm]Sin[\[Psi]\[Theta][s]])/Sin[\[Theta]] Sqrt[\[Beta]zp - \[Beta] z];
u\[Theta]up = u\[Theta]/\[CapitalSigma];
un = -(F /(2\[CapitalSigma]))- \[CapitalDelta]/(2\[CapitalSigma]) ur; 

  
(* Assign the force components *)
Switch[{OptionValue["Force"]},

  {{_, _, _, _}},
    {at, ar, a\[Theta], a\[Phi]} = \[Eta] Through[OptionValue["Force"][a, p[s], e[s], x[s], \[Psi]r[s], \[Psi]\[Theta][s]]];,

  {KerrGasDrag},
   {at, ar, a\[Theta], a\[Phi]} = \[Eta] Values[
    KerrGasDragapex[
      a, p[s], e[s], x[s], \[Psi]r[s], \[Psi]\[Theta][s]
    ]];
    ,_,
    Message[KerrOsculatingOrbitalElements::InvalidForce, OptionValue["Force"]];
    Return[$Failed]];


(*Orbital Element Evolution*)
dEd\[Lambda] = -\[CapitalSigma] at;
dLd\[Lambda] = \[CapitalSigma] a\[Phi]; 
dKd\[Lambda] = (2\[CapitalSigma])/\[CapitalDelta] (-at(\[Omega]^4 En - a \[Omega]^2 L) + a\[Phi] (a^2 L -a \[Omega]^2 En) - \[CapitalDelta]^2 ur ar);  

dr1d\[Lambda] = -2 F1/\[Kappa]1 (\[Omega]1^2 dEd\[Lambda] - a dLd\[Lambda]) + \[CapitalDelta]1/\[Kappa]1 dKd\[Lambda];  
dr2d\[Lambda] = -2 F2/\[Kappa]2 (\[Omega]2^2 dEd\[Lambda] - a dLd\[Lambda]) + \[CapitalDelta]2/\[Kappa]2 dKd\[Lambda];  

dpd\[Lambda] = (2 r2^2)/(r1+r2)^2 dr1d\[Lambda] + (2 r1^2)/(r1+r2)^2 dr2d\[Lambda];
ded\[Lambda] = (2 r2)/(r1+r2)^2 dr1d\[Lambda] -(2 r1)/(r1+r2)^2 dr2d\[Lambda];


(*Convert from BL to Null Tetrad Componets*)

an = \[Omega]^2/(2\[CapitalSigma])  at - \[CapitalDelta]/(2\[CapitalSigma]) ar + a/(2\[CapitalSigma]) a\[Phi];

A1 = a\[Theta];
A2 = -a Sin[\[Theta]] at - 1/Sin[\[Theta]] a\[Phi];
A3 = (a(L - a En Sin[\[Theta]]^2))/\[CapitalSigma]  at + u\[Theta]/\[CapitalSigma] a\[Theta] + (L - a En Sin[\[Theta]]^2)/(\[CapitalSigma] Sin[\[Theta]]^2) a\[Phi] ; 

d\[Psi]rd\[Lambda] = P  +(C A3 Sin[\[Psi]r[s]])/(2(1 + e[s] Cos[\[Psi]r[s]]) un) + (\[ScriptCapitalD] \[CapitalSigma] A3 P )/(2(1+ e[s] Cos[\[Psi]r[s]])^2 un) - (a \[Epsilon] Sin[\[Theta]]Sin[\[Psi]r[s]] A2)/(1 + e[s] Cos[\[Psi]r[s]])  +  (P an)/(un ( 1 + e[s] Cos[\[Psi]r[s]])^2) ((1-e[s])^2 (1 - Cos[\[Psi]r[s]]) ( \[CapitalSigma]1 F1)/\[Kappa]1  +(1+e[s])^2 (1+Cos[\[Psi]r[s]]) (\[CapitalSigma]2 F2)/\[Kappa]2);

d\[Psi]\[Theta]d\[Lambda] = Sqrt[\[Beta]zp - \[Beta] z]( 1 + ((1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta][s]])/(Sqrt[zm](\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) + (Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] H a \[CapitalDelta] ( A3 - 2 ur an))/(2(\[Beta]zp -\[Beta] zm)  un) + (Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] G A2 )/((\[Beta]zp - \[Beta] zm));

dtd\[Lambda] = En(\[Omega]^4/\[CapitalDelta] - a^2 (1 - zm Cos[\[Psi]\[Theta][s]]^2)) + a L(1 - \[Omega]^2/\[CapitalDelta]);
d\[Phi]d\[Lambda] = L/(1-zm Cos[\[Psi]\[Theta][s]]^2) + a En (\[Omega]^2/\[CapitalDelta]-1) - (a^2 L)/\[CapitalDelta];

dzmd\[Lambda] = 1/(\[Beta]zp - \[Beta] zm) ((1-zm)dKd\[Lambda] - 2(L - a(1-zm)En)(dLd\[Lambda] - a (1-zm)dEd\[Lambda]));  
dxd\[Lambda] = -(1/(2x[s]))dzmd\[Lambda];


If[smallEQ, 
d\[Alpha]d\[Lambda] = ded\[Lambda] Sin[\[Psi]r[s]] +e[s] d\[Psi]rd\[Lambda] Cos[\[Psi]r[s]];
d\[Beta]d\[Lambda] = ded\[Lambda] Cos[\[Psi]r[s]] -e[s] d\[Psi]rd\[Lambda] Sin[\[Psi]r[s]];,

   Nothing];
   
smallERules = {
  e[s] -> Sqrt[\[Alpha]p[s]^2 + \[Beta]p[s]^2],
  \[Psi]r[s] -> ArcTan[\[Beta]p[s], \[Alpha]p[s]]
};

  (* The first six equations use the selected parametrisation. *)
  EoM = {
    D[p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dpd\[Lambda],
    If[smallEQ, D[\[Alpha]p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Alpha]d\[Lambda],
    D[e[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] ded\[Lambda]],
    If[equatorialQ, Nothing, D[x[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dxd\[Lambda]],
    If[smallEQ, D[\[Beta]p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Beta]d\[Lambda],
    D[\[Psi]r[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Psi]rd\[Lambda]],
    If[equatorialQ, Nothing, D[\[Psi]\[Theta][s], s] ==
      If[minoQ, 1, 1/dtd\[Lambda]] d\[Psi]\[Theta]d\[Lambda]],
    D[\[Phi][s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Phi]d\[Lambda],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  }     /. If[smallEQ,  {e[s]-> Sqrt[\[Alpha]p[s]^2 + \[Beta]p[s]^2],
\[Psi]r[s] -> ArcTan[\[Beta]p[s], \[Alpha]p[s]] }, {}] /. equatorialRules;

  (* Equatorial orbits only stay in the plane if the force has no \[Theta] component there. *)
  If[equatorialQ,
    icRules = Cases[initialConditions, (f_[0] == v_) :> (f[s] -> v)];
    forceAtStart = Quiet[{at, ar, a\[Theta], a\[Phi]} /. If[smallEQ, smallERules, {}] /. equatorialRules /. icRules];
    If[TrueQ[Abs[forceAtStart[[3]]] > 10^-10 Max[Abs[forceAtStart]]],
      Message[KerrOsculatingOrbitalElements::eqforce, forceAtStart[[3]]/\[Eta]];
      Return[$Failed]]
  ];

  s = If[minoQ, \[Lambda], t];
unknowns = { 
p,
If[smallEQ, \[Alpha]p, e],
If[equatorialQ, Nothing, x],
If[smallEQ, \[Beta]p, \[Psi]r],
If[equatorialQ, Nothing, \[Psi]\[Theta]],
\[Phi],
If[minoQ, t, Nothing]
};

  limit = Replace[OptionValue["IntegrationLimit"], Automatic -> If[minoQ, 10^4, 10^7]];
  pMin = OptionValue["pMin"];
  pMinQ = NumericQ[pMin];

deltaPSep = \[Eta];

pSep[ee_?NumericQ, xx_?NumericQ] := Quiet[KerrGeoSeparatrix[a, ee, xx]];

events = With[{u = s},
  {
    If[
      pMinQ,
      WhenEvent[
        p[u] - pMin == 0,
        stopReason = "pMin";
        "StopIntegration"],
      Nothing
    ],

    If[
      smallEQ,
      WhenEvent[ p[u] - pSep[Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2],x[u]] - deltaPSep == 0,

  stopReason = "SeparatrixBuffer";
  "StopIntegration"],

      WhenEvent[
        Evaluate[
          SeparatrixEqELK[a, En, L, K] == -10^-6
        ],
        stopReason = "Separatrix";
        "StopIntegration"
      ]
    ]
  }
] /. equatorialRules;


  solve[] := NDSolve[
    Evaluate@Join[initialConditions, EoM, events],
    unknowns,
    {s, 0, limit},
    AccuracyGoal -> OptionValue["AccuracyGoal"],
    PrecisionGoal -> OptionValue["PrecisionGoal"],
    Method -> {"EquationSimplification" -> "Solve"},
    StepMonitor :> (progress = s)
  ];

  sol = If[
    monitorQ,
    Monitor[
      solve[],
      Row[{If[minoQ, "\[Lambda]", "t"], " = ", progress}]
    ],
    solve[]
  ];

  If[
    ! MatchQ[sol, {{__Rule}}],
    Message[GenericKerrpexBL::nosol];
    Return[$Failed]
  ];

  rules = First[sol];
  {psol, \[Phi]sol} = {p, \[Phi]} /. rules;
  If[equatorialQ,
    xsol[u_] := Sign[x0];
    \[Psi]\[Theta]sol[u_] := Missing["UndefinedForEquatorialOrbit"],
    {xsol, \[Psi]\[Theta]sol} = {x, \[Psi]\[Theta]} /. rules
  ];

  If[
    minoQ,
    tsol = t /. rules,
    tsol[\[Tau]_?NumericQ] := \[Tau]
  ];

  StopMessage[KerrOsculatingOrbitalElements, If[minoQ, "\[Lambda]", "t"], psol["Domain"][[1, 2]], limit, stopReason];
  
  

If[
  smallEQ,

  {\[Alpha]psol, \[Beta]psol} =
    {\[Alpha]p, \[Beta]p} /. rules;

  esol[u_?NumericQ] :=
    Sqrt[\[Alpha]psol[u]^2 + \[Beta]psol[u]^2];

  \[Psi]rsol[u_?NumericQ] :=
    ArcTan[\[Beta]psol[u], \[Alpha]psol[u]],

  {esol, \[Psi]rsol} =
    {e, \[Psi]r} /. rules
];

  (* Derived quantities. *)
  zmsol[u_] := 1 - xsol[u]^2;
  rsol[u_] := psol[u]/(1 + esol[u] Cos[\[Psi]rsol[u]]);
  \[Theta]sol[u_] := If[equatorialQ, \[Pi]/2, ArcCos[Sqrt[zmsol[u]] Cos[\[Psi]\[Theta]sol[u]]]];

  Ensol[u_] := Energy[a, psol[u], esol[u], xsol[u]];
  Lsol[u_] := AngularMomentum[a, psol[u], esol[u], xsol[u]];
  Qsol[u_] := CarterConstant[a, psol[u], esol[u], xsol[u]];
  Ksol[u_] := Qsol[u] + (Lsol[u] - a Ensol[u])^2;

  r1sol[u_] := psol[u]/(1 - esol[u]);
  r2sol[u_] := psol[u]/(1 + esol[u]);
  \[Iota]sol[u_] := ArcCos[
    Lsol[u]/Sqrt[
      Ksol[u] + 2 a Lsol[u] Ensol[u] - a^2 Ensol[u]^2
    ]
  ];

  
  <|
    "t" -> tsol,
    "r" -> rsol,
    "\[Theta]" -> \[Theta]sol,
    "\[Phi]" -> \[Phi]sol,
    "En" -> Ensol,
    "L" -> Lsol,
    "K" -> Ksol,
    "Q" -> Qsol,
    "p" -> psol,
    "e" -> esol,
    "x" -> xsol,
    "\[Iota]" -> \[Iota]sol,
    "\[Psi]r" -> \[Psi]rsol,
    "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol,
    "r1" -> r1sol,
    "r2" -> r2sol,
    "z1" -> zmsol,
    "limit" -> psol["Domain"][[1, 2]]
  |>
]


(* ::Subsubsection:: *)
(*GenericKerrREGBL*)


GenericKerrREGBL[ \[Eta]_, a_, p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, OptionsPattern[]] := Module[
  {
    initialConditions, EoM, events, unknowns, minoQ, monitorQ,
    limit, pMin, pMinQ, progress = 0, solve, sol, rules, s,
    p, e, e2, x, \[Alpha]p, \[Beta]p, \[Psi]\[Theta], \[Phi], t, \[Lambda],
    eccentricity, radialPhase, En, L, Q, K, V, r, w,
    \[Beta], zm, \[Beta]zp, z, \[CapitalSigma], \[CapitalDelta],
    \[Omega], F, H, \[Theta], Z, P, G, ur, u\[Theta], un,
    at, ar, a\[Theta], a\[Phi], an, A1, A2, A3,
    h0p, h1p, B0, B1, Dp, Zp, Ze2, Z\[Beta], ZK, ZQ,
    dEd\[Lambda], dLd\[Lambda], dKd\[Lambda], dQd\[Lambda], dVd\[Lambda],
    dpd\[Lambda], de2d\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda],
    dzmd\[Lambda], dxd\[Lambda], dtd\[Lambda], d\[Phi]d\[Lambda], d\[Psi]\[Theta]d\[Lambda],
    psol, esol, xsol, \[Alpha]psol, \[Beta]psol, \[Psi]rsol, \[Psi]\[Theta]sol, tsol, \[Phi]sol,
    rsol, \[Theta]sol, Ensol, Lsol, Ksol, Qsol,
    r1sol, r2sol, zmsol, \[Iota]sol, deltaPSep, pSep,
    equatorialQ, equatorialRules, icRules, forceAtStart, stopReason = None
  },

  Needs["KerrGeodesics`"];

  minoQ = MinoParametrisationQ[OptionValue["Parametrisation"]];
  If[FailureQ[minoQ], Return[$Failed]];
  monitorQ = MatchQ[OptionValue["TimeMonitor"], True | "True"] && $FrontEnd =!= Null;
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

  (* Constants of motion and radial position. *)
  e2 = \[Alpha]p[s]^2 + \[Beta]p[s]^2;
  e = eccentricity[\[Alpha]p[s], \[Beta]p[s]];
  {En, L, Q} = {
    Energy[a, p[s], e, x[s]],
    AngularMomentum[a, p[s], e, x[s]],
    CarterConstant[a, p[s], e, x[s]]
  };
  K = Q + (L - a En)^2;
  V = a^2 (1 - En^2) + L^2 + Q;
  w = 1 + \[Beta]p[s];
  r = p[s]/w;

  \[Beta] = a^2 (1 - En^2);
  zm = 1 - x[s]^2;
  \[Beta]zp = \[Beta] + L^2/(1 - zm);
  z = zm Cos[\[Psi]\[Theta][s]]^2;

  (* Useful shorthand. Z = P^2 is polynomial in the eccentricity components. *)
  \[CapitalSigma] = r^2 + a^2 z;
  \[CapitalDelta] = r^2 + a^2 - 2 r;
  \[Omega] = Sqrt[r^2 + a^2];
  F = (r^2 + a^2) En - a L;
  H = L - a En x[s]^2;
  \[Theta] = ArcCos[Sqrt[zm] Cos[\[Psi]\[Theta][s]]];
  Z = p[s] - K (3 - e2 + 2 \[Beta]p[s])/p[s] +
    a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  P = Sqrt[Z];
  G = \[Omega]^2 L/Sin[\[Theta]] - a^3 (1 - zm) Sin[\[Theta]] En;

  (* Particle velocities. *)
  ur = p[s] \[Alpha]p[s] P/(\[CapitalDelta] w^2);
  u\[Theta] = Sqrt[zm] Sin[\[Psi]\[Theta][s]]/Sin[\[Theta]] Sqrt[\[Beta]zp - \[Beta] z];
  un = -(F + \[CapitalDelta] ur)/(2 \[CapitalSigma]);
  dtd\[Lambda] = En (\[Omega]^4/\[CapitalDelta] - a^2 (1 - z)) + a L (1 - \[Omega]^2/\[CapitalDelta]);
  d\[Phi]d\[Lambda] = L/(1 - z) + a En (\[Omega]^2/\[CapitalDelta] - 1) - a^2 L/\[CapitalDelta];

  (* Assign covariant force components, with the same callback arguments as pex. *)
  Switch[{OptionValue["Force"]},
    {{_, _, _, _}},
      {at, ar, a\[Theta], a\[Phi]} = \[Eta] Through[
        OptionValue["Force"][a, p[s], e, x[s],
          radialPhase[\[Alpha]p[s], \[Beta]p[s]], \[Psi]\[Theta][s]]],
    {KerrGasDrag},
      (* Same gas drag: u_t=-En, u_phi=L and u^t=(dt/dlambda)/Sigma.
         Evaluate it directly, without reconstructing the radial anomaly. *)
      {at, ar, a\[Theta], a\[Phi]} = \[Eta] {En - \[CapitalSigma]/dtd\[Lambda], -ur, -u\[Theta], -L},
    _,
      Message[KerrOsculatingOrbitalElements::InvalidForce, OptionValue["Force"]];
      Return[$Failed]
  ];

  (* Integral rates and the exact regular p and e^2 equations. *)
  dEd\[Lambda] = -\[CapitalSigma] at;
  dLd\[Lambda] = \[CapitalSigma] a\[Phi];
  dKd\[Lambda] = 2 \[CapitalSigma]/\[CapitalDelta] (-F (\[Omega]^2 at + a a\[Phi]) - \[CapitalDelta]^2 ur ar);
  dQd\[Lambda] = dKd\[Lambda] - 2 (L - a En) (dLd\[Lambda] - a dEd\[Lambda]);
  dVd\[Lambda] = -2 a^2 En dEd\[Lambda] + 2 L dLd\[Lambda] + dQd\[Lambda];

(*Main result*)

  Dp = (p[s]^3 - K p[s] (3 - e2) + 4 a^2 Q)^2 - 4 e2 (K p[s] - 2 a^2 Q)^2;
  dpd\[Lambda] = p[s]/Dp (
    -2 p[s]^4 (K p[s] - 2 a^2 Q) En dEd\[Lambda] +
    p[s]^2 (p[s]^3 - 2 (1 - e2) (K p[s] - a^2 Q)) dVd\[Lambda] -
    p[s] (p[s]^3 (3 + e2) - (1 - e2) ((7 + e2) K p[s] - 8 a^2 Q)) dKd\[Lambda] +
    a^2 (2 p[s]^3 (1 + e2) - (1 - e2) ((5 + 3 e2) K p[s] - 2 a^2 Q (3 + e2))) dQd\[Lambda]
  );

  h0p = -4 (1 - En^2) p[s]^3 + 6 p[s]^2 - 2 V p[s] (1 + e2) + 2 K (1 + 3 e2);
  h1p = 6 p[s]^2 - 4 V p[s] + 2 K (3 + e2);
  B0 = 2 p[s]^4 En dEd\[Lambda] - p[s]^2 (1 + e2) dVd\[Lambda] +
    2 p[s] (1 + 3 e2) dKd\[Lambda] - a^2 (1 + 6 e2 + e2^2) dQd\[Lambda];
  B1 = -2 p[s]^2 dVd\[Lambda] + 2 p[s] (3 + e2) dKd\[Lambda] - 4 a^2 (1 + e2) dQd\[Lambda];
  de2d\[Lambda] = p[s] (h1p B0 - h0p B1)/(2 Dp);

  (* Partial derivatives of Z with respect to p, e^2, beta_p, K and Q. *)
  Zp = 1 + K (3 - e2 + 2 \[Beta]p[s])/p[s]^2 -
    2 a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^3;
  Ze2 = K/p[s] - a^2 Q/p[s]^2;
  Z\[Beta] = -2 K/p[s] + a^2 Q (4 + 2 \[Beta]p[s])/p[s]^2;
  ZK = -(3 - e2 + 2 \[Beta]p[s])/p[s];
  ZQ = a^2 (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;

  (* Component rates contain no division by e, alpha_p or beta_p. *)
  d\[Beta]d\[Lambda] = w dpd\[Lambda]/p[s] - \[Alpha]p[s] P;
  d\[Alpha]d\[Lambda] = \[Beta]p[s] P + \[CapitalSigma] \[CapitalDelta] w^2 ar/(p[s] P) +
    \[Alpha]p[s] dpd\[Lambda]/p[s] - \[Alpha]p[s]/(2 Z) (
      (Zp + w Z\[Beta]/p[s]) dpd\[Lambda] + Ze2 de2d\[Lambda] + ZK dKd\[Lambda] + ZQ dQd\[Lambda]
    );

  (* Convert from BL to null-tetrad components; retain the pex polar equations. *)
  an = (\[Omega]^2 at - \[CapitalDelta] ar + a a\[Phi])/(2 \[CapitalSigma]);
  A1 = a\[Theta];
  A2 = -a Sin[\[Theta]] at - a\[Phi]/Sin[\[Theta]];
  A3 = a (L - a En Sin[\[Theta]]^2) at/\[CapitalSigma] + u\[Theta] a\[Theta]/\[CapitalSigma] +
    (L - a En Sin[\[Theta]]^2) a\[Phi]/(\[CapitalSigma] Sin[\[Theta]]^2);

  d\[Psi]\[Theta]d\[Lambda] = Sqrt[\[Beta]zp - \[Beta] z] (
      1 + (1 - zm) \[CapitalSigma] A1 Cos[\[Psi]\[Theta][s]]/(Sqrt[zm] (\[Beta]zp - \[Beta] zm) Sin[\[Theta]])) +
    Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] H a \[CapitalDelta] (A3 - 2 ur an)/(2 (\[Beta]zp - \[Beta] zm) un) +
    Cos[\[Psi]\[Theta][s]] Sin[\[Psi]\[Theta][s]] G A2/(\[Beta]zp - \[Beta] zm);
  dzmd\[Lambda] = ((1 - zm) dKd\[Lambda] - 2 (L - a (1 - zm) En) (dLd\[Lambda] - a (1 - zm) dEd\[Lambda]))/
    (\[Beta]zp - \[Beta] zm);
  dxd\[Lambda] = -dzmd\[Lambda]/(2 x[s]);

  (* The first six equations use the selected parametrisation. *)
  EoM = {
    D[p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dpd\[Lambda],
    D[\[Alpha]p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Alpha]d\[Lambda],
    If[equatorialQ, Nothing, D[x[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] dxd\[Lambda]],
    D[\[Beta]p[s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Beta]d\[Lambda],
    If[equatorialQ, Nothing, D[\[Psi]\[Theta][s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Psi]\[Theta]d\[Lambda]],
    D[\[Phi][s], s] == If[minoQ, 1, 1/dtd\[Lambda]] d\[Phi]d\[Lambda],
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

  s = If[minoQ, \[Lambda], t];
  unknowns = {p, \[Alpha]p, If[equatorialQ, Nothing, x], \[Beta]p, If[equatorialQ, Nothing, \[Psi]\[Theta]], \[Phi], If[minoQ, t, Nothing]};
  limit = Replace[OptionValue["IntegrationLimit"], Automatic -> If[minoQ, 10^4, 10^7]];
  pMin = OptionValue["pMin"];
  pMinQ = NumericQ[pMin];
  deltaPSep = \[Eta];
  pSep[ee_?NumericQ, xx_?NumericQ] := Quiet[KerrGeoSeparatrix[a, ee, xx]];

  (* Use the same separatrix buffer as the component branch of GenericKerrpexBL. *)
  events = With[{u = s}, {
    If[pMinQ,
      WhenEvent[p[u] - pMin == 0, stopReason = "pMin"; "StopIntegration"],
      Nothing],
    WhenEvent[p[u] - pSep[eccentricity[\[Alpha]p[u], \[Beta]p[u]], x[u]] - deltaPSep == 0,
      stopReason = "SeparatrixBuffer"; "StopIntegration"]
  }] /. equatorialRules;

  solve[] := NDSolve[
    Evaluate@Join[initialConditions, EoM, events],
    unknowns,
    {s, 0, limit},
    AccuracyGoal -> OptionValue["AccuracyGoal"],
    PrecisionGoal -> OptionValue["PrecisionGoal"],
    Method -> {"EquationSimplification" -> "Solve"},
    StepMonitor :> (progress = s)
  ];
  sol = If[monitorQ,
    Monitor[solve[], Row[{If[minoQ, "\[Lambda]", "t"], " = ", progress}]],
    solve[]
  ];
  If[! MatchQ[sol, {{__Rule}}],
    Message[GenericKerrREGBL::nosol];
    Return[$Failed]
  ];

  rules = First[sol];
  {psol, \[Alpha]psol, \[Beta]psol, \[Phi]sol} = {p, \[Alpha]p, \[Beta]p, \[Phi]} /. rules;
  If[equatorialQ,
    xsol[u_] := Sign[x0];
    \[Psi]\[Theta]sol[u_] := Missing["UndefinedForEquatorialOrbit"],
    {xsol, \[Psi]\[Theta]sol} = {x, \[Psi]\[Theta]} /. rules
  ];
  If[minoQ, tsol = t /. rules, tsol[\[Tau]_?NumericQ] := \[Tau]];
  StopMessage[KerrOsculatingOrbitalElements, If[minoQ, "\[Lambda]", "t"], psol["Domain"][[1, 2]], limit, stopReason];

  esol[u_?NumericQ] := If[TrueQ[e0 == 0 && u == 0], 0,
    eccentricity[\[Alpha]psol[u], \[Beta]psol[u]]];
  \[Psi]rsol[u_?NumericQ] := If[TrueQ[esol[u] == 0],
    Missing["UndefinedAtZeroEccentricity"], ArcTan[\[Beta]psol[u], \[Alpha]psol[u]]];

  (* Derived quantities; r remains defined even when the radial anomaly is not. *)
  zmsol[u_] := 1 - xsol[u]^2;
  rsol[u_] := psol[u]/(1 + \[Beta]psol[u]);
  \[Theta]sol[u_] := If[equatorialQ, \[Pi]/2, ArcCos[Sqrt[zmsol[u]] Cos[\[Psi]\[Theta]sol[u]]]];
  Ensol[u_] := Energy[a, psol[u], esol[u], xsol[u]];
  Lsol[u_] := AngularMomentum[a, psol[u], esol[u], xsol[u]];
  Qsol[u_] := CarterConstant[a, psol[u], esol[u], xsol[u]];
  Ksol[u_] := Qsol[u] + (Lsol[u] - a Ensol[u])^2;
  r1sol[u_] := psol[u]/(1 - esol[u]);
  r2sol[u_] := psol[u]/(1 + esol[u]);
  \[Iota]sol[u_] := ArcCos[Lsol[u]/Sqrt[Ksol[u] + 2 a Lsol[u] Ensol[u] - a^2 Ensol[u]^2]];

  <|
    "t" -> tsol,
    "r" -> rsol,
    "\[Theta]" -> \[Theta]sol,
    "\[Phi]" -> \[Phi]sol,
    "En" -> Ensol,
    "L" -> Lsol,
    "K" -> Ksol,
    "Q" -> Qsol,
    "p" -> psol,
    "e" -> esol,
    "x" -> xsol,
    "\[Iota]" -> \[Iota]sol,
    "\[Psi]r" -> \[Psi]rsol,
    "\[Psi]\[Theta]" -> \[Psi]\[Theta]sol,
    "r1" -> r1sol,
    "r2" -> r2sol,
    "z1" -> zmsol,
    "\[Alpha]p" -> \[Alpha]psol,
    "\[Beta]p" -> \[Beta]psol,
    "limit" -> psol["Domain"][[1, 2]]
  |>
]


