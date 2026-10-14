OsculatingOrbitalElements
===============================================================================

The OsculatingOrbitalElements package solves the forced geodesic motion in either Schwarzshild or Kerr spacetime 
using the Method of Osculating Orbital Elements (also known as the Method of Osculating Geodeiscs).

The user can specify the function for the force or make use of the models included with the package (see the example below).
The earlier functions use these:

SchwarzFastGSF[p, e, &xi;]: Fast first order Gravitational Self Force Model for p<12 and e<0.2.

SchwarzGasDrag[p, e, &xi;]: Relativistic gas drag model for Schwarzschild spacetime.

KerrGasDrag[En, L, K, &psi;r, &psi;&theta;]: Relativistic gas drag model for Kerr spacetime.

Getting the package
-------------------
The latest development version will always be available from the project git
repository:

git clone https://github.com/BlackHolePerturbationToolkit/OsculatingOrbitalElements.git

Requirements
------------
- Mathematica (Wolfram Language) 13.1 or later.
- The [KerrGeodesics package](https://github.com/BlackHolePerturbationToolkit/KerrGeodesics).

Installation
------------
There are two ways to make the package available. Whichever you use, keep only one copy of
OsculatingOrbitalElements where Mathematica can find it, or an older copy may be loaded instead.

**Applications folder.** Clone the repository into the `Applications` folder of your user base
directory, keeping the folder name `OsculatingOrbitalElements`. To find that folder, evaluate

```mathematica
FileNameJoin[{$UserBaseDirectory, "Applications"}]
```

On macOS this is `~/Library/Wolfram/Applications` in recent versions and
`~/Library/Mathematica/Applications` in older ones.

**Paclet.** Clone the repository anywhere and load it as a paclet in each session (or in your
`init.m`):

```mathematica
PacletDirectoryLoad["/path/to/OsculatingOrbitalElements"]
```

Usage
-----
Load the package, which also loads KerrGeodesics, with

```mathematica
<< OsculatingOrbitalElements`
```

Example
--------
An inspiral driven by relativistic gas drag, around a black hole with spin a = 0.9:

```mathematica
drag = ForceModel["GasDrag", "Coefficient" -> 10^-5];
inspiral = OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 0.8, "Force" -> drag|>];
inspiral["StopReason"]      (* why the integration stopped *)
inspiral["p"][1000.]        (* p at coordinate time t = 1000 *)
inspiral[1000.]             (* {t, r, \[Theta], \[Phi]} at t = 1000 *)
inspiral["Properties"]      (* everything that can be queried *)
```

A custom force is a function of the elements, the phases, the azimuth φ and the coordinate time t that returns the
covariant {F_r, F_θ, F_φ}; F_t follows from orthogonality to the velocity. Forces in a list add:

```mathematica
kick = ForceModel[Function[{a, p, e, x, ψr, ψθ, φ, t}, {0, 0.1, 0}], "Name" -> "Vertical"];
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 1, "Force" -> {drag, kick}|>]
```

The built-in models are `"GasDrag"`, `"EMConservative"` and `"FastGSF"` (Schwarzschild).

An inspiral can also be driven by a flux: orbit-averaged rates of change of p, e and x, or of E, L and Q, with respect
to coordinate time. A flux changes only the slowly varying elements, and can be combined with forces. `"Peters"` is the
leading-order gravitational-wave flux, and `FluxModel[force]` is the orbit average of a force:

```mathematica
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-2, "p" -> 12, "e" -> 0.3, "x" -> 0.7, "Flux" -> "Peters", "Force" -> drag|>]
OsculatingInspiral[<|"a" -> 0.9, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> 0.2, "x" -> 1, "Flux" -> FluxModel[drag]|>,
  IntegrationLimit -> 5000]
```

Orbit-averaging a force is slow, since every evaluation averages it over the orbit; its parameter `"Points"` sets the
number of points in each phase (16 by default).

Older examples, using the earlier functions, are included in tutorial.nb.

Tests
-----
Run the test suite from the repository folder with

```
wolframscript -file Tests/AllTests.wls
```

It takes about a minute and exits with status 1 if any test fails. To run only some of the test
files, add their names, for example `wolframscript -file Tests/AllTests.wls Caching Regression`.

Changelog
---------
25 March 2019: Initial version created.

19 September 2019: Added code for Kerr Spacetime

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