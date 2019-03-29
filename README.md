OsculatingOrbitalElements
===============================================================================

The OsculatingOrbitalElements package calculates the inpsiral of a 'small' 
compact object orbiting a Schwarzschild Black Hole when provided a function 
for its gravitational slef-acceleration using the Method of Osculating Orbital 
Elements (also known as Method of Osculating Geodeiscs).

The package comes with a function for the Gravitaional Self Acceleration
'FastGSF', for p <= 12 and e <= 0.2 which can imeadiately be used with 
the package.

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
Clone the repository and place it somewhere on Mathematica's $Path.
Typical locations are inside ${HOME}/.Mathematica/Applications/ for Linux or
inside ${HOME}/Library/Mathematica/Applications/ for Mac OSX.


Usage
-----
The package may be loaded into Mathematica using the command:

```Mathematica
<< OsculatingOrbitalElements`
```
Example
--------

First define the r and &phi; componants of the self acceleration

```
Fr[p_, e_, &xi;_] := FastGSF[p, e, &xi;]["Fr"];
F&phi;[p_, e_, &xi;_] := FastGSF[p, e, &xi;]["F&phi;"];

```

Next define the mass ratio and the initial conditions.

```
&eta; = 10^-5;
p0 = 12;
e0 = 0.2;
&xi;0 = 0.0;

```

Finally, calculate the inspiral.

```
 
OsculatingOrbitalElementsEvolutionSchwarzschild[Fr, F&phi; , &eta;, p0, e0, &xi;0]

```

The output is a list of accosciaitons for p, e, &xi; as well as 
 t, r, &theta; and &phi;. 

Changelog
---------
25 March 2019: Initial version created.

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