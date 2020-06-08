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
		app.launchArguments.append(contentsOf: ["-AppleLocale", "de"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0000_OnboardingFlow_DisablePermissions_normal_XXXL() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[app.localized(AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title)])

		// tap through the onboarding screens
		//snapshot("ScreenShot_\(#function)_0000")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingLetsGo)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0001")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingContinue)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0002")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingDoNotActivate)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0003")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingContinue)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0004")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingDoNotAllow)].tap()
		wait()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertNotNil(app.staticTexts[app.localized(AppStrings.Home.appInformationCardTitle)])
	}

	func test_0001_OnboardingFlow_EnablePermissions_normal_XS() throws {
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertNotNil(app.staticTexts[app.localized(AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title)])

		// tap through the onboarding screens
		//snapshot("ScreenShot_\(#function)_0000")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingLetsGo)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0001")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingContinue)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0002")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0003")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingContinue)].tap()
		wait()
		//snapshot("ScreenShot_\(#function)_0004")
		app.buttons[app.localized(AppStrings.Onboarding.onboardingContinue)].tap()
		wait()

	// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
	XCTAssertNotNil(app.staticTexts[app.localized(AppStrings.Home.appInformationCardTitle)])
	}

}
