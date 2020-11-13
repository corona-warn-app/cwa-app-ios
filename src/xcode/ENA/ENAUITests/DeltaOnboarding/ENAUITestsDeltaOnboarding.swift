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

class ENAUITests_06_DeltaOnboarding: XCTestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
	}

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}

		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		
		// Close (X) Button
		XCTAssertTrue(XCUIApplication().navigationBars["ENA.DeltaOnboardingV15View"].buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5))
		
		// Continue Button
		XCTAssertTrue(XCUIApplication().buttons["AppStrings.DeltaOnboarding.primaryButton"].waitForExistence(timeout: 5))
		XCUIApplication().buttons["AppStrings.DeltaOnboarding.primaryButton"].tap()
	}
	
	func test_screenshotDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_V15"
		
		
		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		
	}

}
