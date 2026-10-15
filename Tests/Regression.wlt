(* ::Package:: *)

(* Regression: fixed solver outputs (RegressionCases.wl) against ReferenceOutputs.wl.
   On the Wolfram version and system that generated ReferenceOutputs.wl they must match exactly; that is how a change
   meant to leave results untouched, such as Phase 1 of the refactor, is checked. Elsewhere NDSolve can differ slightly,
   so a relative tolerance of 1e-8 is used. Regenerate the file with MakeReferenceOutputs.wls only when a change in
   results is intended. *)

Get[FileNameJoin[{$testsDirectory, "RegressionCases.wl"}]];
reference = Get[FileNameJoin[{$testsDirectory, "ReferenceOutputs.wl"}]];

regressionTolerance = If[reference["Version"] === $Version && reference["SystemID"] === $SystemID, 0, 10^-8];
If[regressionTolerance =!= 0,
	Print["    Note: ReferenceOutputs.wl was made with ", reference["Version"], " on ", reference["SystemID"],
		", so outputs are compared with a relative tolerance of 1e-8 rather than exactly."]];

(* Largest difference relative to the reference value, or absolute for reference values smaller than 1 *)
regressionSameTest[actual_, expected_] :=
	Length[actual] === Length[expected] &&
	TrueQ[Max[MapThread[Abs[#1 - #2]/Max[1, Abs[#2]] &, {actual, expected}]] <= regressionTolerance];

VerificationTest[
	Sort[Keys[regressionCases]]
	,
	Sort[Keys[reference["Outputs"]]]
	,
	TestID -> "Regression: the cases match those in ReferenceOutputs.wl"
]

Table[
	VerificationTest[
		regressionCases[label]
		,
		reference["Outputs"][label]
		,
		SameTest -> regressionSameTest,
		TestID -> "Regression: " <> label
	],
	{label, Keys[reference["Outputs"]]}]
