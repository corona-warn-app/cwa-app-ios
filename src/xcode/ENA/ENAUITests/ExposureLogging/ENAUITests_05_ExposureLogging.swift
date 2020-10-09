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

class ENAUITests_05_ExposureLogging: XCTestCase {
	
	var app: XCUIApplication!

    override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_screenshot_exposureLogging() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibililty: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launch()

		// only run if home screen is present
		XCTAssert(app.buttons["AppStrings.Home.rightBarButtonDescription"].waitForExistence(timeout: 5.0))
		
		app.cells["AppStrings.Home.activateCardOnTitle"].tap()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.swipeUp()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}

private extension Int {
	mutating func inc() -> Int {
		self += 1
		return self
	}
}
