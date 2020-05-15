//
//  Onboarding.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

class ENAUITestsOnboarding: XCTestCase {

	override func setUp() {
		continueAfterFailure = false
		
		automaticallyHandleNotificationsDialog()
		automaticallyHandleMicrophonePermissionsDialog()
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testOnboardingFlow() throws {
		let app = XCUIApplication()
		app.launch()

		// need to ensure user is not already onboared
		PersistenceManager.shared.isOnboarded = false
		
		// tap through the onboarding screens
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.finish].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.title])
		
	}
	

}
