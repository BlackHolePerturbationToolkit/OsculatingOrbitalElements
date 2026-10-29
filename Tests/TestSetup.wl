(* ::Package:: *)

(* ::Title:: *)
(*Test setup*)


(* ::Text:: *)
(*Loads this copy of the package and defines helpers shared by the test files. AllTests.wls loads it before running the tests; to run a single .wlt file in a notebook, Get this file first and then call TestReport on the .wlt file.*)


(* ::Section:: *)
(*Load the package*)


(* ::Text:: *)
(*Put this repository first on $Path, so that an older copy elsewhere on $Path (for example in another Applications folder) is not loaded instead.*)


$testsDirectory = DirectoryName[ExpandFileName[$InputFileName]];
$repoDirectory = ParentDirectory[$testsDirectory];
PrependTo[$Path, ParentDirectory[$repoDirectory]];

(* Package.wlt checks what loading the package did: messages, public symbols and the working directory *)
$directoryBeforeLoading = Directory[];
Block[{$MessageList = {}},
	Get["OsculatingOrbitalElements`"];
	$loadMessages = $MessageList];
$publicSymbolsAfterLoading = Names["OsculatingOrbitalElements`*"];
$directoryAfterLoading = Directory[];

If[!StringStartsQ[FindFile["OsculatingOrbitalElements`"], $repoDirectory],
	Print["Loaded the package from ", FindFile["OsculatingOrbitalElements`"], " rather than ", $repoDirectory,
		". The repository folder must be called OsculatingOrbitalElements."];
	Exit[1]];


(* ::Section:: *)
(*Helpers*)


(* ::Text:: *)
(*Every solve reports why it stopped with a message. Tests that are not about those messages suppress them, together with FindRoot::brmp, which KerrGeoOrbitType and KerrGeoOrbit emit. Any other message still fails the test.*)


(* The message names must appear literally inside Quiet, which holds them; evaluating a message name gives its text. *)
SetAttributes[quietStops, HoldAll];
quietStops[expr_] := Quiet[expr, {
	KerrOsculatingOrbitalElements::sep, KerrOsculatingOrbitalElements::sepbuf,
	KerrOsculatingOrbitalElements::pmin, KerrOsculatingOrbitalElements::limit,
	SchwarzOsculatingOrbitalElements::sep, SchwarzOsculatingOrbitalElements::limit,
	FindRoot::brmp}];

(* Messages that a test expects should still appear when an earlier test issued the same message. *)
Off[General::stop];


(* ::Text:: *)
(*SameTest for numerical results: passes when every component differs from the expected value by at most tol. tol is a number, or a list with one tolerance per component.*)


withinTolerance[tol_][actual_, expected_] := TrueQ[And @@ Thread[Abs[N[Flatten[{actual}] - Flatten[{expected}]]] <= tol]];


(* ::Text:: *)
(*{r, Cos[\[Theta]], \[Phi]} of the geodesic with the same parameters, at the given coordinate times. KerrGeoOrbit starts at periapsis with Cos[\[Theta]] = Sqrt[1 - x^2], which matches \[Psi]r0 = \[Psi]\[Theta]0 = 0 (or \[Xi]0 = 0) in this package.*)


geodesicAtTimes[{a_, p_, e_, x_}, times_List] := Module[{t, r, \[Theta], \[Phi], \[Lambda], \[Lambda]AtTime},
	{t, r, \[Theta], \[Phi]} = Quiet[KerrGeoOrbit[a, p, e, x]["Trajectory"], FindRoot::brmp];
	Table[
		\[Lambda]AtTime = \[Lambda] /. FindRoot[t[\[Lambda]] == time, {\[Lambda], time/p^2}];
		{r[\[Lambda]AtTime], Cos[\[Theta][\[Lambda]AtTime]], \[Phi][\[Lambda]AtTime]},
		{time, times}]];


(* ::Text:: *)
(*Largest deviations {|\[CapitalDelta]r|, |\[CapitalDelta]Cos[\[Theta]]|, |\[CapitalDelta]\[Phi]|} of a solution from the geodesic. samples are values of the solution's independent variable, and timeOf converts them to coordinate time (Identity for solutions in coordinate time).*)


geodesicDeviation[sol_, orbit_, samples_List, timeOf_ : Identity] := Module[{ours, geodesic},
	ours = Table[{sol["r"][s], Cos[sol["\[Theta]"][s]], sol["\[Phi]"][s]}, {s, samples}];
	geodesic = geodesicAtTimes[orbit, timeOf /@ samples];
	Max /@ Transpose[Abs[ours - geodesic]]];


(* ::Text:: *)
(*Largest difference between two solutions in the given outputs, at the given samples.*)


maxDifference[sol1_, sol2_, keys_List, samples_List] :=
	Table[Max[Abs[(sol1[k] /@ samples) - (sol2[k] /@ samples)]], {k, keys}];


(* ::Text:: *)
(*Values of the given outputs where the integration stopped.*)


endValues[sol_, keys_List] := Table[sol[k][sol["limit"]], {k, keys}];
