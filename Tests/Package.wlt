(* ::Package:: *)

(* The package's public symbols and what loading it does. TestSetup.wl records these when it loads the package.
   Update the expected symbols when the public interface changes on purpose. *)

VerificationTest[
	Sort[$publicSymbolsAfterLoading]
	,
	(* pMin$ comes from Module renaming its local variable pMin, which shares its name with the pMin option. It should go
	   when the options are reworked. *)
	Sort[{"Force", "ForceUpDown", "GenericKerrpexBL", "GenericKerrREGBL", "IntegrationLimit", "KerrEMCons", "KerrGasDrag",
		"KerrGasDragVec", "KerrOsculatingOrbitalElements", "Parametrisation", "pMin", "pMin$", "SchwarzFastGSF",
		"SchwarzGasDrag", "SchwarzOsculatingOrbitalElements", "SchwarzOsculatingOrbitalElementsTP", "TimeMonitor"}]
	,
	TestID -> "The package exports exactly the expected public symbols"
]

VerificationTest[
	$loadMessages
	,
	{}
	,
	TestID -> "Loading the package issues no messages"
]

VerificationTest[
	$directoryAfterLoading
	,
	$directoryBeforeLoading
	,
	TestID -> "Loading the package does not change the working directory"
]

VerificationTest[
	FileNameSplit[FindFile["OsculatingOrbitalElements`"]][[-2 ;;]]
	,
	{"Kernel", "init.wl"}
	,
	TestID -> "The package loads through Kernel/init.wl"
]
