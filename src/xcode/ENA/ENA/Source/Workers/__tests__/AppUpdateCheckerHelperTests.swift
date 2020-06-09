//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

@testable import ENA
import FMDB
import XCTest

final class AppUpdateCheckerHelperTests: XCTestCase {

	private var mockClient: ClientMock!
	private var mockStore: MockTestStore!
	private var appUpdateChecker: AppUpdateCheckHelper!
	private let currentVersion = "1.0.0"

	override func setUp() {
		super.setUp()
		// Old DB is deinited and hence connection closed at every setUp() call
		mockClient = ClientMock(submissionError: .requestCouldNotBeBuilt)
		mockStore = MockTestStore()
		appUpdateChecker = AppUpdateCheckHelper(client: mockClient, store: mockStore)
	}

	func testAlertType_none() {
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.1.0", latestVersion: "1.0.0") == .none)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.0.0", latestVersion: "0.0.0") == .none)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.99.99", latestVersion: "0.99.99") == .none)
	}

	func testAlertType_update() {
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.1.0", latestVersion: "1.1.0") == .update)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.0.0", latestVersion: "99.99.99") == .update)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "0.1.99", latestVersion: "99.99.99") == .update)

	}

	func testAlertType_forceUpdate() {
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "1.1.0", latestVersion: "1.1.0") == .forceUpdate)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "99.99.99", latestVersion: "99.99.99") == .forceUpdate)
		XCTAssert(appUpdateChecker.compareVersion(currentVersion: currentVersion, minVersion: "1.0.1", latestVersion: "1.0.1") == .forceUpdate)
	}

	func testAlert_none() {
		let alert = appUpdateChecker.createAlert(.none, vc: nil)
		XCTAssertNil(alert)
	}

	func testAlert_update() {
		let alert = appUpdateChecker.createAlert(.update, vc: nil)
		XCTAssertNotNil(alert)
		XCTAssert(alert?.actions.count == 2)
	}

	func testAlert_forceUpdate() {
		let alert = appUpdateChecker.createAlert(.forceUpdate, vc: nil)
		XCTAssertNotNil(alert)
		XCTAssert(alert?.actions.count == 1)
	}

}
