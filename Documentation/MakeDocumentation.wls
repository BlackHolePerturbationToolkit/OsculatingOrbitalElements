#!/usr/bin/env wolframscript
(* ::Package:: *)

(* Generates the documentation notebooks in Documentation/English: a reference page for every public symbol, the guide
   page and the tutorial, in the source format of Wolfram's Documentation Tools (as KerrGeodesics uses). The examples are
   evaluated in a front end with this copy of the package, so the pages include their outputs.
     wolframscript -file Documentation/MakeDocumentation.wls
   It overwrites the notebooks, so edit this file rather than the notebooks, or stop using it once the notebooks are
   edited by hand. *)

$docDirectory = DirectoryName[ExpandFileName[First[$ScriptCommandLine]]];
$repoDirectory = ParentDirectory[$docDirectory];
PrependTo[$Path, ParentDirectory[$repoDirectory]];
Needs["OsculatingOrbitalElements`"];
If[!StringStartsQ[FindFile["OsculatingOrbitalElements`"], $repoDirectory], Print["Loaded the wrong copy of the package"]; Exit[1]];

$paclet = "OsculatingOrbitalElements";
$english = FileNameJoin[{$docDirectory, "English"}];


(* ::Section:: *)
(* Cells *)

uri[kind_, name_] := "paclet:" <> $paclet <> "/" <> kind <> "/" <> name;
refLink[sym_String] := ButtonBox[sym, BaseStyle -> "Link", ButtonData -> uri["ref", sym]];
inlineRef[sym_String] := Cell[BoxData[refLink[sym]], "InlineFormula"];

(* Text with inline code: "plain `Symbol` plain" links Symbol to its page when it has one, otherwise sets it as code *)
$documented := $documentedSymbols;
richText[s_String] := TextData[Flatten[MapIndexed[
	If[EvenQ[First[#2]],
		If[MemberQ[$documented, #1], inlineRef[#1], Cell[BoxData[#1], "InlineFormula", FormatType -> StandardForm]],
		#1] &,
	StringSplit[s, "`", All]]]];

(* Code from a string, as the boxes a front end would show for it. "..." stands for more arguments, as in usage lines. *)
codeBoxes[code_String] := Module[{held = ToExpression[StringReplace[code, "..." -> "$ellipsis"], InputForm, HoldComplete]},
	If[held === $Failed, Print["Cannot parse: ", code]; Exit[1]];
	Replace[held, HoldComplete[e_] :> MakeBoxes[e, StandardForm]] /. "$ellipsis" -> "\[Ellipsis]"];
input[code_String] := Cell[BoxData[codeBoxes[code]], "Input"];

(* Usage lines: {{"Symbol[args]" as code, "what it does"}, ...} *)
usageCell[lines_List] := Cell[TextData[Riffle[
	Map[{Cell[BoxData[codeBoxes[#[[1]]] /. s_String /; MemberQ[$documented, s] :> refLink[s]], "InlineFormula"],
		"\[LineSeparator]", Sequence @@ List @@ richText[#[[2]]]} &, lines],
	"\n"] // Flatten], "Usage"];

notes[texts_List] := Cell[richText[#], "Notes"] & /@ texts;

(* A table in the notes: {{"key", "default", "description"}, ...}. The first two columns are code, and may be
   several expressions separated by commas. *)
sequenceBoxes[""] := "";
sequenceBoxes[code_String] := RowBox[Riffle[List @@ Replace[codeBoxes["{" <> code <> "}"], RowBox[{"{", inner_, "}"}] :>
	If[MatchQ[inner, RowBox[l_List] /; MemberQ[l, ","]], DeleteCases[First[inner], ","], {inner}]], ", "]];
noteTable[rows_List] := Cell[BoxData[GridBox[
	Map[{Cell["      ", "ModInfo"], Cell[BoxData[sequenceBoxes[#[[1]]]], "InlineFormula"],
		Cell[BoxData[sequenceBoxes[#[[2]]]], "InlineFormula"], Cell[richText[#[[3]]], "TableText"]} &, rows]]], "3ColumnTableMod"];

(* Examples: a list of {"text", "code"} pairs, and {"section", {...}} for a named section of extended examples *)
exampleCells[pairs_List] := Flatten[{Cell[richText[#[[1]]], "ExampleText"], input /@ Rest[#]} & /@ pairs];

seeAlso[syms_List] := {Cell["See Also", "SeeAlsoSection"],
	Cell[TextData[Riffle[Cell[BoxData[refLink[#]], "InlineSeeAlsoFunction"] & /@ syms, " \[FilledVerySmallSquare] "]], "SeeAlso"]};

metadata[kind_, name_, title_] := {
	Cell["Metadata", "MetadataSection"],
	Cell[TextData[{"New in: ", Cell["0.1", "HistoryData", CellTags -> "New"], " | Modified in: ",
		Cell[" ", "HistoryData", CellTags -> "Modified"], " | Obsolete in: ", Cell[" ", "HistoryData", CellTags -> "Obsolete"]}], "History"],
	Cell[CellGroupData[{Cell["Categorization", "CategorizationSection"],
		Cell[title, "Categorization", CellLabel -> "Entity Type"],
		Cell[$paclet, "Categorization", CellLabel -> "Paclet Name"],
		Cell[$paclet <> "`", "Categorization", CellLabel -> "Context"],
		Cell[$paclet <> "/" <> kind <> "/" <> name, "Categorization", CellLabel -> "URI"]}, Closed]],
	Cell[CellGroupData[{Cell["Keywords", "KeywordsSection"], Cell["osculating orbital elements", "Keywords"],
		Cell["inspiral", "Keywords"], Cell["Kerr", "Keywords"]}, Closed]]};

moreAbout = {Cell["Related Guides", "MoreAboutSection"],
	Cell[TextData[ButtonBox["Osculating Orbital Elements", BaseStyle -> "Link", ButtonData -> uri["guide", $paclet]]], "MoreAbout"]};
techNotes = {Cell["Tech Notes", "TechNotesSection"],
	Cell[TextData[ButtonBox["Osculating Orbital Elements", BaseStyle -> "Link", ButtonData -> uri["tutorial", $paclet]]], "Tutorials"]};


(* ::Section:: *)
(* Pages *)

(* page = <|"Name", "Usage" -> {{code, text}, ...}, "Notes" -> {cells}, "SeeAlso", "Examples" -> {{text, code...}, ...},
           "Extended" -> {{section, {{text, code...}, ...}}, ...}, "Legacy" -> True|False|> *)
referencePage[page_Association] := Notebook[Flatten[{
	Cell[page["Name"], "ObjectName"],
	usageCell[page["Usage"]],
	Lookup[page, "Notes", {}],
	techNotes,
	seeAlso[Lookup[page, "SeeAlso", {"OsculatingInspiral"}]],
	moreAbout,
	If[KeyExistsQ[page, "Examples"], {
		Cell[CellGroupData[{Cell["Examples Initialization", "ExamplesInitializationSection"],
			Cell[BoxData[RowBox[{"Needs", "[", "\"OsculatingOrbitalElements`\"", "]"}]], "ExampleInitialization"]}, Open]],
		Cell[CellGroupData[Flatten[{Cell["Basic Examples", "PrimaryExamplesSection"], exampleCells[page["Examples"]]}], Open]]},
		{}],
	If[KeyExistsQ[page, "Extended"], {
		Cell[CellGroupData[Flatten[{Cell["More Examples", "ExtendedExamplesSection"],
			Cell[CellGroupData[Flatten[{Cell[#[[1]], "ExampleSection"], exampleCells[#[[2]]]}], Open]] & /@ page["Extended"]}], Open]]},
		{}],
	metadata["ref", page["Name"], "Symbol"]}],
	TaggingRules -> <|"Paclet" -> $paclet|>, CellContext -> "Global`",
	StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8"]];

inspiralParams = "<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 8, \"e\" -> 0.3, \"x\" -> 0.6, \"Force\" -> ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-4]|>";

pages = {
<|"Name" -> "OsculatingInspiral",
	"Usage" -> {{"OsculatingInspiral[params]", "integrates the osculating geodesic equations for an inspiral in Kerr spacetime, driven by the forces and fluxes in `params`, and returns an `OsculatingInspiralFunction`."}},
	"Notes" -> Flatten[{
		notes[{"The parameters `params` are an Association with these keys:"}],
		noteTable[{
			{"\"a\"", "", "the spin of the black hole, 0 \[LessEqual] a < 1; a = 0 is Schwarzschild"},
			{"\"\\[Epsilon]\"", "", "the small mass ratio, which multiplies the forces and fluxes that scale with it"},
			{"\"p\"", "", "the initial semi-latus rectum"},
			{"\"e\"", "", "the initial eccentricity, 0 \[LessEqual] e < 1"},
			{"\"x\"", "", "the initial inclination x = cos \[Iota], with x \[NotEqual] 0; x = \[PlusMinus]1 is an equatorial orbit"},
			{"\"Force\"", "None", "a `ForceModel`, the name of a built-in force, a list of these, or None"},
			{"\"Flux\"", "None", "a `FluxModel`, the name of a built-in flux, a list of these, or None"},
			{"\"\\[Psi]r\"", "0", "the initial Darwin (radial) phase"},
			{"\"\\[Psi]\\[Theta]\"", "0", "the initial Hughes (polar) phase"},
			{"\"\\[Phi]\"", "0", "the initial azimuth"}}],
		notes[{
			"At least one of \"Force\" and \"Flux\" must be given. With neither force nor flux the orbit is a geodesic.",
			"Forces enter through the osculating geodesic equations. A flux changes only the slowly varying elements p, e and x, at its orbit-averaged rate with respect to coordinate time, and the phases advance at their geodesic rates. Forces and fluxes can be combined, and several of each add.",
			"The equations integrate p, the eccentricity components e sin \[Psi]r and e cos \[Psi]r, which are regular for circular orbits, x, the polar phase \[Psi]\[Theta], and \[Phi]. An inspiral can pass through x = 0 from prograde to retrograde. Orbits that start exactly polar, x = 0, are not supported.",
			"Equatorial orbits, x = \[PlusMinus]1, are a special case: x stays \[PlusMinus]1 and \[Theta] = \[Pi]/2, so the force must have no \[Theta] component in the equatorial plane, and a flux must not change x. Close to the equator, a force with a \[Theta] component makes the equations stiff.",
			"The integration stops at p = p_sep + \[Epsilon] outside the separatrix, at `pMin`, or at `IntegrationLimit`. The result's \"StopReason\" says which; only an early stop by NDSolve gives a message.",
			"The following options can be given:"}],
		noteTable[{
			{"Parametrisation", "\"CoordinateTime\"", "the time variable: coordinate time t, or \"Mino\" for Mino time \[Lambda]"},
			{"IntegrationLimit", "Automatic", "the largest value of the time variable: Automatic is 10^7 in coordinate time and 10^4 in Mino time"},
			{"SeparatrixBuffer", "Automatic", "how far outside the separatrix, in p, to stop: Automatic is \[Epsilon]"},
			{"pMin", "None", "a value of p at which to stop"},
			{"TimeMonitor", "False", "whether to show the progress of the integration in a notebook"},
			{"AccuracyGoal", "12", "passed to NDSolve"},
			{"PrecisionGoal", "12", "passed to NDSolve"}}],
		notes[{"Any option of NDSolve can also be given, and is passed to NDSolve. By default NDSolve uses an 8th-order explicit Runge-Kutta method, which resolves the rapid swings of \[Phi] as a near-polar orbit passes close to the poles; looser goals, or another Method, may not.",
			"Values between the integration steps are interpolated, by default to lower order than the integration. InterpolationOrder -> All makes them as accurate as the integration, at about ten times the memory."}]}],
	"SeeAlso" -> {"OsculatingInspiralFunction", "ForceModel", "FluxModel", "IntegrationLimit", "SeparatrixBuffer"},
	"Examples" -> {
		{"An inspiral driven by gas drag, around a black hole with spin a = 0.9:", "inspiral = OsculatingInspiral[" <> inspiralParams <> "]"},
		{"Why and when the integration stopped:", "{inspiral[\"StopReason\"], inspiral[\"Domain\"]}"},
		{"The semi-latus rectum, eccentricity and inclination relative to their initial values. Gas drag shrinks the orbit and, close to the separatrix, makes it more eccentric:",
			"Plot[{inspiral[\"p\"][t]/8, inspiral[\"e\"][t]/0.3, inspiral[\"x\"][t]/0.6}, {t, 0, inspiral[\"Domain\"][[2]]}, PlotLegends -> {\"p/p0\", \"e/e0\", \"x/x0\"}, AxesLabel -> {\"t\", None}]"},
		{"The trajectory in Boyer-Lindquist coordinates, as Cartesian-like coordinates:",
			"ParametricPlot3D[With[{r = inspiral[\"r\"][t], \\[Theta] = inspiral[\"\\[Theta]\"][t], \\[Phi] = inspiral[\"\\[Phi]\"][t]}, {r Sin[\\[Theta]] Cos[\\[Phi]], r Sin[\\[Theta]] Sin[\\[Phi]], r Cos[\\[Theta]]}], {t, 0, inspiral[\"Domain\"][[2]]}, PlotPoints -> 3000, MaxRecursion -> 0, BoxRatios -> Automatic]"}},
	"Extended" -> {
		{"Scope", {
			{"Drive an inspiral with a flux, here the leading-order gravitational-wave flux:",
				"peters = OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> \"Peters\"|>]",
				"Plot[peters[\"e\"][t], {t, 0, peters[\"Domain\"][[2]]}, AxesLabel -> {\"t\", \"e\"}]"},
			{"Combine forces and fluxes:",
				"OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> \"Peters\", \"Force\" -> ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-4]|>][\"Domain\"]"},
			{"Schwarzschild is a = 0. Here the first-order self-force fit for Schwarzschild drives an equatorial inspiral:",
				"gsf = OsculatingInspiral[<|\"a\" -> 0, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 10, \"e\" -> 0.1, \"x\" -> 1, \"Force\" -> \"FastGSF\"|>, IntegrationLimit -> 3000];",
				"Plot[gsf[\"p\"][t], {t, 0, 3000}, AxesLabel -> {\"t\", \"p\"}]"},
			{"Integrate in Mino time instead of coordinate time. Then the coordinate time is a property:",
				"mino = OsculatingInspiral[" <> inspiralParams <> ", Parametrisation -> \"Mino\", IntegrationLimit -> 10];",
				"{mino[\"Domain\"], mino[\"t\"][10]}"}}},
		{"Options", {
			{"Stop further from the separatrix with `SeparatrixBuffer`:",
				"With[{s = OsculatingInspiral[" <> inspiralParams <> ", SeparatrixBuffer -> 0.5]}, {s[\"StopReason\"], s[\"p\"][s[\"Domain\"][[2]]]}]"},
			{"Stop at a given p with `pMin`:",
				"With[{s = OsculatingInspiral[" <> inspiralParams <> ", pMin -> 7.5]}, {s[\"StopReason\"], s[\"p\"][s[\"Domain\"][[2]]]}]"},
			{"Options of NDSolve are passed to NDSolve:",
				"OsculatingInspiral[" <> inspiralParams <> ", MaxSteps -> 50][\"StopReason\"]"}}},
		{"Properties & Relations", {
			{"With no force or flux the orbit is a geodesic, and its constants of motion are those of KerrGeodesics:",
				"geodesic = OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 8, \"e\" -> 0.3, \"x\" -> 0.6, \"Force\" -> None|>, IntegrationLimit -> 1000];",
				"{geodesic[\"En\"][500], geodesic[\"L\"][500], geodesic[\"Q\"][500]} - Values[KerrGeoConstantsOfMotion[0.9, 8, 0.3, 0.6]]"}}},
		{"Possible Issues", {
			{"Orbits that start exactly polar are not supported:",
				"OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 8, \"e\" -> 0.3, \"x\" -> 0, \"Force\" -> None|>]"},
			{"An equatorial orbit stays in the plane, so a force with a \[Theta] component there is rejected:",
				"OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-4, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 1, \"Force\" -> ForceModel[Function[{a, p, e, x, \\[Psi]r, \\[Psi]\\[Theta], \\[Phi], t}, {0, 1, 0}]]|>]"},
			{"The initial orbit must lie outside the separatrix:",
				"OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 3, \"e\" -> 0.3, \"x\" -> 0.6, \"Force\" -> None|>]"},
			{"Fluxes are averages with respect to coordinate time, so they cannot be used in Mino time:",
				"OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> \"Peters\"|>, Parametrisation -> \"Mino\"]"}}}}|>,

<|"Name" -> "OsculatingInspiralFunction",
	"Usage" -> {
		{"OsculatingInspiralFunction[assoc]", "represents an inspiral computed by `OsculatingInspiral`."},
		{"inspiral[t]", "gives {t, r, \[Theta], \[Phi]} at time t."},
		{"inspiral[\"prop\"]", "gives the property \"prop\" of the inspiral."}},
	"Notes" -> Flatten[{
		notes[{"The time is coordinate time, or Mino time if the inspiral was computed with Parametrisation -> \"Mino\". Quantities that change along the inspiral are functions of it, for example inspiral[\"p\"][t], and they are listable.", "The properties include:"}],
		noteTable[{
			{"\"t\", \"r\", \"\\[Theta]\", \"\\[Phi]\"", "", "the Boyer-Lindquist coordinates; \"Trajectory\" gives the four functions"},
			{"\"p\", \"e\", \"x\"", "", "the osculating semi-latus rectum, eccentricity and inclination"},
			{"\"\\[Psi]r\", \"\\[Psi]\\[Theta]\"", "", "the Darwin and Hughes phases, in (-\[Pi], \[Pi]]; Missing where undefined (\[Psi]r at e = 0, \[Psi]\[Theta] on an equatorial orbit)"},
			{"\"En\", \"L\", \"Q\", \"K\"", "", "the osculating constants of motion"},
			{"\"\\[Alpha]p\", \"\\[Beta]p\"", "", "the eccentricity components integrated, e sin \[Psi]r and e cos \[Psi]r"},
			{"\"\\[CapitalOmega]r\", \"\\[CapitalOmega]\\[Theta]\", \"\\[CapitalOmega]\\[Phi]\"", "", "the Boyer-Lindquist frequencies of the osculating geodesic, from `KerrGeoFrequencies`"},
			{"\"\\[CapitalPhi]r\", \"\\[CapitalPhi]\\[Theta]\", \"\\[CapitalPhi]\\[Phi]\"", "", "the Boyer-Lindquist action angles of the osculating geodesic, accumulated over the inspiral; Missing where undefined (\[CapitalPhi]r at e = 0, \[CapitalPhi]\[Theta] on an equatorial orbit)"},
			{"\"Domain\"", "", "{0, end}, the range of the time variable"},
			{"\"StopReason\"", "", "\"SeparatrixBuffer\", \"pMin\", \"IntegrationLimit\", or \"Other\" if NDSolve stopped early"},
			{"\"Parameters\", \"Force\", \"Flux\", \"Parametrisation\"", "", "the parameters, the forces and fluxes as models, and the time variable"}}],
		notes[{"The Boyer-Lindquist action angles advance at the constant rates \[CapitalOmega]r, \[CapitalOmega]\[Theta] and \[CapitalOmega]\[Phi] in t along a geodesic. They are computed from the osculating elements and phases as in P. Lynch and O. Burke, Class. Quantum Grav. 42, 167001 (2025), arXiv:2411.04955, and are 0 where \[Psi]r, \[Psi]\[Theta] and \[Phi] are.",
			"inspiral[\"Properties\"] lists all the properties."}]}],
	"SeeAlso" -> {"OsculatingInspiral", "ForceModel", "FluxModel"},
	"Examples" -> {
		{"Compute an inspiral:", "inspiral = OsculatingInspiral[" <> inspiralParams <> ", IntegrationLimit -> 2000]"},
		{"The position {t, r, \[Theta], \[Phi]} at t = 1000:", "inspiral[1000]"},
		{"The orbital elements at several times:", "inspiral[\"p\"][{0, 1000, 2000}]"},
		{"The Boyer-Lindquist frequencies of the osculating geodesic, and its action angles, which accumulate over the inspiral:",
			"Plot[Evaluate[inspiral[#][t] & /@ {\"\\[CapitalOmega]r\", \"\\[CapitalOmega]\\[Theta]\", \"\\[CapitalOmega]\\[Phi]\"}], {t, 0, 2000}, PlotLegends -> {\"\\[CapitalOmega]r\", \"\\[CapitalOmega]\\[Theta]\", \"\\[CapitalOmega]\\[Phi]\"}, AxesLabel -> {\"t\", None}]",
			"inspiral[#][2000] & /@ {\"\\[CapitalPhi]r\", \"\\[CapitalPhi]\\[Theta]\", \"\\[CapitalPhi]\\[Phi]\"}"},
		{"All the properties:", "inspiral[\"Properties\"]"}}|>,

<|"Name" -> "ForceModel",
	"Usage" -> {
		{"ForceModel[f]", "is a force for `OsculatingInspiral`, where f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t] gives the covariant components {F_r, F_\[Theta], F_\[Phi]}."},
		{"ForceModel[\"name\", param -> value, ...]", "is a built-in force model."},
		{"ForceModel[model, param -> value, ...]", "changes the parameters of a model."},
		{"model[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t]", "gives the covariant force {F_t, F_r, F_\[Theta], F_\[Phi]}."}},
	"Notes" -> Flatten[{
		notes[{
			"f gets the elements and phases of the osculating geodesic, the azimuth \[Phi] and the coordinate time t, and is only called with numbers. \[Phi] and t let a force break axial symmetry or depend on time, for example the tidal field of a third body; most forces ignore them.",
			"Where a phase is undefined, it is passed as 0: \[Psi]r at e = 0, and \[Psi]\[Theta] on an equatorial orbit. A physical force does not depend on it there.",
			"On an equatorial orbit, x = \[PlusMinus]1, `OsculatingInspiral` keeps the orbit in the plane, so the force must have no \[Theta] component there.",
			"F_t follows from orthogonality to the velocity, u^\[Mu] F_\[Mu] = 0.",
			"If the model has parameters, f also gets them, as an Association: f[a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t, params].",
			"The force is multiplied by the mass ratio \[Epsilon] of the inspiral unless \"ScalesWithMassRatio\" is False.",
			"The following options can be given:"}],
		noteTable[{
			{"\"Name\"", "\"Custom\"", "the model's name"},
			{"\"Parameters\"", "<||>", "the parameter values; Missing[\"Required\"] marks one that must be set"},
			{"\"ScalesWithMassRatio\"", "True", "whether the force is multiplied by \[Epsilon]"},
			{"\"ValidityCondition\"", "(True &)", "a function of (a, p, e, x) that is True where the model is valid; outside, a warning is given"},
			{"\"ValidityDescription\"", "None", "the range of validity in words"},
			{"\"Description\"", "None", "a description"},
			{"\"Citation\"", "None", "the reference for the model"}}],
		notes[{"The built-in models are:"}],
		noteTable[{
			{"\"GasDrag\"", "\"Coefficient\" -> k", "relativistic gas drag, -k (u_\[Mu] + \[Delta]^t_\[Mu]/u^t); does not scale with \[Epsilon]"},
			{"\"EMConservative\"", "", "a conservative electromagnetic force"},
			{"\"FastGSF\"", "", "a fit to the first-order gravitational self-force in Schwarzschild, valid for a = 0, p \[LessEqual] 12 and e \[LessEqual] 0.2"}}],
		notes[{"model[\"prop\"] gives a property, and model[\"Properties\"] lists them."}]}],
	"SeeAlso" -> {"OsculatingInspiral", "FluxModel"},
	"Examples" -> {
		{"Gas drag of strength 10^-3:", "drag = ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-3]"},
		{"The covariant force {F_t, F_r, F_\[Theta], F_\[Phi]} at a point of an orbit:", "drag[0.9, 8, 0.3, 0.6, 0.5, 1., 0, 0]"},
		{"Use it in an inspiral:", "OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 8, \"e\" -> 0.3, \"x\" -> 0.6, \"Force\" -> drag|>]"}},
	"Extended" -> {
		{"Scope", {
			{"A custom force: a torque, which reduces the angular momentum, and so x:",
				"torque = ForceModel[Function[{a, p, e, x, \\[Psi]r, \\[Psi]\\[Theta], \\[Phi], t}, {0, 0, -1}], \"Name\" -> \"Torque\"];",
				"tilted = OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-4, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 0.8, \"Force\" -> torque|>, IntegrationLimit -> 3000];",
				"Plot[tilted[\"x\"][t], {t, 0, 3000}, AxesLabel -> {\"t\", \"x\"}]"},
			{"A force with a parameter, which f receives as its last argument:",
				"weak = ForceModel[Function[{a, p, e, x, \\[Psi]r, \\[Psi]\\[Theta], \\[Phi], t, par}, par[\"k\"] {0, 0, -1}], \"Parameters\" -> <|\"k\" -> 1|>, \"Name\" -> \"Torque\"];",
				"ForceModel[weak, \"k\" -> 2][0.9, 8, 0.3, 0.6, 0.5, 1., 0, 0]"},
			{"A force that is not axisymmetric depends on \[Phi]. This one is a uniform field in the equatorial plane, the gradient of r sin \[Theta] cos \[Phi]:",
				"field = ForceModel[Function[{a, p, e, x, \\[Psi]r, \\[Psi]\\[Theta], \\[Phi], t}, With[{r = p/(1 + e Cos[\\[Psi]r]), c = Sqrt[1 - x^2] Cos[\\[Psi]\\[Theta]]}, {Sqrt[1 - c^2] Cos[\\[Phi]], r c Cos[\\[Phi]], -r Sqrt[1 - c^2] Sin[\\[Phi]]}]], \"Name\" -> \"Uniform field\"];",
				"OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-5, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 0.8, \"Force\" -> field|>, IntegrationLimit -> 2000][\"x\"][2000]"},
			{"Several forces add:",
				"OsculatingInspiral[<|\"a\" -> 0, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 10, \"e\" -> 0.1, \"x\" -> 1, \"Force\" -> {\"FastGSF\", drag}|>][\"Force\"]"}}},
		{"Properties & Relations", {
			{"The properties of a model:", "ForceModel[\"FastGSF\"][\"Properties\"]", "ForceModel[\"FastGSF\"][\"ValidityDescription\"]"}}},
		{"Possible Issues", {
			{"Gas drag has no default strength:", "OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 8, \"e\" -> 0.3, \"x\" -> 0.6, \"Force\" -> \"GasDrag\"|>]"},
			{"FastGSF is only valid for Schwarzschild, so using it in Kerr gives a warning:", "OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 10, \"e\" -> 0.1, \"x\" -> 1, \"Force\" -> \"FastGSF\"|>, IntegrationLimit -> 100][\"StopReason\"]"}}}}|>,

<|"Name" -> "FluxModel",
	"Usage" -> {
		{"FluxModel[f]", "is a flux for `OsculatingInspiral`: f[a, p, e, x] gives the orbit-averaged rates {dp/dt, de/dt, dx/dt} with respect to coordinate time."},
		{"FluxModel[\"name\", param -> value, ...]", "is a built-in flux model."},
		{"FluxModel[force]", "is the orbit average of the `ForceModel` force."},
		{"FluxModel[model, param -> value, ...]", "changes the parameters of a model."},
		{"model[a, p, e, x]", "gives the rates."}},
	"Notes" -> Flatten[{
		notes[{
			"A flux changes only the slowly varying elements p, e and x; the phases advance at their geodesic rates, plus the effect of any force. Forces and fluxes can be combined.",
			"With the option \"Rates\" -> {\"En\", \"L\", \"Q\"}, f gives the rates of the energy, angular momentum and Carter constant instead, and they are converted to those of p, e and x.",
			"A physical flux has de/dt \[Proportional] e near e = 0, and dx/dt \[Proportional] 1 - x^2 near x = \[PlusMinus]1. A flux keeps a circular orbit circular. On an equatorial orbit, x = \[PlusMinus]1, `OsculatingInspiral` keeps the orbit in the plane, so the flux must not change x there.",
			"Fluxes are averages with respect to coordinate time, so an inspiral with a flux must use coordinate time.",
			"FluxModel[force] averages the force's rates of change of En, L and Q over the radial and polar motion of the geodesic, with respect to t. The force must depend on neither \[Phi] nor t. The parameter \"Points\" (16 by default) sets the number of points in each phase; the average converges quickly, but it is slow to evaluate.",
			"The options are those of `ForceModel`, and \"Rates\". The flux is multiplied by the mass ratio \[Epsilon] unless \"ScalesWithMassRatio\" is False.",
			"The built-in model \"Peters\" gives the leading-order gravitational-wave rates of p and e (Peters 1964). It is Newtonian: it does not depend on the spin, and leaves x unchanged."}]}],
	"SeeAlso" -> {"OsculatingInspiral", "ForceModel"},
	"Examples" -> {
		{"Peters' leading-order rates of p, e and x at a point:", "FluxModel[\"Peters\"][0.9, 12, 0.3, 0.7]"},
		{"An inspiral driven by them:", "peters = OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> \"Peters\"|>]",
			"Plot[{peters[\"p\"][t]/12, peters[\"e\"][t]/0.3}, {t, 0, peters[\"Domain\"][[2]]}, PlotLegends -> {\"p/p0\", \"e/e0\"}, AxesLabel -> {\"t\", None}]"}},
	"Extended" -> {
		{"Scope", {
			{"A custom flux of p, e and x:",
				"custom = FluxModel[Function[{a, p, e, x}, {-10/p^3, -10 e/p^4, 0}], \"Name\" -> \"Simple\"];",
				"OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> custom|>][\"Domain\"]"},
			{"The orbit average of a force, here gas drag on an equatorial orbit:",
				"drag = ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-4];",
				"averaged = FluxModel[drag]",
				"{forced, fluxed} = OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-4, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 1, #|>, IntegrationLimit -> 1000] & /@ {\"Force\" -> drag, \"Flux\" -> averaged};",
				"Plot[{forced[\"e\"][t], fluxed[\"e\"][t]}, {t, 0, 1000}, PlotLegends -> {\"force\", \"averaged flux\"}, AxesLabel -> {\"t\", \"e\"}]"}}}}|>,

<|"Name" -> "IntegrationLimit",
	"Usage" -> {{"IntegrationLimit", "is an option of `OsculatingInspiral` which gives the largest value of the time variable to integrate to."}},
	"Notes" -> notes[{"The default, Automatic, is 10^7 in coordinate time and 10^4 in Mino time. The integration stops earlier at the separatrix buffer or at `pMin`.", "The earlier functions take it too."}],
	"SeeAlso" -> {"OsculatingInspiral", "Parametrisation", "SeparatrixBuffer", "pMin"},
	"Examples" -> {{"Integrate to t = 1000:", "With[{s = OsculatingInspiral[" <> inspiralParams <> ", IntegrationLimit -> 1000]}, {s[\"StopReason\"], s[\"Domain\"]}]"}}|>,

<|"Name" -> "Parametrisation",
	"Usage" -> {{"Parametrisation", "is an option of `OsculatingInspiral` which gives the time variable: \"CoordinateTime\", the default, or \"Mino\"."}},
	"Notes" -> notes[{"In Mino time the coordinate time is a property of the inspiral, inspiral[\"t\"].", "An inspiral with a flux must use coordinate time."}],
	"SeeAlso" -> {"OsculatingInspiral", "IntegrationLimit"},
	"Examples" -> {{"Integrate to Mino time 5:", "mino = OsculatingInspiral[" <> inspiralParams <> ", Parametrisation -> \"Mino\", IntegrationLimit -> 5];", "{mino[\"Parametrisation\"], mino[\"t\"][5]}"}}|>,

<|"Name" -> "SeparatrixBuffer",
	"Usage" -> {{"SeparatrixBuffer", "is an option of `OsculatingInspiral` which gives how far outside the separatrix, in p, the integration stops."}},
	"Notes" -> notes[{"The default, Automatic, is the mass ratio \[Epsilon].", "The initial orbit must lie further than this outside the separatrix."}],
	"SeeAlso" -> {"OsculatingInspiral", "pMin", "IntegrationLimit"},
	"Examples" -> {{"Stop 0.5 outside the separatrix:", "s = OsculatingInspiral[" <> inspiralParams <> ", SeparatrixBuffer -> 0.5];",
		"With[{end = s[\"Domain\"][[2]]}, s[\"p\"][end] - KerrGeoSeparatrix[0.9, s[\"e\"][end], s[\"x\"][end]]]"}}|>,

<|"Name" -> "pMin",
	"Usage" -> {{"pMin", "is an option of `OsculatingInspiral` which stops the integration when p falls to the given value."}},
	"Notes" -> notes[{"The default, None, does not stop at any p."}],
	"SeeAlso" -> {"OsculatingInspiral", "SeparatrixBuffer", "IntegrationLimit"},
	"Examples" -> {{"Stop at p = 7.5:", "With[{s = OsculatingInspiral[" <> inspiralParams <> ", pMin -> 7.5]}, {s[\"StopReason\"], s[\"p\"][s[\"Domain\"][[2]]]}]"}}|>,

<|"Name" -> "TimeMonitor",
	"Usage" -> {{"TimeMonitor", "is an option of `OsculatingInspiral` which shows the progress of the integration."}},
	"Notes" -> notes[{"The progress is only shown in a notebook. The default is False."}],
	"SeeAlso" -> {"OsculatingInspiral"}|>
};

(* The earlier functions: short pages that point to what replaces them *)
legacyPages = {
	{"SchwarzOsculatingOrbitalElements", "SchwarzOsculatingOrbitalElements[\[Eta], p, e, \[Xi]]", "OsculatingInspiral"},
	{"SchwarzOsculatingOrbitalElementsTP", "SchwarzOsculatingOrbitalElementsTP[\[Eta], p, e, \[Xi]]", "OsculatingInspiral"},
	{"KerrOsculatingOrbitalElements", "KerrOsculatingOrbitalElements[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta]]", "OsculatingInspiral"},
	{"GenericKerrpexBL", "GenericKerrpexBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta]]", "OsculatingInspiral"},
	{"GenericKerrREGBL", "GenericKerrREGBL[\[Eta], a, p, e, x, \[Psi]r, \[Psi]\[Theta]]", "OsculatingInspiral"},
	{"Force", "Force", "OsculatingInspiral"},
	{"ForceUpDown", "ForceUpDown", "OsculatingInspiral"},
	{"SchwarzGasDrag", "SchwarzGasDrag[p, e, \[Xi]]", "ForceModel"},
	{"KerrGasDrag", "KerrGasDrag[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]", "ForceModel"},
	{"KerrGasDragVec", "KerrGasDragVec[a, En, L, K, \[Psi]r, \[Psi]\[Theta]]", "ForceModel"},
	{"KerrEMCons", "KerrEMCons[a, p, e, x, \[Psi]r, \[Psi]\[Theta]]", "ForceModel"},
	{"SchwarzFastGSF", "SchwarzFastGSF[p, e, \[Xi]]", "ForceModel"}};

legacyPage[{name_, template_, replacement_}] := Notebook[Flatten[{
	Cell[name, "ObjectName"],
	Cell[TextData[{Cell[BoxData[template /. name -> ToString[name]], "InlineFormula"], "\[LineSeparator]",
		StringReplace[ToExpression[name <> "::usage"], StartOfString ~~ "Legacy, superseded by " ~~ Shortest[__] ~~ ". " -> ""]}], "Usage"],
	Cell[TextData[{"Legacy: this is one of the earlier functions of the package. It keeps working, but ", inlineRef[replacement],
		" supersedes it."}], "Notes"],
	techNotes, seeAlso[{replacement}], moreAbout,
	metadata["ref", name, "Symbol"]}],
	TaggingRules -> <|"Paclet" -> $paclet|>, CellContext -> "Global`",
	StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "FunctionPageStylesExt.nb", CharacterEncoding -> "UTF-8"]];

$documentedSymbols = Join[#["Name"] & /@ pages, First /@ legacyPages];


(* ::Section:: *)
(* Guide page *)

guideFunction[sym_, text_] := Cell[TextData[{Cell[BoxData[refLink[sym]], "InlineGuideFunction"], " \[LongDash] ", Sequence @@ List @@ richText[text]}], "GuideText"];
guidePage = Notebook[Flatten[{
	Cell["Osculating Orbital Elements", "GuideTitle"],
	Cell["The OsculatingOrbitalElements package computes inspirals in Kerr spacetime with the method of osculating geodesics. An inspiral is driven by forces, which act through the osculating geodesic equations, by fluxes, which are orbit-averaged rates of change of the orbital elements, or by both. Its equations are regular for circular orbits and as an orbit passes from prograde to retrograde, and equatorial orbits are a special case.", "GuideAbstract"],
	Cell[CellGroupData[Flatten[{Cell["", "GuideFunctionsSection"],
		guideFunction["OsculatingInspiral", "integrate an inspiral, from an Association of parameters"],
		guideFunction["OsculatingInspiralFunction", "the inspiral: its trajectory, orbital elements, phases and constants of motion"],
		Cell["\t", "GuideDelimiter"],
		guideFunction["ForceModel", "a force: custom, or a built-in model (\"GasDrag\", \"EMConservative\", \"FastGSF\")"],
		guideFunction["FluxModel", "a flux: custom, a built-in model (\"Peters\"), or the orbit average of a force"],
		Cell["\t", "GuideDelimiter"],
		Cell[TextData[Riffle[Cell[BoxData[refLink[#]], "InlineGuideFunction"] & /@ {"Parametrisation", "IntegrationLimit", "SeparatrixBuffer", "pMin", "TimeMonitor"}, " \[FilledVerySmallSquare] "]], "InlineGuideFunctionListing"],
		Cell["Legacy functions", "GuideFunctionsSubsection"],
		Cell[TextData[Riffle[Cell[BoxData[refLink[#]], "InlineGuideFunction"] & /@ (First /@ legacyPages), " \[FilledVerySmallSquare] "]], "InlineGuideFunctionListing"]}], Open]],
	Cell["Tech Notes", "GuideTutorialsSection"],
	Cell[TextData[ButtonBox["Osculating Orbital Elements", BaseStyle -> "Link", ButtonData -> uri["tutorial", $paclet]]], "GuideTutorial"],
	Cell["Related Links", "GuideRelatedLinksSection"],
	Cell[TextData[ButtonBox["Black Hole Perturbation Toolkit", BaseStyle -> "Hyperlink", ButtonData -> {URL["https://bhptoolkit.org/"], None}]], "GuideRelatedLinks"],
	Cell[TextData[ButtonBox["KerrGeodesics", BaseStyle -> "Hyperlink", ButtonData -> {URL["https://bhptoolkit.org/KerrGeodesics/"], None}]], "GuideRelatedLinks"],
	metadata["guide", $paclet, "Guide"]}],
	TaggingRules -> <|"Paclet" -> $paclet|>,
	StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "GuidePageStylesExt.nb", CharacterEncoding -> "UTF-8"]];


(* ::Section:: *)
(* Tutorial *)

text[s_] := Cell[richText[s], "Text"];
tutorialPage = Notebook[Flatten[{
	Cell["Osculating Orbital Elements", "Title"],
	text["The method of osculating geodesics follows an orbit under a force as a sequence of geodesics: at each moment the orbit is the geodesic with the same position and velocity, and the force changes which geodesic that is. This package integrates those equations for bound orbits in Kerr spacetime, and also drives inspirals with fluxes, orbit-averaged rates of change of the orbital elements. It builds on the KerrGeodesics package."],
	input["Needs[\"OsculatingOrbitalElements`\"]"],
	Cell["An inspiral", "Subsection"],
	text["`OsculatingInspiral` takes an Association of parameters: the spin a, the small mass ratio \[Epsilon], the initial semi-latus rectum p, eccentricity e and inclination x = cos \[Iota], and a force, a flux or both. Here gas drag drives the inspiral until it reaches the separatrix:"],
	input["inspiral = OsculatingInspiral[" <> inspiralParams <> "]"],
	text["The result is an `OsculatingInspiralFunction`. It gives the position {t, r, \[Theta], \[Phi]} at a time, and its properties are functions of the time:"],
	input["inspiral[100]"],
	input["Plot[{inspiral[\"p\"][t], inspiral[\"r\"][t]}, {t, 0, inspiral[\"Domain\"][[2]]}, PlotLegends -> {\"p\", \"r\"}, AxesLabel -> {\"t\", None}]"],
	text["\"StopReason\" says why the integration stopped. By default it stops when p comes within \[Epsilon] of the separatrix:"],
	input["inspiral[\"StopReason\"]"],
	Cell["Forces", "Subsection"],
	text["A force is a `ForceModel`. The built-in models are \"GasDrag\", which needs a \"Coefficient\", \"EMConservative\" and \"FastGSF\", a fit to the first-order self-force in Schwarzschild. A custom force is a function of the elements, the phases, the azimuth and the coordinate time, (a, p, e, x, \[Psi]r, \[Psi]\[Theta], \[Phi], t), that returns the covariant components {F_r, F_\[Theta], F_\[Phi]}; F_t follows from orthogonality to the velocity. This one is a torque, which reduces the angular momentum, and so x:"],
	input["torque = ForceModel[Function[{a, p, e, x, \\[Psi]r, \\[Psi]\\[Theta], \\[Phi], t}, {0, 0, -1}], \"Name\" -> \"Torque\"];"],
	input["tilted = OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-4, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 0.8, \"Force\" -> torque|>, IntegrationLimit -> 3000];"],
	input["Plot[tilted[\"x\"][t], {t, 0, 3000}, AxesLabel -> {\"t\", \"x\"}]"],
	text["A force is multiplied by the mass ratio \[Epsilon] unless it says otherwise; gas drag does not scale with \[Epsilon], since its strength is its coefficient. Several forces add:"],
	input["both = OsculatingInspiral[<|\"a\" -> 0, \"\\[Epsilon]\" -> 10^-3, \"p\" -> 10, \"e\" -> 0.1, \"x\" -> 1, \"Force\" -> {\"FastGSF\", ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-4]}|>];"],
	input["{both[\"Domain\"], both[\"StopReason\"]}"],
	Cell["Fluxes", "Subsection"],
	text["A flux is a `FluxModel`: orbit-averaged rates of change of p, e and x, or of the energy, angular momentum and Carter constant, with respect to coordinate time. It changes only the slowly varying elements, and the phases keep their geodesic rates. \"Peters\" is the leading-order gravitational-wave flux:"],
	input["peters = OsculatingInspiral[<|\"a\" -> 0.9, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0.3, \"x\" -> 0.7, \"Flux\" -> \"Peters\"|>];"],
	input["ParametricPlot[{peters[\"p\"][t], peters[\"e\"][t]}, {t, 0, peters[\"Domain\"][[2]]}, AxesLabel -> {\"p\", \"e\"}, AspectRatio -> 1/2]"],
	text["The orbit average of a force is a flux. Driven by the force and by its averaged flux, an inspiral changes in the same way, apart from oscillations of size \[Epsilon]:"],
	input["drag = ForceModel[\"GasDrag\", \"Coefficient\" -> 10^-4];"],
	input["{forced, fluxed} = OsculatingInspiral[<|\"a\" -> 0.5, \"\\[Epsilon]\" -> 10^-4, \"p\" -> 10, \"e\" -> 0.2, \"x\" -> 1, #|>, IntegrationLimit -> 1000] & /@ {\"Force\" -> drag, \"Flux\" -> FluxModel[drag]};"],
	input["Plot[{forced[\"p\"][t], fluxed[\"p\"][t]}, {t, 0, 1000}, PlotLegends -> {\"force\", \"averaged flux\"}, AxesLabel -> {\"t\", \"p\"}]"],
	text["Forces and fluxes can drive an inspiral together, for example a gravitational-wave flux and gas drag."],
	Cell["Special orbits", "Subsection"],
	text["The radial equations are regular for circular orbits, and the equation for x is regular at x = 0, so an inspiral can pass from prograde to retrograde. Orbits that start exactly polar, x = 0, are not supported. Schwarzschild is a = 0."],
	text["Equatorial orbits, x = \[PlusMinus]1, are a special case: x stays \[PlusMinus]1 and \[Theta] = \[Pi]/2, so the force must have no \[Theta] component in the plane, and a flux must not change x. An orbit that starts circular stays circular under a flux. The Darwin phase is undefined on a circular orbit, and the Hughes phase on an equatorial one:"],
	input["circular = OsculatingInspiral[<|\"a\" -> 0, \"\\[Epsilon]\" -> 10^-2, \"p\" -> 12, \"e\" -> 0, \"x\" -> 1, \"Flux\" -> \"Peters\"|>, IntegrationLimit -> 1000];"],
	input["{circular[\"e\"][1000], circular[\"x\"][1000], circular[\"\\[Psi]r\"][1000], circular[\"\\[Psi]\\[Theta]\"][1000]}"],
	Cell["Frequencies and angles", "Subsection"],
	text["The inspiral also gives the Boyer-Lindquist frequencies of the osculating geodesic, \[CapitalOmega]r, \[CapitalOmega]\[Theta] and \[CapitalOmega]\[Phi], from KerrGeodesics, and its Boyer-Lindquist action angles \[CapitalPhi]r, \[CapitalPhi]\[Theta] and \[CapitalPhi]\[Phi] (Lynch and Burke 2025). Along a geodesic each angle advances at its frequency. Over an inspiral the angles accumulate, and differ from the integral of the frequencies by the force's effect on them, which is small until the orbit nears the separatrix. Here at t = 2000, before the plunge:"],
	input["Plot[Evaluate[inspiral[#][t] & /@ {\"\\[CapitalOmega]r\", \"\\[CapitalOmega]\\[Theta]\", \"\\[CapitalOmega]\\[Phi]\"}], {t, 0, inspiral[\"Domain\"][[2]]}, PlotLegends -> {\"\\[CapitalOmega]r\", \"\\[CapitalOmega]\\[Theta]\", \"\\[CapitalOmega]\\[Phi]\"}, AxesLabel -> {\"t\", None}]"],
	input["Table[{inspiral[\"\\[CapitalPhi]\" <> k][2000] - inspiral[\"\\[CapitalPhi]\" <> k][0], NIntegrate[inspiral[\"\\[CapitalOmega]\" <> k][t], {t, 0, 2000}]}, {k, {\"r\", \"\\[Theta]\", \"\\[Phi]\"}}]"],
	Cell["Options", "Subsection"],
	text["`IntegrationLimit`, `SeparatrixBuffer` and `pMin` control where the integration stops, `Parametrisation` -> \"Mino\" integrates in Mino time, and any option of NDSolve is passed to NDSolve."],
	Cell["The earlier functions", "Subsection"],
	text["The earlier functions of the package, such as `GenericKerrpexBL` and `SchwarzOsculatingOrbitalElements`, keep working but are legacy; `OsculatingInspiral`, `ForceModel` and `FluxModel` supersede them."],
	Cell["Related Guides", "TutorialMoreAboutSection"],
	Cell[TextData[ButtonBox["Osculating Orbital Elements", BaseStyle -> "Link", ButtonData -> uri["guide", $paclet]]], "TutorialMoreAbout"],
	metadata["tutorial", $paclet, "Tech Note"]}],
	TaggingRules -> <|"Paclet" -> $paclet|>, CellContext -> "Global`",
	StyleDefinitions -> FrontEnd`FileName[{"Wolfram"}, "TechNotePageStylesExt.nb", CharacterEncoding -> "UTF-8"]];


(* ::Section:: *)
(* Writing and evaluating *)

(* Evaluating the examples. NotebookEvaluate hangs in a front end started by wolframscript, so the kernel evaluates
   each input cell itself, in a context of its own for each notebook, and inserts the output and any messages after it.
   Outputs are typeset with the front end, as a notebook would show them.
   Message arguments are written on one line, as a notebook would show them, rather than as two-dimensional text.
   With the environment variable DOCVERBOSE set, it prints each input and how long it took. *)
$verbose = StringQ[Environment["DOCVERBOSE"]];
oneLine[x_String] := x;
oneLine[x_] := With[{text = ToString[Short[x], OutputForm]}, If[StringContainsQ[text, "\n"], ToString[x, InputForm], text]];
$exampleCount = 0;
evaluateCell[c:Cell[BoxData[b_], "Input" | "ExampleInitialization", ___]] := Module[{file, stream, result, messages, time},
	file = FileNameJoin[{$TemporaryDirectory, "docmessages" <> ToString[$ProcessID] <> ".txt"}];
	stream = OpenWrite[file, FormatType -> OutputForm, PageWidth -> Infinity];
	{time, result} = AbsoluteTiming[Block[{$Messages = {stream}, $MessagePrePrint = oneLine}, ToExpression[b, StandardForm]]];
	Close[stream];
	messages = Select[StringSplit[Import[file, "Text"], "\n\n" | "\n"], StringContainsQ[#, "::"] &];
	$exampleCount++;
	If[$verbose, Print["  ", ToString[NumberForm[time, {5, 1}]], " s: ", StringTake[StringReplace[ToString[ToExpression[b, StandardForm, HoldForm], InputForm], "\n" -> " "], UpTo[100]]]];
	Flatten[{c,
		Cell[StringTrim[#], "Message", "MSG"] & /@ messages,
		If[result === Null || MatchQ[c, Cell[_, "ExampleInitialization", ___]], {},
			Cell[BoxData[UsingFrontEnd[ToBoxes[result, StandardForm]]], "Output"]]}]];
evaluateCell[Cell[CellGroupData[cells_List, o___], opts___]] := Cell[CellGroupData[Flatten[evaluateCell /@ cells], o], opts];
evaluateCell[c_] := c;

$notebookCount = 0;
evaluateNotebook[Notebook[cells_List, opts___]] := Block[
	{$Context = "Examples" <> ToString[++$notebookCount] <> "`", $ContextPath = DeleteCases[$ContextPath, "Global`"]},
	Notebook[Flatten[evaluateCell /@ cells], opts]];

writeNotebook[nb_Notebook, path_String, evaluate_] := Module[{written, messages},
	Quiet[CreateDirectory[DirectoryName[path]], CreateDirectory::eexist];
	written = If[evaluate, evaluateNotebook[nb], nb];
	UsingFrontEnd[Export[path, written, "NB"]];
	messages = Count[written, Cell[_, "Message", ___], Infinity];
	Print[FileNameTake[path, -2], ": ", FileByteCount[path], " bytes", If[messages > 0, ", " <> ToString[messages] <> " message cells", ""]]];

symbolsDirectory = FileNameJoin[{$english, "ReferencePages", "Symbols"}];
Do[writeNotebook[referencePage[page], FileNameJoin[{symbolsDirectory, page["Name"] <> ".nb"}], KeyExistsQ[page, "Examples"]], {page, pages}];
Do[writeNotebook[legacyPage[page], FileNameJoin[{symbolsDirectory, First[page] <> ".nb"}], False], {page, legacyPages}];
writeNotebook[guidePage, FileNameJoin[{$english, "Guides", $paclet <> ".nb"}], False];
writeNotebook[tutorialPage, FileNameJoin[{$english, "Tutorials", $paclet <> ".nb"}], True];

(* Every public symbol has a page *)
missing = Complement[Names["OsculatingOrbitalElements`*"], FileBaseName /@ FileNames["*.nb", symbolsDirectory]];
If[missing =!= {}, Print["Public symbols without a page: ", missing]];
