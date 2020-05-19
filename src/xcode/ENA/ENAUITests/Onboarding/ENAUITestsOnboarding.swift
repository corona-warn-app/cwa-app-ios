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
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func wait(for seconds: TimeInterval) {
		let expectation = XCTestExpectation(description: "Pause test")
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { expectation.fulfill()}
		wait(for: [expectation], timeout: seconds + 1)

	}

	func tapDontAllow(for alertIdentifier: String, in app: XCUIApplication) {
		let alert = app.alerts[alertIdentifier]
		let exposureNotificationAlertExists = alert.waitForExistence(timeout: 5.0)
		XCTAssertTrue(exposureNotificationAlertExists,"Missing alert")
		alert.scrollViews.otherElements.buttons[Accessibility.Alert.dontAllowButton].tap()
	}

	func tapAllow(for alertIdentifier: String, in app: XCUIApplication) {
		let alert = app.alerts[alertIdentifier]
		let exposureNotificationAlertExists = alert.waitForExistence(timeout: 5.0)
		XCTAssertTrue(exposureNotificationAlertExists,"Missing alert")
		alert.scrollViews.otherElements.buttons[Accessibility.Alert.allowButton].tap()
	}

	func testOnboardingFlow_0000_DisablePermissions() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments += ["-isOnboarded","NO"]

		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)

		// tap through the onboarding screens
		snapshot("ScreenShot_\(#function)_0000")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0001")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0002")
		app.buttons[Accessibility.Button.ignore].tap()
		snapshot("ScreenShot_\(#function)_0003")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0004")
		app.buttons[Accessibility.Button.ignore].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])
		snapshot("ScreenShot_\(#function)_0005")
	}

	func testOnboardingFlow_0001_EnablePermissions() throws {
		let app = XCUIApplication()
		app.setDefaults()
		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)
		
		// tap through the onboarding screens
		snapshot("ScreenShot_\(#function)_0000")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0001")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0002")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0003")
		app.buttons[Accessibility.Button.next].tap()
		snapshot("ScreenShot_\(#function)_0004")
		app.buttons[Accessibility.Button.next].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])
		snapshot("ScreenShot_\(#function)_0005")
	}

//	func testOnboardingFlow_Record() throws {
//	}
	
}

