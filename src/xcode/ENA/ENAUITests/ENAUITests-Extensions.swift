// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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
		self == .normal ? "" : "Accessibility"
	}
}

extension XCUIElement {
	func labelContains(text: String) -> Bool {
		let predicate = NSPredicate(format: "label CONTAINS %@", text)
		return staticTexts.matching(predicate).firstMatch.exists
	}

	func scrollToElement(element: XCUIElement) {
		while !element.visible() {
			swipeUp()
		}
	}

	func visible() -> Bool {
		guard exists, !frame.isEmpty else { return false }
		return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
	}
}

extension XCUIApplication {
	func setDefaults() {
		// launchEnvironment["CW_MODE"] = "mock"
		launchEnvironment["XCUI"] = "YES"
	}

	func setPreferredContentSizeCategory(accessibililty: SizeCategoryAccessibility, size: SizeCategory) {
		// based on https://stackoverflow.com/questions/38316591/how-to-test-dynamic-type-larger-font-sizes-in-ios-simulator
		launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategory\(accessibililty.description())\(size)"]
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
