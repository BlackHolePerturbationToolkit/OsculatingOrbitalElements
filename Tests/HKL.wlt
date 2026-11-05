(* ::Package:: *)

(* HKLambda coordinate charts and the Boyer-Lindquist axis. Shared behaviour is tested in the thematic files. *)

(* Both charts must agree at x = 0. The three forces cover initial data on the
	 north pole, south pole and away from the axis; no BL force is evaluated there. *)
Table[
	VerificationTest[
		Module[{parameters, plus, minus, times = N[Subdivide[0, 300, 30]], difference},
			parameters = <|"a" -> If[polarCase[[1]] === "FastGSF", 0, .5], "\[Epsilon]" -> 10^-5,
				"p" -> 10, "e" -> .1, "x" -> 0, "\[Psi]r" -> .3, "\[Psi]\[Theta]" -> polarCase[[2]], "\[Phi]" -> .7,
				"Force" -> If[polarCase[[1]] === "GasDrag", ForceModel["GasDrag", "Coefficient" -> 10^-5], ForceModel[polarCase[[1]]]]|>;
			plus = OsculatingInspiral[parameters, AngularVariables -> "HKLambda", AngularChart -> 1,
				IntegrationLimit -> 300, InterpolationOrder -> All];
			minus = OsculatingInspiral[parameters, AngularVariables -> "HKLambda", AngularChart -> -1,
				IntegrationLimit -> 300, InterpolationOrder -> All];
			If[!MatchQ[{plus, minus}, {_OsculatingInspiralFunction, _OsculatingInspiralFunction}], Return[False]];
			difference = Max[Table[Norm[plus["Direction"][u] - minus["Direction"][u]], {u, times}]];
			plus["StopReason"] === "IntegrationLimit" && minus["StopReason"] === "IntegrationLimit" &&
				difference < 10^-8 && Max[Abs[plus["x"] /@ times]] <= 1 &&
				Max[Abs[(Norm[plus["Direction"][#]] - 1) & /@ times]] < 10^-12],
		True, TestID -> "HKL polar orbit, both charts: " <> polarCase[[1]] <> ", phase=" <> ToString[polarCase[[2]]]],
	{polarCase, {{"GasDrag", 0}, {"EMConservative", Pi}, {"FastGSF", .4}}}];

VerificationTest[
	Module[{parameters, sol},
		parameters = <|"a" -> .5, "p" -> 10, "e" -> .1, "x" -> -.9799, "\[Psi]r" -> .3, "\[Psi]\[Theta]" -> Pi/2, "\[Phi]" -> .7, "\[Epsilon]" -> .001,
			"Force" -> ForceModel[Function[{a, p, e, x, pr, pt, phi, t}, {0, -1, 0}]]|>;
		sol = OsculatingInspiral[parameters, AngularVariables -> "HKLambda", AngularChart -> 1, IntegrationLimit -> 100];
		{sol["StopReason"], Abs[sol["h"][sol["Domain"][[2]]]^2 + sol["k"][sol["Domain"][[2]]]^2 - 100] < 10^-5}],
	{"AngularChartBoundary", True}, TestID -> "HKL stops at the fixed chart boundary"];

VerificationTest[
	OsculatingInspiral[<|"a" -> .5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> .1, "x" -> 1, "Force" -> None|>, AngularVariables -> "HKLambda", AngularChart -> -1],
	$Failed, {OsculatingInspiral::chart}, TestID -> "HKL rejects the excluded pole of an explicit chart"];

VerificationTest[
	Module[{result, axisMessage = False},
		result = Quiet[Check[
			OsculatingInspiral[<|"a" -> .5, "\[Epsilon]" -> 10^-5, "p" -> 10, "e" -> .1, "x" -> 0,
				"Force" -> ForceModel[Function[{a, p, e, x, pr, pt, phi, t}, {0, 0, 0}]]|>, AngularVariables -> "HKLambda"],
			axisMessage = True; $Failed, OsculatingInspiral::hklaxis],
			{OsculatingInspiral::hklaxis, OsculatingInspiral::hklinitial}];
		{result, axisMessage}],
	{$Failed, True},
	TestID -> "HKL rejects a custom BL callback on the axis without guessing its continuation"];
