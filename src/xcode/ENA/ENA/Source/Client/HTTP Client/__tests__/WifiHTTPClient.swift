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

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class WifiHTTPClientTest: XCTestCase {

	func testWHEN_WifiClient_THEN_wifiOnlyIsActive() {
		// WHEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, true)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiFalse_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// WHEN
		wifiClient.updateSession(wifiOnly: false)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, false)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiTrue_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// WHEN
		wifiClient.updateSession(wifiOnly: true)

		// THEN
		XCTAssertEqual(wifiClient.isWifiOnlyActive, true)
	}

	func testWHEN_WifiOnlyClient_THEN_disableHourlyDownloadIsFalse() {
		// WHEN
		let mockStore = MockTestStore()
		let configuration = HTTPClient.Configuration.makeDefaultConfiguration(store: mockStore)
		let wifiClient = WifiOnlyHTTPClient(configuration: configuration)

		// THEN
		XCTAssertEqual(wifiClient.disableHourlyDownload, false)
	}

	func testGIVEN_WifiOnlyClient_WHEN_DisableHourlyDownloadIsTrue_THEN_NoRequestIsSent() throws {
		let stack = MockNetworkStack( httpStatus: 200, responseData: nil)
		let wifiOnlyHTTPClient = WifiOnlyHTTPClient.with(mock: stack)

		let successExpectation = expectation(description: "ignore request")
		successExpectation.isInverted = true

		// WHEN
		wifiOnlyHTTPClient.disableHourlyDownload = true

		// THEN
		wifiOnlyHTTPClient.fetchHour(12, day: .formattedToday(), country: "DE") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("request wasn't ignored but this was expected")
			case .failure:
				break
			}
		}
		waitForExpectations(timeout: .medium)
	}

}
