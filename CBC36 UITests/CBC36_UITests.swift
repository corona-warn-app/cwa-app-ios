//
//  CBC36_UITests.swift
//  CBC36 UITests
//
//  Created by tcfos on 26.12.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import XCTest
@testable import Call_by_Color_36

class CBC36_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        AccessibilityLabels.printLabels(app.staticTexts)
        AccessibilityLabels.printLabels(app.buttons)

        let settingsLabel = String(format: AccessibilityLabels.localized(AppStrings.home.settings))
        XCTAssert(app.buttons[settingsLabel].waitForExistence(timeout: .short))
        XCTAssert(app.staticTexts["Kate Bell"].waitForExistence(timeout: .short))
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
