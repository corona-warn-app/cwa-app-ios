//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import ExposureNotification


class WifiHTTPClientTest: CWATestCase {

	func testWHEN_WifiClient_THEN_wifiOnlyIsActive() {
		// WHEN
		let wifiClient = WifiOnlyHTTPClient()

		// THEN
		XCTAssertTrue(wifiClient.isWifiOnlyActive)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiFalse_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let wifiClient = WifiOnlyHTTPClient()

		// WHEN
		wifiClient.updateSession(wifiOnly: false)

		// THEN
		XCTAssertFalse(wifiClient.isWifiOnlyActive)
	}

	func testGIVEN_WifiOnlyClient_WHEN_updateSessionWifiTrue_THEN_WifiOnlyIsDisabled() {
		// GIVEN
		let wifiClient = WifiOnlyHTTPClient()

		// WHEN
		wifiClient.updateSession(wifiOnly: true)

		// THEN
		XCTAssertTrue(wifiClient.isWifiOnlyActive)
	}

	func testWHEN_WifiOnlyClient_THEN_disableHourlyDownloadIsFalse() {
		// WHEN
		let wifiClient = WifiOnlyHTTPClient()

		// THEN
		XCTAssertFalse(wifiClient.disableHourlyDownload)
	}

}
