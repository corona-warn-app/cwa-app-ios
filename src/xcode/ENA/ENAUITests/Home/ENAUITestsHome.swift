//
//  ENAUITestsHome.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 19/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

class ENAUITestsHome: XCTestCase {

    override func setUpWithError() throws {
		continueAfterFailure = false
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHomeFlow_0000() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments += ["-isOnboarded","YES"]

		setPreferredContentSizeCategory(in: app, accessibililty: .normal, size: .M)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts[Accessibility.StaticText.onboardingTitle].exists)
		
		//scrollToElement(element: XCUIElement)
		
    }

}
