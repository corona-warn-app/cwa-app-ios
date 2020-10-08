//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest

class ENAUITests_01_Home: XCTestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0010_HomeFlow_medium() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		//snapshot("ScreenShot_\(#function)")
	}

	func test_0011_HomeFlow_extrasmall() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .M)
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		//snapshot("ScreenShot_\(#function)")
	}

	func test_0013_HomeFlow_extralarge() throws {
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .XL)
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))

		app.swipeUp()
		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.infoCardAboutTitle"].waitForExistence(timeout: 5.0))
		app.swipeUp()
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		//snapshot("ScreenShot_\(#function)")
	}
	
	func test_screenshot_homescreen_riskCardIncreased() throws {
		var screenshotCounter = 0
		let riskLevel = "increased"
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .M)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_riskCardLow() throws {
		var screenshotCounter = 0
		let riskLevel = "low"
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .M)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_riskCardInactive() throws {
		var screenshotCounter = 0
		let riskLevel = "inactive"
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .M)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")

	}
	
	func test_screenshot_homescreen_riskCardUnknownUnknownInitial() throws {
		var screenshotCounter = 0
		let riskLevel = "unknownInitial"
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .M)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
	
	func test_screenshot_homescreen_riskCardUnknownUnknownOutdated() throws {
		var screenshotCounter = 0
		let riskLevel = "unknownOutdated"
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .M)
		app.launchArguments.append(contentsOf: ["-riskLevel", riskLevel])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		snapshot("homescreenrisk_level_\(riskLevel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}

private extension Int {
	mutating func inc() -> Int {
		self += 1
		return self
	}
}
