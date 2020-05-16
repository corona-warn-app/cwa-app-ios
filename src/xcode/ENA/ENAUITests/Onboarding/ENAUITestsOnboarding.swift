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
		
		// need to ensure user is not already onboarded
		let store = Store()
		store.isOnboarded = false
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
	
	func testOnboardingFlow_0000_EnablePermissionsAndReject() throws {
		let app = XCUIApplication()
		setDefaults(for: app)
		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .XS)
		app.launch()

		let dontAllowHandler = tapDontAllowOnAllDialogs()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)
		
		// tap through the onboarding screens
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()

		removeUIInterruptionMonitor(dontAllowHandler)

		let allowHandler = tapAllowOnAllDialogs()
		app.staticTexts.element(boundBy: 1).tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])
		removeUIInterruptionMonitor(allowHandler)
		
	}

	func testOnboardingFlow_0001_EnablePermissionsAndAccept() throws {
		let app = XCUIApplication()
		setDefaults(for: app)
		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .M)
		app.launch()

		let _ = tapAllowOnAllDialogs()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)

		// tap through the onboarding screens
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
	
		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])
	}

	func testOnboardingFlow_0002_DisablePermissions() throws {
		let app = XCUIApplication()
		setDefaults(for: app)
		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)

		// tap through the onboarding screens
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.ignore].tap()
		app.buttons[Accessibility.Button.next].tap()
		app.buttons[Accessibility.Button.ignore].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

	}

//	func testOnboardingFlow_Record() throws {
//	}
	
}

