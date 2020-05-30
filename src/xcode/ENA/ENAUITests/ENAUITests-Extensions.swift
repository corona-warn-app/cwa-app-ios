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

	func tapDontAllow(for alertIdentifier: String) {
		let alert = alerts[alertIdentifier]
		let exposureNotificationAlertExists = alert.waitForExistence(timeout: 5.0)
		XCTAssertTrue(exposureNotificationAlertExists, "Missing alert")
		alert.scrollViews.otherElements.buttons[Accessibility.Alert.dontAllowButton].tap()
	}

	func tapAllow(for alertIdentifier: String) {
		let alert = alerts[alertIdentifier]
		let exposureNotificationAlertExists = alert.waitForExistence(timeout: 5.0)
		XCTAssertTrue(exposureNotificationAlertExists, "Missing alert")
		alert.scrollViews.otherElements.buttons[Accessibility.Alert.allowButton].tap()
	}
}

extension XCTestCase {
	var currentLanguage: (langCode: String, localeCode: String)? {
		let currentLocale = Locale(identifier: Locale.preferredLanguages.first!)
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

	func tapAllowOnAllDialogs() -> NSObjectProtocol {
		addUIInterruptionMonitor(withDescription: "UIAlert") {
			(alert) -> Bool in
			let okButton = alert.buttons[Accessibility.Alert.allowButton]
			let allowButton = alert.buttons[Accessibility.Alert.okButton]
			let firstButton = alert.buttons.element(boundBy: 1)
			if okButton.exists {
				okButton.tap()
			} else if allowButton.exists {
				allowButton.tap()
			} else if firstButton.exists {
				firstButton.tap()
			}
			return true
		}
	}

	func tapDontAllowOnAllDialogs() -> NSObjectProtocol {
		addUIInterruptionMonitor(withDescription: "UIAlert") {
			(alert) -> Bool in
			let dontAllowButton = alert.buttons[Accessibility.Alert.dontAllowButton]
			let cancelButton = alert.buttons[Accessibility.Alert.cancelButton]
			let firstButton = alert.buttons.firstMatch
			if dontAllowButton.exists {
				dontAllowButton.tap()
			} else if cancelButton.exists {
				cancelButton.tap()
			} else if firstButton.exists {
				firstButton.tap()
			}
			return true
		}
	}

	func tapAllowOnLocalNotificationsDialog() {
		addUIInterruptionMonitor(withDescription: "Local Notifications") {
			(alert) -> Bool in
			let alertTitle = "Would Like to Send You Notifications"
			print("#", #line, #function, alertTitle)
			if alert.labelContains(text: alertTitle) {
				alert.buttons["Allow"].tap()
				return true
			}
			return false
		}
	}

	func tapAllowOnCOVID19ExposureNotificationsDialog() {
		addUIInterruptionMonitor(withDescription: "COVID-19 Exposure Notifications") {
			(alert) -> Bool in
			let alertTitle = "Enable COVID-19 Exposure Notifications"
			print("#", #line, #function, alertTitle)
			if alert.labelContains(text: alertTitle) {
				alert.buttons["Allow"].tap()
				return true
			}
			return false
		}
	}

	func wait(for seconds: TimeInterval) {
		let expectation = XCTestExpectation(description: "Pause test")
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { expectation.fulfill() }
		wait(for: [expectation], timeout: seconds + 1)
	}
}
