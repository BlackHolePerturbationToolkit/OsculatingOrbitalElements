===============================================================================
 OsculatingOrbitalElements
===============================================================================

The OsculatingOrbitalElements package calculates the inpsiral of a 'small' 
compact object orbiting a Schwarzschild Black Hole when provided a function 
for its gravitational slef-acceleration using the Method of Osculating Orbital 
Elements (also known as Method of Osculating Geodeiscs).

The package comes with a function for the Gravitaional Self Acceleration
'Fast GSF', for p <= 12 and e <= 0.2 which can imeadiately be used with 
the package.
===============================================================================

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

<< OsculatingOrbitalElements`

Examples
--------
First define the r and \theta componants of the self acceleration:

Fr[p_, e_, \[Xi]_] := FastGSF[p, e, \[Xi]]["Fr"];
F\[Phi][p_, e_, \[Xi]_] := FastGSF[p, e, \[Xi]]["F\[Phi]"];

Next define the mass ratio and the initial conditions:

\[Eta] = 10^-5;
p0 = 12;
e0 = 0.2;
\[Xi]0 = 0.0;

Finally, calculate the inspiral:

OsculatingOrbitalElementEvolutionSchwarzschild[Fr, F\[Phi] , \[Eta], \
p0, e0, \[Xi]0]

The output is a list of accosciaitons for p, e, \[Xi] as well as 
 t, r, \[Theta] and \[Phi]. 

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