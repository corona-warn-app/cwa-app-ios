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

import XCTest

class ENAUITestsOnboarding: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
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

}
