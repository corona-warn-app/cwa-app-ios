//
//  ENAUITestsHome.swift
//  ENAUITests
//
//  Created by Dunne, Liam on 19/05/2020.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest

class ENAUITestsHome: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
        app.setDefaults()
        app.launchArguments = ["-isOnboarded", "YES"]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_0010_HomeFlow_medium() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		app.swipeUp()
		// assert cells
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		snapshot("ScreenShot_\(#function)")

    }

    func test_0011_HomeFlow_extrasmall() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .M)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		app.swipeUp()
		// assert cells
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		snapshot("ScreenShot_\(#function)")

    }

    func test_0013_HomeFlow_extralarge() throws {
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .XL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		app.swipeUp()
		app.swipeUp()
		// assert cells
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		app.swipeUp()
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		snapshot("ScreenShot_\(#function)")
    }

}
