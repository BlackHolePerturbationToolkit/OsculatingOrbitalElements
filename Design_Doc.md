# Design Document

Here we will specify plans for refactoring the package and what new features we want and what we wish to support.

## Basic Features

- pex parametrization should be default, we can later try to add support for ELK later
- Code should use p alpha, beta parametrization when eccentricity is sufficiently small
- By default, everything should be report in Boyer-Lindquist coordinate time
- We only support the Darwin and Hughes quasi-Keperian angles
- Initial conditions and argumemnts should be passed as a dictionary, similar to what WaSABI does, NDSolve arguments should be passed directly to the solver as is done now.
- We should output an "inspiral object" similar to KerrGeodesics that can be querries for various properties
- Built in Force models can be specified
- Custom force models should be packaged into a "Force object"
- This object should return the (downstairs indexed) F_r, F_\theta, F_\phi with F_t determined from the orthogonality condition. The object should use pex params and darwin angles
- This object should also accept additional arguments the force might need, like a drag coefficient for the gas drag model etc.
- Keep unused legacy code for now, but segragate it away
- Need unit tests
- Need full documentation with examples
- Set up paclet support so it can be placed on a paclet server for distribution

## Future features that might be nice

- Support for Flux modes that replace the RHS with pdot, edot, xdot (orbit averaged)

- Each built in force object having properties that can be queried, like parameter range, paper citation, etc.

- Having multiple forces/ fluxes driving an inspiral

## Polar motion near the equator and the poles (for later)

The pex polar variables (x, ψθ) are singular for equatorial orbits (x = ±1). There ψθ is undefined, and its equation contains a term proportional to F_θ / √(1 − x²), so in these variables a force with a θ component cannot lift an orbit out of the plane. The current code avoids this by holding equatorial orbits in the plane (see "Before Phase 0"), which rules out such forces.

**Planned replacement:** evolve the 3-vector (αθ, βθ, x), which satisfies αθ² + βθ² + x² = 1, where

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

**Checked so far, at the level of the equations only, not yet in a solver:** they match pex's (x, ψθ) equations to 10⁻¹² or better for a = 0, 0.5 and 0.9, prograde and retrograde, and x from 0.999 down to ±0.01.

**Open issues:**

- `Energy`, `AngularMomentum` and `CarterConstant` give 0/0 at x = 0, and lose about half their digits near it (L is off by 2×10⁻⁸ at x = 10⁻⁸). They need forms that are safe at x = 0, for example KerrGeodesics' polar-orbit formulas.
- **The Boyer–Lindquist axis.** Orbits with x ≈ 0 pass close to θ = 0, π, where the 1/sin θ terms grow and φ swings by nearly π. These terms stay bounded for smooth forces and are only 0/0 exactly on the axis.
  - An inspiral crossing x = 0 generically misses the axis, so it only costs small steps.
  - An exactly polar orbit (L held at 0) crosses the axis every half polar period. Treat exactly polar orbits as unsupported.
- The current pex solver can already cross x = 0, because NDSolve steps over the 0/0 in its dx/dλ. Its accuracy there is limited by the constants-of-motion problem above.
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
│   ├── Interface.wl                  Entry point: parameter Association, validation, solver and force
│   │                                 selection, the shared NDSolve driver
│   ├── InspiralObject.wl             Inspiral object: construction, property access, summary box
│   ├── Utilities.wl                  Constants of motion, radial roots, separatrix, index raising/lowering,
│   │                                 F_t from orthogonality, caching
│   ├── Solvers/
│   │   ├── KerrPEX.wl                Default: p, e, x equations, plus the p, α, β equations used at small e
│   │   ├── KerrELK.wl                En, L, K equations (to be supported later)
│   │   └── Schwarzschild.wl          Existing Schwarzschild solvers
│   ├── ForceModels/
│   │   ├── ForceObject.wl            Force object: parameters, evaluation, combining forces
│   │   ├── GasDrag.wl                Gas drag (Schwarzschild and Kerr)
│   │   ├── EMConservative.wl         Conservative electromagnetic force
│   │   └── FastGSF.wl                Fast first-order GSF fit (Schwarzschild); reads Data/FastGSF
│   └── Legacy/
│       └── LegacyEquations.wl        Unused code kept for reference (see Legacy code below)
├── Data/FastGSF/                     a_n_jk, b_n_jk, c_n_jk, d_n_jk (currently DataFiles/)
├── Documentation/                    Reference pages, guide page and tutorials
├── Tests/
│   ├── AllTests.wls                  Runs every test file
│   └── *.wlt                         VerificationTest files, one per area
├── tutorial.nb                       To be replaced by Documentation/
├── Data generation.nb                Unchanged
├── TestingELKvspex.nb                Unchanged
└── README.md, LICENSE, .gitignore
```

`Interface.wl`, `InspiralObject.wl` and `ForceObject.wl` are created in phases 3 and 4 of the checklist, and `Documentation/` in phase 6. The future features fit this structure without changes. Orbit-averaged flux evolution would be another file in `Solvers/`. A new built-in force is a new file in `ForceModels/`, and combining several forces belongs in `ForceObject.wl`.

### Conventions

- **One public context, one shared private context.** The header declares the public symbols in `` OsculatingOrbitalElements` ``, then loads the other files inside `` Begin["`Private`"] ``. Those files have no `BeginPackage` of their own, so any private helper can be used from any file, and moving code between files needs no import or export changes.
- **Public symbols are declared only in the header.** A new public function or option needs its usage message there; otherwise it is created as a private symbol.
- **The header lists the KerrGeodesics subcontexts explicitly.** The other files are read with the header's `$ContextPath`, and `` "KerrGeodesics`" `` alone does not include `` KerrGeodesics`ConstantsOfMotion` `` or `` KerrGeodesics`SpecialOrbits` ``. Without them, a name such as `KerrGeoEnergy` silently becomes a new private symbol that never evaluates.
- **Load order:** Utilities, ForceModels, Solvers, InspiralObject, Interface, then Legacy. Only code that runs at load time, such as reading the FastGSF data, depends on it.
- **Paths come from the package itself.** The header records its own directory from `$InputFileName`. Nothing calls `SetDirectory` or assumes `$UserBaseDirectory`.

### Legacy code

Unused code is kept but separated from the active code:

- It lives in `Kernel/Legacy/`, which the header loads last, in a block marked as legacy.
- Each legacy file starts with a comment saying that it is legacy, is not used by the current interface, and should not be extended.
- Legacy public functions keep working. Their usage messages move to a marked legacy section at the end of the header (public symbols must be declared there) and say that the function is legacy.
- Usage messages for functions that no longer exist are kept as comments in the legacy file, so they do not create undefined public symbols.

Legacy now:

- `KerrOscGeoEqs`, `KerrOscGeoEqsTP` and `KerrOscGeoEqsTPVecLessArg`, which are never called.
- The usage messages for `KerrOsculatingOrbitalElementsTP` and `KerrOsculatingOrbitalElementsTPVec`, which have no definitions.

Legacy later: each current public function (`SchwarzOsculatingOrbitalElements`, `SchwarzOsculatingOrbitalElementsTP`, `KerrOsculatingOrbitalElements`, `GenericKerrpexBL`, `GenericKerrREGBL`) and the force functions with the old signatures. Each moves once the new interface reproduces its results.

### Where the current code goes

| Current code in `OsculatingOrbitalElements.m` | New file |
|---|---|
| Usage messages, options, `SyntaxInformation`, message texts | `OsculatingOrbitalElements.wl` |
| `SchwarzOscGeoEqs1`, `…TP`, `…2`, `…2TP` and the two Schwarzschild public functions | `Solvers/Schwarzschild.wl` |
| `KerrOsculatingOrbitalElements` | `Solvers/KerrELK.wl` |
| `GenericKerrpexBL`, `GenericKerrREGBL` | `Solvers/KerrPEX.wl` |
| `SchwarzGasDrag`, `KerrGasDrag`, `KerrGasDragVec`, `KerrGasDragapex` | `ForceModels/GasDrag.wl` |
| `KerrEMCons` | `ForceModels/EMConservative.wl` |
| `SchwarzFastGSF` and its data loading | `ForceModels/FastGSF.wl` |
| Radial roots, `SeparatrixEqELK`, constants of motion and `memoLast`, `MinoParametrisationQ` | `Utilities.wl` |
| `KerrOscGeoEqs`, `…TP`, `…TPVecLessArg`, and the stale usage messages | `Legacy/LegacyEquations.wl` |

## Checklist for improvements that should be made

### Before Phase 0: fixes to the current code

- [x] Equatorial orbits (x = ±1) in the pex and REG solvers: x is held at exactly ±1, the polar equations are dropped, and a force with a θ component on the plane is rejected. This is temporary until the regular polar formulation replaces it (see "Polar motion near the equator and the poles").
- [x] pex gas drag at a = 0: `KerrGasDragapex` divided by a²(1 − E²) to get zm; it now uses zm = 1 − x²
- [x] `IntegrationLimit` is in the units of the chosen time variable, with no hidden ×1000. The Kerr default is `Automatic`: 10⁷ in coordinate time and 10⁴ in Mino time.
- [x] `Print` replaced by messages that say why the integration stopped, and `Monitor` only used when a front end is present (Kerr solvers)
- [x] FastGSF coefficient tables built once at load
- [ ] Report to KerrGeodesics: `KerrGeoSeparatrix[a, e, ±1.]` does not evaluate when a ≠ 0 (worked around here by holding x at exact ±1)

### Phase 0: Tests before any restructuring

- [ ] Set up `Tests/` with `.wlt` files and an `AllTests.wls` runner, and run it against the current single-file package
- [ ] Geodesic limit (η → 0) against `KerrGeoOrbit` for every solver
- [ ] Agreement between the ELK, pex and REG solvers
- [ ] Continuity across the Schwarzschild e₀ = 0.05 switch, in both χ and coordinate time
- [ ] Constants of motion against `KerrGeoConstantsOfMotion`, including e = 0
- [ ] Bad input returns `$Failed` with a message: unbound orbit, invalid force, invalid `Parametrisation`
- [ ] Memo caches stay bounded after a solve
- [ ] Save reference outputs, so phase 1 can be checked for identical results

### Phase 1: Restructure with no change in behaviour

- [ ] Create the `Kernel/` layout with `.wl` files and an `init.wl` that loads the header
- [ ] Move the code as in the table above, without changing any equations
- [ ] Move unused code to `Kernel/Legacy/` with legacy headers, and comment out the stale usage messages there
- [ ] Record the package directory from `$InputFileName`, move `DataFiles/` to `Data/FastGSF/`, and remove `SetDirectory`
- [ ] Add `PacletInfo.wl`
- [ ] Tests pass with identical outputs, and `tutorial.nb` still runs
- [ ] Update the README install instructions (Applications folder and `PacletDirectoryLoad`)

### Phase 2: Separate the interface from the solvers

- [ ] Define what each solver file provides: variables, initial conditions, equations, stop events, and derived quantities (r, θ, En, L, Q, …)
- [ ] Write one NDSolve driver shared by all solvers:
  - [ ] Stop conditions (separatrix, pMin, maximum time) handled in one place
  - [ ] A configurable separatrix buffer (currently fixed at η)
  - [ ] Store why the integration stopped in the output (currently only reported as a message)
  - [ ] Pass NDSolve options straight through
- [ ] Move the orbit geometry (Σ, Δ, roots, velocities), currently repeated in several functions, into `Utilities.wl`

### Phase 3: New interface and inspiral object

- [ ] Decide the keys and defaults of the parameter Association, following WaSABI
- [ ] Decide the name and signature of the entry function
- [ ] Validate inputs: bound orbit, parameter ranges, missing keys
- [ ] Make the pex solver the default, reporting in Boyer–Lindquist coordinate time with the Darwin (ψr) and Hughes (ψθ) angles
- [ ] Decide whether Mino time remains available as an option
- [ ] Switch to p, α, β at small e:
  - [ ] Decide the criterion: based on the initial e₀ (as now), or switching during the integration
  - [ ] Merge the pex small-e branch with the REG equations
- [ ] Replace the (x, ψθ) polar equations with the (αθ, βθ, x) formulation, and remove the equatorial safeguard (see "Polar motion near the equator and the poles")
- [ ] Make the constants of motion safe at x = 0
- [ ] Decide whether Schwarzschild stays a separate solver or becomes the a = 0 case of the Kerr solver (this needs the equatorial support above)
- [ ] Build the inspiral object, modelled on `KerrGeoOrbitFunction`:
  - [ ] Properties: trajectory, orbital elements, constants of motion, phases, domain, stop reason, input parameters and force
  - [ ] Summary box
- [ ] Later: offer ELK as an option. Its `"p"` and `"e"` outputs are slow because every evaluation solves the radial quartic, and its gas drag (`KerrGasDrag`, `KerrGasDragVec`) still divides by zero at a = 0.

### Phase 4: Force objects

- [ ] Force object wrapping one function of (a, p, e, x, ψr, ψθ, parameters) that returns the downstairs {F_r, F_θ, F_φ}, and is only evaluated on numeric input
- [ ] Compute F_t from the orthogonality condition in `Utilities.wl`
- [ ] Hold extra model parameters (such as a drag coefficient) in the object, and decide how they relate to η
- [ ] Solvers accept only Force objects, and built-in models can be selected by name
- [ ] Rewrite gas drag, conservative EM and FastGSF as Force objects, each returning all components from a single evaluation
- [ ] Vectorise the FastGSF sum. The tables are now built once, but the 1,600-term sum is about 94% of the 4 ms per call. Solves aren't affected today, because the solvers expand FastGSF symbolically once.

### Phase 5: Legacy

- [ ] When the new interface reproduces a current public function's results, move that function to `Kernel/Legacy/` and mark its usage message as legacy
- [ ] Decide what to do with `Data generation.nb` and `TestingELKvspex.nb`, which call functions that no longer exist

### Phase 6: Documentation and distribution

- [ ] Reference pages for every public symbol, a guide page, and tutorials with worked examples
- [ ] Turn `tutorial.nb` into documentation, fixing its current bugs (undefined `ELKup`, and sin θ and cos θ swapped in the 3D plot)
- [ ] Update the README: features, installation, links
- [ ] Write up the regular polar formulation
- [ ] Strip outputs from committed notebooks
- [ ] Build the paclet and publish it to a paclet server
- [ ] Optional: run the tests automatically on GitHub, as KerrGeodesics does

