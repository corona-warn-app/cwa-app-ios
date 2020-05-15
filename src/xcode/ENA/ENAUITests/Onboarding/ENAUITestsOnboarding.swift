//
//  Onboarding.swift
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

class ENAUITestsOnboarding: XCTestCase {
	
	private func handleAlertTaps(alert: XCUIElement) {
		let okButton = alert.buttons["OK"]
		if okButton.exists {
			okButton.tap()
		}
		
		let allowButton = alert.buttons["Allow"]
		if allowButton.exists {
			allowButton.tap()
		}
	}
	
	override func setUp() {
		continueAfterFailure = false
		
		addUIInterruptionMonitor(withDescription: "Local Notifications") {
			(alert) -> Bool in
			let notifPermission = "Would Like to Send You Notifications"
			if alert.labelContains(text: notifPermission) {
				alert.buttons["Allow"].tap()
				return true
			}
			return false
		}
		
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
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testExample() throws {
		let app = XCUIApplication()
		app.launch()

		// need to ensure user is not already onboared
		PersistenceManager.shared.isOnboarded = false
		
		// tap through the onboarding screens
		app/*@START_MENU_TOKEN@*/.staticTexts["Nächste"]/*[[".buttons[\"Nächste\"].staticTexts[\"Nächste\"]",".staticTexts[\"Nächste\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		app/*@START_MENU_TOKEN@*/.staticTexts["Nächste"]/*[[".buttons[\"Nächste\"].staticTexts[\"Nächste\"]",".staticTexts[\"Nächste\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		app/*@START_MENU_TOKEN@*/.staticTexts["Nächste"]/*[[".buttons[\"Nächste\"].staticTexts[\"Nächste\"]",".staticTexts[\"Nächste\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		app/*@START_MENU_TOKEN@*/.staticTexts["Nächste"]/*[[".buttons[\"Nächste\"].staticTexts[\"Nächste\"]",".staticTexts[\"Nächste\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		app/*@START_MENU_TOKEN@*/.staticTexts["Fertig"]/*[[".buttons[\"Fertig\"].staticTexts[\"Fertig\"]",".staticTexts[\"Fertig\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
		
		// check that the homescreen element "/*@START_MENU_TOKEN@*/.staticTexts["Tracing ist aktiv"]/*[[".cells.staticTexts[\"Tracing ist aktiv\"]",".staticTexts[\"Tracing ist aktiv\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/" is visible onscreen
		XCTAssertNotNil(app.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["Tracing ist aktiv"]/*[[".cells.staticTexts[\"Tracing ist aktiv\"]",".staticTexts[\"Tracing ist aktiv\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/)
	}
	
}
