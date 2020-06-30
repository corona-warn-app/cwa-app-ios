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

class ENAUITests_00_Onboarding: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments += ["-AppleLanguages", "(de)"]
		app.launchArguments += ["-AppleLocale", "de_DE"]
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0000_OnboardingFlow_DisablePermissions_normal_XXXL() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		//snapshot("ScreenShot_\(#function)_0000")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		//snapshot("ScreenShot_\(#function)_0001")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		//snapshot("ScreenShot_\(#function)_0002")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		//snapshot("ScreenShot_\(#function)_0003")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		//snapshot("ScreenShot_\(#function)_0004")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
	}

	func test_0001_OnboardingFlow_EnablePermissions_normal_XS() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		//snapshot("ScreenShot_\(#function)_0000")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		//snapshot("ScreenShot_\(#function)_0001")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		//snapshot("ScreenShot_\(#function)_0002")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		//snapshot("ScreenShot_\(#function)_0003")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		//snapshot("ScreenShot_\(#function)_0004")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
	}

}
