OsculatingOrbitalElements
===============================================================================

The OsculatingOrbitalElements package computes inspirals in Kerr spacetime with the method of osculating geodesics
(also known as the method of osculating orbital elements). An inspiral can be driven by forces, by fluxes, or by both:

- **Forces** act through the osculating geodesic equations. Built in are relativistic gas drag, a conservative
  electromagnetic force and a fit to the first-order gravitational self-force in Schwarzschild; any other force is a
  function of the orbital elements, the phases, the azimuth and the time, so it need not be axisymmetric or stationary.
- **Fluxes** are orbit-averaged rates of change of p, e and x, or of the energy, angular momentum and Carter constant.
  Built in are Peters' leading-order gravitational-wave fluxes, and the orbit average of any force.

Forces and fluxes can be combined, and several of each add. The equations are regular for circular orbits, and an
inspiral can pass from prograde to retrograde. Equatorial orbits are a special case: they stay in the plane, so a force
must have no θ component there. Schwarzschild is the case a = 0.

The package is part of the [Black Hole Perturbation Toolkit](https://bhptoolkit.org/).

Requirements
------------
- Mathematica (Wolfram Language) 13.1 or later.
- The [KerrGeodesics package](https://github.com/BlackHolePerturbationToolkit/KerrGeodesics).

Installation
------------
Get the latest version from the project's git repository:

```
git clone https://github.com/BlackHolePerturbationToolkit/OsculatingOrbitalElements.git
```

Then make it available in one of two ways, keeping only one copy where Mathematica can find it (otherwise an older copy
may be loaded instead).

**Applications folder.** Put the repository in the `Applications` folder of your user base directory, keeping the
folder name `OsculatingOrbitalElements`. To find that folder, evaluate

```mathematica
FileNameJoin[{$UserBaseDirectory, "Applications"}]
```

On macOS this is `~/Library/Wolfram/Applications` in recent versions and `~/Library/Mathematica/Applications` in older
ones.

**Paclet.** Put the repository anywhere and load it as a paclet in each session (or in your `init.m`):

```mathematica
PacletDirectoryLoad["/path/to/OsculatingOrbitalElements"]
```

A paclet archive (`.paclet` file) is installed with `PacletInstall["/path/to/archive.paclet"]`.

Usage
-----
Load the package, which also loads KerrGeodesics, with

```mathematica
<< OsculatingOrbitalElements`
```

An inspiral driven by relativistic gas drag, around a black hole with spin a = 0.9:

```mathematica
drag = ForceModel["GasDrag", "Coefficient" -> 10^-4];
inspiral = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Force" -> drag|>];
inspiral["StopReason"]                 (* why the integration stopped *)
inspiral["p"][1000.]                   (* p at coordinate time t = 1000 *)
inspiral[1000.]                        (* {t, r, \[Theta], \[Phi]} at t = 1000 *)
inspiral["\[CapitalOmega]r"][1000.]    (* the osculating geodesic's Boyer-Lindquist radial frequency *)
inspiral["\[CapitalPhi]r"][1000.]      (* and its Boyer-Lindquist radial action angle *)
inspiral["Properties"]                 (* everything that can be queried *)
```

The parameters are the spin `"a"`, the small mass ratio `"\[Epsilon]"`, the initial elements `"p"`, `"e"` and `"x"`
(x = cos ι), optionally the initial phases `"\[Psi]r"`, `"\[Psi]\[Theta]"` and `"\[Phi]"`, and a `"Force"`, a `"Flux"`, or
both. The integration stops just outside the separatrix, unless `IntegrationLimit` or `pMin` stops it first.

Besides the position and the elements, the inspiral gives, as functions of time, the osculating geodesic's energy,
angular momentum and Carter constant (`"En"`, `"L"`, `"Q"`), its Boyer-Lindquist frequencies (`"Ωr"`, `"Ωθ"`, `"Ωφ"`,
from KerrGeodesics), and its Boyer-Lindquist action angles (`"Φr"`, `"Φθ"`, `"Φφ"`), computed as in
[Lynch and Burke, Class. Quantum Grav. 42, 167001 (2025)](https://arxiv.org/abs/2411.04955). The phases (`"ψr"`, `"ψθ"`,
`"φ"`) and the action angles accumulate over the inspiral rather than wrapping at π.

A custom force is a function of the elements, the phases, the azimuth φ and the coordinate time t that returns the
covariant {F_r, F_θ, F_φ}; F_t follows from orthogonality to the velocity. Forces in a list add:

```mathematica
torque = ForceModel[Function[{a, p, e, x, ψr, ψθ, φ, t}, {0, 0, -1}], "Name" -> "Torque"];
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Force" -> {drag, torque}|>]
```

The built-in forces are `"GasDrag"`, `"EMConservative"` and `"FastGSF"` (Schwarzschild).

A flux changes only the slowly varying elements; the phases advance at their geodesic rates. `"Peters"` is the
leading-order gravitational-wave flux, and `FluxModel[force]` is the orbit average of a force:

```mathematica
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-2, "p" -> 12, "e" -> 0.3, "x" -> 0.7, "Flux" -> "Peters", "Force" -> drag|>]
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 1, "Flux" -> FluxModel[drag]|>,
  IntegrationLimit -> 5000]
```

Orbit-averaging a force is slow, as every evaluation averages over the orbit; its parameter `"Points"` sets the number
of points in each phase (16 by default).

Documentation
-------------
The documentation is in the Wolfram Documentation Center: search for OsculatingInspiral, or open the guide page
`paclet:OsculatingOrbitalElements/guide/OsculatingOrbitalElements`. It has a reference page for each public symbol and a
tutorial.

`Notes/RegularFormulation.md` describes the variables and equations, and why they were chosen. Its regular polar
formulation, which would let a force lift an equatorial orbit out of the plane, is on hold.

The earlier functions
---------------------
The earlier functions, such as `SchwarzOsculatingOrbitalElements`, `KerrOsculatingOrbitalElements`, `GenericKerrpexBL`
and the force functions `KerrGasDrag`, `KerrEMCons` and `SchwarzFastGSF`, keep working but are legacy:
`OsculatingInspiral`, `ForceModel` and `FluxModel` supersede them. Their code is in `Kernel/Legacy`, and their tutorial
in `Notebooks/Legacy`.

Building the documentation and the paclet
-----------------------------------------
From the repository folder, the documentation notebooks in `Documentation/English` are generated, with their examples
evaluated, by

```
wolframscript -file Documentation/MakeDocumentation.wls
```

(edit that script rather than the notebooks), and a paclet archive, with the documentation built, is made in `build/` by

```
wolframscript -code 'Needs["PacletTools`"]; PacletTools`PacletBuild[Directory[]]'
```

Tests
-----
Run the test suite from the repository folder with

```
wolframscript -file Tests/AllTests.wls
```

It takes about six minutes and exits with status 1 if any test fails. To run only some test files, add their names,
for example `wolframscript -file Tests/AllTests.wls FluxModels Regression`.

Changelog
---------
25 March 2019: Initial version created.

19 September 2019: Added code for Kerr Spacetime

2026: New interface. `OsculatingInspiral`, with force models (`ForceModel`), flux models (`FluxModel`) and an inspiral
object that also gives the osculating geodesic's Boyer-Lindquist frequencies and action angles; equations regular for
circular orbits and through x = 0; documentation and a test suite. The earlier functions are kept as legacy.

Known problems
--------------
Known bugs are recorded in the project bug tracker:

https://github.com/BlackHolePerturbationToolkit/OsculatingOrbitalElements/issues

License
-------
This code is distributed under the MIT Open Source License.
Details can be found in the LICENSE file.


Authors
-------
Philip Lynch
