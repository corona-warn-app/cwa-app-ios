//
//  ENAUITests-Extensions.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

extension XCUIElement {
	func labelContains(text: String) -> Bool {
		let predicate = NSPredicate(format: "label CONTAINS %@", text)
		return staticTexts.matching(predicate).firstMatch.exists
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

	func local(_ key: String) -> String {
		let testBundle = Bundle(for: PersistenceManager.self)
		if let currentLanguage = currentLanguage,
			let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ?? testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
			let localizedBundle = Bundle(path: testBundlePath)
		{
			return NSLocalizedString(key, bundle: localizedBundle, comment: "")
		}
		return "?"
	}
	
	func handleAlertTaps(alert: XCUIElement) {
		let okButton = alert.buttons["OK"]
		if okButton.exists {
			okButton.tap()
		}
		
		let allowButton = alert.buttons["Allow"]
		if allowButton.exists {
			allowButton.tap()
		}
	}

	func automaticallyHandleNotificationsDialog() {
		addUIInterruptionMonitor(withDescription: "Local Notifications") {
			(alert) -> Bool in
			let notifPermission = "Would Like to Send You Notifications"
			if alert.labelContains(text: notifPermission) {
				alert.buttons["Allow"].tap()
				return true
			}
			return false
		}
	}
	
	func automaticallyHandleMicrophonePermissionsDialog() {
		addUIInterruptionMonitor(withDescription: "Microphone Access") {
			(alert) -> Bool in
			let micPermission = "Would Like to Access the Microphone"
			if alert.labelContains(text: micPermission) {
				alert.buttons["OK"].tap()
				return true
			}
			return false
		}
	}
	
}
