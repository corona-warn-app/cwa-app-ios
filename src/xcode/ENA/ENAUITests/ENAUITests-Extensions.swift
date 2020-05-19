//
//  ENAUITests-Extensions.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
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
		return self == .normal ? "" : "Accessibility"
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
		guard self.exists && !self.frame.isEmpty else { return false }
		return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
	}
}

extension XCUIApplication {
	func setDefaults() {
		//launchEnvironment["CW_MODE"] = "mock"
		launchEnvironment["XCUI"] = "YES"
	}
	
	func setPreferredContentSizeCategory(accessibililty: SizeCategoryAccessibility, size: SizeCategory) {
		// based on https://stackoverflow.com/questions/38316591/how-to-test-dynamic-type-larger-font-sizes-in-ios-simulator
		launchArguments += [ "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategory\(accessibililty.description())\(size)" ]
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
		return addUIInterruptionMonitor(withDescription: "UIAlert") {
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
		return addUIInterruptionMonitor(withDescription: "UIAlert") {
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
			print("#",#line,#function,alertTitle)
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
			print("#",#line,#function,alertTitle)
			if alert.labelContains(text: alertTitle) {
				alert.buttons["Allow"].tap()
				return true
			}
			return false
		}
	}

}
