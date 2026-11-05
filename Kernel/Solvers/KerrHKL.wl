(* ::Package:: *)

(* ::Title:: *)
(*REG with h, k and Lambda: scalar force-constants formulation*)

(* The radial variables are the Standard REG components:
   \[Alpha]p = e Sin[\[Psi]r], \[Beta]p = e Cos[\[Psi]r]. The angular variables are
   stereographic coordinates h,k of the unit normal H and the phase \[CapitalLambda]
   in its tangent plane. n is the radial unit direction and m = H cross n.
   J = j H, with j^2 = L^2 + Q - \[Beta] n_z^2 and \[Beta] = a^2 (1-En^2).
   The geodesic scale \[ScriptL] = L/x differs from j away from a polar turning point. *)

(* h^2+k^2 grows without bound at the excluded pole of a fixed chart.
   Stop at 100 before this coordinate singularity; it is not a physical boundary. *)
$hklChartLimit = 100;

(* sin^2(theta) below this tolerance is treated as the BL axis for angle output
   and custom BL forces. The regular built-in forces do not use this cutoff. *)
$hklAxisTolerance = 10^-28;

(* ::Section:: *)
(*Constants of motion*)

(* Turning-point construction: W. Schmidt (2002), Appendix B, Eqs. (B.1)-(B.10),
   https://arxiv.org/abs/gr-qc/0202090. The HKLambda polynomial form is derived
   in the OOE manuscript (in preparation), appendix "Algebraic reconstruction of E and j".
   f_i En^2 - 2 g_i En j - h_i j^2 - d_i = 0, i=0,1, are the mean and
   divided difference of u^4 R(p/u) at u=1+e and u=1-e.
   Solve qa y^2 + qb y + qc = 0 for y = j/En, then recover En and j.
   Arguments are (a,p,e^2,nz2,Hz), with nz2 = cos(theta)^2 and Hz = H_z.
   NumericQ keeps the installed formulas out of NDSolve's symbolic expansion. *)
Module[{a, p, e2, nz2, Hz, En, j, f0, f1, g0, g1, h0c, h1c, d0c, d1c,
    qa, qb, qc, discriminant, y, aa, pp, ee, zz, hh},
  f0 = p^4 + a^2 (1 + nz2) p^2 (1 + e2) +
    2 a^2 (1 - nz2) p (1 + 3 e2) + a^4 nz2 (1 + 6 e2 + e2^2);
  f1 = 2 a^2 (1 + nz2) p^2 +
    2 a^2 (1 - nz2) p (3 + e2) + 4 a^4 nz2 (1 + e2);
  g0 = 2 a p Hz (1 + 3 e2); g1 = 2 a p Hz (3 + e2);
  h0c = p^2 (1 + e2) - 2 p (1 + 3 e2) +
    a^2 (1 - Hz^2) (1 + 6 e2 + e2^2);
  h1c = 2 p^2 - 2 p (3 + e2) + 4 a^2 (1 - Hz^2) (1 + e2);
  d0c = p^4 - 2 p^3 + a^2 (1 + nz2) p^2 (1 + e2) -
    2 a^2 nz2 p (1 + 3 e2) + a^4 nz2 (1 + 6 e2 + e2^2);
  d1c = -2 p^3 + 2 a^2 (1 + nz2) p^2 -
    2 a^2 nz2 p (3 + e2) + 4 a^4 nz2 (1 + e2);
  qa = d0c h1c - d1c h0c;
  qb = 2 (d0c g1 - d1c g0);
  qc = d1c f0 - d0c f1;
  discriminant = Sqrt[qb^2 - 4 qa qc];
  (* Use the positive root without subtracting nearly equal numbers. Selecting
     its numerator and denominator separately also permits symbolic substitution. *)
  y = Piecewise[{{-2 qc, qb >= 0}}, -qb + discriminant]/
    Piecewise[{{qb + discriminant, qb >= 0}}, 2 qa];
  En = Sqrt[d0c/(f0 - 2 g0 y - h0c y^2)];
  j = y En;

  hklEnergy[aa_?NumericQ, pp_?NumericQ, ee_?NumericQ, zz_?NumericQ, hh_?NumericQ] =
    En /. {a -> aa, p -> pp, e2 -> ee, nz2 -> zz, Hz -> hh};
  hklAngularScale[aa_?NumericQ, pp_?NumericQ, ee_?NumericQ, zz_?NumericQ, hh_?NumericQ] =
    j /. {a -> aa, p -> pp, e2 -> ee, nz2 -> zz, Hz -> hh};
];

(* The pair is used only for initial conditions, output and pointwise checks. *)
hklConstants[a_, p_, e2_, nz_, Hz_] :=
  {hklEnergy[a, p, e2, nz^2, Hz], hklAngularScale[a, p, e2, nz^2, Hz]};

(* Q/(\[ScriptL]^2+\[Beta]) = 1-x^2 is accurate near the equator; L/\[ScriptL] is accurate near x=0. *)
hklInclination[L_?NumericQ, Q_?NumericQ, \[ScriptL]_?NumericQ, \[Beta]_?NumericQ] :=
  If[Q < (\[ScriptL]^2 + \[Beta])/2, Sign[L] Sqrt[1 - Q/(\[ScriptL]^2 + \[Beta])], L/\[ScriptL]];

(* ::Section:: *)
(*Frame and initial data*)

(* h = H_x/(1+chart H_z), k = H_y/(1+chart H_z), with chart = +1 or -1.
   Rows {f,g,H} form an orthonormal frame with f cross g = H.
   n = Cos[\[CapitalLambda]] f + Sin[\[CapitalLambda]] g; m = H cross n. *)
hklFrame[h_, k_, chart_] := With[{d = 1 + h^2 + k^2},
  {{1 - 2 h^2/d, -2 h k/d, -2 chart h/d},
   {-2 chart h k/d, chart (1 - 2 k^2/d), -2 k/d},
   {2 h/d, 2 k/d, chart (1 - h^2 - k^2)/d}}
];

(* Initial direction and angular momentum, including the limiting tangent at a BL pole.
   Phi rotates both vectors about the spin axis. Guard digits are supplied by hklSystem. *)
hklInitialState[a_, {p_, e_, x_, \[Psi]r_, \[Psi]\[Theta]_, \[Phi]_}, chart_] := Module[
  {En, \[ScriptL], z, sinTheta, nu, n, J, H, h, k, f, g, rotate},
  (* Exact initial equatorial coordinates avoid taking a square root of an approximate
     zero, which halves its accuracy. h and k are still freely evolved afterwards. *)
  If[TrueQ[Abs[x] == 1],
    If[chart x < 0, Return[$Failed]];
    Return[{p, e Sin[\[Psi]r], e Cos[\[Psi]r], 0, 0, chart \[Phi]}]];
  (* At a polar turning point n_z^2 = 1-x^2, H_z = x and j = \[ScriptL].
     The initial phase then determines the direction n and angular momentum J. *)
  {En, \[ScriptL]} = {hklEnergy[a, p, e^2, 1 - x^2, x],
    hklAngularScale[a, p, e^2, 1 - x^2, x]};
  z = Sqrt[1 - x^2] Cos[\[Psi]\[Theta]];
  sinTheta = Sqrt[1 - z^2];
  n = {sinTheta, 0, z};
  J = If[TrueQ[sinTheta == 0], {0, z \[ScriptL], 0},
    nu = Sqrt[\[ScriptL]^2 + a^2 (1 - En^2) sinTheta^2];
    {-\[ScriptL] x z/sinTheta, Sqrt[1 - x^2] Sin[\[Psi]\[Theta]] nu/sinTheta, \[ScriptL] x}];
  rotate = {{Cos[\[Phi]], -Sin[\[Phi]], 0}, {Sin[\[Phi]], Cos[\[Phi]], 0}, {0, 0, 1}};
  n = rotate.n;
  H = rotate.J/Sqrt[J.J];
  If[TrueQ[1 + chart H[[3]] == 0], Return[$Failed]];
  {h, k} = H[[1 ;; 2]]/(1 + chart H[[3]]);
  If[!TrueQ[h^2 + k^2 < $hklChartLimit], Return[$Failed]];
  {f, g} = Take[hklFrame[h, k, chart], 2];
  {p, e Sin[\[Psi]r], e Cos[\[Psi]r], h, k, ArcTan[n.f, n.g]}
];


(* ::Section:: *)
(*Force components*)

(* ::Text:: *)
(*The HKLambda equations use covariant force components {at, ar, a\[Phi], AH}.
  AH = -H_z a\[Theta]/sin(theta) - m_z a\[Phi]/sin(theta)^2 is the angular
  covector contracted with H; it replaces a\[Theta] and is placed last. The factors 1/sin theta
  in the BL-to-frame transformation are cancelled analytically for each built-in
  force.
  The driver's usual ScalesWithMassRatio setting still supplies the only \[Epsilon] factor.
  Matching the model's Function, rather than its display Name, preserves custom models
  whose name happens to be the same as a built-in model.*)


hklForceModelDriver[model_ForceModel] := Module[{evaluate},
  evaluate = Switch[model["Function"],
    gasDragComponents, Function[state, hklGasDrag[state, model["Parameters"]["Coefficient"]]],
    emConservativeComponents, hklEMConservative,
    fastGSFForce, hklFastGSF,
    _, Function[state, Table[hklCustomForceComponent[model, i,
      Sequence @@ Lookup[state, $hklCustomForceKeys]], {i, 4}]]
  ];
  <|"Type" -> "Force", "ScalesWithMassRatio" -> model["ScalesWithMassRatio"], "Function" -> evaluate|>
];


(* ::Subsection:: *)
(*The three built-in forces*)


hklGasDrag[g_Association, coefficient_] := coefficient {
  g["En"] - g["\[CapitalSigma]"]/g["dtd\[Lambda]"],
  -g["ur"], -g["L"], 0
};


(* The same Lorentz force as EMConservative, using its stationary, axisymmetric potential:
   A_t = -a + a r (1+n_z^2)/\[CapitalSigma] and A_phi = (1-n_z^2) B,
   B = (r^2+a^2)/2 - a^2 r (1+n_z^2)/\[CapitalSigma].
   The derivatives are with respect to r and n_z, so their force combinations
   are finite at n_z = +/-1. In particular wPhi = sin^2 theta \[Phi]' = L + \[ScriptCapitalC] sin^2 theta. *)
hklEMConservative[g_Association] := Module[
  {a, r, nz, mz, Hz, En, j, \[CapitalSigma], drd\[Lambda], dtd\[Lambda], dnzd\[Lambda], wPhi,
   dAtr, dAtz, B, dBr, dBz, at, ar, a\[Phi], AH},
  {a, r, nz, mz, Hz, En, j, \[CapitalSigma], drd\[Lambda], dtd\[Lambda]} =
    Lookup[g, {"a", "r", "nz", "mz", "Hz", "En", "j", "\[CapitalSigma]", "drd\[Lambda]", "dtd\[Lambda]"}];
  dAtr = a (1 + nz^2) (a^2 nz^2 - r^2)/\[CapitalSigma]^2;
  dAtz = 2 a r nz (r^2 - a^2)/\[CapitalSigma]^2;
  B = (r^2 + a^2)/2 - a^2 r (1 + nz^2)/\[CapitalSigma];
  dBr = r - a dAtr;
  dBz = -a dAtz;
  dnzd\[Lambda] = j mz;
  wPhi = g["L"] + g["\[ScriptCapitalC]"] g["sin2"];
  at = -(dAtr drd\[Lambda] + dAtz dnzd\[Lambda])/\[CapitalSigma];
  ar = (dAtr dtd\[Lambda] + dBr wPhi)/\[CapitalSigma];
  a\[Phi] = -(g["sin2"] dBr drd\[Lambda] + (g["sin2"] dBz - 2 nz B) dnzd\[Lambda])/\[CapitalSigma];
  AH = (dAtz dtd\[Lambda] Hz + dBr drd\[Lambda] mz + dBz (Hz wPhi + mz dnzd\[Lambda]) -
    2 B nz (j + g["\[ScriptCapitalC]"] Hz))/\[CapitalSigma];
  {at, ar, a\[Phi], AH}
];


(* Extract a fit component only after its arguments are numeric; symbolic equations
   retain this call until NDSolve supplies the current orbit. *)
hklFastGSFComponent[i_, p_?NumericQ, e_?NumericQ, \[Psi]r_?NumericQ] :=
  fastGSFComponents[p, e, \[Psi]r][[i]];


(* FastGSF is the same Schwarzschild fit as fastGSFForce. Its angular force lies
   along m, so AH = 0. This also covers inclined and polar Schwarzschild orbits. *)
hklFastGSF[g_Association] := Module[{fr, fPhi, ar, tangent, a\[Phi], at},
  {fr, fPhi} = Table[hklFastGSFComponent[i, g["p"], g["e"], g["\[Psi]r"]], {i, 2}];
  ar = g["\[CapitalSigma]"]/g["\[CapitalDelta]"] fr;
  tangent = g["r"]^2 fPhi g["j"]/Sqrt[g["L"]^2 + g["Q"]];
  a\[Phi] = g["Hz"] tangent;
  at = -(g["drd\[Lambda]"] ar + g["j"] tangent + g["\[ScriptCapitalC]"] a\[Phi])/g["dtd\[Lambda]"];
  {at, ar, a\[Phi], 0}
];


(* ::Subsection:: *)
(*Custom BL callbacks*)


(* NDSolve needs the state as numeric arguments to the component function.
   Reconstruct only the fields used by the BL callback and force transformation. *)
$hklCustomForceKeys = {"a", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]", "t",
  "sin2", "drd\[Lambda]", "j", "mz", "L", "\[ScriptCapitalC]", "dtd\[Lambda]", "Hz"};

hklCustomForceComponent[model_ForceModel, i_, values__?NumericQ] :=
  hklCustomForce[model, AssociationThread[$hklCustomForceKeys, {values}]][[i]];


(* The existing three-spatial-component callback remains available away from the axis.
   \[Psi]r, \[Psi]\[Theta] and \[Phi] are wrapped to their principal values;
   the force must be 2 pi periodic in these angular arguments. t is coordinate
   time even in Mino-time integration, and the force may depend arbitrarily on t.
   On the axis an arbitrary BL callback has no prescribed continuation,
   so it is rejected explicitly. This test is never used by the regular built-in paths. *)
hklCustomForce[model_ForceModel, g_Association] := Module[{spatial, ar, a\[Theta], a\[Phi], at, AH, sinTheta},
  If[TrueQ[g["sin2"] < $hklAxisTolerance], Message[OsculatingInspiral::hklaxis]; Return[ConstantArray[Indeterminate, 4]]];
  spatial = forceModelComponents[model, Sequence @@ Lookup[g,
    {"a", "p", "e", "x", "\[Psi]r", "\[Psi]\[Theta]", "\[Phi]", "t"}]];
  If[FailureQ[spatial], Return[ConstantArray[Indeterminate, 4]]];
  {ar, a\[Theta], a\[Phi]} = spatial;
  sinTheta = Sqrt[g["sin2"]];
  at = -(g["drd\[Lambda]"] ar - g["j"] g["mz"] a\[Theta]/sinTheta +
    (g["L"]/g["sin2"] + g["\[ScriptCapitalC]"]) a\[Phi])/g["dtd\[Lambda]"];
  AH = -g["Hz"] a\[Theta]/sinTheta - g["mz"] a\[Phi]/g["sin2"];
  {at, ar, a\[Phi], AH}
];


(* ::Section:: *)
(*Equations of motion*)

hklSystem[\[Epsilon]_, a_, initial : {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, \[Phi]0_}, drivers_List, settings_Association] := Module[
  {minoQ, s, precision, initialPrecision, chart, initialState, initialConditions, initialRates,
   p, \[Alpha]p, \[Beta]p, h, k, \[CapitalLambda], t, \[Lambda], e2, e, d, nz,
   mz, nz2, Hz, En, j, L, Q, K, \[Beta], \[ScriptL], x, w, r, \[CapitalSigma], \[CapitalDelta],
   F, Z, P, Dp, Ap, Bp, Hp, CAlpha, JAlpha, drd\[Lambda], dtd\[Lambda], \[ScriptCapitalC], sin2, \[Psi]r, \[Psi]\[Theta], nx, ny, \[Phi], state,
   at, ar, a\[Phi], AH, \[ScriptCapitalB]\[Theta], dpd\[Lambda], d\[Alpha]d\[Lambda], d\[Beta]d\[Lambda], dhd\[Lambda], dkd\[Lambda], d\[CapitalLambda]d\[Lambda], toS,
   EoM, unknowns, events, outputs, deltaPSep, angleTolerance, minimumP, location},

  minoQ = settings["Mino"];
  deltaPSep = Replace[settings["SeparatrixBuffer"], Except[_?NumericQ] -> \[Epsilon]];
  If[!TrueQ[RadialBufferMargin[a, p0, e0, x0, deltaPSep] > 0],
    Message[OsculatingInspiral::sep, deltaPSep, p0]; Return[$Failed]];
  s = If[minoQ, \[Lambda], t];
  chart = Replace[settings["AngularChart"], Automatic -> If[x0 < 0, -1, 1]];
  precision = Replace[settings["WorkingPrecision"], Automatic -> MachinePrecision];
  (* Extra digits reduce cancellation in the initial coordinate conversion:
     50 for machine input, otherwise 30 beyond WorkingPrecision. They do not
     increase the accuracy of the supplied initial data. *)
  initialPrecision = If[precision === MachinePrecision, 50, precision + 30];
  initialState = hklInitialState[SetPrecision[a, initialPrecision], SetPrecision[initial, initialPrecision], chart];
  If[initialState === $Failed, Message[OsculatingInspiral::chart, chart]; Return[$Failed]];
  initialState = N[initialState, precision];

  (* Six orbital variables; Mino-time evolution also integrates coordinate time t. *)
  unknowns = {p, \[Alpha]p, \[Beta]p, h, k, \[CapitalLambda], If[minoQ, t, Nothing]};
  initialConditions = Thread[(#[0] & /@ unknowns) ==
    If[minoQ, Append[initialState, 0], initialState]];

  (* The osculating geodesic, expressed in the regular frame. *)
  e2 = \[Alpha]p[s]^2 + \[Beta]p[s]^2;
  e = Sqrt[e2];
  d = 1 + h[s]^2 + k[s]^2;
  nz = -2 (chart h[s] Cos[\[CapitalLambda][s]] + k[s] Sin[\[CapitalLambda][s]])/d;
  mz = 2 (chart h[s] Sin[\[CapitalLambda][s]] - k[s] Cos[\[CapitalLambda][s]])/d;
  nz2 = nz^2;
  Hz = chart (1 - h[s]^2 - k[s]^2)/d;
  En = hklEnergy[a, p[s], e2, nz2, Hz];
  j = hklAngularScale[a, p[s], e2, nz2, Hz];
  L = j Hz;
  \[Beta] = a^2 (1 - En^2);
  Q = 4 j^2 (h[s]^2 + k[s]^2)/d^2 + \[Beta] nz2;
  K = Q + (L - a En)^2;
  \[ScriptL] = Sqrt[(L^2 + Q - \[Beta] + Sqrt[(L^2 + Q - \[Beta])^2 + 4 \[Beta] L^2])/2];
  x = hklInclination[L, Q, \[ScriptL], \[Beta]];
  w = 1 + \[Beta]p[s];
  r = p[s]/w;
  \[CapitalSigma] = r^2 + a^2 nz2;
  \[CapitalDelta] = r^2 - 2 r + a^2;
  F = (r^2 + a^2) En - a L;
  Z = p[s] - K (3 - e2 + 2 \[Beta]p[s])/p[s] +
    a^2 Q (4 - e2 + 4 \[Beta]p[s] + \[Beta]p[s]^2)/p[s]^2;
  P = Sqrt[Z];
  drd\[Lambda] = p[s] \[Alpha]p[s] P/w^2;
  dtd\[Lambda] = En ((r^2 + a^2)^2/\[CapitalDelta] - a^2 (1 - nz2)) + a L (1 - (r^2 + a^2)/\[CapitalDelta]);
  \[ScriptCapitalC] = a (2 r En - a L)/\[CapitalDelta];

  (* Existing ForceModel callbacks also receive \[Phi] and coordinate time.
     Built-in adapters use the regular scalar geometry directly. Custom callbacks
     receive the usual elements and phases; their definitions are not rewritten. *)
  sin2 = Hz^2 + mz^2;
  \[Psi]r = phaseAngle[\[Alpha]p[s], \[Beta]p[s]];
  \[Psi]\[Theta] = phaseAngle[-j mz/Sqrt[\[ScriptL]^2 + \[Beta] sin2], nz];
  nx = Cos[\[CapitalLambda][s]] (1 - 2 h[s]^2/d) - 2 chart h[s] k[s] Sin[\[CapitalLambda][s]]/d;
  ny = -2 h[s] k[s] Cos[\[CapitalLambda][s]]/d + chart (1 - 2 k[s]^2/d) Sin[\[CapitalLambda][s]];
  \[Phi] = phaseAngle[ny, nx];
  state = <|"a" -> a, "p" -> p[s], "e" -> e, "x" -> x,
    "\[Alpha]p" -> \[Alpha]p[s], "\[Beta]p" -> \[Beta]p[s], "\[Psi]r" -> \[Psi]r,
    "\[Psi]\[Theta]" -> \[Psi]\[Theta], "\[Phi]" -> \[Phi], "t" -> If[minoQ, t[s], s],
    "En" -> En, "j" -> j, "L" -> L, "Q" -> Q, "K" -> K,
    "r" -> r, "\[CapitalSigma]" -> \[CapitalSigma], "\[CapitalDelta]" -> \[CapitalDelta], "F" -> F,
    "nz" -> nz, "mz" -> mz, "Hz" -> Hz, "sin2" -> sin2,
    "drd\[Lambda]" -> drd\[Lambda], "ur" -> drd\[Lambda]/\[CapitalDelta], "dtd\[Lambda]" -> dtd\[Lambda], "\[ScriptCapitalC]" -> \[ScriptCapitalC]|>;
  {at, ar, a\[Phi], AH} = TotalForce[drivers, state, \[Epsilon]];

  (* The radial REG rates, written directly in the force components.
     No term divides by e or either eccentricity component. *)
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

  (* \[ScriptCapitalC] is the frame-dragging contribution. \[ScriptCapitalB]\[Theta] combines
     the geodesic polar term and the normal force AH. All rates below are with
     respect to Mino time; toS converts them to the chosen parameter s. *)
  \[ScriptCapitalB]\[Theta] = (a^2 (1 - En^2) nz Hz - \[CapitalSigma] AH)/j;
  dhd\[Lambda] = -\[ScriptCapitalC] k[s] - d \[ScriptCapitalB]\[Theta] Sin[\[CapitalLambda][s]]/2;
  dkd\[Lambda] = \[ScriptCapitalC] h[s] + chart d \[ScriptCapitalB]\[Theta] Cos[\[CapitalLambda][s]]/2;
  d\[CapitalLambda]d\[Lambda] = j + chart \[ScriptCapitalC] + \[ScriptCapitalB]\[Theta] (h[s] Cos[\[CapitalLambda][s]] + chart k[s] Sin[\[CapitalLambda][s]]);

  toS = If[minoQ, 1, 1/dtd\[Lambda]];
  EoM = {
    D[p[s], s] == toS dpd\[Lambda],
    D[\[Alpha]p[s], s] == toS d\[Alpha]d\[Lambda],
    D[\[Beta]p[s], s] == toS d\[Beta]d\[Lambda],
    D[h[s], s] == toS dhd\[Lambda],
    D[k[s], s] == toS dkd\[Lambda],
    D[\[CapitalLambda][s], s] == toS d\[CapitalLambda]d\[Lambda],
    If[minoQ, D[t[s], s] == dtd\[Lambda], Nothing]
  };
  initialRates = Check[(Last /@ EoM) /. s -> 0 /. (initialConditions /. Equal -> Rule), $Failed];
  If[!VectorQ[initialRates, realQ], Message[OsculatingInspiral::hklinitial]; Return[$Failed]];

  (* Stop at pMin, the separatrix buffer, or the boundary of the chosen chart. *)
  minimumP = settings["pMin"];
  location = "LocationMethod" -> {"Brent", AccuracyGoal -> 8, PrecisionGoal -> 8};
  events = With[
    {u = s, spin = a, buffer = deltaPSep, pThreshold = minimumP,
     eventLocation = location, inclination = x, eccentricity = e},
    {If[NumericQ[pThreshold], stopEvent[p[u] - pThreshold == 0, "pMin", eventLocation], Nothing],
     stopEvent[RadialBufferMargin[spin, p[u], eccentricity, inclination, buffer] == 0,
       "SeparatrixBuffer", eventLocation],
     stopEvent[h[u]^2 + k[u]^2 == $hklChartLimit, "AngularChartBoundary", eventLocation]}];
  angleTolerance = radialAngleTolerance[settings];
  outputs[rules_] := hklOutputs[a, chart, initial,
    Join[{p, \[Alpha]p, \[Beta]p, h, k, \[CapitalLambda]} /. rules,
      {If[minoQ, t /. rules, Function[{u}, u, {Listable}]]}], angleTolerance];
  <|"Variable" -> s, "Unknowns" -> unknowns, "Equations" -> Join[initialConditions, EoM],
    "Events" -> events,
    "Method" -> {"ExplicitRungeKutta", "DifferenceOrder" -> 8, "EquationSimplification" -> "Solve",
      "StiffnessTest" -> {True, "MaxRepetitions" -> {100, 100}}},
    "Outputs" -> outputs|>
];

(* ::Section:: *)
(*Geometry for output*)

(* Reconstruct the direction and constants from an integrated state. The frame
   avoids inverse sin(theta); x and the phases are recovered for output and
   custom force callbacks. Built-in forces use n_z, m_z and H_z directly. *)
hklGeometry[a_, {p_, \[Alpha]p_, \[Beta]p_, h_, k_, \[CapitalLambda]_}, chart_, time_] := Module[
  {f, g, H, n, m, nz, mz, Hz, En, j, L, Q, \[Beta], K, \[ScriptL]2, \[ScriptL], x,
   r, \[CapitalDelta], \[CapitalSigma], Z, P, drd\[Lambda], dtd\[Lambda], \[ScriptCapitalC], sin2, \[Alpha]\[Theta], \[Psi]\[Theta], \[Phi]},
  {f, g, H} = hklFrame[h, k, chart];
  n = Cos[\[CapitalLambda]] f + Sin[\[CapitalLambda]] g;
  m = -Sin[\[CapitalLambda]] f + Cos[\[CapitalLambda]] g;
  {nz, mz, Hz} = {n[[3]], m[[3]], H[[3]]};
  {En, j} = hklConstants[a, p, \[Alpha]p^2 + \[Beta]p^2, nz, Hz];
  L = j Hz;
  \[Beta] = a^2 (1 - En^2);
  Q = j^2 (H[[1]]^2 + H[[2]]^2) + \[Beta] nz^2;
  K = Q + (L - a En)^2;
  \[ScriptL]2 = (L^2 + Q - \[Beta] + Sqrt[(L^2 + Q - \[Beta])^2 + 4 \[Beta] L^2])/2;
  \[ScriptL] = Sqrt[\[ScriptL]2];
  x = hklInclination[L, Q, \[ScriptL], \[Beta]];
  r = p/(1 + \[Beta]p);
  \[CapitalDelta] = r^2 - 2 r + a^2;
  \[CapitalSigma] = r^2 + a^2 nz^2;
  Z = p - K (3 - \[Alpha]p^2 - \[Beta]p^2 + 2 \[Beta]p)/p +
    a^2 Q (4 - \[Alpha]p^2 - \[Beta]p^2 + 4 \[Beta]p + \[Beta]p^2)/p^2;
  P = Sqrt[Z];
  drd\[Lambda] = p \[Alpha]p P/(1 + \[Beta]p)^2;
  dtd\[Lambda] = En ((r^2 + a^2)^2/\[CapitalDelta] - a^2 (1 - nz^2)) + a L (1 - (r^2 + a^2)/\[CapitalDelta]);
  \[ScriptCapitalC] = a (2 r En - a L)/\[CapitalDelta];
  sin2 = Hz^2 + mz^2;
  \[Alpha]\[Theta] = -j mz/Sqrt[\[ScriptL]2 + \[Beta] sin2];
  \[Psi]\[Theta] = phaseAngle[\[Alpha]\[Theta], nz];
  \[Phi] = phaseAngle[n[[2]], n[[1]]];
  <|"a" -> a, "p" -> p, "e" -> Sqrt[\[Alpha]p^2 + \[Beta]p^2], "x" -> x,
    "\[Alpha]p" -> \[Alpha]p, "\[Beta]p" -> \[Beta]p, "\[Psi]r" -> phaseAngle[\[Alpha]p, \[Beta]p],
    "\[Psi]\[Theta]" -> \[Psi]\[Theta], "\[Phi]" -> \[Phi], "t" -> time,
    "h" -> h, "k" -> k, "\[CapitalLambda]" -> \[CapitalLambda], "d" -> 1 + h^2 + k^2,
    "n" -> n, "m" -> m, "H" -> H, "nz" -> nz, "mz" -> mz, "Hz" -> Hz,
    "En" -> En, "j" -> j, "L" -> L, "Q" -> Q, "K" -> K, "\[Beta]" -> \[Beta],
    "\[ScriptL]" -> \[ScriptL], "r" -> r, "\[CapitalDelta]" -> \[CapitalDelta], "\[CapitalSigma]" -> \[CapitalSigma],
    "F" -> (r^2 + a^2) En - a L, "Z" -> Z, "drd\[Lambda]" -> drd\[Lambda], "ur" -> drd\[Lambda]/\[CapitalDelta],
    "dtd\[Lambda]" -> dtd\[Lambda], "\[ScriptCapitalC]" -> \[ScriptCapitalC], "sin2" -> sin2, "\[Alpha]\[Theta]" -> \[Alpha]\[Theta]|>
];


(* ::Section:: *)
(*Output in the existing interface*)


(* Recover continuous phases from their cosine/sine pairs by counting turns
   on the solution grid. The interpolated reference fixes the branch at each time. *)
hklContinuousPhase[pair_, grid_, initial_] := Module[{phases, increments, turns, reference},
  phases = (phaseAngle @@ Reverse[pair[#]]) & /@ grid;
  increments = wrapAngle /@ Differences[phases];
  turns = FoldList[Plus, initial + wrapAngle[First[phases] - initial], increments];
  reference = Interpolation[Transpose[{grid, turns}], InterpolationOrder -> 1];
  Function[{u}, reference[u] + wrapAngle[(phaseAngle @@ Reverse[pair[u]]) - reference[u]], {Listable}]
];


(* The radial phase, counted as above but robust near e = 0, where it can turn
   by nearly pi between samples:
   - Samples within roundoff of e = 0 have no direction and are skipped.
   - An interval over which the phase changes by more than pi/2 is halved, up to
     50 times, until every change is smaller. A change that stays larger, or that
     spans a sample at e = 0, is taken in the sense in which the phase turns,
     the sign of beta alpha' - alpha beta'.
   - If e = 0 at the start, psi_r0 is undefined, and the first resolved phase is
     taken in [-3pi/4, 5pi/4). A circular orbit becomes eccentric at psi_r = 0 or
     pi under a tangential force and at +-pi/2 under a radial one, so all four
     starts lie away from the branch cut. *)
hklRadialPhase[\[Alpha]p_, \[Beta]p_, grid_, \[Psi]r0_] := Module[
  {floor, d\[Alpha]p, d\[Beta]p, resolvedQ, phase, sense, turn, refine, \[Alpha]s, \[Beta]s, resolved, points, start,
   pieces, knots, reference},
  floor = 10^(2 - Replace[Precision[Last[grid]], MachinePrecision -> $MachinePrecision]);
  {d\[Alpha]p, d\[Beta]p} = Derivative[1] /@ {\[Alpha]p, \[Beta]p};
  resolvedQ[u_] := \[Alpha]p[u]^2 + \[Beta]p[u]^2 > floor^2;
  phase[u_] := ArcTan[\[Beta]p[u], \[Alpha]p[u]];
  sense[u_] := Sign[\[Beta]p[u] d\[Alpha]p[u] - \[Alpha]p[u] d\[Beta]p[u]];
  (* d, or d +- 2pi if that turns in the sense s instead *)
  turn[d_, s_] := Which[s > 0 && d < 0, d + 2 \[Pi], s < 0 && d > 0, d - 2 \[Pi], True, d];
  (* The changes from {u1, psi1} to {u2, psi2}, each with the time at which its piece ends *)
  refine[{u1_, \[Psi]1_}, {u2_, \[Psi]2_}, depth_] := With[{d = wrapAngle[\[Psi]2 - \[Psi]1], um = (u1 + u2)/2},
    Which[
      Abs[d] <= \[Pi]/2, {{u2, d}},
      depth == 0 || !(u1 < um < u2) || !resolvedQ[um], {{u2, turn[d, Sign[sense[u1] + sense[u2]]]}},
      True, With[{middle = {um, phase[um]}},
        Join[refine[{u1, \[Psi]1}, middle, depth - 1], refine[middle, {u2, \[Psi]2}, depth - 1]]]]];

  {\[Alpha]s, \[Beta]s} = {\[Alpha]p[grid], \[Beta]p[grid]};
  resolved = Thread[\[Alpha]s^2 + \[Beta]s^2 > floor^2];
  If[FreeQ[resolved, True],
    Return[Function[{u}, \[Psi]r0 + wrapAngle[phaseAngle[\[Alpha]p[u], \[Beta]p[u]] - \[Psi]r0], {Listable}]]];
  points = Transpose[{Pick[grid, resolved], MapThread[ArcTan, Pick[#, resolved] & /@ {\[Beta]s, \[Alpha]s}]}];
  start = If[First[resolved], \[Psi]r0 + wrapAngle[points[[1, 2]] - \[Psi]r0], Mod[points[[1, 2]], 2 \[Pi], -3 \[Pi]/4]];
  pieces = Join @@ MapThread[refine[#1, #2, 50] &, {Most[points], Rest[points]}];
  knots = Transpose[{Prepend[pieces[[All, 1]], points[[1, 1]]], FoldList[Plus, start, pieces[[All, 2]]]}];
  (* Constant before the first resolved sample and after the last *)
  If[knots[[1, 1]] > First[grid], PrependTo[knots, {First[grid], start}]];
  If[knots[[-1, 1]] < Last[grid], AppendTo[knots, {Last[grid], knots[[-1, 2]]}]];
  reference = Interpolation[knots, InterpolationOrder -> 1];
  Function[{u}, reference[u] + wrapAngle[phaseAngle[\[Alpha]p[u], \[Beta]p[u]] - reference[u]], {Listable}]
];


(* In the chart's own hemisphere, chart Lambda gives the azimuth's turns and
   the remaining correction is bounded by pi/2, even near the BL axis.
   Outside this hemisphere, count turns from the direction on the denser grid. *)
hklAzimuth[chart_, {h_, k_, \[CapitalLambda]_}, grid_, denseGrid_, \[Phi]0_] := Module[
  {phasePair, ownHemisphere, \[Phi]Reference, \[Phi]Correction, \[Phi]Offset},
  phasePair[u_] := With[{frame = hklFrame[h[u], k[u], chart]},
    Take[Cos[\[CapitalLambda][u]] frame[[1]] + Sin[\[CapitalLambda][u]] frame[[2]], 2]];
  ownHemisphere = AllTrue[grid, h[#]^2 + k[#]^2 < 1 &];
  If[!ownHemisphere, Return[hklContinuousPhase[phasePair, denseGrid, \[Phi]0]]];

  \[Phi]Reference[u_] := chart \[CapitalLambda][u];
  \[Phi]Correction[u_] := wrapAngle[(phaseAngle @@ Reverse[phasePair[u]]) - \[Phi]Reference[u]];
  \[Phi]Offset = \[Phi]0 - (\[Phi]Reference[0] + \[Phi]Correction[0]);
  Function[{u}, \[Phi]Reference[u] + \[Phi]Correction[u] + \[Phi]Offset, {Listable}]
];


hklOutputs[a_, chart_, {p0_, e0_, x0_, \[Psi]r0_, \[Psi]\[Theta]0_, \[Phi]0_},
    {p_, \[Alpha]p_, \[Beta]p_, h_, k_, \[CapitalLambda]_, t_}, angleTolerance_] := Module[
  {geometry, cache = None, property, grid, denseGrid, \[Psi]r, \[Psi]\[Theta], \[Phi]Continuous,
   circular, equatorial, onAxis, polar, angle, frequency, e, \[Theta], \[Phi]},

  (* All properties at one time share the same reconstructed geometry. *)
  geometry[u_?NumericQ] := memoLast[geometry, cache, {u},
    hklGeometry[a, Through[{p, \[Alpha]p, \[Beta]p, h, k, \[CapitalLambda]}[u]], chart, t[u]]];
  property[key_] := Function[{u}, geometry[u][key], {Listable}];

  (* Identify undefined BL phases without restricting the evolved variables. *)
  circular[u_?NumericQ] := TrueQ[(u == 0 && e0 == 0) || (\[Alpha]p[u] == 0 && \[Beta]p[u] == 0)];
  equatorial[u_?NumericQ] := TrueQ[h[u] == 0 && k[u] == 0];
  onAxis[u_?NumericQ] := TrueQ[geometry[u]["sin2"] < $hklAxisTolerance];
  (* The external BL angle conversion is also singular when roundoff makes 1-x^2
     indistinguishable from 1. This affects only the optional angle/frequency outputs. *)
  polar[u_?NumericQ] := TrueQ[1 - geometry[u]["x"]^2 == 1];
  e = Function[{u}, If[circular[u], 0., Sqrt[\[Alpha]p[u]^2 + \[Beta]p[u]^2]], {Listable}];

  (* Four subintervals per integration step help track phase turns. They refine
     only the output sampling, not NDSolve's integration grid. *)
  grid = Flatten[p["Grid"]];
  denseGrid = DeleteDuplicates[Flatten[Subdivide[#[[1]], #[[2]], 4] & /@ Partition[grid, 2, 1]]];
  \[Psi]r = hklRadialPhase[\[Alpha]p, \[Beta]p, denseGrid, \[Psi]r0];
  \[Psi]\[Theta] = hklContinuousPhase[Function[u, {geometry[u]["nz"], geometry[u]["\[Alpha]\[Theta]"]}], denseGrid, \[Psi]\[Theta]0];
  \[Phi]Continuous = hklAzimuth[chart, {h, k, \[CapitalLambda]}, grid, denseGrid, \[Phi]0];
  \[Theta] = Function[{u}, ArcCos[Clip[geometry[u]["nz"], {-1, 1}]], {Listable}];
  \[Phi] = Function[{u}, If[onAxis[u], Missing["UndefinedOnRotationAxis"], \[Phi]Continuous[u]], {Listable}];

  (* Optional geodesic frequencies and angle variables, with the same output
     functions as Standard: \[CapitalPhi]r is Indeterminate at e >= 1 and within the numerical tolerance
     of the parabolic boundary; undefined BL phases are Missing. *)
  frequency[i_] := Function[{u}, If[polar[u], Missing["UnavailableAtPolarLimit"],
    BoyerLindquistFrequency[i, a, p[u], e[u], geometry[u]["x"]]], {Listable}];
  angle[i_] := Function[{u}, Which[
    i == 1 && radialAngleUnavailableQ[\[Alpha]p[u]^2 + \[Beta]p[u]^2, geometry[u]["En"], angleTolerance], Indeterminate,
    polar[u] || onAxis[u], Missing["UnavailableAtPolarLimit"],
    i == 1 && circular[u], Missing["UndefinedAtZeroEccentricity"],
    i == 2 && equatorial[u], Missing["UndefinedForEquatorialOrbit"],
    True, BoyerLindquistAngle[i, a, p[u], e[u], geometry[u]["x"],
      If[circular[u], 0, \[Psi]r[u]], If[equatorial[u], 0, \[Psi]\[Theta][u]], \[Phi]Continuous[u]]], {Listable}];

  <|"Trajectory" -> {t, property["r"], \[Theta], \[Phi]},
    "t" -> t, "r" -> property["r"], "\[Theta]" -> \[Theta], "\[Phi]" -> \[Phi],
    "p" -> p, "e" -> e, "x" -> property["x"],
    "\[Psi]r" -> Function[{u}, If[circular[u], Missing["UndefinedAtZeroEccentricity"], \[Psi]r[u]], {Listable}],
    "\[Psi]\[Theta]" -> Function[{u}, If[equatorial[u], Missing["UndefinedForEquatorialOrbit"], \[Psi]\[Theta][u]], {Listable}],
    "En" -> property["En"], "L" -> property["L"], "Q" -> property["Q"], "K" -> property["K"],
    "\[Alpha]p" -> \[Alpha]p, "\[Beta]p" -> \[Beta]p,
    "\[CapitalOmega]r" -> frequency[1], "\[CapitalOmega]\[Theta]" -> frequency[2], "\[CapitalOmega]\[Phi]" -> frequency[3],
    "\[CapitalPhi]r" -> angle[1], "\[CapitalPhi]\[Theta]" -> angle[2], "\[CapitalPhi]\[Phi]" -> angle[3],
    "h" -> h, "k" -> k, "\[CapitalLambda]" -> \[CapitalLambda],
    "Direction" -> property["n"], "AngularMomentumDirection" -> property["H"],
    "AngularVariables" -> "HKLambda", "AngularChart" -> chart|>
];
