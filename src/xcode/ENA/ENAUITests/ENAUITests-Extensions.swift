//
// 🦠 Corona-Warn-App
//

import XCTest

enum SizeCategory: String {
	case XS
	case S
	case M
	case L
	case XL
	case XXL
	case XXXL
}

enum SizeCategoryAccessibility: String {
	case accessibility = "Accessibility"
	case normal = ""
	func description() -> String {
		return self.rawValue
	}
}

extension XCUIElement {
	func labelContains(text: String) -> Bool {
		let predicate = NSPredicate(format: "label CONTAINS %@", text)
		return staticTexts.matching(predicate).firstMatch.exists
	}

	func visible() -> Bool {
		guard exists, !frame.isEmpty else { return false }
		return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
	}
}

extension XCUIElementQuery {
	var lastMatch: XCUIElement { return element(boundBy: count - 1) }
}

extension XCUIApplication {
	func setDefaults() {
		// launchEnvironment["CW_MODE"] = "mock"
		launchEnvironment["XCUI"] = "YES"
	}

	func setPreferredContentSizeCategory(accessibility: SizeCategoryAccessibility, size: SizeCategory) {
		// based on https://stackoverflow.com/questions/38316591/how-to-test-dynamic-type-larger-font-sizes-in-ios-simulator
		launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategory\(accessibility.description())\(size)"]
	}

	func localized(_ key: String) -> String {
		let testBundle = Bundle(for: Snapshot.self)
		if let currentLanguage = currentLanguage,
			let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ?? testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
			let localizedBundle = Bundle(path: testBundlePath) {
			return NSLocalizedString(key, bundle: localizedBundle, comment: "")
		}
		return ""
	}

	private var currentLanguage: (langCode: String, localeCode: String)? {
		guard let preferredLanguage = Locale.preferredLanguages.first else {
			fatalError("Cant unwrap: Locale.preferredLanguages.first")
		}
		let currentLocale = Locale(identifier: preferredLanguage)
		guard let langCode = currentLocale.languageCode else {
			return nil
		}
		var localeCode = langCode
		if let scriptCode = currentLocale.scriptCode {
			localeCode = "\(langCode)-\(scriptCode)"
		} else if let regionCode = currentLocale.regionCode {
			localeCode = "\(langCode)-\(regionCode)"
		}
		return (langCode, localeCode)
	}
}

extension XCTestCase {
	func wait(for seconds: TimeInterval = 0.2) {
		let expectation = XCTestExpectation(description: "Pause test")
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { expectation.fulfill() }
		wait(for: [expectation], timeout: seconds + 1)
	}
}
