//
//  Onboarding.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

class ENAUITestsOnboarding_Localized: XCTestCase {

	override func setUp() {
		continueAfterFailure = false
		
		automaticallyHandleNotificationsDialog()
		automaticallyHandleMicrophonePermissionsDialog()
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testOnboardingFlowWithLocalizedStrings() throws {
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
