OsculatingOrbitalElements
===============================================================================

The OsculatingOrbitalElements package solves the forced geodesic motion in either Schwarzshild or Kerr spacetime 
using the Method of Osculating Orbital Elements (also known as the Method of Osculating Geodeiscs).

The user can specify the function for the force or make use of the following models included with the package:

SchwarzFastGSF[p, e, &xi;]: Fast first order Gravitational Self Force Model for p<12 and e<0.2.

SchwarzGasDrag[p, e, &xi;]: Relativistic gas drag model for Schwarzschild spacetime.

KerrGasDrag[En, L, K, &psi;r, &psi;&theta;]: Relativistic gas drag model for Kerr spacetime.

Getting the package
-------------------
The latest development version will always be available from the project git
repository:

git clone https://github.com/ucd-relativity/OsculatingOrbitalElements.git

Requirements
------------
Mathematica: OsculatingOrbitalElements requires a recent version of Mathematica. 
It is typically tested with only the latest available version.

Installation
------------
Clone the repository and place it somewhere on Mathematica's `$Path`.
Typical locations are inside `${HOME}/.Mathematica/Applications/` for Linux,
`${HOME}/Library/Mathematica/Applications/` for Mac OSX, or in 
`C:\Users\yourusername\AppData\Roaming\Mathematica\Applications`
for Windows.

This package requires the [KerrGeodesics Package](https://github.com/BlackHolePerturbationToolkit/KerrGeodesics).


Usage
-----
This package, along with the KerrGeodesics package may be loaded into Mathematica using the command:

```mathematica
<< OsculatingOrbitalElements`
```
Example
--------
Examples are included in tutorial.nb.

Changelog
---------
25 March 2019: Initial version created.

19 September 2019: Added code for Kerr Spacetime

Known problems
--------------
Known bugs are recorded in the project bug tracker:

https://github.com/ucd-relativity/OsculatingOrbitalElements/issues

License
-------
This code is distributed under the MIT Open Source License. 
Details can be found in the LICENSE file.


Authors
-------
Philip Lynch