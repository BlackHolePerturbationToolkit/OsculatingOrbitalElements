# Design Document

Plans for refactoring the package, and the features it should add and support.

## Basic Features

- pex parametrization should be the default; ELK support can be tried later
- Use the p, alpha, beta parametrization when the eccentricity is sufficiently small
- Report everything in Boyer-Lindquist coordinate time by default
- Support only the Darwin and Hughes quasi-Keplerian angles
- Pass initial conditions and arguments as a dictionary, as WaSABI does; pass NDSolve arguments directly to the solver, as now.
- Output an "inspiral object", as KerrGeodesics does, that can be queried for its properties
- Built-in force models can be specified
- Package custom force models as a "Force object"
- It should return the downstairs-indexed F_r, F_\theta, F_\phi, with F_t from the orthogonality condition, and use pex parameters and Darwin angles
- It should also accept any extra arguments the force needs, such as the drag coefficient of the gas drag model.
- Inspirals can also be driven, alone or with forces, by orbit-averaged rates of the slowly varying elements p, e, x (for example leading-order post-Newtonian rates), packaged as a "Flux object". It is implemented after the force objects, but the earlier phases leave room for it. See "Flux-driven evolution".
- Keep unused legacy code for now, but segregate it
- Need unit tests
- Need full documentation with examples
- Set up paclet support, for distribution from a paclet server

## Future features that might be nice

- Support for Flux modes that replace the RHS with pdot, edot, xdot (orbit averaged). Now planned: see "Flux-driven evolution".

- Queryable properties for each built-in force or flux object, such as parameter range and paper citation.

- Several forces or fluxes driving one inspiral, for example a gravitational-wave flux with gas drag. Now planned: see "Flux-driven evolution".

## Flux-driven evolution

Besides an oscillatory force, an inspiral can be driven by orbit-averaged rates of the slowly varying elements, ⟨dp/dt⟩, ⟨de/dt⟩ and ⟨dx/dt⟩, which we call a flux. Examples are leading-order post-Newtonian rates at first order in the mass ratio: Peters (1964) in the weak field, or the Kerr post-Newtonian fluxes of Gair & Glampedakis (2006) or Sago & Fujita (2015).

**Decision: keep evolving the Darwin and Hughes angles.**

- Flux- and force-driven inspirals use the same variables and equations. No separate solver evolves mean anomalies.
- This is slower, since the phases still oscillate on the orbital timescale, but speed is not a priority for this code.
- In exchange, a flux and a force can drive an inspiral together (for example a gravitational-wave flux and gas drag), as can several of each. No other code does this.

**How a flux enters the equations.** A flux is not a force: it has no instantaneous direction, so the force terms in the phase equations have nothing to act on.

- **Only the slow variables change.** A flux adds its rates to p, e and x.
- **Phases advance at their geodesic rate** for the current elements, plus the force terms when a force is also present: the usual adiabatic prescription. The position then drifts from the geodesic at O(η), consistent with an averaged flux.
- **Contributions add.** The osculating equations are linear in the force, so several forces add to one total force, whose rates add to those of any fluxes.
- **Mixed variables need care.** Where slow and fast variables are mixed, add the flux in that form:
  - In the REG components (αp, βp) = e (sin ψr, cos ψr), a flux contributes (ė/e)(αp, βp).
  - In (x, ψθ) it contributes ẋ to x and nothing to ψθ. (In the polar components (αθ, βθ) of the regular polar formulation, now on hold, it would contribute (ż_m/2z_m)(αθ, βθ) = −(xẋ/z_m)(αθ, βθ), alongside ẋ for x.)
  - The ratio ė/e stays finite for physical fluxes (ė ∝ e as e → 0). At exactly e = 0 it is 0/0 and the contribution is set to 0, so a flux keeps a circular orbit circular. On an equatorial orbit x is held fixed, and a flux that changes x is rejected.
  - Do not pass a flux through REG's osculating relations: they assume r and u_r stay continuous, which holds only for a force.
- **The same small-e and equatorial treatments** therefore apply to fluxes as to forces.

**Flux object** (`FluxModel`, in `Kernel/FluxModels/FluxModel.wl`), the counterpart of the Force object (`ForceModel`). It holds:

- a function of (a, p, e, x, parameters) returning the averaged rates, evaluated only on numeric input;
- the quantities the rates are for: (p, e, x), or (E, L, Q), the form most fluxes are published in;
- the time the averages are taken with respect to: always coordinate time t (decided in phase 5);
- its parameters, and the same descriptive properties and mass-ratio convention as force models.

**Converting (E, L, Q) rates.** The map from (dE, dL, dQ) to the rates of p, e and x already exists inside the pex and REG equations; it should live in one place, `Utilities.wl`. Two points:

- **Circular orbits.** `SlowElementRates` gives de²/dt, so ė/e = (de²/dt)/(2e²). Its error is about 10⁻¹⁶/e² relative to the flux, so for nearly circular orbits a flux given for (p, e, x) is better.
- **Polar orbits.** `RegularXRate` gives ẋ with the 1/x cancelled using ℓ = L/x. At x = 0 it is dL/ℓ.

**Interface and output.** The parameter Association takes "Force", "Flux" or both, each as one object or a list. The result is the same inspiral object, recording the forces and fluxes that drove it.

**Checking it:**

- **A force against its averaged flux.** Orbit-averaging a Force object over the radial and polar phases gives a Flux object. Inspirals driven by the force and by its averaged flux should agree in p, e and x to O(η) throughout. This tests the flux machinery against the osculating equations, and lets any force model serve as a flux.
- **Limiting cases.** A zero flux must leave force-driven results unchanged, and with no force the phases must advance at their geodesic rates.
- **Combinations.** Force A plus the averaged flux of force B should agree with forces A and B together, again to O(η) in p, e and x.

**What the earlier phases must allow for.** These are cheap to do now and awkward to retrofit:

- **Phase 2:**
  - The solver contract must not assume a single force. A solver builds its equations from a list of drivers: forces contribute to the slow variables and the phase equations, fluxes only to the slow variables (in the component forms above).
  - The (dE, dL, dQ) → (dp, de², dx) map moves into `Utilities.wl`.
- **Phase 3:** The parameter Association accepts "Flux" alongside "Force", each as one object or a list, and the inspiral object records them.
- **Phase 4:** Parameter handling, the mass-ratio convention and the descriptive properties are designed once, for both Force and Flux objects. Several forces combine into one total force.

## Polar motion near the equator and the poles

The pex polar variables (x, ψθ) are singular for equatorial orbits (x = ±1). There ψθ is undefined, and its equation contains a term proportional to F_θ / √(1 − x²), so in these variables a force with a θ component cannot lift an orbit out of the plane. The earlier solvers avoid this by holding equatorial orbits in the plane (see "Before Phase 0"), which rules out such forces.

**Status: on hold** (decided after phase 7). Because the formulation below may still change, the regular solver behind `OsculatingInspiral` is back to (x, ψθ), with equatorial orbits the same special case as in the earlier solvers. The formulation's code is kept, unused, in `Kernel/Legacy/RegularPolar.wl`; the solver that used it is at commit 7e644fe (see "After phase 7" below). The rest of this section describes the formulation as it was.

**The regular polar formulation**, used by `OsculatingInspiral` from phase 3 until it was put on hold, evolves the 3-vector (αθ, βθ, x), with αθ² + βθ² + x² = 1, where

```
αθ = √zm sin ψθ,    βθ = √zm cos ψθ = cos θ,    zm = 1 − x²
```

Geometrically, this is a unit sphere with x as the height and ψθ as the longitude:

- (x, ψθ) are spherical coordinates, so they fail at the sphere's poles, the equatorial orbits.
- (αθ, βθ) alone fail at its equator, the polar orbits (x = 0), because they cannot tell prograde from retrograde.
- The 3-vector is regular everywhere, including through prograde ↔ retrograde transitions.

**Equations** (Mino time, covariant a_μ). The auxiliary quantities are:

- W = √(βz₊ − β βθ²)
- βz₊ = Q + L² + βx²
- L/x = √(Q + L² − βzm)
- sin θ = √(1 − βθ²)

```
dαθ/dλ = βθ W + Σ [ x² W a_θ / sin θ − αθ ( a²E x² a_t + L a_φ / sin²θ ) ] / (βz₊ − βzm)
dβθ/dλ = −αθ W
dx/dλ  = −Σ αθ [ x W a_θ / sin θ − αθ ( a²E x a_t + (L/x) a_φ / sin²θ ) ] / (βz₊ − βzm)
```

**Derivation outline:**

1. βθ = cos θ is a coordinate, so its rate is the geodesic rate.
2. Writing dQ/dλ in its polar form, 2Σ[u_θ a_θ + cos²θ (a²E a_t + L a_φ / sin²θ)], makes every term of dzm/dλ proportional to αθ. This factor cancels in dαθ/dλ, which follows from αθ² = zm − βθ².
3. dx/dλ = −(dzm/dλ)/(2x), with the 1/x cancelled using 1 − zm = x² and L/x.
4. The equations preserve αθ² + βθ² + x² = 1 exactly, so any drift measures the integration error.
5. The derivation assumes u^μ a_μ = 0. The polar form of dQ and pex's radial form of dK agree only then.

**Checks:**

- Through the chain rule, the equations match pex's (x, ψθ) equations to 10⁻¹³ or better for a = 0, 0.5 and 0.9, prograde and retrograde, x from 0.8 down to ±0.01, and near the axis (sin θ = 0.01); to 10⁻¹¹ at x = 0.999, where pex itself loses digits.
- In a solve, while `OsculatingInspiral` used it (these tests were replaced when it was put on hold):
  - a θ force on an inclined orbit agrees with REG;
  - starting exactly equatorial, the same force lifts the orbit out of the plane, with the 3-vector staying at unit length to 10⁻¹³;
  - the solution is continuous at the equator;
  - a torque drives an inspiral from prograde to retrograde through x = 0, and p, e, x and r agree with REG.
- Mutation tests: dropping one force term, or making a 1% error in one, fails at least 3 tests.

**Constants of motion at x = 0.** `RegularEnergy` and `RegularLOverX` (in `Utilities.wl`) give E and ℓ = L/x from (a, p, e², x). They use Schmidt's construction with two changes:
- L is replaced by xℓ, which turns x² times Schmidt's h(r) into r² − 2r + a²zm.
- The conditions at r1 and r2 are replaced by their mean and divided difference, which are sums of products of r1 and r2 with positive coefficients.

So they are regular at x = 0 and e = 0 with no special cases. They agree with KerrGeodesics to 50 digits, and to 10⁻¹³ at machine precision, including at e = 10⁻⁸, x = 10⁻⁸ and x = 0. (An earlier note here wrongly said the package's `Energy`, `AngularMomentum` and `CarterConstant` lose half their digits near x = 0. They are accurate there, and fail only exactly at x = 0, as 0/0.)

**The Boyer–Lindquist axis.** An orbit with small |x| passes sin θ = |x| from the axis. There dφ/dλ ≈ L/sin²θ, so φ swings by nearly π in a time of order |x|.
- **The swing can be missed.** NDSolve's default multistep method (LSODA) can step over it entirely. At default goals φ was 0.4 rad wrong for a gas-drag inspiral at x = 0.01, and meaninglessly wrong at x = 0.001.
- **REG only gets it right by accident.** Its ψθ equation has force terms that spike at the same moment and force small steps.
- **The regular solver's choice.** An 8th-order explicit Runge–Kutta method with goals of 11 or more resolves the swing down to |x| = 0.001. The regular solver uses it by default, with goals 12. On generic orbits it is about 4 times more accurate in r than the earlier solvers' defaults, and about twice as slow.
- **Tried and rejected: evolving sin θ e^{iφ} in place of φ.** Its equation divides by sin θ e^{−iφ}, which amplifies any inconsistency with (αθ, βθ, x) near the axis. It did worse, and with Runge–Kutta NDSolve judged the system stiff.
- **A fully robust option for later.** Near the poles, evolve the node angle Ω = φ − χ, with χ = arg(−αθ + i x βθ). In Schwarzschild, χ is exactly the azimuth measured from the node. In Kerr, Ω's geodesic rate is the bounded −xβ/(ℓ + W) plus the smooth frame-dragging terms, so no variable swings and |x| can be arbitrarily small.
  - Ω is undefined for equatorial orbits, so this needs two patches, Ω near the poles and φ near the equator, with the integration switching between them when |x| crosses a threshold.
- **Exactly polar orbits** (x = 0, so L = 0 for a force without a φ component) pass through the axis, and are rejected.

**Open issues:**

- For the earlier solvers, `OrbitalElementRates` still gives dx/dλ as −(dzm/dλ)/(2x), which is 0/0 at x = 0. The regular solver and fluxes given as (dE, dL, dQ) use `RegularXRate`.
- The polar rate of x uses the polar form of dQ, while p and e² use the radial form of dK. They agree only for forces orthogonal to the velocity.
- This formulation does not seem to be in the literature, so it is worth writing up.

## Code layout

The package moves from the single `OsculatingOrbitalElements.m` to a paclet with one file per responsibility. Source files use the `.wl` extension and keep the `(* ::Package:: *)` header, so they still open in the Mathematica package editor.

```
OsculatingOrbitalElements/
├── PacletInfo.wl                     Paclet metadata: name, version, Kernel and Documentation extensions
├── Kernel/
│   ├── init.wl                       One-line loader, used by both Applications-folder and paclet installs
│   ├── OsculatingOrbitalElements.wl  Header: usage messages, options and messages for every public symbol;
│   │                                 loads the files below
│   ├── Interface.wl                  Entry point: parameter Association, validation, solver and force or flux
│   │                                 selection, the shared NDSolve driver
│   ├── InspiralObject.wl             Inspiral object: construction, property access, summary box
│   ├── Models.wl                     What force and flux models share: parameters, options, properties,
│   │                                 validity, summary box
│   ├── OrbitalAngles.wl              Boyer–Lindquist frequencies and action angles of the osculating geodesic
│   ├── Utilities.wl                  Constants of motion, radial roots, separatrix, orbit geometry,
│   │                                 index raising/lowering, F_t from orthogonality, the map from (E, L, Q)
│   │                                 rates to (p, e², x) rates, caching
│   ├── Solvers/
│   │   └── KerrPEX.wl                The regular solver: p, αp, βp, x and ψθ, with equatorial orbits as a special case
│   ├── ForceModels/
│   │   ├── ForceModel.wl             Force object (ForceModel): parameters, evaluation, use in a solver
│   │   ├── GasDrag.wl                Gas drag (Schwarzschild and Kerr)
│   │   ├── EMConservative.wl         Conservative electromagnetic force
│   │   └── FastGSF.wl                Fast first-order GSF fit (Schwarzschild); reads Data/FastGSF
│   ├── FluxModels/
│   │   ├── FluxModel.wl              Flux object (FluxModel): averaged rates, the quantities and time they refer to,
│   │   │                             parameters, combining fluxes, orbit-averaging a Force object
│   │   └── PostNewtonian.wl          Peters' leading-order rates; later, Kerr post-Newtonian fluxes
│   └── Legacy/                       Code that OsculatingInspiral does not use (see Legacy code below)
│       ├── Utilities.wl              Radial roots, SeparatrixEqELK, cached constants of motion
│       ├── ForceFunctions.wl         The force functions with the old signatures (SchwarzGasDrag, KerrGasDrag, ...)
│       ├── Schwarzschild.wl          SchwarzOsculatingOrbitalElements, SchwarzOsculatingOrbitalElementsTP
│       ├── KerrELK.wl                KerrOsculatingOrbitalElements (En, L, K equations)
│       ├── GenericKerr.wl            GenericKerrpexBL, GenericKerrREGBL
│       ├── RegularPolar.wl           The regular polar formulation (αθ, βθ, x), on hold
│       └── LegacyEquations.wl        Equations that were never called, and stale usage messages
├── Data/FastGSF/                     a_n_jk, b_n_jk, c_n_jk, d_n_jk
├── Documentation/
│   ├── MakeDocumentation.wls         Generates the notebooks below; edit it, not the notebooks
│   └── English/                      Reference pages, the guide page and the tutorial
├── Notes/RegularFormulation.md       The regular variables and equations, and why they were chosen
├── Notebooks/Legacy/                 The earlier tutorial and research notebooks, outputs stripped
├── .github/workflows/Tests.yml       Runs the tests on GitHub
├── Tests/
│   ├── AllTests.wls                  Runs every test file, or the ones named on the command line
│   ├── TestSetup.wl                  Loads this copy of the package and defines shared helpers
│   ├── *.wlt                         VerificationTest files, one per area
│   ├── RegressionCases.wl            Fixed solver outputs checked by Regression.wlt
│   ├── MakeReferenceOutputs.wls      Regenerates ReferenceOutputs.wl when a change in results is intended
│   └── ReferenceOutputs.wl           Saved outputs, with the Wolfram version and commit that produced them
└── README.md, LICENSE, .gitignore
```

When each file is created:

- `Interface.wl`: phase 2, for the shared NDSolve driver. Phase 3 added the entry point, `OsculatingInspiral`.
- `InspiralObject.wl`: phase 3.
- `ForceModels/ForceModel.wl`: phase 4.
- `FluxModels/`: phase 5.
- `Documentation/`: phase 7.

The future features fit this structure without changes:

- A new built-in force is a new file in `ForceModels/`, and a new flux model a new file in `FluxModels/`.
- Combining several forces belongs in `ForceModel.wl` (a list of models becomes a list of solver drivers, which `TotalForce` adds), and combining several fluxes in `FluxModel.wl`.

### Conventions

- **One public context, one shared private context.** The header declares the public symbols in `` OsculatingOrbitalElements` ``, then loads the other files inside `` Begin["`Private`"] ``. Those files have no `BeginPackage` of their own, so any private helper can be used from any file, and moving code between files needs no import or export changes.
- **Public symbols are declared only in the header.** A new public function or option needs its usage message there; otherwise it is created as a private symbol.
- **The header lists the KerrGeodesics subcontexts explicitly.** The other files are read with the header's `$ContextPath`, and `` "KerrGeodesics`" `` alone does not include `` KerrGeodesics`ConstantsOfMotion` ``, `` KerrGeodesics`SpecialOrbits` `` or `` KerrGeodesics`OrbitalFrequencies` ``. Without them, a name such as `KerrGeoEnergy` silently becomes a new private symbol that never evaluates.
- **Load order:** Utilities, OrbitalAngles, Models, ForceModels, FluxModels, Solvers, InspiralObject, Interface, then Legacy. Only code that runs at load time, such as reading the FastGSF data, depends on it.
- **Paths come from the package itself.** The header records its own directory from `$InputFileName`. Nothing calls `SetDirectory` or assumes `$UserBaseDirectory`.

### Legacy code

Unused code is kept but separated from the active code:

- It lives in `Kernel/Legacy/`, which the header loads last, in a block marked as legacy.
- Each legacy file starts with a comment saying it is legacy, unused by the current interface, and not to be extended.
- Legacy public functions keep working. Their usage messages move to a marked legacy section at the end of the header (public symbols must be declared there) and say the function is legacy.
- Usage messages for functions that no longer exist are kept as comments in the legacy file, so they do not create undefined public symbols.

Legacy (phase 1):

- `KerrOscGeoEqs`, `KerrOscGeoEqsTP` and `KerrOscGeoEqsTPVecLessArg`, which are never called.
- The usage messages for `KerrOsculatingOrbitalElementsTP` and `KerrOsculatingOrbitalElementsTPVec`, which have no definitions.

Legacy (phase 6): the earlier public functions (`SchwarzOsculatingOrbitalElements`, `SchwarzOsculatingOrbitalElementsTP`, `KerrOsculatingOrbitalElements`, `GenericKerrpexBL`, `GenericKerrREGBL`), the force functions with the old signatures (`SchwarzGasDrag`, `KerrGasDrag`, `KerrGasDragVec`, `KerrGasDragapex`, `KerrEMCons`, `SchwarzFastGSF`), the pex and REG systems behind `GenericKerrpexBL` and `GenericKerrREGBL`, and the utilities only they use. `OsculatingInspiral` reproduces their results (the solver agreement tests), and they keep working.

### Where the current code goes

| Current code in `OsculatingOrbitalElements.m` | Phase 1 file | After phase 6 |
|---|---|---|
| Usage messages, options, `SyntaxInformation`, message texts | `OsculatingOrbitalElements.wl` | Legacy ones in the header's legacy section |
| `SchwarzOscGeoEqs1`, `…TP`, `…2`, `…2TP` and the two Schwarzschild public functions | `Solvers/Schwarzschild.wl` | `Legacy/Schwarzschild.wl` |
| `KerrOsculatingOrbitalElements` | `Solvers/KerrELK.wl` | `Legacy/KerrELK.wl` |
| `GenericKerrpexBL`, `GenericKerrREGBL` | `Solvers/KerrPEX.wl` | `Legacy/GenericKerr.wl` |
| `SchwarzGasDrag`, `KerrGasDrag`, `KerrGasDragVec`, `KerrGasDragapex` | `ForceModels/GasDrag.wl` | `Legacy/ForceFunctions.wl` |
| `KerrEMCons` | `ForceModels/EMConservative.wl` | `Legacy/ForceFunctions.wl` |
| `SchwarzFastGSF` and its data loading | `ForceModels/FastGSF.wl` | `SchwarzFastGSF` in `Legacy/ForceFunctions.wl`; the data stays |
| Radial roots, `SeparatrixEqELK`, constants of motion and `memoLast` | `Utilities.wl` | `Legacy/Utilities.wl`, except `memoLast` |
| `StopMessage`, `MinoParametrisationQ` | `Utilities.wl` in phase 1, then `Interface.wl` in phase 2 | `Interface.wl` |
| `KerrOscGeoEqs`, `…TP`, `…TPVecLessArg`, and the stale usage messages | `Legacy/LegacyEquations.wl` | Unchanged |

## Checklist for improvements that should be made

### Before Phase 0: fixes to the current code

- [x] Equatorial orbits (x = ±1) in the pex and REG solvers: x is held at exactly ±1, the polar equations are dropped, and a force with a θ component on the plane is rejected. The regular solver behind `OsculatingInspiral` does the same, since the regular polar formulation was put on hold (see "Polar motion near the equator and the poles").
- [x] pex gas drag at a = 0: `KerrGasDragapex` divided by a²(1 − E²) to get zm; it now uses zm = 1 − x²
- [x] `IntegrationLimit` is in the units of the chosen time variable, with no hidden ×1000. The Kerr default is `Automatic`: 10⁷ in coordinate time and 10⁴ in Mino time.
- [x] `Print` replaced by messages that say why the integration stopped, and `Monitor` only used when a front end is present (Kerr solvers)
- [x] FastGSF coefficient tables built once at load
- [ ] Report to KerrGeodesics: `KerrGeoSeparatrix[a, e, ±1.]` does not evaluate when a ≠ 0 (worked around here by holding x at exact ±1)

### Phase 0: Tests before any restructuring

Run the suite with `wolframscript -file Tests/AllTests.wls` (about a minute). Phase 0 wrote 84 tests in 7 files; there are now 98 in 8.

- [x] Set up `Tests/` with `.wlt` files and an `AllTests.wls` runner, and run it against the current single-file package
- [x] Geodesic limit (η → 0) against `KerrGeoOrbit` for every solver
- [x] Agreement between the ELK, pex and REG solvers
- [x] Continuity across the Schwarzschild e₀ = 0.05 switch, in both χ and coordinate time
- [x] Constants of motion against `KerrGeoConstantsOfMotion`, including e = 0
- [x] Bad input returns `$Failed` with a message: unbound orbit, invalid force, invalid `Parametrisation`
- [x] Memo caches stay bounded after a solve
- [x] Save reference outputs, so phase 1 can be checked for identical results
- [x] Also covered:
  - each stop message;
  - `IntegrationLimit` units;
  - `Parametrisation` as a string or a symbol;
  - Kerr at a = 0, x = 1 against the Schwarzschild solver;
  - the equatorial safeguard (temporary; `Equatorial.wlt`).
- [x] Checked that the suite catches reintroduced bugs:
  - the old Schwarzschild r sign;
  - the old small-e fallback to the χ solver;
  - unbounded memoisation;
  - the hidden ×1000 in `IntegrationLimit`;
  - a 1% error in one pex force term. Catching this needs tight NDSolve goals in the Kerr comparison.

The reference outputs were made at commit `8ce9ffe` with Mathematica 13.1, as Wolfram 14.3's licence had lapsed. They match exactly only on the same Wolfram version and system; elsewhere the regression test uses a relative tolerance of 10⁻⁸. If Phase 1 is done on another version, first regenerate them with `MakeReferenceOutputs.wls`.

They were regenerated in phase 2, when pex switched to the shared rate map (see Phase 2).

### Phase 1: Restructure with no change in behaviour

- [x] Create the `Kernel/` layout with `.wl` files and an `init.wl` that loads the header
- [x] Move the code as in the table above, without changing any equations
- [x] Move unused code to `Kernel/Legacy/` with legacy headers, and comment out the stale usage messages there
- [x] Record the package directory from `$InputFileName`, move `DataFiles/` to `Data/FastGSF/`, and remove `SetDirectory`
- [x] Add `PacletInfo.wl` (version 0.1.0, Mathematica 13.1+)
- [x] Tests pass with identical outputs, and `tutorial.nb` still runs
  - All regression outputs match exactly on Mathematica 13.1.
  - Every tutorial cell gives the same result and the same messages, apart from the time printed by `Timing`.
- [x] Update the README install instructions (Applications folder and `PacletDirectoryLoad`)
- [x] Added `Tests/Package.wlt`, which checks the exported public symbols, that loading issues no messages and leaves the working directory unchanged, and that the package loads through `Kernel/init.wl`
- [x] The public symbol `pMin$` was created by `Module` renaming its local `pMin`, which shares its name with the `pMin` option. Removed in phase 2 by renaming the local variable.

### Phase 2: Separate the interface from the solvers

- [x] Define what each solver file provides: variables, initial conditions, equations, stop events, and derived quantities (r, θ, En, L, Q, …)
  - A solver is a builder and a force resolver, described at `RunSolver` in `Interface.wl`.
  - The builder returns the variable, unknowns, equations, stop events, NDSolve method and a function that makes the outputs from the solution. `RunSolver` reads the options, resolves the force, builds and integrates the system, and adds `"limit"` and `"StopReason"`.
  - pex and REG are written this way (`pexSystem`, `regSystem`), and share their derived outputs.
  - ELK and the Schwarzschild solvers only use the shared NDSolve driver, since ELK is to be supported later and the Schwarzschild solvers' future is undecided.
- [x] Keep that contract independent of what drives the inspiral. A solver builds its equations from a list of drivers: forces contribute to the slow variables and the phase equations, fluxes (from phase 5) only to the slow variables. See "Flux-driven evolution".
  - A force driver is `<|"Type" -> "Force", "Function" -> f|>`, where f takes the orbit's state (elements, phases and the shared geometry) and returns {a_t, a_r, a_θ, a_φ} per unit η.
  - `TotalForce` adds the drivers. A test checks that two half-strength gas drags give the same inspiral as one full-strength gas drag.
  - Flux drivers will be a second type, added in phase 5.
- [x] Move the map from (dE, dL, dQ) to the rates of p, e² and x, now inside the pex and REG equations, into `Utilities.wl`, so the flux solver can reuse it
  - `OrbitalElementRates` uses REG's regular form, which gives de²/dλ. It is tested against 60-digit finite differences of the constants of motion, including at a = 0 and e = 0.
  - pex now uses it too, in place of its map through the turning points r1 and r2. The two agree to 10⁻¹² in the rates, and the new form is usually the more accurate.
  - This changed pex results by at most 5×10⁻⁹, the level of NDSolve's default tolerance, so the reference outputs were regenerated. REG, ELK and Schwarzschild results did not change.
- [x] Write one NDSolve driver shared by all solvers, which works for any set of variables (`IntegrateSystem` in `Interface.wl`):
  - [x] Stop conditions (separatrix, pMin, maximum time) handled in one place. Solvers declare `stopEvent[condition, reason]`.
  - [x] A configurable separatrix buffer: the `SeparatrixBuffer` option (pex and REG; η by default)
  - [x] Store why the integration stopped in the output: `"StopReason"` is `"Separatrix"`, `"SeparatrixBuffer"`, `"pMin"`, `"IntegrationLimit"` or `"Other"`
  - [x] Pass NDSolve options straight through, ahead of the solver's own settings
- [x] Move the orbit geometry (Σ, Δ, roots, velocities), currently repeated in several functions, into `Utilities.wl`
  - pex and REG use `KerrOrbitGeometry`, `NullTetradForce` and `ConstantsOfMotionRates`. Their shared polar phase equation, `polarPhaseRate` in `KerrPEX.wl`, is also used by the regular solver.
  - The force models and ELK still compute their own geometry. They should use the shared one when the force models are rewritten (phase 4) and when ELK is supported.

### Phase 3: New interface and inspiral object

Decisions made at the start of phase 3:

- **Entry function:** `OsculatingInspiral[params, opts]` returns an `OsculatingInspiralFunction`, as `KerrGeoOrbit` returns a `KerrGeoOrbitFunction`.
- **Parameters:** an Association with short keys, as in WaSABI.
  - Required: `"a"`, `"ε"` (the small mass ratio, which scales the force), `"p"`, `"e"`, `"x"` and `"Force"`.
  - Optional, defaulting to 0: the initial phases `"ψr"`, `"ψθ"` and `"φ"`.
  - Solver settings stay as options: `Parametrisation`, `IntegrationLimit`, `SeparatrixBuffer`, `pMin`, `TimeMonitor`, and any NDSolve option.
- **Time:** Boyer–Lindquist coordinate time by default, with Mino time still available through `Parametrisation`.
- **Small eccentricity:** always integrate the regular radial variables (p, αp, βp), which are exact at every e, so there is no threshold or switch. e and ψr are reconstructed for output; ψr is undefined at e = 0. The pex small-e branch stays only in the legacy `GenericKerrpexBL`.
- **Schwarzschild:** handled as the a = 0 case of the Kerr solver, with equatorial orbits as a special case. The current Schwarzschild functions keep working until they move to legacy in phase 6.

- [x] Decide the keys and defaults of the parameter Association, following WaSABI. Accept a "Flux" entry alongside "Force", each as one object or a list.
- [x] Decide the name and signature of the entry function
- [x] Validate inputs: bound orbit, parameter ranges, missing keys
  - Unknown and missing keys, a "Flux" entry (for now), values out of range, x = 0, an invalid force or `Parametrisation`, and an initial orbit not outside the separatrix by more than the buffer each give `$Failed` with a message.
- [x] Make the regular p, e, x solver the default, reporting in Boyer–Lindquist coordinate time with the Darwin (ψr) and Hughes (ψθ) angles
  - `regularSystem` in `Solvers/KerrPEX.wl`. It integrates (p, αp, βp) radially with the REG equations, (x, ψθ) for the polar motion, with equatorial orbits as a special case, and φ. (Until the regular polar formulation was put on hold, (αθ, βθ, x) for the polar motion.)
  - ψr and ψθ are reported in (−π, π], and as `Missing` where they are undefined: ψr at e = 0, and ψθ on an equatorial orbit. φ is continuous. (They accumulate since "After phase 7: accumulated phases".)
  - By default NDSolve uses an 8th-order explicit Runge–Kutta method with goals 12 (see "The Boyer–Lindquist axis" above). Stops are located to 8 digits.
  - Normal stops are recorded in `"StopReason"` without a message. Only an early stop by NDSolve is reported.
- [x] Decide whether Mino time remains available as an option
- [x] Small e: always use the regular (p, αp, βp) variables (decided above), so no criterion or switch is needed
- [ ] Replace the (x, ψθ) polar equations with the (αθ, βθ, x) formulation, and remove the equatorial safeguard (see "Polar motion near the equator and the poles")
  - Done in phase 3, then put on hold after phase 7: the regular solver is back to (x, ψθ) with the equatorial special case, and the formulation's code is in `Kernel/Legacy/RegularPolar.wl`.
- [x] Make the constants of motion safe at x = 0 (`RegularEnergy`, `RegularLOverX`)
- [x] Decide whether Schwarzschild stays a separate solver or becomes the a = 0 case of the Kerr solver: the a = 0 case
  - It agrees with `SchwarzOsculatingOrbitalElementsTP` to 10⁻⁴ over a full inspiral, and with the geodesic at a = 0.
- [x] Build the inspiral object, modelled on `KerrGeoOrbitFunction`:
  - [x] Properties: trajectory, orbital elements, constants of motion, phases, domain, stop reason, input parameters, and the force or flux
    - `inspiral[t]` gives {t, r, θ, φ}, `inspiral["Properties"]` lists the properties, and every property that varies along the inspiral is a listable function of the time variable.
  - [x] Summary box
  - [x] Record the forces and fluxes that drove the inspiral (the force now; fluxes in phase 5)
- [x] `SeparatrixP` (in `Utilities.wl`) wraps `KerrGeoSeparatrix`, which does not evaluate at machine x = ±1. or 0., at |x| > 1, or within machine tolerance of ±1. Inspirals now reach those values.
- [x] Tests: `Tests/OsculatingInspiral.wlt`, and new sections in the constants of motion, caching, geodesic limit, solver agreement and regression tests. There are 165 tests in 9 files.
- [ ] Later: offer ELK as an option. Its `"p"` and `"e"` outputs are slow because every evaluation solves the radial quartic, and its gas drag (`KerrGasDrag`, `KerrGasDragVec`) still divides by zero at a = 0.

### Phase 4: Force objects

Decisions made at the start of phase 4:

- **Name:** `ForceModel`, with `FluxModel` to follow in phase 5.
- **Custom forces** are positional functions, f[a, p, e, x, ψr, ψθ, φ, t], or f[a, p, e, x, ψr, ψθ, φ, t, params] when the model has parameters. They return the covariant {F_r, F_θ, F_φ}, and are only ever called with numbers. Where the phases are undefined, the solver passes ψr = 0 at e = 0 and ψθ = 0 on an equatorial orbit.
  - φ and the coordinate time t are always passed (added after the first decisions), so a force need not be axisymmetric or stationary (for example the tidal field of a third body). A force can ignore them.
  - The background stays Kerr, so the geometry does not depend on φ or t. The solver already integrates φ, and has t as its independent variable, or as a variable in Mino time.
- **Mass ratio:** ε is the mass ratio, and each force declares whether it scales with it.
  - Self-force-like forces are multiplied by ε. Forces with their own strength are not, such as gas drag with its `"Coefficient"`.
  - A custom force scales with ε unless it sets `"ScalesWithMassRatio" -> False`.
- **`OsculatingInspiral`'s `"Force"`** takes a `ForceModel`, the name of a built-in model, a list of these, or None. The old forms (the symbol `KerrGasDrag`, or a list of four functions) remain only in the legacy functions.

- [x] Force object wrapping one function of (a, p, e, x, ψr, ψθ, parameters) that returns the downstairs {F_r, F_θ, F_φ}, and is only evaluated on numeric input
  - `ForceModel` (`Kernel/ForceModels/ForceModel.wl`).
  - In a solve, each model becomes a driver. Its function is called once per state, with numbers only, and the result is cached. The three components are separate functions so they stay unevaluated in the symbolic equations.
  - The model's function is checked at the initial orbit, so a function that does not return three real numbers fails before the integration starts.
  - `model[a, p, e, x, ψr, ψθ]` evaluates the full covariant force {F_t, F_r, F_θ, F_φ}, before any factor of ε.
- [x] Compute F_t from the orthogonality condition in `Utilities.wl` (`OrthogonalTimeComponent`)
  - `NumericOrbitGeometry` gives the geometry, including the four-velocity, from (a, p, e, x, ψr, ψθ) as numbers, for models that need the velocity. It uses the regular constants of motion, so it holds at e = 0 and x = 0.
- [x] Hold extra model parameters (such as a drag coefficient) in the object, and decide how they relate to η
  - `"Parameters"` is an Association. `Missing["Required"]` marks a parameter with no default; using the model without setting it gives a message.
  - `ForceModel[model, "k" -> v]` changes a parameter.
  - Each model has `"ScalesWithMassRatio"` (see the decisions above).
- [x] Design the parameter handling, the mass-ratio convention and the descriptive properties (validity range, citation) once, so Flux objects can share them
  - The properties are `"Name"`, `"Description"`, `"Parameters"`, `"ScalesWithMassRatio"`, `"ValidityCondition"` (a function of a, p, e, x), `"ValidityDescription"` and `"Citation"`.
  - A model used outside its validity range gives a warning, `ForceModel::range`, and the solve goes ahead.
  - `FluxModel` should use the same keys.
- [x] Solvers accept only Force objects, and built-in models can be selected by name (`OsculatingInspiral`; the legacy functions keep their `Force` option)
- [x] Several forces combine into one total force (the osculating equations are linear in the force)
  - `"Force"` takes a list. `TotalForce` applies each model's own ε scaling.
  - A test checks that two forces agree with their sum written as one force.
- [x] Rewrite gas drag, conservative EM and FastGSF as Force objects, each returning all components from a single evaluation
  - **`"GasDrag"`.** It has a required `"Coefficient"` and does not scale with ε. With coefficient 1 it equals `KerrGasDragapex` to 10⁻¹⁵.
  - **`"EMConservative"`.** It is `KerrEMCons`, computed from the regular geometry so it holds at x = 0. It agrees to 10⁻¹⁵, including F_t, and scales with ε. Its physical normalisation and citation are still to be filled in.
  - **`"FastGSF"`.** It scales with ε and is valid for a = 0, p ≤ 12 and e ≤ 0.2. It lowers `SchwarzFastGSF`'s contravariant (F^r, F^φ).
    - The angular part is put along the particle's angular motion, so it also holds for inclined Schwarzschild orbits. Such an inclined orbit gives the same p, e and r as the equatorial one, with x unchanged.
    - It agrees with `SchwarzOsculatingOrbitalElementsTP` over 3000M.
- [x] Vectorise the FastGSF sum. The tables are now built once, but the 1,600-term sum is about 94% of the 4 ms per call. Solves aren't affected today, because the solvers expand FastGSF symbolically once.
  - `fastGSFComponents` does the sums as dot products in about 50 μs, and agrees with `SchwarzFastGSF` to 10⁻¹¹. `SchwarzFastGSF` keeps its symbolic sum for the legacy solvers.
  - It also avoids 0.^0 at e = 0, which makes `SchwarzFastGSF` return Indeterminate there.
- [x] Forces that depend on φ and t (`Tests/ForceModels.wlt`):
  - A non-axisymmetric force, rotated together with the initial φ, gives the same inspiral rotated in φ. Rotating the force alone changes the inspiral.
  - A force switched on at t = 500 leaves p exactly unchanged before then, in coordinate time and in Mino time.
- [x] Tests: `Tests/ForceModels.wlt`, the other tests moved to `ForceModel`s, and new regression cases. There are 197 tests in 10 files.

### Phase 5: Flux-driven evolution

Decisions made at the start of phase 5:

- **Variables.** Flux-driven inspirals use the same variables as force-driven ones: (p, αp, βp) radially, the polar unit vector (αθ, βθ, x), and φ. (Since the polar formulation was put on hold, x and ψθ: a flux adds ẋ to x and nothing to ψθ, and on an equatorial orbit it must not change x.) A flux adds only to the slow parts:
  - ṗ to p;
  - (ė/e)(αp, βp) to the eccentricity components;
  - ẋ to x, and (ż_m/2z_m)(αθ, βθ) = −(xẋ/z_m)(αθ, βθ) to the polar components.
  The phases keep their geodesic rates.
- **Time.** Coordinate time only. Fluxes are averages with respect to t, as published ones nearly always are. A flux adds directly to the t equations; an inspiral with a flux and `Parametrisation -> "Mino"` is an error.

- [x] Flux object, `FluxModel`, in `Kernel/FluxModels/FluxModel.wl`, with:
  - [x] rates for (p, e, x) or (E, L, Q) (option `"Rates"`), with respect to t only;
  - [x] parameters and descriptive properties, shared with `ForceModel` through `Kernel/Models.wl`;
  - [x] combining several fluxes: `"Flux"` takes a list, and `TotalFlux` adds them.
- [x] Add flux contributions to the solvers (the regular solver only):
  - [x] the slow variables only, with the phases at their geodesic rate;
  - [x] the (ė/e) and (ż_m/2z_m) forms for the component variables (`fluxVariableRates`).
  - The parameter Association needs at least one of `"Force"` and `"Flux"`. A flux with `Parametrisation -> "Mino"` is an error.
- [x] Inspirals driven by forces and fluxes together, and by several of each
- [x] Orbit-average a Force object into a Flux object: `FluxModel[force]`
  - It gives the rates of (E, L, Q). In Mino time the radial and polar motions separate, so the Mino-time average over a non-resonant orbit is a double integral over ψr and ψθ, weighted by 1/((dψr/dλ)(dψθ/dλ)). Dividing by the average of dt/dλ gives the average with respect to t.
  - The integrals are trapezoidal sums over the parameter `"Points"` (16 by default) in each phase. They converge exponentially: about 10⁻⁴ relative error at 4 points and 10⁻⁸ at 8 for e = 0.2. A circular orbit needs one radial point, and an equatorial orbit one polar point.
  - It is slow: one evaluation of the averaged gas drag takes about 60 ms with 16×16 points, and 4 ms on the equator. A 2000M inclined inspiral with 4×4 points takes about 20 s.
  - The force must not depend on φ or t: it is evaluated at φ = t = 0.
- [x] First flux model, for example Peters' leading-order rates, in `Kernel/FluxModels/PostNewtonian.wl`: `"Peters"`, with rates of p and e in terms of p, leaving x unchanged
- [x] Tests (`Tests/FluxModels.wlt`):
  - [x] A zero flux leaves force-driven results unchanged, bit for bit, and with no force the phases advance at their geodesic rates: the orbit is the geodesic.
  - [x] With Peters' rates the elements follow the analytic solution of Peters' equations: p/(e^{12/19}(1 + 121e²/304)^{870/2299}) is constant to 10⁻⁵ while e falls by 0.013. A circular orbit stays circular, with p⁴ = p₀⁴ − (256/5)εt to 10⁻¹².
  - [x] Gas drag driven by the force and by its orbit-averaged flux agree in p, e and x to O(η). The secular changes are compared, with the force-driven elements averaged over three radial periods.
    - On the equator the changes agree to 10⁻⁷ in p (out of −0.475) and 10⁻⁶ in e.
    - Inclined, with 4×4 points, they agree to 2×10⁻⁴ relative in p, 6×10⁻⁵ in e (out of 1.2×10⁻³, an O(η) difference) and 0.1% in x.
  - [x] One force plus the averaged flux of another agrees with both forces together, to O(η) in p, e and x. Drag plus the averaged FastGSF agrees with drag and FastGSF together to 2×10⁻⁴ in p, out of −0.65.
  - Also: a flux that changes x (now: x follows it exactly); the conversion from (E, L, Q) rates, including at x = 0; and errors and properties.
  - The averaging weights are checked against KerrGeodesics: the Mino-time averages of dt/dλ and dφ/dλ match Γ and Υφ to 10⁻⁹. A quantity with near-axis structure, such as dφ/dλ ∝ L/sin²θ on a near-polar orbit, needs more points: 2×10⁻³ error with 16 at x = 0.4, and 3×10⁻¹² with 64. Physical forces are bounded near the axis, so their averages converge faster.
  - There are 224 tests in 11 files.

### Phase 6: Legacy

- [x] When the new interface reproduces a current public function's results, move that function to `Kernel/Legacy/` and mark its usage message as legacy
  - All the earlier public functions and force functions moved (see Legacy code above). Their usage messages start "Legacy, superseded by …", and their reference pages say the same.
  - The old header overwrote the usage messages of the System symbols `AccuracyGoal` and `PrecisionGoal`; those lines are now commented out.
- [x] Decide what to do with `Data generation.nb` and `TestingELKvspex.nb`, which call functions that no longer exist
  - Moved, with `tutorial.nb`, to `Notebooks/Legacy/`, outputs stripped, with a README saying what each was for and why the last two no longer run.

### Phase 7: Documentation and distribution

- [x] Reference pages for every public symbol, a guide page, and tutorials with worked examples
  - `Documentation/MakeDocumentation.wls` generates them, with the examples evaluated, in the Documentation Tools source format that KerrGeodesics uses. It stops if a public symbol has no page. Edit the script, not the notebooks.
  - The legacy functions have short pages that say what supersedes them.
  - The kernel evaluates the examples itself, because `NotebookEvaluate` hangs in a front end started by wolframscript. Message arguments are written on one line, as in a notebook.
  - The only message cells are in the Possible Issues sections, where they are the point of the example.
  - Pages that show an inspiral's summary box are large (about 1 MB), since the box embeds the inspiral, as Wolfram objects' summary boxes do.
- [x] Turn `tutorial.nb` into documentation, fixing its current bugs (undefined `ELKup`, and sin θ and cos θ swapped in the 3D plot)
  - The new tutorial (Tutorials/OsculatingOrbitalElements) uses the new interface. The old one, with both bugs fixed, is in `Notebooks/Legacy/`, since it documents the legacy functions.
- [x] Update the README: features, installation, links
- [x] Write up the regular polar formulation (`Notes/RegularFormulation.md`)
- [x] Strip outputs from committed notebooks (those in `Notebooks/Legacy/`; the documentation keeps its outputs)
- [ ] Build the paclet and publish it to a paclet server
  - [x] Build: `PacletInfo.wl` has a Documentation extension and declares `Data/FastGSF` as an asset, without which the build leaves the data out. ``PacletTools`PacletBuild`` makes `build/OsculatingOrbitalElements-0.1.0.paclet` (`build/` is ignored by git). The archive loads without messages, FastGSF finds its data, and the documentation links resolve.
  - [ ] Publish: decide the version, then submit the archive (for example to the Wolfram Paclet Repository, or attach it to a GitHub release)
- [x] Optional: run the tests automatically on GitHub, as KerrGeodesics does
  - `.github/workflows/Tests.yml` runs `Tests/AllTests.wls` on macOS with the Wolfram Engine. It needs the repository secret `WOLFRAM_LICENSE_ENTITLEMENT_ID`. On a Wolfram version other than the one that made `ReferenceOutputs.wl`, the regression tests use a relative tolerance of 1e-8.

### After phase 7: the regular polar formulation on hold

Decision: hold off on the polar unit vector (αθ, βθ, x), as it may change, and treat equatorial orbits as a special case, as the earlier solvers did.

- [x] `regularSystem` integrates x and ψθ, with `RegularXRate` for x (regular at x = 0) and `polarPhaseRate` for ψθ (moved from `Legacy/GenericKerr.wl` to `Solvers/KerrPEX.wl`, since the active code uses it). The radial variables, the regular constants of motion, φ and the default method are unchanged.
- [x] Equatorial orbits (x0 = ±1): x is held at exactly ±1 (output as a machine number), the polar equations are dropped, θ = π/2 and ψθ is `Missing`. A force with a θ component in the plane gives `OsculatingInspiral::eqforce`, and a flux that changes x `OsculatingInspiral::eqflux`; both are checked at the start, as before.
- [x] `KerrOrbitGeometry` takes (r, x, ψθ) only, as before phase 3; `NumericOrbitGeometry` gives it β zp = β + ℓ², so it still holds at x = 0. Fluxes give rates of (p, αp, βp, x). The inspiral no longer has the properties "αθ" and "βθ".
- [x] The formulation's own code (`polarComponentRates`, the polar-component geometry, the flux terms) is kept, unused, in `Kernel/Legacy/RegularPolar.wl`.
- [x] Numerical changes, measured before regenerating `ReferenceOutputs.wl`: the regression inspirals, sampled at the end of the integration, change by at most 7×10⁻¹⁴ relative. The integration is as accurate as before: a geodesic's e stays within 6×10⁻¹³ of its initial value at the steps over 3000M.
- [x] Values between steps are less accurate with the default interpolation. The (x, ψθ) variables let the Runge–Kutta method take about 30% longer steps (the bounded (αθ, βθ) had limited the step more than the goals required), and NDSolve's default interpolation between steps is of lower order than the method. Over 3000M a geodesic's e, sampled every 10M, is off by up to 9.5×10⁻⁷ (1.9×10⁻⁷ before); against REG over 5000M, φ is off by 2×10⁻⁵ (2×10⁻⁶ before). `InterpolationOrder -> All` uses the method's own dense output, and brings both formulations to the integration's accuracy (10⁻¹³ for the geodesic, and agreement with REG to REG's own error), at about 1.8 times the time and 11 times the memory. The defaults are unchanged; the documentation mentions the option.
- [x] Tests: the equatorial special case (stays in the plane, rejects a θ force and an x-changing flux, accepts a force whose θ component vanishes in the plane, continuity at the equator); a flux that changes x is checked against the exact solution. Tests that compare two solutions between steps (with REG, and two ways of writing the same force) use `InterpolationOrder -> All`, and keep their tolerances. The tests of lifting an orbit out of the plane and of the unit length were removed. There are 227 tests.
- [x] Docs, README and `Notes/RegularFormulation.md`: the examples that lifted an equatorial orbit now use a torque on an inclined orbit, and the text describes the equatorial special case. In (x, ψθ) a force with a θ component makes the equations stiff close to the equator (10⁻⁶ from the plane took 60 times longer than at x = 0.99; 10⁻¹⁰ failed as stiff), which the unit vector avoids.

### After phase 7: frequencies and Boyer–Lindquist action angles

Request: as functions of time, the inspiral should give the osculating geodesic's energy, angular momentum and Carter constant, its Boyer–Lindquist frequencies, and its Boyer–Lindquist action angles. The angles follow Lynch and Burke, "A note on the conversion of orbital angles for extreme mass ratio inspirals", Class. Quantum Grav. 42, 167001 (2025), arXiv:2411.04955, and github.com/Philip-Lynch/KerrOrbitalAngleConversion.

Decisions:

- **Names:** `"Ωr"`, `"Ωθ"`, `"Ωφ"` and `"Φr"`, `"Φθ"`, `"Φφ"`, as in KerrGeoFrequencies and the paper. `"En"`, `"L"`, `"Q"` and `"K"` already existed (from `RegularEnergy` and `RegularLOverX`, which agree with KerrGeodesics to 10⁻¹³ and are regular at x = 0).
- **The angles accumulate**, as φ does, rather than being wrapped.
- **Boyer–Lindquist only**: no Mino-time frequencies or angles for now, though they are computed on the way.
- **No public conversion function yet**, and no Boyer–Lindquist initial phases; the conversion is private (`BoyerLindquistAngles` in `Kernel/OrbitalAngles.wl`).

Implementation:

- [x] `Kernel/OrbitalAngles.wl`: the Mino phases qr and qθ from ψr and ψθ, and the oscillating parts Δt and Δφ, in the Fujita–Hikida form of the paper's notebook, with the regular constants (so the polar parts stay finite at a = 0: zp = √(β + ℓ²)). Then Φr = qr + Ωr Δt, Φθ = qθ + Ωθ Δt, Φφ = φ − Δφ + Ωφ Δt. qr's elliptic modulus uses (r − r2)/(r1 − r2) = sin²(ψr/2)(1 − e)/(1 + e cos ψr), which does not cancel at small e. Δt and Δφ are evaluated at the phases mod 2π, as they are periodic. No special case is needed at e = 0 or x = ±1; x = 0 is excluded, as before.
- [x] Frequencies from `KerrGeoFrequencies`. Its context, `` KerrGeodesics`OrbitalFrequencies` ``, was added to the header's `BeginPackage`; without it the name became a private symbol.
- [x] ψr is only known mod 2π from (αp, βp), so its turns are counted at the solver's steps, where it changes by much less than π, starting from the initial ψr0 as given, and interpolated linearly; between steps ψr is the value nearest that. ψθ and φ are integrated, so already continuous.
- [x] Missing where undefined: Φr at e = 0, Φθ on an equatorial orbit. The other angles do not depend on the undefined phase there.
- [x] The components only evaluate for numeric times, so `NIntegrate` and `Plot` work (a symbolic time first gave the spin, from `Part` of an unevaluated call).

Checks (`Tests/OrbitalAngles.wlt`, 10 tests):

- Along geodesics Φ − Ω t is constant to 10⁻¹²–10⁻⁹: prograde, retrograde, a = 0, equatorial, circular, near-polar (x = 0.05), and in Mino time.
- The conversion agrees with the paper's notebook to 5×10⁻¹⁴ (2×10⁻¹² in Φφ) at 24 points, including phases of several turns and negative phases.
- Over a gas-drag inspiral the accumulated angles differ from ∫Ω dt by 0.03 rad in Φr and less than 10⁻³ in Φθ and Φφ, the force's effect on the angles, with no lost turns.
- About 1.5 ms per evaluation.

Found on the way: with NDSolve's default stiffness test the (x, ψθ) solver stopped a long Mino-time geodesic at λ = 734 (t ≈ 98000) as "stiff", though its steps were steady; the (αθ, βθ) solver did not. The stiffness test now needs 100 restricted steps in a row (`"StiffnessTest" -> {True, "MaxRepetitions" -> {100, 100}}`), which gives the same steps as the default. Turning the test off instead lets the steps grow by about 20%, doubling the interpolation error between them. Over long runs the (x, ψθ) and (αθ, βθ) solvers agree: a 2×10⁵M gas-drag inspiral to 10⁻¹⁰ in p and 2×10⁻⁷ rad in φ (out of 7741), and a Peters inspiral to the separatrix to 10⁻¹⁰ in its end time.

There are 238 tests in 12 files.

### After phase 7: readability review

- [x] Comments and usage messages shortened throughout the active code; equations unchanged, and the regression outputs bit-identical. The measurements behind the solver's choices (method, stiffness test) are kept here, not in the code.
- [x] `OrbitalElementRates`, used only by the legacy solvers, moved to `Kernel/Legacy/Utilities.wl`.
- [x] Shared code instead of copies: `cachedComponents` (Models.wl) builds the numeric, cached components of both force and flux drivers, and `TotalForce` and `TotalFlux` share `driverTotal`.
- [x] Documentation generator: symbols in the reference pages' notes and tables were not linked, as the notes were built before the list of documented symbols existed; that list is now the package's public symbols.
- [x] README: the changelog still said the equations were regular for equatorial and polar orbits; corrected. Legacy code was left alone apart from its header comments.

### After phase 7: accumulated phases

Request: ψr and ψθ should accumulate, as φ and the action angles do, rather than being confined to (−π, π].

- [x] ψθ is integrated, so it is output as it is, no longer wrapped. ψr is the phase with its turns counted (`continuousRadialPhase`), which the action angles already used. Initial phases outside (−π, π] are kept as given, and ψr and ψθ are still `Missing` where undefined. Force models still get ψr in (−π, π].
- [x] Regression outputs: only the final ψr and ψθ changed, by whole turns (3 to 10), exact to machine precision; `ReferenceOutputs.wl` regenerated.
- [x] Tests: the phases grow steadily over an inspiral; ψr agrees with (αp, βp) to 10⁻¹⁵; along a geodesic in Mino time ψr and ψθ gain 2π per period, to 4×10⁻¹³ over 5 periods with `InterpolationOrder -> All` (5×10⁻⁸ with the default interpolation). There are 240 tests.

### After phase 7: the REG radial equations in force form

From the `dev` branch (453222d by oleksii-yanchyshen-bit, in `GenericKerrREGBL` of the pre-refactor `OsculatingOrbitalElements.m`): the rates of p, αp and βp written directly in the force components, closer to the form in the paper. It does not merge into the refactor (the file was split up in 2cae7d5), so it was ported by hand.

- [x] `regularSystem` (`Solvers/KerrPEX.wl`) uses the force form of p′, αp′ and βp′, with the shorthands `Dp`, `Ap`, `Bp`, `Hp`, `CAlpha` and `JAlpha` as in the commit. The rate of e² and the partial derivatives of Z are no longer needed; the rates of the constants of motion still give x′. `SlowElementRates` stays, for the fluxes, and the legacy `GenericKerrREGBL` keeps the old form. The commit's other changes (the Parametrisation check replaced by `MatchQ[…, "Mino"]`, and the undefined message `GenericKerrREGForceBL::nosol`) were not taken.
- [x] The two forms are the same equations: at 30 digits they agree to 22 digits or better at 200 random orbits with arbitrary force components, and at e = 0, a = 0, equatorial (both senses) and x = 0.05.
- [x] Round-off at machine precision, against 40 digits, in the force-driven parts of the rates (300 points in each of seven regimes: typical, e up to 0.9, e ≈ 10⁻⁴, e ≈ 10⁻⁸, within 10⁻⁴–10⁻¹ of the separatrix, p = 100–1000, |x| = 0.001–0.01): p′ and βp′ are the same; the medians of αp′ are the same (10⁻¹⁵–10⁻¹⁴, 5×10⁻¹² near the separatrix); the worst points of αp′ are up to 3 times worse (1.7×10⁻¹⁰ against 5.5×10⁻¹¹ at e = 0.88, 1.2 from the separatrix), and point by point the new form is the better at about as many points as the worse.
- [x] Solution error against 32-digit references (goals 22), over 9 inspirals (gas drag, a circular start, strong drag near the separatrix, e = 0.8 to the separatrix, the electromagnetic force, Mino time, retrograde equatorial, a torque through x = 0, force with the Peters flux): with `InterpolationOrder -> All` the new/old error ratio is 0.73–1.5 over all cases and variables, median 1.0, and the two solutions differ by less than either's error, except at round-off level. With the default interpolation the ratio is 0.33–2.2, median 1.0: that error is the interpolation between steps, and the number of steps changed by at most 2 (of 85–330). The time to reach the separatrix buffer changed from 5.9×10⁻¹⁰ to 5.4×10⁻¹⁰ and from 3.0×10⁻¹⁰ to 3.2×10⁻¹⁰. FastGSF, which only evaluates at machine precision, agrees with the old form to 10⁻¹⁴.
- [x] About 1.4 times faster to evaluate the radial rates, and whole inspirals 5–10% faster.
- [x] Regression outputs changed by at most 7×10⁻¹³ (relative) in the forced OsculatingInspiral cases, and not at all elsewhere; `ReferenceOutputs.wl` regenerated.
- [x] One test failed: rotating a non-axisymmetric force and the orbit together compared two solutions between their steps with the default interpolation, where they differ by its error (φ by 6.7×10⁻⁶ before, 1.1×10⁻⁵ after, against a tolerance of 10⁻⁵). It now uses `InterpolationOrder -> All`, as the other comparisons between steps do, and the two agree to 10⁻¹² with either form. There are 240 tests.
