//
//  Onboarding.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 14/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

class ENAUITestsOnboarding: XCTestCase {

    var app: XCUIApplication!

	override func setUp() {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
        app.launchArguments = ["-isOnboarded", "NO"]
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func test_0000_OnboardingFlow_DisablePermissions_normal_XXXL() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XXXL)
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
	}

	func test_0001_OnboardingFlow_EnablePermissions_normal_XS() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
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
	}

	func testOnboardingFlow_Record() throws {
	}
	
}

