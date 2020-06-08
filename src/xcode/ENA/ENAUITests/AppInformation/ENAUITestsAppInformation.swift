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

class ENAUITests_02_AppInformation: XCTestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-AppleLocale", "de"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0020_AppInformationFlow() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.aboutNavigation)].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.faqNavigation)].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.contactNavigation)].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.privacyNavigation)].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.termsNavigation)].waitForExistence(timeout: 5.0))

	}

	func test_0021_AppInformationFlow_about() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.aboutNavigation)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.AppInformation.aboutNavigation)].tap()

		XCTAssert(app.staticTexts[app.localized(AppStrings.AppInformation.aboutTitle)].waitForExistence(timeout: 5.0))
	}

	func test_0022_AppInformationFlow_faq() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.faqNavigation)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.AppInformation.faqNavigation)].tap()

		XCTAssert(app.staticTexts["Done"].waitForExistence(timeout: 5.0))
	}

	func test_0023_AppInformationFlow_contact() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.contactNavigation)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.AppInformation.contactNavigation)].tap()

		XCTAssert(app.staticTexts[app.localized(AppStrings.AppInformation.contactTitle)].waitForExistence(timeout: 5.0))
	}

	func test_0024_AppInformationFlow_privacy() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.privacyNavigation)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.AppInformation.privacyNavigation)].tap()

		XCTAssert(app.staticTexts[app.localized(AppStrings.AppInformation.privacyTitle)].waitForExistence(timeout: 5.0))
	}

	func test_0025_AppInformationFlow_terms() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[app.localized(AppStrings.Home.rightBarButtonDescription)].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.Home.appInformationCardTitle)].tap()

		XCTAssert(app.cells[app.localized(AppStrings.AppInformation.termsNavigation)].waitForExistence(timeout: 5.0))
		app.cells[app.localized(AppStrings.AppInformation.termsNavigation)].tap()

		XCTAssert(app.staticTexts[app.localized(AppStrings.AppInformation.termsTitle)].waitForExistence(timeout: 5.0))
	}

}
