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
  - [ ] Stop conditions (separatrix, pMin, maximum time) in the units of the chosen time variable, removing the hidden ×1000 in `IntegrationLimit`
  - [ ] A configurable separatrix buffer (currently fixed at η)
  - [ ] Record why the integration stopped
  - [ ] Pass NDSolve options straight through
- [ ] Replace `Print` with messages or a `Verbose` option, and only use `Monitor` when a front end is present
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
- [ ] Support equatorial orbits (x = ±1). The pex and REG polar equations divide by √zm, so both currently fail there; REG only works when a = 0.
- [ ] Decide whether Schwarzschild stays a separate solver or becomes the a = 0 case of the Kerr solver (this needs the equatorial support above)
- [ ] Build the inspiral object, modelled on `KerrGeoOrbitFunction`:
  - [ ] Properties: trajectory, orbital elements, constants of motion, phases, domain, stop reason, input parameters and force
  - [ ] Summary box
- [ ] Later: offer ELK as an option. Its `"p"` and `"e"` outputs are slow because every evaluation solves the radial quartic.

### Phase 4: Force objects

- [ ] Force object wrapping one function of (a, p, e, x, ψr, ψθ, parameters) that returns the downstairs {F_r, F_θ, F_φ}, and is only evaluated on numeric input
- [ ] Compute F_t from the orthogonality condition in `Utilities.wl`
- [ ] Hold extra model parameters (such as a drag coefficient) in the object, and decide how they relate to η
- [ ] Solvers accept only Force objects, and built-in models can be selected by name
- [ ] Rewrite gas drag, conservative EM and FastGSF as Force objects, each returning all components from a single evaluation
- [ ] Build the FastGSF coefficient tables once, rather than on every call

### Phase 5: Legacy

- [ ] When the new interface reproduces a current public function's results, move that function to `Kernel/Legacy/` and mark its usage message as legacy
- [ ] Decide what to do with `Data generation.nb` and `TestingELKvspex.nb`, which call functions that no longer exist

### Phase 6: Documentation and distribution

- [ ] Reference pages for every public symbol, a guide page, and tutorials with worked examples
- [ ] Turn `tutorial.nb` into documentation, fixing its current bugs (undefined `ELKup`, and sin θ and cos θ swapped in the 3D plot)
- [ ] Update the README: features, installation, links
- [ ] Strip outputs from committed notebooks
- [ ] Build the paclet and publish it to a paclet server
- [ ] Optional: run the tests automatically on GitHub, as KerrGeodesics does

