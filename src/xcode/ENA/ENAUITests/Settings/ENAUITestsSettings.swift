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

class ENAUITests_03_Settings: XCTestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
	}

	func test_0030_SettingsFlow() throws {
		app.launch()
		
		app.swipeUp()

		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()
		
		XCTAssert(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Settings.notificationLabel"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.Settings.resetLabel"].waitForExistence(timeout: 5.0))
	}
	
	
	func test_0031_SettingsFlow_BackgroundAppRefresh() throws {
		app.launch()
		
		app.swipeUp()

		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()
		
		XCTAssert(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].tap()
		
		XCTAssert(app.images["AppStrings.Settings.backgroundAppRefreshImageDescription"].waitForExistence(timeout: 5.0))
	}
}
