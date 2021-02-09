//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class WifiHTTPClientTest: XCTestCase {

	func testWHEN_WifiClient_THEN_wifiOnlyIsActive() {
		// WHEN
		let mockStore = MockTestStore()
		let wifiClient = WifiOnlyHTTPClient(serverEnvironmentProvider: mockStore)

		// THEN
		XCTAssertTrue(wifiClient.isWifiOnlyActive)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiFalse_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let wifiClient = WifiOnlyHTTPClient(serverEnvironmentProvider: mockStore)

		// WHEN
		wifiClient.updateSession(wifiOnly: false)

		// THEN
		XCTAssertFalse(wifiClient.isWifiOnlyActive)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiTrue_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let mockStore = MockTestStore()
		let wifiClient = WifiOnlyHTTPClient(serverEnvironmentProvider: mockStore)

		// WHEN
		wifiClient.updateSession(wifiOnly: true)

		// THEN
		XCTAssertTrue(wifiClient.isWifiOnlyActive)
	}

	func testWHEN_WifiOnlyClient_THEN_disableHourlyDownloadIsFalse() {
		// WHEN
		let mockStore = MockTestStore()
		let wifiClient = WifiOnlyHTTPClient(serverEnvironmentProvider: mockStore)

		// THEN
		XCTAssertFalse(wifiClient.disableHourlyDownload)
	}

	func testGIVEN_WifiOnlyClient_WHEN_DisableHourlyDownloadIsTrue_THEN_NoRequestIsSent() throws {
		let stack = MockNetworkStack( httpStatus: 200, responseData: nil)
		let wifiOnlyHTTPClient = WifiOnlyHTTPClient.makeWith(mock: stack)
		let successExpectation = expectation(description: "ignore request")

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
