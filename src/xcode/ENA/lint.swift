#!/usr/local/bin/swift-sh
import AnyLint // @Flinesoft ~> 0.8

try Lint.logSummaryAndExit(arguments: CommandLine.arguments) {
	// MARK: - Variables

	let swiftFiles: Regex = #"^ENA/Source/.*\.swift$"#
	let testFiles: Regex = #"^.*/__tests__/.*$"#

	// MARK: - Checks

	// MARK: ClosureParamsParantheses

	try Lint.checkFileContents(
		checkInfo: "ClosureParamsParantheses: Don't use parantheses around non-typed parameters in a closure.",
		regex: #"\{\s*\(((?!self)[^):]+)\)\s*in"#,
		matchingExamples: ["run { (a) in", "run { (a, b) in", "run { (a, b, c) in"],
		nonMatchingExamples: ["run { (a: Int) in", "run { (a: Int, b: Int) in", "run { (a, b) -> String in"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: #"{ $1 in"#,
		autoCorrectExamples: [
			["before": "run { (a) in", "after": "run { a in"],
			["before": "run { (a, b) in", "after": "run { a, b in"],
			["before": "run { (a, b, c) in", "after": "run { a, b, c in"]
		]
	)

	// MARK: EmptyMethodBody

	try Lint.checkFileContents(
		checkInfo: "EmptyMethodBody: Don't use whitespace or newlines for the body of empty methods.",
		regex: ["declaration": #"(init|func [^\(\s]+)\([^{}]*\)"#, "spacing": #"\s*"#, "body": #"\{\s+\}"#],
		matchingExamples: [
			"init() { }",
			"init() {\n\n}",
			"init(\n    x: Int,\n    y: Int\n) { }",
			"func foo2bar()  { }",
			"func foo2bar(x: Int, y: Int)  { }",
			"func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}"
		],
		nonMatchingExamples: ["init() { /* comment */ }", "init() {}", "func foo2bar() {}", "func foo2bar(x: Int, y: Int) {}"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$declaration {}",
		autoCorrectExamples: [
			["before": "init()  { }", "after": "init() {}"],
			["before": "init(x: Int, y: Int)  { }", "after": "init(x: Int, y: Int) {}"],
			["before": "init()\n{\n    \n}", "after": "init() {}"],
			["before": "init(\n    x: Int,\n    y: Int\n) {\n    \n}", "after": "init(\n    x: Int,\n    y: Int\n) {}"],
			["before": "func foo2bar()  { }", "after": "func foo2bar() {}"],
			["before": "func foo2bar(x: Int, y: Int)  { }", "after": "func foo2bar(x: Int, y: Int) {}"],
			["before": "func foo2bar()\n{\n    \n}", "after": "func foo2bar() {}"],
			["before": "func foo2bar(\n    x: Int,\n    y: Int\n) {\n    \n}", "after": "func foo2bar(\n    x: Int,\n    y: Int\n) {}"]
		]
	)

	// MARK: EmptyTodo

	try Lint.checkFileContents(
		checkInfo: "EmptyTodo: `// TODO:` comments should not be empty.",
		regex: #"// TODO: ?(\[[\d\-_a-z]+\])? *\n"#,
		matchingExamples: ["// TODO:\n", "// TODO: [2020-03-19]\n", "// TODO: [cg_2020-03-19]  \n"],
		nonMatchingExamples: ["// TODO: refactor", "// TODO: not yet implemented", "// TODO: [cg_2020-03-19] not yet implemented"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: IfAsGuard

	try Lint.checkFileContents(
		checkInfo: "IfAsGuard: Don't use an if statement to just return – use guard for such cases instead.",
		regex: #" +if [^\{\n]+\{\s*return\s*[^\}]*\}(?! *else)"#,
		matchingExamples: [" if x == 5 { return }", " if x == 5 {\n    return nil\n}", " if x == 5 { return 500 }", " if x == 5 { return do(x: 500, y: 200) }"],
		nonMatchingExamples: [" if x == 5 {\n    let y = 200\n    return y\n}", " if x == 5 { someMethod(x: 500, y: 200) }", " if x == 500 { return } else {"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: LateForceUnwrapping3

	try Lint.checkFileContents(
		checkInfo: "LateForceUnwrapping3: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
		regex: [
			"openingBrace": #"\("#,
			"callPart1": #"[^\s\?\.]+"#,
			"separator1": #"\?\."#,
			"callPart2": #"[^\s\?\.]+"#,
			"separator2": #"\?\."#,
			"callPart3": #"[^\s\?\.]+"#,
			"separator3": #"\?\."#,
			"callPart4": #"[^\s\?\.]+"#,
			"closingBraceUnwrap": #"\)!"#
		],
		matchingExamples: ["let x = (viewModel?.user?.profile?.imagePath)!\n"],
		nonMatchingExamples: ["call(x: (viewModel?.username)!)", "let x = viewModel!.user!.profile!.imagePath\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$callPart1!.$callPart2!.$callPart3!.$callPart4",
		autoCorrectExamples: [
			["before": "let x = (viewModel?.user?.profile?.imagePath)!\n", "after": "let x = viewModel!.user!.profile!.imagePath\n"]
		]
	)

	// MARK: LateForceUnwrapping2

	try Lint.checkFileContents(
		checkInfo: "LateForceUnwrapping2: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
		regex: [
			"openingBrace": #"\("#,
			"callPart1": #"[^\s\?\.]+"#,
			"separator1": #"\?\."#,
			"callPart2": #"[^\s\?\.]+"#,
			"separator2": #"\?\."#,
			"callPart3": #"[^\s\?\.]+"#,
			"closingBraceUnwrap": #"\)!"#
		],
		matchingExamples: ["call(x: (viewModel?.profile?.username)!)"],
		nonMatchingExamples: ["let x = (viewModel?.user?.profile?.imagePath)!\n", "let x = viewModel!.profile!.imagePath\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$callPart1!.$callPart2!.$callPart3",
		autoCorrectExamples: [
			["before": "let x = (viewModel?.profile?.imagePath)!\n", "after": "let x = viewModel!.profile!.imagePath\n"]
		]
	)

	// MARK: LateForceUnwrapping1

	try Lint.checkFileContents(
		checkInfo: "LateForceUnwrapping1: Don't use ? first to force unwrap later – directly unwrap within the parantheses.",
		regex: [
			"openingBrace": #"\("#,
			"callPart1": #"[^\s\?\.]+"#,
			"separator1": #"\?\."#,
			"callPart2": #"[^\s\?\.]+"#,
			"closingBraceUnwrap": #"\)!"#
		],
		matchingExamples: ["call(x: (viewModel?.username)!)"],
		nonMatchingExamples: ["call(x: (viewModel?.profile?.username)!)", "call(x: viewModel!.username)"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$callPart1!.$callPart2",
		autoCorrectExamples: [
			["before": "call(x: (viewModel?.username)!)", "after": "call(x: viewModel!.username)"]
		]
	)

	// MARK: MultilineIfStructure

	try Lint.checkFileContents(
		checkInfo: "MultilineIfStructure: Make sure multiline if conditions are all on their own lines, indented by four spaces.",
		regex: #"^( *)if\s*(.*,) *\n((?:.+, *\n)*) *(.*\S)\s*\{\s*"#,
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1if\n$1    $2\n$3$1    $4\n$1{\n$1    $5",
		autoCorrectExamples: [
			[
				"before": """
				    if let employee = UserDefaults.standard.currentEmployee(),
				        let employeeName = employeeName,
				        let employeeEmail = employeeEmail,
				        let recipientEmail = recipientEmail {
				            dataExporterHelper.exportData(
				""",
				"after": """
				    if
				        let employee = UserDefaults.standard.currentEmployee(),
				        let employeeName = employeeName,
				        let employeeEmail = employeeEmail,
				        let recipientEmail = recipientEmail
				    {
				        dataExporterHelper.exportData(
				"""
			],
			[
				"before": """
				    if let employee = UserDefaults.standard.currentEmployee(),
				        let recipientEmail = recipientEmail
				    {
				        dataExporterHelper.exportData(
				""",
				"after": """
				    if
				        let employee = UserDefaults.standard.currentEmployee(),
				        let recipientEmail = recipientEmail
				    {
				        dataExporterHelper.exportData(
				"""
			]
		]
	)

	// MARK: MultilineGuardEnd

	try Lint.checkFileContents(
		checkInfo: "MultilineGuardEnd: Always close a multiline guard via `else {` on a new line indented like the opening `guard`.",
		regex: #"guard\s*([^\n]*,\n)+([^\n]*\S *)else\s*\{"#,
		matchingExamples: [
			"""
			guard
			    let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty() else {
			    return
			}
			""",
			"""
			guard let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty() else {
			    return
			}
			"""
		],
		nonMatchingExamples: [
			"""
			guard
			    let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty()
			else {
			    return
			}
			""",
			"""
			guard let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty()
			else {
			    return
			}
			"""
		],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: MultilineGuardStart

	try Lint.checkFileContents(
		checkInfo: "MultilineGuardStart: Always start a multiline guard via `guard` then a line break and all expressions indented.",
		regex: #"guard([^\n]*,\s*\n)+[^\n]*\s*else\s*\{"#,
		matchingExamples: [
			"""
			guard let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty()
			else {
			    return
			}
			""",
			"""
			guard let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty() else {
			    return
			}
			"""
		],
		nonMatchingExamples: [
			"""
			guard
			    let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty()
			else {
			    return
			}
			""",
			"""
			guard
			    let collection = viewModel.myCollection(),
			    !collection.compactMap({ OtherType($0) }).isEmpty() else {
			    return
			}
			"""
		],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: NavigationControllerVariableNaming

	try Lint.checkFileContents(
		checkInfo: "NavigationControllerVariableNaming: Always name your navigation controller variables with the suffix `NavCtrl` or just `navCtrl`.",
		regex: #"(var|let) +(nc|navigationcontroller|navc|ncontroller|navcontroller)[ :][^\n=]*=\i"#,
		matchingExamples: ["let nc =", "var navigationController =", "let navc =", "let ncontroller =", "var nc: MyNavigationController =", "let navController: MyNavigationController<T> = "],
		nonMatchingExamples: ["let navCtrl =", "let navCtrl: MyViewController =", "var myNavCtrl: MyViewController<T> ="],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: NavigationControllerViewNaming

	try Lint.checkFileContents(
		checkInfo: "NavigationControllerViewNaming: Don't call your navigation controllers like view controllers, use the suffix `NavCtrl` or just `navCtrl`.",
		regex: #"(var|let) +\w*(?<![Nn]avCtrl) *: *\w+NavigationController\?? *="#,
		matchingExamples: ["let viewCtrl: UINavigationController? = activeViewController != nil ? self.activeViewController : self.portraitViewCtrl"],
		nonMatchingExamples: ["let myNavCtrl: UINavigationController? = activeViewController != nil ? self.activeViewController : self.portraitViewCtrl"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: NilCoalescingOperator

	try Lint.checkFileContents(
		checkInfo: "NilCoalescingOperator: Prefer nil coalescing operator over `variable != nil ? variable! : alternative`.",
		regex: #"(\w+)\s*!=\s*nil\s*\?\s*\1!\s*:\s*(.*)"#,
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1 ?? $2",
		autoCorrectExamples: [
			[
				"before": "    let message = errorMessage != nil ? errorMessage! : L10n.Global.Info.success\n",
				"after": "    let message = errorMessage ?? L10n.Global.Info.success\n"
			],
			[
				"before": "param: callFunction(errorMessage != nil ? errorMessage! : L10n.Global.Info.success),\n",
				"after": "param: callFunction(errorMessage ?? L10n.Global.Info.success),\n"
			]
		]
	)

	// MARK: SingleLineGuard

	try Lint.checkFileContents(
		checkInfo: "SingleLineGuard: Use a single line guard for simple checks.",
		regex: #"guard\s*([^\{]{2,80})\s+else\s*\{\s*\n\s*(return[^\n]{0,40}|continue|fatalError\([^\n;]+\))\s*\}"#,
		matchingExamples: ["guard x else {\n  return\n}", "guard x else {\n  return 2 * x.squared(x: {15})\n}", #"guard x else {\#n  fatalError("some message: \(x)")\#n}"#],
		nonMatchingExamples: ["guard x else { return }", "guard x else { return 2 * x.squared(x: {15}) }", #"guard x else { fatalError("some message: \(x)") }"#],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: #"guard $1 else { $2 }"#,
		autoCorrectExamples: [
			["before": "guard let x = y?.x(z: 5) else {\n  return\n}", "after": "guard let x = y?.x(z: 5) else { return }"],
			["before": "guard let x = y?.x(z: 5) else {\n  return 2 * x.squared(x: {15})\n}", "after": "guard let x = y?.x(z: 5) else { return 2 * x.squared(x: {15}) }"],
			["before": "guard let x = y?.x(z: 5)\nelse {\n  return\n}", "after": "guard let x = y?.x(z: 5) else { return }"]
		]
	)

	// MARK: SingletonDefaultPrivateInit

	try Lint.checkFileContents(
		checkInfo: "SingletonDefaultPrivateInit: Singletons with a `default` object (pseudo-singletons) should not declare init methods as private.",
		regex: #"class +(?<TYPE>\w+)(?:<[^\>]+>)? *\{.*static let `default`(?:: *\k<TYPE>)? *= *\k<TYPE>\(.*(?<=private) init\(\m"#,
		matchingExamples: ["class MySingleton {\n  static let `default` = MySingleton()\n\n  private init() {}\n"],
		nonMatchingExamples: ["class MySingleton {\n  static let `default` = MySingleton()\n\n  init() {}\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: SingletonSharedFinal

	try Lint.checkFileContents(
		checkInfo: "SingletonSharedFinal: Singletons with a single object (`shared`) should be marked as final.",
		regex: #"(?<!final )class +(?<TYPE>\w+)(?:<[^\>]+>)? *\{.*static let shared(?:: *\k<TYPE>)? *= *\k<TYPE>\(\m"#,
		matchingExamples: ["\nclass MySingleton {\n  static let shared = MySingleton()\n\n  private init() {}\n"],
		nonMatchingExamples: ["\nfinal class MySingleton {\n  static let shared = MySingleton()\n\n  private init() {}\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: SingletonSharedPrivateInit

	try Lint.checkFileContents(
		checkInfo: "SingletonSharedPrivateInit: Singletons with a single object (`shared`) should declare their init method(s) as private.",
		regex: #"class +(?<TYPE>\w+)(?:<[^\>]+>)? *\{.*static let shared(?:: *\k<TYPE>)? *= *\k<TYPE>\(.*(?<= |\t|public|internal) init\(\m"#,
		matchingExamples: ["\nfinal class MySingleton {\n  static let shared = MySingleton()\n\n  init() {}\n"],
		nonMatchingExamples: ["\nfinal class MySingleton {\n  static let shared = MySingleton()\n\n  private init() {}\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: SingletonSharedSingleObject

	try Lint.checkFileContents(
		checkInfo: "SingletonSharedSingleObject: Singletons with a `shared` object (real Singletons) should not have other static let properties. Use `default` instead (if needed).",
		regex: #"class +(?<TYPE>\w+)(?:<[^\>]+>)? *\{.*(?:static let shared(?:: *\k<TYPE>)? *= *\k<TYPE>\(.*static let \w+(?:: *\k<TYPE>)? *= *\k<TYPE>\(|static let \w+(?:: *\k<TYPE>)? *= *\k<TYPE>\(.*static let shared(?:: *\k<TYPE>)? *= *\k<TYPE>\()\m"#,
		matchingExamples: ["\nfinal class MySingleton {\n  static let shared = MySingleton(url: productionUrl)\n  static let test = MySingleton(url: testUrl)"],
		nonMatchingExamples: ["\nfinal class MySingleton {\n  static let shared = MySingleton()\n\n  private init() {}\n"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: SwitchAssociatedValueStyle

	try Lint.checkFileContents(
		checkInfo: "SwitchAssociatedValueStyle: Always put the `let` in front of case – even if only one associated value captured.",
		regex: #"case +[^\(][^\n]*(\(let |[^\)], let)"#,
		matchingExamples: ["case .addText(let text, let font, let textColor):", "case .addImage(let image)"],
		nonMatchingExamples: ["case let .addText(text, font, textColor):", "case let .addImage(image)"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: TernaryOperatorWhitespace

	try Lint.checkFileContents(
		checkInfo: "TernaryOperatorWhitespace: There should be a single whitespace around each separator.",
		regex: #"(.*\S)\s*\?\s*(\w+)\s*:\s*(.*)"#,
		nonMatchingExamples: ["viewCtrl?.call(param: 50)"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: #"$1 ? $2 : $3"#,
		autoCorrectExamples: [
			["before": "constant = singleUserMode() ? 0:28", "after": "constant = singleUserMode() ? 0 : 28"],
			["before": "constant = singleUserMode() ? 0 :28", "after": "constant = singleUserMode() ? 0 : 28"],
			["before": "constant = singleUserMode() ?0 : 28", "after": "constant = singleUserMode() ? 0 : 28"],
			["before": "constant = singleUserMode() ? 0: 28", "after": "constant = singleUserMode() ? 0 : 28"]
		]
	)

	// MARK: TodoUppercase

	try Lint.checkFileContents(
		checkInfo: "TodoUppercase: All TODOs should be all-uppercased like this: `// TODO: [cg_YYYY-MM-DD] `.",
		regex: #"// ?(tODO|ToDO|TOdO|TODo|todo|Todo|ToDo|toDo)"#,
		matchingExamples: ["// todo: ", "// toDo: ", "// Todo: ", "// ToDo: ", "//todo: "],
		nonMatchingExamples: ["// TODO: ", "//TODO: "],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: #"// TODO"#,
		autoCorrectExamples: [
			["before": "// todo: ", "after": "// TODO: "],
			["before": "// toDo: ", "after": "// TODO: "],
			["before": "// Todo: ", "after": "// TODO: "],
			["before": "// ToDo: ", "after": "// TODO: "],
			["before": "//todo: ", "after": "// TODO: "]
		]
	)

	// MARK: TodoWhitespacing

	try Lint.checkFileContents(
		checkInfo: "TodoWhitespacing: All TODOs should exactly start like this (mind the whitespacing): `// TODO: `.",
		regex: #"//TODO: *|// TODO:(?=[^ ])|// TODO: {2,}|// {2,}TODO: *|// TODO +|// TODO *(?=\n)"#,
		matchingExamples: ["//TODO: foo", "// TODO foo", "// TODO:foo", "// TODO:   foo", "{\n    // TODO\n}   "],
		nonMatchingExamples: ["// TODO: foo", "// TODO: [cg_2020-02-24] foo"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: #"// TODO: "#,
		autoCorrectExamples: [
			["before": "//TODO: foo", "after": "// TODO: foo"],
			["before": "// TODO foo", "after": "// TODO: foo"],
			["before": "// TODO:foo", "after": "// TODO: foo"],
			["before": "// TODO:   foo", "after": "// TODO: foo"],
			["before": "{\n    // TODO\n}   ", "after": "{\n    // TODO: \n}   "]
		]
	)

	// MARK: TupleIndex

	try Lint.checkFileContents(
		checkInfo: "TupleIndex: Prevent unwrapping tuples by their index – define a typealias with named components instead.",
		regex: #"(\$\d|\w*[^%\d \(\[\{])\.\d[^\w]"#,
		matchingExamples: ["$0.0 ", "$1.2,", "tuple.0)"],
		nonMatchingExamples: ["$0.key ", "tuple.key,", "%1$d of %2$d)"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: UnnecessaryNilAssignment

	try Lint.checkFileContents(
		checkInfo: "UnnecessaryNilAssignment: Don't assign nil as a value when defining an optional type – it's nil by default.",
		regex: #"(\svar +\w+\s*:\s*[^\n=]+\?)\s*=\s*nil"#,
		matchingExamples: ["class MyClass {\n  var count: Int? = nil\n", "class MyClass {\n  var dict: Dictionary<String, AnyObject>? = nil\n"],
		nonMatchingExamples: ["class MyClass {\n  let count: Int? = nil\n", "funct sum(dict: Dictionary<String, AnyObject>? = nil,"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1",
		autoCorrectExamples: [
			["before": "class MyClass {\n  var  count:Int?=nil\n", "after": "class MyClass {\n  var  count:Int?\n"],
			["before": "class MyClass {\n  var dict: Dictionary<String, AnyObject>? = nil\n", "after": "class MyClass {\n  var dict: Dictionary<String, AnyObject>?\n"]
		]
	)

	// MARK: ViewControllerVariableNaming

	try Lint.checkFileContents(
		checkInfo: "ViewControllerVariableNaming: Always name your view controller variables with the suffix `ViewCtrl` or just `viewCtrl`.",
		regex: #"(var|let) +(vc|viewcontroller|viewc|vcontroller)[ :][^\n=]*=\i"#,
		matchingExamples: ["let vc =", "var viewController =", "let viewc =", "let vcontroller =", "var vc: MyViewController =", "let viewController: MyViewController<T> = "],
		nonMatchingExamples: ["let viewCtrl =", "let viewCtrl: MyViewController =", "var myViewCtrl: MyViewController<T> ="],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles]
	)

	// MARK: WhitespaceAfterRangeOperators

	try Lint.checkFileContents(
		checkInfo: "WhitespaceAfterRangeOperators: A range operator should be surrounded by a single whitespace.",
		regex: #"(\w) *(\.\.[<\.])(\w)"#,
		matchingExamples: ["5..<7", "x ..<y", "x ...y", "x...y"],
		nonMatchingExamples: ["5 ..< 7", "5 ... 7", "x ..< y", "x ... y", "// comment ...\n  class"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1 $2 $3",
		autoCorrectExamples: [
			["before": "5...7", "after": "5 ... 7"],
			["before": "x..<y", "after": "x ..< y"],
			["before": "5 ..<7", "after": "5 ..< 7"]
		]
	)

	// MARK: WhitespaceBeforeComment

	try Lint.checkFileContents(
		checkInfo: "WhitespaceBeforeComment: A comment should always be preceded by a single whitespace if on a code line.",
		regex: #"([^:\s/])(?: {0}| {2,})//"#,
		matchingExamples: ["let x = 5// foo", "}//foo", "]  //    foo", "]/// foo"],
		nonMatchingExamples: ["let x = 5 // foo", "} //foo", "] //   foo", "\n  /// foo", #"URL(string: "https://flinesoft.com")"#],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1 //",
		autoCorrectExamples: [
			["before": "let x = 5// foo", "after": "let x = 5 // foo"],
			["before": "}//foo", "after": "} //foo"],
			["before": "]  //    foo", "after": "] //    foo"]
		]
	)

	// MARK: WhitespaceBeforeRangeOperators

	try Lint.checkFileContents(
		checkInfo: "WhitespaceBeforeRangeOperators: A range operator should be surrounded by a single whitespace.",
		regex: #"(\w)(\.\.[<\.]) *(\w)"#,
		matchingExamples: ["5..<7", "5..< 7", "x...y"],
		nonMatchingExamples: ["5 ..< 7", "5 ... 7", "x ..< y", "x ... y", "// comment ... \n  class"],
		includeFilters: [swiftFiles],
		excludeFilters: [testFiles],
		autoCorrectReplacement: "$1 $2 $3",
		autoCorrectExamples: [
			["before": "5...7", "after": "5 ... 7"],
			["before": "x..<y", "after": "x ..< y"],
			["before": "x..< y", "after": "x ..< y"]
		]
	)
}
