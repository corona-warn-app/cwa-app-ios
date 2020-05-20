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
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_0010_HomeFlow_medium() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchEnvironment["isOnboarded"] = "YES"
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .L)
		app.launch()

		NotificationCenter.default.post(name: Notification.Name.isOnboardedDidChange, object: nil)

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		snapshot("ScreenShot_\(#function)_0001")

		// assert cells
		let collectionView = app.collectionViews.element(boundBy:0)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardShareTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardAboutTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.appInformationCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.settingsCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		
    }

    func test_0011_HomeFlow_extrasmall() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchEnvironment["isOnboarded"] = "YES"
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .L)
		app.launch()

		NotificationCenter.default.post(name: Notification.Name.isOnboardedDidChange, object: nil)

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		// assert cells
		let collectionView = app.collectionViews.element(boundBy:0)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardShareTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardAboutTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.appInformationCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.settingsCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		
    }

    func test_0013_HomeFlow_extralarge() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchEnvironment["isOnboarded"] = "YES"
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .L)
		app.launch()

		NotificationCenter.default.post(name: Notification.Name.isOnboardedDidChange, object: nil)

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[Accessibility.StaticText.homeActivateTitle])

		// assert cells
		let collectionView = app.collectionViews.element(boundBy:0)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardShareTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardShareTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.infoCardAboutTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.infoCardAboutTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.appInformationCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.appInformationCardTitle].exists)
		
		collectionView.scrollToElement(element: app.staticTexts[Accessibility.Cell.settingsCardTitle])
		XCTAssert(app.staticTexts[Accessibility.Cell.settingsCardTitle].exists)
		
    }

}
