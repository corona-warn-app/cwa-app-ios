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
@testable import ENA

class HomeViewControllerTests: XCTestCase {

	/// Creates a dummy HomeViewController. Currently used for testing the background fetching alert only.
	func setupDummyHomeVC() -> HomeViewController {
		return AppStoryboard.home.initiate(viewControllerType: HomeViewController.self) { coder in
			HomeViewController(
				coder: coder,
				delegate: MockHomeViewControllerDelegate(),
				detectionMode: .automatic,
				exposureManagerState: .init(authorized: true, enabled: true, status: .active),
				initialEnState: .enabled,
				risk: .none
			)
		}
	 }

	/// This test checks that no alert is created when the device
	///  has the following three conditions:
	/// - background fetching is .available
	/// - not in low power mode
	/// - has not seen the alert before
	func testNoBackgroundFetchingAlertShown() {
		let vc = setupDummyHomeVC()

		let alert = vc.createBackgroundFetchAlert(
			status: .available,
			inLowPowerMode: false,
			hasSeenAlertBefore: false
		)

		XCTAssertNil(alert)
	}

	/// This test checks that an alert is created when the device
	///  has the following three conditions:
	/// - background fetching is .denied
	/// - not in low power mode
	/// - has not seen the alert before
	func testBackgroundFetchingAlertShown() {
		let vc = setupDummyHomeVC()

		let alert = vc.createBackgroundFetchAlert(
			status: .denied,
			inLowPowerMode: false,
			hasSeenAlertBefore: false
		)

		XCTAssertNotNil(alert)
	}

	/// This test checks that an alert is created when the device
	///  has the following three conditions:
	/// - background fetching is .restricted
	/// - not in low power mode
	/// - has not seen the alert before
	func testBackgroundFetchingAlertShownWhenRestricted() {
		let vc = setupDummyHomeVC()

		let alert = vc.createBackgroundFetchAlert(
			status: .restricted,
			inLowPowerMode: false,
			hasSeenAlertBefore: false
		)

		XCTAssertNotNil(alert)
	}

	/// This test checks that an alert is not created when the device
	///  has the following three conditions:
	/// - background fetching is .denied
	/// - is in low power mode
	/// - has not seen the alert before
	func testNoBackgroundFetchingAlertShownWhenInLowPower() {
		let vc = setupDummyHomeVC()

		let alert = vc.createBackgroundFetchAlert(
			status: .denied,
			inLowPowerMode: true,
			hasSeenAlertBefore: false
		)

		XCTAssertNil(alert)
	}

	/// This test checks that an alert is not created when the device
	///  has the following three conditions:
	/// - background fetching is .denied
	/// - is not in low power mode
	/// - has seen the alert before
	func testNoBackgroundFetchingAlertShownWhenSeenOnce() {
		let vc = setupDummyHomeVC()

		let alert = vc.createBackgroundFetchAlert(
			status: .denied,
			inLowPowerMode: false,
			hasSeenAlertBefore: true
		)

		XCTAssertNil(alert)
	}

}
