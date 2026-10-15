#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Runs the test suite.
     wolframscript -file Tests/AllTests.wls                     runs every .wlt file in Tests/
     wolframscript -file Tests/AllTests.wls Caching Equatorial  runs only the named files
   Exits with status 1 if any test fails. *)

Get[FileNameJoin[{DirectoryName[ExpandFileName[First[$ScriptCommandLine]]], "TestSetup.wl"}]];

Print["Wolfram version: ", $Version];
Print["Package: ", FindFile["OsculatingOrbitalElements`"], "\n"];

testFiles = FileNames["*.wlt", $testsDirectory];
If[Length[$ScriptCommandLine] > 1,
	unknown = Complement[Rest[$ScriptCommandLine], FileBaseName /@ testFiles];
	If[unknown =!= {},
		Print["No test files named ", unknown, ". Available: ", FileBaseName /@ testFiles];
		Exit[1]];
	testFiles = Select[testFiles, MemberQ[Rest[$ScriptCommandLine], FileBaseName[#]] &]];

show[expr_] := StringTake[ToString[expr /. HoldForm[x_] :> x, InputForm], UpTo[300]];
seconds[time_] := ToString[Round[10 QuantityMagnitude[time, "Seconds"]]/10.] <> " s";

printFailure[result_] := (
	Print["    FAILED: ", result["TestID"], " (", result["Outcome"], ")"];
	Switch[result["Outcome"],
		"Failure",
			Print["      expected: ", show[result["ExpectedOutput"]]];
			Print["      actual:   ", show[result["ActualOutput"]]],
		"MessagesFailure",
			Print["      expected messages: ", show[result["ExpectedMessages"]]];
			Print["      actual messages:   ", show[result["ActualMessages"]]],
		_, Null]);

reports = Table[
	report = TestReport[file];
	Print[StringPadRight[FileBaseName[file], 20],
		report["TestsSucceededCount"], " passed, ", report["TestsFailedCount"], " failed  (",
		seconds[report["TimeElapsed"]], ")"];
	Scan[printFailure, Select[Values[report["TestResults"]], #["Outcome"] =!= "Success" &]];
	If[report["TestsSucceededCount"] + report["TestsFailedCount"] == 0,
		Print["    No tests ran. Check the file for errors."]];
	report,
	{file, testFiles}];

passed = Total[#["TestsSucceededCount"] & /@ reports];
failed = Total[#["TestsFailedCount"] & /@ reports] + Count[reports, r_ /; r["TestsSucceededCount"] + r["TestsFailedCount"] == 0];
Print["\nTotal: ", passed, " passed, ", failed, " failed  (", seconds[Fold[Plus, Quantity[0, "Seconds"], #["TimeElapsed"] & /@ reports]], ")"];

Exit[If[failed == 0, 0, 1]];
